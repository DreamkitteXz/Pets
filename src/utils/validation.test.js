import { validateCPF, validateCRMV, formatCPF, formatCEP } from './validation';

// ─────────────────────────────────────────────────────────────────────────────
// validateCPF
// ─────────────────────────────────────────────────────────────────────────────
describe('validateCPF', () => {
  describe('valid CPFs', () => {
    it('accepts a well-known valid CPF (unformatted)', () => {
      expect(validateCPF('529.982.247-25')).toBe(true);
    });

    it('accepts a valid CPF with dots and dash stripped internally', () => {
      expect(validateCPF('52998224725')).toBe(true);
    });

    it('accepts another structurally valid CPF', () => {
      expect(validateCPF('111.444.777-35')).toBe(true);
    });
  });

  describe('invalid CPFs', () => {
    it('rejects CPF with all identical digits (111.111.111-11)', () => {
      expect(validateCPF('111.111.111-11')).toBe(false);
    });

    it('rejects CPF with all zeros', () => {
      expect(validateCPF('000.000.000-00')).toBe(false);
    });

    it('rejects CPF shorter than 11 digits', () => {
      expect(validateCPF('123')).toBe(false);
    });

    it('rejects CPF longer than 11 digits', () => {
      expect(validateCPF('529.982.247-250')).toBe(false);
    });

    it('rejects empty string', () => {
      expect(validateCPF('')).toBe(false);
    });

    it('rejects a CPF with wrong check digits', () => {
      // Flipping the last digit makes the CPF invalid
      expect(validateCPF('529.982.247-26')).toBe(false);
    });

    it('rejects 999.999.999-99 (all nines)', () => {
      expect(validateCPF('999.999.999-99')).toBe(false);
    });
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// validateCRMV
// ─────────────────────────────────────────────────────────────────────────────
describe('validateCRMV', () => {
  describe('valid CRMVs', () => {
    it('accepts 5-digit CRMV', () => {
      expect(validateCRMV('CRMV-SP 12345')).toBe(true);
    });

    it('accepts 1-digit CRMV', () => {
      expect(validateCRMV('CRMV-MG 1')).toBe(true);
    });

    it('accepts 4-digit CRMV with different state', () => {
      expect(validateCRMV('CRMV-RJ 9999')).toBe(true);
    });
  });

  describe('invalid CRMVs', () => {
    it('rejects lowercase prefix', () => {
      expect(validateCRMV('crmv-SP 12345')).toBe(false);
    });

    it('rejects missing hyphen', () => {
      expect(validateCRMV('CRMV SP 12345')).toBe(false);
    });

    it('rejects lowercase state code', () => {
      expect(validateCRMV('CRMV-sp 12345')).toBe(false);
    });

    it('rejects more than 5 digits', () => {
      expect(validateCRMV('CRMV-SP 123456')).toBe(false);
    });

    it('rejects zero digits', () => {
      expect(validateCRMV('CRMV-SP ')).toBe(false);
    });

    it('rejects empty string', () => {
      expect(validateCRMV('')).toBe(false);
    });

    it('rejects letters in number section', () => {
      expect(validateCRMV('CRMV-SP 1234A')).toBe(false);
    });
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// formatCPF
// ─────────────────────────────────────────────────────────────────────────────
describe('formatCPF', () => {
  it('formats an 11-digit string into XXX.XXX.XXX-XX', () => {
    expect(formatCPF('52998224725')).toBe('529.982.247-25');
  });

  it('strips non-digit characters before formatting', () => {
    expect(formatCPF('529.982.247-25')).toBe('529.982.247-25');
  });

  it('truncates input that exceeds 11 digits', () => {
    expect(formatCPF('529982247250')).toBe('529.982.247-25');
  });

  it('handles partial input (5 digits) without crashing', () => {
    expect(formatCPF('52998')).toBe('529.98');
  });

  it('returns empty string for empty input', () => {
    expect(formatCPF('')).toBe('');
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// formatCEP
// ─────────────────────────────────────────────────────────────────────────────
describe('formatCEP', () => {
  it('formats 8 digits into XXXXX-XXX', () => {
    expect(formatCEP('01310100')).toBe('01310-100');
  });

  it('handles already-formatted CEP without doubling the hyphen', () => {
    expect(formatCEP('01310-100')).toBe('01310-100');
  });

  it('truncates input beyond 8 digits', () => {
    expect(formatCEP('013101009')).toBe('01310-100');
  });

  it('handles partial input (3 digits) without crashing', () => {
    expect(formatCEP('013')).toBe('013');
  });

  it('returns empty string for empty input', () => {
    expect(formatCEP('')).toBe('');
  });
});
