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
    <div className="h-screen flex bg-gray-100">
      <SideBar />
      <div className="flex-1 flex flex-col overflow-auto">
        <Header currentRoute={currentRoute} />
        <main className="flex-1 p-6 overflow-auto">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default Layout;
