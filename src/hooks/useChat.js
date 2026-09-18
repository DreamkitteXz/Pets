import { useState, useEffect, useRef, useCallback } from 'react';
import {
  collection, doc, getDocs, addDoc, setDoc, updateDoc,
  orderBy, query, where, serverTimestamp, getDoc,
} from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';
import { toMillis } from '../utils/dates';

const POLL_MS = 5000;

export function useChat() {
  const { user, userProfile } = useAuth();
  const [conversations, setConversations] = useState([]);
  const [activeConversaId, setActiveConversaId] = useState(null);
  const [messages, setMessages] = useState([]);
  const [loadingConversations, setLoadingConversations] = useState(true);
  const [loadingMessages, setLoadingMessages] = useState(false);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState(null);
  const pollRef = useRef(null);

  // ── Fetch conversation list for this vet ──────────────────────────────────
  const fetchConversations = useCallback(async () => {
    if (!user) return;
    try {
      // Query scoped to the vet so it complies with the security rules
      // (rules are not filters — querying the whole collection would fail).
      // Sorted client-side to avoid requiring a composite index.
      const snap = await getDocs(
        query(collection(db, 'conversas'), where('vetId', '==', user.uid))
      );
      const all = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      all.sort((a, b) => toMillis(b.lastMessageAt) - toMillis(a.lastMessageAt));
      setConversations(all);
    } catch (err) {
      setError(err);
    } finally {
      setLoadingConversations(false);
    }
  }, [user]);

  useEffect(() => {
    fetchConversations();
  }, [fetchConversations]);

  // ── Fetch messages for active conversation (polling) ──────────────────────
  const fetchMessages = useCallback(async (conversaId) => {
    if (!conversaId) return;
    try {
      const snap = await getDocs(
        query(collection(db, 'conversas', conversaId, 'mensagens'), orderBy('timestamp', 'asc'))
      );
      setMessages(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    } catch (err) {
      setError(err);
    }
  }, []);

  const selectConversation = useCallback((conversaId) => {
    clearInterval(pollRef.current);
    setActiveConversaId(conversaId);
    setMessages([]);
    setLoadingMessages(true);

    fetchMessages(conversaId).then(() => setLoadingMessages(false));

    pollRef.current = setInterval(() => fetchMessages(conversaId), POLL_MS);
  }, [fetchMessages]);

  useEffect(() => {
    return () => clearInterval(pollRef.current);
  }, []);

  // ── Send message ──────────────────────────────────────────────────────────
  const sendMessage = useCallback(async (texto) => {
    if (!activeConversaId || !texto.trim() || !user) return;
    setSending(true);
    try {
      await addDoc(collection(db, 'conversas', activeConversaId, 'mensagens'), {
        remetente: user.uid,
        texto: texto.trim(),
        timestamp: serverTimestamp(),
        lida: false,
      });
      await updateDoc(doc(db, 'conversas', activeConversaId), {
        lastMessage: texto.trim(),
        lastMessageAt: serverTimestamp(),
      });
      await fetchMessages(activeConversaId);
      await fetchConversations();
    } catch (err) {
      setError(err);
    } finally {
      setSending(false);
    }
  }, [activeConversaId, user, fetchMessages, fetchConversations]);

  // ── Start a new conversation with a tutor ────────────────────────────────
  const startConversation = useCallback(async (tutorId, tutorName, petId, petName) => {
    if (!user || !userProfile) return null;
    const conversaId = `${user.uid}_${tutorId}`;
    const ref = doc(db, 'conversas', conversaId);
    const snap = await getDoc(ref);
    if (!snap.exists()) {
      await setDoc(ref, {
        vetId: user.uid,
        tutorId,
        petId: petId || null,
        petName: petName || '',
        vetName: userProfile.name || '',
        tutorName: tutorName || '',
        lastMessage: '',
        lastMessageAt: serverTimestamp(),
        createdAt: serverTimestamp(),
      });
    }
    await fetchConversations();
    selectConversation(conversaId);
    return conversaId;
  }, [user, userProfile, fetchConversations, selectConversation]);

  return {
    conversations,
    activeConversaId,
    messages,
    loadingConversations,
    loadingMessages,
    sending,
    error,
    selectConversation,
    sendMessage,
    startConversation,
    refresh: fetchConversations,
  };
}
