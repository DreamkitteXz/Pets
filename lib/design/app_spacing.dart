import 'package:flutter/material.dart';

/// Escala de espaçamento (múltiplos de 4), espelhando o ritmo do Website.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // Gaps prontos
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);

  // Padding padrão de tela / card
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets card = EdgeInsets.all(lg);
}

/// Raios de canto (cards 16, botões/inputs 10/12, pílula 999).
class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double button = 12;
  static const double card = 16;
  static const double lg = 20;
  static const double pill = 999;

  static const Radius rCard = Radius.circular(card);
  static const BorderRadius card_ = BorderRadius.all(rCard);
  static const BorderRadius button_ = BorderRadius.all(Radius.circular(button));
  static const BorderRadius pill_ = BorderRadius.all(Radius.circular(pill));
}

/// Sombras sutis (estilo "Apple": 0 1px 3px rgba(0,0,0,0.06)).
class AppShadows {
  static List<BoxShadow> card(Brightness b) => b == Brightness.dark
      ? const [] // no dark, o contraste de superfície já separa o card
      : const [
          BoxShadow(
            color: Color(0x0F000000), // ~rgba(0,0,0,0.06)
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ];

  static List<BoxShadow> elevated(Brightness b) => b == Brightness.dark
      ? const [
          BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 8)),
        ]
      : const [
          BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 8)),
        ];
}

/// Durações de animação consistentes.
class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
}
