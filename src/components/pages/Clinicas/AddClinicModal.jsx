import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { httpsCallable } from 'firebase/functions';
import { X, AlertCircle, Check } from 'lucide-react';
import { functions } from '../../../config/firebase';
import { lookupCEP } from '../../../services/addressService';
import { formatCEP, formatCNPJ, formatPhoneBR, validateCNPJ } from '../../../utils/validation';

// Cadastro manual, gravado pelo servidor (o cliente não cria clínica direto —
// ver firestore.rules). O endereço vira ponto no mapa pela CF geocodeClinic.
const addManual = httpsCallable(functions, 'createClinicManual', { timeout: 20000 });
const joinFn    = httpsCallable(functions, 'joinClinic', { timeout: 20000 });

const inputStyle = {
  width: '100%', fontSize: '16px', padding: '10px 14px', borderRadius: '12px',
  background: 'var(--surface-secondary)', color: 'var(--text-primary)', border: 'none', outline: 'none',
};
const Label = ({ children, required }) => (
  <span style={{ display: 'block', fontSize: '13px', fontWeight: 600, color: 'var(--text-secondary)', marginBottom: '6px' }}>
    {children}{required && <span style={{ color: 'var(--apple-red)' }}> *</span>}
  </span>
);

const EMPTY = { name: '', cnpj: '', phone: '', email: '', address: { zipCode: '', street: '', number: '', complement: '', neighborhood: '', city: '', state: '' } };

function ManualTab({ onAdded }) {
  const [form, setForm] = useState(EMPTY);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [existingId, setExistingId] = useState(null);
  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }));
  const setAddr = (k, v) => setForm((f) => ({ ...f, address: { ...f.address, [k]: v } }));

  const onCep = async (raw) => {
    const cep = formatCEP(raw);
    setAddr('zipCode', cep);
    if (cep.replace(/\D/g, '').length === 8) {
      try {
        const data = await lookupCEP(cep.replace(/\D/g, ''));
        setForm((f) => ({ ...f, address: { ...f.address, ...data, zipCode: cep } }));
      } catch { /* preenche à mão */ }
    }
  };

  const submit = async (e) => {
    e.preventDefault();
    setError('');
    setExistingId(null);
    if (form.cnpj && !validateCNPJ(form.cnpj)) { setError('CNPJ inválido.'); return; }
    setSaving(true);
    try {
      await addManual(form);
      onAdded(form.name);
    } catch (err) {
      setError(err?.message || 'Não foi possível cadastrar.');
      if (err?.details?.clinicId) setExistingId(err.details.clinicId);
      setSaving(false);
    }
  };

  const join = async () => {
    setSaving(true);
    try {
      await joinFn({ clinicId: existingId });
      onAdded(form.name);
    } catch (err) {
      setError(err?.message || 'Não foi possível entrar na clínica.');
      setSaving(false);
    }
  };

  const a = form.address;
  return (
    <form onSubmit={submit} className="flex flex-col gap-3.5">
      <label><Label required>Nome da clínica</Label>
        <input value={form.name} onChange={set('name')} style={inputStyle} maxLength={100} placeholder="Ex.: Clínica Veterinária Bem-Estar" />
      </label>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3.5">
        <label><Label>CNPJ</Label>
          <input value={form.cnpj} onChange={(e) => setForm((f) => ({ ...f, cnpj: formatCNPJ(e.target.value) }))} style={inputStyle} inputMode="numeric" placeholder="00.000.000/0000-00" />
        </label>
        <label><Label>Telefone</Label>
          <input value={form.phone} onChange={(e) => setForm((f) => ({ ...f, phone: formatPhoneBR(e.target.value) }))} style={inputStyle} inputMode="tel" placeholder="(00) 0000-0000" />
        </label>
      </div>
      <label><Label>E-mail</Label>
        <input type="email" value={form.email} onChange={set('email')} style={inputStyle} maxLength={120} placeholder="contato@clinica.com.br" />
      </label>
      <div className="grid grid-cols-2 md:grid-cols-3 gap-3.5">
        <label><Label>CEP</Label>
          <input value={a.zipCode} onChange={(e) => onCep(e.target.value)} style={inputStyle} inputMode="numeric" placeholder="00000-000" />
        </label>
        <label className="col-span-2"><Label required>Rua</Label>
          <input value={a.street} onChange={(e) => setAddr('street', e.target.value)} style={inputStyle} maxLength={120} />
        </label>
        <label><Label>Número</Label>
          <input value={a.number} onChange={(e) => setAddr('number', e.target.value)} style={inputStyle} maxLength={10} />
        </label>
        <label className="col-span-2 md:col-span-2"><Label>Bairro</Label>
          <input value={a.neighborhood} onChange={(e) => setAddr('neighborhood', e.target.value)} style={inputStyle} maxLength={80} />
        </label>
        <label className="col-span-2 md:col-span-2"><Label required>Cidade</Label>
          <input value={a.city} onChange={(e) => setAddr('city', e.target.value)} style={inputStyle} maxLength={80} />
        </label>
        <label><Label required>UF</Label>
          <input value={a.state} onChange={(e) => setAddr('state', e.target.value.toUpperCase().slice(0, 2))} style={inputStyle} placeholder="MG" />
        </label>
      </div>

      {error && (
        <div className="flex flex-col items-start gap-2">
          <p className="flex items-start gap-1.5" style={{ fontSize: '13px', color: 'var(--apple-red)' }}>
            <AlertCircle size={14} style={{ flexShrink: 0, marginTop: '2px' }} /> {error}
          </p>
          {existingId && (
            <button type="button" onClick={join} disabled={saving} className="px-3.5 py-2 rounded-[10px] font-semibold"
              style={{ fontSize: '14px', color: '#fff', background: 'var(--apple-blue)' }}>
              Entrar nesta clínica
            </button>
          )}
        </div>
      )}

      <button type="submit" disabled={saving || form.name.trim().length < 3 || !a.street.trim() || !a.city.trim() || a.state.length !== 2}
        className="mt-1 px-4 py-3 rounded-[12px] font-semibold"
        style={{ fontSize: '15px', color: '#fff', background: 'var(--apple-blue)', opacity: saving || form.name.trim().length < 3 || !a.street.trim() || !a.city.trim() || a.state.length !== 2 ? 0.5 : 1 }}>
        {saving ? 'Salvando…' : 'Cadastrar clínica'}
      </button>
    </form>
  );
}

