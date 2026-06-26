import 'package:flutter/material.dart';

/// Tokens de cor semânticos do app, espelhando o design system "Apple/iOS" do
/// Website (src/index.css). Exposto como [ThemeExtension] para alternar
/// automaticamente entre light e dark via `Theme.of(context)`.
///
/// Use `context.colors` (extension abaixo) em vez de cores hardcoded.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  // Acentos (system colors)
  final Color accentBlue;
  final Color accentGreen;
  final Color accentRed;
  final Color accentOrange;
  final Color accentYellow;
  final Color accentPurple;
  final Color accentTeal;
  final Color accentIndigo;
  final Color accentPink;

  // Superfícies (agrupadas, estilo iOS settings)
  final Color surfacePrimary; // fundo de telas brancas
  final Color surfaceSecondary; // inputs / faixas
  final Color surfaceGrouped; // fundo de tela agrupada (lista)
  final Color surfaceGroupedSecondary; // cards sobre o agrupado
  final Color surfaceElevated; // sheets, menus

  // Texto (níveis de ênfase)
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  // Linhas/divisores
  final Color separator;

  const AppColors({
    required this.accentBlue,
    required this.accentGreen,
    required this.accentRed,
    required this.accentOrange,
    required this.accentYellow,
    required this.accentPurple,
    required this.accentTeal,
    required this.accentIndigo,
    required this.accentPink,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceGrouped,
    required this.surfaceGroupedSecondary,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.separator,
  });

  // ── Status clínico (eixo único pending|approved|rejected) ──────────────────
  /// Cor de destaque para um registro aguardando validação do vet.
  Color get statusPending => accentOrange;
  Color get statusApproved => accentGreen;
  Color get statusRejected => accentRed;

  /// Fundo tonalizado (chip/realce) a partir de um acento.
  Color tint(Color c, [double opacity = 0.12]) => c.withValues(alpha: opacity);

  static const AppColors light = AppColors(
    accentBlue: Color(0xFF007AFF),
    accentGreen: Color(0xFF34C759),
    accentRed: Color(0xFFFF3B30),
    accentOrange: Color(0xFFFF9500),
    accentYellow: Color(0xFFFFCC00),
    accentPurple: Color(0xFFAF52DE),
    accentTeal: Color(0xFF5AC8FA),
    accentIndigo: Color(0xFF5856D6),
    accentPink: Color(0xFFFF2D55),
    surfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF2F2F7),
    surfaceGrouped: Color(0xFFF2F2F7),
    surfaceGroupedSecondary: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    textPrimary: Color(0xD9000000), // rgba(0,0,0,0.85)
    textSecondary: Color(0x80000000), // 0.50
    textTertiary: Color(0x4D000000), // 0.30
    separator: Color(0x1F3C3C43), // rgba(60,60,67,0.12)
  );

  static const AppColors dark = AppColors(
    accentBlue: Color(0xFF0A84FF),
    accentGreen: Color(0xFF30D158),
    accentRed: Color(0xFFFF453A),
    accentOrange: Color(0xFFFF9F0A),
    accentYellow: Color(0xFFFFD60A),
    accentPurple: Color(0xFFBF5AF2),
    accentTeal: Color(0xFF5AC8FA),
    accentIndigo: Color(0xFF5856D6),
    accentPink: Color(0xFFFF2D55),
    surfacePrimary: Color(0xFF1C1C1E),
    surfaceSecondary: Color(0xFF2C2C2E),
    surfaceGrouped: Color(0xFF000000),
    surfaceGroupedSecondary: Color(0xFF1C1C1E),
    surfaceElevated: Color(0xFF1C1C1E),
    textPrimary: Color(0xEBFFFFFF), // rgba(255,255,255,0.92)
    textSecondary: Color(0x8CFFFFFF), // 0.55
    textTertiary: Color(0x4DFFFFFF), // 0.30
    separator: Color(0x8C545458), // rgba(84,84,88,0.55)
  );

  @override
  AppColors copyWith({
    Color? accentBlue,
    Color? accentGreen,
    Color? accentRed,
    Color? accentOrange,
    Color? accentYellow,
    Color? accentPurple,
    Color? accentTeal,
    Color? accentIndigo,
    Color? accentPink,
    Color? surfacePrimary,
    Color? surfaceSecondary,
    Color? surfaceGrouped,
    Color? surfaceGroupedSecondary,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? separator,
  }) {
    return AppColors(
      accentBlue: accentBlue ?? this.accentBlue,
      accentGreen: accentGreen ?? this.accentGreen,
      accentRed: accentRed ?? this.accentRed,
      accentOrange: accentOrange ?? this.accentOrange,
      accentYellow: accentYellow ?? this.accentYellow,
      accentPurple: accentPurple ?? this.accentPurple,
      accentTeal: accentTeal ?? this.accentTeal,
      accentIndigo: accentIndigo ?? this.accentIndigo,
      accentPink: accentPink ?? this.accentPink,
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceGrouped: surfaceGrouped ?? this.surfaceGrouped,
      surfaceGroupedSecondary:
          surfaceGroupedSecondary ?? this.surfaceGroupedSecondary,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      separator: separator ?? this.separator,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      accentGreen: Color.lerp(accentGreen, other.accentGreen, t)!,
      accentRed: Color.lerp(accentRed, other.accentRed, t)!,
      accentOrange: Color.lerp(accentOrange, other.accentOrange, t)!,
      accentYellow: Color.lerp(accentYellow, other.accentYellow, t)!,
      accentPurple: Color.lerp(accentPurple, other.accentPurple, t)!,
      accentTeal: Color.lerp(accentTeal, other.accentTeal, t)!,
      accentIndigo: Color.lerp(accentIndigo, other.accentIndigo, t)!,
      accentPink: Color.lerp(accentPink, other.accentPink, t)!,
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceSecondary:
          Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      surfaceGrouped: Color.lerp(surfaceGrouped, other.surfaceGrouped, t)!,
      surfaceGroupedSecondary: Color.lerp(
          surfaceGroupedSecondary, other.surfaceGroupedSecondary, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
    );
  }
}

/// Açúcar sintático: `context.colors.accentBlue`, etc.
extension AppColorsX on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
