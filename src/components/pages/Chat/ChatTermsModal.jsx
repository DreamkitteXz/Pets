import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { doc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { ShieldCheck } from 'lucide-react';
import { db } from '../../../config/firebase';

// Versão do termo: mudou o texto, sobe o número e todos aceitam de novo.
export const CHAT_TERMS_VERSION = 1;

// Base: Resolução CFMV nº 1.465/2022 (telemedicina veterinária) — orientação
// remota não é diagnóstico; teleconsulta exige atendimento presencial prévio
// registrado em prontuário; urgência/emergência não se atende por chat; o que
// for trocado integra o prontuário (art. 13).
const TERMS = {
  tutor: [
    'O chat serve para tirar dúvidas e receber orientações do veterinário do seu pet. Ele não substitui uma consulta presencial.',
    'Em caso de urgência ou emergência, não use o chat: procure imediatamente uma clínica ou hospital veterinário.',
    'Diagnóstico e receita pelo chat só são possíveis se o veterinário já tiver atendido o seu pet pessoalmente.',
    'As mensagens com informação de saúde do pet fazem parte do prontuário e ficam guardadas por pelo menos 5 anos, conforme as normas do CFMV. Por isso não podem ser apagadas.',
    'Seus dados são tratados conforme a LGPD e a nossa política de privacidade.',
  ],
  veterinarian: [
    'Vou usar o chat conforme a Resolução CFMV nº 1.465/2022 (telemedicina veterinária).',
    'Sem atendimento presencial prévio registrado em prontuário, me limito a orientações gerais, sem diagnóstico nem prescrição.',
    'Em casos de urgência ou emergência, oriento o tutor a buscar atendimento presencial imediato.',
    'Sei que as mensagens com conteúdo clínico integram o prontuário do animal e ficam guardadas por pelo menos 5 anos.',
  ],
};

export default function ChatTermsModal({ uid, role, onAccepted }) {
  const [checked, setChecked] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const items = TERMS[role === 'tutor' ? 'tutor' : 'veterinarian'];

  const accept = async () => {
    setSaving(true);
    setError('');
    try {
      await updateDoc(doc(db, 'users', uid), {
        chatTermsVersion: CHAT_TERMS_VERSION,
        chatTermsAcceptedAt: serverTimestamp(),
      });
      onAccepted();
    } catch {
      setError('Não foi possível registrar o aceite. Tente de novo.');
      setSaving(false);
    }
  };

  return createPortal(
    <div className="fixed inset-0 z-50 modal-overlay p-4 font-sf"
      style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(8px)', WebkitBackdropFilter: 'blur(8px)' }}>
      <div role="dialog" aria-modal="true" aria-labelledby="chat-terms-title"
        className="fade-in-up w-full max-w-[520px] rounded-[20px] overflow-hidden"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 24px 70px rgba(0,0,0,0.35)' }}>
        <div className="px-6 py-5 flex items-center gap-2.5" style={{ borderBottom: '1px solid var(--separator)' }}>
          <ShieldCheck size={22} style={{ color: 'var(--apple-blue)' }} />
          <h2 id="chat-terms-title" className="font-bold" style={{ fontSize: '19px', color: 'var(--text-primary)' }}>
            Antes de usar o chat
          </h2>
        </div>
        <div className="px-6 py-5 flex flex-col gap-4">
          <ul className="flex flex-col gap-2.5" style={{ fontSize: '14px', color: 'var(--text-primary)', lineHeight: 1.5 }}>
            {items.map((t) => (
              <li key={t} className="flex gap-2">
                <span style={{ color: 'var(--apple-blue)' }}>•</span>
                <span>{t}</span>
              </li>
            ))}
          </ul>
          <label className="flex items-start gap-2.5 cursor-pointer" style={{ fontSize: '14px', color: 'var(--text-primary)' }}>
            <input type="checkbox" checked={checked} onChange={(e) => setChecked(e.target.checked)} className="mt-1 w-4 h-4 flex-shrink-0" />
            <span>Li e concordo com estas condições de uso do chat.</span>
          </label>
          {error && <p style={{ fontSize: '13px', color: 'var(--apple-red)' }}>{error}</p>}
          <button type="button" onClick={accept} disabled={!checked || saving}
            className="px-4 py-3 rounded-[12px] font-semibold"
            style={{ fontSize: '15px', color: '#fff', background: 'var(--apple-blue)', opacity: !checked || saving ? 0.5 : 1 }}>
            {saving ? 'Salvando…' : 'Aceitar e continuar'}
          </button>
        </div>
      </div>
    </div>,
    document.body,
  );
}
