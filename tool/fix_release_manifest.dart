import 'dart:convert';
import 'dart:io';

import 'release_config.dart';

/// Corrige o `gitCommit` do manifesto de uma release publicada com a árvore
/// suja.
///
/// Por que isto existe: o APK é empacotado a partir do DISCO, mas o manifesto
/// registra o HEAD do git. Publicando com mudanças não commitadas, o commit
/// gravado descreve MENOS do que o binário contém — e o guarda do `patch`, que
/// diffa contra ele, passa a acusar como "mudou desde a release" arquivos que
/// já estavam dentro dela. Foi o que aconteceu com 1.0.1+6: 41 arquivos
/// bloqueando um patch, todos já presentes no APK que o cliente instalou.
///
/// Depois de commitar essa árvore, o novo commit descreve exatamente o que foi
/// empacotado. Este script reaponta o manifesto para ele.
///
/// Uso:
///   dart run tool/fix_release_manifest.dart <tag> <commit>
///   dart run tool/fix_release_manifest.dart 1.0.1+6 HEAD
///
/// NÃO é uma publicação: não toca no canal do Firestore nem no APK. Nenhum
/// cliente baixa nada diferente por causa disto — o manifesto só é lido pelo
/// próprio `tool/release.dart`.
Future<void> main(List<String> args) async {
  if (args.length != 2) {
    stderr.writeln(
      'Uso: dart run tool/fix_release_manifest.dart <tag> <commit>\n'
      'Ex.: dart run tool/fix_release_manifest.dart 1.0.1+6 HEAD',
    );
    exit(64);
  }

  final tag = args[0];
  final commit = git(['rev-parse', args[1]]);
  if (commit == null) {
    stderr.writeln('Commit inválido: ${args[1]}');
    exit(1);
  }

  final objectName = '$kStorageFolder/$tag.json';
  final client = await authenticate();

  try {
    final raw = await downloadObjectAsString(client, objectName);
    if (raw == null) {
      stderr.writeln('Manifesto não encontrado: $objectName');
      exit(1);
    }

    final manifest = jsonDecode(raw) as Map<String, dynamic>;
    final before = manifest['gitCommit'];

    manifest['gitCommit'] = commit;
    // A release CONTINUA tendo sido publicada com a árvore suja. Manter a flag
    // preserva a rede de segurança: se ainda assim algo aparecer como
    // bloqueante, o guarda degrada para aviso e deixa o --dry-run do Shorebird
    // — que compara artefatos compilados, não caminhos — dar a palavra final.
    manifest['gitDirty'] = true;

    stdout.writeln(objectName);
    stdout.writeln('  gitCommit  ${before ?? "(ausente)"}');
    stdout.writeln('          -> $commit');
    stdout.writeln('  gitDirty   true');
    stdout.writeln('');

    if (!confirm('Gravar?')) {
      stdout.writeln('Cancelado.');
      return;
    }

    await uploadObject(
      client,
      objectName: objectName,
      bytes: utf8.encode(const JsonEncoder.withIndent('  ').convert(manifest)),
      contentType: 'application/json',
    );
    stdout.writeln('Manifesto atualizado.');
  } finally {
    client.close();
  }
}
