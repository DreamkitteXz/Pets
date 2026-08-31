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
    if (args.contains('--help') || args.contains('-h')) {
      _printUsage();
      return;
    }
    if (args.contains('--list')) {
      await _list();
      return;
    }
    final rollbackIndex = args.indexOf('--rollback');
    if (rollbackIndex != -1) {
      if (rollbackIndex + 1 >= args.length) {
        throw StateError('--rollback exige a versão, ex.: --rollback 1.0.0+1');
      }
      await _rollback(args[rollbackIndex + 1]);
      return;
    }
    await _publish(args);
  } on StateError catch (e) {
    stderr.writeln('\n${e.message}\n');
    exitCode = 1;
  }
}

void _printUsage() {
  stdout.writeln('''
Publicação de release Android.

  dart run tool/release.dart                 publica a versão do pubspec.yaml
  dart run tool/release.dart --list          lista os releases publicados
  dart run tool/release.dart --rollback TAG  aponta o canal para TAG (ex 1.0.0+1)
  dart run tool/release.dart --min N         define minSupportedBuildNumber
  dart run tool/release.dart --skip-build    usa o APK já em build/
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

    // 2. Build
    final apk = File('build/app/outputs/flutter-apk/app-release.apk');
    if (args.contains('--skip-build')) {
      if (!apk.existsSync()) {
        throw StateError('--skip-build mas não há APK em ${apk.path}');
      }
      stdout.writeln('--skip-build: usando o APK existente.\n');
    } else {
      await _runFlutterBuild();
    }
    if (!apk.existsSync()) {
      throw StateError('Build terminou mas o APK não apareceu em ${apk.path}');
    }

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
    stdout.writeln('\nCanal atualizado. Clientes na ${published ?? "?"} ou '
        'anterior receberão o aviso.\n');
  } finally {
    client.close();
  }
}

Future<void> _runFlutterBuild() async {
  // APK universal, NÃO --split-per-abi. Ver a justificativa no README do tool.
  stdout.writeln('Rodando flutter build apk --release...');
  final process = await Process.start(
    Platform.isWindows ? 'flutter.bat' : 'flutter',
    ['build', 'apk', '--release'],
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  final code = await process.exitCode;
  if (code != 0) {
    throw StateError('flutter build falhou (código $code).');
  }
  stdout.writeln('');
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
