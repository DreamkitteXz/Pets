import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { auth } from '../../config/firebase';

const RouteGuard = ({ children }) => {
  const location = useLocation();
  const user = auth.currentUser;

  if (!user) {
    return <Navigate to="/auth" state={{ from: location }} replace />;
  }

  if (!user.emailVerified && location.pathname !== '/verify-email') {
    return <Navigate to="/verify-email" replace />;
  }

  // Add more checks as needed (e.g., profile completion)

  return children;
};

export default RouteGuard;
