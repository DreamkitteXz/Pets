import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

/**
 * Authenticated entry point (mounted at /app). Sends each user to the home
 * of their role. ProfileGate guarantees a completed profile (with role)
 * before this renders.
 */
const RoleRedirect = () => {
  const { userProfile } = useAuth();
  if (userProfile?.role === 'tutor') return <Navigate to="/inicio" replace />;
  if (userProfile?.role === 'veterinarian') return <Navigate to="/dashboard" replace />;
  return <Navigate to="/unauthorized" replace state={{ code: 403 }} />;
};

export default RoleRedirect;
