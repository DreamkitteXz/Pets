# Estado do Sistema & Guia de Desenvolvimento Mobile (Pets App)

> **Propósito.** Referência única ("fonte da verdade") para retomar o desenvolvimento do **app Flutter (tutor)** alinhado ao estado real do sistema. Tudo aqui foi conferido **lendo o código** dos dois lados (React/branch `Website` + Flutter/branch `origin/App`), das Cloud Functions, das Security Rules e do Storage. Onde não foi possível confirmar, está marcado `⚠️ A CONFIRMAR`.
>
> **Gerado em:** 2026-06-25 · **Branch web:** `Website` · **Branch mobile:** `origin/App` (mesmo repositório).
>
> **Decisões aplicadas nesta versão (definidas pelo dono do produto):**
> - **Enum de status de vacina → o CÓDIGO manda (3 valores):** `pending | approved | rejected` + `tutorAcknowledged`. O enum de 6/7 valores citado no "plano" está **desatualizado** vs. produção (ver §3).
> - **Plano de auditoria:** o arquivo `PLANO_IMPLEMENTACAO_AUDITORIA.md` **não existe** no repositório. O roadmap da §11 foi **autorado aqui** a partir do código real + `AUDITORIA_SISTEMA.md`, com numeração própria de fases (`F0–F4`).

---

## 1. Visão geral do sistema

| Componente | Quem usa | Stack / versões | Onde |
|---|---|---|---|
| **Website** | Veterinários | React 18 (CRA `react-scripts` 5), React Router v6, Tailwind 3.4 (`darkMode:'class'`), Firebase JS SDK v10 | branch `Website`, raiz do repo (`src/`) — **MVP recém-finalizado e em produção** |
| **App Mobile** | Tutores | Flutter (Dart SDK `>=2.19.6 <3.0.0`, ver `pubspec.yaml`), GetX, `firebase_core ^2.15`, `cloud_firestore ^4.8`, `firebase_auth ^4.7`, `firebase_storage ^11.2` | branch `origin/App`, mesmo repo (`lib/`) — **a retomar agora** |
| **Firebase** | Backend dos dois | Auth, Firestore, Storage, Cloud Functions (Node 22, **2ª geração**, `onCall`) | Projeto **`pet-app-fccae`**, região **`southamerica-east1`** |

**Estrutura do repo React (`Website`)** — `src/components/pages/*` (telas por área: `Pets`, `Vacinas`, `Vencimentos`, `Clinicas`, `Chat`, `Dashboard`, `Tutor`, `Support`, `Auth`), `src/components/shared/*` (Header, SideBar, Layout), `src/components/auth/*` (`ProtectedRoute`, `ProfileGate`, `RoleRoute`, `RoleRedirect`), `src/hooks/*`, `src/services/firebase/schema.js`, `src/utils/*`, `functions/index.js`, `firestore.rules`, `storage.rules`, `firestore.indexes.json`.

**Estrutura do repo Flutter (`origin/App`)** — arquitetura em camadas: `lib/models/*` (`user_model`, `pet_model`, `vaccine_model`, `deworming_model`), `lib/repositories/*` (`user_`, `pet_`, `vaccine_`, `pet_weight_`), `lib/controllers/*` (`vaccines/vaccine_controller`, `validacao_controller`, `user_controller`, `pets/pet_controller`, `home/*`), `lib/authentication/*` (`auth_login`, `forgot_password`, `logout`), `lib/screens/*` (auth, onboarding, home, pets, vaccines, deworming, profile), `lib/firebase/schema.dart`, `lib/main.dart`.

> ⚠️ **As Security Rules, Functions, Storage rules e índices vivem na branch web (`Website`) e são compartilhados** — o Firebase é um só. O mobile **precisa respeitar exatamente** o que está em produção (§5/§6), independentemente do que o `lib/firebase/schema.dart` do mobile descreve (esse schema está desatualizado — ver §12).

---

## 2. Contrato de dados (FONTE DA VERDADE)

Convenções (web, `src/services/firebase/schema.js`):
- **Datas** sempre `Timestamp` do Firestore (nunca string ISO). O mobile grava `DateTime`/`Timestamp` do SDK Dart → o SDK converte para `Timestamp` automaticamente (OK), **exceto** onde usa `DateTime.now()` no cliente em vez de `serverTimestamp()` (ver observações).
- **Soft-delete:** registros clínicos usam `active:false` + `deletedAt` + `deletedBy`. **Hard delete é proibido por rule** (§5).
- **Eixo único de status** em `vaccines`/`deworming`: `pending|approved|rejected`. Ciência do tutor é um **campo à parte** (`tutorAcknowledged`), nunca um segundo eixo.

Legenda das tabelas: **W**=Web/vet, **M**=Mobile/tutor, **CF**=Cloud Function (Admin).

### 2.1 `users/{uid}`
Perfil de qualquer usuário (vet ou tutor). Fonte web: `schema.js` (linha ~11); fonte mobile: `lib/models/user_model.dart`.

