import React, { useState } from 'react';
import { CalendarClock, Syringe, Bug, AlertTriangle, Clock } from 'lucide-react';
import { useVencimentos } from '../../../hooks/useVencimentos';
import { toDate } from '../../../utils/dates';

const DAY = 24 * 60 * 60 * 1000;
const fmt = (v) => { const d = toDate(v); return d ? d.toLocaleDateString('pt-BR') : '—'; };
const daysUntil = (v) => {
  const d = toDate(v);
  if (!d) return null;
  return Math.round((d.setHours(0, 0, 0, 0) - new Date().setHours(0, 0, 0, 0)) / DAY);
};

// Filtros (cumulativos para os próximos N dias; "vencidos" = atrasados).
const FILTERS = [
  { key: 'vencidos', label: 'Vencidos' },
  { key: '30', label: 'Próx. 30 dias' },
  { key: '60', label: 'Próx. 60 dias' },
  { key: '90', label: 'Próx. 90 dias' },
];

const matchesFilter = (du, key) => {
  if (du === null) return false;
  if (key === 'vencidos') return du < 0;
  return du >= 0 && du <= Number(key);
};

const KpiCard = ({ label, value, accentColor, icon: Icon, active, onClick, delay }) => (
  <button
    onClick={onClick}
    className="fade-in-up rounded-[16px] p-5 flex items-center justify-between text-left transition-all duration-150"
    style={{
      background: 'var(--surface-grouped-secondary)',
      boxShadow: active ? `0 0 0 2px ${accentColor}` : '0 1px 3px rgba(0,0,0,0.06)',
      animationDelay: `${delay}ms`,
    }}
  >
    <div>
      <div className="text-[28px] font-bold leading-none" style={{ color: accentColor, letterSpacing: '-0.02em' }}>{value}</div>
      <div className="text-[13px] mt-1" style={{ color: 'var(--text-secondary)' }}>{label}</div>
    </div>
    <div className="w-10 h-10 rounded-[12px] flex items-center justify-center flex-shrink-0" style={{ background: `${accentColor}18` }}>
      <Icon size={20} strokeWidth={1.5} style={{ color: accentColor }} />
    </div>
  </button>
);

const TypeBadge = ({ tipo }) => {
  const isVac = tipo === 'vacina';
  const Icon = isVac ? Syringe : Bug;
  const color = isVac ? 'var(--apple-blue)' : 'var(--apple-teal)';
  return (
    <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[12px] font-medium"
      style={{ background: `${color}1A`, color }}>
      <Icon size={11} strokeWidth={2} /> {isVac ? 'Vacina' : 'Vermífugo'}
    </span>
  );
};

const DueChip = ({ du }) => {
  if (du === null) return <span style={{ fontSize: '13px', color: 'var(--text-tertiary)' }}>—</span>;
  const overdue = du < 0;
  const color = overdue ? 'var(--apple-red)' : du <= 30 ? 'var(--apple-orange)' : 'var(--apple-green)';
  const bg = overdue ? 'rgba(255,59,48,0.10)' : du <= 30 ? 'rgba(255,149,0,0.12)' : 'rgba(52,199,89,0.12)';
  const label = overdue ? `Vencido há ${Math.abs(du)}d` : du === 0 ? 'Vence hoje' : `Em ${du}d`;
  return (
    <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[12px] font-medium" style={{ background: bg, color }}>
      {overdue ? <AlertTriangle size={11} strokeWidth={2} /> : <Clock size={11} strokeWidth={2} />} {label}
    </span>
  );
};

