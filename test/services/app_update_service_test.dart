import 'package:flutter_test/flutter_test.dart';

import 'package:pet_app/models/app_release_info.dart';
import 'package:pet_app/services/app_update_service.dart';

AppReleaseInfo release({
  String? versionName,
  int? latest,
  int? minSupported,
  String? url,
  String? sha,
  int? size,
}) =>
    AppReleaseInfo(
      latestVersionName: versionName,
      latestBuildNumber: latest,
      minSupportedBuildNumber: minSupported,
      apkUrl: url,
      apkSha256: sha,
      apkSizeBytes: size,
    );

void main() {
  group('resolve — comparação por buildNumber inteiro', () {
    test('build atual igual ao último: atualizado', () {
      final r = AppUpdateService.resolve(
          current: 15, release: release(latest: 15, minSupported: 10));
      expect(r.status, UpdateStatus.upToDate);
      expect(r.hasUpdate, isFalse);
    });

    test('build atual menor que o último: opcional', () {
      final r = AppUpdateService.resolve(
          current: 14, release: release(latest: 15, minSupported: 10));
      expect(r.status, UpdateStatus.optional);
      expect(r.isBlocking, isFalse);
    });

    test('build atual abaixo do mínimo: obrigatório', () {
      final r = AppUpdateService.resolve(
          current: 9, release: release(latest: 15, minSupported: 10));
      expect(r.status, UpdateStatus.required);
      expect(r.isBlocking, isTrue);
    });

    test('exatamente no mínimo ainda é suportado', () {
      // `current < minSupported` bloqueia; igual NÃO bloqueia.
      final r = AppUpdateService.resolve(
          current: 10, release: release(latest: 15, minSupported: 10));
      expect(r.status, UpdateStatus.optional);
    });

    test('build à frente do canal não é desatualizado', () {
      // Build de desenvolvimento local, acima do publicado.
      final r = AppUpdateService.resolve(
          current: 99, release: release(latest: 15, minSupported: 10));
      expect(r.status, UpdateStatus.upToDate);
    });

    test('obrigatório tem precedência sobre opcional', () {
      final r = AppUpdateService.resolve(
          current: 5, release: release(latest: 15, minSupported: 10));
      expect(r.status, UpdateStatus.required);
    });
  });

  group('a armadilha da comparação por string', () {
    test('1.10.0 (build 110) é mais novo que 1.9.0 (build 90)', () {
      // Como STRING, "1.10.0" < "1.9.0" — a versão nova pareceria antiga e o
      // usuário nunca receberia o aviso. Por inteiro, 110 > 90.
      expect('1.10.0'.compareTo('1.9.0'), lessThan(0),
          reason: 'confirma que a comparação de string é enganosa');

      final r = AppUpdateService.resolve(
        current: 110,
        release: release(versionName: '1.9.0', latest: 90, minSupported: 50),
      );
      expect(r.status, UpdateStatus.upToDate);
    });

    test('quem está na 1.9.0 recebe aviso da 1.10.0', () {
      final r = AppUpdateService.resolve(
        current: 90,
        release: release(versionName: '1.10.0', latest: 110, minSupported: 50),
      );
      expect(r.status, UpdateStatus.optional);
      expect(r.release?.latestVersionName, '1.10.0');
    });
  });

  group('fail open — erro nunca bloqueia o app', () {
    test('sem config: atualizado', () {
      final r = AppUpdateService.resolve(current: 5, release: null);
      expect(r.status, UpdateStatus.upToDate);
    });

    test('build local ilegível (0): não bloqueia mesmo com mínimo alto', () {
      final r = AppUpdateService.resolve(
          current: 0, release: release(latest: 15, minSupported: 10));
      expect(r.status, UpdateStatus.upToDate,
          reason: 'build desconhecido não pode virar killswitch');
    });

    test('doc sem os campos numéricos: não bloqueia', () {
      final r = AppUpdateService.resolve(
          current: 5, release: release(versionName: '2.0.0'));
      expect(r.status, UpdateStatus.upToDate);
    });

    test('só minSupported definido ainda bloqueia quem está abaixo', () {
      final r = AppUpdateService.resolve(
          current: 5, release: release(minSupported: 10));
      expect(r.status, UpdateStatus.required);
    });
  });

  group('AppReleaseInfo.fromMap', () {
    test('lê inteiro digitado como string no console', () {
      final info = AppReleaseInfo.fromMap({
        'latestBuildNumber': '15',
        'minSupportedBuildNumber': 10,
        'apkSizeBytes': '80994271',
      });
      expect(info.latestBuildNumber, 15);
      expect(info.minSupportedBuildNumber, 10);
      expect(info.apkSizeBytes, 80994271);
    });

    test('campo ausente ou vazio vira null, sem lançar', () {
      final info = AppReleaseInfo.fromMap({
        'latestVersionName': '  ',
        'latestBuildNumber': 'abc',
      });
      expect(info.latestVersionName, isNull);
      expect(info.latestBuildNumber, isNull);
      expect(info.apkUrl, isNull);
    });

    test('sha256 normalizado para minúsculo', () {
      final info = AppReleaseInfo.fromMap({'apkSha256': 'AbCdEf'});
      expect(info.apkSha256, 'abcdef');
    });

    test('canDownload exige URL e sha de 64 caracteres', () {
      expect(release(url: 'https://x/a.apk', sha: 'a' * 64).canDownload, isTrue);
      // Sem checksum não há como verificar o binário baixado.
      expect(release(url: 'https://x/a.apk').canDownload, isFalse);
      expect(release(url: 'https://x/a.apk', sha: 'curto').canDownload, isFalse);
      expect(release(sha: 'a' * 64).canDownload, isFalse);
    });

    test('readableSize formata para exibição', () {
      expect(release(size: 80994271).readableSize, '77.2 MB');
      expect(release(size: 2048).readableSize, '2 KB');
      expect(release(size: 0).readableSize, isNull);
      expect(release().readableSize, isNull);
    });
  });
}
