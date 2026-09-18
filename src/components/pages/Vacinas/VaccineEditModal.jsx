import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';
import { toDate } from '../../../utils/dates';

const toInputDate = (v) => {
  const d = toDate(v);
  return d ? d.toISOString().slice(0, 10) : '';
};

// Edição de campos clínicos da vacina. Só deve ser aberta enquanto o registro
// está 'pending' — após validação, as regras do Firestore bloqueiam a alteração.
const VaccineEditModal = ({ isOpen, onClose, vaccine, onSave }) => {
  const [formData, setFormData] = useState(null);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (vaccine) {
      setFormData({
        name: vaccine.name || '',
        manufacturer: vaccine.manufacturer || '',
        batchNumber: vaccine.batchNumber || '',
        expirationDate: toInputDate(vaccine.expirationDate),
        administrationDate: toInputDate(vaccine.administrationDate),
        nextDueDate: toInputDate(vaccine.nextDueDate),
        notes: vaccine.notes || '',
      });
    }
  }, [vaccine]);

  if (!isOpen || !vaccine || !formData) return null;

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await onSave({
        name: formData.name,
        manufacturer: formData.manufacturer,
        batchNumber: formData.batchNumber,
        notes: formData.notes,
        ...(formData.administrationDate ? { administrationDate: new Date(formData.administrationDate) } : {}),
        ...(formData.expirationDate ? { expirationDate: new Date(formData.expirationDate) } : {}),
        ...(formData.nextDueDate ? { nextDueDate: new Date(formData.nextDueDate) } : {}),
      });
      onClose();
    } finally {
      setSaving(false);
    }
  };

  const inputStyle = {
    display: 'block', width: '100%', background: 'var(--surface-secondary)',
    borderRadius: '10px', padding: '12px 14px', fontSize: '15px',
    color: 'var(--text-primary)', border: 'none', outline: 'none', marginTop: '6px',
  };
  const labelStyle = { fontSize: '13px', fontWeight: '600', color: 'var(--text-secondary)', display: 'block' };

  const fields = [
    { label: 'Nome da Vacina',    name: 'name',               type: 'text' },
    { label: 'Fabricante',        name: 'manufacturer',       type: 'text' },
    { label: 'Número do Lote',    name: 'batchNumber',        type: 'text' },
    { label: 'Data de Validade',  name: 'expirationDate',     type: 'date' },
    { label: 'Data de Aplicação', name: 'administrationDate', type: 'date' },
    { label: 'Próxima Dose',      name: 'nextDueDate',        type: 'date' },
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0" style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(8px)', WebkitBackdropFilter: 'blur(8px)' }} onClick={onClose} />
      <div className="relative w-full max-w-[560px] rounded-[20px] overflow-hidden fade-in-up font-sf"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 24px 70px rgba(0,0,0,0.35)', maxHeight: '90vh', overflowY: 'auto' }}>
        <div className="flex items-center justify-between px-7 py-5" style={{ borderBottom: '1px solid var(--separator)' }}>
          <h2 className="font-bold" style={{ fontSize: '20px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
            Editar Vacina
          </h2>
          <button onClick={onClose} className="rounded-[8px] p-1.5 transition-colors duration-150"
            onMouseEnter={e => e.currentTarget.style.background = 'var(--surface-secondary)'}
            onMouseLeave={e => e.currentTarget.style.background = 'transparent'}>
            <X size={18} strokeWidth={2} style={{ color: 'var(--text-secondary)' }} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="px-7 py-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {fields.map(({ label, name, type }) => (
              <div key={name}>
                <label style={labelStyle}>{label}</label>
                <input type={type} name={name} value={formData[name]} onChange={handleChange} style={inputStyle} />
              </div>
            ))}
            <div className="md:col-span-2">
              <label style={labelStyle}>Observações</label>
              <textarea name="notes" value={formData.notes} onChange={handleChange} rows={3} style={{ ...inputStyle, resize: 'vertical' }} />
            </div>
          </div>

          <div className="flex justify-end gap-2 mt-6">
            <button type="button" onClick={onClose}
              className="px-4 py-2.5 rounded-[10px] font-medium transition-colors duration-150"
              style={{ background: 'var(--surface-secondary)', color: 'var(--text-secondary)', fontSize: '15px' }}>
              Cancelar
            </button>
            <button type="submit" disabled={saving}
              className="px-5 py-2.5 rounded-[10px] font-medium transition-opacity duration-150"
              style={{ background: 'var(--apple-blue)', color: '#fff', fontSize: '15px', opacity: saving ? 0.6 : 1, cursor: saving ? 'default' : 'pointer' }}>
              {saving ? 'Salvando...' : 'Salvar'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default VaccineEditModal;
