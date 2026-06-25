import React from 'react';
import { useNavigate } from 'react-router-dom';
import { PawPrint, Syringe, ClipboardCheck, ChevronRight } from 'lucide-react';
import { useTutorPets } from '../../../hooks/useTutorPets';
import { useTutorVaccines } from '../../../hooks/useTutorVaccines';
import { useAuth } from '../../../context/AuthContext';
import { toDate } from '../../../utils/dates';

const DAY = 24 * 60 * 60 * 1000;

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

const TutorHome = () => {
  const navigate = useNavigate();
  const { userProfile } = useAuth();
  const { pets, loading } = useTutorPets();
  const { vaccines } = useTutorVaccines();

  const now = new Date();
  const in30 = new Date(now.getTime() + 30 * DAY);
  const upcomingVaccines = vaccines.filter(v => {
    const d = toDate(v.nextDueDate);
    return d && d >= now && d <= in30;
  }).length;
  const pendingApprovals = vaccines.filter(v => !v.tutorAcknowledged).length;

  const hour = now.getHours();
  const greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';
  const firstName = userProfile?.name?.split(' ')[0];

  return (
    <div className="min-h-full font-sf">
      <div className="mb-6 fade-in-up">
        <h1 className="font-bold" style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
          {greeting}{firstName ? `, ${firstName}` : ''} 👋
        </h1>
        <p className="mt-1" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
          Acompanhe a saúde dos seus pets.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <KpiCard label="Meus pets" value={pets.length} accentColor="var(--apple-blue)" icon={PawPrint} delay={50} />
        <KpiCard label="Vacinas próximas (30d)" value={upcomingVaccines} accentColor="var(--apple-orange)" icon={Syringe} delay={100} />
        <KpiCard label="Aguardando sua ciência" value={pendingApprovals} accentColor="var(--apple-indigo)" icon={ClipboardCheck} delay={150} />
      </div>

      {/* Pets list */}
      <div className="fade-in-up rounded-[20px] overflow-hidden" style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '200ms' }}>
        <div className="px-6 py-4 flex items-center justify-between" style={{ borderBottom: '1px solid var(--separator)' }}>
          <h2 className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>Meus pets</h2>
          <button onClick={() => navigate('/meus-pets')} className="font-medium" style={{ fontSize: '13px', color: 'var(--apple-blue)' }}>
            Ver todos →
          </button>
        </div>
        {loading ? (
          <div className="flex items-center justify-center py-12">
            <div className="w-6 h-6 rounded-full border-2 border-transparent animate-spin" style={{ borderTopColor: 'var(--apple-blue)' }} />
          </div>
        ) : pets.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-12 gap-2">
            <PawPrint size={26} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)' }} />
            <p style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>Nenhum pet vinculado à sua conta ainda.</p>
          </div>
        ) : (
          pets.map((pet, i) => (
            <button key={pet.id} onClick={() => navigate(`/meus-pets/${pet.id}`)}
              className="w-full px-6 py-4 flex items-center justify-between transition-colors duration-100"
              style={{ borderBottom: i < pets.length - 1 ? '1px solid var(--separator)' : 'none' }}
              onMouseEnter={e => e.currentTarget.style.background = 'rgba(116,116,128,0.04)'}
              onMouseLeave={e => e.currentTarget.style.background = 'transparent'}>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-[12px] flex items-center justify-center font-semibold text-[15px] flex-shrink-0"
                  style={{ background: 'rgba(0,122,255,0.1)', color: 'var(--apple-blue)' }}>
                  {pet.name?.[0]?.toUpperCase() || '?'}
                </div>
                <div className="text-left">
                  <div className="font-medium" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{pet.name}</div>
                  <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>{pet.species}{pet.breed ? ` · ${pet.breed}` : ''}</div>
                </div>
              </div>
              <ChevronRight size={18} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)' }} />
            </button>
          ))
        )}
      </div>
    </div>
  );
};

export default TutorHome;
