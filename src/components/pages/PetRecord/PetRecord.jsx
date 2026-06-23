import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  ArrowLeft, Plus, Stethoscope, Syringe, Bug, Scale,
  CheckCircle, Clock, XCircle, CalendarClock, Weight,
} from 'lucide-react';
import { usePetRecord } from '../../../hooks/usePetRecord';
import { useAuth } from '../../../context/AuthContext';
import WeightChart from './WeightChart';
import RecordFormModal from './RecordFormModal';

// ── Helpers ──────────────────────────────────────────────────────────────────
const toDate = (v) => {
  if (!v) return null;
  if (v.toDate instanceof Function) return v.toDate();
  if (v.seconds) return new Date(v.seconds * 1000);
  if (v instanceof Date) return v;
  return new Date(v);
};
const fmt = (v) => {
  const d = toDate(v);
  return d ? d.toLocaleDateString('pt-BR') : '—';
};
const getAge = (birthDate) => {
  const birth = toDate(birthDate);
  if (!birth) return '—';
  const months = (new Date().getFullYear() - birth.getFullYear()) * 12 + (new Date().getMonth() - birth.getMonth());
  if (months < 12) return `${months} ${months === 1 ? 'mês' : 'meses'}`;
  const years = Math.floor(months / 12);
  return `${years} ${years === 1 ? 'ano' : 'anos'}`;
};

const VAC_STATUS = {
  approved:    { label: 'Aprovado',     color: 'var(--apple-green)',  bg: 'rgba(52,199,89,0.12)',  icon: CheckCircle },
  vetApproved: { label: 'Aprovado Vet', color: 'var(--apple-indigo)', bg: 'rgba(88,86,214,0.10)',  icon: CheckCircle },
  pending:     { label: 'Pendente',     color: 'var(--apple-orange)', bg: 'rgba(255,149,0,0.12)',  icon: Clock },
  vetRejected: { label: 'Rejeitado',    color: 'var(--apple-red)',    bg: 'rgba(255,59,48,0.10)',  icon: XCircle },
  rejected:    { label: 'Rejeitado',    color: 'var(--apple-red)',    bg: 'rgba(255,59,48,0.10)',  icon: XCircle },
};
const DEW_STATUS = {
  active:    { label: 'Ativo',     color: 'var(--apple-green)',  bg: 'rgba(52,199,89,0.12)' },
  completed: { label: 'Concluído', color: 'var(--apple-blue)',   bg: 'rgba(0,122,255,0.10)' },
  expired:   { label: 'Vencido',   color: 'var(--apple-red)',    bg: 'rgba(255,59,48,0.10)' },
};

const Badge = ({ label, color, bg, icon: Icon }) => (
  <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[12px] font-medium" style={{ background: bg, color }}>
    {Icon ? <Icon size={11} strokeWidth={2} /> : <span className="w-1.5 h-1.5 rounded-full" style={{ background: color }} />}
    {label}
  </span>
);

