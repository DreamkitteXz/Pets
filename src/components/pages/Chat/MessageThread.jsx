import React, { useEffect, useRef } from 'react';
import { useAuth } from '../../../context/AuthContext';
import { toDate } from '../../../utils/dates';

const formatTime = (ts) => {
  const d = toDate(ts);
  if (!d) return '';
  return d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
};

export default function MessageThread({ messages, loading, conversation }) {
  const { user } = useAuth();
  const bottomRef = useRef(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

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
          Nenhuma mensagem ainda. Seja o primeiro a escrever!
        </p>
      </div>
    );
  }

  return (
    <div className="flex-1 overflow-y-auto px-5 py-4 flex flex-col gap-2.5">
      {messages.map((msg) => {
        const isMine = msg.remetente === user?.uid;
        return (
          <div key={msg.id} className={`flex ${isMine ? 'justify-end' : 'justify-start'}`}>
            <div
              className="max-w-[72%] px-4 py-2.5 rounded-[18px]"
              style={{
                background: isMine ? 'var(--apple-blue)' : 'var(--surface-secondary)',
                borderBottomRightRadius: isMine ? '4px' : '18px',
                borderBottomLeftRadius: isMine ? '18px' : '4px',
              }}
            >
              <p style={{
                fontSize: '15px',
                color: isMine ? '#fff' : 'var(--text-primary)',
                lineHeight: '1.4',
                wordBreak: 'break-word',
              }}>
                {msg.texto}
              </p>
              <p className="mt-1 text-right" style={{
                fontSize: '11px',
                color: isMine ? 'rgba(255,255,255,0.55)' : 'var(--text-tertiary)',
              }}>
                {formatTime(msg.timestamp)}
              </p>
            </div>
          </div>
        );
      })}
      <div ref={bottomRef} />
    </div>
  );
}
