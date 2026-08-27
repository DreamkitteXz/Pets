import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_app/design/design.dart';

/// O bloqueador de "não navega para a home" era de PILHA, não de decisão.
///
/// O roteador é a rota raiz do MaterialApp. O onboarding empilhava a LoginPage
/// por cima dele, então, ao autenticar, o roteador trocava o conteúdo da rota 0
/// e ninguém via — as telas de auth continuavam cobrindo.
///
/// Este teste reproduz a mecânica com widgets triviais (sem Firebase): mostra
/// que empilhar sobre a raiz esconde a troca, e que conter o fluxo num Navigator
/// aninhado — como o AuthFlow faz — resolve.
void main() {
  Widget app({required bool signedIn, required Widget signedOutChild}) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: signedIn ? const Text('HOME') : signedOutChild,
    );
  }

  testWidgets('reproduz o bug: push na raiz esconde a troca do roteador',
      (tester) async {
    // Fluxo antigo: a tela de auth empilha sobre a rota raiz.
    final onboarding = Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(body: Text('LOGIN'))),
            ),
            child: const Text('entrar'),
          ),
        ),
      ),
    );

    await tester.pumpWidget(app(signedIn: false, signedOutChild: onboarding));
    await tester.tap(find.text('entrar'));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);

    // Autentica: o roteador troca a rota raiz para a home...
    await tester.pumpWidget(app(signedIn: true, signedOutChild: onboarding));
    await tester.pumpAndSettle();

    // ...mas a LoginPage empilhada continua por cima. Era exatamente isto que
    // o usuário via.
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('correção: Navigator aninhado some junto com o fluxo',
      (tester) async {
    // Fluxo novo: o push acontece DENTRO da subárvore do AuthFlow.
    final authFlow = Navigator(
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('LOGIN'))),
              ),
              child: const Text('entrar'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(app(signedIn: false, signedOutChild: authFlow));
    await tester.tap(find.text('entrar'));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);

    // Autentica: o roteador troca o AuthFlow inteiro — a subárvore com a
    // LoginPage é descartada junto.
    await tester.pumpWidget(app(signedIn: true, signedOutChild: authFlow));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('LOGIN'), findsNothing);
  });
}