const InfoItem = ({ label, value }) => (
  <div>
    <div style={{ fontSize: '11px', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.05em', color: 'var(--text-tertiary)' }}>{label}</div>
    <div className="mt-0.5" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{value || '—'}</div>
  </div>
);

const EmptyState = ({ icon: Icon, text }) => (
  <div className="flex flex-col items-center justify-center py-12 gap-2">
    <Icon size={26} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)' }} />
    <p style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>{text}</p>
  </div>
);

const card = {
  background: 'var(--surface-grouped-secondary)',
  boxShadow: '0 1px 3px rgba(0,0,0,0.06)',
};

// ── Tabs config (extensible: add an entry to introduce a new section) ─────────
const TABS = [
  { key: 'consultas',      label: 'Consultas',       icon: Stethoscope },
  { key: 'peso',           label: 'Peso',            icon: Scale },
  { key: 'vacinas',        label: 'Vacinas',         icon: Syringe },
  { key: 'vermifugacoes',  label: 'Vermifugações',   icon: Bug },
];

const PetRecord = () => {
  const { petId } = useParams();
  const navigate = useNavigate();
  const { userProfile } = useAuth();
  const { pet, vaccines, dewormings, consultas, pesos, loading, error, addConsulta, addPeso } = usePetRecord(petId);
  const [tab, setTab] = useState('consultas');
  const [modalType, setModalType] = useState(null); // 'consulta' | 'peso' | null

  // Tutors view the record read-only; vets can add records.
  const isTutor = userProfile?.role === 'tutor';
  const backTo = isTutor ? '/meus-pets' : '/pets';

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 rounded-full border-2 border-transparent animate-spin" style={{ borderTopColor: 'var(--apple-blue)' }} />
      </div>
    );
  }
  if (error || !pet) {
    return (
      <div className="flex flex-col items-center justify-center h-64 gap-3 font-sf">
        <XCircle size={32} strokeWidth={1.5} style={{ color: 'var(--apple-red)' }} />
        <p style={{ color: 'var(--text-secondary)', fontSize: '15px' }}>{error?.message || 'Paciente não encontrado.'}</p>
        <button onClick={() => navigate(backTo)} className="font-medium" style={{ fontSize: '15px', color: 'var(--apple-blue)' }}>
          Voltar
        </button>
      </div>
    );
  }

  const latestWeight = pesos.length > 0 ? pesos[pesos.length - 1].weight : pet.weight;

  return (
    <div className="min-h-full font-sf">

      {/* ── Back + header ───────────────────────────────────────────────── */}
      <button onClick={() => navigate(backTo)}
        className="fade-in-up flex items-center gap-1.5 mb-4 font-medium transition-opacity duration-150"
        style={{ fontSize: '14px', color: 'var(--text-secondary)' }}
        onMouseEnter={e => e.currentTarget.style.opacity = '0.7'}
        onMouseLeave={e => e.currentTarget.style.opacity = '1'}>
        <ArrowLeft size={16} strokeWidth={2} /> {isTutor ? 'Meus Pets' : 'Pacientes'}
      </button>

      {/* ── Summary card ─────────────────────────────────────────────────── */}
      <div className="fade-in-up rounded-[20px] p-6 mb-5" style={{ ...card, animationDelay: '40ms' }}>
        <div className="flex items-start gap-4">
          <div className="w-14 h-14 rounded-[16px] flex items-center justify-center font-bold text-[22px] flex-shrink-0"
            style={{ background: 'rgba(0,122,255,0.1)', color: 'var(--apple-blue)' }}>
            {pet.name?.[0]?.toUpperCase() || '?'}
          </div>
          <div className="flex-1 min-w-0">
            <h1 className="font-bold" style={{ fontSize: '26px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>{pet.name}</h1>
            <p style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
              {pet.species}{pet.breed ? ` · ${pet.breed}` : ''} · {getAge(pet.birthDate)}
            </p>
          </div>
          {latestWeight != null && (
            <div className="text-right flex-shrink-0">
              <div className="flex items-center gap-1.5 justify-end">
                <Weight size={15} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)' }} />
                <span className="font-bold" style={{ fontSize: '22px', color: 'var(--text-primary)', letterSpacing: '-0.01em' }}>{latestWeight} kg</span>
              </div>
              <div style={{ fontSize: '12px', color: 'var(--text-tertiary)' }}>peso atual</div>
            </div>
          )}
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-5 pt-5" style={{ borderTop: '1px solid var(--separator)' }}>
          <InfoItem label="Tutor" value={pet.ownerName} />
          <InfoItem label="Sexo" value={pet.gender} />
          <InfoItem label="Castrado" value={pet.isNeutered ? 'Sim' : 'Não'} />
          <InfoItem label="Microchip" value={pet.chipNumber} />
          <InfoItem label="Alergias" value={(pet.allergies || []).join(', ')} />
          <InfoItem label="Condições crônicas" value={pet.chronicConditions} />
        </div>
      </div>

      {/* ── Segmented tabs ───────────────────────────────────────────────── */}
      <div className="fade-in-up flex gap-1 p-1 rounded-[12px] mb-5 overflow-x-auto"
        style={{ background: 'var(--surface-secondary)', animationDelay: '80ms' }}>
        {TABS.map(t => {
          const Icon = t.icon;
          const active = tab === t.key;
          return (
            <button key={t.key} onClick={() => setTab(t.key)}
              className="flex items-center gap-2 px-4 py-2 rounded-[9px] font-medium transition-all duration-150 whitespace-nowrap"
              style={{
                fontSize: '14px',
                flex: 1,
                justifyContent: 'center',
                background: active ? 'var(--surface-grouped-secondary)' : 'transparent',
                color: active ? 'var(--apple-blue)' : 'var(--text-secondary)',
                boxShadow: active ? '0 1px 3px rgba(0,0,0,0.1)' : 'none',
              }}>
              <Icon size={15} strokeWidth={1.5} /> {t.label}
            </button>
          );
        })}
      </div>

      {/* ── Tab content ──────────────────────────────────────────────────── */}
      <div className="fade-in-up" style={{ animationDelay: '120ms' }}>

        {/* CONSULTAS */}
        {tab === 'consultas' && (
          <div className="rounded-[20px] overflow-hidden" style={card}>
            <div className="px-6 py-4 flex items-center justify-between" style={{ borderBottom: '1px solid var(--separator)' }}>
              <h2 className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>Consultas ({consultas.length})</h2>
              {!isTutor && (
                <button onClick={() => setModalType('consulta')}
                  className="flex items-center gap-1.5 px-3 py-1.5 rounded-[9px] font-medium transition-opacity duration-150"
                  style={{ fontSize: '14px', color: '#fff', background: 'var(--apple-blue)' }}
                  onMouseEnter={e => e.currentTarget.style.opacity = '0.85'}
                  onMouseLeave={e => e.currentTarget.style.opacity = '1'}>
                  <Plus size={15} strokeWidth={2.5} /> Nova consulta
                </button>
              )}
            </div>
            {consultas.length === 0 ? (
              <EmptyState icon={Stethoscope} text="Nenhuma consulta registrada." />
            ) : (
              <div>
                {consultas.map((c, i) => (
                  <div key={c.id} className="px-6 py-4" style={{ borderBottom: i < consultas.length - 1 ? '1px solid var(--separator)' : 'none' }}>
                    <div className="flex items-center justify-between mb-1">
                      <span className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{c.motivo || 'Consulta'}</span>
                      <span className="flex items-center gap-1.5" style={{ fontSize: '13px', color: 'var(--text-tertiary)' }}>
                        <CalendarClock size={13} strokeWidth={1.5} /> {fmt(c.date)}
                      </span>
                    </div>
                    {c.diagnostico && <div style={{ fontSize: '14px', color: 'var(--text-secondary)' }}><strong style={{ fontWeight: 600 }}>Diagnóstico:</strong> {c.diagnostico}</div>}
                    {c.observacoes && <div className="mt-0.5" style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>{c.observacoes}</div>}
                    {c.veterinarianName && <div className="mt-1" style={{ fontSize: '12px', color: 'var(--text-tertiary)' }}>{c.veterinarianName}</div>}
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* PESO */}
        {tab === 'peso' && (
          <div className="flex flex-col gap-5">
            <div className="rounded-[20px] p-6" style={card}>
              <div className="flex items-center justify-between mb-2">
                <h2 className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>Evolução do peso</h2>
                {!isTutor && (
                  <button onClick={() => setModalType('peso')}
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-[9px] font-medium transition-opacity duration-150"
                    style={{ fontSize: '14px', color: '#fff', background: 'var(--apple-blue)' }}
                    onMouseEnter={e => e.currentTarget.style.opacity = '0.85'}
                    onMouseLeave={e => e.currentTarget.style.opacity = '1'}>
                    <Plus size={15} strokeWidth={2.5} /> Registrar peso
                  </button>
                )}
              </div>
              <WeightChart pesos={pesos} />
            </div>

            {pesos.length > 0 && (
              <div className="rounded-[20px] overflow-hidden" style={card}>
                <div className="px-6 py-4" style={{ borderBottom: '1px solid var(--separator)' }}>
                  <h2 className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>Histórico ({pesos.length})</h2>
                </div>
                {[...pesos].reverse().map((p, i, arr) => (
                  <div key={p.id} className="px-6 py-3 flex items-center justify-between" style={{ borderBottom: i < arr.length - 1 ? '1px solid var(--separator)' : 'none' }}>
                    <div className="flex items-center gap-2">
                      <span className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{p.weight} kg</span>
                      {p.notes && <span style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>· {p.notes}</span>}
                    </div>
                    <span style={{ fontSize: '13px', color: 'var(--text-tertiary)' }}>{fmt(p.date)}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* VACINAS (read-only) */}
        {tab === 'vacinas' && (
          <div className="rounded-[20px] overflow-hidden" style={card}>
            <div className="px-6 py-4 flex items-center justify-between" style={{ borderBottom: '1px solid var(--separator)' }}>
              <h2 className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>Vacinas ({vaccines.length})</h2>
              <button onClick={() => navigate(isTutor ? '/minhas-vacinas' : '/vacinas')} className="font-medium" style={{ fontSize: '13px', color: 'var(--apple-blue)' }}>
                {isTutor ? 'Ver todas →' : 'Gerenciar em Vacinas →'}
              </button>
            </div>
            {vaccines.length === 0 ? (
              <EmptyState icon={Syringe} text="Nenhuma vacina registrada." />
            ) : (
              vaccines.map((v, i) => {
                const s = VAC_STATUS[v.status] || { label: v.status || '—', color: 'var(--apple-gray-1)', bg: 'rgba(142,142,147,0.1)' };
                return (
                  <div key={v.id} className="px-6 py-4 flex items-center justify-between" style={{ borderBottom: i < vaccines.length - 1 ? '1px solid var(--separator)' : 'none' }}>
                    <div>
                      <div className="font-medium" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{v.name}</div>
                      <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                        Aplicada: {fmt(v.administrationDate)} · Próxima: {fmt(v.nextDueDate)}
                      </div>
                    </div>
                    <Badge label={s.label} color={s.color} bg={s.bg} icon={s.icon} />
                  </div>
                );
              })
            )}
          </div>
        )}

        {/* VERMIFUGAÇÕES (read-only) */}
        {tab === 'vermifugacoes' && (
          <div className="rounded-[20px] overflow-hidden" style={card}>
            <div className="px-6 py-4" style={{ borderBottom: '1px solid var(--separator)' }}>
              <h2 className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>Vermifugações ({dewormings.length})</h2>
            </div>
            {dewormings.length === 0 ? (
              <EmptyState icon={Bug} text="Nenhuma vermifugação registrada." />
            ) : (
              dewormings.map((d, i) => {
                const s = DEW_STATUS[d.status] || { label: d.status || '—', color: 'var(--apple-gray-1)', bg: 'rgba(142,142,147,0.1)' };
                return (
                  <div key={d.id} className="px-6 py-4 flex items-center justify-between" style={{ borderBottom: i < dewormings.length - 1 ? '1px solid var(--separator)' : 'none' }}>
                    <div>
                      <div className="font-medium" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{d.name}</div>
                      <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                        Aplicado: {fmt(d.administrationDate)} · Próximo: {fmt(d.nextDueDate)}{d.dosage ? ` · ${d.dosage}` : ''}
                      </div>
                    </div>
                    <Badge label={s.label} color={s.color} bg={s.bg} />
                  </div>
                );
              })
            )}
          </div>
        )}
      </div>

      {/* ── Add record modal ─────────────────────────────────────────────── */}
      <RecordFormModal
        isOpen={modalType !== null}
        type={modalType}
        onClose={() => setModalType(null)}
        onSubmit={modalType === 'peso' ? addPeso : addConsulta}
      />
    </div>
  );
};

export default PetRecord;
