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
const { onDocumentWritten }  = require('firebase-functions/v2/firestore');
const { defineSecret }       = require('firebase-functions/params');
const logger                 = require('firebase-functions/logger');
const admin                  = require('firebase-admin');
// API modular: `admin.firestore.FieldValue` (namespace) some no runtime do emulador.
const { FieldValue, Timestamp } = require('firebase-admin/firestore');
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
    const now        = Timestamp.now();
    const oneHourAgo = new Timestamp(now.seconds - 3600, 0);

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
    const expiresAt = new Timestamp(now.seconds + OTP_EXPIRY_MINUTES * 60, 0);

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
    const now = Timestamp.now();

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
    await otpRef.update({ attempts: FieldValue.increment(1) });

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
      updatedAt:     FieldValue.serverTimestamp(),
    });

    return { success: true };
  }
);

/* ── CRMV helper ─────────────────────────────────────────────────────────── */

function validateCrmv(crmv) {
  return /^CRMV-[A-Z]{2}\s\d{1,5}$/.test(String(crmv));
}

/* ── Autoridade do veterinário ───────────────────────────────────────────────
 *
 * Validar ou registrar como aprovado exige um VETERINÁRIO ATIVO. O papel vem do
 * doc `users/{uid}`, cujo `role` a rule só deixa definir uma vez no onboarding.
 * Nunca confiar só em `vaccine.veterinarianId == caller`: era assim que um
 * tutor que se declarasse vet aprovava a própria vacina.
 */
const APPLICATION_COLLECTIONS = ['vaccines', 'deworming'];

async function requireActiveVet(uid) {
  const snap = await db.collection('users').doc(uid).get();
  const vet  = snap.exists ? snap.data() : null;
  if (!vet || vet.role !== 'veterinarian' || vet.status !== 'active' || !validateCrmv(vet.crmv || '')) {
    throw new HttpsError('permission-denied', 'Apenas veterinários ativos com CRMV podem fazer isto.');
  }
  return vet;
}

function resolveCollection(name) {
  const collection = name || 'vaccines';
  if (!APPLICATION_COLLECTIONS.includes(collection)) {
    throw new HttpsError('invalid-argument', 'Tipo de registro inválido.');
  }
  return collection;
}

// Campos que só o servidor define — ignorados se vierem do cliente.
const SERVER_OWNED_FIELDS = [
  'status', 'validationDetails', 'veterinarianId', 'veterinarianName', 'crmvNumber',
  'ownerId', 'createdBy', 'updatedBy', 'createdAt', 'updatedAt',
  'tutorAcknowledged', 'tutorAcknowledgedAt', 'active', 'deletedAt', 'deletedBy',
];

// Datas chegam do callable como string ISO (ou null) e são gravadas como Timestamp.
const DATE_FIELDS = ['administrationDate', 'expirationDate', 'nextDueDate', 'reinforcementDate'];

function toTimestamp(value, field) {
  if (value === null || value === undefined || value === '') return null;
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) {
    throw new HttpsError('invalid-argument', `Data inválida em "${field}".`);
  }
  return Timestamp.fromDate(d);
}

/* ── createVaccineRecord ─────────────────────────────────────────────────────
 *
 * Registro feito PELO VETERINÁRIO (vacina ou vermífugo). Nasce aprovado,
 * validado pelo CRMV de quem aplicou — por isso precisa passar pelo servidor:
 * a rule só aceita do cliente a submissão `pending` do tutor.
 *
 * Input: { vaccineData, collection?: 'vaccines' | 'deworming' }
 */
