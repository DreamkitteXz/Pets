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
  clinicId: 'clinic_1',
  clinicName: 'VetLife',
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
  await seed('clinics', 'clinic_1', { name: 'VetLife', status: 'active', veterinarians: [VET] });
  await seed('clinics', 'clinic_off', { name: 'Fechada', status: 'inactive', veterinarians: [VET] });
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

/* ── Clínica da aplicação ──────────────────────────────────────────────── */

describe('clínica na submissão do tutor', () => {
  const put = (col, o) => setDoc(doc(asUser(TUTOR), col, 'r1'), appVaccinePayload(o));
  it('vacina SEM clínica é recusada', async () => {
    await assertFails(put('vaccines', { clinicId: null, clinicName: '' }));
    const { clinicId, clinicName, ...semCampo } = appVaccinePayload();
    await assertFails(setDoc(doc(asUser(TUTOR), 'vaccines', 'r2'), semCampo));
  });
  it('vermífugo sem clínica é aceito (aplicado em casa)', async () => {
    await assertSucceeds(put('deworming', { clinicId: null, clinicName: '' }));
  });
  it('clínica inexistente é recusada', async () => {
    await assertFails(put('vaccines', { clinicId: 'nao_existe', clinicName: 'X' }));
  });
  it('clínica inativa é recusada', async () => {
    await assertFails(put('vaccines', { clinicId: 'clinic_off', clinicName: 'Fechada' }));
  });
  it('nome da clínica diferente do cadastro é recusado', async () => {
    await assertFails(put('vaccines', { clinicName: 'Clínica Inventada' }));
    await assertFails(put('deworming', { clinicName: 'Clínica Inventada' }));
  });
  it('foto marcada com outra clínica é recusada', async () => {
    await assertFails(put('vaccines', { labelImageMetadata: { name: 'f.jpg', clinicId: 'clinic_off' } }));
  });
  it('foto marcada com a clínica da aplicação é aceita', async () => {
    await assertSucceeds(put('vaccines', { labelImageMetadata: { name: 'f.jpg', clinicId: 'clinic_1', clinicName: 'VetLife' } }));
  });
});

/* ── W7: peso informado pelo tutor ─────────────────────────────────────── */

describe('pets/pesos — tutor registra o próprio auto-relato', () => {
  const peso = (o = {}) => ({ weight: 12.4, source: 'tutor', registeredBy: TUTOR, notes: '', ...o });
  it('dono registra peso marcado como do tutor', async () => {
    await assertSucceeds(setDoc(doc(asUser(TUTOR), 'pets', 'pet_1', 'pesos', 'p1'), peso()));
  });
  it('dono NÃO se passa por pesagem do vet', async () => {
    await assertFails(setDoc(doc(asUser(TUTOR), 'pets', 'pet_1', 'pesos', 'p1'), peso({ source: 'vet' })));
  });
  it('dono NÃO registra em nome de outro', async () => {
    await assertFails(setDoc(doc(asUser(TUTOR), 'pets', 'pet_1', 'pesos', 'p1'), peso({ registeredBy: VET })));
  });
  it('peso zero, negativo, texto ou absurdo é recusado', async () => {
    for (const weight of [0, -3, '12', 5000]) {
      await assertFails(setDoc(doc(asUser(TUTOR), 'pets', 'pet_1', 'pesos', 'p1'), peso({ weight })));
    }
  });
  it('dono NÃO edita nem apaga pesagem', async () => {
    await seed('pets/pet_1/pesos', 'p2', peso());
    await assertFails(updateDoc(doc(asUser(TUTOR), 'pets', 'pet_1', 'pesos', 'p2'), { weight: 1 }));
    await assertFails(deleteDoc(doc(asUser(TUTOR), 'pets', 'pet_1', 'pesos', 'p2')));
  });
  it('quem não é dono NÃO registra', async () => {
    await assertFails(setDoc(doc(asUser(OTHER), 'pets', 'pet_1', 'pesos', 'p1'), peso({ registeredBy: OTHER })));
  });
  it('vet vinculado registra pesagem clínica', async () => {
    await assertSucceeds(setDoc(doc(asUser(VET), 'pets', 'pet_1', 'pesos', 'p1'), peso({ source: 'vet', registeredBy: VET })));
  });
});

/* ── Clínicas: cadastro só pelas CFs ───────────────────────────────────── */

