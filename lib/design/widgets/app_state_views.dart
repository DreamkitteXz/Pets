import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../app_spacing.dart';
import 'app_button.dart';

/// Spinner centralizado com mensagem opcional.
class AppLoading extends StatelessWidget {
  final String? message;
  const AppLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: c.accentBlue),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(message!,
                style: AppTypography.callout.copyWith(color: c.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Estado vazio: ícone + título + mensagem + ação opcional.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.tint(c.accentBlue, 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: c.accentBlue),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title,
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(color: c.textPrimary)),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(message!,
                  textAlign: TextAlign.center,
                  style:
                      AppTypography.callout.copyWith(color: c.textSecondary)),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  fullWidth: false),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado de erro: ícone + mensagem + "Tentar novamente".
class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.tint(c.accentRed, 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 30, color: c.accentRed),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTypography.callout.copyWith(color: c.textSecondary)),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Tentar novamente',
                onPressed: onRetry,
                variant: AppButtonVariant.secondary,
                fullWidth: false,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bloco "esqueleto" (placeholder pulsante) para listas em carregamento.
class AppSkeleton extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius? radius;
  const AppSkeleton({super.key, this.height = 16, this.width, this.radius});

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 0.9).animate(_ctrl),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: c.surfaceSecondary,
          borderRadius: widget.radius ??
              const BorderRadius.all(Radius.circular(AppRadius.sm)),
        ),
      ),
    );
  }
}