| Campo | Tipo | Obrigatório | Escreve | Lê | Observações |
|---|---|---|---|---|---|
| `email` | string | sim | W, M | W, M, CF | espelha o Auth |
| `name` | string | sim | W, M | W, M, CF | |
| `cpf` | string | sim (tutor/vet) | W, M | W, CF | CF valida Módulo 11 ao criar vacina (§4) |
| `phone` | string | não | W, M | W, M | |
| `role` | string enum | **sim** | W, M | W, M, CF | `tutor` \| `veterinarian` (§3) |
| `status` | string enum | **sim** | W, M | W | `active`/`pending`/`suspended` (§3) |
| `profileCompleted` | bool | **sim** | W, M | W (gating) | **mobile NÃO usa para gating** (§7) |
| `emailVerified` | bool | sim | CF (`verifyOtp`), W | W (gating) | escrito pela CF; **mobile não tem esse fluxo** (§7) |
| `address` | map | não | W, M | W, M | `{street, number, complement, neighborhood, city, state, zipCode}` |
| `crmv` | string | só vet | W | W, CF | CF valida regex (§4) |
| `specialties` / `yearsOfExperience` / `clinicId` | — | só vet | W | W | `clinicId` **@deprecated** (verdade = `clinics.veterinarians[]`); removido por migração nos seeds |
| `pets` | array<string> | só tutor | M | M | array de petIds (mobile inicializa `[]`) — duplica a verdade `pets.ownerId` |
| `preferredVetId` | string | tutor | ⚠️ | W | ⚠️ A CONFIRMAR quem grava |
| `emergencyContact` | map | tutor | M | W, M | `{name, phone, relationship}` |
| `createdAt`/`updatedAt` | Timestamp | sim | W, M, CF | — | `user_controller.dart:62` usa `serverTimestamp()`; `user_model.toMap()` usa `DateTime.now()` — ⚠️ ver §12 |
| **`password`** | string | — | **M** ⚠️ | — | 🔴 `user_model.toMap()` grava a senha em texto no doc. **Não deve existir.** A web não grava. Remover (§11 F0). |
| `darkMode` | bool | não | W | W | preferência de tema (web) |
| **Subcoleção** `users/{uid}/notifications/{id}` | — | — | **CF** | W (`useNotifications`) | `{type, vaccineId, status, read, createdAt}`. Escrita por `updateVaccineStatus` (§4). **Mobile ainda não lê** (§10). |

### 2.2 `pets/{petId}` (coleção **top-level**)
Fonte web: `schema.js` (~188); mobile: `lib/models/pet_model.dart`, `lib/repositories/pet_repository.dart`.

| Campo | Tipo | Obrigatório | Escreve | Lê | Observações |
|---|---|---|---|---|---|
| `name`, `species`, `breed`, `color`, `gender` | string | sim | W, M | W, M | mobile já usa nomes em inglês (`species`/`breed`/`gender`) |
| `birthDate` | Timestamp | sim | W, M | W, M | |
| `isNeutered` | bool | não | M | W, M | |
| `chipNumber` | string | não | W, M | W, M | |
| **`ownerId`** | string | **sim** | W, M | W, M, CF | 🟢 **verdade do vínculo tutor↔pet.** Mobile já filtra por `ownerId` (`pet_repository`) |
| `ownerName` | string | não | W, M | W, M | |
| **`veterinarians`** | array<string> | sim | W, M | W (rules) | 🟢 vínculo vet↔pet (§8). Rule de leitura/escrita depende deste array |
| `status` | string | sim | W, M | W, M | `active`/`inactive`; mobile filtra `status=='active'` |
| `createdBy` | string | **sim (recomendado)** | W | W (rule) | 🔴 **mobile NÃO grava** (`pet_model.toMap()`). Rule de **delete** exige `createdBy==uid` → delete do tutor falha (§5). Necessário (§11) |
| `createdAt`/`updatedAt` | Timestamp | sim | W, M | — | mobile usa `DateTime.now()` (`pet_model`) — preferir `serverTimestamp()` |
| `medicalNotes`/`allergies`/`chronicConditions` | — | não | W, M | W, M | histórico clínico |
| `imageUrl` | string | não | **M** | M | 🟠 mobile-only; web não lê. Upload **quebrado** por path de Storage (§6) |
| `vaccines` | array<string> | — | **M** ⚠️ | — | 🟠 **@deprecated** — verdade = `vaccines.petId`. Web **removeu** por migração; `pet_model.toMap()` ainda grava `[]`. Parar de gravar (§11) |
| `tutorId` | string | — | — | — | 🟠 **@deprecated** — duplica `ownerId`. Web removeu por migração; `schema.dart` ainda lista, mas `pet_model.toMap()` **não grava** (usa `ownerId`) ✅ |
| `dewormings` | array<string> | — | **M** ⚠️ | — | ⚠️ `add_deworming_screen.dart:187` faz `arrayUnion` — campo que a web não conhece. ⚠️ A CONFIRMAR uso |
| **Subcoleção** `pets/{petId}/pesos/{id}` | — | — | **W** | W, (tutor: leitura) | 🔴 **web usa `pesos`**; **mobile usa `weights`** (`pet_weight_repository.dart`) → nomes divergentes (§12). Escrita é **vet-only** por rule → tutor é **bloqueado** (§5) |
| **Subcoleção** `pets/{petId}/consultas/{id}` | — | — | W | W, (tutor: leitura) | prontuário; escrita vet-only |

### 2.3 `vaccines/{vaccineId}` (coleção **top-level**)
Fonte web: `schema.js` (~60); mobile: `lib/models/vaccine_model.dart`, `lib/repositories/vaccine_repository.dart`, `lib/controllers/vaccines/vaccine_controller.dart`.

