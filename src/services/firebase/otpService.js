/**
 * OTP Service — client-side wrapper for the Cloud Functions.
 *
 * Both functions are Firebase callable: the SDK automatically includes the
 * user's ID token, so the server can verify `context.auth` without manual work.
 */

import { httpsCallable } from 'firebase/functions';
import { functions, auth } from '../../config/firebase';

const sendVerificationOtpFn = httpsCallable(functions, 'sendVerificationOtp', { timeout: 15000 });
const verifyOtpFn           = httpsCallable(functions, 'verifyOtp',           { timeout: 15000 });

/* ── Error mapper ────────────────────────────────────────────────────────── */
function mapOtpError(err) {
  const raw  = err?.code || '';
  const code = raw.replace('functions/', '');
  const serverMsg = err?.message || '';

  const map = {
    'invalid-argument':  serverMsg || 'Código inválido.',
    'not-found':         'Código não encontrado. Solicite um novo.',
    'deadline-exceeded': 'Código expirado. Solicite um novo código.',
    'already-exists':    'Este código já foi utilizado. Solicite um novo.',
    'resource-exhausted': serverMsg || 'Limite de tentativas atingido. Aguarde e solicite um novo código.',
    'unauthenticated':   'Sessão expirada. Faça login novamente.',
    'internal':          serverMsg || 'Erro no servidor. Tente novamente.',
    'unavailable':       'Serviço temporariamente indisponível. Tente novamente em instantes.',
    'cancelled':         'Operação cancelada. Tente novamente.',
  };

  return map[code] || serverMsg || 'Ocorreu um erro inesperado. Tente novamente.';
}

/* ── Detect error type for UI branching ──────────────────────────────────── */
export function classifyOtpError(err) {
  const code = (err?.code || '').replace('functions/', '');
  if (code === 'deadline-exceeded') return 'expired';
  if (code === 'resource-exhausted') return 'rate_limited';
  if (code === 'not-found')          return 'not_found';
  if (code === 'already-exists')     return 'already_used';
  return 'invalid';
}

/* ── sendOtp ─────────────────────────────────────────────────────────────── */
export async function sendOtp() {
  const user = auth.currentUser;
  if (!user) return { error: 'Usuário não autenticado.' };

  try {
    await sendVerificationOtpFn({ name: user.displayName || '' });
    return { error: null };
  } catch (err) {
    return { error: mapOtpError(err), raw: err };
  }
}

/* ── verifyOtp ───────────────────────────────────────────────────────────── */
export async function verifyOtp(code) {
  const user = auth.currentUser;
  if (!user) return { success: false, error: 'Usuário não autenticado.' };

  try {
    await verifyOtpFn({ code });
    // Reload the Firebase user so auth.currentUser.emailVerified becomes true
    await user.reload();
    return { success: true, error: null };
  } catch (err) {
    return { success: false, error: mapOtpError(err), raw: err };
  }
}
