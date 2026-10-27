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
  // S4: declarar um CRMV não basta — ele precisa ter sido conferido pela
  // administração (`adminReviewVet`). Campo ausente = ainda não verificado.
  if (vet.crmvStatus !== 'approved') {
    throw new HttpsError(
      'permission-denied',
      vet.crmvStatus === 'rejected'
        ? 'Seu CRMV não foi aprovado. Veja o motivo em Configurações e reenvie para análise.'
        : 'Seu CRMV está em análise. Você poderá validar e registrar aplicações assim que for aprovado.',
    );
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

    // Só veterinário ATIVO e com CRMV APROVADO pela administração aparece.
    // Listar um vet não verificado daria ao tutor uma escolha que a validação
    // da vacina depois recusaria — e exporia tutores a um CRMV falso.
    const publishable =
      after &&
      after.role === 'veterinarian' &&
      after.status === 'active' &&
      after.crmvStatus === 'approved' &&
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

/* ── Administração: verificação do CRMV (S4) ─────────────────────────────────
 *
 * Quem é admin: custom claim `admin: true` no Auth. Só o Admin SDK define
 * claims (script `functions/scripts/set-admin.js`) — nenhum cliente consegue,
 * e nada no Firestore concede o papel.
 *
 * Toda ação de admin passa por aqui, nunca por escrita direta do cliente:
 *  • claim conferido no TOKEN e de novo no registro do Auth (remover o admin
 *    vale na hora, sem esperar o token de 1h expirar);
 *  • e-mail verificado e login recente (sessão de até 12h para agir);
 *  • ninguém decide sobre o próprio CRMV;
 *  • a decisão confere o CRMV que o admin viu (se o vet trocou no meio, aborta);
 *  • decisão + log de auditoria na MESMA transação: não existe aprovação sem
 *    registro de quem, quando, de onde e por quê.
 * Respostas levam só o necessário para conferir o CRMV — nada de CPF/endereço.
 */
const ADMIN_MAX_SESSION_S = 12 * 60 * 60;
const CRMV_STATUSES = ['pending', 'approved', 'rejected'];

async function requireAdmin(request) {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Autenticação necessária.');
  }
  const { uid, token } = request.auth;
  if (token.admin !== true || token.email_verified !== true) {
    logger.warn('admin: acesso negado', { uid });
    throw new HttpsError('permission-denied', 'Acesso restrito à administração.');
  }
  const ageS = Math.floor(Date.now() / 1000) - Number(token.auth_time || 0);
  if (ageS > ADMIN_MAX_SESSION_S) {
    throw new HttpsError('unauthenticated', 'Por segurança, entre novamente para usar a administração.', { reason: 'reauth' });
  }
  const record = await auth.getUser(uid);
  if (record.disabled || record.customClaims?.admin !== true) {
    logger.warn('admin: claim revogado com token ainda válido', { uid });
    throw new HttpsError('permission-denied', 'Acesso restrito à administração.');
  }
  return { uid, email: record.email || token.email || '' };
}

const toIso = (ts) => (ts && typeof ts.toDate === 'function' ? ts.toDate().toISOString() : null);

/* ── adminListVets ──────────────────────────────────────────────────────────
 * Input: { status: 'pending' | 'approved' | 'rejected' }
 * Output: { vets: [...], counts: { pending, approved, rejected }, audit: [...] }
 */
