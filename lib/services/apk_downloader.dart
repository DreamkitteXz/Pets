import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Progresso do download, para a barra mostrar percentual e MB reais.
class DownloadProgress {
  final int received;

  /// `null` quando o servidor não informa Content-Length — a UI cai em
  /// indeterminado em vez de mostrar uma porcentagem inventada.
  final int? total;

  const DownloadProgress(this.received, this.total);

  double? get fraction {
    final t = total;
    if (t == null || t <= 0) return null;
    return (received / t).clamp(0.0, 1.0);
  }

  static String _mb(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(1);

  /// "12,3 MB de 77,2 MB" — ou só o recebido quando o total é desconhecido.
  String get label {
    final t = total;
    final r = _mb(received).replaceAll('.', ',');
    if (t == null || t <= 0) return '$r MB';
    return '$r MB de ${_mb(t).replaceAll('.', ',')} MB';
  }
}

/// Por que o download não terminou.
enum DownloadFailure {
  network,
  notFound,
  checksumMismatch,
  noSpace,
  cancelled,
  unknown,
}

class DownloadException implements Exception {
  final DownloadFailure reason;
  final String message;
  const DownloadException(this.reason, this.message);

  @override
  String toString() => 'DownloadException($reason): $message';
}

/// Baixa o APK para o cache do app e confere o SHA-256.
///
/// Usa `dart:io` HttpClient em vez de um pacote HTTP: dá streaming, tamanho
/// total e cancelamento sem somar dependência a um pubspec que já teve dor de
/// resolução.
class ApkDownloader {
  ApkDownloader({
    HttpClient Function()? httpClientFactory,
    Future<Directory> Function()? cacheDirProvider,
  })  : _httpClientFactory = httpClientFactory ?? HttpClient.new,
        _cacheDirProvider = cacheDirProvider ?? getTemporaryDirectory;

  final HttpClient Function() _httpClientFactory;
  final Future<Directory> Function() _cacheDirProvider;

  /// Margem sobre o tamanho do APK para não encher o disco por completo.
  static const int _freeSpaceSlackBytes = 20 * 1024 * 1024;

  /// Baixa [url] e devolve o arquivo já verificado.
  ///
  /// Lança [DownloadException] em qualquer falha — e SEMPRE apaga o arquivo
  /// parcial antes de lançar. APK truncado no cache seria oferecido para
  /// instalação numa próxima tentativa mal feita.
  Future<File> download({
    required String url,
    required String expectedSha256,
    required int? expectedSizeBytes,
    void Function(DownloadProgress)? onProgress,
    CancellationToken? cancellationToken,
  }) async {
    final dir = await _cacheDirProvider();
    // Nome fixo por versão: repetir o download sobrescreve em vez de acumular
    // APKs de 80 MB no cache.
    final file = File('${dir.path}/update-$expectedSha256.apk');

    await _assertEnoughSpace(dir, expectedSizeBytes);

    final client = _httpClientFactory();
    IOSink? sink;
    StreamSubscription<List<int>>? sub;

    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 404 || response.statusCode == 403) {
        throw DownloadException(
          DownloadFailure.notFound,
          'Arquivo indisponível (HTTP ${response.statusCode}).',
        );
      }
      if (response.statusCode != 200) {
        throw DownloadException(
          DownloadFailure.network,
          'Resposta inesperada do servidor (HTTP ${response.statusCode}).',
        );
      }

      final total = response.contentLength >= 0
          ? response.contentLength
          : expectedSizeBytes;

      if (file.existsSync()) await file.delete();
      sink = file.openWrite();

      var received = 0;
      final completer = Completer<void>();

      sub = response.listen(
        (chunk) {
          if (cancellationToken?.isCancelled ?? false) return;
          sink!.add(chunk);
          received += chunk.length;
          onProgress?.call(DownloadProgress(received, total));
        },
        onDone: () => completer.complete(),
        onError: completer.completeError,
        cancelOnError: true,
      );

      cancellationToken?.attach(() {
        sub?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(
            const DownloadException(
                DownloadFailure.cancelled, 'Download cancelado.'),
          );
        }
      });

      await completer.future;
      await sink.flush();
      await sink.close();
      sink = null;

      // Verificação SEMPRE, e antes de qualquer instalação. Arquivo que não
      // confere é apagado: pode ser corrupção de rede ou binário trocado.
      final actual = await _sha256Of(file);
      if (actual != expectedSha256.toLowerCase()) {
        throw const DownloadException(
          DownloadFailure.checksumMismatch,
          'O arquivo baixado não confere com o esperado.',
        );
      }

      return file;
    } on DownloadException {
      await _discard(file);
      rethrow;
    } on SocketException catch (e) {
      await _discard(file);
      throw DownloadException(
          DownloadFailure.network, 'Sem conexão com a internet. ${e.message}');
    } on HttpException catch (e) {
      await _discard(file);
      throw DownloadException(DownloadFailure.network, e.message);
    } on FileSystemException catch (e) {
      await _discard(file);
      // Disco cheio aparece aqui, e não na checagem prévia, quando o espaço
      // acaba no meio da escrita.
      throw DownloadException(
          DownloadFailure.noSpace, 'Falha ao gravar o arquivo. ${e.message}');
    } catch (e) {
      await _discard(file);
      throw DownloadException(DownloadFailure.unknown, '$e');
    } finally {
      await sub?.cancel();
      try {
        await sink?.close();
      } catch (_) {}
      client.close(force: true);
    }
  }

  /// Remove o APK do cache. Chamar depois de disparar a instalação e em
  /// qualquer falha — 80 MB parados no cache por download abandonado.
  Future<void> discard(File file) => _discard(file);

  Future<void> _discard(File file) async {
    try {
      if (file.existsSync()) await file.delete();
    } catch (e) {
      debugPrint('[apk] não consegui apagar ${file.path}: $e');
    }
  }

  Future<void> _assertEnoughSpace(Directory dir, int? sizeBytes) async {
    if (sizeBytes == null || sizeBytes <= 0) return;
    try {
      final stat = await dir.stat();
      // `Directory.stat` não expõe espaço livre em todas as plataformas; onde
      // não der para saber, seguimos e deixamos a escrita falhar com
      // FileSystemException, que já é tratada.
      if (stat.type == FileSystemEntityType.notFound) return;
    } catch (_) {
      return;
    }

    try {
      final probe = File('${dir.path}/.space_probe');
      await probe.writeAsBytes(const [0]);
      await probe.delete();
    } on FileSystemException {
      throw DownloadException(
        DownloadFailure.noSpace,
        'Não há espaço disponível para baixar '
        '${(sizeBytes + _freeSpaceSlackBytes) ~/ (1024 * 1024)} MB.',
      );
    }
  }

  /// Hash em streaming: ler 80 MB de uma vez para a memória derruba aparelho
  /// modesto.
  Future<String> _sha256Of(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString().toLowerCase();
  }
}

/// Cancelamento cooperativo do download.
class CancellationToken {
  bool _cancelled = false;
  final List<VoidCallback> _listeners = [];

  bool get isCancelled => _cancelled;

  void attach(VoidCallback onCancel) {
    if (_cancelled) {
      onCancel();
      return;
    }
    _listeners.add(onCancel);
  }

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final l in List<VoidCallback>.from(_listeners)) {
      l();
    }
    _listeners.clear();
  }
}
