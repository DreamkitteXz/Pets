// Create a new file: src/components/ui/ProfileIncompleteBanner.jsx

import React from 'react';
import { useNavigate } from 'react-router-dom';
import { AlertTriangle } from 'lucide-react';

const ProfileIncompleteBanner = ({ mode = 'banner' }) => {
  const navigate = useNavigate();
  
  if (mode === 'page') {
    return (
      <div className="min-h-screen bg-gradient-to-r from-blue-100 to-teal-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-lg shadow-xl p-8 max-w-lg w-full text-center">
          <div className="mb-6 flex justify-center">
            <div className="bg-amber-100 p-3 rounded-full">
              <AlertTriangle size={48} className="text-amber-600" />
            </div>
          </div>
          <h2 className="text-2xl font-bold text-gray-800 mb-3">Profile Incomplete</h2>
          <p className="text-gray-600 mb-6">
            Your veterinarian profile is incomplete. You need to complete your profile to access all features of the application.
          </p>
          <button
            onClick={() => navigate('/complete-profile')}
            className="w-full bg-teal-600 hover:bg-teal-700 text-white font-medium py-3 px-4 rounded-lg transition duration-200"
          >
            Complete Your Profile
          </button>
        </div>
      </div>
    );
  }
  
  return (
    <div className="bg-amber-50 border-l-4 border-amber-500 p-4 mb-4">
      <div className="flex items-center">
        <AlertTriangle size={20} className="text-amber-600 mr-2" />
        <p className="text-amber-700 flex-grow">
          Your profile is incomplete. Some features are limited.
        </p>
        <button
          onClick={() => navigate('/complete-profile')}
          className="bg-amber-600 hover:bg-amber-700 text-white text-sm font-medium py-1 px-3 rounded transition duration-200"
        >
          Complete Now
        </button>
      </div>
    </div>
  );
};

export default ProfileIncompleteBanner;