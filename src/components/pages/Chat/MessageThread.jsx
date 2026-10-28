import React, { useEffect, useRef } from 'react';
import { toDate, toMillis } from '../../../utils/dates';
import Attachment from './Attachment';

const formatTime = (ts) => {
  const d = toDate(ts);
  if (!d) return '';
  const today = new Date().toDateString() === d.toDateString();
  return today
    ? d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
    : d.toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });
};

export default function MessageThread({ messages, loading, conversation, uid, hasMore, onLoadOlder, loadingOlder }) {
  const bottomRef = useRef(null);
  const lastId = messages[messages.length - 1]?.id;

  // Rola para o fim só quando chega mensagem nova (não ao carregar antigas).
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [lastId]);

  if (loading) {
    return (
      <div className="flex-1 flex items-center justify-center">
        <div className="w-6 h-6 rounded-full border-2 border-transparent animate-spin"
          style={{ borderTopColor: 'var(--apple-blue)' }} />
      </div>
    );
  }

  if (messages.length === 0) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center gap-2 px-6 text-center">
        <p style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
          Nenhuma mensagem ainda. Escreva a primeira!
        </p>
      </div>
    );
  }

  // "Visto": a última mensagem MINHA que o outro já leu (lastReadAt dele >= envio).
  const otherId = conversation ? (uid === conversation.vetId ? conversation.tutorId : conversation.vetId) : null;
  const otherReadAt = toMillis(conversation?.lastReadAt?.[otherId]);
  const lastMineSeen = [...messages].reverse().find((m) => m.senderId === uid && otherReadAt && toMillis(m.createdAt) <= otherReadAt);

  return (
    <div className="flex-1 min-h-0 overflow-y-auto px-3 md:px-5 py-4 flex flex-col gap-2.5">
      {hasMore && (
        <button type="button" onClick={onLoadOlder} disabled={loadingOlder}
          className="self-center px-3 py-1.5 rounded-full font-medium"
          style={{ fontSize: '12px', color: 'var(--apple-blue)', background: 'rgba(0,122,255,0.08)' }}>
          {loadingOlder ? 'Carregando…' : 'Ver mensagens anteriores'}
        </button>
      )}
      {messages.map((msg) => {
        const isMine = msg.senderId === uid;
        const hidden = !!msg.deletedAt;
        return (
          <div key={msg.id} className={`flex flex-col ${isMine ? 'items-end' : 'items-start'}`}>
            <div
              className="max-w-[85%] md:max-w-[72%] px-3.5 md:px-4 py-2.5 rounded-[18px]"
              style={{
                background: isMine ? 'var(--apple-blue)' : 'var(--surface-secondary)',
                borderBottomRightRadius: isMine ? '4px' : '18px',
                borderBottomLeftRadius: isMine ? '18px' : '4px',
                opacity: hidden ? 0.6 : 1,
              }}
            >
              {!hidden && msg.tipo === 'anexo' && msg.anexo && (
                <div className={msg.texto ? 'mb-1.5' : ''}>
                  <Attachment anexo={msg.anexo} isMine={isMine} />
                </div>
              )}
              {(hidden || msg.texto) && (
                <p style={{
                  fontSize: '15px',
                  color: isMine ? '#fff' : 'var(--text-primary)',
                  lineHeight: '1.4',
                  wordBreak: 'break-word',
                  whiteSpace: 'pre-wrap',
                  fontStyle: hidden ? 'italic' : 'normal',
                }}>
                  {hidden ? 'Mensagem ocultada pelo autor' : msg.texto}
                </p>
              )}
              <p className="mt-1 text-right" style={{
                fontSize: '11px',
                color: isMine ? 'rgba(255,255,255,0.55)' : 'var(--text-tertiary)',
              }}>
                {formatTime(msg.createdAt)}
              </p>
            </div>
            {lastMineSeen?.id === msg.id && (
              <span className="mt-0.5 mr-1" style={{ fontSize: '11px', color: 'var(--text-tertiary)' }}>Visto</span>
            )}
          </div>
        );
      })}
      <div ref={bottomRef} />
    </div>
  );
}
