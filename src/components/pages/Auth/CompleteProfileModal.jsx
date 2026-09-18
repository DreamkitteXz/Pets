import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { doc, setDoc, serverTimestamp } from 'firebase/firestore';
import { auth, db } from '../../../config/firebase';
import { useAuth } from '../../../context/AuthContext';
import { validateCPF, validateCRMV, formatCPF, formatCEP } from '../../../utils/validation';
import { lookupCEP } from '../../../services/addressService';
import { Stethoscope, User, ChevronDown, ChevronUp, AlertCircle } from 'lucide-react';

const SPECIALTIES = [
  'Pequenos Animais', 'Grandes Animais', 'Pets Exóticos', 'Aves',
  'Dermatologia', 'Cardiologia', 'Neurologia', 'Ortopedia',
  'Cirurgia', 'Emergência', 'Oncologia', 'Acupuntura Integrativa',
];

const formatPhone = (v) => v
  .replace(/\D/g, '')
  .replace(/(\d{2})(\d)/, '($1) $2')
  .replace(/(\d{5})(\d)/, '$1-$2')
  .replace(/(-\d{4})\d+?$/, '$1');

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

const Field = ({ label, required, error, children }) => (
  <div>
    <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, color: 'var(--text-secondary)', marginBottom: '6px' }}>
      {label} {required && <span style={{ color: 'var(--apple-red)' }}>*</span>}
    </label>
    {children}
    {error && (
      <div className="flex items-center gap-1 mt-1" style={{ fontSize: '12px', color: 'var(--apple-red)' }}>
        <AlertCircle size={12} /> {error}
      </div>
    )}
  </div>
);

const RoleOption = ({ active, icon: Icon, label, desc, onClick }) => (
  <button
    type="button"
    onClick={onClick}
    className="flex-1 flex flex-col items-center gap-2 px-4 py-4 rounded-[14px] transition-all duration-150"
    style={{
      background: active ? 'rgba(0,122,255,0.10)' : 'var(--surface-secondary)',
      border: `1.5px solid ${active ? 'var(--apple-blue)' : 'transparent'}`,
    }}
  >
    <div className="w-10 h-10 rounded-[12px] flex items-center justify-center"
      style={{ background: active ? 'var(--apple-blue)' : 'rgba(116,116,128,0.15)' }}>
      <Icon size={20} strokeWidth={1.75} style={{ color: active ? '#fff' : 'var(--text-secondary)' }} />
    </div>
    <div className="text-center">
      <div className="font-semibold" style={{ fontSize: '15px', color: active ? 'var(--apple-blue)' : 'var(--text-primary)' }}>{label}</div>
      <div style={{ fontSize: '12px', color: 'var(--text-tertiary)' }}>{desc}</div>
    </div>
  </button>
);

