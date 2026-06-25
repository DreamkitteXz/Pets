import React, { useState, useEffect, useRef } from 'react';
import { X, Info, MapPin, Maximize2, CheckCircle, XCircle, Clock, AlertCircle } from 'lucide-react';
import { doc, getDoc } from 'firebase/firestore';
import { httpsCallable } from 'firebase/functions';
import { db, functions } from '../../../config/firebase';
import { useAuth } from '../../../context/AuthContext';
import logger from '../../../utils/logger';
import { normalizeStatus } from '../../../utils/vaccineStatus';
import { toDate } from '../../../utils/dates';

const updateVaccineStatusFn = httpsCallable(functions, 'updateVaccineStatus', { timeout: 15000 });

// ── Status → display (eixo único: pending | approved | rejected) ─────────────
const STATUS_CFG = {
  pending:  { label: 'Pendente',  color: 'var(--apple-orange)', bg: 'rgba(255,149,0,0.12)', icon: Clock },
  approved: { label: 'Aprovado',  color: 'var(--apple-green)',  bg: 'rgba(52,199,89,0.12)', icon: CheckCircle },
  rejected: { label: 'Rejeitado', color: 'var(--apple-red)',    bg: 'rgba(255,59,48,0.10)', icon: XCircle },
};

// ── Shared styles / small presentational helpers ─────────────────────────────
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

const StatusBadge = ({ status }) => {
  const cfg = STATUS_CFG[normalizeStatus(status)] || { label: status || '—', color: 'var(--apple-gray-1)', bg: 'rgba(142,142,147,0.12)', icon: Clock };
  const Icon = cfg.icon;
  return (
    <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[12px] font-medium" style={{ background: cfg.bg, color: cfg.color }}>
      <Icon size={11} strokeWidth={2} />
      {cfg.label}
    </span>
  );
};