exports.adminListVets = onCall(
  { region: 'southamerica-east1' },
  async (request) => {
    const actor = await requireAdmin(request);
    const status = request.data?.status || 'pending';
    if (!CRMV_STATUSES.includes(status)) {
      throw new HttpsError('invalid-argument', 'Filtro inválido.');
    }

    const snap = await db.collection('users').where('role', '==', 'veterinarian').limit(1000).get();
    const counts = { pending: 0, approved: 0, rejected: 0 };
    const vets = [];
    snap.forEach((d) => {
      const u = d.data();
      if (!u.crmv) return; // onboarding incompleto: nada a conferir ainda
      if (d.id === actor.uid) return; // o próprio cadastro nunca é decidido por si mesmo
      const s = CRMV_STATUSES.includes(u.crmvStatus) ? u.crmvStatus : 'pending';
      counts[s] += 1;
      if (s !== status) return;
      vets.push({
        uid:               d.id,
        name:              u.name || '',
        email:             u.email || '',
        phone:             u.phone || '',
        crmv:              u.crmv,
        specialties:       Array.isArray(u.specialties) ? u.specialties : [],
        yearsOfExperience: u.yearsOfExperience || 0,
        accountStatus:     u.status || '',
        crmvStatus:        s,
        createdAt:         toIso(u.createdAt),
        review: u.crmvReview ? {
          reviewedAt:      toIso(u.crmvReview.reviewedAt),
          reviewedByEmail: u.crmvReview.reviewedByEmail || '',
          reason:          u.crmvReview.reason || '',
          crmv:            u.crmvReview.crmv || '',
        } : null,
      });
    });
    vets.sort((a, b) => String(a.createdAt || '').localeCompare(String(b.createdAt || '')));

    // O log também guarda outras ações (ex.: disparo de lembretes); aqui só decisões de CRMV.
    const auditSnap = await db.collection('admin_audit_log').orderBy('at', 'desc').limit(60).get();
    const audit = auditSnap.docs.filter((d) => d.data().action === 'crmv_review').slice(0, 20).map((d) => {
      const a = d.data();
      return {
        id: d.id, at: toIso(a.at), actorEmail: a.actorEmail, decision: a.decision,
        targetName: a.targetName, targetCrmv: a.targetCrmv, reason: a.reason || '',
        previousStatus: a.previousStatus, newStatus: a.newStatus,
      };
    });

    logger.info('admin: listou veterinários', { actor: actor.uid, status, total: vets.length });
    return { vets, counts, audit };
  }
);

/* ── adminReviewVet ─────────────────────────────────────────────────────────
 * Input: { uid, decision: 'approve' | 'reject', reason?, expectedCrmv }
 * Recusar (inclusive revogar uma aprovação) exige motivo — o vet vê o motivo.
 */
exports.adminReviewVet = onCall(
  { region: 'southamerica-east1' },
  async (request) => {
    const actor = await requireAdmin(request);
    const { uid, decision, reason, expectedCrmv } = request.data || {};

    if (typeof uid !== 'string' || !uid || uid.length > 128) {
      throw new HttpsError('invalid-argument', 'Veterinário inválido.');
    }
    if (!['approve', 'reject'].includes(decision)) {
      throw new HttpsError('invalid-argument', 'Decisão inválida.');
    }
    const cleanReason = typeof reason === 'string' ? reason.trim().slice(0, 500) : '';
    if (decision === 'reject' && cleanReason.length < 5) {
      throw new HttpsError('invalid-argument', 'Explique o motivo da recusa (mínimo 5 caracteres).');
    }
    if (uid === actor.uid) {
      throw new HttpsError('permission-denied', 'Ninguém aprova ou recusa o próprio CRMV.');
    }

    const newStatus = decision === 'approve' ? 'approved' : 'rejected';
    const userRef   = db.collection('users').doc(uid);
    const auditRef  = db.collection('admin_audit_log').doc();

    const result = await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      if (!snap.exists) throw new HttpsError('not-found', 'Veterinário não encontrado.');
      const u = snap.data();
      if (u.role !== 'veterinarian') {
        throw new HttpsError('failed-precondition', 'Esta conta não é de veterinário.');
      }
      if (!validateCrmv(u.crmv || '')) {
        throw new HttpsError('failed-precondition', 'O CRMV cadastrado está em formato inválido.');
      }
      if (typeof expectedCrmv !== 'string' || expectedCrmv !== u.crmv) {
        throw new HttpsError('aborted', 'O CRMV deste veterinário mudou enquanto você analisava. Recarregue a lista.');
      }
      const previousStatus = CRMV_STATUSES.includes(u.crmvStatus) ? u.crmvStatus : 'pending';
      if (previousStatus === newStatus) {
        throw new HttpsError('failed-precondition', 'Este CRMV já está com essa decisão.');
      }

      const now = FieldValue.serverTimestamp();
      tx.update(userRef, {
        crmvStatus: newStatus,
        crmvReview: {
          status:          newStatus,
          crmv:            u.crmv,
          reason:          cleanReason,
          reviewedBy:      actor.uid,
          reviewedByEmail: actor.email,
          reviewedAt:      now,
        },
      });
      tx.set(auditRef, {
        action:         'crmv_review',
        decision,
        previousStatus,
        newStatus,
        reason:         cleanReason,
        targetUid:      uid,
        targetName:     u.name || '',
        targetCrmv:     u.crmv,
        actorUid:       actor.uid,
        actorEmail:     actor.email,
        ip:             request.rawRequest?.ip || '',
        userAgent:      String(request.rawRequest?.headers?.['user-agent'] || '').slice(0, 300),
        at:             now,
      });
      return { previousStatus };
    });

    await userRef.collection('notifications').add({
      type:      'CRMV_REVIEW',
      status:    newStatus,
      reason:    cleanReason,
      read:      false,
      createdAt: FieldValue.serverTimestamp(),
    }).catch((err) => logger.warn('admin: falha ao notificar vet', { uid, err: err.message }));

    logger.info('admin: decisão de CRMV', { actor: actor.uid, target: uid, from: result.previousStatus, to: newStatus });
    return { status: newStatus };
  }
);