| Campo | Tipo | Obrigatório | Escreve | Lê | Observações |
|---|---|---|---|---|---|
| `name`, `manufacturer`, `batchNumber` | string | sim | W(CF), M | W, M | |
| `dose` | string | não | W | W | **web usa `dose`**; deworming usa `dosage` |
| `expirationDate`, `administrationDate`, `nextDueDate` | Timestamp | sim | W(CF), M | W, M | índice composto `(veterinarianId, nextDueDate)` p/ Vencimentos |
| `petId` | string | **sim** | W(CF), M | W, M | 🟢 verdade do vínculo vacina↔pet |
| `petName`/`petSpecies`/`petBreed`/`petWeight` | — | não | W, M | W, M | desnormalizado |
| **`ownerId`** | string | **sim** | W(CF), M | W, M (rule) | 🟢 rule de leitura usa `ownerId`. Mobile já grava (`vaccine_controller`) |
| `ownerName`/`ownerContact` | string | não | W, M | W, M | mobile usa `user.displayName`/`user.email` (podem vir `null`) |
| **`veterinarianId`** | string | **sim** | W(CF), M | W, M (rule) | 🟢 rule de update/CF usa este campo. **CF `createVaccineRecord` força = caller** → impróprio p/ tutor (§4) |
| `veterinarianName`/`crmvNumber`/`clinicName`/`clinicCnpj`/`clinicAddress` | — | não | W, M | W, M | |
| **`status`** | string enum | sim | **só CF** | W, M | `pending\|approved\|rejected` (§3). 🔴 **cliente NÃO pode escrever** (rule). Mobile escreve `status` direto (cria como `pending` ok no create; mas `validacao_controller` faz update → **bloqueado**, §5) |
| `validationDetails.vetValidation` | map | — | **só CF** | W, M | `{status, validatedAt, validatedBy, validatedByName, validatedByCrmv, notes, rejectionReason}` — escrito por `updateVaccineStatus` |
| `validationDetails.tutorValidation` | map | — | — | — | 🟠 **modelo antigo (2 eixos)** — a web **não usa mais**. `vaccine_model.dart`/`validacao_controller` ainda escrevem → conflito (§12) |
| **`tutorAcknowledged`** | bool | — | **M (alvo)** | W | 🟢 **substitui** a "validação do tutor". Único campo que o tutor pode atualizar (rule `tutorAckOnly`). Mobile **ainda não usa** (§11) |
| `tutorAcknowledgedAt` | Timestamp | — | M (alvo) | W | |
| `labelImage` | string (URL) | não | W, M | W, M | URL do Storage. Upload mobile **quebrado** por path (§6) |
| `active` | bool | — | W (soft-delete) | W | `false` = excluído logicamente |
| `deletedAt`/`deletedBy` | — | — | W | W | soft-delete |
| `createdAt`/`updatedAt`/`updatedBy` | Timestamp/string | sim | W(CF), M | — | CF usa `serverTimestamp()`; mobile usa `DateTime.now()` |

### 2.4 `deworming/{dewormingId}` (top-level) — mesmo padrão de `vaccines`
Fonte web: `schema.js` (~256, `status:['pending','approved','rejected']`); mobile: `lib/models/deworming_model.dart`, `lib/screens/deworming/add_deworming_screen.dart`.
- Campos análogos a `vaccines`, com `dosage` (em vez de `dose`), `isReinforcementNeeded`, `reinforcementDate`, `effectivenessNotes`, `sideEffects[]`, `observations`.
- `status`/`validationDetails`/`tutorAcknowledged`: **mesma regra de `vaccines`** (§5). `deworming_model.dart` tem `DewormingStatus {active, completed, expired}` — ⚠️ **enum errado** (deveria ser `pending/approved/rejected`); ver §12.
- `add_deworming_screen.dart` grava `createdBy` + `serverTimestamp()` (melhor que o fluxo de vacina) e faz `arrayUnion('dewormings')` no pet (campo não-canônico).

### 2.5 `clinics/{clinicId}`
Fonte: `schema.js` (~235). Campos: `name, cnpj, phone, email, address{}, veterinarians[], status, createdAt, updatedAt`.
- 🟢 **`veterinarians[]` é a verdade do vínculo vet↔clínica** (substitui `users.clinicId`).
- Rule: **só vets listados em `veterinarians[]`** leem/escrevem (§5). O mobile (tutor) **lê `clinics`** em `add_vaccine_screen.dart:188` e `add_deworming_screen.dart:76` → ⚠️ **isso viola a rule de `clinics`** (leitura restrita a vets) → provável `permission-denied` (§5/§12).

### 2.6 `appointments/{id}`
`schema.js` (~249): `{petId, tutorId, veterinarianId, clinicId, date, type, status, notes, ...}`. Rule: dono = `veterinarianId`. ⚠️ A CONFIRMAR uso real (sem repositório de appointments no mobile; uso mínimo na web).

### 2.7 `conversas/{id}` + `conversas/{id}/mensagens/{id}` (chat)
- Rules **já existem** (§5): só `vetId`/`tutorId` participantes acessam; só o vet cria a conversa.
- 🟠 **Não há dados reais ainda:** a web roda o chat com um **mock isolado** (`src/services/chatMock.js`, `src/hooks/useChatMock.js`) e o mobile **não tem chat**. Backend pronto, frontend dos dois lados ainda não conectado ao Firestore.

### 2.8 `vaccineCatalog/{id}` e `dewormerCatalog/{id}` (catálogo controlado)
- Leitura por qualquer autenticado; **escrita só Admin SDK** (seed/migração) — rule (§5).
- 🟢 **Esta é a fonte canônica do catálogo de vacinas/vermífugos.** O mobile hoje usa **mocky.io** + lista hardcoded (`vaccine_repository.fetchAvailableVaccinesFromApi`) → migrar para `vaccineCatalog` (§11).

