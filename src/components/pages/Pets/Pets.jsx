import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Filter, Heart, CheckCircle, XCircle, Syringe, CalendarClock } from 'lucide-react';
import { usePets } from '../../../hooks/usePets';
import { usePatientStats } from '../../../hooks/usePatientStats';

// ── Status config ──────────────────────────────────────────────────────────
const STATUS_CFG = {
  active:   { label: 'Ativo',   bg: 'rgba(52,199,89,0.12)',   text: 'var(--apple-green)', dot: 'var(--apple-green)' },
  inactive: { label: 'Inativo', bg: 'rgba(142,142,147,0.12)', text: 'var(--apple-gray-1)', dot: 'var(--apple-gray-1)' },
};

const StatusBadge = ({ status }) => {
  const cfg = STATUS_CFG[status] || { label: status || 'Desconhecido', bg: 'rgba(142,142,147,0.12)', text: 'var(--apple-gray-1)', dot: 'var(--apple-gray-1)' };
  return (
    <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[12px] font-medium" style={{ background: cfg.bg, color: cfg.text }}>
      <span className="w-1.5 h-1.5 rounded-full flex-shrink-0" style={{ background: cfg.dot }} />
      {cfg.label}
    </span>
  );
};

// ── Helper functions ───────────────────────────────────────────────────────
const getNextVaccineDate = (pet) => {
  if (!pet.vaccines || pet.vaccines.length === 0) return null;
  const upcoming = pet.vaccines
    .filter(v => v.nextDate && new Date(v.nextDate) > new Date())
    .sort((a, b) => new Date(a.nextDate) - new Date(b.nextDate));
  if (upcoming.length === 0) return null;
  const d = upcoming[0];
  return `${d.name}: ${new Date(d.nextDate).toLocaleDateString('pt-BR')}`;
};

const getPetAge = (birthDate) => {
  if (!birthDate) return '—';
  const birth = birthDate?.toDate instanceof Function ? birthDate.toDate() : new Date(birthDate);
  const ageInMonths = (new Date().getFullYear() - birth.getFullYear()) * 12 + (new Date().getMonth() - birth.getMonth());
  if (ageInMonths < 12) return `${ageInMonths} ${ageInMonths === 1 ? 'mês' : 'meses'}`;
  const years = Math.floor(ageInMonths / 12);
  return `${years} ${years === 1 ? 'ano' : 'anos'}`;
};

// ── KPI stat card ──────────────────────────────────────────────────────────
const KpiCard = ({ label, value, subtext, accentColor, icon: Icon, delay }) => (
  <div
    className="fade-in-up rounded-[16px] p-5 flex flex-col gap-3"
    style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: `${delay}ms` }}
  >
    <div className="flex items-center justify-between">
      <div className="w-9 h-9 rounded-[10px] flex items-center justify-center" style={{ background: `${accentColor}18` }}>
        <Icon size={18} strokeWidth={1.5} style={{ color: accentColor }} />
      </div>
    </div>
    <div>
      <div className="text-[30px] font-bold leading-none" style={{ color: accentColor, letterSpacing: '-0.02em' }}>{value}</div>
      <div className="text-[14px] font-medium mt-1" style={{ color: 'var(--text-primary)' }}>{label}</div>
      <div className="text-[12px] mt-0.5" style={{ color: 'var(--text-secondary)' }}>{subtext}</div>
    </div>
  </div>
);

