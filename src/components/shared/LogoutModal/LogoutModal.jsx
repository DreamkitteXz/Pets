import React from 'react';

export default function LogoutModal({ isOpen, onClose, onConfirm }) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Overlay */}
      <div 
        className="absolute inset-0 bg-black/50" 
        onClick={onClose}
      />
      
      {/* Modal */}
      <div className="relative bg-white rounded-xl shadow-lg w-full max-w-md p-6 space-y-6">
        <h3 className="text-lg font-medium text-gray-900">
          Confirmar Logout
        </h3>
        <p className="text-gray-500">
          Tem certeza que deseja sair? Você precisará fazer login novamente para acessar sua conta.
        </p>
        <div className="flex justify-end gap-3">
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-lg"
          >
            Cancelar
          </button>
          <button
            onClick={onConfirm}
            className="px-4 py-2 text-sm font-medium text-white bg-red-600 hover:bg-red-700 rounded-lg"
          >
            Sair
          </button>
        </div>
      </div>
    </div>
  );
}