/* ── Lembretes de vencimento por e-mail (W6) ─────────────────────────────────
 *
 * Todo dia às 9h (Brasília) avisa o TUTOR das vacinas e vermífugos que vencem
 * nos próximos 7 dias ou que venceram há até 30 dias. Um e-mail por tutor,
 * reunindo todos os pets, mais o mesmo aviso no sininho do site.
 *
 *  • Cada lembrete sai UMA vez por etapa (a vencer / vencido) e por data de
 *    vencimento: `reminder_log/{coleção}_{id}_{etapa}_{data}` é criado com
 *    `create()` ANTES do envio — se duas execuções coincidirem (agendada e
 *    manual), só uma consegue o registro. Falhou o envio, o registro é
 *    apagado e o lembrete tenta de novo no dia seguinte.
 *  • Dose substituída não gera aviso: se o pet já tomou uma aplicação mais
 *    nova do mesmo produto, a próxima dose da antiga não vale mais.
 *  • Tutor desliga em Configurações (`emailReminders: false`); ligado por padrão.
 *    Só vai para e-mail verificado no Auth.
 *  • Tudo que veio do usuário (nome do pet, do produto) é escapado no HTML.
 */
const { onSchedule } = require('firebase-functions/v2/scheduler');

const REMINDER_KINDS = { vaccines: 'Vacina', deworming: 'Vermífugo' };
const DAY_MS = 24 * 60 * 60 * 1000;
const UPCOMING_DAYS = 7;
const OVERDUE_LOOKBACK_DAYS = 30;
const APP_URL = 'https://pet-app-fccae.web.app';
const SP_TZ = 'America/Sao_Paulo';

const escapeHtml = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => (
  { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]
));
const normName = (s) => String(s || '').trim().toLowerCase();
const tsMillis = (ts) => (ts && typeof ts.toMillis === 'function' ? ts.toMillis() : ts instanceof Date ? ts.getTime() : 0);
// Dia-calendário em São Paulo: "vence hoje" tem que ser hoje para o tutor, não em UTC.
const spDay = (date) => {
  const [y, m, d] = date.toLocaleDateString('en-CA', { timeZone: SP_TZ }).split('-').map(Number);
  return Date.UTC(y, m - 1, d) / DAY_MS;
};
const fmtBR = (date) => date.toLocaleDateString('pt-BR', { timeZone: SP_TZ, day: '2-digit', month: '2-digit', year: 'numeric' });

function whenText(days) {
  if (days === 0) return 'vence hoje';
  if (days === 1) return 'vence amanhã';
  if (days > 1) return `vence em ${days} dias`;
  if (days === -1) return 'venceu ontem';
  return `venceu há ${-days} dias`;
}

/** Lista o que precisa de lembrete hoje, agrupado por tutor. Não escreve nada. */
async function collectDueReminders(now) {
  const today = spDay(now);
  const from  = Timestamp.fromMillis(now.getTime() - (OVERDUE_LOOKBACK_DAYS + 1) * DAY_MS);
  const to    = Timestamp.fromMillis(now.getTime() + (UPCOMING_DAYS + 1) * DAY_MS);
  const history = new Map(); // `${col}:${petId}` → aplicações do pet
  const items = [];

  for (const col of Object.keys(REMINDER_KINDS)) {
    const snap = await db.collection(col)
      .where('nextDueDate', '>=', from).where('nextDueDate', '<=', to).get();
    for (const d of snap.docs) {
      const r = d.data();
      if (r.active === false || r.status === 'rejected' || !r.ownerId || !r.petId) continue;
      const due = r.nextDueDate.toDate();
      const days = spDay(due) - today;
      if (days > UPCOMING_DAYS || days < -OVERDUE_LOOKBACK_DAYS) continue;

      const key = `${col}:${r.petId}`;
      if (!history.has(key)) {
        const h = await db.collection(col).where('petId', '==', r.petId).get();
        history.set(key, h.docs.map((x) => ({ id: x.id, ...x.data() })));
      }
      const mine = tsMillis(r.administrationDate) || tsMillis(r.createdAt);
      const superseded = history.get(key).some((o) => o.id !== d.id
        && o.active !== false && o.status !== 'rejected'
        && normName(o.name) === normName(r.name)
        && (tsMillis(o.administrationDate) || tsMillis(o.createdAt)) > mine);
      if (superseded) continue;

      const stage = days < 0 ? 'overdue' : 'upcoming';
      items.push({
        logId: `${col}_${d.id}_${stage}_${due.toISOString().slice(0, 10)}`,
        collection: col, recordId: d.id, ownerId: r.ownerId, petId: r.petId,
        kindLabel: REMINDER_KINDS[col], name: r.name || REMINDER_KINDS[col], due, days, stage,
      });
    }
  }

  // Já avisados (mesma etapa e mesma data de vencimento) saem da lista.
  const logRefs = items.map((i) => db.collection('reminder_log').doc(i.logId));
  const logs = logRefs.length ? await db.getAll(...logRefs) : [];
  const pending = items.filter((_, idx) => !logs[idx].exists);

  const byOwner = new Map();
  pending.forEach((i) => {
    if (!byOwner.has(i.ownerId)) byOwner.set(i.ownerId, []);
    byOwner.get(i.ownerId).push(i);
  });
  return byOwner;
}

