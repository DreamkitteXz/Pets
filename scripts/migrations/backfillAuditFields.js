/**
 * Migração B4 — backfill da trilha de auditoria.
 *
 * Preenche createdBy/updatedBy ausentes em registros clínicos existentes:
 *   • vaccines / deworming : createdBy = updatedBy = veterinarianId (quando faltam)
 *   • pets                 : createdBy = veterinarians[0] || ownerId (quando falta)
 *                            (as Firestore rules de update de pet dependem de createdBy)
 *
 * IDEMPOTENTE: só escreve onde o campo está AUSENTE. Não sobrescreve valores existentes.
 * DRY-RUN por padrão. Aplicar com --commit.
 *
 *   NODE_PATH="$(pwd)/functions/node_modules" node scripts/migrations/backfillAuditFields.js
 *   NODE_PATH="$(pwd)/functions/node_modules" node scripts/migrations/backfillAuditFields.js --commit
 */
const admin = require('firebase-admin');
const serviceAccount = require('../seedDatabase/cred.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

const COMMIT = process.argv.includes('--commit');

async function backfillClinical(collectionName) {
  const snap = await db.collection(collectionName).get();
  let changed = 0;
  let batch = db.batch();
  let ops = 0;
  for (const docSnap of snap.docs) {
    const d = docSnap.data();
    const update = {};
    if (d.createdBy === undefined && d.veterinarianId) update.createdBy = d.veterinarianId;
    if (d.updatedBy === undefined && d.veterinarianId) update.updatedBy = d.veterinarianId;
    if (Object.keys(update).length === 0) continue;
    changed += 1;
    console.log(`  ${COMMIT ? '[commit]' : '[dry-run]'} ${collectionName}/${docSnap.id}:`, Object.keys(update).join(', '));
    if (COMMIT) {
      batch.update(docSnap.ref, update);
      ops += 1;
      if (ops >= 400) { await batch.commit(); batch = db.batch(); ops = 0; }
    }
  }
  if (COMMIT && ops > 0) await batch.commit();
  console.log(`  → ${collectionName}: ${changed}/${snap.size} ${COMMIT ? 'corrigido(s)' : 'a corrigir'}.`);
  return changed;
}

async function backfillPets() {
  const snap = await db.collection('pets').get();
  let changed = 0;
  let batch = db.batch();
  let ops = 0;
  for (const docSnap of snap.docs) {
    const d = docSnap.data();
    if (d.createdBy !== undefined) continue;
    const fallback = (Array.isArray(d.veterinarians) && d.veterinarians[0]) || d.ownerId || null;
    if (!fallback) {
      console.log(`  [skip] pets/${docSnap.id}: sem veterinarians[]/ownerId para inferir createdBy`);
      continue;
    }
    changed += 1;
    console.log(`  ${COMMIT ? '[commit]' : '[dry-run]'} pets/${docSnap.id}: createdBy=${fallback}`);
    if (COMMIT) {
      batch.update(docSnap.ref, { createdBy: fallback });
      ops += 1;
      if (ops >= 400) { await batch.commit(); batch = db.batch(); ops = 0; }
    }
  }
  if (COMMIT && ops > 0) await batch.commit();
  console.log(`  → pets: ${changed}/${snap.size} ${COMMIT ? 'corrigido(s)' : 'a corrigir'}.`);
  return changed;
}

async function run() {
  console.log(`\n=== Backfill de auditoria (${COMMIT ? 'COMMIT' : 'DRY-RUN'}) ===\n`);
  let total = 0;
  total += await backfillClinical('vaccines');
  total += await backfillClinical('deworming');
  total += await backfillPets();
  console.log(`\n${COMMIT ? 'Corrigidos' : 'A corrigir'}: ${total} documento(s).`);
  if (!COMMIT) console.log('Dry-run — nada foi escrito. Use --commit para aplicar.\n');
}

run().then(() => process.exit(0)).catch((err) => { console.error('Falha:', err); process.exit(1); });
