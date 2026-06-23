# Auditoria do Sistema — Software Veterinário (Controle de Pacientes + Validação de Vacinas/Vermífugos)

> Auditoria conduzida sob a ótica de consultoria em software para medicina veterinária, focada no **propósito declarado**: controle dos pacientes do veterinário e **validação de vacinas e vermífugos aplicados**. Não se avalia gestão completa de clínica (financeiro, estoque, agenda complexa) — exceto onde algo se mostra **essencial** para o propósito.

**Data:** 2026-06-23
**Escopo analisado:** código (React + hooks + services + Cloud Functions), modelagem de dados (Firestore), telas, fluxos do veterinário e do tutor, regras de segurança.
**Nota:** existe uma auditoria técnica anterior (genérica, de 2026-06-02) arquivada em `AUDITORIA_SISTEMA_2026-06-02_tecnica.md`. Vários itens dela já foram resolvidos nesta base (onboarding/completar perfil, papel de tutor, telas de clínicas e prontuário). **Este relatório reflete o estado atual.**

**Legenda de severidade:** 🔴 Crítico · 🟠 Alto · 🟡 Médio · 🔵 Baixo

---

## 1. Resumo executivo

O sistema tem um **propósito claro e bem delimitado** e já entrega a espinha dorsal certa: pacientes vinculados ao veterinário, registro de vacinas com **forte mecanismo de comprovação** (foto do rótulo com remoção de EXIF + geolocalização + mapa) e validação com **autoridade no servidor** (Cloud Function que confere CRMV/dono e estado pendente). O prontuário por animal (consultas, peso com gráfico, vacinas, vermífugos) é um ótimo alicerce clínico.

Porém, o software **ainda não fecha o ciclo do seu próprio propósito**. Os três achados mais graves:

1. **🔴 O veterinário não consegue registrar uma vacina nem um vermífugo pelo sistema.** Só existe a etapa de *validar* algo que veio de outro lugar. A função de criação (`vaccineService.createVaccine`) existe mas está **desconectada** (código órfão). Para "ter controle das vacinas/vermífugos aplicados", falta a porta de entrada do dado dentro da ferramenta do vet.
2. **🔴 Vermífugo é metade do propósito e está praticamente ausente.** Há modelo de dados e exibição somente-leitura no prontuário — mas **nenhum cadastro, nenhuma validação, nenhum alerta**. O produto promete validar vacinas *e* vermífugos; hoje valida (parcialmente) só vacinas.
3. **🔴 Inconsistência na estrutura de validação quebra a tela.** A Cloud Function grava `validationDetails.vetValidation` (aninhado) e status `vetApproved`/`vetRejected`, mas o modal de detalhes lê `validationDetails.validatedAt` (plano) e só mostra o histórico de validação quando o status é `approved`/`rejected`. Resultado: **após validar, o veterinário não vê o registro da validação que acabou de fazer.**

Há ainda **camadas de código mortas** (service + controller + modais de editar/excluir que não fazem nada), uma **máquina de estados de validação excessivamente complexa** (7 status, validação em duas partes) para um produto "enxuto", e **riscos de integridade no banco** (tipos de data misturados, exclusão física de registro clínico, redundância de vínculos que pode dessincronizar, e regras que permitem o tutor sobrescrever a validação do veterinário).

**Conclusão:** a fundação é boa e o escopo está certo. As prioridades são (a) **fechar o ciclo registro→validação→comprovação** para vacinas **e** vermífugos, (b) **unificar e simplificar** a máquina de validação, e (c) **proteger a integridade** do registro clínico (imutabilidade, datas, regras). Nada disso exige sair do escopo enxuto — boa parte é **limpeza e consolidação** do que já existe.

---

## 2. Pontos fortes

