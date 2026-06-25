import React from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Printer, Camera, MapPin, Syringe, Bug, ShieldCheck } from 'lucide-react';
import { usePetRecord } from '../../../hooks/usePetRecord';
import { useAuth } from '../../../context/AuthContext';
import { normalizeStatus } from '../../../utils/vaccineStatus';
import { toDate } from '../../../utils/dates';

const fmt = (v) => { const d = toDate(v); return d ? d.toLocaleDateString('pt-BR') : '—'; };
const getAge = (birthDate) => {
  const b = toDate(birthDate);
  if (!b) return '—';
  const months = (new Date().getFullYear() - b.getFullYear()) * 12 + (new Date().getMonth() - b.getMonth());
  if (months < 12) return `${months} ${months === 1 ? 'mês' : 'meses'}`;
  const y = Math.floor(months / 12);
  return `${y} ${y === 1 ? 'ano' : 'anos'}`;
};

// Carteira de vacinação/vermifugação — só registros APROVADOS e ATIVOS.
// Gera PDF via impressão do navegador (Salvar como PDF). Sem link público.
const Carteira = () => {
  const { petId } = useParams();
  const navigate = useNavigate();
  const { userProfile } = useAuth();
  const { pet, vaccines, dewormings, loading, error } = usePetRecord(petId);

  const isTutor = userProfile?.role === 'tutor';
  const backTo = isTutor ? `/meus-pets/${petId}` : `/pets/${petId}`;

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
        <p style={{ color: 'var(--text-secondary)', fontSize: '15px' }}>{error?.message || 'Paciente não encontrado.'}</p>
      </div>
    );
  }

  const approved = (arr, tipo) => (arr || [])
    .filter(r => normalizeStatus(r.status) === 'approved' && r.active !== false)
    .map(r => ({ ...r, tipo }));
  const records = [...approved(vaccines, 'vacina'), ...approved(dewormings, 'vermifugo')]
    .sort((a, b) => (toDate(b.administrationDate) || 0) - (toDate(a.administrationDate) || 0));

  return (
    <div className="min-h-full font-sf">
      {/* Toolbar (não imprime) */}
      <div className="no-print flex items-center justify-between mb-5">
        <button onClick={() => navigate(backTo)}
          className="flex items-center gap-1.5 font-medium" style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>
          <ArrowLeft size={16} strokeWidth={2} /> Voltar ao prontuário
        </button>
        <button onClick={() => window.print()}
          className="flex items-center gap-1.5 px-4 py-2 rounded-[10px] font-medium transition-opacity duration-150"
          style={{ fontSize: '14px', color: '#fff', background: 'var(--apple-blue)' }}
          onMouseEnter={e => e.currentTarget.style.opacity = '0.85'}
          onMouseLeave={e => e.currentTarget.style.opacity = '1'}>
          <Printer size={15} strokeWidth={2} /> Imprimir / Salvar PDF
        </button>
      </div>

      {/* Documento */}
      <div id="carteira-doc" className="rounded-[16px] p-7"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}>
        {/* Cabeçalho */}
        <div className="flex items-center justify-between pb-5" style={{ borderBottom: '2px solid var(--separator)' }}>
          <div>
            <div className="flex items-center gap-2">
              <ShieldCheck size={20} strokeWidth={1.75} style={{ color: 'var(--apple-blue)' }} />
              <h1 className="font-bold" style={{ fontSize: '20px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
                Carteira de Vacinação e Vermifugação
              </h1>
            </div>
            <p className="mt-1" style={{ fontSize: '13px', color: 'var(--text-tertiary)' }}>
              Documento com registros validados · emitido em {new Date().toLocaleDateString('pt-BR')}
            </p>
          </div>
        </div>

        {/* Dados do pet */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 py-5" style={{ borderBottom: '1px solid var(--separator)' }}>
          {[
            ['Pet', pet.name],
            ['Espécie / Raça', `${pet.species || '—'}${pet.breed ? ` · ${pet.breed}` : ''}`],
            ['Idade', getAge(pet.birthDate)],
            ['Tutor', pet.ownerName],
            ['Microchip', pet.chipNumber || '—'],
            ['Sexo', pet.gender || '—'],
          ].map(([label, value]) => (
            <div key={label}>
              <div style={{ fontSize: '11px', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.05em', color: 'var(--text-tertiary)' }}>{label}</div>
              <div className="mt-0.5" style={{ fontSize: '14px', color: 'var(--text-primary)' }}>{value || '—'}</div>
            </div>
          ))}
        </div>

        {/* Registros */}
        {records.length === 0 ? (
          <div className="py-12 text-center" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
            Nenhum registro validado para exibir.
          </div>
        ) : (
          <div className="overflow-x-auto pt-4">
            <table className="w-full border-collapse">
              <thead>
                <tr style={{ borderBottom: '1px solid var(--separator)' }}>
                  {['Tipo', 'Nome', 'Fabricante', 'Lote', 'Aplicação', 'Próxima dose', 'Responsável', 'Comprovação'].map(h => (
                    <th key={h} className="text-left font-semibold uppercase"
                      style={{ padding: '8px 12px', fontSize: '10px', letterSpacing: '0.05em', color: 'var(--text-secondary)' }}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {records.map((r, i) => (
                  <tr key={`${r.tipo}_${r.id}`} style={{ borderBottom: i < records.length - 1 ? '1px solid var(--separator)' : 'none' }}>
                    <td style={{ padding: '10px 12px' }}>
                      <span className="inline-flex items-center gap-1" style={{ fontSize: '13px', color: r.tipo === 'vacina' ? 'var(--apple-blue)' : 'var(--apple-teal)' }}>
                        {r.tipo === 'vacina' ? <Syringe size={13} strokeWidth={2} /> : <Bug size={13} strokeWidth={2} />}
                        {r.tipo === 'vacina' ? 'Vacina' : 'Vermífugo'}
                      </span>
                    </td>
                    <td style={{ padding: '10px 12px', fontSize: '13px', color: 'var(--text-primary)' }}>{r.name || '—'}</td>
                    <td style={{ padding: '10px 12px', fontSize: '13px', color: 'var(--text-secondary)' }}>{r.manufacturer || '—'}</td>
                    <td style={{ padding: '10px 12px', fontSize: '13px', color: 'var(--text-secondary)' }}>{r.batchNumber || '—'}</td>
                    <td style={{ padding: '10px 12px', fontSize: '13px', color: 'var(--text-secondary)' }}>{fmt(r.administrationDate)}</td>
                    <td style={{ padding: '10px 12px', fontSize: '13px', color: 'var(--text-secondary)' }}>{fmt(r.nextDueDate)}</td>
                    <td style={{ padding: '10px 12px', fontSize: '13px', color: 'var(--text-secondary)' }}>
                      {r.veterinarianName || '—'}{r.crmvNumber ? ` (${r.crmvNumber})` : ''}{r.clinicName ? ` · ${r.clinicName}` : ''}
                    </td>
                    <td style={{ padding: '10px 12px' }}>
                      <span className="inline-flex items-center gap-1.5" style={{ fontSize: '12px', color: 'var(--text-tertiary)' }}>
                        {r.labelImage && <Camera size={13} strokeWidth={1.75} title="Foto do rótulo" />}
                        {r.labelImageMetadata?.location && <MapPin size={13} strokeWidth={1.75} title="Geolocalização" />}
                        {!r.labelImage && !r.labelImageMetadata?.location && '—'}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        <p className="pt-5 mt-2" style={{ fontSize: '11px', color: 'var(--text-tertiary)', borderTop: '1px solid var(--separator)' }}>
          Apenas registros aprovados por veterinário (CRMV) são exibidos. Comprovação: 📷 foto do rótulo · 📍 geolocalização da aplicação.
        </p>
      </div>
    </div>
  );
};

export default Carteira;
