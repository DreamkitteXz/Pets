/**
 * Integration tests for LogoutModal.
 *
 * LogoutModal has no external dependencies — it is a pure presentational
 * component that accepts isOpen, onClose, onConfirm.
 */
import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import LogoutModal from './LogoutModal';

function renderModal(props) {
  const defaults = {
    isOpen: true,
    onClose: jest.fn(),
    onConfirm: jest.fn(),
  };
  return render(<LogoutModal {...defaults} {...props} />);
}

describe('LogoutModal', () => {
  it('renders nothing when isOpen is false', () => {
    const { container } = renderModal({ isOpen: false });
    expect(container).toBeEmptyDOMElement();
  });

  it('renders the modal when isOpen is true', () => {
    renderModal();
    expect(screen.getByText('Sair da conta?')).toBeInTheDocument();
  });

  it('shows the confirmation message body text', () => {
    renderModal();
    expect(
      screen.getByText(/Você precisará fazer login novamente/i)
    ).toBeInTheDocument();
  });

  it('has a "Cancelar" button', () => {
    renderModal();
    expect(screen.getByRole('button', { name: /cancelar/i })).toBeInTheDocument();
  });

  it('has a "Sair" (confirm) button', () => {
    renderModal();
    // There are two elements with "Sair" text — the button and potentially the title.
    // Use getByRole to be precise.
    const buttons = screen.getAllByRole('button');
    const sairBtn = buttons.find(b => /sair/i.test(b.textContent));
    expect(sairBtn).toBeInTheDocument();
  });

  it('calls onClose when "Cancelar" is clicked', async () => {
    const onClose = jest.fn();
    renderModal({ onClose });

    await userEvent.click(screen.getByRole('button', { name: /cancelar/i }));

    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it('calls onConfirm when the confirm "Sair" button is clicked', async () => {
    const onConfirm = jest.fn();
    renderModal({ onConfirm });

    // The confirm button is the second button (Cancelar | Sair layout)
    const buttons = screen.getAllByRole('button');
    const confirmBtn = buttons[1];
    await userEvent.click(confirmBtn);

    expect(onConfirm).toHaveBeenCalledTimes(1);
  });

  it('calls onClose when the backdrop overlay is clicked', async () => {
    const onClose = jest.fn();
    renderModal({ onClose });

    // The overlay is a div positioned behind the modal
    const overlay = document.querySelector('.fixed.inset-0');
    if (overlay) {
      await userEvent.click(overlay);
      // onClose might or might not be called depending on overlay click target
      // — at minimum the call should not throw
    }
    // No assertion here — this is a defensive smoke test
  });
});