- **Escopo focado e coerente.** A intenção "controle de pacientes + validação" é defensável e evita o inchaço típico de sistemas de gestão veterinária.
- **Comprovação de aplicação robusta.** A foto do rótulo com **strip de EXIF** (privacidade) e **geolocalização + mapa** (`labelImageMetadata.location`) é um diferencial real de antifraude/auditoria — exatamente o tipo de evidência que dá confiança a um registro de vacina.
- **Autoridade de validação no servidor.** `updateVaccineStatus` (Cloud Function, `southamerica-east1`) confere `request.auth`, `veterinarianId === uid` e `status === 'pending'` antes de validar. É o jeito certo — não confia no cliente.
- **Notificação ao tutor** na validação (subcoleção `users/{uid}/notifications`).
- **Prontuário por animal** com consultas, evolução de peso (gráfico) e histórico de vacinas/vermífugos — boa base clínica e boa UX.
- **Snapshots clínicos** nos registros de vacina (nome/peso/clínica no momento da aplicação) — conceitualmente correto para um registro que precisa refletir o estado **na data do ato**.
- **Segurança com deny-by-default** nas regras e acesso por papel (veterinário/tutor) após o onboarding.

---

## 3. Problemas e lacunas (sistema, fluxo e UX)

### 🔴 P1 — Não há registro de vacina/vermífugo pelo veterinário
**Problema:** a tela de Vacinas só **lista e valida**. `createVaccine` (com upload de imagem e EXIF strip) existe em `src/services/firebase/vaccineService.js`, mas só é referenciada por `src/controllers/VaccineController.js`, que **não é importado em lugar nenhum**. Não há botão "Nova vacina" no fluxo do vet.
**Impacto:** o sistema depende de uma origem externa de dados (app do tutor?) que não está neste repositório. Para o propósito "controle das vacinas aplicadas", **falta a entrada do dado** dentro da ferramenta do veterinário.
**Solução:**
- Decidir e **documentar a origem** do registro: (a) o vet registra a aplicação que fez, ou (b) o tutor envia e o vet valida. Para uma ferramenta de vet, o mais natural é **o vet registrar a aplicação** (cobre "apliquei e quero comprovar") e, opcionalmente, validar envios de tutor.
- **Conectar `createVaccine`** a um formulário "Nova vacina" (reaproveitando o upload com EXIF strip já pronto) e replicar para vermífugo.
- Se o registro nasce no vet, pode já entrar como `vetApproved` (auto-validado pelo CRMV de quem aplicou), eliminando uma etapa.

### 🔴 P2 — Vermífugo sem fluxo
**Problema:** `deworming` existe no schema e no seed e aparece **somente-leitura** no prontuário. Não há cadastro, validação, alerta de próxima dose nem página dedicada. A tela "Vacinas" é exclusivamente de vacinas.
**Impacto:** metade do propósito declarado ("validar vacinas **e** vermífugos") não é atendida.
**Solução:**
- Tratar vacina e vermífugo como **dois tipos do mesmo conceito** ("aplicações com próxima dose") e reusar a mesma tela/fluxo/validação, alternando por um filtro de tipo. Mantém o sistema enxuto e evita telas duplicadas.
- Incluir vermífugo nos **alertas de vencimento** e na ciência do tutor.

### 🔴 P3 — Inconsistência em `validationDetails` quebra a exibição
**Problema:** a Cloud Function grava `validationDetails.vetValidation.{status,validatedAt,...}` e define status `vetApproved`/`vetRejected`. Já o `VaccineDetailsModal`:
- exibe o bloco "Informações de Validação" apenas quando `status === 'approved' || 'rejected'` → **nunca aparece** para um registro validado pelo vet (que fica `vetApproved`);
- lê campos **planos** (`validationDetails.validatedAt`, `.notes`, `.rejectionReason`) que **não existem** (o dado está em `validationDetails.vetValidation.*`).
**Impacto:** após validar, **o veterinário não enxerga o registro da própria validação** (data, observações, motivo). Quebra a rastreabilidade visível e gera desconfiança.
**Solução:** padronizar **uma** forma (recomendo a aninhada da função) e ajustar o modal para ler `validationDetails.vetValidation.*` e mostrar o bloco para os estados `vetApproved/vetRejected/approved/rejected`. Ver também P4 (simplificar a máquina de estados).

