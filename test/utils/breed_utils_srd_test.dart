import 'package:flutter_test/flutter_test.dart';
import 'package:pet_app/utils/breed_utils.dart';

/// Cobre as duas reclamações sobre o campo de raça: faltava SRD, e a lista não
/// vinha ordenada.
///
/// As raças de gato eram uma lista fixa escrita na ordem em que alguém as
/// digitou no código, e o campo é obrigatório — sem SRD, quem tem vira-lata
/// precisava escolher uma raça errada para conseguir salvar.
void main() {
  test('gatos: SRD primeiro e o resto em ordem alfabética', () async {
    final racas = await BreedUtils.fetchCatBreeds();

    expect(racas.first, BreedUtils.semRacaDefinida);

    final resto = racas.skip(1).toList();
    final ordenado = [...resto]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    expect(resto, ordenado, reason: 'a lista fixa não estava ordenada');
  });

  test('SRD aparece uma única vez', () async {
    final racas = await BreedUtils.fetchCatBreeds();
    expect(racas.where((r) => r == BreedUtils.semRacaDefinida).length, 1);
  });

  test('a lista nunca volta vazia', () async {
    // O validador do campo exige seleção. Lista vazia — rede fora, API mudada
    // — travaria o cadastro do pet inteiro sem explicação.
    expect((await BreedUtils.fetchCatBreeds()), isNotEmpty);
  });
}
