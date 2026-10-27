import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { httpsCallable } from 'firebase/functions';
import { X, Search, MapPin, Phone, Globe, AlertCircle, Check } from 'lucide-react';
import { functions } from '../../../config/firebase';
import { useAuth } from '../../../context/AuthContext';
import { lookupCEP } from '../../../services/addressService';
import { formatCEP, formatCNPJ, formatPhoneBR, validateCNPJ } from '../../../utils/validation';

// Tudo passa pelo servidor: a busca no Google (chave secreta, só vet aprovado)
// e a gravação (o cliente não cria clínica direto — ver firestore.rules).
const searchFn  = httpsCallable(functions, 'searchClinicsOnMaps', { timeout: 20000 });
const addGoogle = httpsCallable(functions, 'addClinicFromGoogle', { timeout: 20000 });
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

function GoogleTab({ onAdded }) {
  const { userProfile } = useAuth();
  const [query, setQuery] = useState('');
  const [city, setCity] = useState(userProfile?.address?.city || '');
  const [results, setResults] = useState(null);
  const [searching, setSearching] = useState(false);
  const [busyId, setBusyId] = useState(null);
  const [error, setError] = useState('');

  const search = async (e) => {
    e.preventDefault();
    if (query.trim().length < 2) return;
    setSearching(true);
    setError('');
    try {
      const res = await searchFn({ query: query.trim(), city: city.trim() });
      setResults(res.data.results);
    } catch (err) {
      // Função ainda não publicada (chave do Google pendente) → orienta o manual.
      const offline = ['functions/not-found', 'functions/internal'].includes(err?.code);
      setError(offline
        ? 'A busca no Google está indisponível no momento. Use “Cadastrar manualmente”.'
        : err?.message || 'A busca falhou.');
    } finally {
      setSearching(false);
    }
  };

  const add = async (r) => {
    setBusyId(r.googlePlaceId);
    setError('');
    try {
      if (r.clinicId) await joinFn({ clinicId: r.clinicId });
      else await addGoogle({ placeId: r.googlePlaceId });
      onAdded(r.name);
    } catch (err) {
      setError(err?.message || 'Não foi possível adicionar.');
      setBusyId(null);
    }
  };

  return (
    <div className="flex flex-col gap-4">
      <form onSubmit={search} className="flex flex-col md:flex-row gap-2">
        <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Nome da clínica ou bairro"
          aria-label="Nome da clínica ou bairro" style={inputStyle} maxLength={80} autoFocus />
        <input value={city} onChange={(e) => setCity(e.target.value)} placeholder="Cidade"
          aria-label="Cidade" style={{ ...inputStyle }} className="md:max-w-[180px]" maxLength={60} />
        <button type="submit" disabled={searching || query.trim().length < 2}
          className="px-4 py-2.5 rounded-[12px] font-semibold flex items-center justify-center gap-1.5 flex-shrink-0"
          style={{ fontSize: '15px', color: '#fff', background: 'var(--apple-blue)', opacity: searching || query.trim().length < 2 ? 0.5 : 1 }}>
          <Search size={15} /> {searching ? 'Buscando…' : 'Buscar'}
        </button>
      </form>

      {error && (
        <p className="flex items-start gap-1.5" style={{ fontSize: '13px', color: 'var(--apple-red)' }}>
          <AlertCircle size={14} style={{ flexShrink: 0, marginTop: '2px' }} /> {error}
        </p>
      )}

      {results && results.length === 0 && (
        <p style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>
          Nenhuma clínica veterinária encontrada no Google. Tente outro nome ou use “Cadastrar manualmente”.
        </p>
      )}

      {results?.length > 0 && (
        <ul className="flex flex-col gap-2">
          {results.map((r) => (
            <li key={r.googlePlaceId} className="rounded-[14px] p-3.5 flex flex-col md:flex-row md:items-center gap-3"
              style={{ background: 'var(--surface-secondary)' }}>
              <div className="flex-1 min-w-0">
                <p className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{r.name}</p>
                <p className="flex items-start gap-1" style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                  <MapPin size={13} style={{ flexShrink: 0, marginTop: '3px' }} /> {r.formattedAddress || '—'}
                </p>
                <p className="flex flex-wrap gap-x-3" style={{ fontSize: '13px', color: 'var(--text-tertiary)' }}>
                  {r.phone && <span className="inline-flex items-center gap-1"><Phone size={12} /> {r.phone}</span>}
                  {r.website && <span className="inline-flex items-center gap-1 truncate"><Globe size={12} /> {r.website.replace(/^https?:\/\//, '').replace(/\/$/, '')}</span>}
                </p>
              </div>
              {r.isMember ? (
                <span className="inline-flex items-center gap-1 font-semibold flex-shrink-0" style={{ fontSize: '14px', color: 'var(--apple-green)' }}>
                  <Check size={15} /> Você já faz parte
                </span>
              ) : (
                <button type="button" onClick={() => add(r)} disabled={!!busyId}
                  className="px-3.5 py-2 rounded-[10px] font-semibold flex-shrink-0"
                  style={{ fontSize: '14px', color: '#fff', background: 'var(--apple-blue)', opacity: busyId ? 0.5 : 1 }}>
                  {busyId === r.googlePlaceId ? 'Adicionando…' : r.clinicId ? 'Entrar nesta clínica' : 'Adicionar'}
                </button>
              )}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

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
  const [tab, setTab] = useState('google');
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
            <>
              <div role="tablist" className="flex gap-1 p-1 rounded-[12px] w-full md:w-auto md:self-start" style={{ background: 'var(--surface-secondary)' }}>
                {[['google', 'Buscar no Google', 'No Google'], ['manual', 'Cadastrar manualmente', 'Manual']].map(([id, label, short]) => (
                  <button key={id} type="button" role="tab" aria-selected={tab === id} aria-label={label} onClick={() => setTab(id)}
                    className="flex-1 md:flex-none px-3.5 py-2 rounded-[9px] font-semibold whitespace-nowrap"
                    style={{
                      fontSize: '14px',
                      background: tab === id ? 'var(--surface-grouped-secondary)' : 'transparent',
                      color: tab === id ? 'var(--text-primary)' : 'var(--text-secondary)',
                      boxShadow: tab === id ? '0 1px 2px rgba(0,0,0,0.08)' : 'none',
                    }}>
                    <span className="hidden md:inline">{label}</span>
                    <span className="md:hidden">{short}</span>
                  </button>
                ))}
              </div>
              {tab === 'google' ? <GoogleTab onAdded={handleAdded} /> : <ManualTab onAdded={handleAdded} />}
            </>
          )}
        </div>
      </div>
    </div>,
    document.body,
  );
}
