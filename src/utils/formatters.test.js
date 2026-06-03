import { formatDate } from './formatters';

describe('formatDate', () => {
  // Pin a known date to avoid locale drift in CI
  const knownDate = new Date(2024, 0, 15, 9, 5); // 15 Jan 2024, 09:05

  it('returns empty string for null', () => {
    expect(formatDate(null)).toBe('');
  });

  it('returns empty string for undefined', () => {
    expect(formatDate(undefined)).toBe('');
  });

  it('formats a native Date object in pt-BR format', () => {
    const result = formatDate(knownDate);
    // dd/mm/yyyy, hh:mm  — exact format depends on locale engine, check structure
    expect(result).toMatch(/^\d{2}\/\d{2}\/\d{4},?\s\d{2}:\d{2}$/);
    expect(result).toContain('15/01/2024');
    expect(result).toContain('09:05');
  });

  it('formats a Firestore-Timestamp-like object with .toDate()', () => {
    const firestoreTimestamp = { toDate: () => knownDate };
    const result = formatDate(firestoreTimestamp);
    expect(result).toContain('15/01/2024');
  });

  it('handles midnight (00:00) correctly', () => {
    const midnight = new Date(2024, 5, 1, 0, 0);
    const result = formatDate(midnight);
    expect(result).toContain('00:00');
  });
});
