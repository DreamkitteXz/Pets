import React from 'react';
import { IoClose } from "react-icons/io5";

const PetDetailsModal = ({ isOpen, onClose, pet }) => {
  if (!isOpen || !pet) return null;

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
                <h3 className="font-semibold text-lg">Basic Information</h3>
                <div className="space-y-2">
                  <div>
                    <label className="block text-sm text-gray-600">Name</label>
                    <div className="font-medium">{pet.name}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Species</label>
                    <div className="font-medium">{pet.species}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Breed</label>
                    <div className="font-medium">{pet.breed}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Age</label>
                    <div className="font-medium">{pet.age} years</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Owner</label>
                    <div className="font-medium">{pet.owner}</div>
                  </div>
                </div>
              </div>

              <div className="space-y-4">
                <h3 className="font-semibold text-lg">Vaccination Status</h3>
                <div className="space-y-2">
                  <div>
                    <label className="block text-sm text-gray-600">Status</label>
                    <div className="font-medium capitalize">{pet.status}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Total Vaccines</label>
                    <div className="font-medium">{pet.vaccines.length}</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Vaccination History */}
            <div className="space-y-4">
              <h3 className="font-semibold text-lg">Vaccination History</h3>
              <div className="border rounded-lg overflow-hidden">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Vaccine</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Last Date</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Next Date</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {pet.vaccines.map((vaccine, index) => (
                      <tr key={index}>
                        <td className="px-4 py-3 text-sm">{vaccine.name}</td>
                        <td className="px-4 py-3 text-sm">{vaccine.lastDate || 'Not administered'}</td>
                        <td className="px-4 py-3 text-sm">{vaccine.nextDate || 'Not scheduled'}</td>
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
