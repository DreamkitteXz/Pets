import React from 'react';
import { useAuth } from '../../../context/AuthContext';

const Header = () => {
  const { user } = useAuth();

  return (
    <header className="bg-white shadow-sm">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
        <div className="flex justify-between items-center">
          <h1 className="text-2xl font-bold text-gray-900">Pet Manager</h1>
          <div className="flex items-center space-x-4">
            {user && (
              <span className="text-sm text-gray-700">
                {user.email}
              </span>
            )}
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
