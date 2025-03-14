import React from 'react';
import Table from './../../tables/Table'; // Assuming the Table component is in a separate file

const VeterinaryDashboard = () => {
  // Define table columns
  const columns = [
    { key: 'petName', header: 'Pet Name' },
    { key: 'species', header: 'Species' },
    { key: 'breed', header: 'Breed' },
    { key: 'age', header: 'Age', render: (value) => `${value} years` },
    { key: 'owner', header: 'Owner' },
    { key: 'lastVisit', header: 'Last Visit' },
    { 
      key: 'status', 
      header: 'Status',
      render: (value, row) => {
        const statusColors = {
          'Healthy': 'text-green-500',
          'Recovering': 'text-yellow-500',
          'Treatment': 'text-blue-500',
          'Critical': 'text-red-500'
        };
        return <span className={`font-medium ${statusColors[value] || ''}`}>{value}</span>;
      }
    },
    { key: 'nextAppointment', header: 'Next Appointment' },
  ];

  // Sample veterinary data
  const petData = [
    { id: 1, petName: 'Max', species: 'Dog', breed: 'Labrador', age: 5, owner: 'John Smith', lastVisit: '2025-03-01', status: 'Healthy', nextAppointment: '2025-06-01' },
    { id: 2, petName: 'Luna', species: 'Cat', breed: 'Siamese', age: 3, owner: 'Emily Johnson', lastVisit: '2025-02-15', status: 'Recovering', nextAppointment: '2025-03-20' },
    { id: 3, petName: 'Charlie', species: 'Dog', breed: 'Beagle', age: 7, owner: 'Michael Brown', lastVisit: '2025-03-05', status: 'Treatment', nextAppointment: '2025-03-19' },
    { id: 4, petName: 'Bella', species: 'Cat', breed: 'Persian', age: 4, owner: 'Sarah Wilson', lastVisit: '2025-02-28', status: 'Healthy', nextAppointment: '2025-05-28' },
    { id: 5, petName: 'Rocky', species: 'Dog', breed: 'German Shepherd', age: 6, owner: 'David Lee', lastVisit: '2025-03-10', status: 'Critical', nextAppointment: '2025-03-15' },
  ];

  return (
    <div className="container mx-auto p-4">
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">Veterinary Practice Dashboard</h1>
        <p className="text-gray-600 mb-6">
          Monitor patient status, upcoming appointments, and critical cases at a glance. 
          This dashboard provides essential information for veterinary staff to prioritize care and follow up with patients.
        </p>
      </div>

      <div className="bg-white rounded-lg shadow p-6 mb-6">
        <h2 className="text-xl font-semibold mb-4">Patient Overview</h2>
        <Table 
          columns={columns} 
          data={petData} 
          rowKey="id" 
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-lg shadow p-4">
          <h2 className="text-lg font-semibold mb-2">Critical Cases</h2>
          <div className="text-red-500 font-medium">
            {petData.filter(pet => pet.status === 'Critical').length} patients
          </div>
          <p className="text-gray-500">Requiring immediate attention</p>
        </div>
        
        <div className="bg-white rounded-lg shadow p-4">
          <h2 className="text-lg font-semibold mb-2">Today's Appointments</h2>
          <div className="text-blue-500 font-medium">3 appointments</div>
          <p className="text-gray-500">Scheduled for today</p>
        </div>
        
        <div className="bg-white rounded-lg shadow p-4">
          <h2 className="text-lg font-semibold mb-2">Follow-ups Needed</h2>
          <div className="text-yellow-500 font-medium">2 patients</div>
          <p className="text-gray-500">Require follow-up calls</p>
        </div>
      </div>
    </div>
  );
};

export default VeterinaryDashboard;