# Testes das regras do Firestore (B3 + B2)

Validam as regras de `firestore.rules` para `vaccines` (mesma lógica vale para `deworming`)
contra o **emulador do Firestore** — sem tocar em produção.

## Pré-requisitos (instalar uma vez)

```bash
npm i -D @firebase/rules-unit-testing firebase jest
# Emulador (se ainda não tiver): firebase init emulators  → marque Firestore
```

## Rodar

O jeito mais simples (o Firebase sobe o emulador, roda os testes e derruba):

```bash
firebase emulators:exec --only firestore "npx jest firestore-tests"
```

Ou, com o emulador já rodando (`firebase emulators:start --only firestore`):

```bash
export FIRESTORE_EMULATOR_HOST=localhost:8080
npx jest firestore-tests
```

## O que é coberto (`vaccines.rules.test.js`)

| Caso | Esperado |
|------|----------|
| vet responsável / tutor dono leem; terceiro não | read ✓ / ✗ |
| tutor tentando `status:'approved'` | **falha** |
| vet mudando `status` pelo cliente | **falha** |
| cliente alterando `validationDetails` | **falha** |
| tutor marcando `tutorAcknowledged` | passa |
| tutor editando campo clínico | **falha** |
| vet editando enquanto `pending` | passa |
| vet editando após `approved` (congelado) | **falha** |
| vet soft-delete (`active:false`) | passa |
| tutor soft-delete | **falha** |
| soft-delete com `deletedBy` ≠ uid | **falha** |
| hard `delete` | **falha** (todos) |

> Nada aqui faz deploy. As regras só vão para produção com
> `firebase deploy --only firestore:rules` — mediante seu OK explícito.
