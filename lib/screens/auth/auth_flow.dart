import 'package:flutter/material.dart';

import 'package:pet_app/screens/onboarding_screen.dart';

/// Fluxo de autenticação (onboarding → login → cadastro) num Navigator PRÓPRIO.
///
/// **Por que aninhado.** Antes o onboarding fazia `Navigator.push(LoginPage)` no
/// navigator raiz — e o roteador de telas É a rota raiz. A pilha ficava assim:
///
///     [0] RoteadorTelas   ← trocava para a home aqui embaixo
///     [1] LoginPage       ← continuava por cima, cobrindo a home
///     [2] SignUpPage
///
/// Ao autenticar, o roteador de fato trocava o conteúdo da rota 0, mas ninguém
/// via: as telas de auth nunca eram removidas. Era esse o bug de "não navega
/// para a home".
///
/// Com o Navigator aninhado, todo push de login/cadastro acontece DENTRO desta
/// subárvore. Quando o usuário autentica, o roteador troca o [AuthFlow] inteiro
/// pela home e a subárvore é descartada junto — não sobra rota órfã por cima.
class AuthFlow extends StatelessWidget {
  const AuthFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();

    return PopScope(
      // O voltar do Android precisa andar DENTRO do fluxo (cadastro → login →
      // onboarding) antes de sair do app. Sem isto, o Navigator aninhado
      // engoliria o gesto e o botão pareceria morto.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = navigatorKey.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        }
      },
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const OnBoarding(),
        ),
      ),
    );
  }
}
