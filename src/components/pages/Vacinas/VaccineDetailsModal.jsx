import React, { useState, useEffect, useRef } from 'react';
import { CiCircleCheck, CiCircleRemove, CiCircleAlert } from "react-icons/ci";
import { IoClose, IoInformationCircle } from "react-icons/io5";
import { doc, updateDoc, getDoc, Timestamp } from 'firebase/firestore';
import { db } from '../../../config/firebase';
import { useAuth } from '../../../context/AuthContext';

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

  const formatDate = (date) => {
    if (!date) return 'N/A';
    const formatToDDMMYYYY = (dateObj) => {
      const day = String(dateObj.getDate()).padStart(2, '0');
      const month = String(dateObj.getMonth() + 1).padStart(2, '0');
      const year = dateObj.getFullYear();
      return `${day}/${month}/${year}`;
    };
    // Handle string dates
    if (typeof date === 'string') return date;
    // Handle Firestore Timestamp
    if (date?.toDate instanceof Function) return formatToDDMMYYYY(date.toDate());
    // Handle regular Date objects
    if (date instanceof Date) return formatToDDMMYYYY(date);
    // Handle Timestamp-like objects
    if (date?.seconds) return formatToDDMMYYYY(new Date(date.seconds * 1000));
    // Handle specific timestamp format
    if (typeof date === 'object' && date.seconds && date.nanoseconds) {
      return formatToDDMMYYYY(new Date(date.seconds * 1000));
    }
    return 'Invalid Date';
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'approved':
        return <CiCircleCheck className="text-green-600" size={24} />;
      case 'rejected':
        return <CiCircleRemove className="text-red-600" size={24} />;
      case 'pending':
        return <CiCircleAlert className="text-yellow-600" size={24} />;
      default:
        return null;
    }
  };

  const handleValidation = async (isApproved) => {
    if (!vaccine || !currentUser) return;

    setIsValidating(true);
    try {
      const vaccineRef = doc(db, 'vaccines', vaccine.id);
      const validationDetails = {
        status: isApproved ? 'approved' : 'rejected',
        validatedAt: Timestamp.now(),
        validatedBy: user.uid,
        validatedByName: currentUser.name || 'Unknown',
        validatedByCrmv: currentUser.crmv || 'Unknown',
        notes: validationNote,
        rejectionReason: isApproved ? '' : rejectionReason
      };

      await updateDoc(vaccineRef, {
        'validationDetails.vetValidation': validationDetails,
        updatedAt: Timestamp.now()
      });

      onClose();
    } catch (error) {
      console.error('Error validating vaccine:', error);
      alert('Erro ao validar vacina. Tente novamente.');
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
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      {isImageViewerOpen && (
        <div
          id="image-viewer-overlay"
          className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-[60]"
          onClick={handleImageViewerClose}
        >
          <div className="relative max-w-4xl mx-auto">
            <button 
              onClick={() => setIsImageViewerOpen(false)}
              className="absolute -top-10 right-0 text-white hover:text-gray-300"
            >
              <IoClose size={30} />
            </button>
            <img
              src={vaccine.labelImage}
              alt="Rótulo da vacina"
              className="max-h-[80vh] w-auto object-contain transform transition-transform duration-300 hover:scale-125"
            />
          </div>
        </div>
      )}

      <div className="bg-white rounded-lg w-full max-w-3xl max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-2xl font-bold text-gray-800">Detalhes da Vacina</h2>
            <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
              <IoClose size={24} />
            </button>
          </div>

          <div className="space-y-6">
            {/* Status Section */}
            <div className="flex items-center justify-between bg-gray-50 p-4 rounded-lg">
              <div className="flex items-center gap-2">
                {getStatusIcon(vaccine.status)}
                <span className="font-semibold capitalize">{vaccine.status}</span>
              </div>
              <span className="text-gray-500">ID: {vaccine.id}</span>
            </div>

            {/* Updated Vaccine Label Image Section */}
            {vaccine?.labelImage && (
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="font-semibold text-lg">Foto do Rótulo da Vacina</h3>
                  {vaccine?.labelImageMetadata && (
                    <button
                      onClick={() => setIsMetadataModalOpen(true)}
                      className="flex items-center gap-2 text-blue-600 hover:text-blue-700"
                    >
                      <IoInformationCircle size={20} />
                      <span className="text-sm">Metadados</span>
                    </button>
                  )}
                </div>
                <div 
                  className="border rounded-lg overflow-hidden cursor-pointer"
                  onClick={() => setIsImageViewerOpen(true)}
                >
                  <img
                    src={vaccine.labelImage}
                    alt="Rótulo da vacina"
                    className="w-full h-auto max-h-[300px] object-contain hover:opacity-90 transition-opacity"
                  />
                </div>
                <p className="text-sm text-gray-500 text-center">
                  Clique na imagem para ampliar
                </p>
              </div>
            )}

            {/* Metadata Modal */}
            {isMetadataModalOpen && vaccine?.labelImageMetadata && (
              <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[70]">
                <div className="bg-white rounded-lg w-full max-w-2xl p-6">
                  <div className="flex justify-between items-center mb-4">
                    <h3 className="text-lg font-semibold">Metadados da Imagem</h3>
                    <button 
                      onClick={() => setIsMetadataModalOpen(false)}
                      className="text-gray-500 hover:text-gray-700"
                    >
                      <IoClose size={24} />
                    </button>
                  </div>
                  <div className="space-y-4">
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <label className="block text-gray-600">Nome do Arquivo</label>
                        <div className="font-medium">{vaccine.labelImageMetadata.name}</div>
                      </div>
                      <div>
                        <label className="block text-gray-600">Tamanho</label>
                        <div className="font-medium">{(vaccine.labelImageMetadata.size / 1024).toFixed(2)} KB</div>
                      </div>
                      <div>
                        <label className="block text-gray-600">Tipo</label>
                        <div className="font-medium">{vaccine.labelImageMetadata.contentType}</div>
                      </div>
                      <div>
                        <label className="block text-gray-600">Data de Upload</label>
                        <div className="font-medium">{formatDate(vaccine.labelImageMetadata.timeCreated)}</div>
                      </div>
                      {vaccine.labelImageMetadata.location && (
                        <div className="col-span-2">
                          <label className="block text-gray-600">Localização</label>
                          <div className="font-medium">
                            {vaccine.labelImageMetadata.location.latitude}°, {vaccine.labelImageMetadata.location.longitude}°
                          </div>
                        </div>
                      )}
                    </div>
                    
                    {vaccine.labelImageMetadata.location && (
                      <div className="mt-4">
                        <label className="block text-gray-600 mb-2">Localização no Mapa</label>
                        <div 
                          ref={mapRef}
                          className="w-full h-[300px] rounded-lg border border-gray-200"
                        />
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* Main Details Grid */}
            <div className="grid grid-cols-2 gap-6">
              {/* Pet Information */}
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">Informações do Pet</h3>
                <div className="space-y-2">
                  <div>
                    <label className="block text-sm text-gray-600">Nome</label>
                    <div className="font-medium">{vaccine.petName}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Espécie</label>
                    <div className="font-medium">{vaccine.petSpecies}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Raça</label>
                    <div className="font-medium">{vaccine.petBreed}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Peso</label>
                    <div className="font-medium">{vaccine.petWeight} kg</div>
                  </div>
                </div>
              </div>

              {/* Owner Information */}
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">Informações do Proprietário</h3>
                <div className="space-y-2">
                  <div>
                    <label className="block text-sm text-gray-600">Nome</label>
                    <div className="font-medium">{vaccine.ownerName}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Contato</label>
                    <div className="font-medium">{vaccine.ownerContact}</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Vaccine Information */}
            <div className="space-y-4">
              <h3 className="font-semibold text-lg">Informações da Vacina</h3>
              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-2">
                  <div>
                    <label className="block text-sm text-gray-600">Nome da Vacina</label>
                    <div className="font-medium">{vaccine.name}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Fabricante</label>
                    <div className="font-medium">{vaccine.manufacturer}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Número do Lote</label>
                    <div className="font-medium">{vaccine.batchNumber}</div>
                  </div>
                </div>
                <div className="space-y-2">
                  <div>
                    <label className="block text-sm text-gray-600">Data de Administração</label>
                    <div className="font-medium">{formatDate(vaccine.administrationDate)}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Data de Validade</label>
                    <div className="font-medium">{formatDate(vaccine.expirationDate)}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Próxima Dose</label>
                    <div className="font-medium">{formatDate(vaccine.nextDueDate)}</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Clinic Information */}
            {vaccine.clinicName && (
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">Informações da Clínica</h3>
                <div className="grid grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <div>
                      <label className="block text-sm text-gray-600">Nome da Clínica</label>
                      <div className="font-medium">{vaccine.clinicName}</div>
                    </div>
                    <div>
                      <label className="block text-sm text-gray-600">CNPJ</label>
                      <div className="font-medium">{vaccine.clinicCnpj}</div>
                    </div>
                  </div>
                  <div className="space-y-2">
                    <div>
                      <label className="block text-sm text-gray-600">Endereço</label>
                      <div className="font-medium">
                        {vaccine.clinicAddress?.street}, {vaccine.clinicAddress?.number}
                        <br />
                        {vaccine.clinicAddress?.neighborhood} - {vaccine.clinicAddress?.city}/{vaccine.clinicAddress?.state}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* Validation Information - Only show if vaccine is approved or rejected */}
            {(vaccine.status === 'approved' || vaccine.status === 'rejected') && vaccine.validationDetails && (
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">Informações de Validação</h3>
                <div className="grid grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <div>
                      <label className="block text-sm text-gray-600">Data de Validação</label>
                      <div className="font-medium">{formatDate(vaccine.validationDetails.validatedAt)}</div>
                    </div>
                    <div>
                      <label className="block text-sm text-gray-600">Validado Por</label>
                      <div className="font-medium">
                        {vaccine.veterinarianName} (CRMV: {vaccine.crmvNumber})
                      </div>
                    </div>
                  </div>
                  <div className="space-y-2">
                    {vaccine.validationDetails.rejectionReason && (
                      <div>
                        <label className="block text-sm text-gray-600">Motivo da Rejeição</label>
                        <div className="font-medium text-red-600">{vaccine.validationDetails.rejectionReason}</div>
                      </div>
                    )}
                    {vaccine.validationDetails.notes && (
                      <div>
                        <label className="block text-sm text-gray-600">Observações</label>
                        <div className="font-medium">{vaccine.validationDetails.notes}</div>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* Validation Controls */}
            {(vaccine.validationDetails?.vetValidation?.status === 'pending' || !vaccine.validationDetails?.vetValidation?.status) && (
              <div className="bg-gray-50 rounded-lg p-6 border border-gray-200 space-y-6">
                <div className="flex items-center gap-3">
                  <CiCircleAlert className="text-blue-600" size={24} />
                  <h3 className="font-semibold text-lg text-blue-700">Validação da Vacina</h3>
                </div>
                
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Observações da Validação
                    </label>
                    <textarea
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition"
                      rows="3"
                      value={validationNote}
                      onChange={(e) => setValidationNote(e.target.value)}
                      placeholder="Adicione observações sobre a validação..."
                    />
                  </div>
                  
                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    {/* Approve Section */}
                    <div className="bg-white p-4 rounded-lg border border-gray-200 hover:shadow-md transition">
                      <div className="flex items-center gap-2 mb-3">
                        <CiCircleCheck className="text-green-600" size={20} />
                        <h4 className="font-medium text-green-700">Aprovar Vacina</h4>
                      </div>
                      <p className="text-sm text-gray-600 mb-4">
                        Confirme a aprovação desta vacina após verificar todos os detalhes.
                      </p>
                      <button
                        className="w-full px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 transition flex items-center justify-center gap-2"
                        onClick={() => handleValidation(true)}
                        disabled={isValidating}
                      >
                        {isValidating ? 'Processando...' : 'Aprovar'}
                        <CiCircleCheck size={18} />
                      </button>
                    </div>
                    
                    {/* Reject Section */}
                    <div className="bg-white p-4 rounded-lg border border-gray-200 hover:shadow-md transition">
                      <div className="flex items-center gap-2 mb-3">
                        <CiCircleRemove className="text-red-600" size={20} />
                        <h4 className="font-medium text-red-700">Rejeitar Vacina</h4>
                      </div>
                      <div className="space-y-3">
                        <label className="block text-sm text-gray-600">
                          Motivo da Rejeição <span className="text-red-500">*</span>
                        </label>
                        <input
                          type="text"
                          className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500 transition"
                          value={rejectionReason}
                          onChange={(e) => setRejectionReason(e.target.value)}
                          placeholder="Informe o motivo da rejeição..."
                        />
                        <button
                          className="w-full px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 transition flex items-center justify-center gap-2"
                          onClick={() => handleValidation(false)}
                          disabled={isValidating || !rejectionReason}
                        >
                          {isValidating ? 'Processando...' : 'Rejeitar'}
                          <CiCircleRemove size={18} />
                        </button>
                      </div>
                    </div>
                  </div>

                  {/* GOVBR Sign Section */}
                  <div className="bg-white p-4 rounded-lg border border-gray-200 hover:shadow-md transition">
                    <div className="flex items-center gap-2 mb-3">
                      <CiCircleCheck className="text-blue-600" size={20} />
                      <h4 className="font-medium text-blue-700">Assinar Documento</h4>
                    </div>
                    <p className="text-sm text-gray-600 mb-4">
                      Utilize o GOVBR para assinar digitalmente este documento.
                    </p>
                    <button
                      className="w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition flex items-center justify-center gap-2"
                    >
                      Assinar com GOVBR
                    </button>
                  </div>
                </div>
              </div>
            )}
            {/* Notes */}
            {vaccine.notes && (
              <div className="space-y-2">
                <h3 className="font-semibold text-lg">Observações</h3>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <p className="text-gray-700">{vaccine.notes}</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default VaccineDetailsModal;