### 🟠 P4 — Máquina de estados de validação complexa demais para o escopo
**Problema:** 7 status (`pending, vetApproved, vetRejected, tutorApproved, tutorRejected, approved, rejected`) + validação em duas partes (vet **e** tutor). Cada parte do código interpreta de um jeito (a tabela de Vacinas mapeia ~4 status; o modal usa outro subconjunto; o tutor escreve `tutorValidation`).
**Impacto:** complexidade, bugs (P3), e fricção numa ferramenta que se quer "enxuta".
**Solução:** definir um fluxo único e mínimo:
- `pending` → aguardando o veterinário;
- `approved` / `rejected` → decisão do veterinário (com `validatedBy`, `validatedAt`, `crmv`, `notes`/`rejectionReason`).
- A confirmação do tutor, se desejada, vira **campo de "ciência do tutor"** (booleano + data), **não** um segundo eixo de status. Preserva a comprovação sem multiplicar estados.

### 🟠 P5 — Código morto / fluxos fantasma poluindo o sistema
**Problema/Impacto:** confunde manutenção e sugere funcionalidades inexistentes:
- `vaccineService.js` + `controllers/VaccineController.js` — **órfãos**.
- `VaccineEditModal` e `VaccineDeleteModal` — montados em `Vacinas.jsx` com `onSave={() => {}}` / `onDelete={() => {}}` (**no-op**) e nunca abertos.
- `VacinaInfo.jsx` / `VacinasTable.jsx` — aparentam estar **órfãos** (a `Vacinas.jsx` tem tabela própria inline). **Confirmar e remover.**
- `CompleteProfile.jsx` (versão antiga, Tailwind teal) — substituída pelo modal de onboarding; não é mais importada.
**Solução:** remover o que é morto; ao reconectar criar/editar/excluir (P1), fazê-lo por **um** caminho (um service usado de fato) em vez de manter camadas duplicadas (service + controller + modais).

### 🟠 P6 — "Assinar com GOVBR" é um botão sem ação
**Problema:** no modal de validação há um botão **"Assinar com GOVBR"** sem `onClick`.
**Impacto:** promete assinatura digital (com peso legal) que não existe — expectativa falsa e ruído.
**Solução:** **remover** (recomendado para o MVP) ou implementar de fato como etapa opcional de comprovação. Não deixar placeholder de algo com conotação legal.

### 🟠 P7 — Inconsistência visual: o coração do produto está fora do design system
**Problema:** as telas centrais de **validação** (`VaccineDetailsModal`) e os modais de editar/excluir usam Tailwind antigo (cinza/azul, `bg-gray-50`), destoando do design system "Apple/iOS" (tokens `--apple-*`, cards `--surface-grouped-secondary`) adotado em Dashboard, Pacientes, Prontuário, etc.
**Impacto:** a tela mais importante do propósito é a menos polida e a mais inconsistente.
**Solução:** repaginar o modal de detalhes/validação com os mesmos tokens e padrões já existentes.

### 🟡 P8 — Falta uma "agenda de vencimentos" acionável
**Problema:** há `nextDueDate` por registro e o Dashboard conta "vacinas em 30 dias" e "vermífugos vencidos", mas **não há uma lista/visão dedicada** de "quais animais estão com dose vencida/a vencer" — a pergunta que o vet mais faz nesse tipo de ferramenta.
**Impacto:** o valor de "alerta de vencimento" fica subutilizado.
**Solução:** uma visão "Vencimentos" (vacinas + vermífugos), filtrável por período (vencidos / próximos 30/60/90 dias), reaproveitando os dados existentes. Em escala, ver B6.

### 🟡 P9 — Registro clínico sem trilha de auditoria / exclusão física
**Problema:** registros podem ser **apagados fisicamente** (`deleteVaccine` → `deleteDoc`) e atualizados livremente; não há versionamento nem "quem alterou o quê e quando".
**Impacto:** perda de histórico clínico e ausência de rastreabilidade — grave para um registro que serve de comprovação. (Detalhes e solução em B2/B4.)

