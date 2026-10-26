import React, { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { X, AlertCircle, Camera } from 'lucide-react';
import { toDate, toDateInput } from '../../../utils/dates';

// Valores gravados iguais aos do app (pet_model / add_pet): o prontuário do
// veterinário e a carteira exibem estes textos como vieram.
const SPECIES = ['Cachorro', 'Gato'];
const GENDERS = ['Macho', 'Fêmea'];

// Mesmo rótulo de "sem raça definida" do app (BreedUtils.semRacaDefinida).
const SRD = 'SRD (sem raça definida)';

// Sugestões em português — o campo aceita qualquer texto.
const BREEDS = {
  Cachorro: [
    SRD, 'Beagle', 'Border Collie', 'Boxer', 'Buldogue Francês', 'Buldogue Inglês',
    'Chihuahua', 'Cocker Spaniel', 'Dachshund (Salsicha)', 'Dálmata', 'Doberman',
    'Golden Retriever', 'Husky Siberiano', 'Labrador Retriever', 'Lhasa Apso', 'Maltês',
    'Pastor Alemão', 'Pinscher', 'Pit Bull', 'Poodle', 'Pug', 'Rottweiler', 'Schnauzer',
    'Shih Tzu', 'Spitz Alemão (Lulu da Pomerânia)', 'Yorkshire Terrier',
  ],
  Gato: [
    SRD, 'Angorá', 'Bengal', 'British Shorthair', 'Maine Coon', 'Persa', 'Ragdoll',
    'Siamês', 'Somali', 'Sphynx',
  ],
};

const todayISO = () => toDateInput();
const MAX_PHOTO_MB = 15; // antes da compressão (que entrega ~1 MB)

const EMPTY = {
  name: '', species: '', gender: '', breed: SRD, birthDate: '', color: '',
  isNeutered: false, chipNumber: '', weight: '', allergies: '', chronicConditions: '',
};

// Pet salvo → valores do formulário (modo edição).
const fromPet = (pet) => {
  const birth = toDate(pet.birthDate);
  return {
    name: pet.name || '',
    species: pet.species || '',
    gender: pet.gender || '',
    breed: pet.breed || SRD,
    birthDate: birth ? toDateInput(birth) : '',
    color: pet.color || '',
    isNeutered: !!pet.isNeutered,
    chipNumber: pet.chipNumber || '',
    weight: pet.weight != null ? String(pet.weight) : '',
    allergies: Array.isArray(pet.allergies) ? pet.allergies.join(', ') : (pet.allergies || ''),
    chronicConditions: pet.chronicConditions || '',
  };
};

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

const Field = ({ label, hint, error, children }) => (
  <div>
    <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, color: 'var(--text-secondary)', marginBottom: '6px' }}>
      {label}
      {hint && <span style={{ fontWeight: 400, color: 'var(--text-tertiary)' }}> · {hint}</span>}
    </label>
    {children}
    {error && <p style={{ fontSize: '12px', color: 'var(--apple-red)', marginTop: '4px' }}>{error}</p>}
  </div>
);

// Escolha única com poucas opções — mais rápido que um select.
const Segmented = ({ options, value, onChange, labels = {} }) => (
  <div className="grid gap-2" style={{ gridTemplateColumns: `repeat(${options.length}, 1fr)` }}>
    {options.map((opt) => {
      const active = value === opt;
      return (
        <button
          key={String(opt)}
          type="button"
          onClick={() => onChange(opt)}
          aria-pressed={active}
          className="rounded-[10px] py-2.5 font-medium transition-colors duration-150"
          style={{
            fontSize: '15px',
            background: active ? 'var(--apple-blue)' : 'var(--surface-secondary)',
            color: active ? '#fff' : 'var(--text-primary)',
          }}
        >
          {labels[opt] ?? opt}
        </button>
      );
    })}
  </div>
);

/**
 * Formulário de pet do tutor — cadastro (sem `initialPet`) ou edição.
 * `onSubmit(data, photoFile)` grava; o retorno (id do pet no cadastro) vai para `onDone`.
 */
