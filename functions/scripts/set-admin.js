/**
 * Concede ou remove o papel de ADMINISTRADOR (custom claim `admin: true`).
 *
 * É o ÚNICO jeito de alguém virar admin: claims só são gravados pelo Admin
 * SDK, com a service account — nenhum cliente, regra ou documento do
 * Firestore concede o papel.
 *
 * Uso (na pasta functions/):
 *   node scripts/set-admin.js <service-account.json> <email>            # mostra o que faria
 *   node scripts/set-admin.js <service-account.json> <email> --grant    # concede
 *   node scripts/set-admin.js <service-account.json> <email> --revoke   # remove
 *
 * A service account NUNCA entra no git. Ao conceder, a pessoa precisa sair e
 * entrar de novo para o token novo trazer o claim. Ao remover, as sessões são
 * encerradas na hora (revokeRefreshTokens) e as CFs de admin já recusam, pois
 * conferem o claim no registro do Auth, não só no token.
 */
const admin = require('firebase-admin');

const [, , saPath, email, flag] = process.argv;
if (!saPath || !email) {
  console.log('Uso: node scripts/set-admin.js <service-account.json> <email> [--grant|--revoke]');
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(require(require('path').resolve(saPath))) });

(async () => {
  const user = await admin.auth().getUserByEmail(email);
  const claims = user.customClaims || {};
  console.log(`Conta: ${user.email} (uid ${user.uid})`);
  console.log(`  e-mail verificado: ${user.emailVerified ? 'sim' : 'NÃO'}`);
  console.log(`  admin hoje: ${claims.admin === true ? 'sim' : 'não'}`);

  if (flag === '--grant') {
    if (!user.emailVerified) {
      console.log('Recusado: a conta precisa ter o e-mail verificado para ser admin.');
      process.exit(1);
    }
    await admin.auth().setCustomUserClaims(user.uid, { ...claims, admin: true });
    console.log('✔ Admin concedido. Saia e entre de novo no site para ativar.');
  } else if (flag === '--revoke') {
    const { admin: _removed, ...rest } = claims;
    await admin.auth().setCustomUserClaims(user.uid, rest);
    await admin.auth().revokeRefreshTokens(user.uid);
    console.log('✔ Admin removido e sessões encerradas.');
  } else {
    console.log('Nada alterado (use --grant ou --revoke).');
  }
  process.exit(0);
})().catch((err) => {
  console.error('Erro:', err.message);
  process.exit(1);
});
