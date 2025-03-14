import React from 'react';
import { CiCircleCheck, CiCircleRemove, CiCircleAlert } from "react-icons/ci";
import { IoClose } from "react-icons/io5";

const VaccineDetailsModal = ({ isOpen, onClose, vaccine }) => {
  if (!isOpen || !vaccine) return null;

  const getStatusIcon = (status) => {
    switch (status) {
      case 'approved':
        return <CiCircleCheck className="text-green-600" size={24} />;
      case 'rejected':
        return <CiCircleRemove className="text-red-600" size={24} />;
      case 'pending':
        return <CiCircleAlert className="text-yellow-600" size={24} />;
      default:
        return null;
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg w-full max-w-3xl max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-2xl font-bold text-gray-800">Vaccine Details</h2>
            <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
              <IoClose size={24} />
            </button>
          </div>

          <div className="space-y-6">
            {/* Status Section */}
            <div className="flex items-center justify-between bg-gray-50 p-4 rounded-lg">
              <div className="flex items-center gap-2">
                {getStatusIcon(vaccine.status)}
                <span className="font-semibold capitalize">{vaccine.status}</span>
              </div>
              <span className="text-gray-500">ID: {vaccine.id}</span>
            </div>

            {/* Main Details Grid */}
            <div className="grid grid-cols-2 gap-6">
              {/* Pet Information */}
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">Pet Information</h3>
                <div className="space-y-2">
                  <div>
                    <label className="block text-sm text-gray-600">Name</label>
                    <div className="font-medium">{vaccine.petName}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Species</label>
                    <div className="font-medium">{vaccine.petSpecies}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Breed</label>
                    <div className="font-medium">{vaccine.breed}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Owner</label>
                    <div className="font-medium">{vaccine.owner}</div>
                  </div>
                </div>
              </div>

              {/* Vaccine Information */}
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">Vaccine Information</h3>
                <div className="space-y-2">
                  <div>
                    <label className="block text-sm text-gray-600">Vaccine Name</label>
                    <div className="font-medium">{vaccine.vaccineName}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Manufacturer</label>
                    <div className="font-medium">{vaccine.manufacturer}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Batch Number</label>
                    <div className="font-medium">{vaccine.batchNumber}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Expiry Date</label>
                    <div className="font-medium">{vaccine.expiryDate}</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Administration Details */}
            <div className="space-y-4">
              <h3 className="font-semibold text-lg">Administration Details</h3>
              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-2">
                  <div>
                    <label className="block text-sm text-gray-600">Administration Date</label>
                    <div className="font-medium">{vaccine.administrationDate}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Veterinarian</label>
                    <div className="font-medium">{vaccine.veterinarian}</div>
                  </div>
                </div>
                <div className="space-y-2">
                  <div>
                    <label className="block text-sm text-gray-600">CRMV Number</label>
                    <div className="font-medium">{vaccine.crmvNumber}</div>
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Submission Date</label>
                    <div className="font-medium">{vaccine.submissionDate}</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Validation Information */}
            {(vaccine.status === 'approved' || vaccine.status === 'rejected') && (
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">Validation Information</h3>
                <div className="grid grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <div>
                      <label className="block text-sm text-gray-600">Validation Date</label>
                      <div className="font-medium">{vaccine.validationDate}</div>
                    </div>
                    <div>
                      <label className="block text-sm text-gray-600">Validator</label>
                      <div className="font-medium">{vaccine.validator}</div>
                    </div>
                  </div>
                  {vaccine.status === 'rejected' && (
                    <div className="space-y-2">
                      <div>
                        <label className="block text-sm text-gray-600">Rejection Reason</label>
                        <div className="font-medium text-red-600">{vaccine.rejectionReason}</div>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* Notes */}
            <div className="space-y-2">
              <h3 className="font-semibold text-lg">Notes</h3>
              <div className="bg-gray-50 p-4 rounded-lg">
                <p className="text-gray-700">{vaccine.notes}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default VaccineDetailsModal;
