import React, { useState } from 'react';
import { Search, Building2, MapPin, Phone, Users, Stethoscope, Heart } from 'lucide-react';
import { useClinics } from '../../../hooks/useClinics';
import { usePets } from '../../../hooks/usePets';
import { useAuth } from '../../../context/AuthContext';

const StatusBadge = ({ status }) => {
  const active = status === 'active';
  return (
    <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[12px] font-medium"
      style={{
        background: active ? 'rgba(52,199,89,0.12)' : 'rgba(142,142,147,0.12)',
        color: active ? 'var(--apple-green)' : 'var(--apple-gray-1)',
      }}>
      <span className="w-1.5 h-1.5 rounded-full flex-shrink-0" style={{ background: active ? 'var(--apple-green)' : 'var(--apple-gray-1)' }} />
      {active ? 'Ativa' : 'Inativa'}
    </span>
  );
};

const KpiCard = ({ label, value, accentColor, icon: Icon, delay }) => (
  <div
    className="fade-in-up rounded-[16px] p-5 flex items-center justify-between"
    style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: `${delay}ms` }}
  >
    <div>
      <div className="text-[28px] font-bold leading-none" style={{ color: accentColor, letterSpacing: '-0.02em' }}>{value}</div>
      <div className="text-[13px] mt-1" style={{ color: 'var(--text-secondary)' }}>{label}</div>
    </div>
    <div className="w-10 h-10 rounded-[12px] flex items-center justify-center flex-shrink-0" style={{ background: `${accentColor}18` }}>
      <Icon size={20} strokeWidth={1.5} style={{ color: accentColor }} />
    </div>
  </div>
);

const formatAddress = (addr) => {
  if (!addr) return '—';
  if (typeof addr === 'string') return addr;
  const parts = [
    addr.street && addr.number ? `${addr.street}, ${addr.number}` : addr.street,
    addr.neighborhood,
    addr.city && addr.state ? `${addr.city}/${addr.state}` : addr.city,
  ].filter(Boolean);
  return parts.join(' · ') || '—';
};

