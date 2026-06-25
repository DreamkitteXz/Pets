// Eixo canônico de status (vacinas/vermífugos): 'pending' | 'approved' | 'rejected'.
// Mapeia status legados (do modelo antigo de dois eixos vet+tutor) para o eixo único,
// garantindo que nenhum leitor quebre com dados ainda não migrados.
const LEGACY_STATUS_MAP = {
  vetApproved: 'approved',
  vetRejected: 'rejected',
  tutorApproved: 'approved',
  tutorRejected: 'rejected',
};

export const normalizeStatus = (status) => LEGACY_STATUS_MAP[status] || status || 'pending';

export const VACCINE_STATUSES = ['pending', 'approved', 'rejected'];