### 2.9 `pending_vaccines/{id}` — ⚠️ órfã / bloqueada
- Escrita **só pelo mobile** (`vaccine_repository.addPendingVaccine` ← `vaccine_controller.addVaccineToQueue`). A web **não conhece** esta coleção.
- 🔴 **Não há rule para ela** → cai no `match /{document=**} { allow read,write: if false }` → **toda escrita é negada** (§5). Além disso, `addVaccineToQueue` lê de subcoleções inexistentes (`users/{uid}/pets/...`, §2.10). **Fluxo morto/quebrado.** Decisão pendente (§13): manter "fila de pendentes" ou usar o próprio `vaccines.status=='pending'` (recomendado).

### 2.10 `otpCodes/{uid}` — somente Admin
- Escrita/leitura **só via Admin SDK** (CFs `sendVerificationOtp`/`verifyOtp`). Rule nega todo acesso de cliente. Guarda `{hash, salt, expiresAt, attempts, used, email, sendHistory}`.

### Campos órfãos / leituras mortas relevantes (resumo)
- `users.password` (mobile grava, ninguém lê — **risco**).
- `pets.vaccines[]`, `pets.tutorId`, `users.clinicId` (deprecados, removidos por migração na web).
- `pets.imageUrl`, `pets.dewormings[]` (mobile-only, web ignora).
- Leituras mobile de **subcoleções `users/{uid}/pets/{petId}/...`** (`vaccine_repository.getPetData/getVaccineData`) → **modelo antigo**; pets/vacinas hoje são **top-level** → retornam vazio/quebram.

---

## 3. Enums e constantes canônicas

### 3.1 `vaccines.status` / `deworming.status` — **eixo único (3 valores)** 🟢 fonte: `src/services/firebase/schema.js:117,297` + `firestore.rules:58` + `functions/index.js:368`

| Valor | Significado | Quem define |
|---|---|---|
| `pending` | aguardando validação do veterinário | criação (cliente ou CF) |
| `approved` | aprovado pelo vet | **só** `updateVaccineStatus` (CF) |
| `rejected` | rejeitado pelo vet | **só** `updateVaccineStatus` (CF) |

- **Ciência do tutor** = campo `tutorAcknowledged: bool` (+`tutorAcknowledgedAt`), **não** um status. É o **único** campo que o tutor pode atualizar (rule `tutorAckOnly`).
- **Transição:** `pending → approved | rejected` via CF, exigindo `veterinarianId == caller` e `status == 'pending'` (uma vez decidido, **congela** — `frozen()`).
- 🔴 **DIVERGÊNCIA:** o mobile (`vaccine_model.dart`, `schema.dart`) ainda usa o enum antigo de 7 valores `{pending, vetApproved, vetRejected, tutorApproved, tutorRejected, fullyApproved, rejected}` e o bloco `tutorValidation`. **O "plano" citado (6 valores) está desatualizado.** Migrar o mobile para os 3 valores + `tutorAcknowledged` (§11 F2).

### 3.2 `role` — `src/services/firebase/schema.js`, `lib/models/user_model.dart`
- `tutor` | `veterinarian`. No **mobile só existe tutor** (default `'tutor'` em `user_model.toMap()`). O gating por role da web não se aplica ao app, mas o mobile deve **garantir** que só loga tutor (ou tratar vet logando no app).

### 3.3 `status` (usuário) — `['active', 'pending', 'suspended']` (`schema.js:11`)
- `active`: liberado. `pending`: aguardando (web usa antes do onboarding). `suspended`: bloqueado.
- 🔴 **DIVERGÊNCIA:** `user_model.toMap()` cria tutor já como **`'active'`** (pula `pending`). A web cria como `pending` até o onboarding. Decidir o padrão do mobile (§13) e respeitar no gating (§7).

### 3.4 `profileCompleted: bool`
- Web bloqueia o app até `true` (`ProfileGate`). O mobile **ignora** → precisa adotar para a UX de onboarding ficar consistente (§7/§11).

---

## 4. Cloud Functions — `functions/index.js` (todas `onCall`, região `southamerica-east1`)

> 🔴 **O mobile NÃO tem o pacote `cloud_functions` no `pubspec.yaml`** → hoje **não consegue chamar nenhuma destas**. Para usar qualquer uma, adicionar `cloud_functions` e inicializar na região correta (§11 F1).

| Função | Tipo | Input | Output | Validações | Quem deve chamar |
|---|---|---|---|---|---|
| **`sendVerificationOtp`** (`:140`) | callable | `{name?}` (usa `auth.token.email`) | `{success:true}` | auth obrigatória; rate-limit `MAX_SENDS_PER_HOUR/hora`; gera OTP com hash+salt em `otpCodes/{uid}`; envia e-mail (Gmail via secrets) | usuário autenticado, **pós-signup** (mobile deveria passar a usar, §11) |
| **`verifyOtp`** (`:212`) | callable | `{code}` (6 dígitos) | `{success:true}` | código 6 dígitos; expira em `OTP_EXPIRY_MINUTES`; `MAX_VERIFY_ATTEMPTS`; em sucesso seta `auth.emailVerified=true` **e** `users/{uid}.emailVerified=true` | usuário autenticado |
| **`createVaccineRecord`** (`:296`) | callable | `{vaccineData}` | `{id}` | auth; valida **CPF (Módulo 11)** e **CRMV (`/^CRMV-[A-Z]{2}\s\d{1,5}$/`)** se presentes; cria `vaccines/*` com `status:'pending'`, `serverTimestamp()` e **`veterinarianId = caller`** | 🟠 **orientada ao VET** (força `veterinarianId=caller`). Para submissão do **tutor**, ver decisão em §13 |
| **`updateVaccineStatus`** (`:330`) | callable | `{vaccineId, isApproved, notes?, rejectionReason?}` | `{success, status}` | auth; exige `vaccine.veterinarianId==caller`; exige `status=='pending'`; rejeição exige `rejectionReason`; grava `validationDetails.vetValidation` + **notifica o owner** (`users/{ownerId}/notifications`) | **somente o vet responsável** |

