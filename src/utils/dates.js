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

// ── <input type="date"> ────────────────────────────────────────────────────
// O campo trabalha com 'yyyy-mm-dd' SEM fuso. `new Date('2026-10-26')` lê como
// meia-noite UTC — no Brasil (UTC-3) isso é 21h do dia anterior, e a data
// gravada/exibida voltava um dia. Converta sempre por estas duas funções.

// Data local → 'yyyy-mm-dd' (padrão "hoje" dos campos; toISOString seria UTC).
export const toDateInput = (date = new Date()) =>
  `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;

// 'yyyy-mm-dd' → Date ao meio-dia local (margem de 12h para qualquer fuso do Brasil).
export const fromDateInput = (value) => (value ? new Date(`${value}T12:00:00`) : null);
