import React, { useCallback, useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { useNavigate } from 'react-router-dom';
import { httpsCallable } from 'firebase/functions';
import { signOut } from 'firebase/auth';
import { ShieldCheck, Copy, Check, ExternalLink, RefreshCw, AlertCircle, History } from 'lucide-react';
import { auth, functions } from '../../../config/firebase';

const listFn   = httpsCallable(functions, 'adminListVets', { timeout: 20000 });
const reviewFn = httpsCallable(functions, 'adminReviewVet', { timeout: 20000 });

const TABS = [
  { id: 'pending',  label: 'Em análise' },
  { id: 'approved', label: 'Aprovados' },
  { id: 'rejected', label: 'Recusados' },
];

// Consulta pública oficial: portal do CFMV ou o site do CRMV do estado.
const CFMV_URL = 'https://www.cfmv.gov.br/';

const fmtDate = (iso) => (iso ? new Date(iso).toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' }) : '—');
const fmtDateTime = (iso) => (iso ? new Date(iso).toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' }) : '—');

const isReauth = (err) => err?.code === 'functions/unauthenticated' || err?.details?.reason === 'reauth';

function CopyButton({ text }) {
  const [done, setDone] = useState(false);
  const copy = async () => {
    try {
      await navigator.clipboard.writeText(text);
      setDone(true);
      setTimeout(() => setDone(false), 1500);
    } catch { /* sem permissão de área de transferência */ }
  };
  return (
    <button type="button" onClick={copy} aria-label={`Copiar ${text}`}
      className="inline-flex items-center gap-1 rounded-[8px] px-2 py-1"
      style={{ fontSize: '12px', color: 'var(--apple-blue)', background: 'rgba(0,122,255,0.08)' }}>
      {done ? <Check size={13} /> : <Copy size={13} />} {done ? 'Copiado' : 'Copiar'}
    </button>
  );
}

function DecisionModal({ target, mode, onClose, onDone }) {
  const [reason, setReason] = useState('');
  const [confirmed, setConfirmed] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const approving = mode === 'approve';
  const canSend = approving ? confirmed : reason.trim().length >= 5;

  const send = async () => {
    setBusy(true);
    setError('');
    try {
      await reviewFn({
        uid: target.uid,
        decision: approving ? 'approve' : 'reject',
        reason: reason.trim(),
        expectedCrmv: target.crmv,
      });
      onDone();
    } catch (err) {
      setError(err?.message || 'Não foi possível registrar a decisão.');
      setBusy(false);
    }
  };

  const title = approving ? 'Aprovar CRMV' : target.crmvStatus === 'approved' ? 'Revogar aprovação' : 'Recusar CRMV';

  return createPortal(
    <div className="fixed inset-0 z-50 modal-overlay p-4 font-sf"
      style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(8px)', WebkitBackdropFilter: 'blur(8px)' }}
      onClick={busy ? undefined : onClose}>
      <div role="dialog" aria-modal="true" aria-labelledby="admin-decision-title"
        className="fade-in-up w-full max-w-[460px] rounded-[20px] overflow-hidden"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 24px 70px rgba(0,0,0,0.35)' }}
        onClick={(e) => e.stopPropagation()}>
        <div className="px-6 py-5" style={{ borderBottom: '1px solid var(--separator)' }}>
          <h2 id="admin-decision-title" className="font-bold" style={{ fontSize: '19px', color: 'var(--text-primary)' }}>{title}</h2>
          <p className="mt-1" style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>
            {target.name} · <span className="font-semibold">{target.crmv}</span>
          </p>
        </div>
        <div className="px-6 py-5 flex flex-col gap-4">
          {approving ? (
            <label className="flex items-start gap-3 cursor-pointer" style={{ fontSize: '14px', color: 'var(--text-primary)', lineHeight: 1.45 }}>
              <input type="checkbox" checked={confirmed} onChange={(e) => setConfirmed(e.target.checked)} className="mt-1 w-4 h-4 flex-shrink-0" />
              <span>
                Conferi na consulta oficial do CFMV/CRMV que o registro <strong>{target.crmv}</strong> pertence
                a <strong>{target.name}</strong> e está ativo.
              </span>
            </label>
          ) : (
            <label className="flex flex-col gap-1.5">
              <span style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text-secondary)' }}>
                Motivo (o veterinário verá esta mensagem)
              </span>
              <textarea value={reason} onChange={(e) => setReason(e.target.value)} rows={3} maxLength={500} autoFocus
                placeholder="Ex.: CRMV não encontrado na consulta do CRMV-SP."
                className="w-full rounded-[12px] px-3.5 py-2.5 outline-none resize-none"
                style={{ fontSize: '16px', background: 'var(--surface-secondary)', color: 'var(--text-primary)', border: 'none' }} />
            </label>
          )}
          {error && (
            <p className="flex items-start gap-1.5" style={{ fontSize: '13px', color: 'var(--apple-red)' }}>
              <AlertCircle size={14} style={{ flexShrink: 0, marginTop: '2px' }} /> {error}
            </p>
          )}
          <div className="flex justify-end gap-2.5">
            <button type="button" onClick={onClose} disabled={busy}
              className="px-4 py-2.5 rounded-[12px] font-semibold"
              style={{ fontSize: '15px', background: 'var(--surface-secondary)', color: 'var(--text-primary)' }}>
              Cancelar
            </button>
            <button type="button" onClick={send} disabled={!canSend || busy}
              className="px-4 py-2.5 rounded-[12px] font-semibold"
              style={{
                fontSize: '15px', color: '#fff',
                background: approving ? 'var(--apple-green)' : 'var(--apple-red)',
                opacity: !canSend || busy ? 0.5 : 1,
              }}>
              {busy ? 'Salvando…' : approving ? 'Aprovar' : title.split(' ')[0]}
            </button>
          </div>
        </div>
      </div>
    </div>,
    document.body,
  );
}

function VetCard({ vet, onDecide }) {
  const uf = vet.crmv.match(/^CRMV-([A-Z]{2})/)?.[1];
  // A CF recusa decidir sobre o próprio CRMV; aqui só não oferecemos o botão.
  const isSelf = vet.uid === auth.currentUser?.uid;
  return (
    <article className="rounded-[18px] p-4 md:p-5 flex flex-col gap-3"
      style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}>
      <div className="flex flex-col md:flex-row md:items-start md:justify-between gap-3">
        <div className="min-w-0">
          <h3 className="font-semibold truncate" style={{ fontSize: '16px', color: 'var(--text-primary)' }}>{vet.name || '(sem nome)'}</h3>
          <p className="truncate" style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>{vet.email}{vet.phone ? ` · ${vet.phone}` : ''}</p>
        </div>
        <div className="flex items-center gap-2 flex-wrap">
          <span className="font-bold tracking-tight" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>{vet.crmv}</span>
          <CopyButton text={vet.crmv} />
        </div>
      </div>

      <dl className="grid grid-cols-2 md:grid-cols-4 gap-x-4 gap-y-2" style={{ fontSize: '13px' }}>
        <div><dt style={{ color: 'var(--text-tertiary)' }}>Estado do CRMV</dt><dd style={{ color: 'var(--text-primary)' }}>{uf || '—'}</dd></div>
        <div><dt style={{ color: 'var(--text-tertiary)' }}>Cadastro</dt><dd style={{ color: 'var(--text-primary)' }}>{fmtDate(vet.createdAt)}</dd></div>
        <div><dt style={{ color: 'var(--text-tertiary)' }}>Experiência</dt><dd style={{ color: 'var(--text-primary)' }}>{vet.yearsOfExperience ? `${vet.yearsOfExperience} anos` : '—'}</dd></div>
        <div className="col-span-2 md:col-span-1"><dt style={{ color: 'var(--text-tertiary)' }}>Especialidades</dt><dd className="truncate" style={{ color: 'var(--text-primary)' }}>{vet.specialties.join(', ') || '—'}</dd></div>
      </dl>

      {vet.review && (
        <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
          {vet.crmvStatus === 'approved' ? 'Aprovado' : 'Recusado'} em {fmtDateTime(vet.review.reviewedAt)} por {vet.review.reviewedByEmail}
          {vet.review.reason ? ` — “${vet.review.reason}”` : ''}
          {vet.review.crmv && vet.review.crmv !== vet.crmv ? ` (CRMV analisado: ${vet.review.crmv})` : ''}
        </p>
      )}

      {isSelf ? (
        <p className="pt-1" style={{ fontSize: '13px', color: 'var(--text-tertiary)' }}>
          Este é o seu cadastro: outro administrador precisa analisá-lo.
        </p>
      ) : (
      <div className="flex flex-wrap gap-2 justify-end pt-1">
        {vet.crmvStatus !== 'rejected' && (
          <button type="button" onClick={() => onDecide(vet, 'reject')}
            className="px-3.5 py-2 rounded-[10px] font-semibold"
            style={{ fontSize: '14px', color: 'var(--apple-red)', background: 'rgba(255,59,48,0.08)' }}>
            {vet.crmvStatus === 'approved' ? 'Revogar' : 'Recusar'}
          </button>
        )}
        {vet.crmvStatus !== 'approved' && (
          <button type="button" onClick={() => onDecide(vet, 'approve')}
            className="px-3.5 py-2 rounded-[10px] font-semibold"
            style={{ fontSize: '14px', color: '#fff', background: 'var(--apple-green)' }}>
            Aprovar
          </button>
        )}
      </div>
      )}
    </article>
  );
}

export default function AdminVets() {
  const navigate = useNavigate();
  const [tab, setTab] = useState('pending');
  const [data, setData] = useState({ vets: [], counts: { pending: 0, approved: 0, rejected: 0 }, audit: [] });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [decision, setDecision] = useState(null); // { vet, mode }

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await listFn({ status: tab });
      setData(res.data);
    } catch (err) {
      setError(err);
    } finally {
      setLoading(false);
    }
  }, [tab]);

  useEffect(() => { load(); }, [load]);

  const reLogin = async () => {
    await signOut(auth);
    navigate('/auth', { replace: true });
  };

  return (
    <div className="min-h-full font-sf flex flex-col gap-5">
      <div className="fade-in-up flex items-start justify-between gap-3">
        <div>
          <h1 className="font-bold flex items-center gap-2" style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
            <ShieldCheck size={26} strokeWidth={1.75} style={{ color: 'var(--apple-blue)' }} /> Administração
          </h1>
          <p className="mt-1" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
            Verificação do CRMV. Só veterinários aprovados validam vacinas e aparecem para os tutores.
          </p>
        </div>
        <button type="button" onClick={load} aria-label="Atualizar"
          className="w-10 h-10 md:w-9 md:h-9 flex-shrink-0 rounded-[10px] flex items-center justify-center"
          style={{ background: 'var(--surface-grouped-secondary)' }}>
          <RefreshCw size={16} strokeWidth={1.5} style={{ color: 'var(--text-secondary)' }} />
        </button>
      </div>

      <div className="rounded-[14px] px-4 py-3 flex flex-col md:flex-row md:items-center gap-2 md:gap-4"
        style={{ background: 'rgba(0,122,255,0.08)', fontSize: '13px', color: 'var(--text-primary)', lineHeight: 1.45 }}>
        <span className="flex-1">
          <strong>Como conferir:</strong> copie o CRMV, consulte no portal do CFMV ou no site do CRMV do estado,
          e confira se o nome bate e se o registro está ativo. Toda decisão fica registrada com seu e-mail.
        </span>
        <a href={CFMV_URL} target="_blank" rel="noopener noreferrer"
          className="inline-flex items-center gap-1 font-semibold flex-shrink-0" style={{ color: 'var(--apple-blue)' }}>
          Portal do CFMV <ExternalLink size={13} />
        </a>
      </div>

      <div role="tablist" aria-label="Situação do CRMV" className="flex gap-1 p-1 rounded-[12px] self-start max-w-full overflow-x-auto"
        style={{ background: 'var(--surface-secondary)' }}>
        {TABS.map((t) => {
          const active = t.id === tab;
          return (
            <button key={t.id} role="tab" aria-selected={active} type="button" onClick={() => setTab(t.id)}
              className="px-3.5 py-2 rounded-[9px] font-semibold whitespace-nowrap"
              style={{
                fontSize: '14px',
                background: active ? 'var(--surface-grouped-secondary)' : 'transparent',
                color: active ? 'var(--text-primary)' : 'var(--text-secondary)',
                boxShadow: active ? '0 1px 2px rgba(0,0,0,0.08)' : 'none',
              }}>
              {t.label} <span style={{ color: 'var(--text-tertiary)' }}>{data.counts?.[t.id] ?? 0}</span>
            </button>
          );
        })}
      </div>

      {error ? (
        <div className="rounded-[16px] p-5 flex flex-col items-start gap-3"
          style={{ background: 'var(--surface-grouped-secondary)' }}>
          <p className="flex items-start gap-2" style={{ fontSize: '14px', color: 'var(--apple-red)' }}>
            <AlertCircle size={16} style={{ flexShrink: 0, marginTop: '2px' }} />
            {error.message || 'Não foi possível carregar.'}
          </p>
          {isReauth(error) && (
            <button type="button" onClick={reLogin} className="px-4 py-2 rounded-[10px] font-semibold"
              style={{ fontSize: '14px', color: '#fff', background: 'var(--apple-blue)' }}>
              Entrar novamente
            </button>
          )}
        </div>
      ) : loading ? (
        <div className="flex items-center justify-center h-40">
          <div className="w-7 h-7 rounded-full border-2 border-transparent animate-spin" style={{ borderTopColor: 'var(--apple-blue)' }} />
        </div>
      ) : data.vets.length === 0 ? (
        <p className="py-10 text-center" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
          {tab === 'pending' ? 'Nenhum CRMV aguardando análise.' : 'Nada por aqui.'}
        </p>
      ) : (
        <div className="flex flex-col gap-3">
          {data.vets.map((v) => (
            <VetCard key={v.uid} vet={v} onDecide={(vet, mode) => setDecision({ vet, mode })} />
          ))}
        </div>
      )}

      {data.audit?.length > 0 && (
        <section className="mt-2">
          <h2 className="font-semibold flex items-center gap-1.5 mb-2" style={{ fontSize: '13px', letterSpacing: '0.02em', color: 'var(--text-secondary)' }}>
            <History size={14} /> ÚLTIMAS DECISÕES
          </h2>
          <ul className="rounded-[16px] overflow-hidden" style={{ background: 'var(--surface-grouped-secondary)' }}>
            {data.audit.map((a, i) => (
              <li key={a.id} className="px-4 py-3 flex flex-col md:flex-row md:items-center md:justify-between gap-0.5 md:gap-4"
                style={{ fontSize: '13px', borderTop: i ? '1px solid var(--separator)' : 'none' }}>
                <span style={{ color: 'var(--text-primary)' }}>
                  <strong style={{ color: a.newStatus === 'approved' ? 'var(--apple-green)' : 'var(--apple-red)' }}>
                    {a.newStatus === 'approved' ? 'Aprovou' : a.previousStatus === 'approved' ? 'Revogou' : 'Recusou'}
                  </strong>{' '}
                  {a.targetName} ({a.targetCrmv}){a.reason ? ` — “${a.reason}”` : ''}
                </span>
                <span className="flex-shrink-0" style={{ color: 'var(--text-tertiary)' }}>{a.actorEmail} · {fmtDateTime(a.at)}</span>
              </li>
            ))}
          </ul>
        </section>
      )}

      {decision && (
        <DecisionModal target={decision.vet} mode={decision.mode}
          onClose={() => setDecision(null)}
          onDone={() => { setDecision(null); load(); }} />
      )}
    </div>
  );
}