### 🔵 P10 — Pequenas fricções de UX
- Não há **comprovante/carteira de vacinação imprimível ou compartilhável** (PDF/link) — algo que tutor e vet esperam para "comprovação". Forte candidato **dentro do escopo**.
- O `Header` tem busca global decorativa sem função e sino de notificações "em desenvolvimento" (apesar de a Cloud Function já gravar notificações reais).
- A validação exige reabrir item a item; uma ação de aprovar/rejeitar direto na lista agilizaria o dia a dia.

---

## 4. Auditoria do Banco de Dados (Firebase/Firestore)

> Avaliação sob a ótica de **confiabilidade e auditabilidade do registro clínico**. Coleções: `users` (+ subcoleções `consultas`, `pesos` em `pets`, e `notifications` em `users`), `pets`, `vaccines`, `deworming`, `clinics`, `appointments`, `conversas/mensagens`, `otpCodes`.

### Visão geral
O desenho central é adequado: entidades separadas para usuário, pet, vacina, vermífugo e clínica, com **snapshots** dos dados clínicos no momento do ato. Os problemas estão em **consistência de tipos, integridade referencial, imutabilidade e consultabilidade** — não na ideia geral.

### 🔴 B1 — Tipos de data misturados (string ISO × Timestamp)
**Problema:** o signup e o onboarding gravam `createdAt`/`updatedAt` como **string ISO** (`new Date().toISOString()`), enquanto o seed e as Cloud Functions usam **`Timestamp`** (`serverTimestamp()`). O mesmo campo tem **tipos diferentes** conforme a origem.
**Impacto:** `orderBy`/comparações de data ficam **incorretas ou imprevisíveis** (string e Timestamp não ordenam juntos); o código de leitura precisa de heurísticas frágeis (`toDate?`, `seconds?`, `typeof === 'string'`) espalhadas por toda parte.
**Solução:** padronizar **tudo em `Timestamp`** (`serverTimestamp()`); rodar um *migration script* para converter os valores em string já gravados; centralizar a conversão de leitura num único helper.

### 🔴 B2 — Exclusão física e mutabilidade de registro clínico
**Problema:** vacinas podem ser `deleteDoc` (hard delete) e atualizadas sem restrição de campos; não há "congelamento" após validação. (No Storage, a imagem do rótulo também não é removida ao excluir — lixo + inconsistência.)
**Impacto:** perda irreversível de histórico e possibilidade de alterar um registro já validado — inaceitável para comprovação clínica.
**Solução:**
- **Exclusão lógica** (`active: false` / `deletedAt`, `deletedBy`) em vez de apagar.
- **Imutabilidade pós-validação:** uma vez `approved/rejected`, bloquear edição dos campos clínicos (correção só via novo registro/anexo). Aplicar nas **regras** e na **Cloud Function**.

### 🔴 B3 — Regras permitem o tutor sobrescrever a validação do veterinário
**Problema:** a regra de `vaccines` permite `update` se o usuário for **vet OU dono**, **sem restringir quais campos**. Um tutor (dono) pode, via cliente, escrever `status: 'approved'` ou alterar `validationDetails.vetValidation`.
**Impacto:** a autoridade do veterinário (e do CRMV) pode ser forjada pelo cliente — fura toda a confiabilidade da validação.
**Solução:**
- Restringir o `update` do cliente aos campos que cada papel pode tocar (tutor só "ciência"/`tutorValidation`; nunca `status` nem `vetValidation`).
- Idealmente, **toda mudança de status passa só por Cloud Function** (como já ocorre na aprovação do vet) e o `update` direto de `status` fica **negado** nas regras.

### 🟠 B4 — Ausência de trilha de auditoria
**Problema:** não há registro de **quem criou/alterou** cada documento clínico além do estado final. (Inclusive `pets.createdBy`, do qual as regras dependem, nem sempre é gravado.)
**Impacto:** impossível auditar o histórico de mudanças — exigência típica de prontuário.
**Solução:** campos mínimos `createdBy`, `updatedBy`, `updatedAt` consistentes em **todos** os registros clínicos; bloco de validação **imutável** (`validatedBy`, `validatedAt`, `crmv`). Para histórico completo, considerar subcoleção `audit` (append-only) por registro.

