/**
 * Custom render utility.
 *
 * Wraps the component under test with MemoryRouter so that any component
 * using react-router hooks/links works without a real browser history.
 * AuthContext is NOT provided here — mock it per-test-file with jest.mock().
 */
import React from 'react';
import { render } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';

/**
 * @param {React.ReactElement} ui
 * @param {{ initialEntries?: string[], [key: string]: any }} options
 */
export function renderWithRouter(ui, { initialEntries = ['/'], ...options } = {}) {
  function Wrapper({ children }) {
    return <MemoryRouter initialEntries={initialEntries}>{children}</MemoryRouter>;
  }
  return render(ui, { wrapper: Wrapper, ...options });
}

// Re-export everything from Testing Library so tests can import from one place
export * from '@testing-library/react';
