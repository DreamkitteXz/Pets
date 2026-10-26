/**
 * Testes das regras — furos fechados na auditoria de out/2026.
 *
 *  S1  criação de vacina/vermífugo pelo cliente só como submissão `pending` do tutor
 *  S2  perfil: role definido uma vez, status não sai de suspended, emailVerified só do token
 *  S5  pets: createdBy obrigatório, ninguém troca dono/autoria
 *
 * Rodam contra o emulador do Firestore. Ver README.md nesta pasta.
 */
const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const { doc, setDoc, updateDoc, deleteDoc, serverTimestamp } = require('firebase/firestore');

const VET = 'vet_uid';
const TUTOR = 'tutor_uid';
const OTHER = 'other_uid';

let testEnv;

const asUser = (uid, token = {}) => testEnv.authenticatedContext(uid, token).firestore();

async function seed(collection, id, data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), collection, id), data);
  });
}

// Exatamente o documento que o app (build 7, add_vaccine_screen.dart) grava.
const appVaccinePayload = (overrides = {}) => ({
  name: 'V10',
  petId: 'pet_1',
  ownerId: TUTOR,
  veterinarianId: VET,
  status: 'pending',
  validationDetails: {
    vetValidation: { status: 'pending', validatedAt: null, validatedBy: null, notes: '', rejectionReason: '' },
  },
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  ...overrides,
});

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'pet-app-security-test',
    firestore: { rules: fs.readFileSync(path.resolve(__dirname, '../firestore.rules'), 'utf8') },
  });
});
afterAll(async () => { await testEnv.cleanup(); });
beforeEach(async () => {
  await testEnv.clearFirestore();
  await seed('pets', 'pet_1', { name: 'Mel', ownerId: TUTOR, createdBy: TUTOR, veterinarians: [VET] });
  await seed('pets', 'pet_other', { name: 'Rex', ownerId: OTHER, createdBy: OTHER, veterinarians: [] });
});

/* ── S1: criação de vacina / vermífugo ─────────────────────────────────── */

describe.each(['vaccines', 'deworming'])('%s — criação pelo cliente', (col) => {
  it('tutor envia submissão pending do próprio pet (formato do app)', async () => {
    await assertSucceeds(setDoc(doc(asUser(TUTOR), col, 'r1'), appVaccinePayload()));
  });
  it('tutor envia submissão pending sem validationDetails', async () => {
    const { validationDetails, ...rest } = appVaccinePayload();
    await assertSucceeds(setDoc(doc(asUser(TUTOR), col, 'r1'), rest));
  });
  it('tutor NÃO cria registro já aprovado', async () => {
    await assertFails(setDoc(doc(asUser(TUTOR), col, 'r1'), appVaccinePayload({ status: 'approved' })));
  });
  it('tutor NÃO forja validationDetails aprovado', async () => {
    await assertFails(setDoc(doc(asUser(TUTOR), col, 'r1'), appVaccinePayload({
      validationDetails: { vetValidation: { status: 'approved', validatedBy: VET } },
    })));
  });
  it('tutor NÃO forja validatedBy num pending', async () => {
    await assertFails(setDoc(doc(asUser(TUTOR), col, 'r1'), appVaccinePayload({
      validationDetails: { vetValidation: { status: 'pending', validatedBy: VET } },
    })));
  });
  it('tutor NÃO cria registro no pet de outra pessoa', async () => {
    await assertFails(setDoc(doc(asUser(TUTOR), col, 'r1'), appVaccinePayload({ petId: 'pet_other' })));
  });
  it('NÃO cria com ownerId de outra pessoa', async () => {
    await assertFails(setDoc(doc(asUser(OTHER), col, 'r1'), appVaccinePayload({ petId: 'pet_other' })));
  });
  it('NÃO cria já com ciência marcada', async () => {
    await assertFails(setDoc(doc(asUser(TUTOR), col, 'r1'), appVaccinePayload({ tutorAcknowledged: true })));
  });
  it('vet NÃO cria aprovado pelo cliente (passa pela CF)', async () => {
    await assertFails(setDoc(doc(asUser(VET), col, 'r1'), appVaccinePayload({
      ownerId: TUTOR, status: 'approved',
      validationDetails: { vetValidation: { status: 'approved', validatedBy: VET } },
    })));
  });
});

describe.each(['vaccines', 'deworming'])('%s — edição do vet não mexe na identidade', (col) => {
  beforeEach(async () => {
    await seed(col, 'r1', appVaccinePayload({ createdAt: new Date(), updatedAt: new Date() }));
  });
  it('vet edita campo clínico enquanto pending', async () => {
    await assertSucceeds(updateDoc(doc(asUser(VET), col, 'r1'), { name: 'V10 Plus' }));
  });
  it('vet NÃO move o registro para o pet de outra pessoa', async () => {
    await assertFails(updateDoc(doc(asUser(VET), col, 'r1'), { petId: 'pet_other', ownerId: OTHER }));
  });
  it('vet NÃO troca o responsável do registro', async () => {
    await assertFails(updateDoc(doc(asUser(VET), col, 'r1'), { veterinarianId: OTHER }));
  });
});