// ── Page ──────────────────────────────────────────────────────────────────
const PetsPage = () => {
  const navigate = useNavigate();
  const [filterStatus, setFilterStatus] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');

  const { pets, loading, error } = usePets();
  const { stats } = usePatientStats();

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 rounded-full border-2 border-transparent border-t-[--apple-blue] animate-spin"
          style={{ borderTopColor: 'var(--apple-blue)' }} />
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center h-64 gap-3">
        <XCircle size={32} strokeWidth={1.5} style={{ color: 'var(--apple-red)' }} />
        <p style={{ color: 'var(--text-secondary)', fontSize: '15px' }}>Erro ao carregar pets: {error.message}</p>
      </div>
    );
  }

  const petsArray = Array.isArray(pets) ? pets : [];
  const activeCount = petsArray.filter(p => p.status === 'active').length;
  const filteredPets = petsArray
    .filter(p => filterStatus === 'all' || p.status === filterStatus)
    .filter(p => {
      if (!searchTerm) return true;
      const q = searchTerm.toLowerCase();
      return p.name?.toLowerCase().includes(q) || p.species?.toLowerCase().includes(q) ||
        p.ownerName?.toLowerCase().includes(q) || p.owner?.toLowerCase().includes(q);
    });

  return (
    <div className="min-h-full font-sf">

      {/* ── Page header ─────────────────────────────────────────────────── */}
      <div className="mb-6 fade-in-up">
        <h1 className="font-bold" style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
          Meus Pacientes
        </h1>
        <p className="mt-1" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
          {petsArray.length} pet{petsArray.length !== 1 ? 's' : ''} sob seus cuidados
        </p>
      </div>

      {/* ── KPI cards ────────────────────────────────────────────────────── */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <KpiCard label="Total de Pacientes" value={petsArray.length}
          subtext="sob seus cuidados" accentColor="var(--apple-blue)" icon={Heart} delay={50} />
        <KpiCard label="Pacientes Ativos" value={activeCount}
          subtext="em acompanhamento" accentColor="var(--apple-green)" icon={CheckCircle} delay={100} />
        <KpiCard label="Vacinas Próximas" value={stats.upcomingVaccines}
          subtext="próximos 30 dias" accentColor="var(--apple-orange)" icon={Syringe} delay={150} />
        <KpiCard label="Consultas Recentes" value={stats.recentConsultations}
          subtext="últimos 30 dias" accentColor="var(--apple-indigo)" icon={CalendarClock} delay={200} />
      </div>

      {/* ── Search + filter bar ───────────────────────────────────────────── */}
      <div
        className="fade-in-up flex flex-wrap items-center gap-3 mb-4 p-4 rounded-[16px]"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '250ms' }}
      >
        {/* Search */}
        <div className="flex items-center gap-2 flex-1 min-w-[180px] px-3 py-2 rounded-[10px]"
          style={{ background: 'var(--surface-secondary)' }}>
          <Search size={14} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)', flexShrink: 0 }} />
          <input
            type="text"
            placeholder="Buscar por nome, espécie ou tutor..."
            className="bg-transparent border-none outline-none flex-1"
            style={{ fontSize: '15px', color: 'var(--text-primary)' }}
            value={searchTerm}
            onChange={e => setSearchTerm(e.target.value)}
          />
        </div>

        {/* Filter */}
        <div className="flex items-center gap-2 px-3 py-2 rounded-[10px]"
          style={{ background: 'var(--surface-secondary)' }}>
          <Filter size={14} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)' }} />
          <select
            className="bg-transparent border-none outline-none"
            style={{ fontSize: '15px', color: 'var(--text-primary)' }}
            value={filterStatus}
            onChange={e => setFilterStatus(e.target.value)}
          >
            <option value="all">Todos os Status</option>
            <option value="active">Ativos</option>
            <option value="inactive">Inativos</option>
          </select>
        </div>

        <span style={{ fontSize: '13px', color: 'var(--text-tertiary)' }}>
          {filteredPets.length} de {petsArray.length}
        </span>
      </div>

      {/* ── Pets table ────────────────────────────────────────────────────── */}
      <div
        className="fade-in-up rounded-[16px] overflow-hidden"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '300ms' }}
      >
        {petsArray.length === 0 ? (
          /* Empty state */
          <div className="flex flex-col items-center justify-center py-20 gap-3">
            <div className="w-16 h-16 rounded-full flex items-center justify-center" style={{ background: 'rgba(0,122,255,0.1)' }}>
              <Heart size={28} strokeWidth={1.5} style={{ color: 'var(--apple-blue)' }} />
            </div>
            <p className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>Nenhum paciente ainda</p>
            <p style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>Os pets cadastrados aparecerão aqui.</p>
          </div>
        ) : filteredPets.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 gap-2">
            <p className="font-medium" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>Nenhum resultado</p>
            <p style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>Tente outros filtros ou termos de busca.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full border-collapse">
              <thead>
                <tr style={{ background: 'rgba(116,116,128,0.06)', borderBottom: '1px solid var(--separator)' }}>
                  {['Pet', 'Tutor', 'Status', 'Próxima Vacina', 'Ações'].map(h => (
                    <th key={h} className="text-left font-semibold uppercase"
                      style={{ padding: '10px 20px', fontSize: '11px', letterSpacing: '0.06em', color: 'var(--text-secondary)', border: 'none', background: 'transparent' }}>
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filteredPets.map((pet, i) => {
                  const isLast = i === filteredPets.length - 1;
                  const nextVaccine = getNextVaccineDate(pet);
                  return (
                    <tr
                      key={pet.id}
                      className="fade-in-up transition-colors duration-100 cursor-pointer"
                      style={{ borderBottom: isLast ? 'none' : '1px solid var(--separator)', animationDelay: `${300 + i * 30}ms` }}
                      onClick={() => navigate(`/pets/${pet.id}`)}
                      onMouseEnter={e => e.currentTarget.style.background = 'rgba(116,116,128,0.04)'}
                      onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
                    >
                      <td style={{ padding: '14px 20px', border: 'none' }}>
                        <div className="flex items-center gap-3">
                          <div className="w-9 h-9 rounded-[10px] flex items-center justify-center font-semibold text-[13px] flex-shrink-0"
                            style={{ background: 'rgba(0,122,255,0.1)', color: 'var(--apple-blue)' }}>
                            {pet.name?.[0]?.toUpperCase() || '?'}
                          </div>
                          <div>
                            <div className="font-medium" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{pet.name}</div>
                            <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>{pet.species}{pet.breed ? ` · ${pet.breed}` : ''} · {getPetAge(pet.birthDate)}</div>
                          </div>
                        </div>
                      </td>
                      <td style={{ padding: '14px 20px', border: 'none', fontSize: '15px', color: 'var(--text-primary)' }}>
                        {pet.ownerName || pet.owner || '—'}
                      </td>
                      <td style={{ padding: '14px 20px', border: 'none' }}>
                        <StatusBadge status={pet.status} />
                      </td>
                      <td style={{ padding: '14px 20px', border: 'none', fontSize: '13px', color: 'var(--text-secondary)' }}>
                        {nextVaccine ? (
                          <div className="flex items-center gap-1.5">
                            <Syringe size={13} strokeWidth={1.5} style={{ color: 'var(--apple-orange)', flexShrink: 0 }} />
                            {nextVaccine}
                          </div>
                        ) : (
                          <span style={{ color: 'var(--text-tertiary)' }}>Em dia</span>
                        )}
                      </td>
                      <td style={{ padding: '14px 20px', border: 'none' }}>
                        <button
                          onClick={(e) => { e.stopPropagation(); navigate(`/pets/${pet.id}`); }}
                          className="font-medium transition-colors duration-100"
                          style={{ fontSize: '15px', color: 'var(--apple-blue)' }}
                          onMouseEnter={e => e.currentTarget.style.opacity = '0.7'}
                          onMouseLeave={e => e.currentTarget.style.opacity = '1'}
                        >
                          Ver prontuário
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};

export default PetsPage;
