import 'package:pet_app/utils/firestore_date.dart';

/// Situação da versão instalada frente ao canal de release.
enum UpdateStatus {
  /// Build atual >= último publicado. Nada a fazer.
  upToDate,

  /// Existe versão nova, mas a atual ainda é suportada.
  optional,

  /// Build atual < mínimo suportado. O app deve bloquear até atualizar.
  ///
  /// Usado quando uma mudança de estrutura no Firestore faria a versão antiga
  /// gravar dado inconsistente ou quebrar.
  required,
}

/// Conteúdo de `app_config/android` — o canal de distribuição fora da Play
/// Store.
///
/// Campos ausentes ou ilegíveis NÃO invalidam o documento: a leitura é
/// tolerante e o serviço decide o estado com o que conseguiu ler. Um doc
/// malformado nunca pode bloquear o app (ver [AppUpdateService]).
class AppReleaseInfo {
  /// Só para exibição ("1.2.0"). NUNCA usado em comparação.
  final String? latestVersionName;

  /// O número que decide se há update. Inteiro, monotônico.
  final int? latestBuildNumber;

  /// Abaixo disso a atualização é obrigatória.
  final int? minSupportedBuildNumber;

  final String? apkUrl;

  /// SHA-256 em hex minúsculo, para validar o arquivo baixado.
  final String? apkSha256;

  final int? apkSizeBytes;
  final String? changelog;
  final DateTime? releasedAt;

  const AppReleaseInfo({
    this.latestVersionName,
    this.latestBuildNumber,
    this.minSupportedBuildNumber,
    this.apkUrl,
    this.apkSha256,
    this.apkSizeBytes,
    this.changelog,
    this.releasedAt,
  });

  factory AppReleaseInfo.fromMap(Map<String, dynamic> map) {
    return AppReleaseInfo(
      latestVersionName: _readString(map['latestVersionName']),
      latestBuildNumber: _readInt(map['latestBuildNumber']),
      minSupportedBuildNumber: _readInt(map['minSupportedBuildNumber']),
      apkUrl: _readString(map['apkUrl']),
      apkSha256: _readString(map['apkSha256'])?.toLowerCase(),
      apkSizeBytes: _readInt(map['apkSizeBytes']),
      changelog: _readString(map['changelog']),
      releasedAt: readFirestoreDate(map['releasedAt']),
    );
  }

  /// Aceita int e String numérica: um campo digitado no console do Firestore
  /// entra como string com facilidade, e um `as int` derrubaria a checagem
  /// inteira.
  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  /// Tamanho legível, para a UI mostrar antes do download.
  String? get readableSize {
    final bytes = apkSizeBytes;
    if (bytes == null || bytes <= 0) return null;
    const mb = 1024 * 1024;
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(1)} MB';
    return '${(bytes / 1024).round()} KB';
  }

  /// Só vale oferecer download com URL E checksum: sem o hash não há como
  /// verificar o que foi baixado, e instalar binário não verificado vindo de
  /// fora da loja é o pior caso deste fluxo.
  bool get canDownload =>
      (apkUrl?.isNotEmpty ?? false) && (apkSha256?.length == 64);
}

/// Resultado da checagem: o estado mais o que é preciso para montar o diálogo.
class AppUpdateCheck {
  final UpdateStatus status;

  /// Build lido do pacote instalado.
  final int currentBuildNumber;

  /// `null` quando a leitura falhou (offline, sem cache, erro de permissão).
  final AppReleaseInfo? release;

  const AppUpdateCheck({
    required this.status,
    required this.currentBuildNumber,
    this.release,
  });

  bool get hasUpdate => status != UpdateStatus.upToDate;
  bool get isBlocking => status == UpdateStatus.required;
}
