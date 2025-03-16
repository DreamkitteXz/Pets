import React, { useState } from 'react';
import { CiCircleCheck, CiCircleRemove, CiCircleAlert } from "react-icons/ci";
import { IoClose } from "react-icons/io5";
import { doc, updateDoc, Timestamp } from 'firebase/firestore';
import { db } from '../../../config/firebase';
import { useAuth } from '../../../context/AuthContext';

const VaccineDetailsModal = ({ isOpen, onClose, vaccine }) => {
  const { user } = useAuth();
  const [validationNote, setValidationNote] = useState('');
  const [rejectionReason, setRejectionReason] = useState('');
  const [isValidating, setIsValidating] = useState(false);

  if (!isOpen || !vaccine) return null;

  const formatDate = (timestamp) => {
    if (!timestamp) return 'N/A';
    return new Date(timestamp.toDate()).toLocaleDateString();
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
    if (!vaccine || !user) return;
    
    setIsValidating(true);
    try {
      const vaccineRef = doc(db, 'vaccines', vaccine.id);
      const validationDetails = {
        validatedAt: Timestamp.now(),
        validatedBy: user.uid,
        notes: validationNote,
        rejectionReason: isApproved ? '' : rejectionReason
      };

      await updateDoc(vaccineRef, {
        status: isApproved ? 'approved' : 'rejected',
        validationDetails,
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

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
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
                      <div className="font-medium">{vaccine.validationDetails.validatedBy}</div>
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
            {vaccine?.status === 'pending' && (
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
