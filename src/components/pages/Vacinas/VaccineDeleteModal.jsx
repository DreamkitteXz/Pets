import React, { useState } from 'react';
import { X, AlertTriangle } from 'lucide-react';

// Exclusão LÓGICA (arquivar) — preserva o registro e a foto para auditoria.
const VaccineDeleteModal = ({ isOpen, onClose, vaccine, onDelete }) => {
  const [busy, setBusy] = useState(false);
  if (!isOpen || !vaccine) return null;

  const handleDelete = async () => {
    setBusy(true);
    try {
      await onDelete(vaccine.id);
      onClose();
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 font-sf">
      <div className="absolute inset-0" style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(8px)', WebkitBackdropFilter: 'blur(8px)' }} onClick={onClose} />
      <div className="relative w-full max-w-[440px] rounded-[20px] overflow-hidden fade-in-up"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 24px 70px rgba(0,0,0,0.35)' }}>
        <div className="px-7 py-6 flex flex-col items-center text-center">
          <div className="w-14 h-14 rounded-full flex items-center justify-center mb-4" style={{ background: 'rgba(255,149,0,0.12)' }}>
            <AlertTriangle size={26} strokeWidth={1.75} style={{ color: 'var(--apple-orange)' }} />
          </div>
          <h2 className="font-bold mb-1" style={{ fontSize: '19px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
            Arquivar registro de vacina?
          </h2>
          <p className="mb-4" style={{ fontSize: '14px', color: 'var(--text-secondary)', lineHeight: 1.5 }}>
            O registro deixará de aparecer nas listagens, mas é <strong>preservado para auditoria</strong> (exclusão lógica).
          </p>
          <div className="w-full rounded-[12px] p-4 text-left mb-2" style={{ background: 'var(--surface-secondary)' }}>
            <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}><strong style={{ color: 'var(--text-primary)' }}>Vacina:</strong> {vaccine.name || '—'}</div>
            <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}><strong style={{ color: 'var(--text-primary)' }}>Pet:</strong> {vaccine.petName || '—'}</div>
          </div>
        </div>

        <div className="flex justify-end gap-2 px-7 pb-6">
          <button onClick={onClose}
            className="px-4 py-2.5 rounded-[10px] font-medium transition-colors duration-150"
            style={{ background: 'var(--surface-secondary)', color: 'var(--text-secondary)', fontSize: '15px' }}>
            Cancelar
          </button>
          <button onClick={handleDelete} disabled={busy}
            className="px-5 py-2.5 rounded-[10px] font-medium transition-opacity duration-150"
            style={{ background: 'var(--apple-red)', color: '#fff', fontSize: '15px', opacity: busy ? 0.6 : 1, cursor: busy ? 'default' : 'pointer' }}>
            {busy ? 'Arquivando...' : 'Arquivar'}
          </button>
        </div>
      </div>
    </div>
  );
};

export default VaccineDeleteModal;
