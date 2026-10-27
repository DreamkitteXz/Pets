import React from 'react';
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

// Só esconde a tela de quem não é admin. A proteção real está nas CFs
// `adminListVets` / `adminReviewVet`, que recusam qualquer um sem o claim.
const AdminRoute = () => {
  const { isAdmin } = useAuth();
  const location = useLocation();

  if (!isAdmin) {
    return <Navigate to="/unauthorized" replace state={{ code: 403, from: location.pathname }} />;
  }
  return <Outlet />;
};

export default AdminRoute;
