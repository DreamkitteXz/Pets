import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// [ThemeData] do Material 3 calibrado para o visual "Apple/clean" do Website,
/// com light e dark derivados dos mesmos tokens ([AppColors]).
class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.accentBlue,
      onPrimary: Colors.white,
      secondary: c.accentIndigo,
      onSecondary: Colors.white,
      error: c.accentRed,
      onError: Colors.white,
      surface: c.surfaceGroupedSecondary,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.surfaceSecondary,
      outline: c.separator,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.surfaceGrouped,
      canvasColor: c.surfaceGrouped,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme(c.textPrimary),
      extensions: [c],
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: c.surfaceGrouped,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headline.copyWith(color: c.textPrimary),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: c.surfaceGroupedSecondary,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card_),
        clipBehavior: Clip.antiAlias,
      ),

      dividerTheme: DividerThemeData(
        color: c.separator,
        thickness: 1,
        space: 1,
      ),

      iconTheme: IconThemeData(color: c.textSecondary),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accentBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: c.accentBlue.withValues(alpha: 0.4),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button_),
          textStyle: AppTypography.headline,
          elevation: 0,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.accentBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button_),
          textStyle: AppTypography.headline,
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accentBlue,
          textStyle: AppTypography.callout.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceSecondary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: AppTypography.callout.copyWith(color: c.textTertiary),
        labelStyle: AppTypography.callout.copyWith(color: c.textSecondary),
        border: OutlineInputBorder(
          borderRadius: AppRadius.button_,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.button_,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.button_,
          borderSide: BorderSide(color: c.accentBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.button_,
          borderSide: BorderSide(color: c.accentRed, width: 1.5),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceElevated,
        modalBackgroundColor: c.surfaceElevated,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card_),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? c.accentGreen // verde iOS
                : c.surfaceSecondary),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surfaceElevated,
        contentTextStyle: AppTypography.callout.copyWith(color: c.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button_),
      ),

      progressIndicatorTheme:
          ProgressIndicatorThemeData(color: c.accentBlue),
    );
  }
}
