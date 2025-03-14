import React from 'react';
import { Link, useLocation } from 'react-router-dom';

const navigation = [
  { name: 'Dashboard', path: '/', icon: '📊' },
  { name: 'Pets', path: '/pets', icon: '🐾' },
  { name: 'Vaccines', path: '/vaccines', icon: '💉' },
];

const Sidebar = () => {
  const location = useLocation();

  return (
    <div className="w-64 bg-white shadow-sm h-screen">
      <nav className="mt-5 px-2">
        {navigation.map((item) => (
          <Link
            key={item.name}
            to={item.path}
            className={`${
              location.pathname === item.path
                ? 'bg-gray-100 text-gray-900'
                : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
            } group flex items-center px-2 py-2 text-base font-medium rounded-md`}
          >
            <span className="mr-4">{item.icon}</span>
            {item.name}
          </Link>
        ))}
      </nav>
    </div>
  );
};

export default Sidebar;
