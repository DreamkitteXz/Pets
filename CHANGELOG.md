# Changelog

O texto de cada seção vai para o diálogo de atualização no aparelho do tutor —
`tool/release.dart` lê a seção que bate com o `versionName` do `pubspec.yaml`.
Escreva pensando em quem vai ler no celular, não em quem escreveu o código.

Formato: `## {versionName}` e, abaixo, o que mudou.

## 1.1.0

Correções no cadastro de pet e nos registros de vacina e medicamento.

- Endereço no cadastro: o CEP agora preenche rua, bairro, cidade e estado
  sozinho. Estado virou lista de UF e o campo Cidade, que não existia, foi
  adicionado.
- Raças: incluída a opção SRD (sem raça definida) e a lista agora vem em
  ordem alfabética.
- Data de nascimento: o calendário abria no ano passado, então um filhote
  nascido hoje aparecia com 1 ano.
- Gato cadastrado aparecia com ilustração de cachorro.
- O aviso "cadastre um pet antes" ficava por cima do botão de confirmar e
  travava a tela.
- Peso: vírgula é aceita em todas as telas. No vermífugo, "10,5" era salvo
  como 0.
- Vacina: a farmacêutica não vem mais preenchida sozinha, e a data de
  validade abre em hoje em vez de um ano à frente.
- Vacina: os campos da clínica só aparecem depois de escolher uma.
- Medicamento: o campo de nome não sugere mais uma marca.
- Nome do responsável aparece com inicial maiúscula.

## 1.0.1

- Registro de medicamentos do pet
- Foto do pet e correção no envio da foto do rótulo de vacina
- Histórico de peso unificado com o site
- Correções no login e no cadastro

## 1.0.0

- Primeira versão distribuída fora da Play Store