const InfoItem = ({ label, value }) => (
  <div>
    <div style={{ fontSize: '11px', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.05em', color: 'var(--text-tertiary)' }}>{label}</div>
    <div className="mt-0.5" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{value || '—'}</div>
  </div>
);

const Section = ({ title, action, children }) => (
  <div className="rounded-[14px] p-5" style={{ background: 'var(--surface-secondary)' }}>
    <div className="flex items-center justify-between mb-3">
      <h3 className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{title}</h3>
      {action}
    </div>
    {children}
  </div>
);

const VaccineDetailsModal = ({ isOpen, onClose, vaccine }) => {
  const { user } = useAuth();
  const [validationNote, setValidationNote] = useState('');
  const [rejectionReason, setRejectionReason] = useState('');
  const [isValidating, setIsValidating] = useState(false);
  const [isImageViewerOpen, setIsImageViewerOpen] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const [isMetadataModalOpen, setIsMetadataModalOpen] = useState(false);
  const mapRef = useRef(null);

  useEffect(() => {
    const fetchUserInfo = async () => {
      if (user) {
        const userDoc = await getDoc(doc(db, 'users', user.uid));
        if (userDoc.exists()) {
          setCurrentUser(userDoc.data());
        }
      }
    };
    fetchUserInfo();
  }, [user]);

  useEffect(() => {
    if (isMetadataModalOpen && vaccine?.labelImageMetadata?.location) {
      try {
        const { latitude, longitude } = vaccine.labelImageMetadata.location;
        if (!window.google?.maps) {
          console.error('Google Maps not loaded');
          return;
        }

        const map = new window.google.maps.Map(mapRef.current, {
          center: { lat: latitude, lng: longitude },
          zoom: 15,
        });

        new window.google.maps.Marker({
          position: { lat: latitude, lng: longitude },
          map,
          title: "Local da Foto",
        });
      } catch (error) {
        console.error('Error initializing map:', error);
      }
    }
  }, [isMetadataModalOpen, vaccine?.labelImageMetadata?.location]);

  if (!isOpen || !vaccine || !currentUser) return null;

  // Contrato único de validação: validationDetails.vetValidation.* (formato aninhado).
  const vetVal = vaccine.validationDetails?.vetValidation || {};
  const showValidationInfo = ['approved', 'rejected'].includes(normalizeStatus(vaccine.status));
  const canValidate = !vetVal.status || vetVal.status === 'pending';

  const formatDate = (date) => {
    const d = toDate(date);
    if (!d) return 'N/A';
    const day = String(d.getDate()).padStart(2, '0');
    const month = String(d.getMonth() + 1).padStart(2, '0');
    return `${day}/${month}/${d.getFullYear()}`;
  };

  const handleValidation = async (isApproved) => {
    if (!vaccine || !currentUser) return;

    setIsValidating(true);
    try {
      await updateVaccineStatusFn({
        vaccineId:       vaccine.id,
        isApproved,
        notes:           validationNote,
        rejectionReason: isApproved ? '' : rejectionReason,
      });

      onClose();
    } catch (error) {
      logger.error('Error validating vaccine:', error);
      alert(error?.message || 'Erro ao validar vacina. Tente novamente.');
    } finally {
      setIsValidating(false);
    }
  };

  const handleImageViewerClose = (e) => {
    if (e.target.id === 'image-viewer-overlay') {
      setIsImageViewerOpen(false);
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 font-sf"
      style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(8px)', WebkitBackdropFilter: 'blur(8px)' }}
    >
      {/* ── Image viewer (fullscreen) ─────────────────────────────────────── */}
      {isImageViewerOpen && (
        <div
          id="image-viewer-overlay"
          className="fixed inset-0 flex items-center justify-center z-[60]"
          style={{ background: 'rgba(0,0,0,0.85)' }}
          onClick={handleImageViewerClose}
        >
          <div className="relative max-w-4xl mx-auto">
            <button
              onClick={() => setIsImageViewerOpen(false)}
              className="absolute -top-11 right-0 transition-opacity duration-150"
              style={{ color: '#fff' }}
              onMouseEnter={e => e.currentTarget.style.opacity = '0.7'}
              onMouseLeave={e => e.currentTarget.style.opacity = '1'}
            >
              <X size={28} strokeWidth={2} />
            </button>
            <img
              src={vaccine.labelImage}
              alt="Rótulo da vacina"
              className="max-h-[80vh] w-auto object-contain rounded-[12px]"
            />
          </div>
        </div>
      )}

      {/* ── Main card ─────────────────────────────────────────────────────── */}
      <div
        className="fade-in-up w-full max-w-3xl max-h-[90vh] overflow-y-auto rounded-[20px]"
        style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 24px 70px rgba(0,0,0,0.35)' }}
      >
        {/* Header */}
        <div
          className="sticky top-0 z-10 flex items-center justify-between px-7 py-5"
          style={{ background: 'var(--surface-grouped-secondary)', borderBottom: '1px solid var(--separator)' }}
        >
          <div className="flex items-center gap-3 min-w-0">
            <div>
              <h2 className="font-bold" style={{ fontSize: '22px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
                Detalhes da Vacina
              </h2>
              <div className="mt-0.5" style={{ fontSize: '12px', color: 'var(--text-tertiary)', fontFamily: 'monospace' }}>
                ID: {vaccine.id}
              </div>
            </div>
            <StatusBadge status={vaccine.status} />
          </div>
          <button
            onClick={onClose}
            className="rounded-[8px] p-1.5 transition-colors duration-150 flex-shrink-0"
            onMouseEnter={e => e.currentTarget.style.background = 'var(--surface-secondary)'}
            onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
          >
            <X size={18} strokeWidth={2} style={{ color: 'var(--text-secondary)' }} />
          </button>
        </div>

        {/* Body */}
        <div className="px-7 py-6 flex flex-col gap-5">

          {/* Label image */}
          {vaccine?.labelImage && (
            <Section
              title="Foto do Rótulo da Vacina"
              action={vaccine?.labelImageMetadata && (
                <button
                  onClick={() => setIsMetadataModalOpen(true)}
                  className="flex items-center gap-1.5 font-medium transition-opacity duration-150"
                  style={{ fontSize: '13px', color: 'var(--apple-blue)' }}
                  onMouseEnter={e => e.currentTarget.style.opacity = '0.7'}
                  onMouseLeave={e => e.currentTarget.style.opacity = '1'}
                >
                  <Info size={15} strokeWidth={1.75} /> Metadados
                </button>
              )}
            >
              <button
                className="relative w-full rounded-[12px] overflow-hidden block"
                onClick={() => setIsImageViewerOpen(true)}
                style={{ border: '1px solid var(--separator)' }}
              >
                <img
                  src={vaccine.labelImage}
                  alt="Rótulo da vacina"
                  className="w-full h-auto max-h-[300px] object-contain transition-opacity duration-150 hover:opacity-90"
                />
                <span
                  className="absolute bottom-2 right-2 flex items-center gap-1 px-2 py-1 rounded-full"
                  style={{ background: 'rgba(0,0,0,0.55)', color: '#fff', fontSize: '11px' }}
                >
                  <Maximize2 size={11} strokeWidth={2} /> Ampliar
                </span>
              </button>
            </Section>
          )}

          {/* Pet + Owner */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Section title="Informações do Pet">
              <div className="grid grid-cols-2 gap-4">
                <InfoItem label="Nome" value={vaccine.petName} />
                <InfoItem label="Espécie" value={vaccine.petSpecies} />
                <InfoItem label="Raça" value={vaccine.petBreed} />
                <InfoItem label="Peso" value={vaccine.petWeight != null ? `${vaccine.petWeight} kg` : null} />
              </div>
            </Section>
            <Section title="Informações do Proprietário">
              <div className="grid grid-cols-2 gap-4">
                <InfoItem label="Nome" value={vaccine.ownerName} />
                <InfoItem label="Contato" value={vaccine.ownerContact} />
              </div>
            </Section>
          </div>

          {/* Vaccine info */}
          <Section title="Informações da Vacina">
            <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
              <InfoItem label="Nome da Vacina" value={vaccine.name} />
              <InfoItem label="Fabricante" value={vaccine.manufacturer} />
              <InfoItem label="Número do Lote" value={vaccine.batchNumber} />
              <InfoItem label="Data de Administração" value={formatDate(vaccine.administrationDate)} />
              <InfoItem label="Data de Validade" value={formatDate(vaccine.expirationDate)} />
              <InfoItem label="Próxima Dose" value={formatDate(vaccine.nextDueDate)} />
              <InfoItem label="Via de administração" value={vaccine.route} />
              <InfoItem label="Local de aplicação" value={vaccine.applicationSite} />
              <InfoItem label="Dose" value={vaccine.dose || vaccine.dosage} />
            </div>
          </Section>

          {/* Clinic info */}
          {vaccine.clinicName && (
            <Section title="Informações da Clínica">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <InfoItem label="Nome da Clínica" value={vaccine.clinicName} />
                <InfoItem label="CNPJ" value={vaccine.clinicCnpj} />
                <div className="md:col-span-2">
                  <InfoItem
                    label="Endereço"
                    value={vaccine.clinicAddress
                      ? `${vaccine.clinicAddress.street || ''}, ${vaccine.clinicAddress.number || ''} — ${vaccine.clinicAddress.neighborhood || ''}, ${vaccine.clinicAddress.city || ''}/${vaccine.clinicAddress.state || ''}`
                      : null}
                  />
                </div>
              </div>
            </Section>
          )}

          {/* Validation info — exibido após a validação do veterinário */}
          {showValidationInfo && (
            <Section title="Informações de Validação">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <InfoItem label="Data de Validação" value={formatDate(vetVal.validatedAt)} />
                <InfoItem
                  label="Validado Por"
                  value={`${vetVal.validatedByName || vaccine.veterinarianName || '—'} (CRMV: ${vetVal.validatedByCrmv || vaccine.crmvNumber || '—'})`}
                />
                {vetVal.rejectionReason && (
                  <div className="md:col-span-2">
                    <div style={{ fontSize: '11px', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.05em', color: 'var(--text-tertiary)' }}>Motivo da Rejeição</div>
                    <div className="mt-0.5" style={{ fontSize: '15px', color: 'var(--apple-red)' }}>{vetVal.rejectionReason}</div>
                  </div>
                )}
                {vetVal.notes && (
                  <div className="md:col-span-2">
                    <InfoItem label="Observações" value={vetVal.notes} />
                  </div>
                )}
              </div>
            </Section>
          )}

          {/* Validation controls */}
          {canValidate && (
            <div className="rounded-[14px] p-5" style={{ background: 'rgba(0,122,255,0.06)', border: '1px solid rgba(0,122,255,0.18)' }}>
              <div className="flex items-center gap-2 mb-4">
                <AlertCircle size={18} strokeWidth={1.75} style={{ color: 'var(--apple-blue)' }} />
                <h3 className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>Validação da Vacina</h3>
              </div>

              <div className="flex flex-col gap-4">
                <div>
                  <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, color: 'var(--text-secondary)', marginBottom: '6px' }}>
                    Observações da Validação
                  </label>
                  <textarea
                    rows={3}
                    value={validationNote}
                    onChange={(e) => setValidationNote(e.target.value)}
                    placeholder="Adicione observações sobre a validação..."
                    style={{ ...inputStyle, resize: 'none' }}
                  />
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                  {/* Approve */}
                  <div className="rounded-[12px] p-4" style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}>
                    <div className="flex items-center gap-2 mb-2">
                      <CheckCircle size={16} strokeWidth={2} style={{ color: 'var(--apple-green)' }} />
                      <h4 className="font-semibold" style={{ fontSize: '14px', color: 'var(--text-primary)' }}>Aprovar Vacina</h4>
                    </div>
                    <p className="mb-4" style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                      Confirme a aprovação desta vacina após verificar todos os detalhes.
                    </p>
                    <button
                      onClick={() => handleValidation(true)}
                      disabled={isValidating}
                      className="w-full flex items-center justify-center gap-2 rounded-[10px] font-medium transition-opacity duration-150"
                      style={{ height: '42px', fontSize: '15px', color: '#fff', background: 'var(--apple-green)', opacity: isValidating ? 0.5 : 1, cursor: isValidating ? 'default' : 'pointer' }}
                    >
                      {isValidating ? 'Processando...' : 'Aprovar'}
                      <CheckCircle size={16} strokeWidth={2} />
                    </button>
                  </div>

                  {/* Reject */}
                  <div className="rounded-[12px] p-4" style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}>
                    <div className="flex items-center gap-2 mb-2">
                      <XCircle size={16} strokeWidth={2} style={{ color: 'var(--apple-red)' }} />
                      <h4 className="font-semibold" style={{ fontSize: '14px', color: 'var(--text-primary)' }}>Rejeitar Vacina</h4>
                    </div>
                    <div className="flex flex-col gap-3">
                      <label style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                        Motivo da Rejeição <span style={{ color: 'var(--apple-red)' }}>*</span>
                      </label>
                      <input
                        type="text"
                        value={rejectionReason}
                        onChange={(e) => setRejectionReason(e.target.value)}
                        placeholder="Informe o motivo da rejeição..."
                        style={inputStyle}
                      />
                      <button
                        onClick={() => handleValidation(false)}
                        disabled={isValidating || !rejectionReason}
                        className="w-full flex items-center justify-center gap-2 rounded-[10px] font-medium transition-opacity duration-150"
                        style={{ height: '42px', fontSize: '15px', color: '#fff', background: 'var(--apple-red)', opacity: (isValidating || !rejectionReason) ? 0.5 : 1, cursor: (isValidating || !rejectionReason) ? 'default' : 'pointer' }}
                      >
                        {isValidating ? 'Processando...' : 'Rejeitar'}
                        <XCircle size={16} strokeWidth={2} />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Notes */}
          {vaccine.notes && (
            <Section title="Observações">
              <p style={{ fontSize: '15px', color: 'var(--text-secondary)', lineHeight: 1.5 }}>{vaccine.notes}</p>
            </Section>
          )}
        </div>
      </div>

      {/* ── Metadata modal ────────────────────────────────────────────────── */}
      {isMetadataModalOpen && vaccine?.labelImageMetadata && (
        <div
          className="fixed inset-0 z-[70] flex items-center justify-center p-4"
          style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(8px)', WebkitBackdropFilter: 'blur(8px)' }}
        >
          <div
            className="fade-in-up w-full max-w-2xl rounded-[20px] overflow-hidden"
            style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 24px 70px rgba(0,0,0,0.35)' }}
          >
            <div className="flex items-center justify-between px-7 py-5" style={{ borderBottom: '1px solid var(--separator)' }}>
              <h3 className="font-semibold" style={{ fontSize: '17px', color: 'var(--text-primary)' }}>Metadados da Imagem</h3>
              <button
                onClick={() => setIsMetadataModalOpen(false)}
                className="rounded-[8px] p-1.5 transition-colors duration-150"
                onMouseEnter={e => e.currentTarget.style.background = 'var(--surface-secondary)'}
                onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
              >
                <X size={18} strokeWidth={2} style={{ color: 'var(--text-secondary)' }} />
              </button>
            </div>
            <div className="px-7 py-6 flex flex-col gap-4">
              <div className="grid grid-cols-2 gap-4">
                <InfoItem label="Nome do Arquivo" value={vaccine.labelImageMetadata.name} />
                <InfoItem label="Tamanho" value={vaccine.labelImageMetadata.size != null ? `${(vaccine.labelImageMetadata.size / 1024).toFixed(2)} KB` : null} />
                <InfoItem label="Tipo" value={vaccine.labelImageMetadata.contentType} />
                <InfoItem label="Data de Upload" value={formatDate(vaccine.labelImageMetadata.timeCreated)} />
                {vaccine.labelImageMetadata.location && (
                  <div className="col-span-2 flex items-center gap-1.5">
                    <MapPin size={14} strokeWidth={1.75} style={{ color: 'var(--text-tertiary)' }} />
                    <InfoItem
                      label="Localização"
                      value={`${vaccine.labelImageMetadata.location.latitude}°, ${vaccine.labelImageMetadata.location.longitude}°`}
                    />
                  </div>
                )}
              </div>

              {vaccine.labelImageMetadata.location && (
                <div>
                  <div className="mb-2" style={{ fontSize: '11px', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.05em', color: 'var(--text-tertiary)' }}>
                    Localização no Mapa
                  </div>
                  <div ref={mapRef} className="w-full h-[300px] rounded-[12px]" style={{ border: '1px solid var(--separator)' }} />
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default VaccineDetailsModal;
