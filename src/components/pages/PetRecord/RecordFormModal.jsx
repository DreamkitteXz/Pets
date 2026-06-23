import React, { useState } from 'react';
import { X } from 'lucide-react';

const todayISO = () => new Date().toISOString().slice(0, 10);

const Field = ({ label, children }) => (
  <div>
    <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, color: 'var(--text-secondary)', marginBottom: '6px' }}>
      {label}
    </label>
    {children}
  </div>
);

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

/**
 * Modal to add a record. `type` is 'consulta' or 'peso'.
 * To support a new record type, add a branch returning its fields + initial state.
 */
export default function RecordFormModal({ isOpen, onClose, type, onSubmit }) {
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState({});

  React.useEffect(() => {
    if (isOpen) {
      setForm(type === 'peso'
        ? { weight: '', date: todayISO(), notes: '' }
        : { date: todayISO(), motivo: '', diagnostico: '', observacoes: '' });
    }
  }, [isOpen, type]);

  if (!isOpen) return null;

  const set = (k) => (e) => setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await onSubmit(form);
      onClose();
    } finally {
      setSaving(false);
    }
  };

  const title = type === 'peso' ? 'Registrar peso' : 'Nova consulta';
  const valid = type === 'peso' ? Number(form.weight) > 0 : (form.motivo || '').trim().length > 0;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 font-sf"
      style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(4px)' }}
      onClick={onClose}
    >
      <div
        className="fade-in-up rounded-[20px] w-full max-w-[460px] overflow-hidden"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 20px 60px rgba(0,0,0,0.3)' }}
        onClick={e => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4" style={{ borderBottom: '1px solid var(--separator)' }}>
          <h2 className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>{title}</h2>
          <button onClick={onClose} className="rounded-[8px] p-1.5 transition-colors duration-150"
            onMouseEnter={e => e.currentTarget.style.background = 'var(--surface-secondary)'}
            onMouseLeave={e => e.currentTarget.style.background = 'transparent'}>
            <X size={18} strokeWidth={2} style={{ color: 'var(--text-secondary)' }} />
          </button>
        </div>

        {/* Body */}
        <form onSubmit={handleSubmit} className="px-6 py-5 flex flex-col gap-4">
          {type === 'peso' ? (
            <>
              <Field label="Peso (kg)">
                <input type="number" step="0.01" min="0" placeholder="0.00"
                  value={form.weight || ''} onChange={set('weight')} style={inputStyle} autoFocus />
              </Field>
              <Field label="Data">
                <input type="date" value={form.date || ''} onChange={set('date')} style={inputStyle} />
              </Field>
              <Field label="Observações (opcional)">
                <textarea rows={2} value={form.notes || ''} onChange={set('notes')}
                  style={{ ...inputStyle, resize: 'none' }} placeholder="Ex.: pesagem em jejum" />
              </Field>
            </>
          ) : (
            <>
              <Field label="Data">
                <input type="date" value={form.date || ''} onChange={set('date')} style={inputStyle} />
              </Field>
              <Field label="Motivo">
                <input type="text" value={form.motivo || ''} onChange={set('motivo')}
                  style={inputStyle} placeholder="Ex.: Consulta de rotina" autoFocus />
              </Field>
              <Field label="Diagnóstico">
                <input type="text" value={form.diagnostico || ''} onChange={set('diagnostico')}
                  style={inputStyle} placeholder="Ex.: Saudável" />
              </Field>
              <Field label="Observações">
                <textarea rows={3} value={form.observacoes || ''} onChange={set('observacoes')}
                  style={{ ...inputStyle, resize: 'none' }} placeholder="Anotações clínicas, conduta, prescrição..." />
              </Field>
            </>
          )}

          {/* Footer */}
          <div className="flex items-center justify-end gap-2 pt-1">
            <button type="button" onClick={onClose}
              className="px-4 py-2.5 rounded-[10px] font-medium transition-colors duration-150"
              style={{ fontSize: '15px', color: 'var(--text-secondary)', background: 'var(--surface-secondary)' }}>
              Cancelar
            </button>
            <button type="submit" disabled={!valid || saving}
              className="px-5 py-2.5 rounded-[10px] font-medium transition-opacity duration-150"
              style={{ fontSize: '15px', color: '#fff', background: 'var(--apple-blue)', opacity: (!valid || saving) ? 0.5 : 1, cursor: (!valid || saving) ? 'default' : 'pointer' }}>
              {saving ? 'Salvando...' : 'Salvar'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