### 🟠 B5 — Redundância de vínculos que pode dessincronizar
**Problema:**
- `pets.vaccines: [ids]` **e** `vaccines.petId` — duplo vínculo; criar uma vacina não atualiza `pets.vaccines` → listas divergentes.
- `pets.ownerId` **e** `pets.tutorId` apontando para o mesmo tutor — campo redundante.
- Vet↔clínica: `users.clinicId` (um) **e** `clinics.veterinarians[]` (vários) — duas fontes de verdade. Além disso, **pets não têm vínculo com clínica** (a vacina guarda `clinicName` como texto, sem `clinicId`).
**Impacto:** dados podem divergir; consultas baseadas no campo "errado" retornam resultado incompleto.
**Solução:** eleger **uma** fonte de verdade por relação:
- vacina↔pet: **`vaccines.petId`** como verdade; `pets.vaccines[]` derivado (ou removido).
- tutor↔pet: **`ownerId`**; aposentar `tutorId`.
- vet↔clínica: **`clinics.veterinarians[]`** (suporta múltiplas) e derivar/remover `users.clinicId`; se relevante, registrar `clinicId` na vacina.

### 🟠 B6 — Consultabilidade de "vencimentos" e organização vacina/vermífugo
**Problema:**
- "Quais animais estão com vacina/vermífugo vencido?" hoje exige **baixar tudo e filtrar em memória** (Dashboard) — não escala e não tem índice.
- Vacinas/vermífugos são **coleções top-level** com `petId`, enquanto `consultas`/`pesos` são **subcoleções** de `pets`. Inconsistência de organização (trade-off conhecido, vale documentar).
**Impacto:** alertas de vencimento ficam caros/limitados; o histórico do animal se espalha por dois padrões.
**Solução:**
- Garantir índices compostos para `where(veterinarianId==) + where(nextDueDate <=)` com ordenação por `nextDueDate`.
- Padronizar a posição: para um software de **vet** (visão por profissional), top-level por `petId`+`veterinarianId` tende a ser melhor para consultas globais; manter `consultas/pesos` coerentes com a escolha.

### 🟡 B7 — `validationDetails` com formato divergente entre origens
**Problema:** a Cloud Function grava **aninhado** (`vetValidation`), o `vaccineService.updateVaccineStatus` (morto) grava **plano**, e o front lê os dois jeitos. (Mesma raiz do P3.)
**Impacto:** dados gravados por caminhos diferentes ficam incompatíveis; leituras quebram.
**Solução:** um **único contrato** de `validationDetails` (recomendo o aninhado) documentado em `schema.js`, e remover o caminho morto que grava plano.

### 🟡 B8 — Vocabulário livre para vacina/fabricante/lote
**Problema:** `name`, `manufacturer`, `batchNumber` são texto livre. "V10" vs "V10 Polivalente" viram registros distintos.
**Impacto:** relatórios/buscas por tipo de vacina ficam sujos; dificulta protocolos por espécie.
**Solução:** um **catálogo controlado** simples (`vaccineCatalog`/`dewormerCatalog` com nome canônico, fabricante, espécie-alvo, intervalo padrão de reforço). O reforço padrão **pré-preenche `nextDueDate`** — ganho direto de usabilidade clínica.

### 🟡 B9 — Campos clínicos: bom, com pequenos reforços
**Avaliação:** o registro de vacina já cobre o essencial de um registro confiável: **fabricante, lote, validade (`expirationDate`), data de aplicação, próxima dose (`nextDueDate`), responsável (vet + CRMV), clínica e comprovação por foto+GPS** — acima da média. Reforços:
- **`route`/`applicationSite`** (via/local de administração) e **`dose`**.
- **Validação por espécie** (liga ao B8).
- Em `deworming`, alinhar os mesmos campos de comprovação que a vacina tem (foto/lote/validade), hoje mais pobres.