- **Total: 4 callables.** Não há triggers (`onDocument*`) nem HTTP.
- 🟢 **O mobile deve passar a usar:** `sendVerificationOtp`/`verifyOtp` (verificação de e-mail, §7). `updateVaccineStatus` é **do vet** (o tutor não valida — ele dá ciência via `tutorAcknowledged`). `createVaccineRecord` só faz sentido para o tutor se o produto decidir que o tutor pode submeter vacina (hoje o mobile cria direto em `vaccines`; ver §13).

---

## 5. Security Rules — o que o mobile DEVE respeitar (`firestore.rules`)

> Regra-mãe: **tudo que não está explicitamente liberado é negado** (`match /{document=**} { allow read,write: if false }`, `:145`). Logo, coleção sem rule = bloqueada (caso de `pending_vaccines`).

| Coleção | Leitura | Criação | Update | Delete | Impacto no mobile |
|---|---|---|---|---|---|
| `users/{uid}` (+`/notifications`) | dono (`uid==userId`) | — | dono | dono | OK ler/escrever próprio perfil e notificações |
| `pets/{petId}` | dono **ou** vet em `veterinarians[]` | qualquer autenticado | `createdBy==uid` **ou** `ownerId==uid` | **`createdBy==uid`** | 🔴 tutor **deleta pet só se** `createdBy==uid`; mobile **não grava `createdBy`** → **delete falha** |
| `pets/{petId}/{record=**}` (pesos, consultas) | dono **ou** vet | — | **só vet** vinculado | só vet | 🔴 **tutor NÃO escreve** subcoleção → `pet_weight_repository.addWeight` (tutor) → **`permission-denied`** |
| `vaccines/{id}` | `isVet()` **ou** `isOwner()` | qualquer autenticado | `!touchesProtected()` **e** (`isOwner()&&tutorAckOnly()` \| `isVet()&&softDeleteOnly()` \| `isVet()&&!frozen()`) | **`if false`** | 🔴 `validacao_controller` (tutor escreve `status`+`validationDetails`) → **negado** (`touchesProtected`). 🔴 `deleteVaccine` (hard delete) → **negado**. ✅ criar como `pending` é permitido |
| `deworming/{id}` | igual a `vaccines` | qualquer autenticado | igual a `vaccines` | `if false` | mesmas restrições |
| `clinics/{id}` | **só vet em `veterinarians[]`** | (idem) | só vet | só vet | 🔴 **tutor lê `clinics`** em add_vaccine/add_deworming → **`permission-denied`** |
| `conversas/{id}` (+`/mensagens`) | participantes (`vetId`/`tutorId`) | só vet (`vetId==uid`) | participantes | participantes | chat: tutor lê/escreve mensagens de conversas onde é `tutorId`; **não cria conversa** |
| `vaccineCatalog` / `dewormerCatalog` | qualquer autenticado | — | — | — | 🟢 mobile pode **ler** o catálogo (migrar do mocky.io) |
| `otpCodes/{uid}` | `if false` | — | — | — | só Admin (CF) |
| `appointments/{id}` | dono=`veterinarianId` | qualquer autenticado | dono | dono | tutor não lê/escreve (rule é do vet) |

**Resumo dos `permission-denied` que o mobile toma HOJE** (todos confirmados por leitura de código vs. rules):
1. **Validação de vacina pelo tutor** (`validacao_controller.validadeVacTutor/rejectVacTutor`) — escreve `status`+`validationDetails`. → trocar por update de `tutorAcknowledged` apenas.
2. **Hard delete de vacina** (`vaccine_repository.deleteVaccine`) — usar soft-delete (e, na prática, soft-delete é **vet-only**; o tutor não exclui).
3. **Adicionar peso** (`pet_weight_repository.addWeight`, tutor) — subcoleção é **vet-only**. Decisão de produto (§13): tutor pode registrar peso?
4. **Ler `clinics`** (tutor) — restrito a vets. Precisa de catálogo de clínicas legível ao tutor, ou desnormalizar dados da clínica.
5. **Escrever em `pending_vaccines`** — coleção sem rule (negada).
6. **Deletar pet sem `createdBy`** — gravar `createdBy` na criação.

---

## 6. Storage — `storage.rules`

| Path | Regra | Quem |
|---|---|---|
| `vaccine-labels/{fileName}` | read: autenticado · write: autenticado **+ `size < 5MB` + `contentType` `image/*`** | qualquer autenticado |
| `{allPaths=**}` (resto) | **`read, write: if false`** | ninguém |

