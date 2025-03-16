import React from 'react';
import { IoClose } from "react-icons/io5";
import { usePetDetails } from '../../../hooks/usePetDetails';

const PetDetailsModal = ({ isOpen, onClose, pet }) => {
  const { pet: petDetails, vaccines, loading, error } = usePetDetails(pet?.id);

  if (!isOpen) return null;

  if (loading) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-6">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-yellow-500"></div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-6">
          <p className="text-red-500">Error: {error.message}</p>
          <button 
            onClick={onClose}
            className="mt-4 px-4 py-2 bg-gray-200 rounded-lg hover:bg-gray-300"
          >
            Close
          </button>
        </div>
      </div>
    );
  }

  if (!petDetails) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg w-full max-w-3xl max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-2xl font-bold text-gray-800">Pet Details</h2>
            <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
              <IoClose size={24} />
            </button>
          </div>

          <div className="space-y-6">
            {/* Basic Information */}
            <div className="grid grid-cols-2 gap-6">
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">Informações Básicas</h3>
                <div className="space-y-2">
                  <div>
                    <label className="block text-sm text-gray-600">Nome</label>
                    <div className="font-medium">{petDetails.name}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Espécie</label>
                    <div className="font-medium">{petDetails.species}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Raça</label>
                    <div className="font-medium">{petDetails.breed}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Idade</label>
                    <div className="font-medium">
                      {petDetails.birthDate ? 
                        Math.floor((new Date() - petDetails.birthDate) / (1000 * 60 * 60 * 24 * 365)) : 'N/A'} anos
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Proprietário</label>
                    <div className="font-medium">{petDetails.ownerName}</div>
                  </div>
                </div>
              </div>

              <div className="space-y-4">
                <h3 className="font-semibold text-lg">Status de Vacinação</h3>
                <div className="space-y-2">
                  <div>
                    <label className="block text-sm text-gray-600">Status</label>
                    <div className="font-medium capitalize">{petDetails.status}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Total de Vacinas</label>
                    <div className="font-medium">{vaccines.length}</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Vaccination History */}
            <div className="space-y-4">
              <h3 className="font-semibold text-lg">Histórico de Vacinação</h3>
              <div className="border rounded-lg overflow-hidden">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Vacina</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Data</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Próxima Data</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {vaccines.map((vaccine) => (
                      <tr key={vaccine.id}>
                        <td className="px-4 py-3 text-sm">{vaccine.name}</td>
                        <td className="px-4 py-3 text-sm">
                          {vaccine.administrationDate?.toLocaleDateString('pt-BR') || 'Não administrada'}
                        </td>
                        <td className="px-4 py-3 text-sm">
                          {vaccine.nextDueDate?.toLocaleDateString('pt-BR') || 'Não agendada'}
                        </td>
                        <td className="px-4 py-3 text-sm capitalize">{vaccine.status}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PetDetailsModal;
