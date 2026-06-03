import React, { useState } from 'react';
import { Search, Filter, CheckCircle, Clock, XCircle, ClipboardList } from 'lucide-react';
import VaccineDetailsModal from './VaccineDetailsModal';
import VaccineDeleteModal from './VaccineDeleteModal';
import VaccineEditModal from './VaccineEditModal';
import useVetVaccines from '../../../hooks/useVetVaccines';

// ── Status config ──────────────────────────────────────────────────────────
const STATUS_CFG = {
  approved:  { label: 'Aprovado',  bg: 'rgba(52,199,89,0.12)',  text: 'var(--apple-green)', dot: 'var(--apple-green)',  icon: CheckCircle },
  rejected:  { label: 'Rejeitado', bg: 'rgba(255,59,48,0.10)',  text: 'var(--apple-red)',   dot: 'var(--apple-red)',    icon: XCircle     },
  pending:   { label: 'Pendente',  bg: 'rgba(255,149,0,0.12)', text: 'var(--apple-orange)', dot: 'var(--apple-orange)', icon: Clock       },
  vetApproved: { label: 'Aprovado Vet', bg: 'rgba(88,86,214,0.10)', text: 'var(--apple-indigo)', dot: 'var(--apple-indigo)', icon: CheckCircle },
};

const StatusBadge = ({ status }) => {
  const cfg = STATUS_CFG[status] || { label: status || '—', bg: 'rgba(142,142,147,0.1)', text: 'var(--apple-gray-1)', dot: 'var(--apple-gray-3)', icon: Clock };
  const Icon = cfg.icon;
  return (
    <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[12px] font-medium" style={{ background: cfg.bg, color: cfg.text }}>
      <Icon size={11} strokeWidth={2} />
      {cfg.label}
    </span>
  );
};

const formatDate = (date) => {
  if (!date) return '—';
  if (typeof date === 'string') return date;
  if (date?.toDate instanceof Function) return date.toDate().toLocaleDateString('pt-BR');
  if (date instanceof Date) return date.toLocaleDateString('pt-BR');
  if (date?.seconds) return new Date(date.seconds * 1000).toLocaleDateString('pt-BR');
  return '—';
};

// ── KPI stat card ──────────────────────────────────────────────────────────
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

