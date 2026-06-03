import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { auth } from '../../../config/firebase';
import { getFirestore, doc, updateDoc } from 'firebase/firestore';
import { validateCPF, validateCRMV, formatCPF, formatCEP } from '../../../utils/validation';
import { lookupCEP } from '../../../services/addressService';
import { Stethoscope, Clipboard, MapPin, User, CheckCircle, AlertCircle } from 'lucide-react';

const db = getFirestore();

const CompleteProfile = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    fullName: '',
    cpf: '',
    crmv: '',
    specialties: [],
    yearsOfExperience: '',
    address: {
      street: '',
      number: '',
      complement: '',
      neighborhood: '',
      city: '',
      state: '',
      zipCode: ''
    },
    phone: ''  // Add phone field
  });
  
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [validationErrors, setValidationErrors] = useState({});
  const [isAddressLookupLoading, setIsAddressLookupLoading] = useState(false);
  const [step, setStep] = useState(1);
  
  const specialtyOptions = [
    'Pequenos Animais', 'Grandes Animais', 'Pets Exóticos', 'Aves', 
    'Dermatologia', 'Cardiologia', 'Neurologia', 'Ortopedia',
    'Cirurgia', 'Emergência', 'Oncologia', 'Acupuntura Integrativa'
  ];

  const handleCEPLookup = async (cep) => {
    if (cep.replace(/\D/g, '').length !== 8) return;

    setIsAddressLookupLoading(true);
    try {
      const addressData = await lookupCEP(cep.replace(/\D/g, ''));
      setFormData(prev => ({
        ...prev,
        address: {
          ...prev.address,
          ...addressData
        }
      }));
      setSuccess('Endereço encontrado com sucesso!');
      setTimeout(() => setSuccess(''), 3000);
    } catch (error) {
      setError('Erro ao buscar endereço');
      setTimeout(() => setError(''), 3000);
    } finally {
      setIsAddressLookupLoading(false);
    }
  };

  const validateForm = () => {
    const errors = {};
    
    if (!validateCPF(formData.cpf)) {
      errors.cpf = 'CPF inválido';
    }
    
    if (!validateCRMV(formData.crmv)) {
      errors.crmv = 'Formato de CRMV inválido (CRMV-XX 12345)';
    }
    
    if (!formData.address.zipCode) {
      errors.zipCode = 'CEP é obrigatório';
    }
    
    if (formData.specialties.length === 0) {
      errors.specialties = 'Selecione pelo menos uma especialidade';
    }

    setValidationErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    
    if (name === 'cpf') {
      const formattedCPF = formatCPF(value);
      setFormData(prev => ({ ...prev, cpf: formattedCPF }));
      setValidationErrors(prev => ({ ...prev, cpf: validateCPF(formattedCPF) ? '' : 'Invalid CPF' }));
    } else if (name === 'crmv') {
      setFormData(prev => ({ ...prev, crmv: value.toUpperCase() }));
      setValidationErrors(prev => ({ ...prev, crmv: validateCRMV(value) ? '' : 'Invalid CRMV format' }));
    } else if (name === 'address.zipCode') {
      const formattedCEP = formatCEP(value);
      setFormData(prev => ({
        ...prev,
        address: { ...prev.address, zipCode: formattedCEP }
      }));
      if (formattedCEP.length === 9) {
        handleCEPLookup(formattedCEP);
      }
    } else if (name.includes('.')) {
      const [parent, child] = name.split('.');
      setFormData(prev => ({
        ...prev,
        [parent]: {
          ...prev[parent],
          [child]: value
        }
      }));
    } else {
      setFormData(prev => ({
        ...prev,
        [name]: value
      }));
    }
  };
  
  const handleSpecialtyChange = (specialty) => {
    setFormData(prev => {
      if (prev.specialties.includes(specialty)) {
        return {
          ...prev,
          specialties: prev.specialties.filter(s => s !== specialty)
        };
      } else {
        return {
          ...prev,
          specialties: [...prev.specialties, specialty]
        };
      }
    });
    setValidationErrors(prev => ({ ...prev, specialties: '' }));
  };

  const handleNextStep = () => {
    if (step === 1) {
      if (!formData.fullName || !formData.cpf || !formData.crmv || formData.specialties.length === 0) {
        setError('Por favor, preencha todos os campos obrigatórios para continuar');
        setTimeout(() => setError(''), 3000);
        return;
      }
      if (validationErrors.cpf || validationErrors.crmv) {
        setError('Por favor, corrija os erros de validação antes de continuar');
        setTimeout(() => setError(''), 3000);
        return;
      }
    }
    setStep(step + 1);
  };

  const handlePrevStep = () => {
    setStep(step - 1);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;
    
    setLoading(true);
    setError('');

    try {
      const user = auth.currentUser;
      if (!user) throw new Error('No authenticated user found');

      const userRef = doc(db, "users", user.uid);
      // COMENTADO: profileCompleted removido da atualização
      // A aplicação agora permite acesso completo sem verificar este campo
      await updateDoc(userRef, {
        ...formData,
        role: 'veterinarian',
        updatedAt: new Date().toISOString(),
        status: 'active'
        // profileCompleted: true
      });

      setSuccess('Profile completed successfully! Redirecting to dashboard...');
      setTimeout(() => navigate('/'), 2000);
    } catch (error) {
      setError(error.message);
      setTimeout(() => setError(''), 3000);
    } finally {
      setLoading(false);
    }
  };

  const renderStepIndicator = () => {
    return (
      <div className="flex items-center justify-center mb-8">
        <div className={`flex items-center ${step >= 1 ? 'text-teal-600' : 'text-gray-400'}`}>
          <div className={`rounded-full transition duration-500 ease-in-out h-12 w-12 flex items-center justify-center py-3 border-2 ${step >= 1 ? 'border-teal-600 bg-teal-100' : 'border-gray-300'}`}>
            <User size={24} />
          </div>
          <div className="text-center text-xs mt-2">Informações Profissionais</div>
        </div>
        
        <div className={`flex-auto border-t-2 transition duration-500 ease-in-out ${step >= 2 ? 'border-teal-600' : 'border-gray-300'}`}></div>
        
        <div className={`flex items-center ${step >= 2 ? 'text-teal-600' : 'text-gray-400'}`}>
          <div className={`rounded-full transition duration-500 ease-in-out h-12 w-12 flex items-center justify-center py-3 border-2 ${step >= 2 ? 'border-teal-600 bg-teal-100' : 'border-gray-300'}`}>
            <MapPin size={24} />
          </div>
          <div className="text-center text-xs mt-2">Endereço</div>
        </div>
      </div>
    );
  };

  return (
    <div className="min-h-screen py-8 px-4 bg-gray-50">
      <div className="max-w-3xl mx-auto bg-white rounded-lg shadow-lg p-8">
        <div className="flex items-center justify-center mb-6">
          <Stethoscope size={32} className="text-blue-600 mr-2" />
          <h2 className="text-3xl font-bold text-gray-800">Complete Seu Perfil Veterinário</h2>
        </div>

        {renderStepIndicator()}
        
        {success && (
          <div className="mb-6 p-3 bg-green-100 border border-green-400 text-green-700 rounded-lg flex items-center">
            <CheckCircle size={20} className="mr-2" />
            {success}
          </div>
        )}
        
        {error && (
          <div className="mb-6 p-3 bg-red-100 border border-red-400 text-red-700 rounded-lg flex items-center">
            <AlertCircle size={20} className="mr-2" />
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-6">
          {step === 1 && (
            <div className="space-y-6">
              <div className="flex items-center space-x-6 mb-6">
                <div className="w-24 h-24 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden">
                  <span className="text-3xl text-gray-500">
                    {formData.fullName.split(' ').map(n => n[0]).join('')}
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
                  <label className="block text-sm font-medium text-gray-700">
                    Nome Completo <span className="text-red-500">*</span>
                  </label>
                  <input 
                    type="text" 
                    name="fullName" 
                    value={formData.fullName} 
                    onChange={handleChange}
                    className="mt-1 w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Telefone <span className="text-red-500">*</span>
                  </label>
                  <input 
                    type="tel" 
                    name="phone" 
                    value={formData.phone} 
                    onChange={handleChange}
                    placeholder="(00) 00000-0000"
                    className="mt-1 w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">CPF <span className="text-red-500">*</span></label>
                  <div className="mt-1 relative rounded-md shadow-sm">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <Clipboard size={16} className="text-gray-400" />
                    </div>
                    <input
                      type="text"
                      name="cpf"
                      value={formData.cpf}
                      onChange={handleChange}
                      maxLength="14"
                      className={`pl-10 block w-full rounded-md shadow-sm focus:ring-teal-500 focus:border-teal-500 ${
                        validationErrors.cpf ? 'border-red-300' : 'border-gray-300'
                      }`}
                      placeholder="000.000.000-00"
                      required
                    />
                  </div>
                  {validationErrors.cpf && (
                    <div className="text-red-600 text-sm mt-1 flex items-center">
                      <AlertCircle size={14} className="mr-1" />
                      {validationErrors.cpf}
                    </div>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">CRMV <span className="text-red-500">*</span></label>
                  <div className="mt-1 relative rounded-md shadow-sm">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <Clipboard size={16} className="text-gray-400" />
                    </div>
                    <input
                      type="text"
                      name="crmv"
                      value={formData.crmv}
                      onChange={handleChange}
                      className={`pl-10 block w-full rounded-md shadow-sm focus:ring-teal-500 focus:border-teal-500 ${
                        validationErrors.crmv ? 'border-red-300' : 'border-gray-300'
                      }`}
                      placeholder="CRMV-XX 12345"
                      required
                    />
                  </div>
                  {validationErrors.crmv && (
                    <div className="text-red-600 text-sm mt-1 flex items-center">
                      <AlertCircle size={14} className="mr-1" />
                      {validationErrors.crmv}
                    </div>
                  )}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Especialidades <span className="text-red-500">*</span></label>
                {validationErrors.specialties && (
                  <div className="text-red-600 text-sm mb-2 flex items-center">
                    <AlertCircle size={14} className="mr-1" />
                    {validationErrors.specialties}
                  </div>
                )}
                <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                  {specialtyOptions.map((specialty) => (
                    <div
                      key={specialty}
                      className={`
                        flex items-center rounded-md px-3 py-2 cursor-pointer border-2 transition-all
                        ${formData.specialties.includes(specialty)
                          ? 'bg-teal-100 border-teal-500 text-teal-700'
                          : 'bg-white border-gray-200 text-gray-700 hover:bg-gray-50'
                        }
                      `}
                      onClick={() => handleSpecialtyChange(specialty)}
                    >
                      <Stethoscope
                        size={16}
                        className={`mr-2 ${formData.specialties.includes(specialty) ? 'text-teal-600' : 'text-gray-400'}`}
                      />
                      {specialty}
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {step === 2 && (
            <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
              <div>
                <label className="block text-sm font-medium text-gray-700">CEP <span className="text-red-500">*</span></label>
                <div className="mt-1 relative rounded-md shadow-sm">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <MapPin size={16} className="text-gray-400" />
                  </div>
                  <input
                    type="text"
                    name="address.zipCode"
                    value={formData.address.zipCode}
                    onChange={handleChange}
                    className={`pl-10 block w-full rounded-md shadow-sm focus:ring-teal-500 focus:border-teal-500 ${
                      validationErrors.zipCode ? 'border-red-300' : 'border-gray-300'
                    }`}
                    placeholder="00000-000"
                    required
                  />
                </div>
                {isAddressLookupLoading && (
                  <div className="text-gray-600 text-sm mt-1">Looking up address...</div>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Rua <span className="text-red-500">*</span></label>
                <input
                  type="text"
                  name="address.street"
                  value={formData.address.street}
                  onChange={handleChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-teal-500 focus:ring-teal-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Número <span className="text-red-500">*</span></label>
                <input
                  type="text"
                  name="address.number"
                  value={formData.address.number}
                  onChange={handleChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-teal-500 focus:ring-teal-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Complemento</label>
                <input
                  type="text"
                  name="address.complement"
                  value={formData.address.complement}
                  onChange={handleChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-teal-500 focus:ring-teal-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Bairro <span className="text-red-500">*</span></label>
                <input
                  type="text"
                  name="address.neighborhood"
                  value={formData.address.neighborhood}
                  onChange={handleChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-teal-500 focus:ring-teal-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Cidade <span className="text-red-500">*</span></label>
                <input
                  type="text"
                  name="address.city"
                  value={formData.address.city}
                  onChange={handleChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-teal-500 focus:ring-teal-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Estado <span className="text-red-500">*</span></label>
                <input
                  type="text"
                  name="address.state"
                  value={formData.address.state}
                  onChange={handleChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-teal-500 focus:ring-teal-500"
                  maxLength="2"
                  required
                />
              </div>
            </div>
          )}

          <div className="flex justify-between pt-4">
            {step > 1 && (
              <button
                type="button"
                onClick={handlePrevStep}
                className="px-6 py-2 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-500"
              >
                Anterior
              </button>
            )}
            
            {step < 2 ? (
              <button
                type="button"
                onClick={handleNextStep}
                className="ml-auto px-6 py-2 bg-teal-600 text-white rounded-md hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-500"
              >
                Próximo
              </button>
            ) : (
              <button
                type="submit"
                disabled={loading}
                className={`ml-auto px-6 py-2 bg-teal-600 text-white rounded-md hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-500 ${
                  loading ? 'opacity-50 cursor-not-allowed' : ''
                }`}
              >
                {loading ? 'Salvando...' : 'Completar Perfil'}
              </button>
            )}
          </div>
        </form>
      </div>
    </div>
  );
};

export default CompleteProfile;