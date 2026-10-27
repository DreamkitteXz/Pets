/**
 * Migração S4: veterinários cadastrados antes da verificação do CRMV não têm
 * `crmvStatus`. Este script marca todos como `pending`, para entrarem na fila
 * da página de administração.
 *
 * Efeito imediato: a escrita dispara `mirrorVetDirectory`, que tira o vet do
 * diretório público até a administração aprovar. Aprovações já feitas
 * (`crmvStatus` presente) não são tocadas.
 *
 * Uso (na pasta functions/):
 *   node scripts/migrate-crmv-status.js <service-account.json>          # só lista
 *   node scripts/migrate-crmv-status.js <service-account.json> --write  # grava
 */
const admin = require('firebase-admin');

const [, , saPath, flag] = process.argv;
if (!saPath) {
  console.log('Uso: node scripts/migrate-crmv-status.js <service-account.json> [--write]');
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(require(require('path').resolve(saPath))) });
const db = admin.firestore();

(async () => {
  const snap = await db.collection('users').where('role', '==', 'veterinarian').get();
  const todo = snap.docs.filter((d) => !d.data().crmvStatus);
  console.log(`${snap.size} veterinário(s); ${todo.length} sem crmvStatus:`);
  todo.forEach((d) => {
    const u = d.data();
    console.log(`  - ${d.id.slice(0, 8)}…  ${u.name || '(sem nome)'}  ${u.crmv || '(sem CRMV)'}  status=${u.status || '—'}`);
  });

  if (flag !== '--write') {
    console.log('\nNada gravado (use --write).');
    process.exit(0);
  }
  for (const d of todo) {
    await d.ref.update({ crmvStatus: 'pending' });
  }
  console.log(`\n✔ ${todo.length} marcado(s) como pending.`);
  process.exit(0);
})().catch((err) => {
  console.error('Erro:', err.message);
  process.exit(1);
});
