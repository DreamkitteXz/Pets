import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import LimitedAccessWrapper from '../pages/Auth/LimitedAccessWrapper';

const ProtectedRoute = ({ limitedView }) => {
  const { user, loading } = useAuth();

  if (loading) {
    return <div>Loading...</div>; // Or a loading spinner
  }

  if (!user) {
    return <Navigate to="/auth" />;
  }

  return (
    <LimitedAccessWrapper limitedView={limitedView}>
      <Outlet />
    </LimitedAccessWrapper>
  );
};

export default ProtectedRoute;
