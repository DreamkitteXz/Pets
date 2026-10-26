import React, { useState } from 'react';
import { httpsCallable } from 'firebase/functions';
import { functions } from '../../../config/firebase';

const updateStatusFn = httpsCallable(functions, 'updateVaccineStatus', { timeout: 15000 });

/**
 * Aprovar / rejeitar uma submissão `pending` do tutor (vacina ou vermífugo).
 * Status só muda pela CF updateVaccineStatus — a rule recusa o cliente.
 * Rejeição exige motivo (a CF também exige).
 */
export default function ValidationActions({ record, collection, onDone }) {
  const [rejecting, setRejecting] = useState(false);
  const [reason, setReason] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  const send = async (isApproved) => {
    setBusy(true);
    setError('');
    try {
      await updateStatusFn({
        vaccineId: record.id,
        collection,
        isApproved,
        notes: '',
        rejectionReason: isApproved ? '' : reason.trim(),
      });
      await onDone?.();
    } catch (err) {
      setError(err?.message || 'Não foi possível validar.');
      setBusy(false);
    }
  };

  const btn = { fontSize: '13px', padding: '6px 12px', borderRadius: '8px', fontWeight: 500 };

  if (rejecting) {
    return (
      <div className="flex flex-col items-end gap-1.5">
        <div className="flex items-center gap-2">
          <input type="text" value={reason} onChange={(e) => setReason(e.target.value)} autoFocus
            placeholder="Motivo da rejeição" aria-label="Motivo da rejeição"
            style={{ fontSize: '13px', padding: '6px 10px', borderRadius: '8px', background: 'var(--surface-secondary)', color: 'var(--text-primary)', border: 'none', outline: 'none', width: '200px' }} />
          <button onClick={() => { setRejecting(false); setReason(''); }} disabled={busy}
            style={{ ...btn, color: 'var(--text-secondary)', background: 'var(--surface-secondary)' }}>
            Cancelar
          </button>
          <button onClick={() => send(false)} disabled={busy || !reason.trim()}
            style={{ ...btn, color: '#fff', background: 'var(--apple-red)', opacity: busy || !reason.trim() ? 0.5 : 1 }}>
            {busy ? 'Enviando...' : 'Rejeitar'}
          </button>
        </div>
        {error && <span style={{ fontSize: '12px', color: 'var(--apple-red)' }}>{error}</span>}
      </div>
    );
  }

  return (
    <div className="flex flex-col items-end gap-1.5">
      <div className="flex items-center gap-2">
        <button onClick={() => setRejecting(true)} disabled={busy}
          style={{ ...btn, color: 'var(--apple-red)', background: 'rgba(255,59,48,0.08)' }}>
          Rejeitar
        </button>
        <button onClick={() => send(true)} disabled={busy}
          style={{ ...btn, color: '#fff', background: 'var(--apple-green)', opacity: busy ? 0.5 : 1 }}>
          {busy ? 'Enviando...' : 'Aprovar'}
        </button>
      </div>
      {error && <span style={{ fontSize: '12px', color: 'var(--apple-red)' }}>{error}</span>}
    </div>
  );
}
