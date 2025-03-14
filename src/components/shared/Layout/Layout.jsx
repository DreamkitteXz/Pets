import React from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import SideBar from '../SideBar/SideBar';
import Header from '../Header/Header';
import { PROTECTED_ROUTES } from '../../../lib/consts/routes';

const Layout = () => {
  const location = useLocation();
  const currentRoute = Object.values(PROTECTED_ROUTES)
    .find(route => 
      typeof route === 'string' 
        ? route === location.pathname
        : Object.values(route).some(r => 
            typeof r === 'string' 
              ? r === location.pathname
              : location.pathname.startsWith(r.toString().split(':')[0])
          )
    );

  return (
    <div className="min-h-screen bg-gray-100">
      <div className="flex">
        <SideBar />
        <main className="flex-1">
          <Header currentRoute={currentRoute} />
          <div className="p-6">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
};

export default Layout;
