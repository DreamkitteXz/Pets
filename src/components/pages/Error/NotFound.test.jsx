/**
 * Integration tests for the 404 NotFound page.
 */
import React from 'react';
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { renderWithRouter } from '../../../tests/utils/render';
import NotFound from './NotFound';

// Mock useNavigate so we can assert navigations without a real router history
const mockNavigate = jest.fn();
jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  useNavigate: () => mockNavigate,
}));

describe('NotFound (404)', () => {
  beforeEach(() => mockNavigate.mockClear());

  it('renders the page without crashing', () => {
    renderWithRouter(<NotFound />);
    expect(screen.getByText(/página não encontrada/i)).toBeInTheDocument();
  });

  it('shows a user-friendly error description', () => {
    renderWithRouter(<NotFound />);
    expect(screen.getByText(/endereço que você tentou acessar/i)).toBeInTheDocument();
  });

  it('renders a "Ir para o início" button', () => {
    renderWithRouter(<NotFound />);
    expect(screen.getByRole('button', { name: /ir para o início/i })).toBeInTheDocument();
  });

  it('navigates to "/" when the home button is clicked', async () => {
    renderWithRouter(<NotFound />);
    await userEvent.click(screen.getByRole('button', { name: /ir para o início/i }));
    expect(mockNavigate).toHaveBeenCalledWith('/');
  });
});
