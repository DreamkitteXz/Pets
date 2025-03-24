import React, { useState } from 'react';
import { CiSearch, CiFilter, CiCircleCheck, CiCircleRemove, CiCircleAlert } from "react-icons/ci";
import VaccineDetailsModal from './VaccineDetailsModal';
import VaccineDeleteModal from './VaccineDeleteModal';
import VaccineEditModal from './VaccineEditModal';
import useVetVaccines from '../../../hooks/useVetVaccines';

const VaccinePage = () => {
  const { vaccines, loading } = useVetVaccines();
  // Change default filter to 'all'
  const [filterStatus, setFilterStatus] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedVaccine, setSelectedVaccine] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);

  const formatDate = (date) => {
    if (!date) return 'N/A';
    // Handle string dates
    if (typeof date === 'string') return date;
    // Handle Firestore Timestamp
    if (date?.toDate instanceof Function) return date.toDate().toLocaleDateString();
    // Handle regular Date objects
    if (date instanceof Date) return date.toLocaleDateString();
    // Handle Timestamp-like objects
    if (date?.seconds) return new Date(date.seconds * 1000).toLocaleDateString();
    return 'Invalid Date';
  };

  const filteredVaccines = vaccines
    .filter(vaccine => {
      const isStatusMatch = filterStatus === 'all' || vaccine.status === filterStatus;
      console.log('Vaccine status:', vaccine.status, 'Filter status:', filterStatus, 'Match:', isStatusMatch);
      return isStatusMatch;
    })
    .filter(vaccine => {
      if (!searchTerm) return true;
      const searchTermLower = searchTerm.toLowerCase();
      const isMatch = vaccine.petName?.toLowerCase().includes(searchTermLower) ||
        vaccine.id?.toLowerCase().includes(searchTermLower) ||
        vaccine.ownerName?.toLowerCase().includes(searchTermLower) ||
        vaccine.name?.toLowerCase().includes(searchTermLower);
      console.log('Search term match:', isMatch);
      return isMatch;
    });

  // Debug logs after declaration
  console.log('Vaccines in component:', vaccines);
  console.log('Filtered vaccines:', filteredVaccines);

  const getStatusIcon = (status) => {
    switch (status) {
      case 'approved':
        return <CiCircleCheck className="text-green-600" size={20} />;
      case 'rejected':
        return <CiCircleRemove className="text-red-600" size={20} />;
      case 'pending':
        return <CiCircleAlert className="text-yellow-600" size={20} />;
      default:
        return null;
    }
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case 'approved':
        return <span className="px-2 py-1 text-xs rounded-full bg-green-100 text-green-800">Aprovado</span>;
      case 'rejected':
        return <span className="px-2 py-1 text-xs rounded-full bg-red-100 text-red-800">Rejeitado</span>;
      case 'pending':
        return <span className="px-2 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800">Pendente</span>;
      default:
        return null;
    }
  };

  const handleViewDetails = (vaccine) => {
    setSelectedVaccine(vaccine);
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setSelectedVaccine(null);
  };

  const handleDeleteClick = (vaccine) => {
    setSelectedVaccine(vaccine);
    setIsDeleteModalOpen(true);
  };

  const handleDelete = (vaccineId) => {
    console.log('Deleting vaccine:', vaccineId);
  };

  const handleEditClick = (vaccine) => {
    setSelectedVaccine(vaccine);
    setIsEditModalOpen(true);
  };

  const handleSaveEdit = (updatedVaccine) => {
    console.log('Saving updated vaccine:', updatedVaccine);
  };

  return (
    <div className="container mx-auto p-6">
      {loading ? (
        <div>Loading...</div>
      ) : (
        <>
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-gray-800 mb-2">Validação de Vacinas</h1>
            <p className="text-gray-600">
              Revise e valide os registros de vacinação associados ao seu registro CRMV. 
              Todas as vacinas administradas requerem validação para garantir conformidade com os padrões regulatórios e manter registros de saúde precisos.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div className="bg-white p-4 rounded-lg shadow">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-sm text-gray-500">Total de Registros</div>
                  <div className="text-2xl font-bold">{vaccines.length}</div>
                </div>
                <div className="bg-blue-100 p-2 rounded-full">
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-blue-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                  </svg>
                </div>
              </div>
            </div>
            
            <div className="bg-white p-4 rounded-lg shadow">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-sm text-gray-500">Pendentes</div>
                  <div className="text-2xl font-bold">{vaccines.filter(v => v.status === 'pending').length}</div>
                </div>
                <div className="bg-yellow-100 p-2 rounded-full">
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-yellow-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
              </div>
            </div>
            
            <div className="bg-white p-4 rounded-lg shadow">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-sm text-gray-500">Aprovados</div>
                  <div className="text-2xl font-bold">{vaccines.filter(v => v.status === 'approved').length}</div>
                </div>
                <div className="bg-green-100 p-2 rounded-full">
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
              </div>
            </div>
            
            <div className="bg-white p-4 rounded-lg shadow">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-sm text-gray-500">Rejeitados</div>
                  <div className="text-2xl font-bold">{vaccines.filter(v => v.status === 'rejected').length}</div>
                </div>
                <div className="bg-red-100 p-2 rounded-full">
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
              </div>
            </div>
          </div>

          <div className="flex flex-wrap items-center justify-between mb-6 gap-4">
            <div className="flex items-center gap-3">
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <CiSearch className="text-gray-400" />
                </div>
                <input
                  type="text"
                  placeholder="Buscar vacinas..."
                  className="pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 w-64"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
              
              <div className="flex items-center bg-white rounded-lg shadow-sm p-2 border">
                <CiFilter className="text-gray-500 mr-2" size={18} />
                <select 
                  className="border-none bg-transparent focus:outline-none text-sm"
                  value={filterStatus}
                  onChange={(e) => setFilterStatus(e.target.value)}
                >
                  <option value="all">Todos os Status</option>
                  <option value="pending">Pendente</option>
                  <option value="approved">Aprovado</option>
                  <option value="rejected">Rejeitado</option>
                </select>
              </div>
              
              <span className="text-sm text-gray-500">
                Mostrando {filteredVaccines.length} de {vaccines.length} registros
              </span>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow overflow-hidden">
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      ID / Data
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Pet / Proprietário
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Detalhes da Vacina
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      CRMV / Veterinário
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Ações
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredVaccines.map((vaccine) => (
                    <tr key={vaccine.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4">
                        <div className="text-sm font-medium text-gray-900">{vaccine.id}</div>
                        <div className="text-sm text-gray-500">
                          {formatDate(vaccine.administrationDate)}
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm font-medium text-gray-900">{vaccine.petName}</div>
                        <div className="text-sm text-gray-500">{vaccine.ownerName}</div>
                        {console.log('Pet Name:', vaccine.petName, 'Owner Name:', vaccine.ownerName)}
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm font-medium text-gray-900">{vaccine.name}</div>
                        <div className="text-sm text-gray-500">Lote: {vaccine.batchNumber}</div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm font-medium text-gray-900">{vaccine.crmvNumber}</div>
                        <div className="text-sm text-gray-500">{vaccine.veterinarianName}</div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center">
                          {getStatusIcon(vaccine.status)}
                          <span className="ml-2">{getStatusBadge(vaccine.status)}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <button 
                          className="text-blue-600 hover:text-blue-900 font-medium text-sm mr-3"
                          onClick={() => handleViewDetails(vaccine)}
                        >
                          Ver Detalhes
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          <div>
            <VaccineDetailsModal 
              isOpen={isModalOpen}
              onClose={handleCloseModal}
              vaccine={selectedVaccine}
            />

            <VaccineDeleteModal 
              isOpen={isDeleteModalOpen}
              onClose={() => setIsDeleteModalOpen(false)}
              vaccine={selectedVaccine}
              onDelete={handleDelete}
            />

            <VaccineEditModal 
              isOpen={isEditModalOpen}
              onClose={() => setIsEditModalOpen(false)}
              vaccine={selectedVaccine}
              onSave={handleSaveEdit}
            />
          </div>
        </>
      )}
    </div>
  );
};

export default VaccinePage;