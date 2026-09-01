import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 'release_config.dart';

/// Publica um release Android: valida versão, builda, sobe o APK e aponta o
/// canal de versão para ele.
///
/// Uso:
///   dart run tool/release.dart                  publica a versão do pubspec
///   dart run tool/release.dart --list           lista releases publicados
///   dart run tool/release.dart --rollback 1.0.0+1
///   dart run tool/release.dart --min 12         define minSupportedBuildNumber
///   dart run tool/release.dart --skip-build     reaproveita o APK já gerado
///
/// A ORDEM importa: upload primeiro, canal depois, com confirmação no meio.
/// Um APK sobrando no Storage não afeta ninguém e pode ser substituído; um
/// canal apontando para versão quebrada chega no aparelho do cliente na hora.
Future<void> main(List<String> args) async {
  try {
    if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
      _printUsage();
      return;
    }
    final command = args.first;
    final rest = args.skip(1).toList();

    switch (command) {
      case 'release':
        await _publish(rest);
        break;
      case 'patch':
        await _patch(rest);
        break;
      case 'list':
        await _list();
        break;
      case 'rollback':
        if (rest.isEmpty) {
          throw StateError('rollback exige a versão, ex.: rollback 1.0.0+1');
        }
        await _rollback(rest.first);
        break;
      default:
        throw StateError('Comando desconhecido: "$command".\n'
            'Use: release | patch | list | rollback');
    }
  } on StateError catch (e) {
    stderr.writeln('\n${e.message}\n');
    exitCode = 1;
  }
}

void _printUsage() {
  stdout.writeln('''
Publicação Android — dois caminhos.

  dart run tool/release.dart release    APK NOVO (mudanca nativa, asset,
                                        permissao, plugin ou upgrade de Flutter)
  dart run tool/release.dart patch      CODE PUSH (so codigo Dart)
  dart run tool/release.dart list       releases publicados
  dart run tool/release.dart rollback TAG    aponta o canal para TAG

Opcoes de `release`:
  --skip-build     reaproveita o APK ja em build/
  --min N          define minSupportedBuildNumber (trava versoes anteriores)

Opcoes de `patch`:
  --force          publica mesmo com aviso de mudanca nativa/asset
  --release-version TAG   alvo do patch (padrao: a versao do pubspec)

Na duvida entre os dois: `patch` avisa e recusa quando a mudanca exige
`release`. O contrario nao e verdade — `release` sempre funciona.
''');
}

// ── Publicar ────────────────────────────────────────────────────────────────