export default function PetFormModal({ isOpen, onClose, onSubmit, onDone, initialPet }) {
  const isEdit = !!initialPet;
  const [form, setForm] = useState(EMPTY);
  const [errors, setErrors] = useState({});
  const [saving, setSaving] = useState(false);
  const [submitError, setSubmitError] = useState('');
  const [photoFile, setPhotoFile] = useState(null);
  const [photoPreview, setPhotoPreview] = useState(null);

  useEffect(() => {
    if (isOpen) {
      setForm(initialPet ? fromPet(initialPet) : EMPTY);
      setErrors({});
      setSubmitError('');
      setSaving(false);
      setPhotoFile(null);
      setPhotoPreview(null);
    }
  }, [isOpen, initialPet]);

  // Libera a URL temporária da prévia ao trocar de foto ou fechar.
  useEffect(() => () => { if (photoPreview) URL.revokeObjectURL(photoPreview); }, [photoPreview]);

  if (!isOpen) return null;

  const choosePhoto = (e) => {
    const file = e.target.files?.[0];
    e.target.value = '';
    if (!file) return;
    if (!file.type.startsWith('image/')) {
      setErrors((x) => ({ ...x, photo: 'Escolha um arquivo de imagem.' }));
      return;
    }
    if (file.size > MAX_PHOTO_MB * 1024 * 1024) {
      setErrors((x) => ({ ...x, photo: `A foto precisa ter até ${MAX_PHOTO_MB} MB.` }));
      return;
    }
    setErrors((x) => ({ ...x, photo: undefined }));
    setPhotoFile(file);
    setPhotoPreview(URL.createObjectURL(file));
  };
  const shownPhoto = photoPreview || initialPet?.imageUrl || null;

  // Corrigir o campo apaga o erro dele na hora — sem esperar novo envio.
  const clearError = (k) => setErrors((e) => (e[k] ? { ...e, [k]: undefined } : e));
  const set = (k) => (e) => {
    setForm((f) => ({ ...f, [k]: e?.target ? e.target.value : e }));
    clearError(k);
  };
  const setSpecies = (species) => {
    setForm((f) => ({ ...f, species, breed: SRD }));
    clearError('species');
  };

  const validate = () => {
    const e = {};
    if (!form.name.trim()) e.name = 'Informe o nome do pet.';
    if (!form.species) e.species = 'Escolha a espécie.';
    if (!form.gender) e.gender = 'Escolha o sexo.';
    if (!form.birthDate) e.birthDate = 'Informe a data de nascimento (pode ser aproximada).';
    else if (form.birthDate > todayISO()) e.birthDate = 'A data não pode estar no futuro.';
    if (form.weight !== '' && !(Number(form.weight) > 0)) e.weight = 'Peso inválido.';
    setErrors(e);
    return Object.keys(e).length === 0;
  };

  const handleSubmit = async (ev) => {
    ev.preventDefault();
    if (!validate()) return;
    setSaving(true);
    setSubmitError('');
    try {
      const result = await onSubmit({
        name: form.name.trim(),
        species: form.species,
        gender: form.gender,
        breed: form.breed.trim() || SRD,
        // Meio-dia local: evita o pet "nascer" um dia antes por fuso horário.
        birthDate: new Date(`${form.birthDate}T12:00:00`),
        color: form.color.trim(),
        isNeutered: form.isNeutered,
        chipNumber: form.chipNumber.trim(),
        weight: form.weight !== '' ? Number(form.weight) : null,
        allergies: form.allergies.split(',').map((a) => a.trim()).filter(Boolean),
        chronicConditions: form.chronicConditions.trim(),
      }, photoFile);
      onDone?.(result);
    } catch (err) {
      setSubmitError(err?.message || `Não foi possível ${isEdit ? 'salvar' : 'cadastrar'} o pet. Tente novamente.`);
      setSaving(false);
    }
  };

  // Portal no body: na edição o modal abre de dentro do card do prontuário,
  // que tem animação com transform (prenderia o `position: fixed`).
  return createPortal(
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 font-sf overflow-y-auto"
      style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(4px)' }}
      onClick={onClose}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="pet-form-title"
        className="fade-in-up rounded-[20px] w-full max-w-[520px] my-8 overflow-hidden"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 20px 60px rgba(0,0,0,0.3)' }}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between px-6 py-4" style={{ borderBottom: '1px solid var(--separator)' }}>
          <h2 id="pet-form-title" className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>{isEdit ? 'Editar pet' : 'Cadastrar pet'}</h2>
          <button onClick={onClose} aria-label="Fechar" className="rounded-[8px] p-1.5 transition-colors duration-150"
            onMouseEnter={(e) => { e.currentTarget.style.background = 'var(--surface-secondary)'; }}
            onMouseLeave={(e) => { e.currentTarget.style.background = 'transparent'; }}>
            <X size={18} strokeWidth={2} style={{ color: 'var(--text-secondary)' }} />
          </button>
        </div>

        <form onSubmit={handleSubmit} noValidate className="px-6 py-5 flex flex-col gap-4">
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 rounded-[18px] overflow-hidden flex items-center justify-center flex-shrink-0"
              style={{ background: 'rgba(0,122,255,0.1)' }}>
              {shownPhoto
                ? <img src={shownPhoto} alt="Foto do pet" className="w-full h-full object-cover" />
                : <Camera size={22} strokeWidth={1.5} style={{ color: 'var(--apple-blue)' }} />}
            </div>
            <div>
              <label className="inline-block px-3 py-1.5 rounded-[9px] font-medium cursor-pointer"
                style={{ fontSize: '14px', color: 'var(--apple-blue)', background: 'var(--surface-secondary)' }}>
                {shownPhoto ? 'Trocar foto' : 'Adicionar foto'}
                <input type="file" accept="image/*" onChange={choosePhoto} className="sr-only" aria-label="Foto do pet" />
              </label>
              <p className="mt-1" style={{ fontSize: '12px', color: errors.photo ? 'var(--apple-red)' : 'var(--text-tertiary)' }}>
                {errors.photo || 'Opcional. A localização gravada na foto é removida.'}
              </p>
            </div>
          </div>

          <Field label="Nome" error={errors.name}>
            <input type="text" value={form.name} onChange={set('name')} maxLength={40}
              style={inputStyle} placeholder="Ex.: Mel" autoFocus />
          </Field>

          <Field label="Espécie" error={errors.species}>
            <Segmented options={SPECIES} value={form.species} onChange={setSpecies} />
          </Field>

          <Field label="Sexo" error={errors.gender}>
            <Segmented options={GENDERS} value={form.gender} onChange={set('gender')} />
          </Field>

          <div className="grid gap-4 sm:grid-cols-2">
            <Field label="Raça">
              <input type="text" list="new-pet-breeds" value={form.breed} onChange={set('breed')}
                style={inputStyle} disabled={!form.species}
                placeholder={form.species ? '' : 'Escolha a espécie'} />
              <datalist id="new-pet-breeds">
                {(BREEDS[form.species] || []).map((b) => <option key={b} value={b} />)}
              </datalist>
            </Field>
            <Field label="Nascimento" error={errors.birthDate}>
              <input type="date" value={form.birthDate} onChange={set('birthDate')} max={todayISO()} style={inputStyle} />
            </Field>
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <Field label="Cor / pelagem" hint="opcional">
              <input type="text" value={form.color} onChange={set('color')} style={inputStyle} placeholder="Ex.: Caramelo" />
            </Field>
            <Field label="Peso (kg)" hint="opcional" error={errors.weight}>
              <input type="number" step="0.01" min="0" value={form.weight} onChange={set('weight')} style={inputStyle} placeholder="0,00" />
            </Field>
          </div>

          <Field label="Castrado(a)">
            <Segmented options={[false, true]} value={form.isNeutered} onChange={set('isNeutered')} labels={{ false: 'Não', true: 'Sim' }} />
          </Field>

          <Field label="Microchip" hint="opcional">
            <input type="text" inputMode="numeric" value={form.chipNumber} onChange={set('chipNumber')} style={inputStyle} placeholder="Número do microchip" />
          </Field>

          <Field label="Alergias" hint="opcional, separadas por vírgula">
            <input type="text" value={form.allergies} onChange={set('allergies')} style={inputStyle} placeholder="Ex.: frango, dipirona" />
          </Field>

          <Field label="Condições crônicas" hint="opcional">
            <textarea rows={2} value={form.chronicConditions} onChange={set('chronicConditions')}
              style={{ ...inputStyle, resize: 'none' }} placeholder="Ex.: dermatite atópica" />
          </Field>

          {submitError && (
            <div className="flex items-start gap-2 rounded-[10px] px-3 py-2.5" style={{ background: 'rgba(255,59,48,0.08)' }}>
              <AlertCircle size={16} strokeWidth={2} style={{ color: 'var(--apple-red)', flexShrink: 0, marginTop: '2px' }} />
              <p style={{ fontSize: '14px', color: 'var(--apple-red)' }}>{submitError}</p>
            </div>
          )}

          <div className="flex items-center justify-end gap-2 pt-1">
            <button type="button" onClick={onClose}
              className="px-4 py-2.5 rounded-[10px] font-medium transition-colors duration-150"
              style={{ fontSize: '15px', color: 'var(--text-secondary)', background: 'var(--surface-secondary)' }}>
              Cancelar
            </button>
            <button type="submit" disabled={saving}
              className="px-5 py-2.5 rounded-[10px] font-medium transition-opacity duration-150"
              style={{ fontSize: '15px', color: '#fff', background: 'var(--apple-blue)', opacity: saving ? 0.5 : 1, cursor: saving ? 'default' : 'pointer' }}>
              {saving ? 'Salvando...' : (isEdit ? 'Salvar' : 'Cadastrar')}
            </button>
          </div>
        </form>
      </div>
    </div>,
    document.body,
  );
}