function buildReminderEmailHtml(firstName, items) {
  const year = new Date().getFullYear();
  const rows = items.map((i) => `
              <tr>
                <td style="padding:14px 0;border-bottom:1px solid #eef0f3;">
                  <p style="margin:0;color:#0f172a;font-size:15px;font-weight:600;">${escapeHtml(i.petName)} · ${escapeHtml(i.name)}</p>
                  <p style="margin:3px 0 0;color:#5b6470;font-size:13px;">
                    ${escapeHtml(i.kindLabel)} ·
                    <strong style="color:${i.days < 0 ? '#d92d20' : '#b54708'};">${escapeHtml(whenText(i.days))}</strong>
                    (${escapeHtml(fmtBR(i.due))})
                  </p>
                </td>
              </tr>`).join('');
  return `
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Lembrete de vencimento</title>
</head>
<body style="margin:0;padding:0;background:#f0f4f8;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f0f4f8;">
    <tr>
      <td align="center" style="padding:40px 16px;">
        <table width="480" cellpadding="0" cellspacing="0"
               style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);max-width:100%;">
          <tr>
            <td style="background:#023047;padding:26px 32px;">
              <span style="color:#ffffff;font-size:20px;font-weight:700;letter-spacing:-0.02em;">Pets</span>
              <span style="display:block;color:rgba(255,255,255,0.45);font-size:12px;margin-top:2px;">Sistema de Documentação Pet</span>
            </td>
          </tr>
          <tr>
            <td style="padding:32px 32px 8px;">
              <h1 style="color:#0f172a;font-size:21px;font-weight:700;margin:0 0 10px;letter-spacing:-0.01em;">
                ${items.length === 1 ? 'Uma dose precisa de atenção' : `${items.length} doses precisam de atenção`}
              </h1>
              <p style="color:#5b6470;font-size:14px;line-height:1.65;margin:0 0 8px;">
                ${firstName ? `Olá, <strong style="color:#111827">${escapeHtml(firstName)}</strong>!` : 'Olá!'}
                Estas aplicações dos seus pets vencem em breve ou já venceram. Combine a próxima dose com o veterinário.
              </p>
              <table width="100%" cellpadding="0" cellspacing="0">${rows}
              </table>
              <table cellpadding="0" cellspacing="0" style="margin:24px 0 28px;">
                <tr><td style="background:#0a84ff;border-radius:10px;">
                  <a href="${APP_URL}/minhas-vacinas" style="display:inline-block;padding:12px 22px;color:#ffffff;font-size:14px;font-weight:600;text-decoration:none;">Ver a carteira dos pets</a>
                </td></tr>
              </table>
            </td>
          </tr>
          <tr>
            <td style="border-top:1px solid #e3e6ea;padding:16px 32px;text-align:center;">
              <p style="color:#9aa0a9;font-size:11px;line-height:1.6;margin:0;">
                Você recebe este lembrete porque tem pets cadastrados no Pets App.<br>
                Para não receber mais: <a href="${APP_URL}/settings" style="color:#9aa0a9;">Configurações → Sistema → Lembretes por e-mail</a>.<br>
                © ${year} Pets App · pet-app-fccae.web.app
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`.trim();
}

// No emulador nada sai de verdade: a mensagem vai para `dev_outbox` (só emulador).
function reminderTransport() {
  if (process.env.FUNCTIONS_EMULATOR === 'true') {
    return {
      sendMail: async (msg) => {
        await db.collection('dev_outbox').add({ ...msg, at: FieldValue.serverTimestamp() });
        return { messageId: 'emulator' };
      },
    };
  }
  return createTransporter();
}

