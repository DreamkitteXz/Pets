import React from 'react';
import { IoClose } from "react-icons/io5";
import { IoWarningOutline } from "react-icons/io5";

const VaccineDeleteModal = ({ isOpen, onClose, vaccine, onDelete }) => {
  if (!isOpen || !vaccine) return null;

  const handleDelete = () => {
    onDelete(vaccine.id);
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg w-full max-w-md p-6">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-bold text-gray-800">Delete Vaccine Record</h2>
          <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
            <IoClose size={24} />
          </button>
        </div>

        <div className="mb-6">
          <div className="flex items-center justify-center text-yellow-500 mb-4">
            <IoWarningOutline size={48} />
          </div>
          <p className="text-center text-gray-600 mb-2">
            Are you sure you want to delete this vaccine record?
          </p>
          <div className="bg-gray-50 p-4 rounded-lg">
            <p className="text-sm text-gray-600 mb-1">
              <span className="font-semibold">ID:</span> {vaccine.id}
            </p>
            <p className="text-sm text-gray-600 mb-1">
              <span className="font-semibold">Pet:</span> {vaccine.petName}
            </p>
            <p className="text-sm text-gray-600">
              <span className="font-semibold">Vaccine:</span> {vaccine.vaccineName}
            </p>
          </div>
          <p className="text-red-600 text-sm mt-4">
            This action cannot be undone.
          </p>
        </div>

        <div className="flex justify-end gap-3">
          <button
            onClick={onClose}
            className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            onClick={handleDelete}
            className="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700"
          >
            Delete Record
          </button>
        </div>
      </div>
    </div>
  );
};

export default VaccineDeleteModal;
