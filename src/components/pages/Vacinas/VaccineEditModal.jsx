import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';

const VaccineEditModal = ({ isOpen, onClose, vaccine, onSave }) => {
  const [formData, setFormData] = useState(null);

  useEffect(() => {
    if (vaccine) {
      setFormData({
        id: vaccine.id,
        petName: vaccine.petName || '',
        vaccineName: vaccine.vaccineName || '',
        manufacturer: vaccine.manufacturer || '',
        batchNumber: vaccine.batchNumber || '',
        expiryDate: vaccine.expiryDate || '',
        administrationDate: vaccine.administrationDate || '',
        notes: vaccine.notes || '',
      });
    }
  }, [vaccine]);

  if (!isOpen || !vaccine || !formData) return null;

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onSave(formData);
    onClose();
  };

  const inputStyle = {
    display: 'block',
    width: '100%',
    background: 'var(--surface-secondary)',
    borderRadius: '10px',
    padding: '12px 14px',
    fontSize: '15px',
    color: 'var(--text-primary)',
    border: 'none',
    outline: 'none',
    marginTop: '6px',
  };

  const labelStyle = {
    fontSize: '13px',
    fontWeight: '600',
    color: 'var(--text-secondary)',
    display: 'block',
  };

  const fields = [
    { label: 'Nome do Pet',      name: 'petName',           type: 'text' },
    { label: 'Vacina',           name: 'vaccineName',       type: 'text' },
    { label: 'Fabricante',       name: 'manufacturer',      type: 'text' },
    { label: 'Número do Lote',   name: 'batchNumber',       type: 'text' },
    { label: 'Data de Validade', name: 'expiryDate',        type: 'date' },
    { label: 'Data de Aplicação',name: 'administrationDate',type: 'date' },
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Overlay */}
      <div
        className="absolute inset-0"
        style={{ background: 'rgba(0,0,0,0.4)', backdropFilter: 'blur(6px)', WebkitBackdropFilter: 'blur(6px)' }}
        onClick={onClose}
      />

      {/* Modal */}
      <div
        className="relative w-full max-w-[560px] rounded-[20px] overflow-hidden fade-in-up font-sf"
        style={{ background: 'var(--surface-elevated)', boxShadow: '0 24px 64px rgba(0,0,0,0.2), 0 0 0 1px rgba(0,0,0,0.06)', animationDuration: '0.25s', maxHeight: '90vh', overflowY: 'auto' }}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-5" style={{ borderBottom: '1px solid var(--separator)' }}>
          <h2 className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)', letterSpacing: '-0.01em' }}>
            Editar Registro de Vacina
          </h2>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full flex items-center justify-center transition-colors duration-150"
            style={{ background: 'var(--surface-secondary)', color: 'var(--text-secondary)' }}
            onMouseEnter={e => e.currentTarget.style.background = 'var(--apple-gray-5)'}
            onMouseLeave={e => e.currentTarget.style.background = 'var(--surface-secondary)'}
          >
            <X size={16} strokeWidth={2} />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="px-6 py-5">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {fields.map(({ label, name, type }) => (
              <div key={name}>
                <label style={labelStyle}>{label}</label>
                <input
                  type={type}
                  name={name}
                  value={formData[name]}
                  onChange={handleChange}
                  style={inputStyle}
                  onFocus={e => e.currentTarget.style.boxShadow = '0 0 0 3px rgba(0,122,255,0.25)'}
                  onBlur={e => e.currentTarget.style.boxShadow = 'none'}
                />
              </div>
            ))}

            <div className="md:col-span-2">
              <label style={labelStyle}>Observações</label>
              <textarea
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                rows={3}
                style={{ ...inputStyle, resize: 'vertical' }}
                onFocus={e => e.currentTarget.style.boxShadow = '0 0 0 3px rgba(0,122,255,0.25)'}
                onBlur={e => e.currentTarget.style.boxShadow = 'none'}
              />
            </div>
          </div>

          {/* Actions */}
          <div className="flex justify-end gap-3 mt-6" style={{ borderTop: '1px solid var(--separator)', paddingTop: '20px' }}>
            <button
              type="button"
              onClick={onClose}
              className="px-5 py-2.5 rounded-[10px] font-medium transition-all duration-150 active:scale-[0.97]"
              style={{ background: 'var(--surface-secondary)', color: 'var(--text-primary)', fontSize: '15px' }}
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
  );
};

export default VaccineEditModal;