describe('clinics — escrita restrita', () => {
  beforeEach(async () => {
    await seed('clinics', 'c1', { name: 'VetLife', veterinarians: [VET, OTHER], source: 'manual', createdBy: OTHER, status: 'active' });
  });
  it('qualquer logado lê', async () => {
    const { getDoc } = require('firebase/firestore');
    await assertSucceeds(getDoc(doc(asUser(TUTOR), 'clinics', 'c1')));
  });
  it('NÃO cria clínica pelo cliente', async () => {
    await assertFails(setDoc(doc(asUser(VET), 'clinics', 'c2'), { name: 'X', veterinarians: [VET] }));
  });
  it('membro corrige telefone', async () => {
    await assertSucceeds(updateDoc(doc(asUser(VET), 'clinics', 'c1'), { phone: '(31) 3333-4444' }));
  });
  it('membro NÃO remove colega', async () => {
    await assertFails(updateDoc(doc(asUser(VET), 'clinics', 'c1'), { veterinarians: [VET] }));
  });
  it('não-membro NÃO edita', async () => {
    await assertFails(updateDoc(doc(asUser(TUTOR), 'clinics', 'c1'), { phone: '1' }));
  });
  it('NÃO se coloca na clínica pelo cliente', async () => {
    await assertFails(updateDoc(doc(asUser(TUTOR), 'clinics', 'c1'), { veterinarians: [VET, OTHER, TUTOR] }));
  });
  it('membro NÃO mexe na coordenada do mapa', async () => {
    await assertFails(updateDoc(doc(asUser(VET), 'clinics', 'c1'), { location: { lat: 0, lng: 0 } }));
  });
  it('NÃO apaga clínica', async () => {
    await assertFails(deleteDoc(doc(asUser(VET), 'clinics', 'c1')));
  });
});

/* ── S4: verificação do CRMV ───────────────────────────────────────────── */

describe('users — verificação do CRMV (só a administração aprova)', () => {
  const vetAprovado = { role: 'veterinarian', status: 'active', crmv: 'CRMV-SP 12345', crmvStatus: 'approved', crmvReview: { status: 'approved' } };

  it('onboarding de vet entra como pending', async () => {
    await seed('users', VET, { email: 'v@x.com', status: 'pending' });
    await assertSucceeds(setDoc(doc(asUser(VET), 'users', VET), {
      role: 'veterinarian', status: 'active', crmv: 'CRMV-SP 12345', crmvStatus: 'pending', profileCompleted: true,
    }, { merge: true }));
  });
  it('NÃO se autoaprova no onboarding', async () => {
    await seed('users', VET, { email: 'v@x.com', status: 'pending' });
    await assertFails(setDoc(doc(asUser(VET), 'users', VET), {
      role: 'veterinarian', status: 'active', crmv: 'CRMV-SP 12345', crmvStatus: 'approved',
    }, { merge: true }));
  });
  it('NÃO cria o perfil já aprovado', async () => {
    await assertFails(setDoc(doc(asUser(VET), 'users', VET), { role: 'veterinarian', crmvStatus: 'approved' }));
  });
  it('NÃO cria o perfil com crmvReview forjado', async () => {
    await assertFails(setDoc(doc(asUser(VET), 'users', VET), { role: 'veterinarian', crmvReview: { status: 'approved' } }));
  });
  it('NÃO troca pending → approved', async () => {
    await seed('users', VET, { ...vetAprovado, crmvStatus: 'pending', crmvReview: null });
    await assertFails(updateDoc(doc(asUser(VET), 'users', VET), { crmvStatus: 'approved' }));
  });
  it('NÃO sai de rejected sem trocar o CRMV', async () => {
    await seed('users', VET, { ...vetAprovado, crmvStatus: 'rejected' });
    await assertFails(updateDoc(doc(asUser(VET), 'users', VET), { crmvStatus: 'pending' }));
  });
  it('recusado reenvia trocando o CRMV (volta para pending)', async () => {
    await seed('users', VET, { ...vetAprovado, crmvStatus: 'rejected' });
    await assertSucceeds(updateDoc(doc(asUser(VET), 'users', VET), { crmv: 'CRMV-MG 54321', crmvStatus: 'pending' }));
  });
  it('aprovado NÃO troca o CRMV mantendo a aprovação', async () => {
    await seed('users', VET, vetAprovado);
    await assertFails(updateDoc(doc(asUser(VET), 'users', VET), { crmv: 'CRMV-MG 99999' }));
  });
  it('aprovado troca o CRMV e volta para análise', async () => {
    await seed('users', VET, vetAprovado);
    await assertSucceeds(updateDoc(doc(asUser(VET), 'users', VET), { crmv: 'CRMV-MG 99999', crmvStatus: 'pending' }));
  });
  it('NÃO mexe em crmvReview', async () => {
    await seed('users', VET, vetAprovado);
    await assertFails(updateDoc(doc(asUser(VET), 'users', VET), { 'crmvReview.status': 'forjado', crmv: 'CRMV-MG 1', crmvStatus: 'pending' }));
  });
  it('aprovado edita nome/telefone sem perder nada', async () => {
    await seed('users', VET, vetAprovado);
    await assertSucceeds(updateDoc(doc(asUser(VET), 'users', VET), { name: 'Dra. Ana', phone: '11999999999' }));
  });
  it('app sem o campo: vet antigo troca CRMV (continua não verificado)', async () => {
    await seed('users', VET, { role: 'veterinarian', status: 'active', crmv: 'CRMV-SP 12345' });
    await assertSucceeds(updateDoc(doc(asUser(VET), 'users', VET), { crmv: 'CRMV-SP 12346' }));
  });
  it('ninguém lê nem escreve o log de auditoria', async () => {
    await seed('admin_audit_log', 'a1', { action: 'crmv_review' });
    const { getDoc } = require('firebase/firestore');
    await assertFails(getDoc(doc(asUser(VET, { admin: true }), 'admin_audit_log', 'a1')));
    await assertFails(setDoc(doc(asUser(VET, { admin: true }), 'admin_audit_log', 'a2'), { x: 1 }));
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