Future<void> _publish(List<String> args) async {
  final version = ReleaseVersion.fromPubspec();
  stdout.writeln('\nVersão do pubspec: ${version.tag}\n');

  final client = await authenticate();
  try {
    // 1. Validação contra o que está PUBLICADO, não contra um arquivo local:
    // o canal é a verdade sobre o que o cliente já recebeu.
    final channel = await readChannel(client);
    final published = decodeField(channel, 'latestBuildNumber') as int?;
    if (published != null && version.buildNumber <= published) {
      throw StateError(
        'versionCode não subiu.\n'
        '  no pubspec.yaml  : ${version.buildNumber}\n'
        '  já publicado     : $published\n\n'
        'O Android recusa instalar por cima com versionCode menor ou igual.\n'
        'Suba o número depois do "+" em `version:` no pubspec.yaml.',
      );
    }
    stdout.writeln('Último publicado: ${published ?? "(nenhum)"} — ok\n');

    // 2. Build via Shorebird (ver _runShorebirdRelease)
    if (args.contains('--skip-build')) {
      stdout.writeln('--skip-build: usando o APK existente.\n');
    } else {
      await _runShorebirdRelease();
    }
    final apk = _findReleaseApk();

    // Confere que o APK gerado é mesmo a versão esperada — evita publicar um
    // binário antigo se o build falhou silenciosamente.
    await _assertApkMatches(apk, version);

    // 3. Checksum
    stdout.writeln('Calculando SHA-256...');
    final bytes = await apk.readAsBytes();
    final sha = sha256.convert(bytes).toString();
    stdout.writeln('  $sha\n');

    // 4. Changelog
    final changelog = _resolveChangelog(version);

    // 5. Upload (reversível)
    stdout.writeln('Enviando ${bytesToMb(bytes.length)} para '
        '${version.apkObjectName}...');
    await uploadObject(
      client,
      objectName: version.apkObjectName,
      bytes: bytes,
      contentType: 'application/vnd.android.package-archive',
    );

    final manifest = {
      'latestVersionName': version.versionName,
      'latestBuildNumber': version.buildNumber,
      'apkUrl': downloadUrl(version.apkObjectName),
      'apkSha256': sha,
      'apkSizeBytes': bytes.length,
      'changelog': changelog,
      'releasedAt': DateTime.now().toUtc().toIso8601String(),
      // Commit da release. O `patch` diffa contra ele para descobrir se algo
      // nativo ou de asset mudou desde então — sem isso não haveria como saber
      // o que o APK instalado já contém.
      if (currentCommit() != null) 'gitCommit': currentCommit(),
    };
    await uploadObject(
      client,
      objectName: version.manifestObjectName,
      bytes: utf8.encode(const JsonEncoder.withIndent('  ').convert(manifest)),
      contentType: 'application/json',
    );
    stdout.writeln('Upload concluído.\n');

    // 6. Resumo + confirmação ANTES de mexer no canal
    final minSupported = _resolveMinSupported(args, channel, version);
    _printSummary(version, sha, bytes.length, changelog, minSupported,
        published, manifest['apkUrl'] as String);

    if (!confirm('Publicar esta versão para os clientes?')) {
      stdout.writeln('\nCancelado. O APK ficou no Storage e pode ser '
          'republicado depois com --skip-build;\no canal NÃO foi alterado.\n');
      return;
    }

    await _writeChannelFrom(client, manifest, minSupported);

    // Só agora o portão do Gradle é atualizado: "publicado" significa que o
    // canal aponta para esta versão, não que o build passou.
    _recordGate(version.buildNumber);

    stdout.writeln('\nCanal atualizado. Clientes na ${published ?? "?"} ou '
        'anterior receberão o aviso.\n');
  } finally {
    client.close();
  }
}

/// `shorebird release android`, NAO `flutter build apk`.
///
/// So o APK produzido pelo Shorebird carrega o updater embutido — um APK feito
/// com `flutter build` nunca recebe patch, e o erro so apareceria meses depois,
/// quando o primeiro `patch` nao chegasse em ninguem.
///
/// APK universal, sem --split-per-abi: com distribuicao manual, tres APKs
/// significam escolher o certo por aparelho, e instalar a ABI errada da erro
/// generico dificil de diagnosticar a distancia.
Future<void> _runShorebirdRelease() async {
  stdout.writeln('Rodando shorebird release android --artifact=apk...');
  // `--artifact=apk` é obrigatório aqui: o padrão do Shorebird é `aab`, que
  // serve para a Play Store. Distribuindo o arquivo direto, o cliente precisa
  // de APK — um AAB não instala em aparelho nenhum.
  final code =
      await _runShorebird(['release', 'android', '--artifact=apk']);
  if (code != 0) {
    throw StateError('shorebird release falhou (código $code).');
  }
  stdout.writeln('');
}

/// APK de release, entre os dois caminhos que Shorebird e Flutter usam.
///
/// Devolve o MAIS RECENTE, não o primeiro encontrado: `flutter build apk`
/// deixa um artefato em `flutter-apk/` que sobrevive a builds seguintes, e
/// pegá-lo por ordem de lista faria o script publicar um binário velho. (O
/// `_assertApkMatches` ainda barra isso depois, mas errar aqui gasta um build
/// inteiro para descobrir.)
File _findReleaseApk() {
  const candidates = [
    'build/app/outputs/apk/release/app-release.apk',
    'build/app/outputs/flutter-apk/app-release.apk',
  ];
  final found = candidates.map(File.new).where((f) => f.existsSync()).toList();
  if (found.isEmpty) {
    throw StateError('APK de release não encontrado. Procurei em:\n  '
        '${candidates.join("\n  ")}\n\n'
        'Se o build gerou um .aab, faltou `--artifact=apk`.');
  }
  found.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
  return found.first;
}

