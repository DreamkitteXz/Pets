import React, { useState } from 'react';
import { BarChart, Bar, ResponsiveContainer, Cell } from 'recharts';
import { useDashboard } from '../../../hooks/useDashboard';
import { useAuth } from '../../../context/AuthContext';
import { formatDate } from '../../../utils/formatters';
import LoadingScreen from '../../ui/LoadingScreen';
import { Heart, Calendar, Syringe, ShieldAlert, Clock } from 'lucide-react';

// ── Status badges — opacity-based colors work in light & dark mode ─────────
const STATUS = {
  healthy:    { label: 'Saudável',      bgColor: 'rgba(52,199,89,0.14)',  textColor: 'var(--apple-green)', dotColor: 'var(--apple-green)' },
  recovering: { label: 'Recuperação',   bgColor: 'rgba(255,149,0,0.14)',  textColor: 'var(--apple-orange)', dotColor: 'var(--apple-orange)' },
  treatment:  { label: 'Em Tratamento', bgColor: 'rgba(10,132,255,0.14)', textColor: 'var(--apple-blue)',   dotColor: 'var(--apple-blue)' },
  critical:   { label: 'Crítico',       bgColor: 'rgba(255,59,48,0.14)',  textColor: 'var(--apple-red)',    dotColor: 'var(--apple-red)' },
};

const StatusBadge = ({ status }) => {
  const s = STATUS[status] || {
    label: status || '—',
    bgColor: 'rgba(142,142,147,0.14)',
    textColor: 'var(--text-secondary)',
    dotColor: 'var(--apple-gray-2)',
  };
  return (
    <span
      className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium"
      style={{ background: s.bgColor, color: s.textColor }}
    >
      <span className="w-1.5 h-1.5 rounded-full flex-shrink-0" style={{ background: s.dotColor }} />
      {s.label}
    </span>
  );
};

