import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../app_spacing.dart';

enum AppButtonVariant { primary, secondary, destructive }

/// Botão padrão (estilo web): preenchido azul (primary), tonalizado (secondary)
/// ou vermelho (destructive). Suporta estado [loading] e ícone opcional.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final bool fullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.fullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    Color bg;
    Color fg;
    switch (variant) {
      case AppButtonVariant.secondary:
        bg = c.tint(c.accentBlue, 0.12);
        fg = c.accentBlue;
        break;
      case AppButtonVariant.destructive:
        bg = c.accentRed;
        fg = Colors.white;
        break;
      case AppButtonVariant.primary:
        bg = c.accentBlue;
        fg = Colors.white;
        break;
    }

    final disabled = onPressed == null || loading;

    final child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                AppSpacing.gapSm,
              ],
              Text(label,
                  style: AppTypography.headline.copyWith(color: fg)),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: FilledButton(
        onPressed: disabled ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.4),
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape:
              const RoundedRectangleBorder(borderRadius: AppRadius.button_),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}
