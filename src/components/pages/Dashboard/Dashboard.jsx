import React, { useState } from 'react';
import { useDashboard } from '../../../hooks/useDashboard';
import Table from '../../tables/Table';
import { formatDate } from '../../../utils/formatters';
import LoadingScreen from '../../ui/LoadingScreen';

const Dashboard = () => {
  const { dashboardData, loading, error } = useDashboard();
  const [showDevMessage, setShowDevMessage] = useState(false);

  if (loading) return <LoadingScreen />;
  if (error) return <div>Erro ao carregar dados do dashboard</div>;
  if (!dashboardData) return null;

  const columns = [
    { key: 'name', header: 'Nome do Pet' },
    { key: 'species', header: 'Espécie' },
    { key: 'breed', header: 'Raça' },
    { 
      key: 'birthDate', 
      header: 'Idade',
      render: (date) => {
        const years = date ? Math.floor((new Date() - new Date(date)) / (1000 * 60 * 60 * 24 * 365)) : 0;
        return `${years} anos`;
      }
    },
    { key: 'ownerName', header: 'Tutor' },
    { 
      key: 'lastVisit', 
      header: 'Última Visita',
      render: (date) => date ? formatDate(date) : 'N/A'
    },
    { 
      key: 'status', 
      header: 'Status',
      render: (value) => {
        const statusColors = {
          'healthy': 'text-green-500',
          'recovering': 'text-yellow-500',
          'treatment': 'text-blue-500',
          'critical': 'text-red-500'
        };
        const statusText = {
          'healthy': 'Saudável',
          'recovering': 'Em Recuperação',
          'treatment': 'Em Tratamento',
          'critical': 'Crítico'
        };
        return <span className={`font-medium ${statusColors[value] || ''}`}>
          {statusText[value] || value}
        </span>;
      }
    }
  ];

  const handleConsultationClick = () => {
    setShowDevMessage(true);
    setTimeout(() => setShowDevMessage(false), 3000);
  };

  return (
    <div className="container mx-auto p-4">
      {/* Development Message Toast */}
      {showDevMessage && (
        <div className="fixed bottom-4 right-4 bg-yellow-100 text-yellow-800 px-4 py-2 rounded-lg shadow-lg z-20">
          🚧 Sistema de consultas em desenvolvimento
        </div>
      )}

      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">Dashboard Veterinário</h1>
        <p className="text-gray-600 mb-6">
          Monitore seus pacientes, consultas e casos críticos.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div className="bg-white rounded-lg shadow p-4">
          <h2 className="text-lg font-semibold mb-2">Pacientes Totais</h2>
          <div className="text-blue-500 font-medium text-2xl">
            {dashboardData.totalPets}
          </div>
          <p className="text-gray-500">Pets cadastrados</p>
        </div>
        
        <div className="bg-white rounded-lg shadow p-4">
          <h2 className="text-lg font-semibold mb-2">Consultas Hoje</h2>
          <div className="text-blue-500 font-medium text-2xl">
            {dashboardData.todayAppointments.length}
          </div>
          <p className="text-gray-500">Agendadas para hoje</p>
        </div>
        
        <div className="bg-white rounded-lg shadow p-4">
          <h2 className="text-lg font-semibold mb-2">Casos Críticos</h2>
          <div className="text-red-500 font-medium text-2xl">
            {dashboardData.criticalCases}
          </div>
          <p className="text-gray-500">Necessitam atenção</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-6 mb-6">
        <h2 className="text-xl font-semibold mb-4">Pacientes Recentes</h2>
        <Table 
          columns={columns} 
          data={dashboardData.recentPets} 
          rowKey="id" 
        />
      </div>

      {dashboardData.todayAppointments.length > 0 && (
        <div className="bg-white rounded-lg shadow p-6 relative">
          <div className="absolute inset-0 bg-gray-50/50 backdrop-blur-[1px] z-10 flex items-center justify-center">
            <span className="bg-yellow-100 text-yellow-800 px-3 py-1 rounded-lg text-sm">
              🚧 Em desenvolvimento
            </span>
          </div>
          <h2 className="text-xl font-semibold mb-4">Consultas de Hoje</h2>
          <div className="space-y-4">
            {dashboardData.todayAppointments.map(appointment => (
              <div 
                key={appointment.id} 
                className="flex items-center justify-between border-b pb-4 cursor-pointer hover:bg-gray-50 transition-colors p-2 rounded"
                onClick={handleConsultationClick}
              >
                <div>
                  <h3 className="font-medium">{appointment.petName}</h3>
                  <p className="text-gray-500">{formatDate(appointment.date)}</p>
                </div>
                <span className={`px-3 py-1 rounded-full text-sm ${
                  appointment.status === 'scheduled' ? 'bg-blue-100 text-blue-800' :
                  appointment.status === 'completed' ? 'bg-green-100 text-green-800' :
                  'bg-gray-100 text-gray-800'
                }`}>
                  {appointment.status === 'scheduled' ? 'Agendada' :
                   appointment.status === 'completed' ? 'Concluída' :
                   'Cancelada'}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default Dashboard;