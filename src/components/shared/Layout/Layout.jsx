import React, { useState, useEffect } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import SideBar from '../SideBar/SideBar';
import Header from '../Header/Header';
import { PROTECTED_ROUTES } from '../../../lib/consts/routes';

const Layout = () => {
  const location = useLocation();
  // Celular: o menu lateral vira gaveta, aberta pelo botão do Header.
  const [mobileNavOpen, setMobileNavOpen] = useState(false);

  // Fecha a gaveta ao navegar.
  useEffect(() => { setMobileNavOpen(false); }, [location.pathname]);

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
    <div className="h-screen flex" style={{ background: 'var(--surface-grouped)' }}>
      <SideBar mobileOpen={mobileNavOpen} onMobileClose={() => setMobileNavOpen(false)} />
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <Header currentRoute={currentRoute} onMenuClick={() => setMobileNavOpen(true)} />
        <main className="flex-1 p-4 md:p-6 overflow-auto">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default Layout;
