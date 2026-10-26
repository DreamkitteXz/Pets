import React from 'react';
import { MessageSquare, RefreshCw, ChevronLeft } from 'lucide-react';
import { useMediaQuery, DESKTOP_QUERY } from '../../../hooks/useMediaQuery';
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
  const isDesktop = useMediaQuery(DESKTOP_QUERY);
  // No celular é um painel por vez: lista, ou a conversa aberta em tela cheia.
  const showList = isDesktop || !activeConversaId;
  const showThread = isDesktop || !!activeConversaId;

  return (
    // No celular a página ocupa exatamente a área visível (tela − header 60px −
    // padding do main), para o campo de mensagem ficar sempre à vista.
    <div className="font-sf flex flex-col h-[calc(100dvh-92px)] md:h-auto md:min-h-full">

      {/* ── Page header ─────────────────────────────────────────────────── */}
      <div className={`mb-4 md:mb-5 fade-in-up items-center justify-between gap-3 ${showList ? 'flex' : 'hidden'}`}>
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
          className="w-10 h-10 md:w-9 md:h-9 flex-shrink-0 rounded-[10px] flex items-center justify-center transition-colors duration-150"
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
        className="fade-in-up flex rounded-[20px] overflow-hidden flex-1 min-h-0 md:min-h-[520px]"
        style={{
          background: 'var(--surface-grouped-secondary)',
          boxShadow: '0 1px 3px rgba(0,0,0,0.06)',
          animationDelay: '80ms',
        }}
      >
        {/* ── Left panel — conversation list ───────────────────────────── */}
        <div
          className={`w-full md:w-[280px] flex-shrink-0 flex-col min-h-0 md:border-r ${showList ? 'flex' : 'hidden'}`}
          style={{ borderColor: 'var(--separator)', background: 'var(--surface-secondary)' }}
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
        <div className={`flex-1 flex-col min-w-0 min-h-0 ${showThread ? 'flex' : 'hidden'}`}>
          {activeConversaId ? (
            <>
              {/* Thread header */}
              <div
                className="pl-2 pr-4 md:px-5 py-2.5 md:py-3.5 flex items-center gap-2 md:gap-3 flex-shrink-0"
                style={{ borderBottom: '1px solid var(--separator)' }}
              >
                {!isDesktop && (
                  <button
                    onClick={() => selectConversation(null)}
                    className="w-10 h-10 flex-shrink-0 rounded-[10px] flex items-center justify-center"
                    aria-label="Voltar para as conversas"
                  >
                    <ChevronLeft size={22} strokeWidth={2} style={{ color: 'var(--apple-blue)' }} />
                  </button>
                )}
                {activeConversation && (
                  <>
                    <div className="w-9 h-9 rounded-full flex items-center justify-center font-semibold text-[12px] flex-shrink-0"
                      style={{ background: 'rgba(0,122,255,0.1)', color: 'var(--apple-blue)' }}>
                      {activeConversation.tutorName?.split(' ').map(w => w[0]).slice(0, 2).join('').toUpperCase() || '?'}
                    </div>
                    <div className="min-w-0">
                      <div className="font-semibold truncate" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>
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
