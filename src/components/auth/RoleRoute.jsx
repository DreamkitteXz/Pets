import React from 'react';
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

const RoleRoute = ({ requiredRole }) => {
  const { userProfile } = useAuth();
  const location = useLocation();

  if (userProfile?.role !== requiredRole) {
    return (
      <Navigate
        to="/unauthorized"
        replace
        state={{ code: 403, from: location.pathname }}
      />
    );
  }

  return <Outlet />;
};

export default RoleRoute;