const CompleteProfileModal = () => {
  const navigate = useNavigate();
  const { userProfile, refreshProfile } = useAuth();

  const [role, setRole] = useState(null); // 'veterinarian' | 'tutor'
  const [form, setForm] = useState({
    name: userProfile?.name || auth.currentUser?.displayName || '',
    cpf: '',
    phone: '',
    crmv: '',
    specialties: [],
    yearsOfExperience: '',
    emergencyName: '',
    emergencyPhone: '',
    emergencyRelationship: '',
    address: { street: '', number: '', complement: '', neighborhood: '', city: '', state: '', zipCode: '' },
  });
  const [errors, setErrors] = useState({});
  const [showAddress, setShowAddress] = useState(false);
  const [cepLoading, setCepLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [submitError, setSubmitError] = useState('');

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }));
  const setAddr = (k, v) => setForm(f => ({ ...f, address: { ...f.address, [k]: v } }));

  const handleCep = async (raw) => {
    const cep = formatCEP(raw);
    setAddr('zipCode', cep);
    if (cep.replace(/\D/g, '').length === 8) {
      setCepLoading(true);
      try {
        const data = await lookupCEP(cep.replace(/\D/g, ''));
        setForm(f => ({ ...f, address: { ...f.address, ...data } }));
      } catch { /* silent — usuário pode preencher manualmente */ }
      finally { setCepLoading(false); }
    }
  };

  const toggleSpecialty = (s) => setForm(f => ({
    ...f,
    specialties: f.specialties.includes(s) ? f.specialties.filter(x => x !== s) : [...f.specialties, s],
  }));

  const validate = () => {
    const e = {};
    if (!form.name.trim()) e.name = 'Informe seu nome.';
    if (!validateCPF(form.cpf)) e.cpf = 'CPF inválido.';
    if (form.phone.replace(/\D/g, '').length < 10) e.phone = 'Telefone inválido.';
    if (role === 'veterinarian') {
      if (!validateCRMV(form.crmv)) e.crmv = 'Formato: CRMV-XX 12345';
      if (form.specialties.length === 0) e.specialties = 'Selecione ao menos uma especialidade.';
    } else if (role === 'tutor') {
      if (!form.emergencyName.trim()) e.emergencyName = 'Informe um contato de emergência.';
      if (form.emergencyPhone.replace(/\D/g, '').length < 10) e.emergencyPhone = 'Telefone do contato inválido.';
    }
    setErrors(e);
    return Object.keys(e).length === 0;
  };

  const handleSubmit = async (ev) => {
    ev.preventDefault();
    if (!role || !validate()) return;
    setSaving(true);
    setSubmitError('');

    const common = {
      name: form.name.trim(),
      cpf: form.cpf,
      phone: form.phone,
      address: form.address,
      role,
      profileCompleted: true,
      status: 'active',
      updatedAt: serverTimestamp(),
    };
    const payload = role === 'veterinarian'
      ? { ...common, crmv: form.crmv, specialties: form.specialties, yearsOfExperience: form.yearsOfExperience ? Number(form.yearsOfExperience) : 0 }
      : { ...common, pets: userProfile?.pets || [], preferredVetId: '', emergencyContact: { name: form.emergencyName, phone: form.emergencyPhone, relationship: form.emergencyRelationship } };

    try {
      const uid = auth.currentUser?.uid;
      if (!uid) throw new Error('Sessão expirada. Faça login novamente.');
      await setDoc(doc(db, 'users', uid), payload, { merge: true });
      await refreshProfile();
      navigate(role === 'veterinarian' ? '/dashboard' : '/inicio', { replace: true });
    } catch (err) {
      setSubmitError(err.message || 'Erro ao salvar. Tente novamente.');
      setSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 font-sf overflow-y-auto"
      style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(10px)', WebkitBackdropFilter: 'blur(10px)' }}>
      <div className="fade-in-up rounded-[22px] w-full max-w-[560px] my-8 overflow-hidden"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 24px 70px rgba(0,0,0,0.35)' }}>

        {/* Header */}
        <div className="px-7 pt-7 pb-5" style={{ borderBottom: '1px solid var(--separator)' }}>
          <h2 className="font-bold" style={{ fontSize: '22px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
            Complete seu perfil
          </h2>
          <p className="mt-1" style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>
            Precisamos de algumas informações para liberar o acesso ao sistema.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="px-7 py-6 flex flex-col gap-5">

          {/* Role choice */}
          <div>
            <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, color: 'var(--text-secondary)', marginBottom: '8px' }}>
              Você é... <span style={{ color: 'var(--apple-red)' }}>*</span>
            </label>
            <div className="flex gap-3">
              <RoleOption active={role === 'tutor'} icon={User} label="Tutor" desc="Dono de pets" onClick={() => setRole('tutor')} />
              <RoleOption active={role === 'veterinarian'} icon={Stethoscope} label="Veterinário" desc="Profissional" onClick={() => setRole('veterinarian')} />
            </div>
          </div>

          {role && (
            <>
              {/* Common fields */}
              <Field label="Nome completo" required error={errors.name}>
                <input type="text" value={form.name} onChange={e => set('name', e.target.value)} style={inputStyle} placeholder="Seu nome" />
              </Field>

              <div className="grid grid-cols-2 gap-4">
                <Field label="CPF" required error={errors.cpf}>
                  <input type="text" value={form.cpf} maxLength={14}
                    onChange={e => set('cpf', formatCPF(e.target.value))} style={inputStyle} placeholder="000.000.000-00" />
                </Field>
                <Field label="Telefone" required error={errors.phone}>
                  <input type="tel" value={form.phone} maxLength={15}
                    onChange={e => set('phone', formatPhone(e.target.value))} style={inputStyle} placeholder="(00) 00000-0000" />
                </Field>
              </div>

              {/* Vet-specific */}
              {role === 'veterinarian' && (
                <>
                  <div className="grid grid-cols-2 gap-4">
                    <Field label="CRMV" required error={errors.crmv}>
                      <input type="text" value={form.crmv} onChange={e => set('crmv', e.target.value.toUpperCase())}
                        style={inputStyle} placeholder="CRMV-SP 12345" />
                    </Field>
                    <Field label="Anos de experiência">
                      <input type="number" min="0" value={form.yearsOfExperience}
                        onChange={e => set('yearsOfExperience', e.target.value)} style={inputStyle} placeholder="0" />
                    </Field>
                  </div>
                  <Field label="Especialidades" required error={errors.specialties}>
                    <div className="flex flex-wrap gap-2">
                      {SPECIALTIES.map(s => {
                        const on = form.specialties.includes(s);
                        return (
                          <button key={s} type="button" onClick={() => toggleSpecialty(s)}
                            className="px-3 py-1.5 rounded-full transition-all duration-150"
                            style={{
                              fontSize: '13px', fontWeight: 500,
                              background: on ? 'rgba(0,122,255,0.12)' : 'var(--surface-secondary)',
                              color: on ? 'var(--apple-blue)' : 'var(--text-secondary)',
                              border: `1px solid ${on ? 'var(--apple-blue)' : 'transparent'}`,
                            }}>
                            {s}
                          </button>
                        );
                      })}
                    </div>
                  </Field>
                </>
              )}

              {/* Tutor-specific */}
              {role === 'tutor' && (
                <div className="flex flex-col gap-4">
                  <div style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text-secondary)' }}>Contato de emergência</div>
                  <div className="grid grid-cols-2 gap-4">
                    <Field label="Nome" required error={errors.emergencyName}>
                      <input type="text" value={form.emergencyName} onChange={e => set('emergencyName', e.target.value)} style={inputStyle} placeholder="Nome do contato" />
                    </Field>
                    <Field label="Telefone" required error={errors.emergencyPhone}>
                      <input type="tel" value={form.emergencyPhone} maxLength={15}
                        onChange={e => set('emergencyPhone', formatPhone(e.target.value))} style={inputStyle} placeholder="(00) 00000-0000" />
                    </Field>
                  </div>
                  <Field label="Parentesco / relação">
                    <input type="text" value={form.emergencyRelationship} onChange={e => set('emergencyRelationship', e.target.value)} style={inputStyle} placeholder="Ex.: Cônjuge, irmão..." />
                  </Field>
                </div>
              )}

              {/* Optional address */}
              <div>
                <button type="button" onClick={() => setShowAddress(s => !s)}
                  className="flex items-center gap-1.5 font-medium" style={{ fontSize: '14px', color: 'var(--apple-blue)' }}>
                  {showAddress ? <ChevronUp size={16} /> : <ChevronDown size={16} />} Endereço (opcional)
                </button>
                {showAddress && (
                  <div className="grid grid-cols-2 gap-4 mt-3">
                    <Field label="CEP">
                      <input type="text" value={form.address.zipCode} maxLength={9} onChange={e => handleCep(e.target.value)}
                        style={inputStyle} placeholder={cepLoading ? 'Buscando...' : '00000-000'} />
                    </Field>
                    <Field label="Rua">
                      <input type="text" value={form.address.street} onChange={e => setAddr('street', e.target.value)} style={inputStyle} />
                    </Field>
                    <Field label="Número">
                      <input type="text" value={form.address.number} onChange={e => setAddr('number', e.target.value)} style={inputStyle} />
                    </Field>
                    <Field label="Bairro">
                      <input type="text" value={form.address.neighborhood} onChange={e => setAddr('neighborhood', e.target.value)} style={inputStyle} />
                    </Field>
                    <Field label="Cidade">
                      <input type="text" value={form.address.city} onChange={e => setAddr('city', e.target.value)} style={inputStyle} />
                    </Field>
                    <Field label="Estado">
                      <input type="text" value={form.address.state} maxLength={2} onChange={e => setAddr('state', e.target.value.toUpperCase())} style={inputStyle} />
                    </Field>
                  </div>
                )}
              </div>

              {submitError && (
                <div className="flex items-center gap-2 px-3 py-2.5 rounded-[10px]"
                  style={{ background: 'rgba(255,59,48,0.08)', color: 'var(--apple-red)', fontSize: '13px' }}>
                  <AlertCircle size={14} /> {submitError}
                </div>
              )}

              <button type="submit" disabled={saving}
                className="w-full rounded-[12px] font-semibold transition-opacity duration-150"
                style={{ height: '50px', fontSize: '16px', color: '#fff', background: 'var(--apple-blue)', opacity: saving ? 0.6 : 1, cursor: saving ? 'default' : 'pointer' }}>
                {saving ? 'Salvando...' : 'Concluir e acessar'}
              </button>
            </>
          )}
        </form>
      </div>
    </div>
  );
};

export default CompleteProfileModal;
