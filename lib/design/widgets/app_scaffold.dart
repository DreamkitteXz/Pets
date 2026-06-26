import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../app_spacing.dart';

/// Scaffold padrão com header de "título grande" estilo iOS: fundo agrupado,
/// título 28px e ações à direita. [body] já recebe padding horizontal de tela.
class AppScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final bool showBack;
  final bool bodyPadding;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
    this.floatingActionButton,
    this.showBack = false,
    this.bodyPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.surfaceGrouped,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
              child: Row(
                children: [
                  if (showBack)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20),
                        color: c.textPrimary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: AppTypography.largeTitle
                                .copyWith(color: c.textPrimary)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle!,
                              style: AppTypography.callout
                                  .copyWith(color: c.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: bodyPadding
                    ? const EdgeInsets.symmetric(horizontal: AppSpacing.lg)
                    : EdgeInsets.zero,
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
