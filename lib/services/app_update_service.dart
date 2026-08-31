import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:pet_app/models/app_release_info.dart';

/// Consulta o canal de versão em `app_config/{plataforma}`.
///
/// Existe porque o app é distribuído FORA da Play Store: não há loja avisando
/// que saiu versão nova, nem impedindo que uma versão antiga continue rodando
/// depois de uma mudança de estrutura no Firestore.
///
/// **Comparação é por `buildNumber` inteiro, nunca por `versionName`.**
/// Comparar "1.10.0" com "1.9.0" como string dá o resultado ERRADO — "1.1" <
/// "1.9" lexicograficamente, então a 1.10.0 pareceria mais antiga que a 1.9.0.
/// O `versionName` serve só para exibir.
///
/// **Falha de leitura nunca bloqueia** (fail open). Um `minSupportedBuildNumber`
/// que trava o app é um killswitch: se um erro de rede ou de permissão fosse
/// interpretado como "abaixo do mínimo", uma instabilidade do Firestore
/// derrubaria o app de todo mundo ao mesmo tempo. Sem dado confiável, o
/// resultado é [UpdateStatus.upToDate].
class AppUpdateService {
  AppUpdateService({
    FirebaseFirestore? firestore,
    Future<PackageInfo> Function()? packageInfoLoader,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _packageInfoLoader = packageInfoLoader ?? PackageInfo.fromPlatform;

  final FirebaseFirestore _firestore;
  final Future<PackageInfo> Function() _packageInfoLoader;

  static const String collection = 'app_config';

  /// Um documento por plataforma: o APK do Android tem ciclo próprio e o iOS,
  /// se existir um dia, não compartilha nem build number nem URL.
  static String documentIdFor(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'android';
    }
  }

  /// Build instalado, lido do pacote. `0` se ilegível — com isso qualquer
  /// `minSupportedBuildNumber` positivo bloquearia, então o chamador precisa
  /// tratar; ver a guarda em [check].
  Future<int> currentBuildNumber() async {
    final info = await _packageInfoLoader();
    return int.tryParse(info.buildNumber.trim()) ?? 0;
  }

  /// Lê o canal. Devolve `null` quando não há dado utilizável.
  ///
  /// O `get()` normal usa o cache offline do Firestore quando não há rede, o
  /// que mantém a última config conhecida valendo — comportamento desejado
  /// aqui, já que a config muda raramente.
  Future<AppReleaseInfo?> fetchRelease({TargetPlatform? platform}) async {
    final docId = documentIdFor(platform ?? defaultTargetPlatform);
    try {
      final snap = await _firestore.collection(collection).doc(docId).get();
      final data = snap.data();
      if (!snap.exists || data == null) {
        debugPrint('[update] $collection/$docId não existe');
        return null;
      }
      return AppReleaseInfo.fromMap(data);
    } catch (e) {
      debugPrint('[update] falha ao ler $collection/$docId: $e');
      return null;
    }
  }

  /// Estado da versão instalada. Nunca lança.
  Future<AppUpdateCheck> check({TargetPlatform? platform}) async {
    int current;
    try {
      current = await currentBuildNumber();
    } catch (e) {
      debugPrint('[update] falha ao ler o pacote: $e');
      return const AppUpdateCheck(
          status: UpdateStatus.upToDate, currentBuildNumber: 0);
    }

    final release = await fetchRelease(platform: platform);
    return resolve(current: current, release: release);
  }

  /// Decisão pura, separada da E/S para poder ser testada sem Firebase.
  @visibleForTesting
  static AppUpdateCheck resolve({
    required int current,
    required AppReleaseInfo? release,
  }) {
    // Sem config, ou build local ilegível: não dá para afirmar que está
    // desatualizado, muito menos bloquear.
    if (release == null || current <= 0) {
      return AppUpdateCheck(
        status: UpdateStatus.upToDate,
        currentBuildNumber: current,
        release: release,
      );
    }

    final minSupported = release.minSupportedBuildNumber;
    if (minSupported != null && current < minSupported) {
      return AppUpdateCheck(
        status: UpdateStatus.required,
        currentBuildNumber: current,
        release: release,
      );
    }

    final latest = release.latestBuildNumber;
    if (latest != null && current < latest) {
      return AppUpdateCheck(
        status: UpdateStatus.optional,
        currentBuildNumber: current,
        release: release,
      );
    }

    // Inclui o caso `current > latest`: build de desenvolvimento à frente do
    // canal não é "desatualizado".
    return AppUpdateCheck(
      status: UpdateStatus.upToDate,
      currentBuildNumber: current,
      release: release,
    );
  }
}
