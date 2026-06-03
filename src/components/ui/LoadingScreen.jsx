import React from 'react';

const LoadingScreen = ({ message = 'Carregando...' }) => {
  return (
    <div className="min-h-screen flex items-center justify-center font-sf"
      style={{ background: 'var(--surface-grouped)' }}>
      <div className="flex flex-col items-center gap-4">
        <div
          className="w-10 h-10 rounded-full border-2 border-transparent animate-spin"
          style={{ borderTopColor: 'var(--apple-blue)' }}
        />
        <p style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>{message}</p>
      </div>
    </div>
  );
};

export default LoadingScreen;
