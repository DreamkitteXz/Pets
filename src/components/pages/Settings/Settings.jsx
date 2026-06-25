import React, { useState, useEffect } from 'react';
import { useUser } from '../../../hooks/useUser';
import { useTheme } from '../../../context/ThemeContext';
import { User, MapPin, Stethoscope, Sliders, ChevronRight } from 'lucide-react';

// ── Apple-style input ──────────────────────────────────────────────────────
const Field = ({ label, children }) => (
  <div>
    <label style={{ display: 'block', fontSize: '13px', fontWeight: '600', color: 'var(--text-secondary)', marginBottom: '6px' }}>
      {label}
    </label>
    {children}
  </div>
);

const Input = ({ ...props }) => (
  <input
    {...props}
    className="w-full outline-none transition-shadow duration-200"
    style={{
      background: 'var(--surface-secondary)',
      borderRadius: '10px',
      padding: '12px 14px',
      fontSize: '15px',
      color: 'var(--text-primary)',
      border: 'none',
    }}
    onFocus={e => e.currentTarget.style.boxShadow = `0 0 0 3px rgba(0,122,255,0.25)`}
    onBlur={e => e.currentTarget.style.boxShadow = 'none'}
  />
);

const SelectInput = ({ children, ...props }) => (
  <select
    {...props}
    className="w-full outline-none transition-shadow duration-200"
    style={{
      background: 'var(--surface-secondary)',
      borderRadius: '10px',
      padding: '12px 14px',
      fontSize: '15px',
      color: 'var(--text-primary)',
      border: 'none',
      appearance: 'none',
    }}
    onFocus={e => e.currentTarget.style.boxShadow = `0 0 0 3px rgba(0,122,255,0.25)`}
    onBlur={e => e.currentTarget.style.boxShadow = 'none'}
  >
    {children}
  </select>
);

// ── Apple Toggle ───────────────────────────────────────────────────────────
const Toggle = ({ checked, onChange, name }) => (
  <label className="apple-toggle cursor-pointer">
    <input type="checkbox" name={name} checked={checked} onChange={onChange} />
    <div className="apple-toggle__track">
      <div className="apple-toggle__thumb" />
    </div>
  </label>
);

// ── Toggle row in system settings ──────────────────────────────────────────
const ToggleRow = ({ label, sublabel, name, checked, onChange, isLast }) => (
  <div
    className="flex items-center justify-between px-5"
    style={{
      paddingTop: '14px',
      paddingBottom: '14px',
      borderBottom: isLast ? 'none' : '1px solid var(--separator)',
    }}
  >
    <div>
      <div style={{ fontSize: '15px', color: 'var(--text-primary)', fontWeight: '400' }}>{label}</div>
      {sublabel && <div style={{ fontSize: '13px', color: 'var(--text-secondary)', marginTop: '2px' }}>{sublabel}</div>}
    </div>
    <Toggle name={name} checked={checked} onChange={onChange} />
  </div>
);

// ── Tabs ──────────────────────────────────────────────────────────────────
const TABS = [
  { id: 'profile',      label: 'Perfil',     icon: User },
  { id: 'address',      label: 'Endereço',   icon: MapPin },
  { id: 'professional', label: 'Profissional', icon: Stethoscope },
  { id: 'system',       label: 'Sistema',    icon: Sliders },
];

