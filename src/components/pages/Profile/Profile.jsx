import React from 'react';
import { auth } from '../../../config/firebase';
import { Mail, Shield, User } from 'lucide-react';

const Profile = () => {
  const user = auth.currentUser;
  const initial = user?.email?.[0]?.toUpperCase() || 'V';

  const rows = [
    { icon: Mail,   label: 'E-mail',  value: user?.email || '—' },
    { icon: Shield, label: 'Status',  value: user?.emailVerified ? 'Verificado' : 'Não verificado' },
    { icon: User,   label: 'UID',     value: user?.uid || '—' },
  ];

  return (
    <div className="min-h-full font-sf">

      {/* Page header */}
      <div className="mb-6 fade-in-up">
        <h1 className="font-bold" style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
          Perfil
        </h1>
      </div>

      {/* Avatar card */}
      <div
        className="fade-in-up rounded-[20px] p-8 mb-4 flex flex-col items-center text-center"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '50ms' }}
      >
        <div
          className="w-24 h-24 rounded-full flex items-center justify-center font-bold text-[36px] mb-4 text-white"
          style={{ background: 'var(--apple-blue)' }}
        >
          {initial}
        </div>
        <p className="font-semibold" style={{ fontSize: '20px', color: 'var(--text-primary)', letterSpacing: '-0.01em' }}>
          {user?.displayName || user?.email?.split('@')[0] || 'Usuário'}
        </p>
        <p style={{ fontSize: '15px', color: 'var(--text-secondary)', marginTop: '4px' }}>
          Veterinário
        </p>
      </div>

      {/* Info rows — grouped list */}
      <div
        className="fade-in-up rounded-[16px] overflow-hidden"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '100ms' }}
      >
        {rows.map(({ icon: Icon, label, value }, i) => (
          <div
            key={label}
            className="flex items-center gap-4 px-5"
            style={{
              paddingTop: '14px',
              paddingBottom: '14px',
              borderBottom: i < rows.length - 1 ? '1px solid var(--separator)' : 'none',
            }}
          >
            <div className="w-8 h-8 rounded-[8px] flex items-center justify-center flex-shrink-0"
              style={{ background: 'rgba(0,122,255,0.1)' }}>
              <Icon size={16} strokeWidth={1.5} style={{ color: 'var(--apple-blue)' }} />
            </div>
            <div className="flex-1 min-w-0">
              <div style={{ fontSize: '12px', color: 'var(--text-tertiary)', marginBottom: '1px' }}>{label}</div>
              <div className="truncate" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{value}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Profile;
