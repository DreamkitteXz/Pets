import React, { useState } from 'react';
import { Send } from 'lucide-react';

export default function MessageInput({ onSend, disabled }) {
  const [text, setText] = useState('');

  const handleSend = async () => {
    if (!text.trim() || disabled) return;
    try {
      await onSend(text);
      setText('');
    } catch {
      // Mantém o texto para tentar de novo (o erro aparece acima do campo).
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <div
      className="px-3 md:px-4 py-3 flex items-end gap-2 flex-shrink-0"
      style={{ borderTop: '1px solid var(--separator)' }}
    >
      <div
        className="flex-1 rounded-[14px] px-4 py-2.5"
        style={{ background: 'var(--surface-secondary)' }}
      >
        <textarea
          rows={1}
          value={text}
          onChange={e => setText(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="Mensagem..."
          maxLength={4000}
          aria-label="Mensagem"
          disabled={disabled}
          className="w-full bg-transparent border-none outline-none resize-none"
          style={{
            fontSize: '16px', // < 16px faz o iPhone dar zoom ao focar o campo
            color: 'var(--text-primary)',
            maxHeight: '120px',
            lineHeight: '1.4',
          }}
        />
      </div>
      <button
        onClick={handleSend}
        disabled={disabled || !text.trim()}
        aria-label="Enviar mensagem"
        className="w-10 h-10 md:w-9 md:h-9 rounded-full flex items-center justify-center flex-shrink-0 transition-opacity duration-150"
        style={{
          background: 'var(--apple-blue)',
          opacity: disabled || !text.trim() ? 0.4 : 1,
          cursor: disabled || !text.trim() ? 'default' : 'pointer',
        }}
      >
        <Send size={16} strokeWidth={2} style={{ color: '#fff', marginLeft: '1px' }} />
      </button>
    </div>
  );
}
