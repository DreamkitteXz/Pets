import React, { useState } from 'react';
import Modal from '../../../components/common/Modal/Modal';

const VaccineList = () => {
  const [vaccines] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <div className="container mx-auto p-6">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-800 mb-2">Vaccine Records</h1>
        <p className="text-gray-600">
          Manage and track vaccination records for your patients
        </p>
      </div>

      {/* Action Bar */}
      <div className="flex justify-between items-center mb-6">
        <button
          onClick={() => setIsModalOpen(true)}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
        >
          Add New Vaccine
        </button>
      </div>

      {/* Vaccines Table */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Pet Name
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Vaccine
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Date
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {vaccines.length === 0 ? (
              <tr>
                <td colSpan="5" className="px-6 py-4 text-center text-gray-500">
                  No vaccine records found
                </td>
              </tr>
            ) : (
              vaccines.map((vaccine) => (
                <tr key={vaccine.id}>
                  <td className="px-6 py-4 whitespace-nowrap">{vaccine.petName}</td>
                  <td className="px-6 py-4 whitespace-nowrap">{vaccine.name}</td>
                  <td className="px-6 py-4 whitespace-nowrap">{vaccine.date}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                      ${vaccine.status === 'completed' ? 'bg-green-100 text-green-800' : 
                        'bg-yellow-100 text-yellow-800'}`}
                    >
                      {vaccine.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right text-sm font-medium">
                    <button className="text-blue-600 hover:text-blue-900 mr-3" disabled>
                      Edit
                    </button>
                    <button className="text-red-600 hover:text-red-900" disabled>
                      Delete
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Add Vaccine Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title="Add New Vaccine Record"
      >
        <form className="space-y-4">
          {/* Add form fields here */}
          <div className="flex justify-end space-x-3">
            <button
              type="button"
              onClick={() => setIsModalOpen(false)}
              className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              Save
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};

export default VaccineList;
