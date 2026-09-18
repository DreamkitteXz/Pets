import { useState, useCallback, useSyncExternalStore } from 'react';
import { chatMock } from '../services/chatMock';
import { useAuth } from '../context/AuthContext';

/**
 * Hook que serve a tela de Chat a partir do mock (src/services/chatMock.js).
 * Expõe a MESMA interface que a UI consome — trocar pela fonte real depois é
 * só substituir este hook/import, sem tocar nos componentes.
 */
export function useChatMock() {
  const { user } = useAuth();
  const [activeConversaId, setActiveConversaId] = useState(null);

  const conversations = useSyncExternalStore(chatMock.subscribe, chatMock.getConversations);
  const rawMessages = useSyncExternalStore(
    chatMock.subscribe,
    () => chatMock.getMessages(activeConversaId)
  );

  const selectConversation = useCallback((id) => {
    setActiveConversaId(id);
    chatMock.markRead(id);
  }, []);

  const sendMessage = useCallback((texto) => {
    if (!activeConversaId || !texto.trim()) return;
    chatMock.sendMessage(activeConversaId, texto.trim());
  }, [activeConversaId]);

  // Mapeia `from` → `remetente` (uid do vet logado) para o MessageThread atual,
  // que decide "minha mensagem" via `remetente === user.uid`.
  const uid = user?.uid || 'vet';
  const messages = rawMessages.map((m) => ({
    id: m.id,
    texto: m.texto,
    timestamp: m.timestamp,
    remetente: m.from === 'vet' ? uid : `tutor_${activeConversaId}`,
  }));

  return {
    conversations,
    activeConversaId,
    messages,
    loadingConversations: false,
    loadingMessages: false,
    sending: false,
    selectConversation,
    sendMessage,
    refresh: () => {},
  };
}

/** Total de mensagens não lidas — consumido pelo badge do header (T2). */
export function useChatUnread() {
  return useSyncExternalStore(chatMock.subscribe, chatMock.getTotalUnread);
}
