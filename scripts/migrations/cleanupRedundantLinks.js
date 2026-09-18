/**
 * Migração B5 — fonte única de verdade por vínculo.
 *
 * Limpa campos redundantes/aposentados, preservando a fonte de verdade:
 *   • pets.tutorId   → backfill ownerId ← tutorId (se ownerId faltar) e REMOVE tutorId.
 *                      Verdade do vínculo tutor↔pet: pets.ownerId.
 *   • pets.vaccines  → REMOVE o array (stale). Verdade vacina↔pet: vaccines.petId.
 *   • users.clinicId → REMOVE. Verdade vet↔clínica: clinics.veterinarians[].
 *
 * IDEMPOTENTE: só age onde o campo existe. DRY-RUN por padrão; aplicar com --commit.
 *
 *   NODE_PATH="$(pwd)/functions/node_modules" node scripts/migrations/cleanupRedundantLinks.js
 *   NODE_PATH="$(pwd)/functions/node_modules" node scripts/migrations/cleanupRedundantLinks.js --commit
 */
const admin = require('firebase-admin');
const serviceAccount = require('../seedDatabase/cred.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();
const { FieldValue } = admin.firestore;

const COMMIT = process.argv.includes('--commit');

async function cleanupPets() {
  const snap = await db.collection('pets').get();
  let changed = 0;
  let batch = db.batch();
  let ops = 0;
  for (const docSnap of snap.docs) {
    const d = docSnap.data();
    const update = {};
    const notes = [];

    // tutorId → ownerId (backfill) + remoção
    if (d.tutorId !== undefined) {
      if ((d.ownerId === undefined || d.ownerId === '') && d.tutorId) {
        update.ownerId = d.tutorId;
        notes.push(`ownerId←tutorId(${d.tutorId})`);
      }
      update.tutorId = FieldValue.delete();
      notes.push('del tutorId');
    }
    // vaccines[] stale → remoção
    if (d.vaccines !== undefined) {
      update.vaccines = FieldValue.delete();
      notes.push('del vaccines[]');
    }

    if (Object.keys(update).length === 0) continue;
    changed += 1;
    console.log(`  ${COMMIT ? '[commit]' : '[dry-run]'} pets/${docSnap.id}: ${notes.join(', ')}`);
    if (COMMIT) {
      batch.update(docSnap.ref, update);
      ops += 1;
      if (ops >= 400) { await batch.commit(); batch = db.batch(); ops = 0; }
    }
  }
  if (COMMIT && ops > 0) await batch.commit();
  console.log(`  → pets: ${changed}/${snap.size} ${COMMIT ? 'limpos' : 'a limpar'}.`);
  return changed;
}

async function cleanupUsers() {
  const snap = await db.collection('users').get();
  let changed = 0;
  let batch = db.batch();
  let ops = 0;
  for (const docSnap of snap.docs) {
    if (docSnap.data().clinicId === undefined) continue;
    changed += 1;
    console.log(`  ${COMMIT ? '[commit]' : '[dry-run]'} users/${docSnap.id}: del clinicId`);
    if (COMMIT) {
      batch.update(docSnap.ref, { clinicId: FieldValue.delete() });
      ops += 1;
      if (ops >= 400) { await batch.commit(); batch = db.batch(); ops = 0; }
    }
  }
  if (COMMIT && ops > 0) await batch.commit();
  console.log(`  → users: ${changed}/${snap.size} ${COMMIT ? 'limpos' : 'a limpar'}.`);
  return changed;
}

async function run() {
  console.log(`\n=== Limpeza de vínculos redundantes (${COMMIT ? 'COMMIT' : 'DRY-RUN'}) ===\n`);
  let total = 0;
  total += await cleanupPets();
  total += await cleanupUsers();
  console.log(`\n${COMMIT ? 'Limpos' : 'A limpar'}: ${total} documento(s).`);
  if (!COMMIT) console.log('Dry-run — nada foi escrito. Use --commit para aplicar.\n');
}

run().then(() => process.exit(0)).catch((err) => { console.error('Falha:', err); process.exit(1); });
