import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../app_spacing.dart';
import 'app_card.dart';

/// Linha de lista agrupada estilo iOS. Ícone opcional em quadrado tonalizado,
/// título/subtítulo e chevron automático quando [onTap] é dado.
class AppListTile extends StatelessWidget {
  final IconData? leadingIcon;
  final Color? leadingColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AppListTile({
    super.key,
    required this.title,
    this.leadingIcon,
    this.leadingColor,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = leadingColor ?? c.accentBlue;

    Widget row = Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: c.tint(accent, 0.12),
                borderRadius:
                    const BorderRadius.all(Radius.circular(AppRadius.sm)),
              ),
              child: Icon(leadingIcon, size: 18, color: accent),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style:
                        AppTypography.callout.copyWith(color: c.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: AppTypography.footnote
                          .copyWith(color: c.textSecondary)),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: c.textTertiary, size: 22),
        ],
      ),
    );

    if (onTap == null) return row;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

/// Agrupa [AppListTile]s num card com divisores entre eles (estilo iOS).
class AppListSection extends StatelessWidget {
  final String? header;
  final List<Widget> children;
  const AppListSection({super.key, required this.children, this.header});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final divided = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      divided.add(children[i]);
      if (i != children.length - 1) {
        divided.add(Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          child: Divider(height: 1, thickness: 1, color: c.separator),
        ));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            child: Text(header!.toUpperCase(),
                style: AppTypography.caption.copyWith(
                    color: c.textTertiary, letterSpacing: 0.5)),
          ),
        ],
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: divided),
        ),
      ],
    );
  }
}
