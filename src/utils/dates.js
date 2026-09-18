// Helper único de leitura de datas. Normaliza os formatos que aparecem no app
// (Firestore Timestamp, objeto {seconds}, epoch em ms, string ISO legada, Date)
// para um Date — substituindo as heurísticas de tipo espalhadas pelo código.
export const toDate = (value) => {
  if (!value && value !== 0) return null;
  if (value instanceof Date) return isNaN(value.getTime()) ? null : value;
  if (typeof value.toDate === 'function') return value.toDate();          // Firestore Timestamp
  if (typeof value === 'object' && typeof value.seconds === 'number') {   // {seconds, nanoseconds}
    return new Date(value.seconds * 1000);
  }
  if (typeof value === 'number') return new Date(value);                  // epoch em ms
  if (typeof value === 'string') {                                        // ISO legada / 'YYYY-MM-DD'
    const d = new Date(value);
    return isNaN(d.getTime()) ? null : d;
  }
  return null;
};

// Conveniência: data pt-BR (dd/mm/aaaa) com fallback configurável.
export const formatDateBR = (value, fallback = '—') => {
  const d = toDate(value);
  return d ? d.toLocaleDateString('pt-BR') : fallback;
};

// Conveniência: epoch em ms (para ordenação), 0 quando ausente/ inválido.
export const toMillis = (value) => {
  const d = toDate(value);
  return d ? d.getTime() : 0;
};