- 🟢 **Path canônico de imagem de rótulo:** `vaccine-labels/...` (a web usa este).
- 🔴 **DIVERGÊNCIA CRÍTICA (mobile):** o mobile sobe imagens para **`images/...`**, não para `vaccine-labels/`:
  - rótulo de vacina → `images/{microsecondsSinceEpoch}` (`lib/screens/vaccines/vaccine_steps/label_step.dart:94-99`)
  - foto do pet → `images/pets/{ts}_{name}` (`lib/screens/pets/pet_information.dart:845`)
  - → **ambos caem no catch-all `if false` → `permission-denied`.** Hoje o upload de imagem do mobile **não funciona** sob as rules de produção.
- **Alvo:** rótulos de vacina → `vaccine-labels/...`. Foto de pet → **definir um path próprio** (ex.: `pet-photos/...`) **e criar a rule correspondente** (decisão §13; a web não usa foto de pet hoje).

---

## 7. Autenticação e onboarding (foco mobile)

**Web (`src/components/auth/*`, `src/App.jsx`):** cadeia `ProtectedRoute` (exige login **+ `emailVerified`**) → `ProfileGate` (exige `profileCompleted`) → `Layout` → `RoleRoute` (separa rotas de `veterinarian` e `tutor`). Telas: `/auth` (login), `/verify-email` (OTP via `sendVerificationOtp`/`verifyOtp`), `/forgot-password` + `/reset-password`. `status:'suspended'` bloqueia.

**Mobile (`lib/main.dart`, `lib/authentication/*`):**
- `RoteadorTelas` = `StreamBuilder(authStateChanges)` → logado → `HomeScreenPage`; senão → `OnBoarding`. **Sem gating** por `role`/`status`/`profileCompleted`/`emailVerified`.
- Login: `auth_login.entrarUsuario` = `signInWithEmailAndPassword` puro (sem checagem de e-mail verificado).
- Reset de senha: ✅ `forgot_password.esqueciMinhaSenha` = `sendPasswordResetEmail` (nativo Firebase) — **já funciona**.
- **Verificação de e-mail (OTP): ausente** (mobile não chama as CFs; falta `cloud_functions`).

**Falta no mobile (§11):** gating pós-login (bloquear até e-mail verificado + perfil completo; tratar `suspended`); fluxo OTP (`sendVerificationOtp`/`verifyOtp`); decidir `status` inicial (`pending` vs `active`, §3.3); garantir `profileCompleted` coerente.

---

## 8. Modelo de vínculo Vet ↔ Pet

- **Verdade hoje:** `pets.veterinarians[]` (array de uids de vets) — usado nas **rules** de leitura/escrita do pet e das subcoleções (§5). `pets.ownerId` = tutor dono. `preferredVetId` (em `users`, do tutor) ⚠️ A CONFIRMAR quem grava/consome.
- **Por que "o vet não vê os pets":** a rule de leitura de `pets` exige `ownerId==uid` **ou** `veterinarians.hasAny(uid)`. Se o vet **não está** em `veterinarians[]` do pet, ele **não lê** aquele pet. No mobile, o pet é criado pelo **tutor** e `veterinarians[]` só é populado quando uma vacina/vermífugo é registrado com um vet (ex.: `add_vaccine_screen.dart:769` faz `arrayUnion(selectedVetId)`). Pets sem registro com vet → invisíveis ao vet.
- **DECISÃO DE PRODUTO PENDENTE (apenas apontando, §13):** como o tutor associa um veterinário ao pet? (seleção explícita de vet preferido? convite? associação automática no 1º registro?) Isso define o que o mobile precisa gravar em `veterinarians[]`/`preferredVetId`.

---

## 9. Estado atual — Web (vet) · MVP funcionando

Construído e em produção (`Website`, deploy em `pet-app-fccae.web.app`):
- **Auth completo:** login, OTP de verificação de e-mail (CF), reset de senha, gating por role/status/perfil.
- **Pacientes:** lista (`/pets`), prontuário (`PetRecord` — vacinas, vermífugos, pesos, consultas), **Carteira de vacinação em PDF** (`Carteira`, `@media print`).
- **Vacinas/Vermífugos:** lista, **validação em 1 clique** (aprovar/rejeitar via `updateVaccineStatus`), `VaccineDetailsModal`, catálogo controlado (`vaccineCatalog`/`dewormerCatalog`).
- **Vencimentos** (`/vencimentos`) e **Dashboard** com alertas (índice composto `veterinarianId+nextDueDate`).
- **Clínicas** (`/clinicas`).
- **Chat** (`/chat`) — UI pronta consumindo **mock isolado** (`chatMock.js`), com badge de não-lidas no header e roteamento; **backend de chat ainda não conectado**.
- **Ajuda & Suporte** (`/support`) — FAQ + contato.
- **Tema** claro/escuro com tokens; landing page.
- **Endurecimento:** rules com soft-delete + imutabilidade pós-validação + eixo único de status; auditoria (`validationDetails.vetValidation` com `validatedBy*`); migração `cleanupRedundantLinks` executada (removeu `pets.tutorId`/`pets.vaccines[]`/`users.clinicId`).

---

## 10. Estado atual — Mobile (tutor)

**Existe (`origin/App`):** login/signup/forgot-password, onboarding, home, **pets** (listar por `ownerId`, criar, ver, editar, foto), **peso** (tracker), **vacinas** (listar, criar, "validar"), **vermífugos** (listar, criar), perfil. Arquitetura limpa (models/repositories/controllers/screens), GetX, PDF (syncfusion), geolocation, image_picker.

