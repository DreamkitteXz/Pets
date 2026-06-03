import { getAuthErrorMessage } from './authErrors';

describe('getAuthErrorMessage', () => {
  it('returns fallback message when error is null', () => {
    expect(getAuthErrorMessage(null)).toBe('Ocorreu um erro inesperado. Tente novamente.');
  });

  it('returns fallback message when error is undefined', () => {
    expect(getAuthErrorMessage(undefined)).toBe('Ocorreu um erro inesperado. Tente novamente.');
  });

  it('returns fallback message for an error with no code', () => {
    expect(getAuthErrorMessage({})).toBe('Ocorreu um erro inesperado. Tente novamente.');
  });

  it('returns fallback message for an unrecognized error code', () => {
    expect(getAuthErrorMessage({ code: 'auth/unknown-code' })).toBe(
      'Ocorreu um erro inesperado. Tente novamente.'
    );
  });

  const cases = [
    ['auth/user-not-found',     'Nenhuma conta encontrada com este e-mail.'],
    ['auth/wrong-password',     'Senha incorreta. Verifique e tente novamente.'],
    ['auth/invalid-credential', 'E-mail ou senha inválidos.'],
    ['auth/email-already-in-use', 'Este e-mail já está cadastrado. Tente fazer login.'],
    ['auth/weak-password',      'A senha deve ter pelo menos 6 caracteres.'],
    ['auth/invalid-email',      'Endereço de e-mail inválido.'],
    ['auth/popup-closed-by-user', 'Login com Google cancelado.'],
    ['auth/popup-blocked',      'Pop-up bloqueado pelo navegador. Permita pop-ups e tente novamente.'],
    ['auth/network-request-failed', 'Sem conexão com a internet. Verifique sua rede.'],
    ['auth/too-many-requests',  'Muitas tentativas. Aguarde alguns minutos e tente novamente.'],
    ['auth/user-disabled',      'Esta conta foi desativada. Entre em contato com o suporte.'],
    ['auth/expired-action-code', 'Este link expirou. Solicite a recuperação novamente.'],
    ['auth/invalid-action-code', 'Link inválido ou já utilizado. Solicite a recuperação novamente.'],
    ['auth/requires-recent-login', 'Por segurança, faça login novamente para continuar.'],
    ['auth/operation-not-allowed', 'Este método de login não está habilitado.'],
    ['auth/missing-email',      'Informe um endereço de e-mail.'],
    ['auth/timeout',            'A operação expirou. Tente novamente.'],
  ];

  it.each(cases)('maps %s to the correct Portuguese message', (code, expected) => {
    expect(getAuthErrorMessage({ code })).toBe(expected);
  });
});
