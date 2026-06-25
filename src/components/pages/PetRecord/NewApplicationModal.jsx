import React, { useState, useEffect } from 'react';
import { X, MapPin, AlertCircle } from 'lucide-react';
import { serverTimestamp } from 'firebase/firestore';
import { vaccineService } from '../../../services/firebase/vaccineService';
import { useAuth } from '../../../context/AuthContext';
import { useCatalog } from '../../../hooks/useCatalog';

const DAY = 24 * 60 * 60 * 1000;
const todayISO = () => new Date().toISOString().slice(0, 10);

const inputStyle = {
  width: '100%',
  background: 'var(--surface-secondary)',
  borderRadius: '10px',
  padding: '12px 14px',
  fontSize: '15px',
  color: 'var(--text-primary)',
  border: 'none',
  outline: 'none',
};

const Field = ({ label, required, children }) => (
  <div>
    <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, color: 'var(--text-secondary)', marginBottom: '6px' }}>
      {label} {required && <span style={{ color: 'var(--apple-red)' }}>*</span>}
    </label>
    {children}
  </div>
);

// Captura não-bloqueante da localização do dispositivo.
const getCurrentLocation = () => new Promise((resolve) => {
  if (!navigator.geolocation) return resolve(null);
  navigator.geolocation.getCurrentPosition(
    (pos) => resolve({ latitude: pos.coords.latitude, longitude: pos.coords.longitude }),
    () => resolve(null),
    { timeout: 8000, enableHighAccuracy: false }
  );
});

/**
 * Cadastro de aplicação feito pelo próprio veterinário.
 * O registro nasce com status 'approved' (auto-validado pelo CRMV de quem aplicou).
 * `type` permite reuso futuro (vermífugo) — por ora, 'vacina'.
 */
