import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';

const navigation = [
  { name: 'Dashboard', path: '/', icon: '📊' },
  { name: 'Pets', path: '/pets', icon: '🐾' },
  { name: 'Vaccines', path: '/vaccines', icon: '💉' },
];

const Sidebar = () => {
  const location = useLocation();
  const [isCollapsed, setIsCollapsed] = useState(false);

  return (
    <div className={`${isCollapsed ? 'w-20' : 'w-64'} transition-all duration-300 bg-white shadow-sm h-screen`}>
      {/* Header with logo and collapse button */}
      <div className="flex items-center justify-between p-4 border-b">
        {!isCollapsed && (
          <div className="text-xl font-bold">
            Logo
          </div>
        )}
        <button
          onClick={() => setIsCollapsed(!isCollapsed)}
          className="p-2 rounded-lg hover:bg-gray-100"
        >
          {isCollapsed ? '→' : '←'}
        </button>
      </div>

      <nav className="mt-5 px-2">
        {navigation.map((item) => (
          <Link
            key={item.name}
            to={item.path}
            className={`${
              location.pathname === item.path
                ? 'bg-gray-100 text-gray-900'
                : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
            } group flex items-center px-2 py-2 text-base font-medium rounded-md ${
              isCollapsed ? 'justify-center' : ''
            }`}
          >
            <span className={isCollapsed ? '' : 'mr-4'}>{item.icon}</span>
            {!isCollapsed && item.name}
          </Link>
        ))}
      </nav>
    </div>
  );
};

export default Sidebar;