**Quebrado hoje (vs. produção)** — todos confirmados por código:
- 🔴 **Validação de vacina pelo tutor** (`validacao_controller`) → `permission-denied` (escreve `status`/`validationDetails`).
- 🔴 **Hard delete** de vacina (`vaccine_repository.deleteVaccine`) → `permission-denied`.
- 🔴 **Upload de imagem** (rótulo e foto de pet) → `permission-denied` (path `images/` fora de `vaccine-labels/`, §6).
- 🔴 **Registrar peso** (tutor) → `permission-denied` (subcoleção vet-only, §5).
- 🔴 **Ler `clinics`** (tutor, nos fluxos de add) → `permission-denied`.
- 🔴 **`pending_vaccines`** (`addVaccineToQueue`) → `permission-denied` + lê subcoleções inexistentes.
- 🟠 **Enum de status** (7 valores + `tutorValidation`) divergente do real (3 + `tutorAcknowledged`).
- 🟠 **Catálogo via mocky.io** (URL externa) + lista hardcoded, em vez de `vaccineCatalog`.
- 🟠 Leituras de `users/{uid}/pets/...` (modelo de subcoleção antigo) → não casam com o top-level atual.

**Ausente:** gating pós-login; OTP/verificação de e-mail; `cloud_functions` no pubspec; consumo de `users/{uid}/notifications`; FCM/push (`firebase_messaging` ausente); `createdBy` em pets; `tutorAcknowledged`; `serverTimestamp()` consistente; remoção do campo `password` em `users`.

---

## 11. Guia / Roadmap de desenvolvimento mobile

> Numeração de fases (`F0–F4`) **autorada aqui** (não há `PLANO_IMPLEMENTACAO_AUDITORIA.md`). Esforço: **P** (≤0,5d) · **M** (1–2d) · **G** (3+d). Ordenado por dependência.

### F0 — Higiene/segurança (rápido, destrava)
| # | Tarefa | Esforço | Refs |
|---|---|---|---|
| F0.1 | **Remover `password` do `users` doc** (`user_model.toMap()`) | P | §2.1 |
| F0.2 | Trocar `DateTime.now()` por `FieldValue.serverTimestamp()` nas escritas (pet/vacina) | P | §2 |
| F0.3 | Parar de gravar `pets.vaccines[]` (e revisar `pets.dewormings[]`) | P | §2.2 |
| F0.4 | Gravar **`createdBy`** ao criar pet (destrava delete e a rule de update) | P | §5 |

### F1 — Infra de backend no app (pré-requisito de quase tudo)
| # | Tarefa | Esforço | Refs |
|---|---|---|---|
| F1.1 | Adicionar **`cloud_functions`** ao `pubspec.yaml` e configurar região `southamerica-east1` | P | §4 |
| F1.2 | Corrigir **path de Storage** dos uploads → `vaccine-labels/` (rótulo) e definir/criar rule p/ foto de pet | M | §6, §13 |
| F1.3 | Remover leituras do modelo antigo `users/{uid}/pets/...` (usar coleções top-level) | M | §2.10 |

### F2 — Alinhar o domínio de vacinas/vermífugos
| # | Tarefa | Esforço | Refs |
|---|---|---|---|
| F2.1 | **Enum de status → 3 valores** (`pending/approved/rejected`) em `vaccine_model`/`deworming_model`/`schema.dart`; remover `tutorValidation` | M | §3.1 |
| F2.2 | **Ciência do tutor**: substituir `validacao_controller` por update **só de `tutorAcknowledged`/`tutorAcknowledgedAt`** | M | §5 |
| F2.3 | Remover `deleteVaccine` (hard delete) — tutor não exclui registro clínico | P | §5 |
| F2.4 | Decidir e implementar criação de vacina pelo tutor: manter `vaccines.status='pending'` (direto, permitido) **vs.** via CF (decisão §13). Aposentar `pending_vaccines` | M | §2.9, §13 |
| F2.5 | Catálogo: **mocky.io → `vaccineCatalog`/`dewormerCatalog`** (ou Remote Config como fallback) | M | §2.8 |

### F3 — Onboarding/auth alinhados
| # | Tarefa | Esforço | Refs |
|---|---|---|---|
| F3.1 | **Gating pós-login**: bloquear até `emailVerified` + `profileCompleted`; tratar `status=='suspended'` | M | §7 |
| F3.2 | **OTP de verificação de e-mail** via `sendVerificationOtp`/`verifyOtp` (tela equivalente à web) | G | §4, §7 |
| F3.3 | Padronizar `status` inicial do tutor (decisão §13: `pending` vs `active`) | P | §3.3 |

### F4 — Recursos
| # | Tarefa | Esforço | Refs |
|---|---|---|---|
| F4.1 | **Notificações**: consumir `users/{uid}/notifications` (lista in-app) | M | §2.1, §4 |
| F4.2 | **Push (FCM)**: decisão §13; se sim, `firebase_messaging` + token em `users` + envio (nova CF/trigger) | G | §13 |
| F4.3 | **Peso do pet**: depende da decisão §13 (tutor pode registrar?) — se sim, ajustar rule da subcoleção **ou** mover para coleção com rule de tutor; alinhar nome `pesos` vs `weights` | M | §2.2, §5 |
| F4.4 | **Edição de pet**: garantir que o update respeita a rule (`ownerId==uid`) e não toca campos proibidos | P | §5 |
| F4.5 | **Chat** (quando o backend for ligado dos dois lados): `conversas`/`mensagens` conforme rules | G | §2.7 |

---

## 12. Divergências conhecidas mobile ↔ web (onde os dados "não casam")