// ── Page ──────────────────────────────────────────────────────────────────
const VaccinePage = () => {
  const { vaccines, loading } = useVetVaccines();
  const [filterStatus, setFilterStatus] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedVaccine, setSelectedVaccine] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);

  const filteredVaccines = vaccines
    .filter(v => filterStatus === 'all' || v.status === filterStatus)
    .filter(v => {
      if (!searchTerm) return true;
      const q = searchTerm.toLowerCase();
      return v.petName?.toLowerCase().includes(q) ||
        v.id?.toLowerCase().includes(q) ||
        v.ownerName?.toLowerCase().includes(q) ||
        v.name?.toLowerCase().includes(q);
    });

  return (
    <div className="min-h-full font-sf">

      {/* ── Page header ─────────────────────────────────────────────────── */}
      <div className="mb-6 fade-in-up">
        <h1 className="font-bold" style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
          Vacinas
        </h1>
        <p className="mt-1" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
          Revise e valide os registros de vacinação associados ao seu CRMV.
        </p>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-64">
          <div className="w-8 h-8 rounded-full border-2 border-transparent animate-spin"
            style={{ borderTopColor: 'var(--apple-blue)' }} />
        </div>
      ) : (
        <>
          {/* ── KPI cards ──────────────────────────────────────────────── */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
            <KpiCard label="Total" value={vaccines.length} accentColor="var(--apple-blue)" icon={ClipboardList} delay={50} />
            <KpiCard label="Pendentes" value={vaccines.filter(v => v.status === 'pending').length} accentColor="var(--apple-orange)" icon={Clock} delay={100} />
            <KpiCard label="Aprovados" value={vaccines.filter(v => v.status === 'approved' || v.status === 'vetApproved').length} accentColor="var(--apple-green)" icon={CheckCircle} delay={150} />
            <KpiCard label="Rejeitados" value={vaccines.filter(v => v.status === 'rejected').length} accentColor="var(--apple-red)" icon={XCircle} delay={200} />
          </div>

          {/* ── Search + filter bar ──────────────────────────────────────── */}
          <div
            className="fade-in-up flex flex-wrap items-center gap-3 mb-4 p-4 rounded-[16px]"
            style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '250ms' }}
          >
            <div className="flex items-center gap-2 flex-1 min-w-[180px] px-3 py-2 rounded-[10px]"
              style={{ background: 'var(--surface-secondary)' }}>
              <Search size={14} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)', flexShrink: 0 }} />
              <input
                type="text"
                placeholder="Buscar por pet, tutor ou vacina..."
                className="bg-transparent border-none outline-none flex-1"
                style={{ fontSize: '15px', color: 'var(--text-primary)' }}
                value={searchTerm}
                onChange={e => setSearchTerm(e.target.value)}
              />
            </div>
            <div className="flex items-center gap-2 px-3 py-2 rounded-[10px]" style={{ background: 'var(--surface-secondary)' }}>
              <Filter size={14} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)' }} />
              <select
                className="bg-transparent border-none outline-none"
                style={{ fontSize: '15px', color: 'var(--text-primary)' }}
                value={filterStatus}
                onChange={e => setFilterStatus(e.target.value)}
              >
                <option value="all">Todos</option>
                <option value="pending">Pendente</option>
                <option value="approved">Aprovado</option>
                <option value="vetApproved">Aprovado Vet</option>
                <option value="rejected">Rejeitado</option>
              </select>
            </div>
            <span style={{ fontSize: '13px', color: 'var(--text-tertiary)' }}>
              {filteredVaccines.length} de {vaccines.length}
            </span>
          </div>

          {/* ── Table ────────────────────────────────────────────────────── */}
          <div
            className="fade-in-up rounded-[16px] overflow-hidden"
            style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '300ms' }}
          >
            {filteredVaccines.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-20 gap-3">
                <div className="w-16 h-16 rounded-full flex items-center justify-center" style={{ background: 'rgba(0,122,255,0.1)' }}>
                  <ClipboardList size={28} strokeWidth={1.5} style={{ color: 'var(--apple-blue)' }} />
                </div>
                <p className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>
                  {vaccines.length === 0 ? 'Nenhuma vacina registrada' : 'Nenhum resultado'}
                </p>
                <p style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
                  {vaccines.length === 0 ? 'Os registros de vacinas aparecerão aqui.' : 'Tente outros filtros.'}
                </p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full border-collapse">
                  <thead>
                    <tr style={{ background: 'rgba(116,116,128,0.06)', borderBottom: '1px solid var(--separator)' }}>
                      {['Data / ID', 'Pet · Tutor', 'Vacina', 'CRMV', 'Status', 'Ações'].map(h => (
                        <th key={h} className="text-left font-semibold uppercase"
                          style={{ padding: '10px 20px', fontSize: '11px', letterSpacing: '0.06em', color: 'var(--text-secondary)', border: 'none', background: 'transparent' }}>
                          {h}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {filteredVaccines.map((vaccine, i) => {
                      const isLast = i === filteredVaccines.length - 1;
                      return (
                        <tr
                          key={vaccine.id}
                          className="fade-in-up transition-colors duration-100"
                          style={{ borderBottom: isLast ? 'none' : '1px solid var(--separator)', animationDelay: `${300 + i * 25}ms` }}
                          onMouseEnter={e => e.currentTarget.style.background = 'rgba(116,116,128,0.04)'}
                          onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
                        >
                          <td style={{ padding: '14px 20px', border: 'none' }}>
                            <div className="font-medium" style={{ fontSize: '13px', color: 'var(--text-secondary)', fontFamily: 'monospace' }}>
                              {vaccine.id?.substring(0, 8)}…
                            </div>
                            <div style={{ fontSize: '13px', color: 'var(--text-tertiary)' }}>{formatDate(vaccine.administrationDate)}</div>
                          </td>
                          <td style={{ padding: '14px 20px', border: 'none' }}>
                            <div className="font-medium" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{vaccine.petName || '—'}</div>
                            <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>{vaccine.ownerName || '—'}</div>
                          </td>
                          <td style={{ padding: '14px 20px', border: 'none' }}>
                            <div className="font-medium" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{vaccine.name || '—'}</div>
                            <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>Lote: {vaccine.batchNumber || '—'}</div>
                          </td>
                          <td style={{ padding: '14px 20px', border: 'none' }}>
                            <div className="font-medium" style={{ fontSize: '13px', color: 'var(--text-primary)' }}>{vaccine.crmvNumber || '—'}</div>
                            <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>{vaccine.veterinarianName || '—'}</div>
                          </td>
                          <td style={{ padding: '14px 20px', border: 'none' }}>
                            <StatusBadge status={vaccine.status} />
                          </td>
                          <td style={{ padding: '14px 20px', border: 'none' }}>
                            <button
                              onClick={() => { setSelectedVaccine(vaccine); setIsModalOpen(true); }}
                              className="font-medium transition-opacity duration-100"
                              style={{ fontSize: '15px', color: 'var(--apple-blue)' }}
                              onMouseEnter={e => e.currentTarget.style.opacity = '0.7'}
                              onMouseLeave={e => e.currentTarget.style.opacity = '1'}
                            >
                              Ver
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
        </>
      )}

      {/* Modals */}
      <VaccineDetailsModal isOpen={isModalOpen} onClose={() => { setIsModalOpen(false); setSelectedVaccine(null); }} vaccine={selectedVaccine} />
      <VaccineDeleteModal isOpen={isDeleteModalOpen} onClose={() => setIsDeleteModalOpen(false)} vaccine={selectedVaccine} onDelete={() => {}} />
      <VaccineEditModal isOpen={isEditModalOpen} onClose={() => setIsEditModalOpen(false)} vaccine={selectedVaccine} onSave={() => {}} />
    </div>
  );
};

export default VaccinePage;
