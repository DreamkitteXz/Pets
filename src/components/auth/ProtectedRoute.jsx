import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import LoadingScreen from '../ui/LoadingScreen';

const ProtectedRoute = () => {
  const { user, userProfile, loading } = useAuth();

  if (loading) return <LoadingScreen message="Carregando..." />;
  if (!user) return <Navigate to="/auth" replace />;
  if (!user.emailVerified) return <Navigate to="/verify-email" replace />;
  if (userProfile?.status === 'suspended') {
    return <Navigate to="/unauthorized" replace state={{ code: 403, reason: 'suspended' }} />;
  }

  return <Outlet />;
};

export default ProtectedRoute;
