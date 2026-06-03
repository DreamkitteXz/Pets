/**
 * Pets App — Firebase Cloud Functions (2nd Gen / Node.js 22)
 *
 * SETUP (one-time):
 *
 *   1. cd Pets
 *   2. Configurar secrets do Gmail (substitui functions:config:set):
 *        firebase functions:secrets:set GMAIL_EMAIL
 *        firebase functions:secrets:set GMAIL_PASSWORD
 *      (Gmail App Password: myaccount.google.com/apppasswords — exige 2FA ativo)
 *   3. cd functions && npm install
 *   4. cd .. && firebase deploy --only functions
 *
 * LOCAL EMULATOR (opcional):
 *   firebase emulators:start --only functions,firestore
 */

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret }       = require('firebase-functions/params');
const logger                 = require('firebase-functions/logger');
const admin                  = require('firebase-admin');
const crypto                 = require('crypto');
const nodemailer             = require('nodemailer');

admin.initializeApp();

const db   = admin.firestore();
const auth = admin.auth();

// Secrets — injected as env vars at runtime after `firebase functions:secrets:set`
const gmailEmailSecret    = defineSecret('GMAIL_EMAIL');
const gmailPasswordSecret = defineSecret('GMAIL_PASSWORD');

const OTP_EXPIRY_MINUTES  = 10;
const MAX_VERIFY_ATTEMPTS = 5;
const MAX_SENDS_PER_HOUR  = 3;

/* ── Helpers ─────────────────────────────────────────────────────────────── */

function generateOtp() {
  return crypto.randomInt(100000, 1000000).toString().padStart(6, '0');
}

function generateSalt() {
  return crypto.randomBytes(32).toString('hex');
}

function hashOtp(otp, salt) {
  return crypto.createHmac('sha256', salt).update(otp).digest('hex');
}

function createTransporter() {
  const email    = process.env.GMAIL_EMAIL;
  const password = process.env.GMAIL_PASSWORD;
  if (!email || !password) {
    throw new Error('Gmail secrets not set. Run: firebase functions:secrets:set GMAIL_EMAIL && firebase functions:secrets:set GMAIL_PASSWORD');
  }
  return nodemailer.createTransport({
    service: 'gmail',
    auth: { user: email, pass: password },
  });
}

function buildEmailHtml(otp, name) {
  const firstName = name ? name.split(' ')[0] : null;
  const year = new Date().getFullYear();
  return `
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Código de verificação</title>
</head>
<body style="margin:0;padding:0;background:#f0f4f8;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="min-height:100vh;background:#f0f4f8;">
    <tr>
      <td align="center" style="padding:48px 16px;">
        <table width="480" cellpadding="0" cellspacing="0"
               style="background:#ffffff;border-radius:16px;overflow:hidden;
                      box-shadow:0 4px 24px rgba(0,0,0,0.08);max-width:100%;">
          <tr>
            <td style="background:#023047;padding:26px 32px;">
              <span style="color:#ffffff;font-size:20px;font-weight:700;letter-spacing:-0.02em;">Pets</span>
              <span style="display:block;color:rgba(255,255,255,0.45);font-size:12px;margin-top:2px;">
                Sistema de Documentação Pet
              </span>
            </td>
          </tr>
          <tr>
            <td style="padding:36px 32px 28px;">
              <h1 style="color:#0f172a;font-size:21px;font-weight:700;margin:0 0 10px;letter-spacing:-0.01em;">
                Verifique seu e-mail
              </h1>
              <p style="color:#5b6470;font-size:14px;line-height:1.65;margin:0 0 28px;">
                ${firstName ? `Olá, <strong style="color:#111827">${firstName}</strong>!` : 'Olá!'}
                Use o código abaixo para confirmar seu endereço de e-mail e acessar sua conta.
              </p>
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td style="background:#f5f8fb;border-radius:12px;padding:24px 16px;text-align:center;
                             border:1px solid #e3e6ea;">
                    <p style="color:#9aa0a9;font-size:11px;text-transform:uppercase;
                              letter-spacing:0.1em;margin:0 0 10px;">
                      Código de verificação
                    </p>
                    <span style="font-size:42px;font-weight:800;letter-spacing:14px;
                                 color:#023047;font-family:'Courier New',Courier,monospace;">
                      ${otp}
                    </span>
                    <p style="color:#9aa0a9;font-size:12px;margin:10px 0 0;">
                      Válido por ${OTP_EXPIRY_MINUTES} minutos
                    </p>
                  </td>
                </tr>
              </table>
              <p style="color:#b4b4b4;font-size:12px;line-height:1.6;margin:22px 0 0;text-align:center;">
                Não compartilhe este código com ninguém.<br>
                Se você não criou uma conta, ignore este e-mail.
              </p>
            </td>
          </tr>
          <tr>
            <td style="border-top:1px solid #e3e6ea;padding:16px 32px;text-align:center;">
              <p style="color:#c4c4c4;font-size:11px;margin:0;">
                © ${year} Pets App &nbsp;·&nbsp; pet-app-fccae.web.app
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `.trim();
}

