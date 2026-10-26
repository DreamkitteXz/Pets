import React, { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { X, Search, Stethoscope, AlertCircle } from 'lucide-react';

const normalize = (s) => (s || '').normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase();

/**
 * Escolha de veterinário no diretório público. `vets` vem de useVetDirectory;
 * `linkedIds` são os que já atendem o pet (ficam fora da lista).
 * `onLink(uid)` grava o vínculo.
 */
export default function LinkVetModal({ isOpen, onClose, vets, loading, linkedIds, onLink }) {
  const [term, setTerm] = useState('');
  const [busyId, setBusyId] = useState(null);
  const [error, setError] = useState('');

  useEffect(() => {
    if (isOpen) { setTerm(''); setBusyId(null); setError(''); }
  }, [isOpen]);

  if (!isOpen) return null;

  const q = normalize(term.trim());
  const available = vets
    .filter((v) => !linkedIds.includes(v.uid))
    .filter((v) => !q || normalize(v.name).includes(q) || normalize(v.crmv).includes(q));

  const handleLink = async (uid) => {
    setBusyId(uid);
    setError('');
    try {
      await onLink(uid);
      onClose();
    } catch (err) {
      setError(err?.message || 'Não foi possível vincular o veterinário. Tente novamente.');
      setBusyId(null);
    }
  };

  // Portal no body: o card que abre o modal tem animação com transform e
  // overflow-hidden, o que prenderia o `position: fixed` dentro do card.
  return createPortal(
    <div
      className="fixed inset-0 z-50 modal-overlay p-4 font-sf"
      style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(4px)' }}
      onClick={onClose}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="link-vet-title"
        className="fade-in-up rounded-[20px] w-full max-w-[480px] overflow-hidden flex flex-col"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 20px 60px rgba(0,0,0,0.3)', maxHeight: 'min(640px, 90vh)' }}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between px-6 py-4" style={{ borderBottom: '1px solid var(--separator)' }}>
          <h2 id="link-vet-title" className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>Vincular veterinário</h2>
          <button onClick={onClose} aria-label="Fechar" className="rounded-[8px] p-1.5 transition-colors duration-150"
            onMouseEnter={(e) => { e.currentTarget.style.background = 'var(--surface-secondary)'; }}
            onMouseLeave={(e) => { e.currentTarget.style.background = 'transparent'; }}>
            <X size={18} strokeWidth={2} style={{ color: 'var(--text-secondary)' }} />
          </button>
        </div>

        <div className="px-6 pt-4">
          <p style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>
            O veterinário vinculado passa a ver o prontuário deste pet e pode validar as vacinas registradas.
          </p>
          <div className="flex items-center gap-2 mt-3 px-3 py-2.5 rounded-[10px]" style={{ background: 'var(--surface-secondary)' }}>
            <Search size={15} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)', flexShrink: 0 }} />
            <input type="text" value={term} onChange={(e) => setTerm(e.target.value)} autoFocus
              placeholder="Buscar por nome ou CRMV" aria-label="Buscar veterinário"
              className="bg-transparent border-none outline-none flex-1" style={{ fontSize: '15px', color: 'var(--text-primary)' }} />
          </div>
          {error && (
            <div className="flex items-start gap-2 rounded-[10px] px-3 py-2.5 mt-3" style={{ background: 'rgba(255,59,48,0.08)' }}>
              <AlertCircle size={16} strokeWidth={2} style={{ color: 'var(--apple-red)', flexShrink: 0, marginTop: '2px' }} />
              <p style={{ fontSize: '14px', color: 'var(--apple-red)' }}>{error}</p>
            </div>
          )}
        </div>

        <div className="px-3 py-3 overflow-y-auto flex-1">
          {loading ? (
            <div className="flex items-center justify-center py-10">
              <div className="w-6 h-6 rounded-full border-2 border-transparent animate-spin" style={{ borderTopColor: 'var(--apple-blue)' }} />
            </div>
          ) : available.length === 0 ? (
            <p className="text-center px-6 py-10" style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>
              {vets.length === 0
                ? 'Ainda não há veterinários cadastrados. Peça ao seu veterinário para criar a conta no site.'
                : q ? 'Nenhum veterinário encontrado com essa busca.' : 'Todos os veterinários disponíveis já atendem este pet.'}
            </p>
          ) : (
            available.map((v) => (
              <div key={v.uid} className="flex items-center justify-between gap-3 px-3 py-3 rounded-[12px]">
                <div className="flex items-center gap-3 min-w-0">
                  <div className="w-10 h-10 rounded-[12px] flex items-center justify-center flex-shrink-0" style={{ background: 'rgba(0,122,255,0.1)' }}>
                    <Stethoscope size={18} strokeWidth={1.5} style={{ color: 'var(--apple-blue)' }} />
                  </div>
                  <div className="min-w-0">
                    <div className="font-medium truncate" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{v.name || 'Veterinário'}</div>
                    <div className="truncate" style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                      {v.crmv}{v.specialties?.length ? ` · ${v.specialties.join(', ')}` : ''}
                    </div>
                  </div>
                </div>
                <button onClick={() => handleLink(v.uid)} disabled={busyId !== null}
                  className="px-3 py-1.5 rounded-[9px] font-medium flex-shrink-0 transition-opacity duration-150"
                  style={{ fontSize: '14px', color: '#fff', background: 'var(--apple-blue)', opacity: busyId !== null && busyId !== v.uid ? 0.5 : 1 }}>
                  {busyId === v.uid ? 'Vinculando...' : 'Vincular'}
                </button>
              </div>
            ))
          )}
        </div>
      </div>
    </div>,
    document.body,
  );
}
