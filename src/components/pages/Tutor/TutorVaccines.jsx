import React, { useState } from 'react';
import { Syringe, CheckCircle, XCircle, Clock, Check, X } from 'lucide-react';
import { useTutorVaccines } from '../../../hooks/useTutorVaccines';

const toDate = (v) => {
  if (!v) return null;
  if (v.toDate instanceof Function) return v.toDate();
  if (v.seconds) return new Date(v.seconds * 1000);
  return new Date(v);
};
const fmt = (v) => { const d = toDate(v); return d ? d.toLocaleDateString('pt-BR') : '—'; };

const TUTOR_STATUS = {
  approved: { label: 'Você aprovou', color: 'var(--apple-green)', bg: 'rgba(52,199,89,0.12)', icon: CheckCircle },
  rejected: { label: 'Você rejeitou', color: 'var(--apple-red)', bg: 'rgba(255,59,48,0.10)', icon: XCircle },
  pending:  { label: 'Aguardando você', color: 'var(--apple-orange)', bg: 'rgba(255,149,0,0.12)', icon: Clock },
};

const KpiCard = ({ label, value, accentColor, icon: Icon, delay }) => (
  <div className="fade-in-up rounded-[16px] p-5 flex items-center justify-between"
    style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: `${delay}ms` }}>
    <div>
      <div className="text-[28px] font-bold leading-none" style={{ color: accentColor, letterSpacing: '-0.02em' }}>{value}</div>
      <div className="text-[13px] mt-1" style={{ color: 'var(--text-secondary)' }}>{label}</div>
    </div>
    <div className="w-10 h-10 rounded-[12px] flex items-center justify-center flex-shrink-0" style={{ background: `${accentColor}18` }}>
      <Icon size={20} strokeWidth={1.5} style={{ color: accentColor }} />
    </div>
  </div>
);

const TutorVaccines = () => {
  const { vaccines, loading, respond } = useTutorVaccines();
  const [busyId, setBusyId] = useState(null);

  const tutorStatusOf = (v) => v.validationDetails?.tutorValidation?.status || 'pending';
  const pending = vaccines.filter(v => tutorStatusOf(v) === 'pending').length;
  const approved = vaccines.filter(v => tutorStatusOf(v) === 'approved').length;

  const handle = async (id, decision) => {
    setBusyId(id);
    try { await respond(id, decision); } finally { setBusyId(null); }
  };

  return (
    <div className="min-h-full font-sf">
      <div className="mb-6 fade-in-up">
        <h1 className="font-bold" style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
          Vacinas
        </h1>
        <p className="mt-1" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
          Confirme as vacinas registradas para os seus pets.
        </p>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-64">
          <div className="w-8 h-8 rounded-full border-2 border-transparent animate-spin" style={{ borderTopColor: 'var(--apple-blue)' }} />
        </div>
      ) : (
        <>
          <div className="grid grid-cols-3 gap-4 mb-6">
            <KpiCard label="Total" value={vaccines.length} accentColor="var(--apple-blue)" icon={Syringe} delay={50} />
            <KpiCard label="Aguardando você" value={pending} accentColor="var(--apple-orange)" icon={Clock} delay={100} />
            <KpiCard label="Aprovadas por você" value={approved} accentColor="var(--apple-green)" icon={CheckCircle} delay={150} />
          </div>

          <div className="fade-in-up rounded-[20px] overflow-hidden" style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '200ms' }}>
            {vaccines.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-20 gap-3">
                <div className="w-16 h-16 rounded-full flex items-center justify-center" style={{ background: 'rgba(0,122,255,0.1)' }}>
                  <Syringe size={28} strokeWidth={1.5} style={{ color: 'var(--apple-blue)' }} />
                </div>
                <p className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>Nenhuma vacina registrada</p>
                <p style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>As vacinas dos seus pets aparecerão aqui.</p>
              </div>
            ) : (
              vaccines.map((v, i) => {
                const ts = tutorStatusOf(v);
                const cfg = TUTOR_STATUS[ts] || TUTOR_STATUS.pending;
                const StatusIcon = cfg.icon;
                const isPending = ts === 'pending';
                return (
                  <div key={v.id} className="px-6 py-4 flex items-center justify-between gap-4"
                    style={{ borderBottom: i < vaccines.length - 1 ? '1px solid var(--separator)' : 'none' }}>
                    <div className="min-w-0">
                      <div className="font-medium" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>
                        {v.name} <span style={{ color: 'var(--text-tertiary)', fontWeight: 400 }}>· {v.petName}</span>
                      </div>
                      <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                        Aplicada: {fmt(v.administrationDate)} · Próxima: {fmt(v.nextDueDate)}
                      </div>
                      {v.veterinarianName && (
                        <div style={{ fontSize: '12px', color: 'var(--text-tertiary)' }}>{v.veterinarianName}</div>
                      )}
                    </div>

                    {isPending ? (
                      <div className="flex items-center gap-2 flex-shrink-0">
                        <button onClick={() => handle(v.id, 'rejected')} disabled={busyId === v.id}
                          className="flex items-center gap-1.5 px-3 py-2 rounded-[10px] font-medium transition-opacity duration-150"
                          style={{ fontSize: '14px', color: 'var(--apple-red)', background: 'rgba(255,59,48,0.10)', opacity: busyId === v.id ? 0.5 : 1 }}>
                          <X size={14} strokeWidth={2.5} /> Rejeitar
                        </button>
                        <button onClick={() => handle(v.id, 'approved')} disabled={busyId === v.id}
                          className="flex items-center gap-1.5 px-3 py-2 rounded-[10px] font-medium transition-opacity duration-150"
                          style={{ fontSize: '14px', color: '#fff', background: 'var(--apple-green)', opacity: busyId === v.id ? 0.5 : 1 }}>
                          <Check size={14} strokeWidth={2.5} /> Aprovar
                        </button>
                      </div>
                    ) : (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[12px] font-medium flex-shrink-0"
                        style={{ background: cfg.bg, color: cfg.color }}>
                        <StatusIcon size={11} strokeWidth={2} /> {cfg.label}
                      </span>
                    )}
                  </div>
                );
              })
            )}
          </div>
        </>
      )}
    </div>
  );
};

export default TutorVaccines;