export default function AddClinicModal({ onClose, onAdded }) {
  const [done, setDone] = useState('');

  const handleAdded = (name) => {
    setDone(name);
    onAdded?.();
  };

  return createPortal(
    <div className="fixed inset-0 z-50 modal-overlay p-4 font-sf"
      style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(8px)', WebkitBackdropFilter: 'blur(8px)' }}
      onClick={onClose}>
      <div role="dialog" aria-modal="true" aria-labelledby="add-clinic-title"
        className="fade-in-up w-full max-w-[600px] rounded-[20px] overflow-hidden"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 24px 70px rgba(0,0,0,0.35)' }}
        onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-6 py-5" style={{ borderBottom: '1px solid var(--separator)' }}>
          <h2 id="add-clinic-title" className="font-bold" style={{ fontSize: '19px', color: 'var(--text-primary)' }}>Adicionar clínica</h2>
          <button type="button" onClick={onClose} aria-label="Fechar" className="rounded-[8px] p-1.5">
            <X size={18} style={{ color: 'var(--text-secondary)' }} />
          </button>
        </div>
        <div className="px-6 py-5 flex flex-col gap-4">
          {done ? (
            <div className="flex flex-col items-center text-center gap-3 py-6">
              <div className="w-12 h-12 rounded-full flex items-center justify-center" style={{ background: 'rgba(52,199,89,0.14)' }}>
                <Check size={24} style={{ color: 'var(--apple-green)' }} />
              </div>
              <p className="font-semibold" style={{ fontSize: '16px', color: 'var(--text-primary)' }}>{done} foi adicionada às suas clínicas.</p>
              <button type="button" onClick={onClose} className="px-4 py-2.5 rounded-[12px] font-semibold"
                style={{ fontSize: '15px', color: '#fff', background: 'var(--apple-blue)' }}>Concluir</button>
            </div>
          ) : (
            <ManualTab onAdded={handleAdded} />
          )}
        </div>
      </div>
    </div>,
    document.body,
  );
}
