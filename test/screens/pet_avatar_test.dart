import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/screens/components/pet_avatar.dart';
import 'package:pet_app/services/pet_assets_service.dart';

/// Miniatura do pet com o [PetAssetsService] inicializado (o caso normal).
///
/// A resiliência ao serviço NÃO inicializado é coberta em
/// `pet_avatar_uninitialized_test.dart` — arquivo separado porque
/// `PetAssetsService` guarda estado estático sem reset.
void main() {
  setUpAll(() {
    // Mesma forma do assets/config/pet_assets.json, só o suficiente para
    // resolver uma raça conhecida.
    PetAssetsService.initialize(<String, dynamic>{
      'types': {
        'dog': {
          'icon': 'pets',
          'races': {
            'beagle': {
              'gender': {
                'male': {'imageKey': 'beagleMaleImage'},
              },
            },
          },
        },
      },
    });
  });

  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );

  Pets petWith({String? imageUrl, String? species = 'dog', String? breed}) =>
      Pets(
        id: 'p1',
        name: 'Rex',
        species: species,
        breed: breed ?? 'beagle',
        gender: 'male',
        imageUrl: imageUrl,
      );

  testWidgets('sem foto: usa a ilustração local', (tester) async {
    await tester.pumpWidget(wrap(PetAvatar(pet: petWith())));
    await tester.pump();

    expect(tester.takeException(), isNull);
    final images = tester.widgetList<Image>(find.byType(Image));
    expect(images.any((i) => i.image is AssetImage), isTrue);
    expect(images.any((i) => i.image is NetworkImage), isFalse);
  });

  testWidgets('com foto: usa Image.network', (tester) async {
    await tester.pumpWidget(wrap(PetAvatar(
      pet: petWith(imageUrl: 'https://example.invalid/foto.jpg'),
    )));
    await tester.pump();

    // Em teste toda Image.network falha (HTTP 400 do mock), então isto também
    // exercita o errorBuilder — o fallback não pode derrubar a lista.
    expect(tester.takeException(), isNull);
    final images = tester.widgetList<Image>(find.byType(Image));
    expect(images.any((i) => i.image is NetworkImage), isTrue);
  });

  testWidgets('raça desconhecida cai no asset padrão, sem exceção',
      (tester) async {
    await tester.pumpWidget(wrap(PetAvatar(pet: petWith(breed: 'inexistente'))));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(PetAvatar), findsOneWidget);
  });

  testWidgets('respeita o tamanho pedido', (tester) async {
    await tester.pumpWidget(wrap(PetAvatar(pet: petWith(), size: 52)));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(PetAvatar)), const Size(52, 52));
  });
}
