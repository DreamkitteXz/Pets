/**
 * Pets App — Firebase Cloud Functions
 *
 * SETUP (one-time, after `firebase login` and upgrading to Blaze plan):
 *
 *   1. cd Pets
 *   2. firebase functions:config:set gmail.email="you@gmail.com" gmail.password="your-app-password"
 *      (Gmail App Password: myaccount.google.com/apppasswords — requires 2FA enabled)
 *   3. cd functions && npm install
 *   4. cd .. && firebase deploy --only functions
 *
 * LOCAL EMULATOR (optional):
 *   firebase emulators:start --only functions,firestore
 */

const functions = require('firebase-functions');
const admin     = require('firebase-admin');
const crypto    = require('crypto');
const nodemailer = require('nodemailer');

admin.initializeApp();

const db   = admin.firestore();
const auth = admin.auth();

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
  const { email, password } = functions.config().gmail || {};
  if (!email || !password) {
    throw new Error('Gmail credentials not configured. Run: firebase functions:config:set gmail.email="..." gmail.password="..."');
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
          <!-- Header -->
          <tr>
            <td style="background:#023047;padding:26px 32px;">
              <span style="color:#ffffff;font-size:20px;font-weight:700;letter-spacing:-0.02em;">Pets</span>
              <span style="display:block;color:rgba(255,255,255,0.45);font-size:12px;margin-top:2px;">
                Sistema de Documentação Pet
              </span>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style="padding:36px 32px 28px;">
              <h1 style="color:#0f172a;font-size:21px;font-weight:700;margin:0 0 10px;letter-spacing:-0.01em;">
                Verifique seu e-mail
              </h1>
              <p style="color:#5b6470;font-size:14px;line-height:1.65;margin:0 0 28px;">
                ${firstName ? `Olá, <strong style="color:#111827">${firstName}</strong>!` : 'Olá!'}
                Use o código abaixo para confirmar seu endereço de e-mail e acessar sua conta.
              </p>
              <!-- Code box -->
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
              <p style="color:#b4b4b4;font-size:12px;line-height:1.6;
                        margin:22px 0 0;text-align:center;">
                Não compartilhe este código com ninguém.<br>
                Se você não criou uma conta, ignore este e-mail.
              </p>
            </td>
          </tr>
          <!-- Footer -->
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
exports.sendVerificationOtp = functions.https.onCall(async (data, context) => {
  // Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Autenticação necessária.');
  }

  const uid   = context.auth.uid;
  const email = context.auth.token.email;
  const name  = data?.name || '';

  if (!email) {
    throw new functions.https.HttpsError('invalid-argument', 'E-mail não encontrado na conta.');
  }

  const otpRef = db.collection('otpCodes').doc(uid);
  const now    = admin.firestore.Timestamp.now();
  const oneHourAgo = new admin.firestore.Timestamp(now.seconds - 3600, 0);

  // Rate limiting
  const existing = await otpRef.get();
  if (existing.exists) {
    const history = (existing.data().sendHistory || [])
      .filter(t => t.seconds > oneHourAgo.seconds);
    if (history.length >= MAX_SENDS_PER_HOUR) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        `Limite de ${MAX_SENDS_PER_HOUR} envios por hora atingido. Aguarde antes de solicitar um novo código.`
      );
    }
  }

  // Generate and store OTP
  const otp    = generateOtp();
  const salt   = generateSalt();
  const hash   = hashOtp(otp, salt);
  const expiresAt = new admin.firestore.Timestamp(now.seconds + OTP_EXPIRY_MINUTES * 60, 0);

  const recentHistory = existing.exists
    ? (existing.data().sendHistory || []).filter(t => t.seconds > oneHourAgo.seconds)
    : [];

  await otpRef.set({
    hash,
    salt,
    expiresAt,
    attempts: 0,
    used: false,
    email,
    createdAt: now,
    sendHistory: [...recentHistory, now],
  });

  // Send email
  try {
    const transporter = createTransporter();
    const gmailEmail  = functions.config().gmail.email;
    await transporter.sendMail({
      from:    `"Pets App" <${gmailEmail}>`,
      to:      email,
      subject: `${otp} é seu código de verificação — Pets App`,
      html:    buildEmailHtml(otp, name),
    });
  } catch (emailErr) {
    functions.logger.error('Failed to send OTP email:', emailErr);
    await otpRef.delete();
    throw new functions.https.HttpsError(
      'internal',
      'Não foi possível enviar o e-mail. Verifique sua conexão e tente novamente.'
    );
  }

  return { success: true };
});

/* ── verifyOtp ───────────────────────────────────────────────────────────── */
exports.verifyOtp = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Autenticação necessária.');
  }

  const uid  = context.auth.uid;
  const code = (data?.code || '').trim();

  if (!code || code.length !== 6 || !/^\d{6}$/.test(code)) {
    throw new functions.https.HttpsError('invalid-argument', 'Código deve ter 6 dígitos numéricos.');
  }

  const otpRef = db.collection('otpCodes').doc(uid);
  const otpDoc = await otpRef.get();

  if (!otpDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Código não encontrado. Solicite um novo código.');
  }

  const otp = otpDoc.data();
  const now = admin.firestore.Timestamp.now();

  if (otp.used) {
    throw new functions.https.HttpsError('already-exists', 'Este código já foi utilizado. Solicite um novo.');
  }

  if (otp.expiresAt.seconds < now.seconds) {
    await otpRef.update({ used: true });
    throw new functions.https.HttpsError('deadline-exceeded', 'Código expirado. Solicite um novo código.');
  }

  if (otp.attempts >= MAX_VERIFY_ATTEMPTS) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Muitas tentativas incorretas. Solicite um novo código.'
    );
  }

  // Increment attempt before validation (prevents timing attacks)
  await otpRef.update({ attempts: admin.firestore.FieldValue.increment(1) });

  // Validate
  const inputHash = hashOtp(code, otp.salt);
  if (inputHash !== otp.hash) {
    const remaining = MAX_VERIFY_ATTEMPTS - (otp.attempts + 1);
    throw new functions.https.HttpsError(
      'invalid-argument',
      remaining > 0
        ? `Código incorreto. ${remaining} tentativa${remaining !== 1 ? 's' : ''} restante${remaining !== 1 ? 's' : ''}.`
        : 'Código incorreto. Solicite um novo código.'
    );
  }

  // Mark used and verify user
  await otpRef.update({ used: true });

  await auth.updateUser(uid, { emailVerified: true });

  await db.collection('users').doc(uid).update({
    emailVerified: true,
    updatedAt:     new Date().toISOString(),
  });

  return { success: true };
});