/**
 * Envia (ou, com dryRun, só lista) os lembretes de hoje.
 * Retorna um resumo para o log / página de admin.
 */
async function runDueReminders({ now = new Date(), dryRun = false } = {}) {
  const byOwner = await collectDueReminders(now);
  const summary = { tutors: 0, items: 0, sent: 0, skipped: [], preview: [] };
  const transporter = dryRun ? null : reminderTransport();
  const petCache = new Map();
  const petName = async (petId) => {
    if (!petCache.has(petId)) {
      const p = await db.collection('pets').doc(petId).get();
      petCache.set(petId, p.exists ? (p.data().name || 'Seu pet') : 'Seu pet');
    }
    return petCache.get(petId);
  };

  for (const [ownerId, list] of byOwner) {
    const userSnap = await db.collection('users').doc(ownerId).get();
    const profile = userSnap.exists ? userSnap.data() : {};
    if (profile.emailReminders === false) { summary.skipped.push({ ownerId, reason: 'desligou os lembretes' }); continue; }
    const authUser = await auth.getUser(ownerId).catch(() => null);
    if (!authUser?.email || !authUser.emailVerified || authUser.disabled) {
      summary.skipped.push({ ownerId, reason: 'sem e-mail verificado' });
      continue;
    }

    for (const i of list) i.petName = await petName(i.petId);
    list.sort((a, b) => a.days - b.days);
    summary.tutors += 1;
    summary.items += list.length;
    if (dryRun) {
      summary.preview.push({
        email: authUser.email,
        items: list.map((i) => ({ pet: i.petName, kind: i.kindLabel, name: i.name, when: whenText(i.days), due: fmtBR(i.due) })),
      });
      continue;
    }

    // Reserva cada lembrete antes de enviar: quem não conseguir o create() já foi
    // (ou está sendo) avisado por outra execução.
    const claimed = [];
    for (const i of list) {
      try {
        await db.collection('reminder_log').doc(i.logId).create({
          ownerId, collection: i.collection, recordId: i.recordId, stage: i.stage,
          dueDate: Timestamp.fromDate(i.due), status: 'sending', at: FieldValue.serverTimestamp(),
        });
        claimed.push(i);
      } catch { /* já reservado */ }
    }
    if (!claimed.length) continue;

    const first = (profile.name || authUser.displayName || '').split(' ')[0];
    const subject = claimed.length === 1
      ? `${claimed[0].petName}: ${claimed[0].kindLabel.toLowerCase()} ${whenText(claimed[0].days)}`
      : `${claimed.length} doses dos seus pets precisam de atenção`;
    try {
      await transporter.sendMail({
        from: `"Pets App" <${process.env.GMAIL_EMAIL || 'no-reply@pet-app-fccae.web.app'}>`,
        to: authUser.email,
        subject,
        html: buildReminderEmailHtml(first, claimed),
      });
    } catch (err) {
      logger.error('lembretes: falha no envio', { ownerId, err: err.message });
      await Promise.all(claimed.map((i) => db.collection('reminder_log').doc(i.logId).delete().catch(() => {})));
      summary.skipped.push({ ownerId, reason: 'falha no envio' });
      continue;
    }

    const batch = db.batch();
    claimed.forEach((i) => batch.update(db.collection('reminder_log').doc(i.logId), { status: 'sent' }));
    batch.set(db.collection('users').doc(ownerId).collection('notifications').doc(), {
      type: 'DUE_REMINDER',
      count: claimed.length,
      overdue: claimed.some((i) => i.days < 0),
      items: claimed.map((i) => ({ pet: i.petName, kind: i.collection, name: i.name, days: i.days })),
      read: false,
      createdAt: FieldValue.serverTimestamp(),
    });
    await batch.commit();
    summary.sent += claimed.length;
  }

  logger.info('lembretes: execução', { dryRun, tutors: summary.tutors, items: summary.items, sent: summary.sent, skipped: summary.skipped.length });
  return summary;
}

exports.sendDueReminders = onSchedule(
  {
    schedule: 'every day 09:00',
    timeZone: SP_TZ,
    region:   'southamerica-east1',
    secrets:  [gmailEmailSecret, gmailPasswordSecret],
    retryCount: 0, // reenvio fica a cargo do próximo dia (o registro garante que não duplica)
  },
  async () => { await runDueReminders({ now: new Date() }); }
);

