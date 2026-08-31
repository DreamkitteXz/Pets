import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Ponte para o instalador de APK nativo (`ApkInstaller.kt`).
///
/// **Só Android.** Em qualquer outra plataforma todos os métodos devolvem o
/// valor inerte, sem tocar no MethodChannel — o canal não existe fora do
/// Android e chamá-lo lançaria MissingPluginException.
class ApkInstaller {
  ApkInstaller({MethodChannel? channel, TargetPlatform? platformOverride})
      : _channel = channel ?? const MethodChannel('pet_app/apk_installer'),
        _platform = platformOverride ?? defaultTargetPlatform;

  final MethodChannel _channel;
  final TargetPlatform _platform;

  bool get isSupported => !kIsWeb && _platform == TargetPlatform.android;

  /// O usuário já autorizou este app a instalar apps desconhecidos?
  ///
  /// Fora do Android devolve `false`: nada a instalar, e o chamador usa isso
  /// para não oferecer o fluxo.
  Future<bool> canRequestPackageInstalls() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('canRequestPackageInstalls') ??
          false;
    } on PlatformException catch (e) {
      debugPrint('[apk] canRequestPackageInstalls: $e');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Abre a tela de autorização já no toggle deste app.
  /// `false` quando nem a tela nem o fallback abriram.
  Future<bool> openInstallPermissionSettings() async {
    if (!isSupported) return false;
    try {
      return await _channel
              .invokeMethod<bool>('openInstallPermissionSettings') ??
          false;
    } on PlatformException catch (e) {
      debugPrint('[apk] openInstallPermissionSettings: $e');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Dispara a instalação. O retorno indica que a TELA do instalador abriu —
  /// não que o usuário concluiu: quem confirma é ele, e o app é substituído no
  /// processo.
  Future<void> installApk(String filePath) async {
    if (!isSupported) {
      throw UnsupportedError('Instalação de APK só existe no Android.');
    }
    await _channel.invokeMethod<bool>('installApk', {'filePath': filePath});
  }
}
