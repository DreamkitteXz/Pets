import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pet_app/services/apk_downloader.dart';
import 'package:pet_app/services/apk_installer.dart';
import 'package:pet_app/services/update_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UpdatePreferences — "não perguntar de novo hoje"', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('dispensa vale só no mesmo dia', () async {
      final prefs = UpdatePreferences(
          prefs: await SharedPreferences.getInstance());
      final hoje = DateTime(2026, 8, 26, 23, 59);

      await prefs.dismissForToday(15, now: hoje);

      expect(await prefs.wasDismissedToday(15, now: hoje), isTrue);
      // Um minuto depois, mas outro DIA: volta a perguntar. A regra é por dia
      // de calendário, não 24h corridas.
      expect(
        await prefs.wasDismissedToday(15, now: DateTime(2026, 8, 27, 0, 1)),
        isFalse,
      );
    });

    test('dispensar uma versão não cala a próxima', () async {
      final prefs = UpdatePreferences(
          prefs: await SharedPreferences.getInstance());
      final hoje = DateTime(2026, 8, 26);

      await prefs.dismissForToday(15, now: hoje);

      expect(await prefs.wasDismissedToday(15, now: hoje), isTrue);
      expect(await prefs.wasDismissedToday(16, now: hoje), isFalse);
    });

    test('limpa dispensas de builds superados', () async {
      final store = await SharedPreferences.getInstance();
      final prefs = UpdatePreferences(prefs: store);
      final hoje = DateTime(2026, 8, 26);

      await prefs.dismissForToday(10, now: hoje);
      await prefs.dismissForToday(15, now: hoje);
      await prefs.clearOlderThan(15);

      expect(await prefs.wasDismissedToday(10, now: hoje), isFalse);
      expect(await prefs.wasDismissedToday(15, now: hoje), isTrue);
    });
  });

  group('ApkDownloader — verificação e limpeza', () {
    late Directory tempDir;
    HttpOverrides? overridesAnteriores;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('apk_test');
      // O TestWidgetsFlutterBinding instala um HttpOverrides que faz TODA
      // requisição voltar 400 sem sair da máquina. Estes testes sobem um
      // servidor em loopback e precisam de socket de verdade, então a rede
      // real é restaurada só aqui.
      overridesAnteriores = HttpOverrides.current;
      HttpOverrides.global = _RedeReal();
    });
    tearDown(() async {
      HttpOverrides.global = overridesAnteriores;
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    });

    /// Servidor local: exercita o caminho real de rede (streaming,
    /// Content-Length, progresso) sem depender de internet.
    Future<HttpServer> serve(List<int> body, {int status = 200}) async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((req) async {
        req.response.statusCode = status;
        if (status == 200) {
          req.response.headers.contentType = ContentType.binary;
          req.response.contentLength = body.length;
          req.response.add(body);
        }
        await req.response.close();
      });
      return server;
    }

    test('baixa, confere o sha256 e reporta progresso', () async {
      final body = utf8.encode('conteudo-de-apk-falso' * 500);
      final expected = sha256.convert(body).toString();
      final server = await serve(body);
      addTearDown(() => server.close(force: true));

      final downloader = ApkDownloader(cacheDirProvider: () async => tempDir);
      final progressos = <DownloadProgress>[];

      final file = await downloader.download(
        url: 'http://${server.address.host}:${server.port}/app.apk',
        expectedSha256: expected,
        expectedSizeBytes: body.length,
        onProgress: progressos.add,
      );

      expect(file.existsSync(), isTrue);
      expect(await file.length(), body.length);
      expect(progressos, isNotEmpty);
      expect(progressos.last.received, body.length);
      expect(progressos.last.total, body.length);
      expect(progressos.last.fraction, 1.0);
    });

    test('sha256 divergente: lança e APAGA o arquivo', () async {
      final body = utf8.encode('binario-adulterado');
      final server = await serve(body);
      addTearDown(() => server.close(force: true));

      final downloader = ApkDownloader(cacheDirProvider: () async => tempDir);
      final shaErrado = 'a' * 64;

      await expectLater(
        downloader.download(
          url: 'http://${server.address.host}:${server.port}/app.apk',
          expectedSha256: shaErrado,
          expectedSizeBytes: body.length,
        ),
        throwsA(isA<DownloadException>().having(
            (e) => e.reason, 'reason', DownloadFailure.checksumMismatch)),
      );

      // O ponto do teste: nao pode sobrar arquivo nao verificado no cache,
      // senao uma tentativa seguinte poderia instala-lo.
      expect(tempDir.listSync().whereType<File>().length, 0);
    });

    test('404 vira notFound, sem deixar arquivo', () async {
      final server = await serve(const [], status: 404);
      addTearDown(() => server.close(force: true));

      final downloader = ApkDownloader(cacheDirProvider: () async => tempDir);

      await expectLater(
        downloader.download(
          url: 'http://${server.address.host}:${server.port}/sumiu.apk',
          expectedSha256: 'b' * 64,
          expectedSizeBytes: 10,
        ),
        throwsA(isA<DownloadException>()
            .having((e) => e.reason, 'reason', DownloadFailure.notFound)),
      );
      expect(tempDir.listSync().whereType<File>().length, 0);
    });

    test('sem servidor (rede caída) vira network', () async {
      final downloader = ApkDownloader(cacheDirProvider: () async => tempDir);
      await expectLater(
        downloader.download(
          // Porta fechada: simula queda de conexão.
          url: 'http://127.0.0.1:9/app.apk',
          expectedSha256: 'c' * 64,
          expectedSizeBytes: 10,
        ),
        throwsA(isA<DownloadException>()
            .having((e) => e.reason, 'reason', DownloadFailure.network)),
      );
    });
  });

  group('DownloadProgress', () {
    test('sem total, fração é nula e o rótulo mostra só o recebido', () {
      const p = DownloadProgress(1024 * 1024 * 3, null);
      expect(p.fraction, isNull);
      expect(p.label, '3,0 MB');
    });

    test('com total, fração e rótulo completos', () {
      const p = DownloadProgress(1024 * 1024 * 10, 1024 * 1024 * 40);
      expect(p.fraction, 0.25);
      expect(p.label, '10,0 MB de 40,0 MB');
    });
  });

  group('ApkInstaller — inerte fora do Android', () {
    test('iOS: não é suportado e não toca no channel', () async {
      final installer = ApkInstaller(
        channel: const MethodChannel('canal_inexistente'),
        platformOverride: TargetPlatform.iOS,
      );

      expect(installer.isSupported, isFalse);
      // Sem exceção: os métodos devolvem valor inerte em vez de estourar
      // MissingPluginException.
      expect(await installer.canRequestPackageInstalls(), isFalse);
      expect(await installer.openInstallPermissionSettings(), isFalse);
      expect(() => installer.installApk('/tmp/x.apk'),
          throwsA(isA<UnsupportedError>()));
    });

    test('Android: é suportado', () {
      final installer = ApkInstaller(
        channel: const MethodChannel('canal'),
        platformOverride: TargetPlatform.android,
      );
      expect(installer.isSupported, isTrue);
    });
  });
}

/// HttpOverrides sem customização: a implementação padrão cria HttpClient de
/// verdade, desfazendo o mock do binding de teste.
class _RedeReal extends HttpOverrides {}