/* adminRunReminders — { dryRun: boolean }: pré-visualiza ou dispara agora. */
exports.adminRunReminders = onCall(
  { region: 'southamerica-east1', secrets: [gmailEmailSecret, gmailPasswordSecret] },
  async (request) => {
    const actor = await requireAdmin(request);
    const dryRun = request.data?.dryRun !== false;
    const summary = await runDueReminders({ now: new Date(), dryRun });
    if (!dryRun) {
      await db.collection('admin_audit_log').add({
        action: 'reminders_run', actorUid: actor.uid, actorEmail: actor.email,
        sent: summary.sent, tutors: summary.tutors, at: FieldValue.serverTimestamp(),
      });
    }
    return summary;
  }
);

/* ── Clínicas: veterinário cadastra e entra em clínicas ─────────────────────
 *
 * O cliente nunca cria clínica direto (rule). Tudo passa por aqui e exige
 * veterinário com CRMV APROVADO (`requireActiveVet`).
 *
 *  • Busca no Google: Places API (New), chamada SÓ do servidor. A chave fica
 *    em segredo (`PLACES_API_KEY`), nunca vai ao navegador; cada vet tem
 *    limite de buscas por hora.
 *  • "Adicionar do Google" recebe só o placeId e busca os dados de novo no
 *    Google — o cliente não consegue forjar nome/endereço "vindos do Google".
 *    O doc tem id determinístico (`gplace_<placeId>`): a mesma clínica nunca
 *    é cadastrada duas vezes, nem com cliques simultâneos.
 *  • Manual: campos validados (CNPJ com dígito verificador); com CNPJ, o id é
 *    `cnpj_<dígitos>` pelo mesmo motivo.
 *  • Já cadastrada: o vet entra nela (`joinClinic`) em vez de duplicar.
 */
const placesApiKeySecret = defineSecret('PLACES_API_KEY');
// No emulador os testes apontam para um Google falso local; em produção, sempre o real.
const PLACES_BASE = (process.env.FUNCTIONS_EMULATOR === 'true' && process.env.PLACES_FAKE_URL)
  || 'https://places.googleapis.com/v1';
const PLACE_FIELDS = ['id', 'displayName', 'formattedAddress', 'addressComponents',
  'nationalPhoneNumber', 'websiteUri', 'location', 'businessStatus'];
const SEARCHES_PER_HOUR = 30;

async function rateLimit(uid, bucket, max, windowS) {
  const ref = db.collection('rate_limits').doc(`${bucket}_${uid}`);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const now = Date.now();
    const hits = (snap.exists ? snap.data().hits || [] : []).filter((t) => t > now - windowS * 1000);
    if (hits.length >= max) {
      throw new HttpsError('resource-exhausted', 'Muitas buscas em pouco tempo. Tente de novo em alguns minutos.');
    }
    tx.set(ref, { hits: [...hits, now] });
  });
}

function placeToClinic(p) {
  const comp = (type, short = false) => {
    const c = (p.addressComponents || []).find((x) => (x.types || []).includes(type));
    return c ? (short ? c.shortText : c.longText) || '' : '';
  };
  return {
    googlePlaceId: p.id,
    name: p.displayName?.text || '',
    phone: p.nationalPhoneNumber || '',
    website: p.websiteUri || '',
    formattedAddress: p.formattedAddress || '',
    address: {
      street:       comp('route'),
      number:       comp('street_number'),
      complement:   '',
      neighborhood: comp('sublocality_level_1') || comp('sublocality'),
      city:         comp('administrative_area_level_2') || comp('locality'),
      state:        comp('administrative_area_level_1', true),
      zipCode:      comp('postal_code'),
    },
    location: p.location ? { lat: p.location.latitude, lng: p.location.longitude } : null,
    businessStatus: p.businessStatus || '',
  };
}

async function placesRequest(path, { method = 'GET', body, fieldMask }) {
  const key = process.env.PLACES_API_KEY;
  if (!key) throw new HttpsError('failed-precondition', 'Busca no Google ainda não configurada.');
  const res = await fetch(`${PLACES_BASE}${path}`, {
    method,
    headers: { 'Content-Type': 'application/json', 'X-Goog-Api-Key': key, 'X-Goog-FieldMask': fieldMask },
    body: body ? JSON.stringify(body) : undefined,
  });
  if (res.status === 404) throw new HttpsError('not-found', 'Clínica não encontrada no Google.');
  if (!res.ok) {
    logger.error('places: erro', { status: res.status, body: (await res.text()).slice(0, 300) });
    throw new HttpsError('unavailable', 'A busca no Google falhou. Tente de novo ou cadastre manualmente.');
  }
  return res.json();
}

