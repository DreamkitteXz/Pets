import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/screens/components/pet_avatar.dart';

/// Regressão: [PetAvatar] não pode explodir quando o `PetAssetsService` está
/// sem inicializar.
///
/// `getImagePath`/`getSpeciesIcon` LANÇAM nesse estado, e o `main.dart` engole
/// a falha de `rootBundle.loadString('assets/config/pet_assets.json')` num
/// try/catch. Ou seja: um config ausente ou corrompido deixa o app rodando com
/// o serviço morto — e a exceção sairia de dentro do `build()`, onde nenhum
/// `errorBuilder` alcança, derrubando a lista de pets inteira.
///
/// Arquivo separado de propósito: `PetAssetsService` guarda estado estático e
/// não tem reset, então este teste precisa de um isolate onde ninguém chamou
/// `initialize()`.
void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );

  final pet = Pets(
    id: 'p1',
    name: 'Rex',
    species: 'dog',
    breed: 'beagle',
    gender: 'male',
  );

  testWidgets('serviço não inicializado: renderiza o ícone, sem exceção',
      (tester) async {
    await tester.pumpWidget(wrap(PetAvatar(pet: pet)));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('serviço não inicializado com foto: ainda tenta a rede',
      (tester) async {
    await tester.pumpWidget(wrap(PetAvatar(
      pet: Pets(
        id: 'p2',
        name: 'Mia',
        species: 'cat',
        imageUrl: 'https://example.invalid/foto.jpg',
      ),
    )));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
