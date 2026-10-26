import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { Search, PawPrint, ChevronRight, Plus } from 'lucide-react';
import { useTutorPets } from '../../../hooks/useTutorPets';
import NewPetModal from './NewPetModal';
import { toDate } from '../../../utils/dates';

const getAge = (birthDate) => {
  const birth = toDate(birthDate);
  if (!birth) return '—';
  const months = (new Date().getFullYear() - birth.getFullYear()) * 12 + (new Date().getMonth() - birth.getMonth());
  if (months < 12) return `${months} ${months === 1 ? 'mês' : 'meses'}`;
  const years = Math.floor(months / 12);
  return `${years} ${years === 1 ? 'ano' : 'anos'}`;
};

const TutorPets = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { pets, loading, error, createPet } = useTutorPets();
  const [searchTerm, setSearchTerm] = useState('');
  // O atalho do Início chega com { openNewPet: true } para abrir o cadastro direto.
  const [newPetOpen, setNewPetOpen] = useState(Boolean(location.state?.openNewPet));

  // Consome o pedido: sem isso, recarregar a página reabriria o cadastro.
  useEffect(() => {
    if (location.state?.openNewPet) navigate(location.pathname, { replace: true, state: null });
  }, [location, navigate]);

  const filtered = pets.filter(p => {
    if (!searchTerm) return true;
    const q = searchTerm.toLowerCase();
    return p.name?.toLowerCase().includes(q) || p.species?.toLowerCase().includes(q) || p.breed?.toLowerCase().includes(q);
  });

  return (
    <div className="min-h-full font-sf">
      <div className="mb-6 fade-in-up flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="font-bold" style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
            Meus Pets
          </h1>
          <p className="mt-1" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
            {pets.length} pet{pets.length !== 1 ? 's' : ''} cadastrado{pets.length !== 1 ? 's' : ''} na sua conta
          </p>
        </div>
        {pets.length > 0 && (
          <button onClick={() => setNewPetOpen(true)}
            className="flex items-center gap-1.5 px-4 py-2.5 rounded-[10px] font-medium transition-opacity duration-150 hover:opacity-90"
            style={{ fontSize: '15px', color: '#fff', background: 'var(--apple-blue)' }}>
            <Plus size={16} strokeWidth={2.5} /> Cadastrar pet
          </button>
        )}
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-64">
          <div className="w-8 h-8 rounded-full border-2 border-transparent animate-spin" style={{ borderTopColor: 'var(--apple-blue)' }} />
        </div>
      ) : error ? (
        <div className="flex items-center justify-center h-64">
          <p style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>Erro ao carregar seus pets.</p>
        </div>
      ) : (
        <>
          {pets.length > 0 && (
            <div className="fade-in-up flex items-center gap-2 mb-4 px-3 py-2 rounded-[12px] max-w-md"
              style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '60ms' }}>
              <Search size={14} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)', flexShrink: 0 }} />
              <input type="text" placeholder="Buscar pet..." className="bg-transparent border-none outline-none flex-1"
                style={{ fontSize: '15px', color: 'var(--text-primary)' }} value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
            </div>
          )}

          {pets.length === 0 ? (
            <div className="fade-in-up rounded-[20px] flex flex-col items-center justify-center py-20 gap-3"
              style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}>
              <div className="w-16 h-16 rounded-full flex items-center justify-center" style={{ background: 'rgba(0,122,255,0.1)' }}>
                <PawPrint size={28} strokeWidth={1.5} style={{ color: 'var(--apple-blue)' }} />
              </div>
              <p className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>Nenhum pet ainda</p>
              <p className="text-center px-6" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>Cadastre seu pet para guardar a carteira de vacinação e o histórico de saúde dele.</p>
              <button onClick={() => setNewPetOpen(true)}
                className="mt-2 flex items-center gap-1.5 px-4 py-2.5 rounded-[10px] font-medium transition-opacity duration-150 hover:opacity-90"
                style={{ fontSize: '15px', color: '#fff', background: 'var(--apple-blue)' }}>
                <Plus size={16} strokeWidth={2.5} /> Cadastrar pet
              </button>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {filtered.map((pet, i) => (
                <button key={pet.id} onClick={() => navigate(`/meus-pets/${pet.id}`)}
                  className="fade-in-up rounded-[18px] p-5 text-left transition-transform duration-150 hover:scale-[1.01]"
                  style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: `${80 + i * 40}ms` }}>
                  <div className="flex items-center justify-between">
                    <div className="w-12 h-12 rounded-[14px] flex items-center justify-center font-bold text-[18px]"
                      style={{ background: 'rgba(0,122,255,0.1)', color: 'var(--apple-blue)' }}>
                      {pet.name?.[0]?.toUpperCase() || '?'}
                    </div>
                    <ChevronRight size={18} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)' }} />
                  </div>
                  <div className="mt-3">
                    <div className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>{pet.name}</div>
                    <div style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>
                      {pet.species}{pet.breed ? ` · ${pet.breed}` : ''} · {getAge(pet.birthDate)}
                    </div>
                  </div>
                </button>
              ))}
            </div>
          )}
        </>
      )}

      <NewPetModal
        isOpen={newPetOpen}
        onClose={() => setNewPetOpen(false)}
        onCreate={createPet}
        onCreated={(id) => navigate(`/meus-pets/${id}`)}
      />
    </div>
  );
};

export default TutorPets;
