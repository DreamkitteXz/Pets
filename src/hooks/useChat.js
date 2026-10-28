import { useState, useEffect, useRef, useCallback } from 'react';
import {
  collection, doc, addDoc, setDoc, updateDoc, getDocs, onSnapshot,
  orderBy, query, where, limit, startAfter, serverTimestamp,
} from 'firebase/firestore';
import { httpsCallable } from 'firebase/functions';
import { ref, uploadBytes } from 'firebase/storage';
import imageCompression from 'browser-image-compression';
import { db, functions, storage } from '../config/firebase';
import { useAuth } from '../context/AuthContext';

// Mesmos limites da storage.rules e da firestore.rules.
export const ATTACHMENT_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];
const ATTACHMENT_MAX = 10 * 1024 * 1024;

const openConversationFn = httpsCallable(functions, 'openConversation', { timeout: 20000 });

// Paginação é o que controla o custo do chat: cada documento entregue a um
// listener é uma leitura. A lista escuta só as 20 conversas mais recentes e a
// conversa aberta só as últimas 30 mensagens; as antigas vêm sob demanda.
const CONVERSATIONS_LIMIT = 20;
const PAGE = 30;
// Sem isto, a mensagem recém-enviada aparece sem horário até o servidor confirmar.
const SNAP = { serverTimestamps: 'estimate' };

const toMsg = (d) => ({ id: d.id, ...d.data(SNAP) });

/** Abre (ou reaproveita) a conversa — só o servidor cria, conferindo o vínculo. */
export async function openConversation({ petId, vetId }) {
  const { data } = await openConversationFn({ petId, ...(vetId ? { vetId } : {}) });
  return data.conversaId;
}