/// Lê versionName/versionCode do APK e compara com o pubspec.
Future<void> _assertApkMatches(File apk, ReleaseVersion version) async {
  final aapt = _findAapt();
  if (aapt == null) {
    stdout.writeln('aapt não encontrado — pulando a conferência do APK.\n');
    return;
  }
  final res = await Process.run(aapt, ['dump', 'badging', apk.path]);
  final first = '${res.stdout}'.split('\n').first;
  final code = RegExp(r"versionCode='(\d+)'").firstMatch(first)?.group(1);
  final name = RegExp(r"versionName='([^']+)'").firstMatch(first)?.group(1);

  if (code != '${version.buildNumber}' || name != version.versionName) {
    throw StateError(
      'O APK gerado não bate com o pubspec:\n'
      '  APK     : $name+$code\n'
      '  pubspec : ${version.tag}\n'
      'Rode o build de novo (sem --skip-build).',
    );
  }
  stdout.writeln('APK confere com o pubspec: $name+$code\n');
}

String? _findAapt() {
  final home = Platform.environment['ANDROID_HOME'] ??
      '${Platform.environment['LOCALAPPDATA']}\\Android\\Sdk';
  final dir = Directory('$home/build-tools');
  if (!dir.existsSync()) return null;
  final versions = dir.listSync().whereType<Directory>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  if (versions.isEmpty) return null;
  final exe = Platform.isWindows ? 'aapt.exe' : 'aapt';
  final path = '${versions.last.path}${Platform.pathSeparator}$exe';
  return File(path).existsSync() ? path : null;
}

/// CHANGELOG.md se existir; senão pergunta.
String _resolveChangelog(ReleaseVersion version) {
  final file = File('CHANGELOG.md');
  if (file.existsSync()) {
    final entry = _extractChangelogSection(file.readAsStringSync(), version);
    if (entry != null && entry.trim().isNotEmpty) {
      stdout.writeln('Changelog lido do CHANGELOG.md:\n');
      stdout.writeln(entry.trim().split('\n').map((l) => '  $l').join('\n'));
      stdout.writeln('');
      return entry.trim();
    }
    stdout.writeln('CHANGELOG.md existe mas não tem seção para '
        '${version.versionName}.\n');
  }

  stdout.writeln('Descreva o que mudou (linha vazia termina):');
  final lines = <String>[];
  while (true) {
    final line = stdin.readLineSync();
    if (line == null || line.trim().isEmpty) break;
    lines.add(line);
  }
  if (lines.isEmpty) {
    throw StateError('Changelog vazio. O cliente vê esse texto no diálogo.');
  }
  return lines.join('\n');
}

/// Extrai a seção `## {versionName}` até o próximo cabeçalho de mesmo nível.
String? _extractChangelogSection(String content, ReleaseVersion version) {
  final lines = content.split('\n');
  var capturing = false;
  final out = <String>[];
  for (final line in lines) {
    final isHeading = line.trimLeft().startsWith('## ');
    if (isHeading) {
      if (capturing) break;
      capturing = line.contains(version.versionName);
      continue;
    }
    if (capturing) out.add(line);
  }
  return capturing || out.isNotEmpty ? out.join('\n') : null;
}

/// Mantém o valor atual salvo o `--min` explícito.
///
/// Subir isso trava o app de quem ainda não atualizou — não é decisão de
/// rotina, então nunca acontece por padrão.
int _resolveMinSupported(
    List<String> args, Map<String, dynamic>? channel, ReleaseVersion version) {
  final index = args.indexOf('--min');
  if (index != -1 && index + 1 < args.length) {
    final value = int.tryParse(args[index + 1]);
    if (value == null) throw StateError('--min exige um inteiro.');
    if (value > version.buildNumber) {
      throw StateError(
        '--min $value é maior que a versão publicada (${version.buildNumber}).\n'
        'Isso travaria o app inclusive para quem instalar esta release.',
      );
    }
    return value;
  }
  return (decodeField(channel, 'minSupportedBuildNumber') as int?) ?? 0;
}