/* ── S2: perfil do usuário ─────────────────────────────────────────────── */

describe('users — campos que decidem acesso', () => {
  it('cadastro com role tutor e status active (formato do app)', async () => {
    await assertSucceeds(setDoc(doc(asUser(TUTOR), 'users', TUTOR), {
      name: 'Ana', role: 'tutor', status: 'active', profileCompleted: false,
    }));
  });
  it('cadastro do site (pending, emailVerified false)', async () => {
    await assertSucceeds(setDoc(doc(asUser(TUTOR), 'users', TUTOR), {
      email: 't@x.com', emailVerified: false, status: 'pending',
    }));
  });
  it('cadastro com Google grava emailVerified true quando o token confirma', async () => {
    await assertSucceeds(setDoc(doc(asUser(TUTOR, { email_verified: true }), 'users', TUTOR), {
      email: 't@x.com', emailVerified: true, status: 'pending',
    }));
  });
  it('NÃO grava emailVerified true sem o token confirmar', async () => {
    await assertFails(setDoc(doc(asUser(TUTOR, { email_verified: false }), 'users', TUTOR), {
      email: 't@x.com', emailVerified: true, status: 'pending',
    }));
  });
  it('NÃO cria já suspenso/outro status inventado', async () => {
    await assertFails(setDoc(doc(asUser(TUTOR), 'users', TUTOR), { status: 'admin' }));
  });
  it('onboarding: define role e passa pending → active', async () => {
    await seed('users', TUTOR, { email: 't@x.com', status: 'pending' });
    await assertSucceeds(setDoc(doc(asUser(TUTOR), 'users', TUTOR), {
      role: 'veterinarian', status: 'active', crmv: 'CRMV-SP 12345', profileCompleted: true,
    }, { merge: true }));
  });
  it('NÃO troca de role depois de definido (tutor → vet)', async () => {
    await seed('users', TUTOR, { role: 'tutor', status: 'active' });
    await assertFails(updateDoc(doc(asUser(TUTOR), 'users', TUTOR), { role: 'veterinarian' }));
  });
  it('NÃO sai de suspended sozinho', async () => {
    await seed('users', TUTOR, { role: 'tutor', status: 'suspended' });
    await assertFails(updateDoc(doc(asUser(TUTOR), 'users', TUTOR), { status: 'active' }));
  });
  it('edita nome, telefone e preferências normalmente', async () => {
    await seed('users', TUTOR, { role: 'tutor', status: 'active', name: 'Ana' });
    await assertSucceeds(updateDoc(doc(asUser(TUTOR), 'users', TUTOR), { name: 'Ana Souza', phone: '11999999999', darkMode: true }));
  });
  it('NÃO apaga o próprio perfil (apagar e recriar trocaria o role)', async () => {
    await seed('users', TUTOR, { role: 'tutor', status: 'active' });
    await assertFails(deleteDoc(doc(asUser(TUTOR), 'users', TUTOR)));
  });
  it('NÃO escreve perfil de outra pessoa', async () => {
    await assertFails(setDoc(doc(asUser(OTHER), 'users', TUTOR), { name: 'x' }));
  });
});

/* ── S5: pets ──────────────────────────────────────────────────────────── */

describe('pets — criação e dono', () => {
  it('tutor cria o próprio pet assinando createdBy (formato do app)', async () => {
    await assertSucceeds(setDoc(doc(asUser(TUTOR), 'pets', 'novo'), {
      name: 'Bob', ownerId: TUTOR, createdBy: TUTOR, veterinarians: [], status: 'active',
    }));
  });
  it('NÃO cria pet sem createdBy', async () => {
    await assertFails(setDoc(doc(asUser(TUTOR), 'pets', 'novo'), { name: 'Bob', ownerId: TUTOR }));
  });
  it('NÃO cria pet em nome de outro dono', async () => {
    await assertFails(setDoc(doc(asUser(TUTOR), 'pets', 'novo'), {
      name: 'Bob', ownerId: OTHER, createdBy: TUTOR, veterinarians: [],
    }));
  });
  it('vet cria paciente se estiver vinculado nele', async () => {
    await assertSucceeds(setDoc(doc(asUser(VET), 'pets', 'novo'), {
      name: 'Bob', ownerId: TUTOR, createdBy: VET, veterinarians: [VET],
    }));
  });
  it('dono vincula um veterinário (arrayUnion do app)', async () => {
    await assertSucceeds(updateDoc(doc(asUser(TUTOR), 'pets', 'pet_1'), { veterinarians: [VET, OTHER] }));
  });
  it('dono edita dados do pet', async () => {
    await assertSucceeds(updateDoc(doc(asUser(TUTOR), 'pets', 'pet_1'), { name: 'Mel II' }));
  });
  it('NÃO troca o dono do pet', async () => {
    await assertFails(updateDoc(doc(asUser(TUTOR), 'pets', 'pet_1'), { ownerId: OTHER }));
  });
  it('NÃO troca a autoria do pet', async () => {
    await assertFails(updateDoc(doc(asUser(TUTOR), 'pets', 'pet_1'), { createdBy: OTHER }));
  });
});
