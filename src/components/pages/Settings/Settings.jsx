import React, { useState, useEffect } from 'react';
import { useUser } from '../../../hooks/useUser';

const Settings = () => {
  const [activeTab, setActiveTab] = useState('profile');
  const { userData, loading, updateUserData } = useUser();
  const [role, setRole] = useState('veterinarian');
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    cpf: '',
    street: '',
    number: '',
    complement: '',
    neighborhood: '',
    city: '',
    state: '',
    zipCode: '',
    crmv: '',
    specialties: [],
    yearsOfExperience: 0,
    clinicId: '',
    notifications: false,
    darkMode: false,
    language: 'pt-BR',
    twoFactorAuth: false
  });

  // Update formData when userData changes
  useEffect(() => {
    if (userData) {
      setFormData({
        name: userData.name || '',
        email: userData.email || '',
        phone: userData.phone || '',
        cpf: userData.cpf || '',
        street: userData.address?.street || '',
        number: userData.address?.number || '',
        complement: userData.address?.complement || '',
        neighborhood: userData.address?.neighborhood || '',
        city: userData.address?.city || '',
        state: userData.address?.state || '',
        zipCode: userData.address?.zipCode || '',
        crmv: userData.crmv || '',
        specialties: userData.specialties || [],
        yearsOfExperience: userData.yearsOfExperience || 0,
        clinicId: userData.clinicId || '',
        notifications: userData.notifications || false,
        darkMode: userData.darkMode || false,
        language: userData.language || 'pt-BR',
        twoFactorAuth: userData.twoFactorAuth || false
      });
      setRole(userData.role || 'veterinarian');
    }
  }, [userData]);
  
  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData({
      ...formData,
      [name]: type === 'checkbox' ? checked : value
    });
  };
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    const success = await updateUserData(formData);
    if (success) {
      alert('Configurações salvas com sucesso!');
    } else {
      alert('Erro ao salvar configurações. Tente novamente.');
    }
  };

  if (loading) {
    return <div className="container mx-auto p-6">Loading...</div>;
  }

  return (
    <div className="container mx-auto p-6 bg-gray-50 min-h-screen">
      <h1 className="text-3xl font-bold mb-6 text-gray-800">Configurações</h1>
      
      {/* Tabs */}
      <div className="flex mb-6 border-b border-gray-200">
        <button 
          className={`py-2 px-4 font-medium ${activeTab === 'profile' ? 'text-blue-600 border-b-2 border-blue-600' : 'text-gray-500'}`}
          onClick={() => setActiveTab('profile')}
        >
          Perfil
        </button>
        <button 
          className={`py-2 px-4 font-medium ${activeTab === 'address' ? 'text-blue-600 border-b-2 border-blue-600' : 'text-gray-500'}`}
          onClick={() => setActiveTab('address')}
        >
          Endereço
        </button>
        <button 
          className={`py-2 px-4 font-medium ${activeTab === 'professional' ? 'text-blue-600 border-b-2 border-blue-600' : 'text-gray-500'}`}
          onClick={() => setActiveTab('professional')}
        >
          {role === 'veterinarian' ? 'Profissional' : 'Informações do Pet'}
        </button>
        <button 
          className={`py-2 px-4 font-medium ${activeTab === 'system' ? 'text-blue-600 border-b-2 border-blue-600' : 'text-gray-500'}`}
          onClick={() => setActiveTab('system')}
        >
          Sistema
        </button>
      </div>
      
      <div className="bg-white rounded-lg shadow p-6">
        <form onSubmit={handleSubmit}>
          
          {/* Profile Settings */}
          {activeTab === 'profile' && (
            <div className="space-y-6">
              <div className="flex items-center space-x-6 mb-6">
                <div className="w-24 h-24 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden">
                  <span className="text-3xl text-gray-500">
                    {formData.name.split(' ').map(n => n[0]).join('')}
                  </span>
                </div>
                <div>
                  <button type="button" className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
                    Enviar Foto
                  </button>
                </div>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Nome
                  </label>
                  <input 
                    type="text" 
                    name="name" 
                    value={formData.name} 
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    E-mail
                  </label>
                  <input 
                    type="email" 
                    name="email" 
                    value={formData.email} 
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Telefone
                  </label>
                  <input 
                    type="text" 
                    name="phone" 
                    value={formData.phone} 
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    CPF
                  </label>
                  <input 
                    type="text" 
                    name="cpf" 
                    value={formData.cpf} 
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Tipo de Conta
                </label>
                <div className="flex space-x-4">
                  <label className="flex items-center">
                    <input 
                      type="radio" 
                      name="role"
                      checked={role === 'veterinarian'} 
                      onChange={() => setRole('veterinarian')}
                      className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300"
                    />
                    <span className="ml-2 text-gray-700">Veterinário</span>
                  </label>
                </div>
              </div>
            </div>
          )}
          
          {/* Address Settings */}
          {activeTab === 'address' && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Rua
                  </label>
                  <input 
                    type="text" 
                    name="street" 
                    value={formData.street} 
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Número
                    </label>
                    <input 
                      type="text" 
                      name="number" 
                      value={formData.number} 
                      onChange={handleChange}
                      className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Complemento
                    </label>
                    <input 
                      type="text" 
                      name="complement" 
                      value={formData.complement} 
                      onChange={handleChange}
                      className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Bairro
                  </label>
                  <input 
                    type="text" 
                    name="neighborhood" 
                    value={formData.neighborhood} 
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    CEP
                  </label>
                  <input 
                    type="text" 
                    name="zipCode" 
                    value={formData.zipCode} 
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Cidade
                  </label>
                  <input 
                    type="text" 
                    name="city" 
                    value={formData.city} 
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Estado
                  </label>
                  <select 
                    name="state" 
                    value={formData.state} 
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="AC">AC</option>
                    <option value="AL">AL</option>
                    <option value="SP">SP</option>
                    <option value="RJ">RJ</option>
                    <option value="MG">MG</option>
                    {/* Add other Brazilian states */}
                  </select>
                </div>
              </div>
            </div>
          )}
          
          {/* Professional/Pet Settings */}
          {activeTab === 'professional' && role === 'veterinarian' && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    CRMV
                  </label>
                  <input 
                    type="text" 
                    name="crmv" 
                    value={formData.crmv} 
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Anos de Experiência
                  </label>
                  <input 
                    type="number" 
                    name="yearsOfExperience" 
                    value={formData.yearsOfExperience} 
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Especialidades
                  </label>
                  <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
                    {['Dermatology', 'Surgery', 'Cardiology', 'Oncology', 'Neurology', 'Orthopedics'].map(specialty => (
                      <label key={specialty} className="flex items-center p-2 border rounded-md">
                        <input 
                          type="checkbox" 
                          checked={formData.specialties.includes(specialty)}
                          onChange={(e) => {
                            if (e.target.checked) {
                              setFormData({
                                ...formData,
                                specialties: [...formData.specialties, specialty]
                              });
                            } else {
                              setFormData({
                                ...formData,
                                specialties: formData.specialties.filter(s => s !== specialty)
                              });
                            }
                          }}
                          className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                        />
                        <span className="ml-2 text-sm text-gray-700">{specialty}</span>
                      </label>
                    ))}
                  </div>
                </div>
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    ID da Clínica
                  </label>
                  <input 
                    type="text" 
                    name="clinicId" 
                    value={formData.clinicId} 
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
              </div>
            </div>
          )}
          
          {activeTab === 'professional' && role === 'tutor' && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="md:col-span-2">
                  <h3 className="text-lg font-medium text-gray-900 mb-4">Contato de Emergência</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Nome
                      </label>
                      <input 
                        type="text" 
                        name="emergencyContactName" 
                        value={formData.emergencyContactName} 
                        onChange={handleChange}
                        className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Telefone
                      </label>
                      <input 
                        type="text" 
                        name="emergencyContactPhone" 
                        value={formData.emergencyContactPhone} 
                        onChange={handleChange}
                        className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                    <div className="md:col-span-2">
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Relação
                      </label>
                      <input 
                        type="text" 
                        name="emergencyContactRelationship" 
                        value={formData.emergencyContactRelationship} 
                        onChange={handleChange}
                        className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}
          
          {/* System Settings */}
          {activeTab === 'system' && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 gap-6">
                <div>
                  <label className="flex items-center">
                    <input 
                      type="checkbox" 
                      name="notifications" 
                      checked={formData.notifications} 
                      onChange={handleChange}
                      className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                    />
                    <span className="ml-2 text-sm text-gray-700">Ativar Notificações</span>
                  </label>
                </div>
                <div>
                  <label className="flex items-center">
                    <input 
                      type="checkbox" 
                      name="darkMode" 
                      checked={formData.darkMode} 
                      onChange={handleChange}
                      className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                    />
                    <span className="ml-2 text-sm text-gray-700">Modo Escuro</span>
                  </label>
                </div>
                <div>
                  <label className="flex items-center">
                    <input 
                      type="checkbox" 
                      name="twoFactorAuth" 
                      checked={formData.twoFactorAuth} 
                      onChange={handleChange}
                      className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                    />
                    <span className="ml-2 text-sm text-gray-700">Ativar Autenticação em Dois Fatores</span>
                  </label>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Idioma
                  </label>
                  <select 
                    name="language" 
                    value={formData.language} 
                    onChange={handleChange}
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="pt-BR">Português (Brasil)</option>
                    <option value="en-US">English (US)</option>
                    <option value="es-ES">Español</option>
                  </select>
                </div>
              </div>
            </div>
          )}
          
          {/* Form Buttons */}
          <div className="mt-6 flex items-center justify-end space-x-4">
            <button 
              type="button" 
              className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              onClick={() => {
                // Reset form logic here
              }}
            >
              Cancelar
            </button>
            <button 
              type="submit" 
              className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Salvar Alterações
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default Settings;