import 'package:flutter_test/flutter_test.dart';
import 'package:pet_app/utils/weight_utils.dart';

/// A regressão que importa aqui é perda silenciosa de dado.
///
/// A conversão estava espalhada: algumas telas trocavam vírgula por ponto
/// antes do parse, outras chamavam `double.tryParse` direto. Nas segundas,
/// "10,5" — a notação brasileira, sugerida pelo próprio hint do campo — virava
/// `null`, que o `?? 0.0` transformava em **zero** e gravava como peso do
/// animal. Sem erro na tela, sem log.
void main() {
  group('parse', () {
    test('aceita vírgula — era o caso que virava 0.0 em silêncio', () {
      expect(WeightUtils.parse('10,5'), 10.5);
      expect(WeightUtils.parse('0,8'), 0.8);
    });

    test('aceita ponto', () {
      expect(WeightUtils.parse('10.5'), 10.5);
      expect(WeightUtils.parse('32'), 32);
    });

    test('ignora espaço em volta', () {
      expect(WeightUtils.parse('  4,2  '), 4.2);
    });

    test('devolve null, nunca 0.0, quando não dá para ler', () {
      // A distinção existe porque zero é digitável: confundir "não entendi"
      // com "o usuário escreveu 0" foi exatamente o defeito original.
      for (final entrada in [null, '', '   ', 'abc', ',', '.']) {
        expect(WeightUtils.parse(entrada), isNull, reason: 'entrada: $entrada');
      }
    });

    test('recusa valores que nenhum animal tem', () {
      expect(WeightUtils.parse('0'), isNull);
      expect(WeightUtils.parse('-3'), isNull);
    });
  });

  group('format', () {
    test('usa vírgula decimal', () {
      expect(WeightUtils.format(10.5), '10,5');
      expect(WeightUtils.format(32), '32,0');
    });

    test('corta o ruído de ponto flutuante', () {
      expect(WeightUtils.format(10.4300000000000001), '10,4');
    });

    test('null vira string vazia, não "null"', () {
      expect(WeightUtils.format(null), '');
    });
  });

  test('ida e volta preserva o valor', () {
    for (final kg in [0.5, 4.2, 10.5, 32.0, 68.7]) {
      expect(WeightUtils.parse(WeightUtils.format(kg)), kg);
    }
  });
}
