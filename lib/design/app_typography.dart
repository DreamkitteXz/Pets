import 'package:flutter/material.dart';

/// Escala tipográfica estilo iOS/SF, aproximada no Android com a família
/// **Inter** (já empacotada no pubspec) — espelha o stack do Website
/// (-apple-system / SF Pro / Inter).
class AppTypography {
  static const String fontFamily = 'Inter';

  // Títulos
  static const TextStyle largeTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4, // ~ -0.02em
    height: 1.15,
  );
  static const TextStyle title1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );
  static const TextStyle title2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  // Corpo
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );
  static const TextStyle callout = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle subhead = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle footnote = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// Mapeia a escala para um [TextTheme] do Material 3, tingindo com [color].
  static TextTheme textTheme(Color color) {
    TextStyle c(TextStyle s) => s.copyWith(color: color);
    return TextTheme(
      displayLarge: c(largeTitle),
      headlineLarge: c(largeTitle),
      headlineMedium: c(title1),
      headlineSmall: c(title2),
      titleLarge: c(title2),
      titleMedium: c(headline),
      titleSmall: c(subhead),
      bodyLarge: c(body),
      bodyMedium: c(callout),
      bodySmall: c(footnote),
      labelLarge: c(headline),
      labelMedium: c(subhead),
      labelSmall: c(caption),
    );
  }
}