exports.createVaccineRecord = onCall(
  { region: 'southamerica-east1' },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Autenticação necessária.');
    }

    const { vaccineData, collection: collectionName } = request.data || {};
    if (!vaccineData || typeof vaccineData !== 'object') {
      throw new HttpsError('invalid-argument', 'Dados do registro não informados.');
    }
    const collection = resolveCollection(collectionName);
    const uid = request.auth.uid;
    const vet = await requireActiveVet(uid);

    if (!vaccineData.petId) {
      throw new HttpsError('invalid-argument', 'Paciente não informado.');
    }
    const petSnap = await db.collection('pets').doc(String(vaccineData.petId)).get();
    if (!petSnap.exists) {
      throw new HttpsError('not-found', 'Paciente não encontrado.');
    }
    const pet = petSnap.data();
    if (!Array.isArray(pet.veterinarians) || !pet.veterinarians.includes(uid)) {
      throw new HttpsError('permission-denied', 'Você não está vinculado a este paciente.');
    }

    const data = { ...vaccineData };
    SERVER_OWNED_FIELDS.forEach((f) => delete data[f]);
    DATE_FIELDS.forEach((f) => {
      if (f in data) data[f] = toTimestamp(data[f], f);
    });
    if (data.labelImageMetadata && typeof data.labelImageMetadata === 'object') {
      data.labelImageMetadata = {
        ...data.labelImageMetadata,
        timeCreated: FieldValue.serverTimestamp(),
        updated:     FieldValue.serverTimestamp(),
      };
    }

    const now = FieldValue.serverTimestamp();
    const ref = db.collection(collection).doc();
    await ref.set({
      ...data,
      ownerId:          pet.ownerId || '',
      veterinarianId:   uid,
      veterinarianName: vet.name || '',
      crmvNumber:       vet.crmv,
      status:           'approved',
      validationDetails: {
        vetValidation: {
          status:          'approved',
          validatedAt:     now,
          validatedBy:     uid,
          validatedByName: vet.name || '',
          validatedByCrmv: vet.crmv,
          notes:           'Registrado e validado pelo veterinário aplicador.',
          rejectionReason: '',
        },
      },
      tutorAcknowledged:   false,
      tutorAcknowledgedAt: null,
      active:    true,
      createdBy: uid,
      updatedBy: uid,
      createdAt: now,
      updatedAt: now,
    });

    return { id: ref.id };
  }
);

/* ── updateVaccineStatus ─────────────────────────────────────────────────────
 *
 * O veterinário responsável aprova ou rejeita uma submissão `pending` do tutor.
 * Input: { vaccineId, isApproved, notes?, rejectionReason?, collection?: 'vaccines' | 'deworming' }
 * Sem `collection`, segue valendo para vacinas (chamadas existentes).
 */
exports.updateVaccineStatus = onCall(
  { region: 'southamerica-east1' },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Autenticação necessária.');
    }

    const { vaccineId, isApproved, notes, rejectionReason, collection: collectionName } = request.data || {};
    const collection = resolveCollection(collectionName);

    if (!vaccineId) {
      throw new HttpsError('invalid-argument', 'ID do registro não informado.');
    }
    if (!isApproved && !rejectionReason) {
      throw new HttpsError('invalid-argument', 'Motivo da rejeição é obrigatório.');
    }

    const vaccineRef = db.collection(collection).doc(vaccineId);
    const snap       = await vaccineRef.get();

    if (!snap.exists) {
      throw new HttpsError('not-found', 'Registro não encontrado.');
    }

    const vaccine = snap.data();

    if (vaccine.veterinarianId !== request.auth.uid) {
      throw new HttpsError('permission-denied', 'Sem permissão para validar este registro.');
    }

    if (vaccine.status !== 'pending') {
      throw new HttpsError('failed-precondition', 'Este registro não está pendente de validação.');
    }

    // Ser o veterinarianId do registro não basta: quem valida precisa ser vet ativo.
    const vetData = await requireActiveVet(request.auth.uid);

    // Eixo único de status: aprovação/rejeição do vet define o status diretamente.
    const newStatus = isApproved ? 'approved' : 'rejected';

    await vaccineRef.update({
      status: newStatus,
      'validationDetails.vetValidation': {
        status:          newStatus,
        validatedAt:     FieldValue.serverTimestamp(),
        validatedBy:     request.auth.uid,
        validatedByName: vetData.name || '',
        validatedByCrmv: vetData.crmv || '',
        notes:           notes || '',
        rejectionReason: isApproved ? '' : rejectionReason,
      },
      updatedBy: request.auth.uid,
      updatedAt: FieldValue.serverTimestamp(),
    });

    if (vaccine.ownerId) {
      await db.collection('users').doc(vaccine.ownerId)
        .collection('notifications').add({
          // Mesmo `type` para os dois — as caixas de notificação (web e app)
          // já sabem exibi-lo; `collection` diz se é vacina ou vermífugo.
          type: 'VACCINE_VALIDATION',
          vaccineId,
          collection,
          status: newStatus,
          read: false,
          createdAt: FieldValue.serverTimestamp(),
        });
    }

    return { success: true, status: newStatus };
  }
);

