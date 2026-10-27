import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { doc, onSnapshot } from 'firebase/firestore';
import { Clock, AlertCircle } from 'lucide-react';
import { db } from '../../../config/firebase';
import { useAuth } from '../../../context/AuthContext';

/**
 * Aviso para o veterinário cujo CRMV ainda não foi aprovado pela administração.
 * Escuta o próprio perfil ao vivo: quando a administração aprova, o aviso some
 * sem precisar recarregar. Só informa — quem bloqueia de fato são as CFs.
 */
export default function VetVerificationBanner() {
  const { user, userProfile } = useAuth();
  const isVet = userProfile?.role === 'veterinarian';
  const [live, setLive] = useState(null);

  useEffect(() => {
    if (!isVet || !user?.uid) return undefined;
    return onSnapshot(doc(db, 'users', user.uid), (snap) => setLive(snap.data() || null), () => {});
  }, [isVet, user?.uid]);

  if (!isVet) return null;
  const profile = live || userProfile;
  const status = profile?.crmvStatus;
  if (status === 'approved') return null;

  const rejected = status === 'rejected';
  return (
    <div role="status" className="mb-4 md:mb-5 rounded-[14px] px-4 py-3 flex items-start gap-2.5 font-sf"
      style={{
        background: rejected ? 'rgba(255,59,48,0.10)' : 'rgba(255,149,0,0.12)',
        fontSize: '14px', lineHeight: 1.45, color: 'var(--text-primary)',
      }}>
      {rejected
        ? <AlertCircle size={18} style={{ flexShrink: 0, marginTop: '1px', color: 'var(--apple-red)' }} />
        : <Clock size={18} style={{ flexShrink: 0, marginTop: '1px', color: 'var(--apple-orange)' }} />}
      <div>
        {rejected ? (
          <>
            <strong>Seu CRMV não foi aprovado.</strong>
            {profile?.crmvReview?.reason ? <> Motivo: “{profile.crmvReview.reason}”.</> : null}{' '}
            Corrija o CRMV em <Link to="/settings" className="font-semibold" style={{ color: 'var(--apple-blue)' }}>Configurações</Link> para enviar de novo para análise.
          </>
        ) : (
          <>
            <strong>Seu CRMV ({profile?.crmv || '—'}) está em análise.</strong>{' '}
            Enquanto isso você ainda não aparece para os tutores e não pode validar nem registrar aplicações.
          </>
        )}
      </div>
    </div>
  );
}