const VencimentosPage = () => {
  const { items, loading, error } = useVencimentos();
  const [filter, setFilter] = useState('30');

  const counts = {
    vencidos: items.filter(i => matchesFilter(daysUntil(i.nextDueDate), 'vencidos')).length,
    30: items.filter(i => matchesFilter(daysUntil(i.nextDueDate), '30')).length,
    60: items.filter(i => matchesFilter(daysUntil(i.nextDueDate), '60')).length,
    90: items.filter(i => matchesFilter(daysUntil(i.nextDueDate), '90')).length,
  };
  const filtered = items.filter(i => matchesFilter(daysUntil(i.nextDueDate), filter));

  return (
    <div className="min-h-full font-sf">
      <div className="mb-6 fade-in-up">
        <h1 className="font-bold" style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
          Vencimentos
        </h1>
        <p className="mt-1" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
          Vacinas e vermífugos com dose vencida ou a vencer.
        </p>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-64">
          <div className="w-8 h-8 rounded-full border-2 border-transparent animate-spin" style={{ borderTopColor: 'var(--apple-blue)' }} />
        </div>
      ) : error ? (
        <div className="flex flex-col items-center justify-center h-64 gap-2">
          <p style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>Erro ao carregar vencimentos.</p>
          <p style={{ fontSize: '13px', color: 'var(--text-tertiary)' }}>
            Verifique se o índice composto (veterinarianId + nextDueDate) foi publicado.
          </p>
        </div>
      ) : (
        <>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
            <KpiCard label="Vencidos" value={counts.vencidos} accentColor="var(--apple-red)" icon={AlertTriangle}
              active={filter === 'vencidos'} onClick={() => setFilter('vencidos')} delay={50} />
            <KpiCard label="Próximos 30 dias" value={counts['30']} accentColor="var(--apple-orange)" icon={Clock}
              active={filter === '30'} onClick={() => setFilter('30')} delay={100} />
            <KpiCard label="Próximos 60 dias" value={counts['60']} accentColor="var(--apple-blue)" icon={CalendarClock}
              active={filter === '60'} onClick={() => setFilter('60')} delay={150} />
            <KpiCard label="Próximos 90 dias" value={counts['90']} accentColor="var(--apple-green)" icon={CalendarClock}
              active={filter === '90'} onClick={() => setFilter('90')} delay={200} />
          </div>

          <div className="fade-in-up rounded-[16px] overflow-hidden"
            style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '250ms' }}>
            <div className="px-6 py-3 flex items-center gap-2" style={{ borderBottom: '1px solid var(--separator)' }}>
              {FILTERS.map(f => (
                <button key={f.key} onClick={() => setFilter(f.key)}
                  className="px-3 py-1.5 rounded-[9px] font-medium transition-colors duration-150"
                  style={{
                    fontSize: '13px',
                    background: filter === f.key ? 'var(--apple-blue)' : 'var(--surface-secondary)',
                    color: filter === f.key ? '#fff' : 'var(--text-secondary)',
                  }}>
                  {f.label}
                </button>
              ))}
            </div>

            {filtered.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-16 gap-2">
                <CalendarClock size={26} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)' }} />
                <p style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>Nada neste período.</p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full border-collapse">
                  <thead>
                    <tr style={{ background: 'rgba(116,116,128,0.06)', borderBottom: '1px solid var(--separator)' }}>
                      {['Pet · Tutor', 'Tipo', 'Nome', 'Próxima dose', 'Situação'].map(h => (
                        <th key={h} className="text-left font-semibold uppercase"
                          style={{ padding: '10px 20px', fontSize: '11px', letterSpacing: '0.06em', color: 'var(--text-secondary)', border: 'none' }}>
                          {h}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {filtered.map((it, i) => {
                      const du = daysUntil(it.nextDueDate);
                      const isLast = i === filtered.length - 1;
                      return (
                        <tr key={`${it.tipo}_${it.id}`} className="fade-in-up transition-colors duration-100"
                          style={{ borderBottom: isLast ? 'none' : '1px solid var(--separator)', animationDelay: `${250 + i * 20}ms` }}
                          onMouseEnter={e => e.currentTarget.style.background = 'rgba(116,116,128,0.04)'}
                          onMouseLeave={e => e.currentTarget.style.background = 'transparent'}>
                          <td style={{ padding: '14px 20px', border: 'none' }}>
                            <div className="font-medium" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{it.petName || '—'}</div>
                            <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>{it.ownerName || '—'}</div>
                          </td>
                          <td style={{ padding: '14px 20px', border: 'none' }}><TypeBadge tipo={it.tipo} /></td>
                          <td style={{ padding: '14px 20px', border: 'none', fontSize: '14px', color: 'var(--text-secondary)' }}>{it.name || '—'}</td>
                          <td style={{ padding: '14px 20px', border: 'none', fontSize: '14px', color: 'var(--text-primary)' }}>{fmt(it.nextDueDate)}</td>
                          <td style={{ padding: '14px 20px', border: 'none' }}><DueChip du={du} /></td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
};

export default VencimentosPage;
