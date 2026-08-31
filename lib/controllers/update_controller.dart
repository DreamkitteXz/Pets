import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pet_app/models/app_release_info.dart';
import 'package:pet_app/services/apk_downloader.dart';
import 'package:pet_app/services/apk_installer.dart';
import 'package:pet_app/services/app_update_service.dart';
import 'package:pet_app/services/update_preferences.dart';

/// Etapa do fluxo de atualização, para a UI escolher o que mostrar.
enum UpdateStage {
  /// Diálogo aberto, aguardando o tutor decidir.
  idle,

  /// Falta autorizar "instalar apps desconhecidos".
  needsPermission,

  downloading,

  /// Baixado e verificado; o instalador do sistema foi aberto.
  installing,

  failed,
}

/// Orquestra checagem, download, verificação e instalação.
///
/// Não conhece widget: a UI observa e reage. Isso mantém o fluxo testável sem
/// bombear frames.
class UpdateController extends ChangeNotifier {
  UpdateController({
    AppUpdateService? updateService,
    ApkDownloader? downloader,
    ApkInstaller? installer,
    UpdatePreferences? preferences,
  })  : _updateService = updateService ?? AppUpdateService(),
        _downloader = downloader ?? ApkDownloader(),
        _installer = installer ?? ApkInstaller(),
        _preferences = preferences ?? UpdatePreferences();

  final AppUpdateService _updateService;
  final ApkDownloader _downloader;
  final ApkInstaller _installer;
  final UpdatePreferences _preferences;

  UpdateStage _stage = UpdateStage.idle;
  DownloadProgress? _progress;
  String? _errorMessage;
  CancellationToken? _cancellationToken;

  UpdateStage get stage => _stage;
  DownloadProgress? get progress => _progress;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _stage == UpdateStage.downloading;

  /// Decide se há algo a mostrar ao abrir o app.
  ///
  /// Devolve `null` quando não se deve incomodar o usuário: já atualizado,
  /// plataforma sem este fluxo (iOS), ou update opcional já dispensado hoje.
  Future<AppUpdateCheck?> checkOnStartup() async {
    // iOS fica inerte: não há APK para instalar e o diálogo não teria ação.
    if (!_installer.isSupported) return null;

    final check = await _updateService.check();
    if (check.status == UpdateStatus.upToDate) return null;

    // Obrigatório ignora qualquer dispensa anterior — é justamente o caso em
    // que a versão antiga não pode continuar rodando.
    if (check.status == UpdateStatus.required) return check;

    final latest = check.release?.latestBuildNumber;
    if (latest != null) {
      unawaited(_preferences.clearOlderThan(latest));
      if (await _preferences.wasDismissedToday(latest)) return null;
    }
    return check;
  }

  /// "Agora não" num update opcional.
  Future<void> dismissForToday(AppUpdateCheck check) async {
    final latest = check.release?.latestBuildNumber;
    if (latest == null) return;
    await _preferences.dismissForToday(latest);
  }

  /// Baixa, verifica e dispara a instalação.
  ///
  /// Retorna `true` quando o instalador do sistema chegou a abrir.
  Future<bool> downloadAndInstall(AppReleaseInfo release) async {
    if (!release.canDownload) {
      _fail('Esta versão não tem arquivo de instalação publicado.');
      return false;
    }

    // Sem a autorização o instalador abriria uma tela morta. Checa ANTES de
    // gastar 80 MB de download.
    if (!await _installer.canRequestPackageInstalls()) {
      _stage = UpdateStage.needsPermission;
      _errorMessage = null;
      notifyListeners();
      return false;
    }

    final token = CancellationToken();
    _cancellationToken = token;
    _stage = UpdateStage.downloading;
    _progress = const DownloadProgress(0, null);
    _errorMessage = null;
    notifyListeners();

    File? file;
    try {
      file = await _downloader.download(
        url: release.apkUrl!,
        expectedSha256: release.apkSha256!,
        expectedSizeBytes: release.apkSizeBytes,
        cancellationToken: token,
        onProgress: (p) {
          _progress = p;
          notifyListeners();
        },
      );

      _stage = UpdateStage.installing;
      notifyListeners();

      await _installer.installApk(file.path);

      // O APK fica no cache até o sistema concluir a instalação — apagar aqui
      // puxaria o arquivo debaixo do instalador. A limpeza acontece no próximo
      // início, em [cleanupStaleDownloads].
      return true;
    } on DownloadException catch (e) {
      if (e.reason == DownloadFailure.cancelled) {
        _stage = UpdateStage.idle;
        _progress = null;
        _errorMessage = null;
      } else {
        _fail(_messageFor(e));
      }
      return false;
    } catch (e) {
      if (file != null) await _downloader.discard(file);
      _fail('Não foi possível instalar: $e');
      return false;
    } finally {
      _cancellationToken = null;
    }
  }

  void cancelDownload() => _cancellationToken?.cancel();

  Future<bool> openInstallPermissionSettings() =>
      _installer.openInstallPermissionSettings();

  void reset() {
    _stage = UpdateStage.idle;
    _progress = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Apaga APKs deixados no cache por instalações concluídas ou abandonadas.
  ///
  /// Não dá para apagar logo após disparar a instalação — puxaria o arquivo
  /// debaixo do instalador do sistema, que ainda está lendo. Então a limpeza
  /// roda no início seguinte, quando ninguém mais precisa deles.
  Future<void> cleanupStaleDownloads() async {
    try {
      final dir = await getTemporaryDirectory();
      if (!dir.existsSync()) return;
      for (final entity in dir.listSync()) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        if (!name.startsWith('update-') || !name.endsWith('.apk')) continue;
        await _downloader.discard(entity);
      }
    } catch (e) {
      debugPrint('[update] limpeza de cache falhou: $e');
    }
  }

  static String _messageFor(DownloadException e) {
    switch (e.reason) {
      case DownloadFailure.network:
        return 'A conexão caiu durante o download. Tente de novo.';
      case DownloadFailure.notFound:
        return 'O arquivo da atualização não está disponível no servidor.';
      case DownloadFailure.checksumMismatch:
        // Deliberadamente alarmante: ou corrompeu na rede, ou o arquivo não é
        // o que o canal anunciou.
        return 'O arquivo baixado não confere com o esperado e foi descartado. '
            'Tente de novo; se persistir, avise o suporte.';
      case DownloadFailure.noSpace:
        return 'Espaço insuficiente no aparelho para baixar a atualização.';
      case DownloadFailure.cancelled:
        return 'Download cancelado.';
      case DownloadFailure.unknown:
        return e.message;
    }
  }

  void _fail(String message) {
    _stage = UpdateStage.failed;
    _progress = null;
    _errorMessage = message;
    notifyListeners();
  }
}