void _printSummary(
  ReleaseVersion version,
  String sha,
  int size,
  String changelog,
  int minSupported,
  int? published,
  String url,
) {
  stdout.writeln('─' * 62);
  stdout.writeln('  RESUMO — nada foi anunciado ao cliente ainda');
  stdout.writeln('─' * 62);
  stdout.writeln('  versão            ${version.tag}');
  stdout.writeln('  publicada agora   ${published ?? "(primeira)"} -> '
      '${version.buildNumber}');
  stdout.writeln('  minSupported      $minSupported'
      '${minSupported > (published ?? 0) ? "   *** TRAVA versoes anteriores ***" : ""}');
  stdout.writeln('  tamanho           ${bytesToMb(size)}');
  stdout.writeln('  sha256            $sha');
  stdout.writeln('  arquivo           ${version.apkObjectName}');
  stdout.writeln('  url               $url');
  stdout.writeln('  changelog         ${changelog.split("\n").first}');
  if (changelog.contains('\n')) {
    for (final l in changelog.split('\n').skip(1)) {
      stdout.writeln('                    $l');
    }
  }
  stdout.writeln('─' * 62);
}

Future<void> _writeChannelFrom(
    dynamic client, Map<String, dynamic> manifest, int minSupported) async {
  await writeChannel(client, {
    'latestVersionName': stringValue(manifest['latestVersionName'] as String),
    'latestBuildNumber': integerValue(manifest['latestBuildNumber'] as int),
    'minSupportedBuildNumber': integerValue(minSupported),
    'apkUrl': stringValue(manifest['apkUrl'] as String),
    'apkSha256': stringValue(manifest['apkSha256'] as String),
    'apkSizeBytes': integerValue(manifest['apkSizeBytes'] as int),
    'changelog': stringValue(manifest['changelog'] as String),
    'releasedAt':
        timestampValue(DateTime.parse(manifest['releasedAt'] as String)),
  });
}

// ── Listar ──────────────────────────────────────────────────────────────────

Future<void> _list() async {
  final client = await authenticate();
  try {
    final manifests = await listReleaseManifests(client);
    final channel = await readChannel(client);
    final current = decodeField(channel, 'latestBuildNumber') as int?;

    if (manifests.isEmpty) {
      stdout.writeln('\nNenhum release publicado ainda.\n');
      return;
    }
    stdout.writeln('\nReleases no Storage:\n');
    for (final name in manifests) {
      final tag = name.split('/').last.replaceAll('.json', '');
      final raw = await downloadObjectAsString(client, name);
      final data = raw == null
          ? null
          : jsonDecode(raw) as Map<String, dynamic>;
      final build = data?['latestBuildNumber'];
      final marker = build == current ? '  <- canal aponta para esta' : '';
      stdout.writeln('  $tag'
          '${data != null ? "  (${bytesToMb(data["apkSizeBytes"] as int)})" : ""}'
          '$marker');
    }
    stdout.writeln('\nPara voltar: dart run tool/release.dart --rollback TAG\n');
  } finally {
    client.close();
  }
}

// ── Rollback ────────────────────────────────────────────────────────────────

