import React, { useEffect, useState } from 'react';
import { useLocation } from 'react-router-dom';
import { MessageSquare, ChevronLeft, AlertTriangle } from 'lucide-react';
import { useMediaQuery, DESKTOP_QUERY } from '../../../hooks/useMediaQuery';
import { useAuth } from '../../../context/AuthContext';
import { useChat } from '../../../hooks/useChat';
import ConversationList from './ConversationList';
import MessageThread from './MessageThread';
import MessageInput from './MessageInput';
import ChatTermsModal, { CHAT_TERMS_VERSION } from './ChatTermsModal';

// Nome e detalhe do OUTRO participante, do ponto de vista de quem está logado.
export function otherParty(c, isTutor) {
  if (!c) return { name: '', detail: '' };
  const pets = Object.values(c.petNames || {}).filter(Boolean).join(', ');
  return isTutor
    ? { name: c.vetName || 'Veterinário', detail: [c.vetCrmv, pets].filter(Boolean).join(' · ') }
    : { name: c.tutorName || 'Tutor', detail: pets };
}

const initials = (name) => (name || '?').split(' ').map((w) => w[0]).slice(0, 2).join('').toUpperCase();

const ChatPage = () => {
  const location = useLocation();
  const { user, userProfile } = useAuth();
  const isTutor = userProfile?.role === 'tutor';
  const {
    conversations, activeConversaId, activeConversation, messages, hasMore, loadOlder, loadingOlder,
    loadingConversations, loadingMessages, sending, error, selectConversation, sendMessage,
  } = useChat();
  const [termsAccepted, setTermsAccepted] = useState(false);
  const needsTerms = !termsAccepted && (userProfile?.chatTermsVersion || 0) < CHAT_TERMS_VERSION;

  // Veio de um botão "Conversar": abre direto a conversa.
  useEffect(() => {
    const id = location.state?.conversaId;
    if (id) selectConversation(id);
  }, [location.state, selectConversation]);

  const isDesktop = useMediaQuery(DESKTOP_QUERY);
  // No celular é um painel por vez: lista, ou a conversa aberta em tela cheia.
  const showList = isDesktop || !activeConversaId;
  const showThread = isDesktop || !!activeConversaId;
  const other = otherParty(activeConversation, isTutor);

  return (
    // No celular a página ocupa exatamente a área visível (tela − header 60px −
    // padding do main), para o campo de mensagem ficar sempre à vista.
    <div className="font-sf flex flex-col h-[calc(100dvh-92px)] md:h-auto md:min-h-full">
      {needsTerms && user && (
        <ChatTermsModal uid={user.uid} role={userProfile?.role} onAccepted={() => setTermsAccepted(true)} />
      )}

      {/* ── Page header ─────────────────────────────────────────────────── */}
      <div className={`mb-4 md:mb-5 fade-in-up items-center justify-between gap-3 ${showList ? 'flex' : 'hidden'}`}>
        <div>
          <h1 className="font-bold" style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
            Chat
          </h1>
          <p className="mt-1" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
            {isTutor ? 'Mensagens com os veterinários dos seus pets.' : 'Mensagens com tutores dos seus pacientes.'}
          </p>
        </div>
      </div>

      {/* ── Two-panel layout ─────────────────────────────────────────────── */}
      <div
        className="fade-in-up flex rounded-[20px] overflow-hidden flex-1 min-h-0 md:min-h-[520px]"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '80ms' }}
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
            isTutor={isTutor}
            uid={user?.uid}
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
                <div className="w-9 h-9 rounded-full flex items-center justify-center font-semibold text-[12px] flex-shrink-0"
                  style={{ background: 'rgba(0,122,255,0.1)', color: 'var(--apple-blue)' }}>
                  {initials(other.name)}
                </div>
                <div className="min-w-0">
                  <div className="font-semibold truncate" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>
                    {other.name}
                  </div>
                  {other.detail && (
                    <div className="truncate" style={{ fontSize: '12px', color: 'var(--text-tertiary)' }}>{other.detail}</div>
                  )}
                </div>
              </div>

              {/* Aviso fixo (CFMV Res. 1465/2022: urgência/emergência não se atende a distância) */}
              <div className="px-3 md:px-5 py-2 flex items-start gap-1.5 flex-shrink-0"
                style={{ background: 'rgba(255,149,0,0.10)', fontSize: '12px', color: 'var(--text-secondary)', lineHeight: 1.4 }}>
                <AlertTriangle size={13} style={{ flexShrink: 0, marginTop: '2px', color: 'var(--apple-orange)' }} />
                <span>O chat não substitui o atendimento presencial. <strong>Em emergência, procure uma clínica imediatamente.</strong></span>
              </div>

              <MessageThread
                messages={messages}
                loading={loadingMessages}
                conversation={activeConversation}
                uid={user?.uid}
                hasMore={hasMore}
                onLoadOlder={loadOlder}
                loadingOlder={loadingOlder}
              />
              {error && (
                <p className="px-4 py-1.5" style={{ fontSize: '12px', color: 'var(--apple-red)' }}>
                  {error.code === 'permission-denied' ? 'Você não tem acesso a esta conversa.' : 'Não foi possível enviar. Tente de novo.'}
                </p>
              )}
              <MessageInput onSend={sendMessage} disabled={sending || needsTerms || activeConversation?.status === 'closed'} />
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
              <p style={{ fontSize: '14px', color: 'var(--text-secondary)', maxWidth: '280px' }}>
                {isTutor
                  ? 'Para começar, abra o pet e toque em "Conversar" ao lado do veterinário.'
                  : 'Para começar, abra o paciente e toque em "Conversar com o tutor".'}
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ChatPage;
