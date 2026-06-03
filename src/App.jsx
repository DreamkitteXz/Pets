import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/shared/Layout/Layout';
import { AuthProvider } from './context/AuthContext';
import { ThemeProvider } from './context/ThemeContext';
import ProtectedRoute from './components/auth/ProtectedRoute';

// Auth Pages
import Login from './components/pages/Auth/Login/Auth';
import CompleteProfile from './components/pages/Auth/CompleteProfile';
import EmailVerification from './components/pages/Auth/EmailVerification';
import ForgotPassword from './components/pages/Auth/ForgotPassword';
import ResetPassword from './components/pages/Auth/ResetPassword';

// Main Features
import Dashboard from './components/pages/Dashboard/Dashboard';
import Pets from './components/pages/Pets/Pets';
import PetDetailsModal from './components/pages/Pets/PetDetailsModal';
import Vaccines from './components/pages/Vacinas/Vacinas';
import VaccineDetailsModal from './components/pages/Vacinas/VaccineDetailsModal';

// Profile & Settings
import Profile from './components/pages/Profile/Profile';
import Settings from './components/pages/Settings/Settings';

// Error Pages
import NotFound from './components/pages/Error/NotFound';
import Unauthorized from './components/pages/Error/Unauthorized';
import PettoHomepage from './components/pages/Landing/landing';

const App = () => {
  return (
    <AuthProvider>
      <ThemeProvider>
      <Router>
        <Routes>
          {/* Public Routes */}
          <Route path="/home" element={<PettoHomepage />} />
          <Route path="/auth" element={<Login />} />
          <Route path="/forgot-password" element={<ForgotPassword />} />
          <Route path="/reset-password" element={<ResetPassword />} />
          <Route path="/verify-email" element={<EmailVerification />} />
          <Route path="/unauthorized" element={<Unauthorized />} />
          {/* COMENTADO: Rota de complete-profile desabilitada */}
          {/* <Route path="/complete-profile" element={<CompleteProfile />} /> */}

          {/* Protected Routes */}
          <Route element={<ProtectedRoute />}>
            <Route element={<Layout />}>
              {/* Dashboard */}
              <Route path="" element={<VaccineDetailsModal /> } />
              
              {/* Pets */}
              <Route path="/pets">
                <Route index element={<Pets />} />
                <Route path=":petId" element={<PetDetailsModal />} />
              </Route>
              
              {/* Vaccines */}
              <Route path="/vacinas">
                <Route index element={<Vaccines />} />
                <Route path=":vaccineId" element={<VaccineDetailsModal />} />
              </Route>
              
              {/* Profile & Settings */}
              <Route path="/profile" element={<Profile />} />
              <Route path="/settings" element={<Settings />} />
            </Route>
          </Route>

          {/* Error Routes */}
          <Route path="/404" element={<NotFound />} />
          <Route path="*" element={<Navigate to="/404" replace />} />
          <Route path="/" element={<Navigate to="/vacinas" replace />} />
        </Routes>
      </Router>
      </ThemeProvider>
    </AuthProvider>
  );
};

export default App;
