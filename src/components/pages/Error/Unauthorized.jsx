import React from 'react';
import { useNavigate } from 'react-router-dom';

const Unauthorized = () => {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <div className="text-center">
        <h1 className="text-9xl font-bold text-gray-800">401</h1>
        <p className="text-2xl text-gray-600 mb-8">Unauthorized Access</p>
        <p className="text-gray-500 mb-8">You don't have permission to access this page.</p>
        <button
          onClick={() => navigate('/auth')}
          className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700"
        >
          Login
        </button>
      </div>
    </div>
  );
};

export default Unauthorized;
