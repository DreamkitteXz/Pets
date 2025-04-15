import React from 'react';
import PropTypes from 'prop-types';
import './PetDetailsModal.css';

const PetDetailsModal = ({ pet = {}, show, onClose }) => {
  if (!show) return null;

  const calculateAge = (birthDate) => {
    if (!birthDate) return 'Não informado';
    
    const birth = new Date(birthDate);
    const today = new Date();
    
    // Calculate total days difference
    const diffTime = Math.abs(today - birth);
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    
    let years = today.getFullYear() - birth.getFullYear();
    let months = today.getMonth() - birth.getMonth();
    
    if (months < 0 || (months === 0 && today.getDate() < birth.getDate())) {
      years--;
      months = 12 + months;
    }
    
    // For pets less than a month old
    if (diffDays < 31) {
      return `${diffDays} ${diffDays === 1 ? 'dia' : 'dias'}`;
    }
    
    // For pets less than a year old
    if (years < 1) {
      return `${months} ${months === 1 ? 'mês' : 'meses'}`;
    }
    
    // For pets with exact years
    if (months === 0) {
      return `${years} ${years === 1 ? 'ano' : 'anos'}`;
    }
    
    // For pets with years and months
    return `${years} ${years === 1 ? 'ano' : 'anos'} e ${months} ${months === 1 ? 'mês' : 'meses'}`;
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <header className="modal-header">
          <h2>{pet?.name || 'Detalhes do Pet'}</h2>
          <button className="close-button" onClick={onClose}>&times;</button>
        </header>

        <div className="modal-body">
          <div className="pet-profile">
            <div className="pet-basic-info">
              <div className="info-section">
                <h3>Informações Básicas</h3>
                <div className="info-grid">
                  <div className="info-item">
                    <span>Espécie:</span>
                    <p>{pet?.species || 'Não informado'}</p>
                  </div>
                  <div className="info-item">
                    <span>Raça:</span>
                    <p>{pet?.breed || 'Não informado'}</p>
                  </div>
                  <div className="info-item">
                    <span>Idade:</span>
                    <p>{calculateAge(pet?.birthDate)}</p>
                  </div>
                  <div className="info-item">
                    <span>Peso:</span>
                    <p>{pet?.weight ? `${pet.weight} kg` : 'Não informado'}</p>
                  </div>
                  <div className="info-item">
                    <span>Cor:</span>
                    <p>{pet?.color || 'Não informado'}</p>
                  </div>
                  <div className="info-item">
                    <span>Microchip:</span>
                    <p>{pet?.chipNumber || 'Não possui'}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <footer className="modal-footer">
          <button className="action-button" onClick={onClose}>Fechar</button>
        </footer>
      </div>
    </div>
  );
};

PetDetailsModal.propTypes = {
  pet: PropTypes.object,
  show: PropTypes.bool.isRequired,
  onClose: PropTypes.func.isRequired,
};

export default PetDetailsModal;