### 🔵 B10 — Pontos menores
- `appointments` existe no schema/seed e nas regras, mas **sem UI** no escopo — decidir se entra (agenda simples) ou sai.
- Snapshots clínicos (nome/peso/clínica na vacina) são **corretos** como ponto-no-tempo; documentar explicitamente que **não são fonte de verdade** do cadastro atual do pet, para ninguém "corrigir" um registro histórico por engano.
- Notificações já são gravadas pela Cloud Function, mas **nenhum hook as lê** — implementar o painel (liga ao P10) ou remover a escrita.

---

## 5. Recomendações de fluxo e experiência (alinhadas ao escopo)

1. **Fechar o ciclo do registro.** Fluxo-alvo do veterinário: *Paciente → Nova aplicação (vacina **ou** vermífugo) → foto do rótulo (EXIF strip + GPS) → dados (tipo, lote, validade, próxima dose) → salva já validada pelo CRMV de quem aplicou.* Reaproveita `createVaccine`/upload já prontos.
2. **Unificar vacina e vermífugo** numa única experiência "Aplicações", com filtro por tipo — mantém o sistema enxuto e cobre 100% do propósito.
3. **Validação em 1 clique na lista** (aprovar/rejeitar sem abrir o item) para envios pendentes, mantendo o modal para detalhes/comprovação.
4. **Visão "Vencimentos"** (vacinas + vermífugos) por período — transforma o `nextDueDate` em valor diário para o vet.
5. **Carteira de vacinação/vermifugação compartilhável (PDF/link).** Alto valor de "comprovação", dentro do escopo, e fecha o ciclo para o tutor.
6. **Repaginar o modal de validação** no design system atual (P7) — é a tela-âncora do produto.
7. **Remover ruído fora de escopo:** botão GOVBR placeholder, busca decorativa do header, e o código morto (service/controller/modais no-op/tela antiga).

---

## 6. Plano priorizado

### Quick wins (baixo esforço, alto retorno)
- 🔴 P3/B7 — Corrigir o `validationDetails` (aninhado) e a exibição do modal.
- 🟠 P5 — Remover código morto (service/controller órfãos, modais no-op, telas órfãs após confirmação).
- 🟠 P6 — Remover/implementar de fato o botão GOVBR.
- 🟡 P7 — Repaginar o modal de validação no design system.

### Estrutural (núcleo do propósito)
- 🔴 P1 — Conectar **cadastro** de vacina (formulário + `createVaccine` + upload).
- 🔴 P2 — Implementar **vermífugo** reutilizando o mesmo fluxo (tipo).
- 🟠 P4 — Simplificar a máquina de estados (1 eixo de status + "ciência do tutor").
- 🟡 P8 — Visão de vencimentos.

### Integridade de dados (confiabilidade do registro)
- 🔴 B1 — Padronizar datas em `Timestamp` (+ migração).
- 🔴 B2 — Exclusão lógica + imutabilidade pós-validação (+ limpar imagem no Storage).
- 🔴 B3 — Endurecer regras (tutor não altera status/validação do vet; status só via Cloud Function).
- 🟠 B4 — Trilha de auditoria mínima (`createdBy/updatedBy` + bloco de validação imutável).
- 🟠 B5 — Eleger fonte única de verdade por vínculo.
- 🟡 B6/B8/B9 — Índices de vencimento, catálogo controlado e campos clínicos (via/dose) + paridade do vermífugo.

---

## 7. Veredito

O produto está **no caminho certo e com um diferencial real de comprovação** (foto+GPS+validação no servidor). Para cumprir plenamente o que se propõe, o foco deve ser **fechar o ciclo registro→validação→comprovação para vacinas e vermífugos**, **simplificar/unificar a validação** e **blindar a integridade do registro clínico** (datas, imutabilidade, regras, fonte única de verdade). Nada disso exige sair do escopo enxuto — pelo contrário, várias ações são de **limpeza e consolidação** do que já existe.

---

*Relatório elaborado em 2026-06-23 sob a ótica de consultoria em software veterinário, com base na leitura do código (telas, hooks, services, Cloud Functions), do `schema.js`, do seed, das `firestore.rules` e do fluxo de validação. Auditoria técnica anterior preservada em `AUDITORIA_SISTEMA_2026-06-02_tecnica.md`.*
