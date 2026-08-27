import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_app/design/design.dart';

/// Regressão: `AppButton(fullWidth: false)` estourava o layout dentro de um pai
/// de largura ILIMITADA (Row, Wrap, ListView horizontal).
///
/// A causa era `minimumSize: Size.fromHeight(50)`, que é `Size(infinity, 50)`:
/// largura mínima infinita. Num pai de largura limitada isso só significa
/// "ocupa tudo", então o bug ficou latente enquanto o botão compacto só era
/// usado dentro de Column/Center.
void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('compacto dentro de Row (largura ilimitada) não estoura',
      (tester) async {
    await tester.pumpWidget(wrap(
      Row(
        children: [
          const Expanded(child: Text('Aguardando')),
          AppButton(
            label: 'Confirmar ciência',
            icon: Icons.check_rounded,
            fullWidth: false,
            onPressed: () {},
          ),
        ],
      ),
    ));

    expect(tester.takeException(), isNull);

    // Largura finita e proporcional ao conteúdo — não a tela inteira.
    final width = tester.getSize(find.byType(AppButton)).width;
    expect(width, lessThan(tester.view.physicalSize.width));
    expect(width, greaterThan(0));
  });

  testWidgets('compacto mantém a altura de 50 do design system',
      (tester) async {
    await tester.pumpWidget(wrap(
      Row(
        children: [
          AppButton(label: 'Ok', fullWidth: false, onPressed: () {}),
        ],
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(AppButton)).height, 50);
  });

  testWidgets('só ícone (label vazio) cabe na largura do voltar do wizard',
      (tester) async {
    // Geometria exata do WizardShell: SizedBox de 56 menos 32 de padding
    // horizontal do botão = 24px úteis. Com o gap + Text vazio dava 26.
    await tester.pumpWidget(wrap(
      SizedBox(
        width: 56,
        child: AppButton(
          label: '',
          icon: Icons.arrow_back_rounded,
          variant: AppButtonVariant.secondary,
          fullWidth: false,
          onPressed: () {},
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(AppButton)).width, 56);
  });

  testWidgets('fullWidth continua ocupando a largura disponível',
      (tester) async {
    await tester.pumpWidget(wrap(
      SizedBox(
        width: 300,
        child: AppButton(label: 'Salvar', onPressed: () {}),
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(AppButton)).width, 300);
  });
}