export default function NewApplicationModal({ isOpen, onClose, pet, type = 'vacina', onCreated }) {
  const { user, userProfile } = useAuth();
  const { items: catalog } = useCatalog(type);
  const [form, setForm] = useState({});
  const [selectedCatalogId, setSelectedCatalogId] = useState('');
  const [labelFile, setLabelFile] = useState(null);
  const [attachLocation, setAttachLocation] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (isOpen) {
      setForm({
        name: '', manufacturer: '', batchNumber: '', dosage: '', dose: '',
        route: '', applicationSite: '',
        administrationDate: todayISO(), expirationDate: '', nextDueDate: '',
        clinicName: '',
      });
      setLabelFile(null);
      setAttachLocation(false);
      setSelectedCatalogId('');
      setError('');
    }
  }, [isOpen]);

  // Recalcula a próxima dose ao mudar a data de aplicação (se item do catálogo escolhido).
  useEffect(() => {
    if (!isOpen || !selectedCatalogId) return;
    const item = catalog.find(c => c.id === selectedCatalogId);
    if (!item?.reforcoDias || !form.administrationDate) return;
    const next = new Date(new Date(form.administrationDate).getTime() + item.reforcoDias * DAY);
    setForm(f => ({ ...f, nextDueDate: next.toISOString().slice(0, 10) }));
  }, [form.administrationDate]); // eslint-disable-line react-hooks/exhaustive-deps

  if (!isOpen) return null;

  const isDeworming = type === 'vermifugo';
  const title = isDeworming ? 'Novo vermífugo' : 'Nova vacina';
  const nameLabel = isDeworming ? 'Nome do produto' : 'Nome da vacina';
  const namePlaceholder = isDeworming ? 'Ex.: Milbemax' : 'Ex.: V10 Polivalente';

  const set = (k) => (e) => setForm(f => ({ ...f, [k]: e.target.value }));
  const valid = (form.name || '').trim() && form.administrationDate;

  // Item do catálogo selecionado (para pré-preenchimento e validação por espécie).
  const chosen = catalog.find(c => c.id === selectedCatalogId) || null;
  const speciesMismatch = chosen && Array.isArray(chosen.species) && pet?.species
    && !chosen.species.includes('all') && !chosen.species.includes(pet.species);

  const chooseCatalog = (id) => {
    setSelectedCatalogId(id);
    const item = catalog.find(c => c.id === id);
    if (!item) return;
    setForm(f => {
      const adm = f.administrationDate ? new Date(f.administrationDate) : new Date();
      const next = item.reforcoDias ? new Date(adm.getTime() + item.reforcoDias * DAY) : null;
      return { ...f, name: item.name, manufacturer: item.manufacturer || '', nextDueDate: next ? next.toISOString().slice(0, 10) : f.nextDueDate };
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!valid || saving) return;
    setSaving(true);
    setError('');
    try {
      let location = null;
      if (attachLocation) location = await getCurrentLocation();

      const data = {
        type,
        name: form.name.trim(),
        manufacturer: form.manufacturer.trim(),
        batchNumber: form.batchNumber.trim(),
        ...(isDeworming ? { dosage: (form.dosage || '').trim() } : { dose: (form.dose || '').trim() }),
        route: form.route || '',
        applicationSite: (form.applicationSite || '').trim(),
        administrationDate: form.administrationDate ? new Date(form.administrationDate) : new Date(),
        expirationDate: form.expirationDate ? new Date(form.expirationDate) : null,
        nextDueDate: form.nextDueDate ? new Date(form.nextDueDate) : null,
        // Snapshot clínico (ponto-no-tempo)
        petId: pet.id,
        petName: pet.name || '',
        petSpecies: pet.species || '',
        petBreed: pet.breed || '',
        petWeight: pet.weight ?? null,
        ownerId: pet.ownerId || '',
        ownerName: pet.ownerName || '',
        ownerContact: pet.ownerContact || '',
        // Responsável
        veterinarianId: user?.uid || '',
        veterinarianName: userProfile?.name || '',
        crmvNumber: userProfile?.crmv || '',
        clinicName: (form.clinicName || '').trim(),
        // Trilha de auditoria (createdAt/updatedAt são carimbados no service)
        createdBy: user?.uid || '',
        updatedBy: user?.uid || '',
        // Nasce aprovada — auto-validada pelo CRMV de quem aplicou
        status: 'approved',
        validationDetails: {
          vetValidation: {
            status: 'approved',
            validatedBy: user?.uid || '',
            validatedByName: userProfile?.name || '',
            validatedByCrmv: userProfile?.crmv || '',
            validatedAt: serverTimestamp(),
            notes: 'Registrado e validado pelo veterinário aplicador.',
            rejectionReason: '',
          },
        },
        tutorAcknowledged: false,
        tutorAcknowledgedAt: null,
        notes: '',
        ...(location ? { location } : {}),
      };

      if (isDeworming) await vaccineService.createDeworming(data, labelFile);
      else await vaccineService.createVaccine(data, labelFile);
      if (onCreated) await onCreated();
      onClose();
    } catch (err) {
      setError(err?.message || 'Erro ao salvar a aplicação. Tente novamente.');
      setSaving(false);
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 font-sf overflow-y-auto"
      style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(8px)', WebkitBackdropFilter: 'blur(8px)' }}
      onClick={onClose}
    >
      <div
        className="fade-in-up w-full max-w-[520px] my-8 rounded-[20px] overflow-hidden"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 24px 70px rgba(0,0,0,0.35)' }}
        onClick={e => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-7 py-5" style={{ borderBottom: '1px solid var(--separator)' }}>
          <div>
            <h2 className="font-bold" style={{ fontSize: '20px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
              {title}
            </h2>
            <p className="mt-0.5" style={{ fontSize: '13px', color: 'var(--text-tertiary)' }}>
              {pet?.name} · será registrado como aprovado (seu CRMV)
            </p>
          </div>
          <button onClick={onClose} className="rounded-[8px] p-1.5 transition-colors duration-150"
            onMouseEnter={e => e.currentTarget.style.background = 'var(--surface-secondary)'}
            onMouseLeave={e => e.currentTarget.style.background = 'transparent'}>
            <X size={18} strokeWidth={2} style={{ color: 'var(--text-secondary)' }} />
          </button>
        </div>

        {/* Body */}
        <form onSubmit={handleSubmit} className="px-7 py-6 flex flex-col gap-4">
          {catalog.length > 0 && (
            <Field label="Catálogo">
              <select value={selectedCatalogId} onChange={e => chooseCatalog(e.target.value)} style={{ ...inputStyle, appearance: 'auto' }}>
                <option value="">— Entrada livre —</option>
                {catalog.map(c => (
                  <option key={c.id} value={c.id}>{c.name}{c.manufacturer ? ` · ${c.manufacturer}` : ''}</option>
                ))}
              </select>
            </Field>
          )}

          <Field label={nameLabel} required>
            <input type="text" value={form.name || ''} onChange={set('name')} style={inputStyle} placeholder={namePlaceholder} autoFocus />
            {catalog.length > 0 && !selectedCatalogId && (form.name || '').trim() && (
              <p className="mt-1" style={{ fontSize: '12px', color: 'var(--apple-orange)' }}>Item fora do catálogo (entrada livre).</p>
            )}
            {speciesMismatch && (
              <p className="mt-1 flex items-center gap-1" style={{ fontSize: '12px', color: 'var(--apple-orange)' }}>
                <AlertCircle size={12} /> Este item não é indicado para a espécie do pet ({pet.species}).
              </p>
            )}
          </Field>

          <div className="grid grid-cols-2 gap-4">
            <Field label="Fabricante">
              <input type="text" value={form.manufacturer || ''} onChange={set('manufacturer')} style={inputStyle} placeholder={isDeworming ? 'Ex.: Elanco' : 'Ex.: Zoetis'} />
            </Field>
            <Field label="Lote">
              <input type="text" value={form.batchNumber || ''} onChange={set('batchNumber')} style={inputStyle} placeholder="Ex.: ZT-2025-001" />
            </Field>
          </div>

          {isDeworming && (
            <Field label="Dosagem">
              <input type="text" value={form.dosage || ''} onChange={set('dosage')} style={inputStyle} placeholder="Ex.: 1 comprimido" />
            </Field>
          )}

          <div className="grid grid-cols-2 gap-4">
            <Field label="Via de administração">
              <select value={form.route || ''} onChange={set('route')} style={{ ...inputStyle, appearance: 'auto' }}>
                <option value="">—</option>
                <option>Subcutânea</option>
                <option>Intramuscular</option>
                <option>Oral</option>
                <option>Intranasal</option>
                <option>Tópica</option>
                <option>Outra</option>
              </select>
            </Field>
            <Field label="Local de aplicação">
              <input type="text" value={form.applicationSite || ''} onChange={set('applicationSite')} style={inputStyle} placeholder="Ex.: dorso, membro posterior" />
            </Field>
          </div>

          {!isDeworming && (
            <Field label="Dose">
              <input type="text" value={form.dose || ''} onChange={set('dose')} style={inputStyle} placeholder="Ex.: 1 mL" />
            </Field>
          )}

          <div className="grid grid-cols-2 gap-4">
            <Field label="Data de aplicação" required>
              <input type="date" value={form.administrationDate || ''} onChange={set('administrationDate')} style={inputStyle} />
            </Field>
            <Field label="Próxima dose">
              <input type="date" value={form.nextDueDate || ''} onChange={set('nextDueDate')} style={inputStyle} />
            </Field>
            <Field label="Validade do produto">
              <input type="date" value={form.expirationDate || ''} onChange={set('expirationDate')} style={inputStyle} />
            </Field>
            <Field label="Clínica">
              <input type="text" value={form.clinicName || ''} onChange={set('clinicName')} style={inputStyle} placeholder="Opcional" />
            </Field>
          </div>

          <Field label="Foto do rótulo">
            <input
              type="file"
              accept="image/*"
              onChange={e => setLabelFile(e.target.files?.[0] || null)}
              style={{ ...inputStyle, padding: '10px 14px' }}
            />
            <p className="mt-1" style={{ fontSize: '12px', color: 'var(--text-tertiary)' }}>
              Os metadados da imagem (EXIF) são removidos no upload por privacidade.
            </p>
          </Field>

          {/* Location toggle */}
          <label className="flex items-center justify-between gap-3 rounded-[10px] px-4 py-3 cursor-pointer"
            style={{ background: 'var(--surface-secondary)' }}>
            <span className="flex items-center gap-2" style={{ fontSize: '14px', color: 'var(--text-primary)' }}>
              <MapPin size={15} strokeWidth={1.75} style={{ color: 'var(--text-secondary)' }} />
              Anexar localização atual
            </span>
            <input type="checkbox" checked={attachLocation} onChange={e => setAttachLocation(e.target.checked)} />
          </label>

          {error && (
            <div className="flex items-center gap-2 px-3 py-2.5 rounded-[10px]"
              style={{ background: 'rgba(255,59,48,0.08)', color: 'var(--apple-red)', fontSize: '13px' }}>
              <AlertCircle size={14} /> {error}
            </div>
          )}

          <div className="flex items-center justify-end gap-2 pt-1">
            <button type="button" onClick={onClose}
              className="px-4 py-2.5 rounded-[10px] font-medium transition-colors duration-150"
              style={{ fontSize: '15px', color: 'var(--text-secondary)', background: 'var(--surface-secondary)' }}>
              Cancelar
            </button>
            <button type="submit" disabled={!valid || saving}
              className="px-5 py-2.5 rounded-[10px] font-medium transition-opacity duration-150"
              style={{ fontSize: '15px', color: '#fff', background: 'var(--apple-blue)', opacity: (!valid || saving) ? 0.5 : 1, cursor: (!valid || saving) ? 'default' : 'pointer' }}>
              {saving ? 'Salvando...' : 'Registrar aplicação'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