// ── Page ──────────────────────────────────────────────────────────────────
const Settings = () => {
  const [activeTab, setActiveTab] = useState('profile');
  const { userData, loading, updateUserData } = useUser();
  const { setDark } = useTheme();
  const [role, setRole] = useState('veterinarian');
  const [formData, setFormData] = useState({
    name: '', email: '', phone: '', cpf: '',
    street: '', number: '', complement: '', neighborhood: '', city: '', state: '', zipCode: '',
    crmv: '', specialties: [], yearsOfExperience: 0,
    notifications: false, darkMode: false, language: 'pt-BR', twoFactorAuth: false,
  });

  useEffect(() => {
    if (userData) {
      setFormData({
        name: userData.name || '', email: userData.email || '', phone: userData.phone || '', cpf: userData.cpf || '',
        street: userData.address?.street || '', number: userData.address?.number || '',
        complement: userData.address?.complement || '', neighborhood: userData.address?.neighborhood || '',
        city: userData.address?.city || '', state: userData.address?.state || '', zipCode: userData.address?.zipCode || '',
        crmv: userData.crmv || '', specialties: userData.specialties || [],
        yearsOfExperience: userData.yearsOfExperience || 0,
        notifications: userData.notifications || false, darkMode: userData.darkMode || false,
        language: userData.language || 'pt-BR', twoFactorAuth: userData.twoFactorAuth || false,
      });
      setRole(userData.role || 'veterinarian');
    }
  }, [userData]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    const newValue = type === 'checkbox' ? checked : value;
    setFormData(prev => ({ ...prev, [name]: newValue }));
    // Apply dark mode instantly — no need to wait for Firestore save
    if (name === 'darkMode') setDark(newValue);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const success = await updateUserData(formData);
    if (success) alert('Configurações salvas com sucesso!');
    else alert('Erro ao salvar. Tente novamente.');
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 rounded-full border-2 border-transparent animate-spin" style={{ borderTopColor: 'var(--apple-blue)' }} />
      </div>
    );
  }

  const activeTabLabel = TABS.find(t => t.id === activeTab)?.label || '';

  return (
    <div className="min-h-full font-sf">

      {/* Page header */}
      <div className="mb-6 fade-in-up">
        <h1 className="font-bold" style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
          Configurações
        </h1>
      </div>

      <div className="flex gap-6 items-start">

        {/* ── Sidebar tabs ──────────────────────────────────────────────── */}
        <div
          className="fade-in-up rounded-[16px] overflow-hidden w-[200px] flex-shrink-0 hidden md:block"
          style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)', animationDelay: '50ms' }}
        >
          {TABS.map(({ id, label, icon: Icon }, i) => {
            const isActive = activeTab === id;
            const isLast = i === TABS.length - 1;
            return (
              <button
                key={id}
                onClick={() => setActiveTab(id)}
                className="w-full flex items-center gap-3 px-4 transition-colors duration-100"
                style={{
                  padding: '12px 16px',
                  borderBottom: isLast ? 'none' : '1px solid var(--separator)',
                  background: isActive ? 'rgba(0,122,255,0.08)' : 'transparent',
                  color: isActive ? 'var(--apple-blue)' : 'var(--text-primary)',
                  fontSize: '15px',
                  fontWeight: isActive ? '600' : '400',
                  textAlign: 'left',
                }}
                onMouseEnter={e => { if (!isActive) e.currentTarget.style.background = 'rgba(116,116,128,0.06)'; }}
                onMouseLeave={e => { if (!isActive) e.currentTarget.style.background = 'transparent'; }}
              >
                <Icon size={16} strokeWidth={1.5} style={{ flexShrink: 0 }} />
                {label}
                {isActive && <ChevronRight size={14} strokeWidth={2} style={{ marginLeft: 'auto', opacity: 0.5 }} />}
              </button>
            );
          })}
        </div>

        {/* ── Mobile tabs ──────────────────────────────────────────────── */}
        <div className="md:hidden flex gap-1 mb-4 p-1 rounded-[12px] w-full"
          style={{ background: 'var(--surface-secondary)' }}>
          {TABS.map(({ id, label }) => (
            <button
              key={id}
              onClick={() => setActiveTab(id)}
              className="flex-1 py-1.5 rounded-[8px] text-[13px] font-medium transition-all duration-150"
              style={{
                background: activeTab === id ? 'var(--surface-primary)' : 'transparent',
                color: activeTab === id ? 'var(--text-primary)' : 'var(--text-secondary)',
                boxShadow: activeTab === id ? '0 1px 3px rgba(0,0,0,0.1)' : 'none',
              }}
            >
              {label}
            </button>
          ))}
        </div>

        {/* ── Form content ─────────────────────────────────────────────── */}
        <div className="fade-in-up flex-1 min-w-0" style={{ animationDelay: '100ms' }}>
          <form onSubmit={handleSubmit}>

            {/* Section header */}
            <p className="font-semibold mb-4 md:hidden" style={{ fontSize: '13px', color: 'var(--text-secondary)', textTransform: 'uppercase', letterSpacing: '0.06em' }}>
              {activeTabLabel}
            </p>

            {/* ── Profile tab ─────────────────────────────────────────── */}
            {activeTab === 'profile' && (
              <div className="space-y-4">
                {/* Avatar */}
                <div
                  className="rounded-[16px] p-6 flex items-center gap-5"
                  style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}
                >
                  <div
                    className="w-20 h-20 rounded-full flex items-center justify-center font-bold text-[28px] text-white flex-shrink-0"
                    style={{ background: 'var(--apple-blue)' }}
                  >
                    {formData.name?.[0]?.toUpperCase() || 'V'}
                  </div>
                  <div>
                    <p className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>{formData.name || 'Seu nome'}</p>
                    <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginTop: '2px' }}>{formData.email}</p>
                    <button type="button" className="mt-3 font-medium transition-opacity duration-150"
                      style={{ fontSize: '15px', color: 'var(--apple-blue)' }}
                      onMouseEnter={e => e.currentTarget.style.opacity = '0.7'}
                      onMouseLeave={e => e.currentTarget.style.opacity = '1'}>
                      Enviar foto
                    </button>
                  </div>
                </div>

                {/* Fields */}
                <div
                  className="rounded-[16px] p-5 grid grid-cols-1 md:grid-cols-2 gap-4"
                  style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}
                >
                  <Field label="Nome completo"><Input type="text" name="name" value={formData.name} onChange={handleChange} /></Field>
                  <Field label="E-mail"><Input type="email" name="email" value={formData.email} onChange={handleChange} /></Field>
                  <Field label="Telefone"><Input type="text" name="phone" value={formData.phone} onChange={handleChange} /></Field>
                  <Field label="CPF"><Input type="text" name="cpf" value={formData.cpf} onChange={handleChange} /></Field>
                </div>

                {/* Role */}
                <div className="rounded-[16px] p-5" style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}>
                  <p className="font-semibold mb-3" style={{ fontSize: '13px', color: 'var(--text-secondary)', textTransform: 'uppercase', letterSpacing: '0.06em' }}>Tipo de Conta</p>
                  <div className="flex gap-3">
                    {['veterinarian', 'tutor'].map(r => (
                      <label key={r} className="flex items-center gap-2 cursor-pointer">
                        <input type="radio" name="role" checked={role === r} onChange={() => setRole(r)}
                          className="accent-[--apple-blue]" style={{ accentColor: 'var(--apple-blue)' }} />
                        <span style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{r === 'veterinarian' ? 'Veterinário' : 'Tutor de Pet'}</span>
                      </label>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {/* ── Address tab ─────────────────────────────────────────── */}
            {activeTab === 'address' && (
              <div
                className="rounded-[16px] p-5 grid grid-cols-1 md:grid-cols-2 gap-4"
                style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}
              >
                <Field label="Rua"><Input type="text" name="street" value={formData.street} onChange={handleChange} /></Field>
                <div className="grid grid-cols-2 gap-3">
                  <Field label="Número"><Input type="text" name="number" value={formData.number} onChange={handleChange} /></Field>
                  <Field label="Complemento"><Input type="text" name="complement" value={formData.complement} onChange={handleChange} /></Field>
                </div>
                <Field label="Bairro"><Input type="text" name="neighborhood" value={formData.neighborhood} onChange={handleChange} /></Field>
                <Field label="CEP"><Input type="text" name="zipCode" value={formData.zipCode} onChange={handleChange} /></Field>
                <Field label="Cidade"><Input type="text" name="city" value={formData.city} onChange={handleChange} /></Field>
                <Field label="Estado">
                  <SelectInput name="state" value={formData.state} onChange={handleChange}>
                    {['AC','AL','AM','AP','BA','CE','DF','ES','GO','MA','MG','MS','MT','PA','PB','PE','PI','PR','RJ','RN','RO','RR','RS','SC','SE','SP','TO'].map(s => (
                      <option key={s} value={s}>{s}</option>
                    ))}
                  </SelectInput>
                </Field>
              </div>
            )}

            {/* ── Professional tab ─────────────────────────────────────── */}
            {activeTab === 'professional' && role === 'veterinarian' && (
              <div className="space-y-4">
                <div
                  className="rounded-[16px] p-5 grid grid-cols-1 md:grid-cols-2 gap-4"
                  style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}
                >
                  <Field label="CRMV"><Input type="text" name="crmv" value={formData.crmv} onChange={handleChange} /></Field>
                  <Field label="Anos de Experiência"><Input type="number" name="yearsOfExperience" value={formData.yearsOfExperience} onChange={handleChange} /></Field>
                </div>

                <div className="rounded-[16px] p-5" style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}>
                  <p className="font-semibold mb-3" style={{ fontSize: '13px', color: 'var(--text-secondary)', textTransform: 'uppercase', letterSpacing: '0.06em' }}>Especialidades</p>
                  <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
                    {['Dermatology', 'Surgery', 'Cardiology', 'Oncology', 'Neurology', 'Orthopedics'].map(s => (
                      <label key={s} className="flex items-center gap-2 cursor-pointer p-3 rounded-[10px] transition-colors duration-100"
                        style={{ background: formData.specialties.includes(s) ? 'rgba(0,122,255,0.1)' : 'var(--surface-secondary)' }}>
                        <input
                          type="checkbox"
                          checked={formData.specialties.includes(s)}
                          onChange={e => setFormData(prev => ({
                            ...prev,
                            specialties: e.target.checked ? [...prev.specialties, s] : prev.specialties.filter(x => x !== s),
                          }))}
                          style={{ accentColor: 'var(--apple-blue)' }}
                        />
                        <span style={{ fontSize: '14px', color: formData.specialties.includes(s) ? 'var(--apple-blue)' : 'var(--text-primary)' }}>{s}</span>
                      </label>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'professional' && role === 'tutor' && (
              <div className="rounded-[16px] p-5 space-y-4" style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}>
                <p className="font-semibold" style={{ fontSize: '13px', color: 'var(--text-secondary)', textTransform: 'uppercase', letterSpacing: '0.06em' }}>Contato de Emergência</p>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <Field label="Nome"><Input type="text" name="emergencyContactName" value={formData.emergencyContactName || ''} onChange={handleChange} /></Field>
                  <Field label="Telefone"><Input type="text" name="emergencyContactPhone" value={formData.emergencyContactPhone || ''} onChange={handleChange} /></Field>
                  <Field label="Relação"><Input type="text" name="emergencyContactRelationship" value={formData.emergencyContactRelationship || ''} onChange={handleChange} /></Field>
                </div>
              </div>
            )}

            {/* ── System tab ───────────────────────────────────────────── */}
            {activeTab === 'system' && (
              <div className="space-y-4">
                <div className="rounded-[16px] overflow-hidden" style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}>
                  <ToggleRow label="Notificações" sublabel="Receba alertas de vacinação e consultas" name="notifications" checked={formData.notifications} onChange={handleChange} />
                  <ToggleRow label="Modo Escuro" sublabel="Aparência escura para a interface" name="darkMode" checked={formData.darkMode} onChange={handleChange} />
                  <ToggleRow label="Autenticação em 2 Fatores" sublabel="Segurança adicional no login" name="twoFactorAuth" checked={formData.twoFactorAuth} onChange={handleChange} isLast />
                </div>

                <div className="rounded-[16px] p-5" style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}>
                  <Field label="Idioma">
                    <SelectInput name="language" value={formData.language} onChange={handleChange}>
                      <option value="pt-BR">Português (Brasil)</option>
                      <option value="en-US">English (US)</option>
                      <option value="es-ES">Español</option>
                    </SelectInput>
                  </Field>
                </div>
              </div>
            )}

            {/* ── Action buttons ────────────────────────────────────────── */}
            <div className="flex justify-end gap-3 mt-6">
              <button
                type="button"
                className="px-5 py-2.5 rounded-[10px] font-medium transition-all duration-150 active:scale-[0.97]"
                style={{ background: 'var(--surface-secondary)', color: 'var(--text-primary)', fontSize: '15px' }}
                onMouseEnter={e => e.currentTarget.style.background = 'var(--apple-gray-5)'}
                onMouseLeave={e => e.currentTarget.style.background = 'var(--surface-secondary)'}
              >
                Cancelar
              </button>
              <button
                type="submit"
                className="px-5 py-2.5 rounded-[10px] font-semibold text-white transition-all duration-150 active:scale-[0.97]"
                style={{ background: 'var(--apple-blue)', fontSize: '15px', boxShadow: '0 4px 12px rgba(0,122,255,0.3)' }}
                onMouseEnter={e => e.currentTarget.style.filter = 'brightness(1.08)'}
                onMouseLeave={e => e.currentTarget.style.filter = 'none'}
              >
                Salvar
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Settings;