| # | Tema | Web (verdade) | Mobile (hoje) | Efeito |
|---|---|---|---|---|
| 1 | Status de vacina | `pending/approved/rejected` + `tutorAcknowledged` | 7 valores + `tutorValidation` | dados/regra incompatíveis |
| 2 | Validação do tutor | `tutorAcknowledged` (campo) | escreve `status`+`validationDetails` | `permission-denied` |
| 3 | Subcoleção de peso | `pets/{id}/**pesos**` (vet-only) | `pets/{id}/**weights**` (tutor) | nome diverge **e** rule bloqueia tutor |
| 4 | Storage | `vaccine-labels/` | `images/...` | upload negado |
| 5 | Catálogo | `vaccineCatalog`/`dewormerCatalog` | mocky.io + hardcoded | fonte diferente |
| 6 | `pending_vaccines` | inexistente | mobile grava | coleção negada por rule |
| 7 | `pets.createdBy` | gravado | ausente no mobile | delete do pet falha |
| 8 | `pets.vaccines[]`/`tutorId`, `users.clinicId` | removidos (migração) | `schema.dart` ainda lista; `pet_model` grava `vaccines:[]` | campos zumbis |
| 9 | `users.password` | nunca gravado | `user_model` grava | risco de segurança |
| 10 | Timestamps | `serverTimestamp()` | `DateTime.now()` em vários pontos | divergência de relógio/consistência |
| 11 | Ler `clinics` | só vet | tutor lê nos add | `permission-denied` |
| 12 | `deworming.status` enum | `pending/approved/rejected` | `{active,completed,expired}` | incompatível |
| 13 | Gating/OTP | exigidos | ausentes | UX e segurança divergentes |

---

## 13. Decisões pendentes que afetam o mobile

1. **Vínculo Vet ↔ Pet (§8):** como o tutor associa um veterinário ao pet? Define o que gravar em `pets.veterinarians[]` / `users.preferredVetId`.
2. **Submissão de vacina pelo tutor:** o tutor pode criar vacina? Se sim, **direto em `vaccines` (`status:'pending'`)** ou **via CF** (a `createVaccineRecord` força `veterinarianId=caller`, imprópria p/ tutor — precisaria de CF nova `submitVaccineByTutor`)?
3. **`pending_vaccines`:** descontinuar (recomendado) e usar `vaccines.status=='pending'`, ou criar rules/fluxo para ela?
4. **Peso do pet pelo tutor:** permitir? Se sim, mudar a rule da subcoleção `pets/{id}/{record=**}` (hoje vet-only) ou mover pesos para coleção própria com rule de tutor. Também unificar `pesos` vs `weights`.
5. **Foto do pet:** a web não tem; definir path de Storage + rule (ex.: `pet-photos/`).
6. **Notificações push (FCM):** implementar? Hoje só há notificações **in-app** (`users/{uid}/notifications`); não há `firebase_messaging` nem trigger de push.
7. **Criptografia de CPF/CNPJ:** dados sensíveis hoje em texto (`users.cpf`, `vaccines.clinicCnpj`). Decisão de proteção/retenção (afeta o que o mobile grava/exibe).
8. **`status` inicial do tutor:** `pending` (como a web) ou `active` (como o mobile faz hoje)?
9. **Catálogo:** `vaccineCatalog` (Firestore, já existe) é a fonte — confirmar se Remote Config entra como fallback/feature-flag.

---

## Apêndice — `⚠️ A CONFIRMAR` e limites de acesso

**Acessos confirmados:** ✅ repo React (`Website`, `src/`), ✅ repo Flutter (`origin/App`, `lib/`, via leitura git), ✅ Cloud Functions (`functions/index.js`), ✅ `firestore.rules` / `storage.rules` / `firestore.indexes.json`, ✅ Firebase CLI (projeto `pet-app-fccae`).

**Não localizado:** `PLANO_IMPLEMENTACAO_AUDITORIA.md` (não existe no repo nem em diretórios irmãos). Roadmap (§11) foi autorado a partir do código + `AUDITORIA_SISTEMA.md`.

**Itens `⚠️ A CONFIRMAR` (não verificados 100% no código):**
1. `users.preferredVetId` — quem grava e quando (vínculo vet↔pet, §8).
2. **Signup real do mobile** (`lib/controllers/user_controller.dart`) — usa `serverTimestamp()` (linhas 62-63), mas **não confirmei** se persiste o campo `password` de `user_model.toMap()` ou monta o próprio mapa. Verificar antes de F0.1.
3. **`add_vaccine_screen.dart`** (fluxo "completo", ~linha 762) vs. `vaccine_controller.registerVaccine` (fluxo "flat") — há **dois caminhos** de criação de vacina no mobile; não li o `add_vaccine_screen` inteiro (faz `arrayUnion` em `pets.vaccines[]` e `pets.veterinarians[]`, e lê `clinics`).
4. **`add_deworming_screen.dart`** — confirmar coleção de destino (`deworming` top-level?) e o uso de `pets.dewormings[]`.
5. **`pet_controller.dart`**, `home_screen_controller.dart`, telas de onboarding — não lidos em detalhe (lógica de UI/estado).
6. Consumo de **`users/{uid}/notifications`** no mobile — não encontrei leitor; assumido ausente.
7. `appointments` — sem repositório/uso no mobile; uso real na web não reconfirmado.
8. Variáveis de OTP (`OTP_EXPIRY_MINUTES`, `MAX_SENDS_PER_HOUR`, `MAX_VERIFY_ATTEMPTS`) — definidas no topo de `functions/index.js` (valores exatos não relidos aqui).
