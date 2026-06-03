import React from 'react';
import { LogOut } from 'lucide-react';

export default function LogoutModal({ isOpen, onClose, onConfirm }) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div
        className="absolute inset-0"
        style={{ background: 'rgba(0,0,0,0.4)', backdropFilter: 'blur(4px)', WebkitBackdropFilter: 'blur(4px)' }}
        onClick={onClose}
      />

      {/* Sheet */}
      <div
        className="relative w-full max-w-[320px] rounded-[20px] overflow-hidden fade-in-up"
        style={{
          background: 'var(--surface-elevated)',
          boxShadow: '0 24px 64px rgba(0,0,0,0.2), 0 0 0 1px rgba(0,0,0,0.06)',
          animationDuration: '0.25s',
        }}
      >
        {/* Icon + content */}
        <div className="px-6 pt-7 pb-6 text-center">
          <div
            className="w-14 h-14 rounded-full flex items-center justify-center mx-auto mb-4"
            style={{ background: 'rgba(255,59,48,0.12)' }}
          >
            <LogOut size={24} strokeWidth={1.5} style={{ color: 'var(--apple-red)' }} />
          </div>
          <h3
            className="font-semibold mb-2"
            style={{ fontSize: '17px', color: 'var(--text-primary)', letterSpacing: '-0.01em' }}
          >
            Sair da conta?
          </h3>
          <p style={{ fontSize: '15px', color: 'var(--text-secondary)', lineHeight: '1.5' }}>
            Você precisará fazer login novamente para acessar sua conta.
          </p>
        </div>

        {/* Actions */}
        <div style={{ borderTop: '1px solid var(--separator)' }}>
          <div className="grid grid-cols-2">
            <button
              onClick={onClose}
              className="py-4 font-medium transition-colors duration-150"
              style={{
                fontSize: '17px',
                color: 'var(--apple-blue)',
                borderRight: '1px solid var(--separator)',
              }}
              onMouseEnter={e => e.currentTarget.style.background = 'rgba(116,116,128,0.08)'}
              onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
            >
              Cancelar
            </button>
            <button
              onClick={onConfirm}
              className="py-4 font-semibold transition-colors duration-150"
              style={{ fontSize: '17px', color: 'var(--apple-red)' }}
              onMouseEnter={e => e.currentTarget.style.background = 'rgba(255,59,48,0.06)'}
              onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
            >
              Sair
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