/* ── sendVerificationOtp ─────────────────────────────────────────────────── */
exports.sendVerificationOtp = onCall(
  { region: 'southamerica-east1', secrets: [gmailEmailSecret, gmailPasswordSecret] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Autenticação necessária.');
    }

    const uid   = request.auth.uid;
    const email = request.auth.token.email;
    const name  = request.data?.name || '';

    if (!email) {
      throw new HttpsError('invalid-argument', 'E-mail não encontrado na conta.');
    }

    const otpRef     = db.collection('otpCodes').doc(uid);
    const now        = admin.firestore.Timestamp.now();
    const oneHourAgo = new admin.firestore.Timestamp(now.seconds - 3600, 0);

    // Rate limiting
    const existing = await otpRef.get();
    if (existing.exists) {
      const history = (existing.data().sendHistory || [])
        .filter(t => t.seconds > oneHourAgo.seconds);
      if (history.length >= MAX_SENDS_PER_HOUR) {
        throw new HttpsError(
          'resource-exhausted',
          `Limite de ${MAX_SENDS_PER_HOUR} envios por hora atingido. Aguarde antes de solicitar um novo código.`
        );
      }
    }

    // Generate and store OTP
    const otp       = generateOtp();
    const salt      = generateSalt();
    const hash      = hashOtp(otp, salt);
    const expiresAt = new admin.firestore.Timestamp(now.seconds + OTP_EXPIRY_MINUTES * 60, 0);

    const recentHistory = existing.exists
      ? (existing.data().sendHistory || []).filter(t => t.seconds > oneHourAgo.seconds)
      : [];

    await otpRef.set({
      hash, salt, expiresAt,
      attempts: 0, used: false, email,
      createdAt: now,
      sendHistory: [...recentHistory, now],
    });

    // Send email
    try {
      const transporter = createTransporter();
      await transporter.sendMail({
        from:    `"Pets App" <${process.env.GMAIL_EMAIL}>`,
        to:      email,
        subject: `${otp} é seu código de verificação — Pets App`,
        html:    buildEmailHtml(otp, name),
      });
    } catch (emailErr) {
      logger.error('Failed to send OTP email:', emailErr);
      await otpRef.delete();
      throw new HttpsError(
        'internal',
        'Não foi possível enviar o e-mail. Verifique sua conexão e tente novamente.'
      );
    }

    return { success: true };
  }
);

/* ── verifyOtp ───────────────────────────────────────────────────────────── */
exports.verifyOtp = onCall(
  { region: 'southamerica-east1' },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Autenticação necessária.');
    }

    const uid  = request.auth.uid;
    const code = (request.data?.code || '').trim();

    if (!code || code.length !== 6 || !/^\d{6}$/.test(code)) {
      throw new HttpsError('invalid-argument', 'Código deve ter 6 dígitos numéricos.');
    }

    const otpRef = db.collection('otpCodes').doc(uid);
    const otpDoc = await otpRef.get();

    if (!otpDoc.exists) {
      throw new HttpsError('not-found', 'Código não encontrado. Solicite um novo código.');
    }

    const otp = otpDoc.data();
    const now = admin.firestore.Timestamp.now();

    if (otp.used) {
      throw new HttpsError('already-exists', 'Este código já foi utilizado. Solicite um novo.');
    }

    if (otp.expiresAt.seconds < now.seconds) {
      await otpRef.update({ used: true });
      throw new HttpsError('deadline-exceeded', 'Código expirado. Solicite um novo código.');
    }

    if (otp.attempts >= MAX_VERIFY_ATTEMPTS) {
      throw new HttpsError('resource-exhausted', 'Muitas tentativas incorretas. Solicite um novo código.');
    }

    // Increment attempt before validation (prevents timing attacks)
    await otpRef.update({ attempts: admin.firestore.FieldValue.increment(1) });

    const inputHash = hashOtp(code, otp.salt);
    if (inputHash !== otp.hash) {
      const remaining = MAX_VERIFY_ATTEMPTS - (otp.attempts + 1);
      throw new HttpsError(
        'invalid-argument',
        remaining > 0
          ? `Código incorreto. ${remaining} tentativa${remaining !== 1 ? 's' : ''} restante${remaining !== 1 ? 's' : ''}.`
          : 'Código incorreto. Solicite um novo código.'
      );
    }

    await otpRef.update({ used: true });
    await auth.updateUser(uid, { emailVerified: true });
    await db.collection('users').doc(uid).update({
      emailVerified: true,
      updatedAt:     new Date().toISOString(),
    });

    return { success: true };
  }
);

