import React, { useRef, useState } from 'react';
import { Send, Paperclip, X, FileText, Image } from 'lucide-react';

const ACCEPT = 'image/jpeg,image/png,image/webp,application/pdf';

export default function MessageInput({ onSend, onSendAttachment, disabled }) {
  const [text, setText] = useState('');
  const [file, setFile] = useState(null);
  const fileRef = useRef(null);
  const canSend = !disabled && (file || text.trim());

  const handleSend = async () => {
    if (!canSend) return;
    const sentFile = file;
    const sentText = text;
    try {
      if (sentFile) await onSendAttachment(sentFile, sentText);
      else await onSend(sentText);
      // Limpa só o que foi enviado: se a pessoa já escolheu o próximo arquivo
      // (ou digitou) enquanto este subia, não apaga.
      setText((t) => (t === sentText ? '' : t));
      setFile((f) => (f === sentFile ? null : f));
    } catch {
      // Mantém texto/arquivo para tentar de novo (o erro aparece acima do campo).
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <div className="flex-shrink-0" style={{ borderTop: '1px solid var(--separator)' }}>
      {file && (
        <div className="mx-3 md:mx-4 mt-2.5 flex items-center gap-2 px-3 py-2 rounded-[12px]"
          style={{ background: 'var(--surface-secondary)', fontSize: '13px', color: 'var(--text-primary)' }}>
          {file.type.startsWith('image/') ? <Image size={16} /> : <FileText size={16} />}
          <span className="truncate flex-1">{file.name}</span>
          <button type="button" onClick={() => setFile(null)} aria-label="Remover anexo" className="p-1 rounded-[6px]">
            <X size={14} />
          </button>
        </div>
      )}
      <div className="px-3 md:px-4 py-3 flex items-end gap-2">
        <input ref={fileRef} type="file" accept={ACCEPT} hidden aria-label="Escolher anexo"
          onChange={(e) => { setFile(e.target.files?.[0] || null); e.target.value = ''; }} />
        <button
          type="button"
          onClick={() => fileRef.current?.click()}
          disabled={disabled}
          aria-label="Anexar foto ou PDF"
          className="w-10 h-10 md:w-9 md:h-9 rounded-full flex items-center justify-center flex-shrink-0"
          style={{ color: 'var(--text-secondary)', opacity: disabled ? 0.4 : 1 }}
        >
          <Paperclip size={18} strokeWidth={1.75} />
        </button>
        <div className="flex-1 rounded-[14px] px-4 py-2.5" style={{ background: 'var(--surface-secondary)' }}>
          <textarea
            rows={1}
            value={text}
            onChange={e => setText(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder={file ? 'Legenda (opcional)...' : 'Mensagem...'}
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
          disabled={!canSend}
          aria-label="Enviar mensagem"
          className="w-10 h-10 md:w-9 md:h-9 rounded-full flex items-center justify-center flex-shrink-0 transition-opacity duration-150"
          style={{
            background: 'var(--apple-blue)',
            opacity: canSend ? 1 : 0.4,
            cursor: canSend ? 'pointer' : 'default',
          }}
        >
          <Send size={16} strokeWidth={2} style={{ color: '#fff', marginLeft: '1px' }} />
        </button>
      </div>
    </div>
  );
}
