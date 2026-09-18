/**
 * Migração — eixo único de status de vacinas (Tarefa 1 / Fase 2).
 *
 * Converte registros existentes da coleção `vaccines` do modelo antigo
 * (7 status + dois eixos vet/tutor) para o modelo novo:
 *   status: 'pending' | 'approved' | 'rejected'   (decisão do veterinário)
 *   tutorAcknowledged: boolean  + tutorAcknowledgedAt
 *
 * Regras:
 *   - Se houver vetValidation.status ('approved'/'rejected'), ele MANDA no status.
 *   - Senão, mapeia o status antigo: vetApproved→approved, vetRejected→rejected,
 *     tutorApproved→approved, tutorRejected→rejected, pending→pending.
 *   - tutorAcknowledged = true quando o tutor já havia agido (tutorApproved/
 *     tutorRejected ou tutorValidation.status definido); senão false.
 *
 * Uso (a partir da raiz do repo):
 *   NODE_PATH="$(pwd)/functions/node_modules" node scripts/migrations/migrateVaccineStatus.js
 *
 * NÃO apaga o bloco legado validationDetails.tutorValidation (não-destrutivo;
 * imutabilidade/limpeza são de outra fase).
 */
const admin = require('firebase-admin');
const serviceAccount = require('../seedDatabase/cred.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

const STATUS_MAP = {
  pending: 'pending',
  approved: 'approved',
  rejected: 'rejected',
  vetApproved: 'approved',
  vetRejected: 'rejected',
  tutorApproved: 'approved',
  tutorRejected: 'rejected',
};

async function run() {
  const snap = await db.collection('vaccines').get();
  console.log(`Encontrados ${snap.size} registros em 'vaccines'.`);

  let updated = 0;
  let unchanged = 0;
  let batch = db.batch();
  let ops = 0;

  for (const docSnap of snap.docs) {
    const d = docSnap.data();
    const old = d.status;
    const vetDecision = d.validationDetails && d.validationDetails.vetValidation
      ? d.validationDetails.vetValidation.status
      : undefined;

    // Eixo único: decisão do vet quando existir; senão mapeia o status antigo.
    let newStatus;
    if (vetDecision === 'approved' || vetDecision === 'rejected') {
      newStatus = vetDecision;
    } else {
      newStatus = STATUS_MAP[old] || 'pending';
    }

    // Ciência do tutor.
    const tutorVal = d.validationDetails && d.validationDetails.tutorValidation;
    const alreadyAck = d.tutorAcknowledged === true;
    const tutorActed =
      alreadyAck ||
      old === 'tutorApproved' ||
      old === 'tutorRejected' ||
      (tutorVal && (tutorVal.status === 'approved' || tutorVal.status === 'rejected'));

    const update = {};
    if (newStatus !== old) update.status = newStatus;

    if (d.tutorAcknowledged === undefined) {
      update.tutorAcknowledged = !!tutorActed;
      update.tutorAcknowledgedAt = tutorActed
        ? (d.tutorAcknowledgedAt || (tutorVal && tutorVal.validatedAt) || admin.firestore.FieldValue.serverTimestamp())
        : null;
    } else if (tutorActed && !alreadyAck) {
      update.tutorAcknowledged = true;
      update.tutorAcknowledgedAt = d.tutorAcknowledgedAt || (tutorVal && tutorVal.validatedAt) || admin.firestore.FieldValue.serverTimestamp();
    }

    if (Object.keys(update).length === 0) {
      unchanged += 1;
      continue;
    }

    update.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    batch.update(docSnap.ref, update);
    ops += 1;
    updated += 1;

    if (ops >= 400) {
      await batch.commit();
      batch = db.batch();
      ops = 0;
    }
  }

  if (ops > 0) await batch.commit();

  console.log(`Migração concluída. Atualizados: ${updated} | Inalterados: ${unchanged} | Total: ${snap.size}`);
}

run().then(() => process.exit(0)).catch((err) => { console.error('Falha na migração:', err); process.exit(1); });
