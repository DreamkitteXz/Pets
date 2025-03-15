import React, { useState } from 'react';
import { CiSearch, CiFilter, CiCircleCheck, CiCircleRemove, CiCircleAlert } from "react-icons/ci";
import VaccineDetailsModal from './VaccineDetailsModal';
import VaccineDeleteModal from './VaccineDeleteModal';
import VaccineEditModal from './VaccineEditModal';

const VaccinePage = () => {
  const [filterStatus, setFilterStatus] = useState('pending');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedVaccine, setSelectedVaccine] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  
  // Sample vaccine validation data
  const vaccineData = [
    { 
      id: 'VAC-2025-1023',
      petName: 'Max',
      petSpecies: 'Dog', 
      breed: 'Labrador',
      vaccineName: 'Rabies Vaccine',
      manufacturer: 'PetVax',
      batchNumber: 'RB-45921',
      expiryDate: '2026-03-15',
      administrationDate: '2025-03-01',
      veterinarian: 'Dr. Sarah Wilson',
      crmvNumber: 'CRMV-SP 12345',
      status: 'pending',
      submissionDate: '2025-03-02',
      owner: 'John Smith',
      notes: 'Annual vaccination, no adverse reactions observed'
    },
    { 
      id: 'VAC-2025-1019',
      petName: 'Luna',
      petSpecies: 'Cat', 
      breed: 'Siamese',
      vaccineName: 'FVRCP',
      manufacturer: 'FeliFax',
      batchNumber: 'FF-78542',
      expiryDate: '2026-01-20',
      administrationDate: '2025-02-27',
      veterinarian: 'Dr. Sarah Wilson',
      crmvNumber: 'CRMV-SP 12345',
      status: 'pending',
      submissionDate: '2025-02-28',
      owner: 'Emily Johnson',
      notes: 'Booster shot administered according to schedule'
    },
    { 
      id: 'VAC-2025-0982',
      petName: 'Charlie',
      petSpecies: 'Dog', 
      breed: 'Golden Retriever',
      vaccineName: 'DHPP',
      manufacturer: 'PetVax',
      batchNumber: 'DH-11546',
      expiryDate: '2025-12-10',
      administrationDate: '2025-02-15',
      veterinarian: 'Dr. Sarah Wilson',
      crmvNumber: 'CRMV-SP 12345',
      status: 'approved',
      submissionDate: '2025-02-16',
      validationDate: '2025-02-18',
      validator: 'Dr. Michael Brown',
      owner: 'David Lee',
      notes: 'Complete vaccination series'
    },
    { 
      id: 'VAC-2025-0971',
      petName: 'Bella',
      petSpecies: 'Dog', 
      breed: 'Beagle',
      vaccineName: 'Leptospirosis',
      manufacturer: 'CanineHealth',
      batchNumber: 'LP-33281',
      expiryDate: '2025-11-05',
      administrationDate: '2025-02-10',
      veterinarian: 'Dr. Sarah Wilson',
      crmvNumber: 'CRMV-SP 12345',
      status: 'rejected',
      submissionDate: '2025-02-11',
      validationDate: '2025-02-13',
      validator: 'Dr. James Taylor',
      rejectionReason: 'Incomplete documentation, missing consent form',
      owner: 'Michael Brown',
      notes: 'First-time vaccination for this pathogen'
    },
    { 
      id: 'VAC-2025-0965',
      petName: 'Oliver',
      petSpecies: 'Cat', 
      breed: 'Persian',
      vaccineName: 'FeLV',
      manufacturer: 'FeliFax',
      batchNumber: 'FL-66420',
      expiryDate: '2025-10-30',
      administrationDate: '2025-02-08',
      veterinarian: 'Dr. Sarah Wilson',
      crmvNumber: 'CRMV-SP 12345',
      status: 'approved',
      submissionDate: '2025-02-09',
      validationDate: '2025-02-11',
      validator: 'Dr. Michael Brown',
      owner: 'Sarah Wilson',
      notes: 'Initial vaccination in series, follow-up in 3-4 weeks'
    },
    { 
      id: 'VAC-2025-0959',
      petName: 'Rocky',
      petSpecies: 'Dog', 
      breed: 'German Shepherd',
      vaccineName: 'Bordetella',
      manufacturer: 'CanineHealth',
      batchNumber: 'BD-12785',
      expiryDate: '2025-09-15',
      administrationDate: '2025-02-05',
      veterinarian: 'Dr. Sarah Wilson',
      crmvNumber: 'CRMV-SP 12345',
      status: 'pending',
      submissionDate: '2025-02-06',
      owner: 'Thomas Anderson',
      notes: 'Administered via intranasal route'
    }
  ];

  // Filter and search logic
  const filteredVaccines = vaccineData
    .filter(vaccine => filterStatus === 'all' || vaccine.status === filterStatus)
    .filter(vaccine => 
      searchTerm === '' || 
      vaccine.petName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      vaccine.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      vaccine.owner.toLowerCase().includes(searchTerm.toLowerCase()) ||
      vaccine.vaccineName.toLowerCase().includes(searchTerm.toLowerCase())
    );

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
    // Here you would typically call your API to delete the vaccine
    console.log('Deleting vaccine:', vaccineId);
    // Update local state after successful deletion
  };

  const handleEditClick = (vaccine) => {
    setSelectedVaccine(vaccine);
    setIsEditModalOpen(true);
  };

  const handleSaveEdit = (updatedVaccine) => {
    // Here you would typically call your API to update the vaccine
    console.log('Saving updated vaccine:', updatedVaccine);
    // Update local state after successful update
  };

  return (
    <div className="container mx-auto p-6">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-800 mb-2">Validação de Vacinas</h1>
        <p className="text-gray-600">
          Revise e valide os registros de vacinação associados ao seu registro CRMV. 
          Todas as vacinas administradas requerem validação para garantir conformidade com os padrões regulatórios e manter registros de saúde precisos.
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow">
          <div className="flex items-center justify-between">
            <div>
              <div className="text-sm text-gray-500">Total de Registros</div>
              <div className="text-2xl font-bold">{vaccineData.length}</div>
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
              <div className="text-2xl font-bold">{vaccineData.filter(v => v.status === 'pending').length}</div>
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
              <div className="text-2xl font-bold">{vaccineData.filter(v => v.status === 'approved').length}</div>
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
              <div className="text-2xl font-bold">{vaccineData.filter(v => v.status === 'rejected').length}</div>
            </div>
            <div className="bg-red-100 p-2 rounded-full">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
          </div>
        </div>
      </div>

      {/* Filters and Actions */}
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
            Mostrando {filteredVaccines.length} de {vaccineData.length} registros
          </span>
        </div>
      </div>

      {/* Vaccines Table */}
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
                    <div className="text-sm text-gray-500">{vaccine.administrationDate}</div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm font-medium text-gray-900">{vaccine.petName}</div>
                    <div className="text-sm text-gray-500">{vaccine.owner}</div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm font-medium text-gray-900">{vaccine.vaccineName}</div>
                    <div className="text-sm text-gray-500">Batch: {vaccine.batchNumber}</div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm font-medium text-gray-900">{vaccine.crmvNumber}</div>
                    <div className="text-sm text-gray-500">{vaccine.veterinarian}</div>
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
                    <button 
                      className="text-gray-600 hover:text-gray-900 font-medium text-sm mr-3"
                      onClick={() => handleEditClick(vaccine)}
                    >
                      Editar
                    </button>
                    <button 
                      className="text-red-600 hover:text-red-900 font-medium text-sm"
                      onClick={() => handleDeleteClick(vaccine)}
                    >
                      Excluir
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

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
  );
};

export default VaccinePage;