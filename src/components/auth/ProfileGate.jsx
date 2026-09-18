import React from 'react';
import { Outlet } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import LoadingScreen from '../ui/LoadingScreen';
import CompleteProfileModal from '../pages/Auth/CompleteProfileModal';

/**
 * Sits between ProtectedRoute and the app Layout.
 * If the authenticated user hasn't completed onboarding (no role / profileCompleted
 * !== true), it blocks the app behind a blurred system backdrop and shows the
 * complete-profile modal. Otherwise it renders the app as usual.
 */
const ProfileGate = () => {
  const { userProfile, loading } = useAuth();

  if (loading) return <LoadingScreen message="Carregando..." />;

  const needsOnboarding = !userProfile || userProfile.profileCompleted !== true || !userProfile.role;

  if (needsOnboarding) {
    return (
      <div className="relative h-screen w-full overflow-hidden" style={{ background: 'var(--surface-grouped)' }}>
        {/* Blurred system backdrop */}
        <div
          aria-hidden="true"
          className="absolute inset-0"
          style={{
            filter: 'blur(8px)',
            background:
              'radial-gradient(1200px 600px at 12% 0%, rgba(0,122,255,0.10), transparent 60%),' +
              'radial-gradient(900px 500px at 100% 100%, rgba(88,86,214,0.10), transparent 55%),' +
              'var(--surface-grouped)',
          }}
        />
        <CompleteProfileModal />
      </div>
    );
  }

  return <Outlet />;
};

export default ProfileGate;