// ── Dashboard ──────────────────────────────────────────────────────────────
const Dashboard = () => {
  const { dashboardData, loading, error } = useDashboard();
  const { userProfile } = useAuth();
  const [showDevToast, setShowDevToast] = useState(false);

  if (loading) return <LoadingScreen />;
  if (error) return (
    <div className="flex items-center justify-center h-64">
      <p style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>Erro ao carregar dados do dashboard.</p>
    </div>
  );
  if (!dashboardData) return null;

  const hour = new Date().getHours();
  const greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';
  const firstName = userProfile?.name?.split(' ')[0];

  const todayLabel = new Intl.DateTimeFormat('pt-BR', {
    weekday: 'long', day: 'numeric', month: 'long',
  }).format(new Date());

  const hasOverdue = dashboardData.overdueDewormings > 0;
  const todayIdx = new Date().getDay();

  // Shared card style — uses surface token so it adapts to dark mode
  const cardStyle = {
    background: 'var(--surface-grouped-secondary)',
    boxShadow: '0 1px 4px rgba(0,0,0,0.08)',
  };

  return (
    <div className="min-h-full font-sf">

      {/* Dev toast */}
      {showDevToast && (
        <div
          className="fixed bottom-6 right-6 z-50 text-sm px-4 py-2.5 rounded-[12px] fade-in-up"
          style={{ background: 'var(--surface-elevated)', color: 'var(--text-primary)', boxShadow: '0 8px 24px rgba(0,0,0,0.2), 0 0 0 1px var(--separator)' }}
        >
          🚧 Sistema de consultas em desenvolvimento
        </div>
      )}

      {/* ── Page header ─────────────────────────────────────────────────── */}
      <div className="mb-7 fade-in-up">
        <p
          className="text-[11px] font-semibold uppercase tracking-[0.1em] mb-1 capitalize"
          style={{ color: 'var(--text-tertiary)' }}
        >
          {todayLabel}
        </p>
        <h1
          className="text-[26px] font-semibold leading-tight"
          style={{ color: 'var(--text-primary)', letterSpacing: '-0.02em' }}
        >
          {greeting}{firstName ? `, ${firstName}` : ''} 👋
        </h1>
        <p className="text-sm mt-1 leading-relaxed" style={{ color: 'var(--text-secondary)' }}>
          Resumo dos seus pacientes e agenda de hoje.
        </p>
      </div>

      {/* ── Bento grid ──────────────────────────────────────────────────── */}
      <div className="grid grid-cols-12 gap-5">

        {/* ── KPI 1 — Pacientes Totais (dark hero — looks good in both modes) */}
        <div
          className="col-span-12 md:col-span-3 fade-in-up rounded-[20px] overflow-hidden relative p-6 flex flex-col justify-between min-h-[152px]"
          style={{
            animationDelay: '50ms',
            background: 'linear-gradient(135deg, #023047 0%, #033c5c 100%)',
            boxShadow: '0 8px 32px -8px rgba(2,48,71,0.35)',
          }}
        >
          <div className="absolute inset-0 pointer-events-none" style={{ mixBlendMode: 'plus-lighter', opacity: 0.18, background: 'radial-gradient(ellipse 80% 60% at 90% 10%, #3bade6 0%, transparent 70%)' }} />
          <div className="relative z-10 flex items-center justify-between">
            <div className="w-9 h-9 rounded-[10px] bg-white/10 flex items-center justify-center">
              <Heart size={18} strokeWidth={1.5} className="text-white" />
            </div>
            <span className="text-[10px] font-semibold text-white/40 uppercase tracking-[0.1em]">Pacientes</span>
          </div>
          <div className="relative z-10 mt-3">
            <div className="text-[44px] font-bold tracking-[-0.03em] text-white leading-none">{dashboardData.totalPets}</div>
            <div className="text-sm text-white/55 mt-1">pets cadastrados</div>
          </div>
        </div>

        {/* ── KPI 2 — Consultas na Semana (com mini-gráfico) ────────────── */}
        <div
          className="col-span-12 md:col-span-5 fade-in-up rounded-[20px] p-6 flex flex-col justify-between min-h-[152px]"
          style={{ animationDelay: '100ms', ...cardStyle }}
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-[10px] flex items-center justify-center" style={{ background: 'rgba(0,122,255,0.1)' }}>
                <Calendar size={18} strokeWidth={1.5} style={{ color: 'var(--apple-blue)' }} />
              </div>
              <div>
                <div className="text-[28px] font-bold tracking-[-0.03em] leading-none" style={{ color: 'var(--apple-blue)' }}>
                  {dashboardData.weekAppointments}
                </div>
                <div className="text-xs mt-1" style={{ color: 'var(--text-secondary)' }}>consultas nesta semana</div>
              </div>
            </div>
            <span className="text-[10px] font-semibold uppercase tracking-[0.1em]" style={{ color: 'var(--text-tertiary)' }}>Semana</span>
          </div>
          {/* Mini bar chart */}
          <div className="mt-3" style={{ height: '52px' }}>
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={dashboardData.weeklyData} margin={{ top: 4, right: 0, bottom: 0, left: 0 }} barCategoryGap="22%">
                <Bar dataKey="consultas" radius={[3, 3, 0, 0]}>
                  {dashboardData.weeklyData.map((entry, idx) => (
                    <Cell key={idx} fill={idx === todayIdx ? 'var(--apple-blue)' : 'rgba(10,132,255,0.25)'} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
            <div className="flex justify-between mt-1 px-0.5">
              {dashboardData.weeklyData.map((d, idx) => (
                <span key={idx} className="text-[9px] font-medium"
                  style={{ color: idx === todayIdx ? 'var(--apple-blue)' : 'var(--text-tertiary)', flex: 1, textAlign: 'center' }}>
                  {d.day}
                </span>
              ))}
            </div>
          </div>
        </div>

        {/* ── KPI 3 — Vacinas Próximas ──────────────────────────────────── */}
        <div
          className="col-span-6 md:col-span-2 fade-in-up rounded-[20px] p-5 flex flex-col justify-between min-h-[152px] hover:scale-[1.01] transition-all duration-200"
          style={{ animationDelay: '150ms', ...cardStyle }}
        >
          <div className="w-9 h-9 rounded-[10px] flex items-center justify-center" style={{ background: 'rgba(255,149,0,0.12)' }}>
            <Syringe size={18} strokeWidth={1.5} style={{ color: 'var(--apple-orange)' }} />
          </div>
          <div className="mt-3">
            <div className="text-[34px] font-bold tracking-[-0.03em] leading-none" style={{ color: 'var(--apple-orange)' }}>
              {dashboardData.upcomingVaccines}
            </div>
            <div className="text-xs mt-1" style={{ color: 'var(--text-secondary)' }}>vacinas em 30 dias</div>
          </div>
        </div>

        {/* ── KPI 4 — Vermifugações Vencidas ───────────────────────────── */}
        <div
          className="col-span-6 md:col-span-2 fade-in-up rounded-[20px] p-5 flex flex-col justify-between min-h-[152px] hover:scale-[1.01] transition-all duration-200"
          style={{
            animationDelay: '200ms',
            background: hasOverdue ? 'rgba(255,59,48,0.08)' : 'var(--surface-grouped-secondary)',
            boxShadow: hasOverdue ? '0 2px 16px rgba(255,59,48,0.12)' : '0 1px 4px rgba(0,0,0,0.08)',
            border: `1px solid ${hasOverdue ? 'rgba(255,59,48,0.2)' : 'var(--separator)'}`,
          }}
        >
          <div className="w-9 h-9 rounded-[10px] flex items-center justify-center"
            style={{ background: hasOverdue ? 'rgba(255,59,48,0.12)' : 'rgba(142,142,147,0.1)' }}>
            <ShieldAlert size={18} strokeWidth={1.5} style={{ color: hasOverdue ? 'var(--apple-red)' : 'var(--text-tertiary)' }} />
          </div>
          <div className="mt-3">
            <div className="text-[34px] font-bold tracking-[-0.03em] leading-none"
              style={{ color: hasOverdue ? 'var(--apple-red)' : 'var(--text-primary)' }}>
              {dashboardData.overdueDewormings}
            </div>
            <div className="text-xs mt-1" style={{ color: hasOverdue ? 'var(--apple-red)' : 'var(--text-secondary)', opacity: hasOverdue ? 0.85 : 1 }}>
              vermífugos vencidos
            </div>
          </div>
        </div>

        {/* ── Pacientes Recentes ── col-span-12 ───────────────────────── */}
        <div
          className="col-span-12 fade-in-up rounded-[20px] overflow-hidden"
          style={{ animationDelay: '200ms', ...cardStyle }}
        >
          <div className="px-6 py-5 flex items-center justify-between" style={{ borderBottom: '1px solid var(--separator)' }}>
            <div>
              <h2 className="text-[15px] font-semibold tracking-[-0.01em]" style={{ color: 'var(--text-primary)' }}>
                Pacientes Recentes
              </h2>
              <p className="text-xs mt-0.5" style={{ color: 'var(--text-tertiary)' }}>
                {dashboardData.recentPets.length} paciente{dashboardData.recentPets.length !== 1 ? 's' : ''}
              </p>
            </div>
          </div>

          {dashboardData.recentPets.length === 0 ? (
            <div className="px-6 py-14 flex flex-col items-center justify-center gap-2">
              <Heart size={28} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)' }} />
              <p className="text-sm" style={{ color: 'var(--text-secondary)' }}>Nenhum paciente cadastrado ainda.</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full border-collapse">
                <thead>
                  <tr style={{ background: 'var(--surface-secondary)', borderBottom: '1px solid var(--separator)' }}>
                    {['Nome do Pet', 'Espécie', 'Raça', 'Idade', 'Tutor', 'Última Visita', 'Status'].map(h => (
                      <th
                        key={h}
                        className="text-left text-[11px] font-semibold uppercase tracking-[0.07em]"
                        style={{ padding: '10px 24px', border: 'none', background: 'transparent', color: 'var(--text-tertiary)' }}
                      >
                        {h}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {dashboardData.recentPets.map((pet, i) => {
                    const age = pet.birthDate
                      ? Math.floor((Date.now() - new Date(pet.birthDate).getTime()) / (1000 * 60 * 60 * 24 * 365))
                      : null;
                    const isLast = i === dashboardData.recentPets.length - 1;
                    return (
                      <tr
                        key={pet.id}
                        className="fade-in-up"
                        style={{ animationDelay: `${220 + i * 35}ms`, borderBottom: isLast ? 'none' : '1px solid var(--separator)' }}
                        onMouseEnter={e => e.currentTarget.style.background = 'rgba(142,142,147,0.06)'}
                        onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
                      >
                        <td style={{ padding: '12px 24px', border: 'none' }}>
                          <div className="flex items-center gap-2.5">
                            <div className="w-8 h-8 rounded-[10px] flex items-center justify-center flex-shrink-0"
                              style={{ background: 'rgba(0,122,255,0.1)' }}>
                              <span className="text-xs font-semibold" style={{ color: 'var(--apple-blue)' }}>
                                {pet.name?.[0]?.toUpperCase() || '?'}
                              </span>
                            </div>
                            <span className="text-sm font-medium" style={{ color: 'var(--text-primary)' }}>{pet.name}</span>
                          </div>
                        </td>
                        <td style={{ padding: '12px 24px', border: 'none' }}>
                          <span className="text-sm capitalize" style={{ color: 'var(--text-secondary)' }}>{pet.species || '—'}</span>
                        </td>
                        <td style={{ padding: '12px 24px', border: 'none' }}>
                          <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>{pet.breed || '—'}</span>
                        </td>
                        <td style={{ padding: '12px 24px', border: 'none' }}>
                          <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>{age !== null ? `${age} ano${age !== 1 ? 's' : ''}` : '—'}</span>
                        </td>
                        <td style={{ padding: '12px 24px', border: 'none' }}>
                          <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>{pet.ownerName || '—'}</span>
                        </td>
                        <td style={{ padding: '12px 24px', border: 'none' }}>
                          <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>{pet.lastVisit ? formatDate(pet.lastVisit) : '—'}</span>
                        </td>
                        <td style={{ padding: '12px 24px', border: 'none' }}>
                          <StatusBadge status={pet.status} />
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* ── Consultas de Hoje (in development) ── col-span-12 ────────── */}
        {dashboardData.todayAppointments.length > 0 && (
          <div
            className="col-span-12 fade-in-up rounded-[20px] overflow-hidden relative"
            style={{ animationDelay: '260ms', ...cardStyle }}
          >
            {/* Frosted overlay */}
            <div
              className="absolute inset-0 z-10 flex flex-col items-center justify-center gap-2"
              style={{ backdropFilter: 'blur(3px)', background: 'rgba(var(--surface-grouped-secondary-rgb, 255,255,255), 0.75)' }}
            >
              <Clock size={20} strokeWidth={1.5} style={{ color: 'var(--text-secondary)' }} />
              <p className="text-sm font-medium" style={{ color: 'var(--text-secondary)' }}>Consultas de Hoje</p>
              <span
                className="text-xs px-3 py-1 rounded-full"
                style={{ color: 'var(--text-tertiary)', background: 'rgba(255,149,0,0.1)', border: '1px solid rgba(255,149,0,0.2)' }}
              >
                Em desenvolvimento
              </span>
            </div>

            <div className="px-6 py-5" style={{ borderBottom: '1px solid var(--separator)' }}>
              <h2 className="text-[15px] font-semibold tracking-[-0.01em]" style={{ color: 'var(--text-primary)' }}>Consultas de Hoje</h2>
            </div>
            <div>
              {dashboardData.todayAppointments.slice(0, 3).map((apt, i) => (
                <div
                  key={apt.id}
                  className="px-6 py-4 flex items-center justify-between cursor-pointer"
                  style={{ borderBottom: i < 2 ? '1px solid var(--separator)' : 'none' }}
                  onClick={() => { setShowDevToast(true); setTimeout(() => setShowDevToast(false), 3000); }}
                >
                  <div>
                    <p className="text-sm font-medium" style={{ color: 'var(--text-primary)' }}>{apt.petName}</p>
                    <p className="text-xs" style={{ color: 'var(--text-secondary)' }}>{apt.date ? formatDate(apt.date) : '—'}</p>
                  </div>
                  <span className="text-xs px-2.5 py-1 rounded-full font-medium"
                    style={{ background: 'rgba(0,122,255,0.1)', color: 'var(--apple-blue)' }}>
                    {apt.status === 'scheduled' ? 'Agendada' : apt.status === 'completed' ? 'Concluída' : 'Cancelada'}
                  </span>
                </div>
              ))}
            </div>
          </div>
        )}

      </div>
    </div>
  );
};

export default Dashboard;