const ClinicasPage = () => {
  const { clinics, loading, error } = useClinics();
  const { pets } = usePets();
  const { user } = useAuth();
  const [searchTerm, setSearchTerm] = useState('');

  const filtered = clinics.filter(c => {
    if (!searchTerm) return true;
    const q = searchTerm.toLowerCase();
    return (
      c.name?.toLowerCase().includes(q) ||
      formatAddress(c.address)?.toLowerCase().includes(q) ||
      c.address?.city?.toLowerCase().includes(q)
    );
  });

  // ── Card metrics ───────────────────────────────────────────────────────────
  const cities = new Set(clinics.map(c => c.address?.city).filter(Boolean)).size;
  const colleagues = new Set(
    clinics.flatMap(c => c.veterinarians || []).filter(id => id !== user?.uid)
  ).size;
  const totalPatients = Array.isArray(pets) ? pets.length : 0;

  return (
    <div className="min-h-full font-sf">

      {/* ── Page header ─────────────────────────────────────────────────── */}
      <div className="mb-6 fade-in-up">
        <h1 className="font-bold" style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
          Clínicas
        </h1>
        <p className="mt-1" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
          Unidades veterinárias às quais você está associado.
        </p>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-64">
          <div className="w-8 h-8 rounded-full border-2 border-transparent animate-spin"
            style={{ borderTopColor: 'var(--apple-blue)' }} />
        </div>
      ) : error ? (
        <div className="flex items-center justify-center h-64">
          <p style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>Erro ao carregar clínicas.</p>
        </div>
      ) : (
        <>
          {/* ── KPI cards ──────────────────────────────────────────────── */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
            <KpiCard label="Clínicas associadas" value={clinics.length} accentColor="var(--apple-blue)" icon={Building2} delay={50} />
            <KpiCard label="Cidades atendidas" value={cities} accentColor="var(--apple-indigo)" icon={MapPin} delay={100} />
            <KpiCard label="Colegas de equipe" value={colleagues} accentColor="var(--apple-teal)" icon={Users} delay={150} />
            <KpiCard label="Total de pacientes" value={totalPatients} accentColor="var(--apple-green)" icon={Heart} delay={200} />
          </div>

          {/* ── Search bar ───────────────────────────────────────────────── */}
          <div
            className="fade-in-up flex flex-wrap items-center gap-3 mb-4 p-4 rounded-[16px]"
            style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '250ms' }}
          >
            <div className="flex items-center gap-2 flex-1 min-w-[180px] px-3 py-2 rounded-[10px]"
              style={{ background: 'var(--surface-secondary)' }}>
              <Search size={14} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)', flexShrink: 0 }} />
              <input
                type="text"
                placeholder="Buscar por nome, endereço ou cidade..."
                className="bg-transparent border-none outline-none flex-1"
                style={{ fontSize: '15px', color: 'var(--text-primary)' }}
                value={searchTerm}
                onChange={e => setSearchTerm(e.target.value)}
              />
            </div>
            <span style={{ fontSize: '13px', color: 'var(--text-tertiary)' }}>
              {filtered.length} de {clinics.length}
            </span>
          </div>

          {/* ── Table ────────────────────────────────────────────────────── */}
          <div
            className="fade-in-up rounded-[16px] overflow-hidden"
            style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '300ms' }}
          >
            {filtered.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-20 gap-3">
                <div className="w-16 h-16 rounded-full flex items-center justify-center" style={{ background: 'rgba(0,122,255,0.1)' }}>
                  <Building2 size={28} strokeWidth={1.5} style={{ color: 'var(--apple-blue)' }} />
                </div>
                <p className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>
                  {clinics.length === 0 ? 'Nenhuma clínica associada' : 'Nenhum resultado'}
                </p>
                <p style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
                  {clinics.length === 0 ? 'Você ainda não está vinculado a nenhuma clínica.' : 'Tente outros termos de busca.'}
                </p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full border-collapse">
                  <thead>
                    <tr style={{ background: 'rgba(116,116,128,0.06)', borderBottom: '1px solid var(--separator)' }}>
                      {['Clínica', 'Endereço', 'Telefone', 'Veterinários', 'Status'].map(h => (
                        <th key={h} className="text-left font-semibold uppercase"
                          style={{ padding: '10px 20px', fontSize: '11px', letterSpacing: '0.06em', color: 'var(--text-secondary)', border: 'none', background: 'transparent' }}>
                          {h}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {filtered.map((clinic, i) => {
                      const isLast = i === filtered.length - 1;
                      const vetCount = (clinic.veterinarians || []).length;
                      return (
                        <tr
                          key={clinic.id}
                          className="fade-in-up transition-colors duration-100"
                          style={{ borderBottom: isLast ? 'none' : '1px solid var(--separator)', animationDelay: `${300 + i * 25}ms` }}
                          onMouseEnter={e => e.currentTarget.style.background = 'rgba(116,116,128,0.04)'}
                          onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
                        >
                          {/* Clínica */}
                          <td style={{ padding: '14px 20px', border: 'none' }}>
                            <div className="flex items-center gap-3">
                              <div className="w-9 h-9 rounded-[10px] flex items-center justify-center font-semibold text-[13px] flex-shrink-0"
                                style={{ background: 'rgba(88,86,214,0.1)', color: 'var(--apple-indigo)' }}>
                                {clinic.name?.[0]?.toUpperCase() || '?'}
                              </div>
                              <div>
                                <div className="font-medium" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{clinic.name || '—'}</div>
                                <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>{clinic.address?.city || '—'}</div>
                              </div>
                            </div>
                          </td>

                          {/* Endereço */}
                          <td style={{ padding: '14px 20px', border: 'none' }}>
                            <div className="flex items-center gap-1.5">
                              <MapPin size={13} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)', flexShrink: 0 }} />
                              <span style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>{formatAddress(clinic.address)}</span>
                            </div>
                          </td>

                          {/* Telefone */}
                          <td style={{ padding: '14px 20px', border: 'none' }}>
                            <div className="flex items-center gap-1.5">
                              <Phone size={13} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)', flexShrink: 0 }} />
                              <span style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>{clinic.phone || '—'}</span>
                            </div>
                          </td>

                          {/* Veterinários */}
                          <td style={{ padding: '14px 20px', border: 'none' }}>
                            <div className="flex items-center gap-1.5">
                              <Stethoscope size={13} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)', flexShrink: 0 }} />
                              <span style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>
                                {vetCount} {vetCount === 1 ? 'profissional' : 'profissionais'}
                              </span>
                            </div>
                          </td>

                          {/* Status */}
                          <td style={{ padding: '14px 20px', border: 'none' }}>
                            <StatusBadge status={clinic.status} />
                          </td>
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

export default ClinicasPage;