const clinicIdForPlace = (placeId) => `gplace_${placeId}`;
const PLACE_ID_RE = /^[A-Za-z0-9_-]{10,300}$/;

/* searchClinicsOnMaps — { query, city? } → { results: [...] } */
exports.searchClinicsOnMaps = onCall(
  { region: 'southamerica-east1', secrets: [placesApiKeySecret] },
  async (request) => {
    if (!request.auth) throw new HttpsError('unauthenticated', 'Autenticação necessária.');
    await requireActiveVet(request.auth.uid);
    const query = String(request.data?.query || '').trim().slice(0, 80);
    const city  = String(request.data?.city || '').trim().slice(0, 60);
    if (query.length < 2) throw new HttpsError('invalid-argument', 'Digite o nome da clínica ou o bairro.');
    await rateLimit(request.auth.uid, 'places', SEARCHES_PER_HOUR, 3600);

    const data = await placesRequest('/places:searchText', {
      method: 'POST',
      fieldMask: PLACE_FIELDS.map((f) => `places.${f}`).join(','),
      body: {
        textQuery: city ? `${query} ${city}` : query,
        languageCode: 'pt-BR',
        regionCode: 'BR',
        includedType: 'veterinary_care',
        strictTypeFiltering: true,
        maxResultCount: 10,
      },
    });
    const results = (data.places || []).map(placeToClinic).filter((c) => c.businessStatus !== 'CLOSED_PERMANENTLY');

    // Marca as que já estão no Pets (e se o vet já faz parte).
    const refs = results.map((c) => db.collection('clinics').doc(clinicIdForPlace(c.googlePlaceId)));
    const existing = refs.length ? await db.getAll(...refs) : [];
    return {
      results: results.map((c, i) => ({
        ...c,
        clinicId: existing[i].exists ? existing[i].id : null,
        isMember:  existing[i].exists && (existing[i].data().veterinarians || []).includes(request.auth.uid),
      })),
    };
  }
);

/* addClinicFromGoogle — { placeId } → { clinicId, created } */
exports.addClinicFromGoogle = onCall(
  { region: 'southamerica-east1', secrets: [placesApiKeySecret] },
  async (request) => {
    if (!request.auth) throw new HttpsError('unauthenticated', 'Autenticação necessária.');
    const uid = request.auth.uid;
    await requireActiveVet(uid);
    const placeId = String(request.data?.placeId || '');
    if (!PLACE_ID_RE.test(placeId)) throw new HttpsError('invalid-argument', 'Clínica inválida.');

    const ref = db.collection('clinics').doc(clinicIdForPlace(placeId));
    const snap = await ref.get();
    if (snap.exists) {
      await ref.update({ veterinarians: FieldValue.arrayUnion(uid), updatedAt: FieldValue.serverTimestamp() });
      return { clinicId: ref.id, created: false };
    }

    // Dados oficiais buscados de novo no Google — nada do cliente além do id.
    const place = placeToClinic(await placesRequest(`/places/${encodeURIComponent(placeId)}?languageCode=pt-BR&regionCode=BR`, {
      fieldMask: PLACE_FIELDS.join(','),
    }));
    if (!place.name) throw new HttpsError('not-found', 'Clínica não encontrada no Google.');
    const now = FieldValue.serverTimestamp();
    try {
      await ref.create({
        name: place.name, phone: place.phone, email: '', website: place.website, cnpj: '',
        address: place.address, formattedAddress: place.formattedAddress, location: place.location,
        googlePlaceId: placeId, source: 'google', status: 'active',
        veterinarians: [uid], createdBy: uid, createdAt: now, updatedAt: now,
      });
      return { clinicId: ref.id, created: true };
    } catch (err) {
      // Outro vet cadastrou no mesmo instante: só entra nela.
      if (err.code === 6 /* ALREADY_EXISTS */) {
        await ref.update({ veterinarians: FieldValue.arrayUnion(uid), updatedAt: FieldValue.serverTimestamp() });
        return { clinicId: ref.id, created: false };
      }
      throw err;
    }
  }
);

function validCnpj(value) {
  const d = String(value || '').replace(/\D/g, '');
  if (d.length !== 14 || /^(\d)\1+$/.test(d)) return false;
  const digit = (len) => {
    let sum = 0;
    let pos = len - 7;
    for (let i = len; i >= 1; i--) {
      sum += Number(d[len - i]) * pos--;
      if (pos < 2) pos = 9;
    }
    const r = sum % 11;
    return r < 2 ? 0 : 11 - r;
  };
  return digit(12) === Number(d[12]) && digit(13) === Number(d[13]);
}

