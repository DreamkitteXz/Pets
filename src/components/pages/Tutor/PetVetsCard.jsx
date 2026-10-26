import React, { useState } from 'react';
import { doc, updateDoc, arrayUnion, arrayRemove, serverTimestamp } from 'firebase/firestore';
import { Stethoscope, Plus } from 'lucide-react';
import { db } from '../../../config/firebase';
import { useVetDirectory } from '../../../hooks/useVetDirectory';
import LinkVetModal from './LinkVetModal';

/**
 * Veterinários que atendem o pet — visão do TUTOR.
 *
 * O vínculo é `pets.veterinarians` (a rule deixa o dono alterar). Estar nessa
 * lista é o que dá ao vet acesso ao prontuário e coloca o pet em "Pacientes".
 */
export default function PetVetsCard({ pet, onChanged }) {
  const { vets, loading } = useVetDirectory();
  const [linkOpen, setLinkOpen] = useState(false);
  const [confirmId, setConfirmId] = useState(null);
  const [busyId, setBusyId] = useState(null);
  const [error, setError] = useState('');

  const linkedIds = Array.isArray(pet.veterinarians) ? pet.veterinarians : [];
  const byId = Object.fromEntries(vets.map((v) => [v.uid, v]));

  const petRef = doc(db, 'pets', pet.id);

  const link = async (uid) => {
    await updateDoc(petRef, { veterinarians: arrayUnion(uid), updatedAt: serverTimestamp() });
    await onChanged?.();
  };

  const unlink = async (uid) => {
    setBusyId(uid);
    setError('');
    try {
      await updateDoc(petRef, { veterinarians: arrayRemove(uid), updatedAt: serverTimestamp() });
      setConfirmId(null);
      await onChanged?.();
    } catch (err) {
      setError(err?.message || 'Não foi possível remover o veterinário.');
    } finally {
      setBusyId(null);
    }
  };

  return (
    <div className="fade-in-up rounded-[20px] overflow-hidden mb-5"
      style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '60ms' }}>
      <div className="px-6 py-4 flex items-center justify-between gap-3" style={{ borderBottom: '1px solid var(--separator)' }}>
        <h2 className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>
          Veterinários do pet ({linkedIds.length})
        </h2>
        <button onClick={() => setLinkOpen(true)}
          className="flex items-center gap-1.5 px-3 py-1.5 rounded-[9px] font-medium transition-opacity duration-150 hover:opacity-90"
          style={{ fontSize: '14px', color: '#fff', background: 'var(--apple-blue)' }}>
          <Plus size={15} strokeWidth={2.5} /> Vincular veterinário
        </button>
      </div>

      {error && <p className="px-6 pt-3" style={{ fontSize: '14px', color: 'var(--apple-red)' }}>{error}</p>}

      {linkedIds.length === 0 ? (
        <p className="px-6 py-5" style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>
          Nenhum veterinário vinculado. Vincule o veterinário que atende o pet para ele ver o prontuário e validar as vacinas.
        </p>
      ) : (
        linkedIds.map((uid, i) => {
          const v = byId[uid];
          return (
            <div key={uid} className="px-6 py-3.5 flex items-center justify-between gap-3"
              style={{ borderBottom: i < linkedIds.length - 1 ? '1px solid var(--separator)' : 'none' }}>
              <div className="flex items-center gap-3 min-w-0">
                <div className="w-9 h-9 rounded-[11px] flex items-center justify-center flex-shrink-0" style={{ background: 'rgba(0,122,255,0.1)' }}>
                  <Stethoscope size={16} strokeWidth={1.5} style={{ color: 'var(--apple-blue)' }} />
                </div>
                <div className="min-w-0">
                  <div className="font-medium truncate" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>
                    {v?.name || (loading ? 'Carregando…' : 'Veterinário')}
                  </div>
                  <div className="truncate" style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                    {v ? v.crmv : (loading ? '' : 'Perfil não está mais disponível no diretório')}
                  </div>
                </div>
              </div>

              {confirmId === uid ? (
                <div className="flex items-center gap-2 flex-shrink-0">
                  <button onClick={() => setConfirmId(null)} disabled={busyId === uid}
                    className="px-3 py-1.5 rounded-[9px] font-medium" style={{ fontSize: '14px', color: 'var(--text-secondary)', background: 'var(--surface-secondary)' }}>
                    Cancelar
                  </button>
                  <button onClick={() => unlink(uid)} disabled={busyId === uid}
                    className="px-3 py-1.5 rounded-[9px] font-medium" style={{ fontSize: '14px', color: '#fff', background: 'var(--apple-red)', opacity: busyId === uid ? 0.5 : 1 }}>
                    {busyId === uid ? 'Removendo...' : 'Remover'}
                  </button>
                </div>
              ) : (
                <button onClick={() => setConfirmId(uid)}
                  className="font-medium flex-shrink-0" style={{ fontSize: '14px', color: 'var(--apple-red)' }}>
                  Remover
                </button>
              )}
            </div>
          );
        })
      )}

      <LinkVetModal
        isOpen={linkOpen}
        onClose={() => setLinkOpen(false)}
        vets={vets}
        loading={loading}
        linkedIds={linkedIds}
        onLink={link}
      />
    </div>
  );
}
