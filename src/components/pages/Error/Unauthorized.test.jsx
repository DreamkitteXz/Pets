/**
 * Integration tests for the 401 Unauthorized page.
 */
import React from 'react';
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { renderWithRouter } from '../../../tests/utils/render';
import Unauthorized from './Unauthorized';

const mockNavigate = jest.fn();
jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  useNavigate: () => mockNavigate,
}));

describe('Unauthorized (401)', () => {
  beforeEach(() => mockNavigate.mockClear());

  it('renders the page without crashing', () => {
    renderWithRouter(<Unauthorized />);
    expect(screen.getByText(/acesso negado/i)).toBeInTheDocument();
  });

  it('shows an explanatory message', () => {
    renderWithRouter(<Unauthorized />);
    expect(screen.getByText(/não tem permissão/i)).toBeInTheDocument();
  });

  it('has a login button', () => {
    renderWithRouter(<Unauthorized />);
    expect(screen.getByRole('button', { name: /fazer login/i })).toBeInTheDocument();
  });

  it('navigates to /auth when the login button is clicked', async () => {
    renderWithRouter(<Unauthorized />);
    await userEvent.click(screen.getByRole('button', { name: /fazer login/i }));
    expect(mockNavigate).toHaveBeenCalledWith('/auth');
  });
});