/// Aponta o canal de volta para um release anterior.
///
/// Só mexe no canal: o APK antigo já está no Storage (por isso releases
/// anteriores nunca são apagadas). Não desinstala nada de ninguém — quem já
/// atualizou continua na versão nova, porque o Android não faz downgrade.
Future<void> _rollback(String tag) async {
  final client = await authenticate();
  try {
    final manifestName = '$kStorageFolder/$tag.json';
    final raw = await downloadObjectAsString(client, manifestName);
    if (raw == null) {
      throw StateError(
        'Não achei o manifesto de "$tag" ($manifestName).\n'
        'Veja o que existe com: dart run tool/release.dart --list',
      );
    }
    final manifest = jsonDecode(raw) as Map<String, dynamic>;

    final channel = await readChannel(client);
    final current = decodeField(channel, 'latestBuildNumber') as int?;
    final target = manifest['latestBuildNumber'] as int;
    final minSupported =
        (decodeField(channel, 'minSupportedBuildNumber') as int?) ?? 0;

    stdout.writeln('\n${'─' * 62}');
    stdout.writeln('  ROLLBACK');
    stdout.writeln('─' * 62);
    stdout.writeln('  canal hoje        $current');
    stdout.writeln('  voltar para       $target  ($tag)');
    stdout.writeln('  minSupported      $minSupported (inalterado)');
    stdout.writeln('  changelog         ${manifest["changelog"]}');
    stdout.writeln('─' * 62);

    if (minSupported > target) {
      stdout.writeln(
        '\nATENÇÃO: minSupportedBuildNumber ($minSupported) é maior que a\n'
        'versão de destino ($target). Quem instalar o rollback cairia direto\n'
        'no bloqueio de atualização obrigatória. Ajuste com --min antes.\n',
      );
      if (!confirm('Continuar mesmo assim?')) {
        stdout.writeln('\nCancelado.\n');
        return;
      }
    }

    if (!confirm('Apontar o canal de volta para $tag?')) {
      stdout.writeln('\nCancelado. Nada foi alterado.\n');
      return;
    }

    await _writeChannelFrom(client, manifest, minSupported);
    stdout.writeln('\nCanal apontando para $tag.\n'
        'Quem JÁ atualizou permanece na versão nova — o Android não faz\n'
        'downgrade automático. O rollback vale para quem ainda não atualizou.\n');
  } finally {
    client.close();
  }
}

// ── Patch (code push) ───────────────────────────────────────────────────────

