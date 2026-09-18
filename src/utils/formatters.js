import { toDate } from './dates';

export const formatDate = (date) => {
  const d = toDate(date);
  if (!d) return '';
  return new Intl.DateTimeFormat('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(d);
};