/* ── CPF / CRMV helpers ──────────────────────────────────────────────────── */

function validateCpf(raw) {
  const cpf = String(raw).replace(/\D/g, '');
  if (cpf.length !== 11 || /^(\d)\1+$/.test(cpf)) return false;
  let sum = 0;
  for (let i = 1; i <= 9; i++) sum += parseInt(cpf[i - 1]) * (11 - i);
  let rem = (sum * 10) % 11;
  if (rem === 10 || rem === 11) rem = 0;
  if (rem !== parseInt(cpf[9])) return false;
  sum = 0;
  for (let i = 1; i <= 10; i++) sum += parseInt(cpf[i - 1]) * (12 - i);
  rem = (sum * 10) % 11;
  if (rem === 10 || rem === 11) rem = 0;
  return rem === parseInt(cpf[10]);
}

function validateCrmv(crmv) {
  return /^CRMV-[A-Z]{2}\s\d{1,5}$/.test(String(crmv));
}

/* ── createVaccineRecord ─────────────────────────────────────────────────── */
exports.createVaccineRecord = onCall(
  { region: 'southamerica-east1' },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Autenticação necessária.');
    }

    const { vaccineData } = request.data || {};
    if (!vaccineData) {
      throw new HttpsError('invalid-argument', 'Dados da vacina não informados.');
    }

    if (vaccineData.cpf && !validateCpf(vaccineData.cpf)) {
      throw new HttpsError('invalid-argument', 'CPF inválido.');
    }

    if (vaccineData.crmv && !validateCrmv(vaccineData.crmv)) {
      throw new HttpsError('invalid-argument', 'CRMV inválido. Use o formato: CRMV-XX 12345');
    }

    const ref = db.collection('vaccines').doc();
    await ref.set({
      ...vaccineData,
      veterinarianId: request.auth.uid,
      status: 'pending',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { id: ref.id };
  }
);

/* ── updateVaccineStatus ─────────────────────────────────────────────────── */
exports.updateVaccineStatus = onCall(
  { region: 'southamerica-east1' },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Autenticação necessária.');
    }

    const { vaccineId, isApproved, notes, rejectionReason } = request.data || {};

    if (!vaccineId) {
      throw new HttpsError('invalid-argument', 'ID da vacina não informado.');
    }
    if (!isApproved && !rejectionReason) {
      throw new HttpsError('invalid-argument', 'Motivo da rejeição é obrigatório.');
    }

    const vaccineRef = db.collection('vaccines').doc(vaccineId);
    const snap       = await vaccineRef.get();

    if (!snap.exists) {
      throw new HttpsError('not-found', 'Vacina não encontrada.');
    }

    const vaccine = snap.data();

    if (vaccine.veterinarianId !== request.auth.uid) {
      throw new HttpsError('permission-denied', 'Sem permissão para validar esta vacina.');
    }

    if (vaccine.status !== 'pending') {
      throw new HttpsError('failed-precondition', 'Esta vacina não está pendente de validação.');
    }

    const newStatus = isApproved ? 'vetApproved' : 'vetRejected';

    await vaccineRef.update({
      status: newStatus,
      'validationDetails.vetValidation': {
        status: isApproved ? 'approved' : 'rejected',
        validatedAt: admin.firestore.FieldValue.serverTimestamp(),
        validatedBy: request.auth.uid,
        notes:           notes || '',
        rejectionReason: isApproved ? '' : rejectionReason,
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    if (vaccine.ownerId) {
      await db.collection('users').doc(vaccine.ownerId)
        .collection('notifications').add({
          type: 'VACCINE_VALIDATION',
          vaccineId,
          status: newStatus,
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }

    return { success: true, status: newStatus };
  }
);
