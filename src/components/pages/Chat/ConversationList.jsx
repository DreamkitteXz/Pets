import React from 'react';
import { MessageSquare } from 'lucide-react';

const formatTime = (ts) => {
  if (!ts) return '';
  const d = ts.toDate ? ts.toDate() : new Date(ts.seconds * 1000);
  const now = new Date();
  const diff = now - d;
  if (diff < 60000) return 'agora';
  if (diff < 3600000) return `${Math.floor(diff / 60000)}m`;
  if (diff < 86400000) return d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
  return d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
};

export default function ConversationList({ conversations, activeId, onSelect, loading }) {
  if (loading) {
    return (
      <div className="flex items-center justify-center h-40">
        <div className="w-6 h-6 rounded-full border-2 border-transparent animate-spin"
          style={{ borderTopColor: 'var(--apple-blue)' }} />
      </div>
    );
  }

  if (conversations.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-16 gap-3 px-6 text-center">
        <div className="w-12 h-12 rounded-full flex items-center justify-center"
          style={{ background: 'rgba(0,122,255,0.1)' }}>
          <MessageSquare size={22} strokeWidth={1.5} style={{ color: 'var(--apple-blue)' }} />
        </div>
        <p className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>
          Nenhuma conversa
        </p>
        <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
          Inicie uma conversa a partir da tela de um paciente.
        </p>
      </div>
    );
  }

  return (
    <div className="overflow-y-auto flex-1">
      {conversations.map((c) => {
        const isActive = c.id === activeId;
        const initials = c.tutorName?.split(' ').map(w => w[0]).slice(0, 2).join('').toUpperCase() || '?';
        return (
          <button
            key={c.id}
            onClick={() => onSelect(c.id)}
            className="w-full text-left px-4 py-3.5 transition-colors duration-100"
            style={{
              background: isActive ? 'rgba(10,132,255,0.12)' : 'transparent',
              borderLeft: isActive ? '3px solid var(--apple-blue)' : '3px solid transparent',
            }}
            onMouseEnter={e => { if (!isActive) e.currentTarget.style.background = 'rgba(255,255,255,0.04)'; }}
            onMouseLeave={e => { if (!isActive) e.currentTarget.style.background = 'transparent'; }}
          >
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full flex items-center justify-center font-semibold text-[13px] flex-shrink-0 text-white"
                style={{ background: 'rgba(255,255,255,0.15)' }}>
                {initials}
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between gap-2">
                  <span className="font-medium truncate" style={{ fontSize: '14px', color: isActive ? 'var(--apple-blue)' : 'rgba(255,255,255,0.85)' }}>
                    {c.tutorName || 'Tutor'}
                  </span>
                  <span className="flex-shrink-0" style={{ fontSize: '11px', color: 'rgba(255,255,255,0.35)' }}>
                    {formatTime(c.lastMessageAt)}
                  </span>
                </div>
                {c.petName && (
                  <div className="truncate" style={{ fontSize: '12px', color: 'rgba(255,255,255,0.40)', marginTop: '1px' }}>
                    {c.petName}
                  </div>
                )}
                {c.lastMessage && (
                  <div className="truncate mt-0.5" style={{ fontSize: '12px', color: 'rgba(255,255,255,0.35)' }}>
                    {c.lastMessage}
                  </div>
                )}
              </div>
            </div>
          </button>
        );
      })}
    </div>
  );
}