/// Envia só código Dart para quem já tem o APK instalado.
///
/// Antes de chamar o Shorebird, faz a própria checagem contra o commit da
/// release: se algo nativo ou de asset mudou, avisa e RECUSA. O Shorebird
/// também detecta isso, mas depois de compilar — aqui o aviso vem em segundos
/// e diz exatamente quais arquivos são o problema.
Future<void> _patch(List<String> args) async {
  final version = ReleaseVersion.fromPubspec();
  final force = args.contains('--force');

  final targetIndex = args.indexOf('--release-version');
  final target = targetIndex != -1 && targetIndex + 1 < args.length
      ? args[targetIndex + 1]
      : version.versionName;

  stdout.writeln('\nPatch para a release $target\n');

  final client = await authenticate();
  Map<String, dynamic>? manifest;
  try {
    // O manifesto da release alvo carrega o commit em que ela foi gerada.
    final raw = await downloadObjectAsString(
        client, '$kStorageFolder/${version.tag}.json');
    if (raw != null) manifest = jsonDecode(raw) as Map<String, dynamic>;
  } finally {
    client.close();
  }

  final baseCommit = manifest?['gitCommit'] as String?;
  if (baseCommit == null) {
    stdout.writeln(
        'Sem commit registrado para ${version.tag} — não consigo comparar o\n'
        'que mudou desde a release. Seguindo direto para a checagem do\n'
        'Shorebird, que também detecta diffs nativos.\n');
  } else {
    final changed = changedFilesSince(baseCommit);
    final blocking = blockingChanges(changed);

    stdout.writeln('${changed.length} arquivo(s) alterado(s) desde a release '
        '(${baseCommit.substring(0, 8)}).');

    if (blocking.isNotEmpty) {
      stdout.writeln('\n${'─' * 62}');
      stdout.writeln('  ESTA MUDANÇA EXIGE RELEASE, NÃO PATCH');
      stdout.writeln('─' * 62);
      for (final f in blocking.take(20)) {
        stdout.writeln('  $f');
      }
      if (blocking.length > 20) {
        stdout.writeln('  ... e mais ${blocking.length - 20}');
      }
      stdout.writeln('─' * 62);
      stdout.writeln(
        'Patch carrega APENAS código Dart. Código nativo, assets, permissões\n'
        'e dependências fazem parte do APK e não são atualizados por patch.\n\n'
        'Use: dart run tool/release.dart release\n',
      );
      if (!force) {
        throw StateError('Abortado. (--force ignora este aviso, por sua conta.)');
      }
      stdout.writeln('--force: seguindo mesmo assim.\n');
    } else {
      stdout.writeln('Nenhuma mudança nativa ou de asset — patch é seguro.\n');
    }
  }

  // Dry-run do Shorebird: valida sem publicar. É a segunda rede de proteção,
  // e pega o que a minha checagem de caminhos não veria (ex.: um plugin que
  // trouxe código nativo novo sem alterar arquivo em android/).
  stdout.writeln('Validando com o Shorebird (dry-run)...\n');
  final dryRun = await _runShorebird(
      ['patch', 'android', '--release-version', target, '--dry-run']);
  if (dryRun != 0) {
    throw StateError(
        'O dry-run do Shorebird recusou este patch (código $dryRun).\n'
        'Leia a saída acima: normalmente é diff nativo ou de asset.');
  }

  stdout.writeln('\n${'─' * 62}');
  stdout.writeln('  Dry-run passou. O patch ainda NÃO foi publicado.');
  stdout.writeln('─' * 62);
  stdout.writeln('  release alvo   $target');
  stdout.writeln('  versão local   ${version.tag}');
  stdout.writeln('─' * 62);

  if (!confirm('Publicar o patch para os clientes?')) {
    stdout.writeln('\nCancelado. Nada foi enviado.\n');
    return;
  }

  final code =
      await _runShorebird(['patch', 'android', '--release-version', target]);
  if (code != 0) {
    throw StateError('shorebird patch falhou (código $code).');
  }
  stdout.writeln('\nPatch publicado. Os aparelhos aplicam na próxima abertura '
      'do app.\n'
      'O atualizador in-app (APK) segue valendo para mudanças nativas.\n');
}

Future<int> _runShorebird(List<String> args) async {
  final process = await Process.start(
    _shorebirdExecutable(),
    args,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}

/// Caminho do executável do Shorebird.
///
/// Não confia só no PATH: um terminal (ou processo pai) aberto ANTES da
/// instalação não enxerga a entrada nova, e o erro que aparece —
/// "'shorebird.bat' não é reconhecido" — parece instalação quebrada quando na
/// verdade é só herança de ambiente.
String _shorebirdExecutable() {
  final name = Platform.isWindows ? 'shorebird.bat' : 'shorebird';
  final home = Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ??
      '';
  final candidates = [
    if (home.isNotEmpty) '$home${Platform.pathSeparator}.shorebird'
        '${Platform.pathSeparator}bin${Platform.pathSeparator}$name',
  ];
  for (final path in candidates) {
    if (File(path).existsSync()) return path;
  }
  // Cai no PATH: em CI o Shorebird costuma estar em outro lugar.
  return name;
}

/// Grava o versionCode publicado no portão do Gradle.
///
/// Chamado só depois de o canal apontar para esta versão. O Gradle usa esse
/// arquivo para recusar um build de release que não subiu a versão; se ele
/// fosse escrito no fim do build, "buildado" e "publicado" virariam sinônimos
/// e um upload que falhasse deixaria o portão bloqueando à toa.
void _recordGate(int buildNumber) {
  final file = File('android/last_release_version_code.txt');
  try {
    file.writeAsStringSync('$buildNumber\n');
    stdout.writeln('Portão do Gradle atualizado para $buildNumber '
        '(${file.path}) — faça commit desse arquivo.');
  } catch (e) {
    // Não é motivo para falhar: a publicação já aconteceu.
    stdout.writeln('Aviso: não consegui atualizar ${file.path}: $e');
  }
}
