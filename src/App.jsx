import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/shared/Layout/Layout';
import { AuthProvider } from './context/AuthContext';
import { ThemeProvider } from './context/ThemeContext';
import ProtectedRoute from './components/auth/ProtectedRoute';
import RoleRoute from './components/auth/RoleRoute';
import ProfileGate from './components/auth/ProfileGate';
import RoleRedirect from './components/auth/RoleRedirect';

// Auth Pages
import Login from './components/pages/Auth/Login/Auth';
import EmailVerification from './components/pages/Auth/EmailVerification';
import ForgotPassword from './components/pages/Auth/ForgotPassword';
import ResetPassword from './components/pages/Auth/ResetPassword';

// Veterinarian Features
import Pets from './components/pages/Pets/Pets';
import PetRecord from './components/pages/PetRecord/PetRecord';
import Carteira from './components/pages/PetRecord/Carteira';
import Vaccines from './components/pages/Vacinas/Vacinas';
import VaccineDetailsModal from './components/pages/Vacinas/VaccineDetailsModal';
import Clinicas from './components/pages/Clinicas/Clinicas';
import Chat from './components/pages/Chat/Chat';
import Dashboard from './components/pages/Dashboard/Dashboard';
import Vencimentos from './components/pages/Vencimentos/Vencimentos';

// Tutor Features
import TutorHome from './components/pages/Tutor/TutorHome';
import TutorPets from './components/pages/Tutor/TutorPets';
import TutorVaccines from './components/pages/Tutor/TutorVaccines';

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
          <Route path="/" element={<Navigate to="/home" replace />} />

          {/* Protected Routes — auth + email verified + onboarding complete */}
          <Route element={<ProtectedRoute />}>
            <Route element={<ProfileGate />}>
              <Route element={<Layout />}>
                {/* Authenticated entry — redirects to each role's home */}
                <Route path="/app" element={<RoleRedirect />} />

                {/* Veterinarian-only routes */}
                <Route element={<RoleRoute requiredRole="veterinarian" />}>
                  <Route path="/dashboard" element={<Dashboard />} />
                  <Route path="/pets">
                    <Route index element={<Pets />} />
                    <Route path=":petId" element={<PetRecord />} />
                    <Route path=":petId/carteira" element={<Carteira />} />
                  </Route>
                  <Route path="/vacinas">
                    <Route index element={<Vaccines />} />
                    <Route path=":vaccineId" element={<VaccineDetailsModal />} />
                  </Route>
                  <Route path="/vencimentos" element={<Vencimentos />} />
                  <Route path="/clinicas" element={<Clinicas />} />
                  <Route path="/chat" element={<Chat />} />
                </Route>

                {/* Tutor-only routes */}
                <Route element={<RoleRoute requiredRole="tutor" />}>
                  <Route path="/inicio" element={<TutorHome />} />
                  <Route path="/meus-pets">
                    <Route index element={<TutorPets />} />
                    <Route path=":petId" element={<PetRecord />} />
                    <Route path=":petId/carteira" element={<Carteira />} />
                  </Route>
                  <Route path="/minhas-vacinas" element={<TutorVaccines />} />
                </Route>

                {/* Any authenticated, onboarded user */}
                <Route path="/profile" element={<Profile />} />
                <Route path="/settings" element={<Settings />} />
              </Route>
            </Route>
          </Route>

          {/* Error Routes */}
          <Route path="/404" element={<NotFound />} />
          <Route path="*" element={<Navigate to="/404" replace />} />
        </Routes>
      </Router>
      </ThemeProvider>
    </AuthProvider>
  );
};

export default App;
