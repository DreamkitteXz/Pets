import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

/// Constantes e utilidades compartilhadas por `release.dart`.

const String kProjectId = 'pet-app-fccae';
const String kBucket = 'pet-app-fccae.appspot.com';

/// Pasta versionada no Storage. Releases anteriores FICAM: sem elas o rollback
/// não teria para onde voltar.
const String kStorageFolder = 'releases/android';

/// Documento do canal lido pelo app (`AppUpdateService`).
const String kConfigCollection = 'app_config';
const String kConfigDocument = 'android';

/// Escopos mínimos: escrever no Firestore e no Storage. Nada além disso — uma
/// credencial de publicação não deve poder ler dados de usuário.
const List<String> kScopes = [
  'https://www.googleapis.com/auth/datastore',
  'https://www.googleapis.com/auth/devstorage.read_write',
];

/// Onde procurar a chave da service account, em ordem.
///
/// NUNCA versionada: `tool/service-account.json` está no .gitignore. Em CI,
/// use a variável de ambiente apontando para um arquivo montado pelo runner.
List<String> serviceAccountCandidates() => [
      if (Platform.environment['PETS_SERVICE_ACCOUNT'] != null)
        Platform.environment['PETS_SERVICE_ACCOUNT']!,
      'tool/service-account.json',
    ];

class ReleaseVersion {
  final String versionName;
  final int buildNumber;

  const ReleaseVersion(this.versionName, this.buildNumber);

  /// `1.0.1+2` — mesmo formato do pubspec, usado no nome do arquivo.
  String get tag => '$versionName+$buildNumber';

  String get apkObjectName => '$kStorageFolder/$tag.apk';

  /// Manifesto ao lado do APK com os metadados completos.
  ///
  /// Existe por causa do rollback: o GCS guarda md5/crc32c, não SHA-256, então
  /// sem isto voltar para uma versão anterior exigiria baixar o APK inteiro
  /// para recalcular o hash.
  String get manifestObjectName => '$kStorageFolder/$tag.json';

  static ReleaseVersion fromPubspec([String path = 'pubspec.yaml']) {
    final doc = loadYaml(File(path).readAsStringSync()) as YamlMap;
    final raw = (doc['version'] as String?)?.trim();
    if (raw == null || raw.isEmpty) {
      throw StateError('`version:` ausente em $path');
    }
    final parts = raw.split('+');
    if (parts.length != 2) {
      throw StateError(
          'Formato de versão inválido: "$raw". Esperado `x.y.z+n`.');
    }
    final build = int.tryParse(parts[1].trim());
    if (build == null) {
      throw StateError('buildNumber não é inteiro em "$raw".');
    }
    return ReleaseVersion(parts[0].trim(), build);
  }
}

/// Cliente autenticado por service account.
///
/// Deliberadamente NÃO usa a conta pessoal logada no Firebase CLI: publicar é
/// operação de máquina, precisa funcionar em CI e não deve depender de quem
/// está logado na estação.
Future<AutoRefreshingAuthClient> authenticate() async {
  final path = serviceAccountCandidates().firstWhere(
    (p) => File(p).existsSync(),
    orElse: () => throw StateError(
      'Credencial não encontrada.\n'
      'Procurei em: ${serviceAccountCandidates().join(", ")}\n\n'
      'Baixe a chave em: Firebase Console > Configuracoes do projeto >\n'
      'Contas de servico > Gerar nova chave privada.\n'
      'Salve como tool/service-account.json (ja esta no .gitignore) ou\n'
      'aponte a variavel PETS_SERVICE_ACCOUNT para o arquivo.',
    ),
  );

  final credentials =
      ServiceAccountCredentials.fromJson(jsonDecode(File(path).readAsStringSync()));
  return clientViaServiceAccount(credentials, kScopes);
}

// ── Firestore REST ──────────────────────────────────────────────────────────
// A API REST usa "typed values": cada campo carrega o tipo explicitamente.
// Escrever integerValue como String é o formato da API, não engano.

String _firestoreDocUrl(String collection, String document) =>
    'https://firestore.googleapis.com/v1/projects/$kProjectId/databases/(default)'
    '/documents/$collection/$document';

Map<String, dynamic> stringValue(String v) => {'stringValue': v};
Map<String, dynamic> integerValue(int v) => {'integerValue': '$v'};
Map<String, dynamic> timestampValue(DateTime v) =>
    {'timestampValue': v.toUtc().toIso8601String()};

Future<Map<String, dynamic>?> readChannel(http.Client client) async {
  final res = await client.get(
      Uri.parse(_firestoreDocUrl(kConfigCollection, kConfigDocument)));
  if (res.statusCode == 404) return null;
  if (res.statusCode != 200) {
    throw StateError('Falha ao ler o canal (HTTP ${res.statusCode}): ${res.body}');
  }
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  return (body['fields'] as Map?)?.cast<String, dynamic>();
}

/// Converte um campo tipado da REST para valor Dart (só o que usamos).
Object? decodeField(Map<String, dynamic>? fields, String name) {
  final f = fields?[name] as Map?;
  if (f == null) return null;
  if (f.containsKey('integerValue')) return int.tryParse('${f['integerValue']}');
  if (f.containsKey('stringValue')) return f['stringValue'];
  if (f.containsKey('timestampValue')) return f['timestampValue'];
  return null;
}

