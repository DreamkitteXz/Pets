import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { LockKeyhole, ShieldOff } from 'lucide-react';

const Unauthorized = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const code = location.state?.code;
  const reason = location.state?.reason;
  const is403 = code === 403;
  const isSuspended = is403 && reason === 'suspended';

  const icon = is403
    ? <ShieldOff size={44} strokeWidth={1.2} style={{ color: 'var(--apple-red)' }} />
    : <LockKeyhole size={44} strokeWidth={1.2} style={{ color: 'var(--apple-red)' }} />;

  const title = isSuspended ? 'Conta suspensa' : 'Acesso negado';

  const message = isSuspended
    ? 'Sua conta foi suspensa. Entre em contato com o suporte para mais informações.'
    : is403
      ? 'Você não tem permissão para acessar esta página.'
      : 'Faça login para continuar.';

  return (
    <div className="min-h-screen flex items-center justify-center p-6 font-sf"
      style={{ background: 'var(--surface-grouped)' }}>
      <div className="text-center fade-in-up max-w-[320px]">
        <div className="w-24 h-24 rounded-[28px] flex items-center justify-center mx-auto mb-6"
          style={{ background: 'rgba(255,59,48,0.1)' }}>
          {icon}
        </div>
        <h1 className="font-bold mb-3"
          style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
          {title}
        </h1>
        <p className="mb-8"
          style={{ fontSize: '17px', color: 'var(--text-secondary)', lineHeight: '1.5' }}>
          {message}
        </p>
        {!isSuspended && (
          <button
            onClick={() => is403 ? navigate(-1) : navigate('/auth')}
            className="px-6 py-3 rounded-[12px] font-semibold text-white transition-all duration-150 active:scale-[0.97]"
            style={{ background: 'var(--apple-blue)', fontSize: '17px', boxShadow: '0 4px 16px rgba(0,122,255,0.3)' }}
            onMouseEnter={e => e.currentTarget.style.filter = 'brightness(1.08)'}
            onMouseLeave={e => e.currentTarget.style.filter = 'none'}
          >
            {is403 ? 'Voltar' : 'Fazer login'}
          </button>
        )}
      </div>
    </div>
  );
};

export default Unauthorized;
