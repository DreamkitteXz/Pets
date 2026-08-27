import 'package:flutter_test/flutter_test.dart';
import 'package:pet_app/utils/image_upload_utils.dart';

/// A `storage.rule` exige `contentType.matches('image/.*')`, e o SDK do
/// Storage deriva o contentType da EXTENSÃO do nome do arquivo. O upload do
/// rótulo de vacina gravava só o timestamp (`1735123456789012`, sem extensão),
/// o tipo virava `application/octet-stream` e a regra recusava — o envio
/// falhava sempre.
///
/// Estes testes travam as duas garantias que impedem a volta disso:
/// nunca devolver extensão vazia, e nunca devolver um contentType fora de
/// `image/*`.
void main() {
  group('extensionOf', () {
    test('extrai a extensão em minúsculas', () {
      expect(ImageUploadUtils.extensionOf('foto.JPG'), 'jpg');
      expect(ImageUploadUtils.extensionOf('rotulo.png'), 'png');
      expect(ImageUploadUtils.extensionOf('img.HEIC'), 'heic');
    });

    test('nome sem extensão cai em jpg — nunca vazio', () {
      // Exatamente o caso do bug: o nome era só o timestamp.
      expect(ImageUploadUtils.extensionOf('1735123456789012'), 'jpg');
      expect(ImageUploadUtils.extensionOf(''), 'jpg');
      expect(ImageUploadUtils.extensionOf('arquivo.'), 'jpg');
    });

    test('usa só o último ponto', () {
      expect(ImageUploadUtils.extensionOf('a.b.c.png'), 'png');
    });
  });

  group('contentTypeFor', () {
    test('mapeia os formatos que a câmera/galeria produzem', () {
      expect(ImageUploadUtils.contentTypeFor('png'), 'image/png');
      expect(ImageUploadUtils.contentTypeFor('webp'), 'image/webp');
      expect(ImageUploadUtils.contentTypeFor('heic'), 'image/heic');
      expect(ImageUploadUtils.contentTypeFor('heif'), 'image/heic');
      expect(ImageUploadUtils.contentTypeFor('gif'), 'image/gif');
      expect(ImageUploadUtils.contentTypeFor('jpg'), 'image/jpeg');
      expect(ImageUploadUtils.contentTypeFor('jpeg'), 'image/jpeg');
    });

    test('extensão desconhecida ainda satisfaz a regra image/*', () {
      // O default NÃO pode ser application/octet-stream: a regra recusaria.
      for (final ext in ['', 'bin', 'pdf', 'xyz']) {
        expect(ImageUploadUtils.contentTypeFor(ext), startsWith('image/'),
            reason: 'extensão "$ext" produziu tipo fora de image/*');
      }
    });
  });

  test('qualquer nome de arquivo termina em um contentType image/*', () {
    const nomes = [
      '1735123456789012', // o caso do bug
      'foto.jpg',
      'scan.PNG',
      'sem_ponto',
      '.oculto',
      'a.b.heic',
    ];
    for (final nome in nomes) {
      final ext = ImageUploadUtils.extensionOf(nome);
      expect(ext, isNotEmpty, reason: nome);
      expect(ImageUploadUtils.contentTypeFor(ext), startsWith('image/'),
          reason: nome);
    }
  });
}
