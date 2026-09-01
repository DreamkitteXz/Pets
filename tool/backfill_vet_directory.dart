import 'dart:convert';
import 'dart:io';

import 'release_config.dart';

/// Popula `vet_directory` a partir dos veterinários já existentes em `users`.
///
/// Por que é necessário: a Function `mirrorVetDirectory` é um trigger de
/// ESCRITA em `users/{uid}`. Ela mantém o diretório em dia daqui para frente,
/// mas não enxerga quem já estava cadastrado antes do deploy — esses
/// documentos não serão reescritos tão cedo, e até lá o veterinário não
/// apareceria no app.
///
/// Roda uma vez, depois do deploy da Function. É idempotente: rodar de novo
/// apenas reescreve os mesmos valores.
///
/// Uso:
///   dart run tool/backfill_vet_directory.dart          (mostra e confirma)
///   dart run tool/backfill_vet_directory.dart --dry-run
///
/// Precisa da service account (tool/service-account.json) porque a rule de
/// `vet_directory` nega escrita a TODO cliente — de propósito: quem pudesse
/// escrever ali publicaria um CRMV falso e apareceria como veterinário.

/// Espelha VET_PUBLIC_FIELDS da Function. Mantenha os dois lados iguais: um
/// campo que só exista aqui some no primeiro update de perfil, e um que só
/// exista lá nunca chega para quem foi criado antes do deploy.
const List<String> kVetPublicFields = [
  'name',
  'crmv',
  'specialties',
  'yearsOfExperience',
];

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final client = await authenticate();

  try {
    const url = 'https://firestore.googleapis.com/v1/projects/$kProjectId'
        '/databases/(default)/documents/users?pageSize=300';
    final res = await client.get(Uri.parse(url));
    if (res.statusCode != 200) {
      stderr.writeln('Falha ao ler users (HTTP ${res.statusCode}).');
      exit(1);
    }

    final docs = (jsonDecode(res.body)['documents'] as List?) ?? const [];
    final elegiveis = <String, Map<String, dynamic>>{};

    for (final doc in docs) {
      final fields = (doc['fields'] as Map?)?.cast<String, dynamic>() ?? {};
      String? str(String k) => fields[k]?['stringValue'] as String?;

      // Mesmas condições da Function: vet, ativo e com CRMV. Listar um vet sem
      // CRMV daria ao tutor uma escolha que a validação depois recusaria.
      if (str('role') != 'veterinarian') continue;
      if (str('status') != 'active') continue;
      if ((str('crmv') ?? '').isEmpty) continue;

      final uid = '${doc['name']}'.split('/').last;
      final projection = <String, dynamic>{
        'uid': stringValue(uid),
      };
      for (final f in kVetPublicFields) {
        if (fields[f] != null) projection[f] = fields[f];
      }
      elegiveis[uid] = projection;
    }

    if (elegiveis.isEmpty) {
      stdout.writeln('Nenhum veterinário elegível encontrado.');
      return;
    }

    stdout.writeln('${elegiveis.length} veterinário(s) para publicar:\n');
    elegiveis.forEach((uid, p) {
      final nome = p['name']?['stringValue'] ?? '(sem nome)';
      final crmv = p['crmv']?['stringValue'] ?? '—';
      stdout.writeln('  ${uid.substring(0, 8)}…  $nome  ($crmv)');
    });
    stdout.writeln('');

    if (dryRun) {
      stdout.writeln('--dry-run: nada foi gravado.');
      return;
    }
    if (!confirm('Gravar em vet_directory?')) {
      stdout.writeln('Cancelado.');
      return;
    }

    for (final entry in elegiveis.entries) {
      final fields = Map<String, dynamic>.from(entry.value)
        ..['updatedAt'] = timestampValue(DateTime.now());
      // updateMask com os campos enviados: sem ele o PATCH apagaria o que o
      // script não conhece.
      final mask =
          fields.keys.map((k) => 'updateMask.fieldPaths=$k').join('&');
      final docUrl =
          'https://firestore.googleapis.com/v1/projects/$kProjectId'
          '/databases/(default)/documents/vet_directory/${entry.key}?$mask';

      final r = await client.patch(
        Uri.parse(docUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fields': fields}),
      );
      if (r.statusCode != 200) {
        stderr.writeln('  FALHOU ${entry.key}: HTTP ${r.statusCode} ${r.body}');
      } else {
        stdout.writeln('  ok ${entry.key}');
      }
    }
    stdout.writeln('\nPronto.');
  } finally {
    client.close();
  }
}
