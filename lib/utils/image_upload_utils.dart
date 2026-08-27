import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Regras de upload de imagem para o Firebase Storage, compartilhadas pelas
/// duas telas que enviam foto (rótulo de vacina e foto do pet).
///
/// Existe porque a `storage.rule` impõe DUAS condições que o cliente precisa
/// satisfazer explicitamente, e errar qualquer uma delas dá `unauthorized`:
///
///   allow write: if request.resource.size < 5 * 1024 * 1024
///             && request.resource.contentType.matches('image/.*');
///
/// 1. **contentType** — o SDK infere o tipo pela EXTENSÃO do arquivo no
///    Storage. Nome sem extensão vira `application/octet-stream`, que não casa
///    com `image/*` e a regra recusa. Por isso o nome sempre leva extensão E o
///    metadata vai explícito.
/// 2. **tamanho** — foto de câmera em resolução cheia passa de 5 MB fácil, e
///    o `image_picker` só recomprime quando recebe maxWidth/imageQuality.
class ImageUploadUtils {
  ImageUploadUtils._();

  /// Teto da `storage.rule`. Serve para falhar cedo, com mensagem clara, em
  /// vez de tomar um `unauthorized` opaco do servidor.
  static const int maxBytes = 5 * 1024 * 1024;

  /// Extensão em minúsculas, sem ponto. `jpg` quando o nome não tem uma —
  /// nunca string vazia, senão o arquivo sobe sem extensão de novo.
  static String extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1 || dot == fileName.length - 1) return 'jpg';
    final ext = fileName.substring(dot + 1).toLowerCase();
    return ext.isEmpty ? 'jpg' : ext;
  }

  static String contentTypeFor(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
      case 'heif':
        return 'image/heic';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  /// Sobe [file] e devolve a URL de download.
  ///
  /// [timeout] evita o spinner infinito: o retry padrão do Storage é de 10
  /// minutos, tempo em que a tela fica parada sem explicar nada.
  static Future<String> upload({
    required Reference ref,
    required File file,
    required String extension,
    void Function(int transferred, int total)? onProgress,
    Duration timeout = const Duration(seconds: 90),
  }) async {
    final bytes = await file.length();
    if (bytes > maxBytes) {
      throw StateError(
          'A imagem tem ${(bytes / 1024 / 1024).toStringAsFixed(1)} MB e o '
          'limite é 5 MB.');
    }

    final task = ref.putFile(
      file,
      SettableMetadata(contentType: contentTypeFor(extension)),
    );

    final sub = onProgress == null
        ? null
        : task.snapshotEvents.listen(
            (s) => onProgress(s.bytesTransferred, s.totalBytes),
            onError: (_) {},
          );

    try {
      await task.timeout(timeout, onTimeout: () {
        task.cancel();
        throw StateError(
            'O envio passou de ${timeout.inSeconds}s sem concluir.');
      });
    } finally {
      await sub?.cancel();
    }

    return ref.getDownloadURL().timeout(const Duration(seconds: 30));
  }
}
