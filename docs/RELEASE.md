# Como publicar uma atualização

Escrito para ser seguido sem lembrar de nada. Se você só quer a resposta
rápida: **na dúvida, use `release`.** Ele sempre funciona; `patch` é o atalho
que às vezes não serve.

---

## Decidir: patch ou release?

| Você mexeu em... | Caminho |
|---|---|
| Só arquivos `.dart` dentro de `lib/` | **patch** |
| Qualquer coisa em `android/` (Kotlin, manifest, Gradle) | release |
| Permissão nova no `AndroidManifest.xml` | release |
| Imagem, fonte ou qualquer asset (`assets/`, `lib/assets/`) | release |
| `pubspec.yaml` — dependência nova ou versão de plugin | release |
| Ícone do app ou splash | release |
| Nome ou `applicationId` do app | release |
| Versão do Flutter | release |
| Subiu `version:` no `pubspec.yaml` | release |

**Não precisa decorar.** Rode `patch`: se a mudança exigir release, ele recusa
e diz quais arquivos são o problema. A checagem é dupla — o script compara com
o commit da última release, e o Shorebird valida de novo antes de publicar.

---

## Caminho A — patch (só código Dart)

Chega no aparelho na próxima vez que o app abrir. Não gera APK, não precisa de
Storage, o cliente não instala nada.

```
cd C:\kayque\pets
dart run tool/release.dart patch
```

O que acontece:

1. Compara o código atual com o commit da última release
2. Se algo nativo ou de asset mudou → **para aqui** e lista os arquivos
3. Roda o dry-run do Shorebird (valida sem publicar)
4. Mostra o resumo e **espera sua confirmação**
5. Publica

**Não suba `version:` no pubspec para um patch.** O patch se prende à release
que já está instalada; mudar a versão faz ele procurar uma release que não
existe.

---

## Caminho B — release (APK novo)

Gera APK, sobe para o Storage e aponta o canal de versão. O cliente recebe o
diálogo de atualização dentro do app, baixa e instala.

### 1. Suba a versão no `pubspec.yaml`

```yaml
version: 1.0.2+3
```

O número depois do `+` é o que decide tudo. **Sempre para cima**, nunca repete.
O Android recusa instalar por cima com número menor ou igual.

### 2. Escreva o changelog

Em `CHANGELOG.md`, uma seção com o mesmo `versionName`:

```markdown
## 1.0.2

- O que mudou, em português, para quem vai ler no celular
```

Se esquecer, o script pergunta no terminal.

### 3. Publique

```
cd C:\kayque\pets
dart run tool/release.dart release
```

O que acontece:

1. Confere que o buildNumber subiu em relação ao **que está publicado**
2. `shorebird release android` (não `flutter build` — veja "Por quê" abaixo)
3. Confere que o APK gerado é mesmo a versão do pubspec
4. Calcula o SHA-256
5. Sobe APK + manifesto para `releases/android/`
6. **Mostra o resumo e espera sua confirmação**
7. Só então aponta o canal

Cancelar no passo 6 é seguro: o APK fica no Storage e o canal não muda. Para
retomar sem recompilar: `dart run tool/release.dart release --skip-build`.

---

## Atualização obrigatória (trava o app)

Só quando a versão antiga **quebra de verdade** — por exemplo, você mudou a
estrutura do Firestore e a versão antiga passaria a gravar dado inconsistente.

```
dart run tool/release.dart release --min 3
```

Todo mundo abaixo do build 3 fica travado num diálogo sem saída até atualizar.

Por padrão o script **mantém** o valor anterior. Não suba esse número por
hábito: quem estiver numa versão antiga perde o acesso ao app na hora.

---

## Se der errado: rollback

```
dart run tool/release.dart list
dart run tool/release.dart rollback 1.0.1+2
```

Aponta o canal de volta. Funciona porque cada release deixa um manifesto
`.json` ao lado do APK, e releases antigas nunca são apagadas.

**Limite importante:** quem **já atualizou** continua na versão nova. O Android
não faz downgrade. O rollback protege quem ainda não atualizou — se a versão
quebrada já chegou em todo mundo, o caminho é publicar uma correção, não voltar.

---

## Pré-requisitos (uma vez só)

**Keystore** — `C:\Users\eduar\keystores\pet-app-release.jks`, com as senhas em
`android/key.properties`. Perder isso significa nunca mais conseguir atualizar
os APKs instalados. Há uma cópia no Drive; as senhas ficam separadas dela.

**Service account** — `tool/service-account.json`, baixado em Firebase Console →
Configurações do projeto → Contas de serviço. Nenhum dos dois vai para o git.

**Shorebird** — `shorebird login`. As credenciais ficam em
`%APPDATA%\shorebird\credentials.json`.

Se algo não funcionar, comece por:

```
shorebird doctor
```

---

## Por quê algumas escolhas

**`shorebird release android` em vez de `flutter build apk`** — só o APK feito
pelo Shorebird carrega o updater embutido. Um APK gerado com `flutter build`
nunca recebe patch, e você só descobriria meses depois, quando o primeiro
patch não chegasse em ninguém.

**APK universal, sem `--split-per-abi`** — dividir por ABI economizaria uns
47 MB, mas criaria três APKs e alguém teria que escolher o certo para cada
aparelho. Instalar a ABI errada dá erro genérico, difícil de diagnosticar à
distância. Não compensa numa transferência que acontece uma vez por release.

**Upload antes do canal, com confirmação no meio** — um APK sobrando no
Storage não afeta ninguém e pode ser substituído. Um canal apontando para
versão quebrada chega no aparelho do cliente na hora seguinte.

**Os dois sistemas convivem** — Shorebird entrega código Dart; o atualizador
in-app entrega APK. Nenhum substitui o outro, e o `patch` recusa o que só o
`release` resolve.
