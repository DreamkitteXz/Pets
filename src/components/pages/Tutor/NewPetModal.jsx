import React, { useState, useEffect } from 'react';
import { X, AlertCircle } from 'lucide-react';

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

const todayISO = () => new Date().toISOString().slice(0, 10);

const EMPTY = {
  name: '', species: '', gender: '', breed: SRD, birthDate: '', color: '',
  isNeutered: false, chipNumber: '', weight: '', allergies: '', chronicConditions: '',
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
 * Cadastro de pet pelo tutor. `onCreate(data)` grava e devolve o id do pet.
 */
export default function NewPetModal({ isOpen, onClose, onCreate, onCreated }) {
  const [form, setForm] = useState(EMPTY);
  const [errors, setErrors] = useState({});
  const [saving, setSaving] = useState(false);
  const [submitError, setSubmitError] = useState('');

  useEffect(() => {
    if (isOpen) {
      setForm(EMPTY);
      setErrors({});
      setSubmitError('');
      setSaving(false);
    }
  }, [isOpen]);

  if (!isOpen) return null;

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
      const id = await onCreate({
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
      });
      onCreated?.(id);
    } catch (err) {
      setSubmitError(err?.message || 'Não foi possível cadastrar o pet. Tente novamente.');
      setSaving(false);
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 font-sf overflow-y-auto"
      style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(4px)' }}
      onClick={onClose}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="new-pet-title"
        className="fade-in-up rounded-[20px] w-full max-w-[520px] my-8 overflow-hidden"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 20px 60px rgba(0,0,0,0.3)' }}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between px-6 py-4" style={{ borderBottom: '1px solid var(--separator)' }}>
          <h2 id="new-pet-title" className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>Cadastrar pet</h2>
          <button onClick={onClose} aria-label="Fechar" className="rounded-[8px] p-1.5 transition-colors duration-150"
            onMouseEnter={(e) => { e.currentTarget.style.background = 'var(--surface-secondary)'; }}
            onMouseLeave={(e) => { e.currentTarget.style.background = 'transparent'; }}>
            <X size={18} strokeWidth={2} style={{ color: 'var(--text-secondary)' }} />
          </button>
        </div>

        <form onSubmit={handleSubmit} noValidate className="px-6 py-5 flex flex-col gap-4">
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
              {saving ? 'Salvando...' : 'Cadastrar'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
