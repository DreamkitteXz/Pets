/**
 * Mock de chat — fonte de dados FAKE e ISOLADA para a tela de Conversas e o badge.
 *
 * Trocar pelo backend real depois = mexer SÓ aqui (ou apontar os hooks para o
 * serviço real, ex.: `useChat` baseado em Firestore). A UI não muda: os hooks
 * `useChatMock`/`useChatUnread` (em src/hooks/useChatMock.js) expõem a mesma
 * interface que a UI já consome.
 *
 * É um store observável simples (subscribe/notify) para que o badge no header e a
 * tela de chat reajam à leitura ("marcar como lida") sem backend.
 */

const EMPTY = [];

const ago = (mins) => new Date(Date.now() - mins * 60 * 1000);

let _conversations = [
  { id: 'c1', tutorName: 'Maria Fernanda Costa', petName: 'Rex',  lastMessage: 'Doutor, o Rex está com febre?',         lastMessageAt: ago(8),       unread: 2 },
  { id: 'c2', tutorName: 'Roberto Alves Nunes',   petName: 'Thor', lastMessage: 'Obrigado pela validação da vacina!',     lastMessageAt: ago(3 * 60),  unread: 0 },
  { id: 'c3', tutorName: 'Ana Paula Lima',        petName: 'Mia',  lastMessage: 'Posso remarcar a consulta de sexta?',    lastMessageAt: ago(26 * 60), unread: 1 },
];

// Mensagens por conversa. `from`: 'vet' (eu) | 'tutor' (interlocutor).
const _messages = {
  c1: [
    { id: 'm1', from: 'tutor', texto: 'Boa tarde, doutor!',                         timestamp: ago(20) },
    { id: 'm2', from: 'vet',   texto: 'Boa tarde, Maria. Como posso ajudar?',       timestamp: ago(18) },
    { id: 'm3', from: 'tutor', texto: 'O Rex está meio quietinho hoje.',            timestamp: ago(10) },
    { id: 'm4', from: 'tutor', texto: 'Doutor, o Rex está com febre?',              timestamp: ago(8)  },
  ],
  c2: [
    { id: 'm5', from: 'vet',   texto: 'Vacina validada, Roberto. Está tudo certo!', timestamp: ago(3 * 60 + 12) },
    { id: 'm6', from: 'tutor', texto: 'Obrigado pela validação da vacina!',         timestamp: ago(3 * 60)      },
  ],
  c3: [
    { id: 'm7', from: 'tutor', texto: 'Posso remarcar a consulta de sexta?',        timestamp: ago(26 * 60) },
  ],
};

const _listeners = new Set();
const _notify = () => _listeners.forEach((fn) => fn());
let _seq = 100;

export const chatMock = {
  getConversations: () => _conversations,
  getMessages: (id) => _messages[id] || EMPTY,
  getTotalUnread: () => _conversations.reduce((sum, c) => sum + (c.unread || 0), 0),

  markRead: (id) => {
    if (!_conversations.some((c) => c.id === id && c.unread > 0)) return;
    _conversations = _conversations.map((c) => (c.id === id ? { ...c, unread: 0 } : c));
    _notify();
  },

  sendMessage: (id, texto) => {
    const msg = { id: `m${++_seq}`, from: 'vet', texto, timestamp: new Date() };
    _messages[id] = [...(_messages[id] || []), msg];
    _conversations = _conversations.map((c) =>
      c.id === id ? { ...c, lastMessage: texto, lastMessageAt: new Date() } : c
    );
    _notify();
  },

  subscribe: (fn) => {
    _listeners.add(fn);
    return () => _listeners.delete(fn);
  },
};