/* ── Diretório público de veterinários ───────────────────────────────────────
 *
 * O app precisa listar veterinários para o tutor associar a uma vacina, mas o
 * documento em `users` guarda cpf, email, phone e o endereço residencial
 * completo (street, number, neighborhood, city, state, zipCode). Liberar
 * consulta por `role` em `users` exporia tudo isso a qualquer tutor.
 *
 * Então `users` continua fechado e esta função espelha APENAS o subconjunto
 * público em `vet_directory/{uid}`, que a rule abre para leitura autenticada e
 * fecha para escrita de todo cliente — só o Admin SDK escreve aqui.
 */

/**
 * Lista de PERMITIDOS, não de proibidos.
 *
 * Deliberado: com uma lista de proibidos, um campo sensível adicionado ao
 * perfil no futuro viraria público por esquecimento. Aqui o padrão é não
 * publicar, e incluir algo novo exige uma edição consciente desta linha.
 *
 * `clinicId` NÃO entra: o vínculo vet↔clínica mora em `clinics.veterinarians`,
 * e duplicá-lo aqui exigiria um segundo trigger sobre `clinics` para não
 * desincronizar. O app deriva a clínica da lista que já carrega.
 */
const VET_PUBLIC_FIELDS = ['name', 'crmv', 'specialties', 'yearsOfExperience'];

exports.mirrorVetDirectory = onDocumentWritten(
  { document: 'users/{uid}', region: 'southamerica-east1' },
  async (event) => {
    const uid    = event.params.uid;
    const before = event.data?.before?.data();
    const after  = event.data?.after?.data();

    // O trigger cobre TODA escrita em `users`, e a maioria é de tutor. Sem
    // esta saída, cada atualização de perfil de tutor gastaria um `delete` num
    // documento que nunca existiu.
    const tocaVet =
      before?.role === 'veterinarian' || after?.role === 'veterinarian';
    if (!tocaVet) return;

    const ref = db.collection('vet_directory').doc(uid);

    // Só veterinário ATIVO aparece. Perfil incompleto ainda não tem crmv, e
    // listar um vet sem CRMV daria ao tutor uma escolha que a validação da
    // vacina depois recusaria.
    const publishable =
      after &&
      after.role === 'veterinarian' &&
      after.status === 'active' &&
      !!after.crmv;

    if (!publishable) {
      // Virou tutor, foi desativado ou o documento sumiu: sai do diretório.
      // Sem isto um vet removido continuaria selecionável para sempre.
      await ref.delete().catch((err) => {
        logger.warn('vet_directory: falha ao remover', { uid, err: err.message });
      });
      return;
    }

    const projection = { uid };
    for (const field of VET_PUBLIC_FIELDS) {
      if (after[field] !== undefined) projection[field] = after[field];
    }
    projection.updatedAt = FieldValue.serverTimestamp();

    // `set` sem merge: o documento é derivado por inteiro de `users`, então
    // apagar um campo lá tem que apagá-lo aqui. Com merge, um campo removido
    // do perfil ficaria fossilizado no diretório público.
    await ref.set(projection);
    logger.info('vet_directory atualizado', { uid });
  }
);