/** Lista de conversas do usuário (vet ou tutor), ao vivo. */
function useConversationList() {
  const { user, userProfile } = useAuth();
  const [conversations, setConversations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const field = userProfile?.role === 'tutor' ? 'tutorId' : 'vetId';

  useEffect(() => {
    if (!user?.uid || !userProfile?.role) return undefined;
    const q = query(
      collection(db, 'conversas'),
      where(field, '==', user.uid),
      orderBy('lastMessageAt', 'desc'),
      limit(CONVERSATIONS_LIMIT),
    );
    return onSnapshot(q, (snap) => {
      setConversations(snap.docs.map((d) => ({ id: d.id, ...d.data(SNAP) })));
      setLoading(false);
    }, (err) => { setError(err); setLoading(false); });
  }, [user?.uid, userProfile?.role, field]);

  return { conversations, loading, error };
}

/** Total de conversas com mensagens não lidas (badge do cabeçalho). */
export function useChatUnread() {
  const { user } = useAuth();
  const { conversations } = useConversationList();
  return conversations.filter((c) => (c.unread?.[user?.uid] || 0) > 0).length;
}

export function useChat() {
  const { user } = useAuth();
  const uid = user?.uid;
  const { conversations, loading: loadingConversations, error: listError } = useConversationList();
  const [activeConversaId, setActiveConversaId] = useState(null);
  const [recent, setRecent] = useState([]);   // últimas PAGE, ao vivo
  const [older, setOlder] = useState([]);     // páginas anteriores, sob demanda
  const [hasMore, setHasMore] = useState(false);
  const [loadingMessages, setLoadingMessages] = useState(false);
  const [loadingOlder, setLoadingOlder] = useState(false);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState(null);
  const oldestRef = useRef(null);

  const active = conversations.find((c) => c.id === activeConversaId) || null;

  // Mensagens da conversa aberta: listener só nas últimas PAGE.
  useEffect(() => {
    setRecent([]);
    setOlder([]);
    setHasMore(false);
    oldestRef.current = null;
    if (!activeConversaId) return undefined;
    setLoadingMessages(true);
    const q = query(collection(db, 'conversas', activeConversaId, 'mensagens'), orderBy('createdAt', 'desc'), limit(PAGE));
    return onSnapshot(q, (snap) => {
      setRecent(snap.docs.map(toMsg).reverse());
      if (!oldestRef.current) {
        oldestRef.current = snap.docs[snap.docs.length - 1] || null;
        setHasMore(snap.docs.length === PAGE);
      }
      setLoadingMessages(false);
    }, (err) => { setError(err); setLoadingMessages(false); });
  }, [activeConversaId]);

  const loadOlder = useCallback(async () => {
    if (!activeConversaId || !oldestRef.current || loadingOlder) return;
    setLoadingOlder(true);
    try {
      const snap = await getDocs(query(
        collection(db, 'conversas', activeConversaId, 'mensagens'),
        orderBy('createdAt', 'desc'), startAfter(oldestRef.current), limit(PAGE),
      ));
      oldestRef.current = snap.docs[snap.docs.length - 1] || oldestRef.current;
      setOlder((prev) => [...snap.docs.map(toMsg).reverse(), ...prev]);
      setHasMore(snap.docs.length === PAGE);
    } catch (err) {
      setError(err);
    } finally {
      setLoadingOlder(false);
    }
  }, [activeConversaId, loadingOlder]);

  // Marca como lida só quando há não lidas para mim — uma gravação por leitura,
  // não por mensagem (o "visto" do outro lado usa lastReadAt).
  const myUnread = active?.unread?.[uid] || 0;
  useEffect(() => {
    if (!activeConversaId || !uid || myUnread === 0) return;
    updateDoc(doc(db, 'conversas', activeConversaId), {
      [`lastReadAt.${uid}`]: serverTimestamp(),
      [`unread.${uid}`]: 0,
    }).catch(() => {});
  }, [activeConversaId, uid, myUnread]);

  const sendMessage = useCallback(async (texto) => {
    const clean = (texto || '').trim();
    if (!activeConversaId || !clean || !uid) return;
    setSending(true);
    setError(null);
    try {
      await addDoc(collection(db, 'conversas', activeConversaId, 'mensagens'), {
        senderId: uid,
        texto: clean.slice(0, 4000),
        tipo: 'texto',
        createdAt: serverTimestamp(),
      });
    } catch (err) {
      setError(err);
      throw err;
    } finally {
      setSending(false);
    }
  }, [activeConversaId, uid]);

  // Anexo (foto ou PDF): sobe o arquivo em chat/{conversa}/{mensagem}/… e só
  // então grava a mensagem apontando para ele (a rule confere o caminho).
  const sendAttachment = useCallback(async (file, caption = '') => {
    if (!activeConversaId || !file || !uid) return;
    setSending(true);
    setError(null);
    try {
      let blob = file;
      let contentType = file.type;
      let name = file.name || 'arquivo';
      if (/^image\/(jpeg|png|webp)$/.test(contentType)) {
        // Recomprimir corta o maior custo do chat (download de fotos) e tira o
        // EXIF (pode ter o GPS da casa do tutor). Sem web worker: a CSP do site
        // não libera o script que a biblioteca buscaria em CDN.
        blob = await imageCompression(file, { maxWidthOrHeight: 1600, initialQuality: 0.8, fileType: 'image/jpeg', useWebWorker: false });
        contentType = 'image/jpeg';
        name = name.replace(/\.[^.]+$/, '') + '.jpg';
      }
      if (!ATTACHMENT_TYPES.includes(contentType)) throw Object.assign(new Error('Tipo de arquivo não aceito. Envie foto (JPG, PNG, WebP) ou PDF.'), { code: 'chat/type' });
      if (blob.size > ATTACHMENT_MAX) throw Object.assign(new Error('Arquivo maior que 10 MB.'), { code: 'chat/size' });

      const msgRef = doc(collection(db, 'conversas', activeConversaId, 'mensagens'));
      const safe = name.normalize('NFD').replace(/[^\w.-]+/g, '_').slice(-80) || 'arquivo';
      const path = `chat/${activeConversaId}/${msgRef.id}/${safe}`;
      await uploadBytes(ref(storage, path), blob, { contentType });
      await setDoc(msgRef, {
        senderId: uid,
        tipo: 'anexo',
        texto: (caption || '').trim().slice(0, 4000),
        anexo: { path, name: name.slice(0, 200), contentType, size: blob.size },
        createdAt: serverTimestamp(),
      });
    } catch (err) {
      setError(err);
      throw err;
    } finally {
      setSending(false);
    }
  }, [activeConversaId, uid]);

  return {
    sendAttachment,
    conversations,
    activeConversaId,
    activeConversation: active,
    messages: [...older, ...recent],
    hasMore,
    loadOlder,
    loadingOlder,
    loadingConversations,
    loadingMessages,
    sending,
    error: error || listError,
    selectConversation: setActiveConversaId,
    sendMessage,
  };
}