const cleanText = (v, max) => String(v ?? '').replace(/[\u0000-\u001f]/g, '').trim().slice(0, max);

/* createClinicManual — clínica que não está no Google. */
exports.createClinicManual = onCall(
  { region: 'southamerica-east1' },
  async (request) => {
    if (!request.auth) throw new HttpsError('unauthenticated', 'Autenticação necessária.');
    const uid = request.auth.uid;
    await requireActiveVet(uid);
    const d = request.data || {};
    const a = d.address || {};

    const clinic = {
      name:  cleanText(d.name, 100),
      phone: cleanText(d.phone, 20),
      email: cleanText(d.email, 120).toLowerCase(),
      cnpj:  cleanText(d.cnpj, 18),
      address: {
        street:       cleanText(a.street, 120),
        number:       cleanText(a.number, 10),
        complement:   cleanText(a.complement, 60),
        neighborhood: cleanText(a.neighborhood, 80),
        city:         cleanText(a.city, 80),
        state:        cleanText(a.state, 2).toUpperCase(),
        zipCode:      cleanText(a.zipCode, 9),
      },
    };
    const problems = [];
    if (clinic.name.length < 3) problems.push('nome');
    if (clinic.cnpj && !validCnpj(clinic.cnpj)) problems.push('CNPJ');
    const phoneDigits = clinic.phone.replace(/\D/g, '');
    if (clinic.phone && (phoneDigits.length < 10 || phoneDigits.length > 11)) problems.push('telefone');
    if (clinic.email && !/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(clinic.email)) problems.push('e-mail');
    if (!clinic.address.street || !clinic.address.city) problems.push('endereço (rua e cidade)');
    if (!/^[A-Z]{2}$/.test(clinic.address.state)) problems.push('estado (UF)');
    if (clinic.address.zipCode && clinic.address.zipCode.replace(/\D/g, '').length !== 8) problems.push('CEP');
    if (problems.length) throw new HttpsError('invalid-argument', `Confira: ${problems.join(', ')}.`);

    const cnpjDigits = clinic.cnpj.replace(/\D/g, '');
    const ref = cnpjDigits ? db.collection('clinics').doc(`cnpj_${cnpjDigits}`) : db.collection('clinics').doc();
    const now = FieldValue.serverTimestamp();
    try {
      await ref.create({
        ...clinic, website: '', googlePlaceId: '', source: 'manual', status: 'active',
        veterinarians: [uid], createdBy: uid, createdAt: now, updatedAt: now,
      });
    } catch (err) {
      if (err.code === 6 /* ALREADY_EXISTS */) {
        throw new HttpsError('already-exists', 'Já existe uma clínica com este CNPJ. Você pode entrar nela.', { clinicId: ref.id });
      }
      throw err;
    }
    return { clinicId: ref.id, created: true };
  }
);

/* joinClinic / leaveClinic — { clinicId } */
exports.joinClinic = onCall(
  { region: 'southamerica-east1' },
  async (request) => {
    if (!request.auth) throw new HttpsError('unauthenticated', 'Autenticação necessária.');
    await requireActiveVet(request.auth.uid);
    const clinicId = String(request.data?.clinicId || '');
    if (!/^[A-Za-z0-9_-]{1,350}$/.test(clinicId)) throw new HttpsError('invalid-argument', 'Clínica inválida.');
    const ref = db.collection('clinics').doc(clinicId);
    const snap = await ref.get();
    if (!snap.exists || snap.data().status === 'inactive') throw new HttpsError('not-found', 'Clínica não encontrada.');
    await ref.update({ veterinarians: FieldValue.arrayUnion(request.auth.uid), updatedAt: FieldValue.serverTimestamp() });
    return { clinicId };
  }
);

exports.leaveClinic = onCall(
  { region: 'southamerica-east1' },
  async (request) => {
    if (!request.auth) throw new HttpsError('unauthenticated', 'Autenticação necessária.');
    const clinicId = String(request.data?.clinicId || '');
    if (!/^[A-Za-z0-9_-]{1,350}$/.test(clinicId)) throw new HttpsError('invalid-argument', 'Clínica inválida.');
    const ref = db.collection('clinics').doc(clinicId);
    const snap = await ref.get();
    if (!snap.exists || !(snap.data().veterinarians || []).includes(request.auth.uid)) {
      throw new HttpsError('not-found', 'Você não faz parte desta clínica.');
    }
    await ref.update({ veterinarians: FieldValue.arrayRemove(request.auth.uid), updatedAt: FieldValue.serverTimestamp() });
    return { clinicId };
  }
);
