import React from 'react';
import { MessageSquare, RefreshCw } from 'lucide-react';
// Fonte de dados: mock isolado (src/services/chatMock.js). Trocar pelo backend
// real depois = voltar para `useChat` (Firestore) — a UI permanece igual.
import { useChatMock as useChat } from '../../../hooks/useChatMock';
import ConversationList from './ConversationList';
import MessageThread from './MessageThread';
import MessageInput from './MessageInput';

const ChatPage = () => {
  const {
    conversations,
    activeConversaId,
    messages,
    loadingConversations,
    loadingMessages,
    sending,
    selectConversation,
    sendMessage,
    refresh,
  } = useChat();

  const activeConversation = conversations.find(c => c.id === activeConversaId) || null;

  return (
    <div className="min-h-full font-sf flex flex-col">

      {/* ── Page header ─────────────────────────────────────────────────── */}
      <div className="mb-5 fade-in-up flex items-center justify-between">
        <div>
          <h1 className="font-bold" style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
            Chat
          </h1>
          <p className="mt-1" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
            Mensagens com tutores dos seus pacientes.
          </p>
        </div>
        <button
          onClick={refresh}
          className="w-9 h-9 rounded-[10px] flex items-center justify-center transition-colors duration-150"
          style={{ background: 'var(--surface-grouped-secondary)' }}
          onMouseEnter={e => e.currentTarget.style.background = 'var(--surface-secondary)'}
          onMouseLeave={e => e.currentTarget.style.background = 'var(--surface-grouped-secondary)'}
          title="Atualizar"
        >
          <RefreshCw size={16} strokeWidth={1.5} style={{ color: 'var(--text-secondary)' }} />
        </button>
      </div>

      {/* ── Two-panel layout ─────────────────────────────────────────────── */}
      <div
        className="fade-in-up flex rounded-[20px] overflow-hidden flex-1"
        style={{
          background: 'var(--surface-grouped-secondary)',
          boxShadow: '0 1px 3px rgba(0,0,0,0.06)',
          minHeight: '520px',
          animationDelay: '80ms',
        }}
      >
        {/* ── Left panel — conversation list ───────────────────────────── */}
        <div
          className="w-[280px] flex-shrink-0 flex flex-col"
          style={{ borderRight: '1px solid var(--separator)', background: 'var(--surface-secondary)' }}
        >
          <div className="px-4 py-3.5" style={{ borderBottom: '1px solid var(--separator)' }}>
            <h2 className="font-semibold" style={{ fontSize: '13px', letterSpacing: '0.02em', color: 'var(--text-secondary)' }}>
              CONVERSAS
            </h2>
          </div>
          <ConversationList
            conversations={conversations}
            activeId={activeConversaId}
            onSelect={selectConversation}
            loading={loadingConversations}
          />
        </div>

        {/* ── Right panel — messages ────────────────────────────────────── */}
        <div className="flex-1 flex flex-col min-w-0">
          {activeConversaId ? (
            <>
              {/* Thread header */}
              <div
                className="px-5 py-3.5 flex items-center gap-3 flex-shrink-0"
                style={{ borderBottom: '1px solid var(--separator)' }}
              >
                {activeConversation && (
                  <>
                    <div className="w-9 h-9 rounded-full flex items-center justify-center font-semibold text-[12px] flex-shrink-0"
                      style={{ background: 'rgba(0,122,255,0.1)', color: 'var(--apple-blue)' }}>
                      {activeConversation.tutorName?.split(' ').map(w => w[0]).slice(0, 2).join('').toUpperCase() || '?'}
                    </div>
                    <div>
                      <div className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>
                        {activeConversation.tutorName || 'Tutor'}
                      </div>
                      {activeConversation.petName && (
                        <div style={{ fontSize: '12px', color: 'var(--text-tertiary)' }}>
                          {activeConversation.petName}
                        </div>
                      )}
                    </div>
                  </>
                )}
              </div>

              <MessageThread
                messages={messages}
                loading={loadingMessages}
                conversation={activeConversation}
              />
              <MessageInput onSend={sendMessage} disabled={sending} />
            </>
          ) : (
            <div className="flex-1 flex flex-col items-center justify-center gap-3 px-8 text-center">
              <div className="w-14 h-14 rounded-full flex items-center justify-center"
                style={{ background: 'rgba(0,122,255,0.1)' }}>
                <MessageSquare size={26} strokeWidth={1.5} style={{ color: 'var(--apple-blue)' }} />
              </div>
              <p className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>
                Selecione uma conversa
              </p>
              <p style={{ fontSize: '14px', color: 'var(--text-secondary)', maxWidth: '260px' }}>
                Escolha uma conversa à esquerda ou inicie uma nova a partir de um paciente.
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ChatPage;
