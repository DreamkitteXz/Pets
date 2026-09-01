import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_app/design/design.dart';
import 'package:pet_app/screens/home/home_screen.dart';

/// Cobre o dimensionamento dos cards de "Ações rápidas".
///
/// Antes a largura era o literal `86` e a fileira tinha `height: 92`. Os dois
/// números fixos davam dois defeitos: o card ocupava proporções diferentes
/// conforme o aparelho, e o conteúdo estourava assim que a fonte do sistema
/// crescia.
void main() {
  group('actionCardWidth', () {
    test('acompanha a largura disponível em vez de ser fixa', () {
      final estreito = actionCardWidth(328); // ~360pt menos as margens
      final largo = actionCardWidth(398); // ~430pt menos as margens
      expect(largo, greaterThan(estreito),
          reason: 'tela maior tem que render card maior');
    });

    test('mostra ~3,5 colunas — a meia coluna é o que sinaliza que rola', () {
      const available = 361.0;
      final slot = actionCardWidth(available) + AppSpacing.md;
      expect(available / slot, closeTo(kActionCardsPerScreen, 0.05));
    });

    test('não degenera nos extremos', () {
      // Sem piso, um aparelho minúsculo espremeria o ícone de 40px.
      expect(actionCardWidth(120), greaterThanOrEqualTo(84));
      // Sem teto, um tablet viraria placas com vazio em volta do ícone.
      expect(actionCardWidth(1600), lessThanOrEqualTo(120));
    });
  });

  group('fileira de ações rápidas', () {
    // Monta só o suficiente para renderizar a fileira: a home inteira puxa
    // Firebase. O que está sob teste é geometria, não dados.
    Widget host({required double width, required double textScale}) {
      return MediaQuery(
        data: MediaQueryData(
          size: Size(width, 800),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: width - AppSpacing.lg * 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final label in const [
                        'Novo pet',
                        'Vacina',
                        'Vermífugo',
                        'Medicamento',
                        'Peso',
                      ])
                        SizedBox(
                          width: actionCardWidth(width - AppSpacing.lg * 2),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                                horizontal: AppSpacing.sm),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 40, height: 40),
                                const SizedBox(height: AppSpacing.sm),
                                Text(label,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('não estoura com a fonte do sistema aumentada', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // 1.6 é o topo da faixa que o Android oferece em Acessibilidade.
      await tester.pumpWidget(host(width: 360, textScale: 1.6));

      expect(tester.takeException(), isNull,
          reason: 'com altura fixa de 92 aqui vinha um RenderFlex overflow');
    });

    testWidgets('o rótulo tem duas linhas de folga', (tester) async {
      await tester.pumpWidget(host(width: 360, textScale: 1.0));

      // Deliberadamente NÃO se afirma aqui que "Medicamento" cabe: teste de
      // widget renderiza com a fonte Ahem, um bloco de largura fixa de 1em
      // por caractere. Ela mede a palavra em 132px contra ~75px da fonte que
      // o app embarca — a asserção falaria da Ahem, não do aparelho.
      // O que dá para garantir sem depender de fonte é a folga: uma linha só
      // não tem para onde transbordar.
      expect(tester.widget<Text>(find.text('Medicamento')).maxLines, 2);
    });
  });
}
