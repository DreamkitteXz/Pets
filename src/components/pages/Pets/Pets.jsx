import React, { useState } from 'react';
import { CiFilter } from "react-icons/ci";
import PetDetailsModal from './PetDetailsModal';
import PetEditModal from './PetEditModal';
import { usePets } from '../../../hooks/usePets';
import { useAuth } from '../../../context/AuthContext'; // Correct import path

const PetsPage = () => {
  const [filterStatus, setFilterStatus] = useState('all');
  const [selectedPet, setSelectedPet] = useState(null);
  const [isDetailsModalOpen, setIsDetailsModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  
  const { pets, loading, error } = usePets();
  const { user } = useAuth(); // Ensure useAuth is used within AuthProvider
  const userId = user?.id; // Extract userId from user object

  // Early return for loading state
  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-yellow-500"></div>
      </div>
    );
  }

  // Early return for error state
  if (error) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-red-500">Error loading pets: {error.message}</div>
      </div>
    );
  }

  // Ensure pets is always an array
  const petsArray = Array.isArray(pets) ? pets : [];

  // Filter pets based on status
  const filteredPets = filterStatus === 'all' 
    ? petsArray 
    : petsArray.filter(pet => pet.status === filterStatus);

  const getStatusColor = (status) => {
    switch (status) {
      case 'validated':
        return 'text-green-600 bg-green-100';
      case 'waiting validation':
        return 'text-yellow-600 bg-yellow-100';
      case 'recused':
        return 'text-red-600 bg-red-100';
      default:
        return 'text-gray-600 bg-gray-100';
    }
  };

  const getNextVaccineDate = (pet) => {
    if (!pet.vaccines || pet.vaccines.length === 0) return 'Sem vacinas';
    
    const upcomingVaccines = pet.vaccines
      .filter(v => v.nextDate && new Date(v.nextDate) > new Date())
      .sort((a, b) => new Date(a.nextDate) - new Date(b.nextDate));
    
    if (upcomingVaccines.length === 0) return 'Todas as vacinas em dia';
    
    const nextVaccine = upcomingVaccines[0];
    return `${nextVaccine.name}: ${new Date(nextVaccine.nextDate).toLocaleDateString('pt-BR')}`;
  };

  const getPetAge = (birthDate) => {
    const birth = new Date(birthDate);
    const now = new Date();
    const ageInMonths = (now.getFullYear() - birth.getFullYear()) * 12 + (now.getMonth() - birth.getMonth());
    
    if (ageInMonths < 12) {
      return `${ageInMonths} ${ageInMonths === 1 ? 'mês' : 'meses'}`;
    }
    
    const ageInYears = Math.floor(ageInMonths / 12);
    return `${ageInYears} ${ageInYears === 1 ? 'ano' : 'anos'}`;
  };

  const handleViewPet = (pet) => {
    setSelectedPet(pet);
    setIsDetailsModalOpen(true);
  };

  const handleEditPet = (pet) => {
    setSelectedPet(pet);
    setIsEditModalOpen(true);
  };

  const handleSavePet = (updatedPet) => {
    // Here you would typically update the pet data in your backend
    console.log('Saving updated pet:', updatedPet);
  };

  const getUserVaccinesCount = (pet, userId) => {
    return pet.vaccines?.filter(vaccine => vaccine.ownerId === userId).length || 0;
  };

  return (
    <div className="container mx-auto p-6">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-800 mb-2">Gerenciamento de Pets</h1>
        <p className="text-gray-600">
          Acompanhe o status de vacinação, próximas consultas e informações de saúde dos pets. 
          Use os filtros para encontrar rapidamente os pets com base em seu status de vacinação.
        </p>
      </div>

      {/* Filters and Actions */}
      <div className="flex flex-wrap items-center justify-between mb-6 gap-4">
        <div className="flex items-center gap-3">
          <div className="flex items-center bg-white rounded-lg shadow-sm p-2 border">
            <CiFilter className="text-gray-500 mr-2" size={18} />
            <select 
              className="border-none bg-transparent focus:outline-none text-sm"
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
            >
              <option value="all">Todos os Status</option>
              <option value="validated">Validado</option>
              <option value="waiting validation">Aguardando Validação</option>
              <option value="recused">Recusado</option>
            </select>
          </div>
          
          <span className="text-sm text-gray-500">
            Mostrando {filteredPets.length} de {petsArray.length} pets
          </span>
        </div>
      </div>

      {/* Pets Table */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        {petsArray.length === 0 ? (
          <div className="p-4 text-center text-gray-500">
            Nenhum pet encontrado.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Pet
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Proprietário
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status da Vacina
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Próxima Vacina
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ações
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredPets.map((pet) => (
                  <tr key={pet.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="flex-shrink-0 h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center text-gray-500">
                          {pet.species === 'Dog' ? (
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.5 14h-.79l-.28-.27a6.5 6.5 0 001.48-5.34c-.47-2.78-2.79-5-5.59-5.34a6.505 6.505 0 00-7.27 7.27c.34 2.8 2.56 5.12 5.34 5.59a6.5 6.5 0 005.34-1.48l.27.28v.79l4.25 4.25c.41.41 1.08.41 1.49 0 .41-.41.41-1.08 0-1.49L15.5 14z" />
                            </svg>
                          ) : (
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 15v-1a4 4 0 00-4-4H8m0 0l3 3m-3-3l3-3m9 14V5a2 2 0 00-2-2H6a2 2 0 00-2 2v16l4-2 4 2 4-2 4 2z" />
                            </svg>
                          )}
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">{pet.name}</div>
                          <div className="text-sm text-gray-500">{pet.species} • {pet.breed} • {getPetAge(pet.birthDate)}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">{pet.owner}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(pet.status)}`}>
                        {pet.status?.charAt(0).toUpperCase() + pet.status?.slice(1)}
                      </span>
                      <div className="text-xs text-gray-500 mt-1">
                        {getUserVaccinesCount(pet, userId)} vacinas registradas
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {getNextVaccineDate(pet)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button 
                        className="text-blue-600 hover:text-blue-900 mr-3"
                        onClick={() => handleViewPet(pet)}
                      >
                        Visualizar
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Vaccination Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mt-8">
        <div className="bg-white p-4 rounded-lg shadow border-l-4 border-green-500">
          <div className="text-green-600 text-lg font-semibold">Validados</div>
          <div className="text-3xl font-bold mt-1">
            {petsArray.filter(pet => pet.status === 'validated').length}
          </div>
          <div className="text-sm text-gray-500 mt-1">pets com vacinação completa</div>
        </div>
        
        <div className="bg-white p-4 rounded-lg shadow border-l-4 border-yellow-500">
          <div className="text-yellow-600 text-lg font-semibold">Aguardando Validação</div>
          <div className="text-3xl font-bold mt-1">
            {petsArray.filter(pet => pet.status === 'waiting validation').length}
          </div>
          <div className="text-sm text-gray-500 mt-1">pets precisam de revisão</div>
        </div>
        
        <div className="bg-white p-4 rounded-lg shadow border-l-4 border-red-500">
          <div className="text-red-600 text-lg font-semibold">Recusados</div>
          <div className="text-3xl font-bold mt-1">
            {petsArray.filter(pet => pet.status === 'recused').length}
          </div>
          <div className="text-sm text-gray-500 mt-1">pets com problemas na vacinação</div>
        </div>
        
        <div className="bg-white p-4 rounded-lg shadow border-l-4 border-blue-500">
          <div className="text-blue-600 text-lg font-semibold">Vence Este Mês</div>
          <div className="text-3xl font-bold mt-1">3</div>
          <div className="text-sm text-gray-500 mt-1">pets precisam de vacinação em breve</div>
        </div>
      </div>

      {/* Add modals */}
      <PetDetailsModal
        isOpen={isDetailsModalOpen}
        onClose={() => setIsDetailsModalOpen(false)}
        pet={selectedPet}
      />

      <PetEditModal
        isOpen={isEditModalOpen}
        onClose={() => setIsEditModalOpen(false)}
        pet={selectedPet}
        onSave={handleSavePet}
      />
    </div>
  );
};

export default PetsPage;