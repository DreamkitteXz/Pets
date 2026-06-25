/**
 * Migração B1 — datas string ISO → Firestore Timestamp.
 *
 * Converte campos de data gravados como string ISO (legado do signup/onboarding/
 * verifyOtp antigos) para Timestamp, normalizando o tipo em todo o banco.
 *
 * IDEMPOTENTE: só converte valores que são `string`. Pula o que já é Timestamp,
 * null/ausente, ou qualquer outro tipo. Rodar de novo não causa efeito.
 *
 * DRY-RUN (padrão): apenas relata o que mudaria, sem escrever.
 *   NODE_PATH="$(pwd)/functions/node_modules" node scripts/migrations/migrateDatesToTimestamp.js
 *
 * APLICAR de verdade: passe --commit
 *   NODE_PATH="$(pwd)/functions/node_modules" node scripts/migrations/migrateDatesToTimestamp.js --commit
 */
const admin = require('firebase-admin');
const serviceAccount = require('../seedDatabase/cred.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();
const { Timestamp } = admin.firestore;

const COMMIT = process.argv.includes('--commit');

// Campos de data por coleção (nível raiz do documento).
const FIELD_MAP = {
  users:        ['createdAt', 'updatedAt'],
  vaccines:     ['createdAt', 'updatedAt', 'administrationDate', 'expirationDate', 'nextDueDate', 'tutorAcknowledgedAt'],
  deworming:    ['createdAt', 'updatedAt', 'administrationDate', 'nextDueDate', 'tutorAcknowledgedAt'],
  pets:         ['createdAt', 'updatedAt', 'birthDate'],
  appointments: ['createdAt', 'updatedAt', 'date'],
};

// Subcoleções clínicas (via collectionGroup).
const SUBCOLLECTION_FIELD_MAP = {
  consultas: ['date', 'createdAt'],
  pesos:     ['date', 'createdAt'],
};

const isIsoString = (v) => typeof v === 'string' && !isNaN(new Date(v).getTime());

function buildUpdate(data, fields) {
  const update = {};
  for (const f of fields) {
    const v = data[f];
    if (isIsoString(v)) {
      update[f] = Timestamp.fromDate(new Date(v));
    }
  }
  return update;
}

async function migrateCollection(name, fields) {
  const snap = await db.collection(name).get();
  let changed = 0;
  let batch = db.batch();
  let ops = 0;
  for (const doc of snap.docs) {
    const update = buildUpdate(doc.data(), fields);
    if (Object.keys(update).length === 0) continue;
    changed += 1;
    console.log(`  ${COMMIT ? '[commit]' : '[dry-run]'} ${name}/${doc.id}:`, Object.keys(update).join(', '));
    if (COMMIT) {
      batch.update(doc.ref, update);
      ops += 1;
      if (ops >= 400) { await batch.commit(); batch = db.batch(); ops = 0; }
    }
  }
  if (COMMIT && ops > 0) await batch.commit();
  console.log(`  → ${name}: ${changed} doc(s) ${COMMIT ? 'convertido(s)' : 'a converter'} de ${snap.size}.`);
  return changed;
}

async function migrateSubcollection(name, fields) {
  const snap = await db.collectionGroup(name).get();
  let changed = 0;
  let batch = db.batch();
  let ops = 0;
  for (const doc of snap.docs) {
    const update = buildUpdate(doc.data(), fields);
    if (Object.keys(update).length === 0) continue;
    changed += 1;
    console.log(`  ${COMMIT ? '[commit]' : '[dry-run]'} ${doc.ref.path}:`, Object.keys(update).join(', '));
    if (COMMIT) {
      batch.update(doc.ref, update);
      ops += 1;
      if (ops >= 400) { await batch.commit(); batch = db.batch(); ops = 0; }
    }
  }
  if (COMMIT && ops > 0) await batch.commit();
  console.log(`  → ${name} (collectionGroup): ${changed} doc(s) ${COMMIT ? 'convertido(s)' : 'a converter'} de ${snap.size}.`);
  return changed;
}

async function run() {
  console.log(`\n=== Migração de datas (${COMMIT ? 'COMMIT' : 'DRY-RUN'}) ===\n`);
  let total = 0;
  for (const [name, fields] of Object.entries(FIELD_MAP)) {
    total += await migrateCollection(name, fields);
  }
  for (const [name, fields] of Object.entries(SUBCOLLECTION_FIELD_MAP)) {
    total += await migrateSubcollection(name, fields);
  }
  console.log(`\n${COMMIT ? 'Convertidos' : 'A converter'}: ${total} documento(s).`);
  if (!COMMIT) console.log('Dry-run — nada foi escrito. Use --commit para aplicar.\n');
}

run().then(() => process.exit(0)).catch((err) => { console.error('Falha na migração:', err); process.exit(1); });
