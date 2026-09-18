/**
 * Testes das regras de segurança — vaccines (B3 + B2).
 * Rodam contra o emulador do Firestore. Ver README.md nesta pasta.
 */
const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const { doc, setDoc, updateDoc, deleteDoc, getDoc } = require('firebase/firestore');

const VET = 'vet_uid';
const TUTOR = 'tutor_uid';
const OTHER = 'other_uid';

let testEnv;

const baseVaccine = (overrides = {}) => ({
  name: 'V10',
  veterinarianId: VET,
  ownerId: TUTOR,
  petId: 'pet_1',
  status: 'pending',
  validationDetails: { vetValidation: { status: 'pending' } },
  tutorAcknowledged: false,
  ...overrides,
});

// Semeia um doc ignorando as regras (estado inicial do teste).
async function seed(id, data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'vaccines', id), data);
  });
}

const vetDb   = () => testEnv.authenticatedContext(VET).firestore();
const tutorDb = () => testEnv.authenticatedContext(TUTOR).firestore();
const otherDb = () => testEnv.authenticatedContext(OTHER).firestore();

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'pet-app-rules-test',
    firestore: { rules: fs.readFileSync(path.resolve(__dirname, '../firestore.rules'), 'utf8') },
  });
});
afterAll(async () => { await testEnv.cleanup(); });
beforeEach(async () => { await testEnv.clearFirestore(); });

describe('vaccines — leitura', () => {
  it('vet responsável lê', async () => {
    await seed('v1', baseVaccine());
    await assertSucceeds(getDoc(doc(vetDb(), 'vaccines', 'v1')));
  });
  it('tutor dono lê', async () => {
    await seed('v1', baseVaccine());
    await assertSucceeds(getDoc(doc(tutorDb(), 'vaccines', 'v1')));
  });
  it('terceiro NÃO lê', async () => {
    await seed('v1', baseVaccine());
    await assertFails(getDoc(doc(otherDb(), 'vaccines', 'v1')));
  });
});

describe('vaccines — status/validação só via Cloud Function', () => {
  it('tutor NÃO pode aprovar (status)', async () => {
    await seed('v1', baseVaccine());
    await assertFails(updateDoc(doc(tutorDb(), 'vaccines', 'v1'), { status: 'approved' }));
  });
  it('vet NÃO pode mudar status pelo cliente', async () => {
    await seed('v1', baseVaccine());
    await assertFails(updateDoc(doc(vetDb(), 'vaccines', 'v1'), { status: 'approved' }));
  });
  it('cliente NÃO pode alterar validationDetails', async () => {
    await seed('v1', baseVaccine());
    await assertFails(updateDoc(doc(vetDb(), 'vaccines', 'v1'), {
      'validationDetails': { vetValidation: { status: 'approved' } },
    }));
  });
});

describe('vaccines — ciência do tutor', () => {
  it('tutor pode marcar tutorAcknowledged', async () => {
    await seed('v1', baseVaccine());
    await assertSucceeds(updateDoc(doc(tutorDb(), 'vaccines', 'v1'), {
      tutorAcknowledged: true, tutorAcknowledgedAt: new Date(), updatedAt: new Date(),
    }));
  });
  it('tutor NÃO pode editar campo clínico junto', async () => {
    await seed('v1', baseVaccine());
    await assertFails(updateDoc(doc(tutorDb(), 'vaccines', 'v1'), {
      tutorAcknowledged: true, name: 'Outra',
    }));
  });
});

describe('vaccines — edição clínica do vet (imutabilidade)', () => {
  it('vet edita enquanto pending', async () => {
    await seed('v1', baseVaccine());
    await assertSucceeds(updateDoc(doc(vetDb(), 'vaccines', 'v1'), { name: 'V10 Plus', updatedAt: new Date() }));
  });
  it('vet NÃO edita após approved (congelado)', async () => {
    await seed('v1', baseVaccine({ status: 'approved' }));
    await assertFails(updateDoc(doc(vetDb(), 'vaccines', 'v1'), { name: 'V10 Plus' }));
  });
  it('tutor NÃO edita campo clínico', async () => {
    await seed('v1', baseVaccine());
    await assertFails(updateDoc(doc(tutorDb(), 'vaccines', 'v1'), { name: 'V10 Plus' }));
  });
});

describe('vaccines — exclusão lógica', () => {
  it('vet pode soft-delete (active:false)', async () => {
    await seed('v1', baseVaccine({ status: 'approved' }));
    await assertSucceeds(updateDoc(doc(vetDb(), 'vaccines', 'v1'), {
      active: false, deletedAt: new Date(), deletedBy: VET, updatedAt: new Date(),
    }));
  });
  it('tutor NÃO pode soft-delete', async () => {
    await seed('v1', baseVaccine());
    await assertFails(updateDoc(doc(tutorDb(), 'vaccines', 'v1'), {
      active: false, deletedAt: new Date(), deletedBy: TUTOR, updatedAt: new Date(),
    }));
  });
  it('soft-delete com deletedBy ≠ uid falha', async () => {
    await seed('v1', baseVaccine());
    await assertFails(updateDoc(doc(vetDb(), 'vaccines', 'v1'), {
      active: false, deletedAt: new Date(), deletedBy: OTHER, updatedAt: new Date(),
    }));
  });
  it('hard delete é negado para todos', async () => {
    await seed('v1', baseVaccine());
    await assertFails(deleteDoc(doc(vetDb(), 'vaccines', 'v1')));
  });
});
