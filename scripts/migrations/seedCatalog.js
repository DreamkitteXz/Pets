/**
 * Seed do catálogo controlado (B8) — vaccineCatalog / dewormerCatalog.
 *
 * Itens comuns com: name (canônico), manufacturer, species (alvo), reforcoDias.
 * IDEMPOTENTE: doc id determinístico (slug do nome) + set(merge). Rodar de novo não duplica.
 * DRY-RUN por padrão. Aplicar com --commit.
 *
 *   NODE_PATH="$(pwd)/functions/node_modules" node scripts/migrations/seedCatalog.js
 *   NODE_PATH="$(pwd)/functions/node_modules" node scripts/migrations/seedCatalog.js --commit
 */
const admin = require('firebase-admin');
const serviceAccount = require('../seedDatabase/cred.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

const COMMIT = process.argv.includes('--commit');
const slug = (s) => s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');

const VACCINES = [
  { name: 'V10 Polivalente', manufacturer: 'Zoetis', species: ['Cachorro'], reforcoDias: 365 },
  { name: 'V8 Polivalente', manufacturer: 'Ourofino', species: ['Cachorro'], reforcoDias: 365 },
  { name: 'Antirrábica', manufacturer: 'MSD Saúde Animal', species: ['Cachorro', 'Gato'], reforcoDias: 365 },
  { name: 'Tríplice Felina (FVRCP)', manufacturer: 'Zoetis', species: ['Gato'], reforcoDias: 365 },
  { name: 'Leucemia Felina (FeLV)', manufacturer: 'Boehringer Ingelheim', species: ['Gato'], reforcoDias: 365 },
  { name: 'Giárdia', manufacturer: 'MSD Saúde Animal', species: ['Cachorro'], reforcoDias: 180 },
];

const DEWORMERS = [
  { name: 'Milbemax', manufacturer: 'Elanco', species: ['Cachorro', 'Gato'], reforcoDias: 90 },
  { name: 'Drontal Plus', manufacturer: 'Bayer', species: ['Cachorro'], reforcoDias: 90 },
  { name: 'Panacur', manufacturer: 'Intervet', species: ['Cachorro', 'Gato'], reforcoDias: 180 },
];

async function seedCol(col, items) {
  let batch = db.batch();
  let ops = 0;
  for (const item of items) {
    const id = slug(item.name);
    console.log(`  ${COMMIT ? '[commit]' : '[dry-run]'} ${col}/${id}: ${item.name}`);
    if (COMMIT) {
      batch.set(db.collection(col).doc(id), item, { merge: true });
      ops += 1;
      if (ops >= 400) { await batch.commit(); batch = db.batch(); ops = 0; }
    }
  }
  if (COMMIT && ops > 0) await batch.commit();
  console.log(`  → ${col}: ${items.length} item(ns) ${COMMIT ? 'gravados' : 'a gravar'}.`);
}

async function run() {
  console.log(`\n=== Seed do catálogo (${COMMIT ? 'COMMIT' : 'DRY-RUN'}) ===\n`);
  await seedCol('vaccineCatalog', VACCINES);
  await seedCol('dewormerCatalog', DEWORMERS);
  if (!COMMIT) console.log('\nDry-run — nada foi escrito. Use --commit para aplicar.\n');
}

run().then(() => process.exit(0)).catch((err) => { console.error('Falha:', err); process.exit(1); });