Future<void> writeChannel(
    http.Client client, Map<String, Map<String, dynamic>> fields) async {
  // updateMask garante que só os campos enviados são tocados; sem ele o PATCH
  // apagaria qualquer campo que o script não conheça.
  final mask = fields.keys.map((k) => 'updateMask.fieldPaths=$k').join('&');
  final url = '${_firestoreDocUrl(kConfigCollection, kConfigDocument)}?$mask';

  final res = await client.patch(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'fields': fields}),
  );
  if (res.statusCode != 200) {
    throw StateError(
        'Falha ao gravar o canal (HTTP ${res.statusCode}): ${res.body}');
  }
}

// ── Storage REST ────────────────────────────────────────────────────────────

/// URL de download pública. Depende da rule `allow read: if true` em
/// `releases/`; sem token, portanto não revogável nem quebra ao reenviar.
String downloadUrl(String objectName) {
  final encoded = Uri.encodeComponent(objectName);
  return 'https://firebasestorage.googleapis.com/v0/b/$kBucket/o/$encoded?alt=media';
}

Future<void> uploadObject(
  http.Client client, {
  required String objectName,
  required List<int> bytes,
  required String contentType,
  void Function(int sent, int total)? onProgress,
}) async {
  final url = Uri.parse(
    'https://storage.googleapis.com/upload/storage/v1/b/$kBucket/o'
    '?uploadType=media&name=${Uri.encodeComponent(objectName)}',
  );

  final request = http.Request('POST', url)
    ..headers['Content-Type'] = contentType
    ..bodyBytes = bytes;

  onProgress?.call(0, bytes.length);
  final streamed = await client.send(request);
  final res = await http.Response.fromStream(streamed);
  onProgress?.call(bytes.length, bytes.length);

  if (res.statusCode != 200) {
    throw StateError(
        'Falha no upload de $objectName (HTTP ${res.statusCode}): ${res.body}');
  }
}

Future<String?> downloadObjectAsString(
    http.Client client, String objectName) async {
  final url = Uri.parse(
    'https://storage.googleapis.com/storage/v1/b/$kBucket/o/'
    '${Uri.encodeComponent(objectName)}?alt=media',
  );
  final res = await client.get(url);
  if (res.statusCode == 404) return null;
  if (res.statusCode != 200) {
    throw StateError('Falha ao ler $objectName (HTTP ${res.statusCode}).');
  }
  return res.body;
}

Future<List<String>> listReleaseManifests(http.Client client) async {
  final url = Uri.parse(
    'https://storage.googleapis.com/storage/v1/b/$kBucket/o'
    '?prefix=${Uri.encodeComponent('$kStorageFolder/')}',
  );
  final res = await client.get(url);
  if (res.statusCode != 200) {
    throw StateError('Falha ao listar releases (HTTP ${res.statusCode}).');
  }
  final items = (jsonDecode(res.body)['items'] as List?) ?? const [];
  return items
      .map((i) => '${i['name']}')
      .where((n) => n.endsWith('.json'))
      .toList()
    ..sort();
}

// ── Console ─────────────────────────────────────────────────────────────────

String bytesToMb(int bytes) =>
    '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

bool confirm(String question) {
  stdout.write('$question [s/N] ');
  final answer = stdin.readLineSync()?.trim().toLowerCase();
  return answer == 's' || answer == 'sim';
}

// ── Guarda de patch ─────────────────────────────────────────────────────────

/// Caminhos cuja alteração EXIGE release novo — patch não os carrega.
///
/// `lib/assets/` está aqui junto de `assets/`: este projeto declara imagens
/// nos dois lugares (ver a lista `assets:` do pubspec), e patch de asset não é
/// suportado pelo Shorebird.
const List<String> kNativeOrAssetPaths = [
  'android/',
  'ios/',
  'macos/',
  'windows/',
  'linux/',
  'assets/',
  'lib/assets/',
  'pubspec.yaml',
  'pubspec.lock',
];

/// Roda git e devolve stdout, ou `null` se o comando falhar.
String? git(List<String> args) {
  try {
    final res = Process.runSync('git', args);
    if (res.exitCode != 0) return null;
    return '${res.stdout}'.trim();
  } catch (_) {
    return null;
  }
}

String? currentCommit() => git(['rev-parse', 'HEAD']);

/// Arquivos alterados entre [fromCommit] e o estado ATUAL do working tree.
///
/// Inclui commits e mudanças não commitadas: o que vai para o patch é o que
/// está no disco, não o que está no último commit.
List<String> changedFilesSince(String fromCommit) {
  final committed = git(['diff', '--name-only', fromCommit, 'HEAD']) ?? '';
  final working = git(['diff', '--name-only', 'HEAD']) ?? '';
  final untracked =
      git(['ls-files', '--others', '--exclude-standard']) ?? '';
  return {
    ...committed.split('\n'),
    ...working.split('\n'),
    ...untracked.split('\n'),
  }.where((f) => f.trim().isNotEmpty).toList()
    ..sort();
}

/// Subconjunto de [files] que impede um patch.
List<String> blockingChanges(List<String> files) => files
    .where((f) => kNativeOrAssetPaths.any((p) =>
        p.endsWith('/') ? f.startsWith(p) : f == p))
    .toList();
