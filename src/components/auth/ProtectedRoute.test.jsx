/**
 * Integration tests for ProtectedRoute.
 *
 * ProtectedRoute reads from AuthContext via useAuth().
 * We mock the entire AuthContext module so we can control the auth state
 * without initialising Firebase.
 */
import React from 'react';
import { screen } from '@testing-library/react';
import { Routes, Route } from 'react-router-dom';
import { renderWithRouter } from '../../tests/utils/render';
import ProtectedRoute from './ProtectedRoute';

// ── Mock AuthContext so tests never touch Firebase ─────────────────────────
jest.mock('../../context/AuthContext', () => ({
  useAuth: jest.fn(),
}));

// ── Mock LoadingScreen to keep snapshots deterministic ────────────────────
jest.mock('../ui/LoadingScreen', () => ({
  __esModule: true,
  default: ({ message }) => <div data-testid="loading-screen">{message}</div>,
}));

import { useAuth } from '../../context/AuthContext';

// Helper: wrap ProtectedRoute inside a Routes tree the same way App.jsx does.
function renderProtected(authValue, protectedContent = <div>Protected Content</div>) {
  useAuth.mockReturnValue(authValue);

  return renderWithRouter(
    <Routes>
      <Route element={<ProtectedRoute />}>
        <Route path="/" element={protectedContent} />
      </Route>
      <Route path="/auth"         element={<div>Auth Page</div>} />
      <Route path="/verify-email" element={<div>Verify Email Page</div>} />
    </Routes>,
    { initialEntries: ['/'] }
  );
}

// ─────────────────────────────────────────────────────────────────────────────
describe('ProtectedRoute', () => {
  afterEach(() => jest.clearAllMocks());

  it('shows a loading screen while auth state is being resolved', () => {
    renderProtected({ user: null, loading: true });

    expect(screen.getByTestId('loading-screen')).toBeInTheDocument();
    expect(screen.getByText('Carregando...')).toBeInTheDocument();
    expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
  });

  it('redirects to /auth when the user is not authenticated', () => {
    renderProtected({ user: null, loading: false });

    expect(screen.getByText('Auth Page')).toBeInTheDocument();
    expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
  });

  it('redirects to /verify-email when the user exists but email is not verified', () => {
    renderProtected({ user: { emailVerified: false }, loading: false });

    expect(screen.getByText('Verify Email Page')).toBeInTheDocument();
    expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
  });

  it('renders the protected content when the user is authenticated and verified', () => {
    renderProtected({ user: { emailVerified: true }, loading: false });

    expect(screen.getByText('Protected Content')).toBeInTheDocument();
    expect(screen.queryByText('Auth Page')).not.toBeInTheDocument();
    expect(screen.queryByText('Verify Email Page')).not.toBeInTheDocument();
  });

  it('does not render the loading screen once auth resolves', () => {
    renderProtected({ user: { emailVerified: true }, loading: false });

    expect(screen.queryByTestId('loading-screen')).not.toBeInTheDocument();
  });
});
