import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../app_spacing.dart';
import 'app_card.dart';

/// Bloco de "ficha" estilo iOS: cabeçalho em caixa alta e um card com linhas
/// `rótulo → valor` separadas por hairline.
///
/// Estava copiado em cada tela de detalhe (vacina, vermífugo) — o terceiro
/// detalhe (medicamento) virou o momento de subir para o design system.
class AppInfoGroup extends StatelessWidget {
  final String header;
  final Map<String, String> rows;

  const AppInfoGroup({super.key, required this.header, required this.rows});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final entries = rows.entries.toList();
    final children = <Widget>[];

    for (var i = 0; i < entries.length; i++) {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entries[i].key,
                style: AppTypography.callout.copyWith(color: c.textSecondary)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(entries[i].value,
                  textAlign: TextAlign.right,
                  style: AppTypography.callout.copyWith(color: c.textPrimary)),
            ),
          ],
        ),
      ));
      if (i != entries.length - 1) {
        children.add(Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          child: Divider(height: 1, thickness: 1, color: c.separator),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs, 0, AppSpacing.xs, AppSpacing.sm),
          child: Text(header.toUpperCase(),
              style: AppTypography.caption
                  .copyWith(color: c.textTertiary, letterSpacing: 0.5)),
        ),
        AppCard(padding: EdgeInsets.zero, child: Column(children: children)),
      ],
    );
  }
}
