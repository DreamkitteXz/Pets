import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';

/// Card padrão do design system: superfície agrupada, canto 16, sombra sutil
/// (clara) / contraste de superfície (escura). Tappable se [onTap] for dado.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.card,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final brightness = Theme.of(context).brightness;

    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? c.surfaceGroupedSecondary,
        borderRadius: AppRadius.card_,
        boxShadow: AppShadows.card(brightness),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card_,
        child: onTap == null
            ? content
            : Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  splashColor: c.tint(c.accentBlue, 0.06),
                  highlightColor: c.tint(c.accentBlue, 0.04),
                  child: content,
                ),
              ),
      ),
    );
  }
}
