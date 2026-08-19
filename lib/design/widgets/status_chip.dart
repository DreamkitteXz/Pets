import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../app_spacing.dart';

/// Eixo único de status clínico (espelha vaccines/deworming.status).
enum AppStatus { pending, approved, rejected }

/// Espelha `normalizeStatus` da web (src/utils/vaccineStatus.js): mapeia os
/// status do modelo antigo de dois eixos (vet + tutor) para o eixo único.
/// Sem isso, um registro legado `vetApproved` cai no `default` e o app mostra
/// "Aguardando validação" onde o site mostra "Aprovada".
AppStatus appStatusFromString(String? s) {
  switch (s) {
    case 'approved':
    case 'vetApproved':
    case 'tutorApproved':
      return AppStatus.approved;
    case 'rejected':
    case 'vetRejected':
    case 'tutorRejected':
      return AppStatus.rejected;
    case 'pending':
    default:
      return AppStatus.pending;
  }
}

/// Chip de status como conceito de 1ª classe na UI: 3 estados visuais
/// (Aguardando validação / Aprovada / Rejeitada), com cor, ícone e rótulo.
class StatusChip extends StatelessWidget {
  final AppStatus status;
  final bool compact;

  /// Rótulos padrão são femininos (vacina). Para vermífugo, passe [labels]
  /// no masculino (ex.: 'Aprovado').
  final Map<AppStatus, String>? labels;

  const StatusChip({
    super.key,
    required this.status,
    this.compact = false,
    this.labels,
  });

  factory StatusChip.fromString(String? status,
          {bool compact = false, Map<AppStatus, String>? labels}) =>
      StatusChip(
        status: appStatusFromString(status),
        compact: compact,
        labels: labels,
      );

  static const Map<AppStatus, String> _defaultLabels = {
    AppStatus.pending: 'Aguardando validação',
    AppStatus.approved: 'Aprovada',
    AppStatus.rejected: 'Rejeitada',
  };

  static const Map<AppStatus, IconData> _icons = {
    AppStatus.pending: Icons.schedule_rounded,
    AppStatus.approved: Icons.check_circle_rounded,
    AppStatus.rejected: Icons.cancel_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color color;
    switch (status) {
      case AppStatus.approved:
        color = c.statusApproved;
        break;
      case AppStatus.rejected:
        color = c.statusRejected;
        break;
      case AppStatus.pending:
        color = c.statusPending;
        break;
    }
    final label = (labels ?? _defaultLabels)[status]!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: c.tint(color, 0.12),
        borderRadius: AppRadius.pill_,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icons[status], size: compact ? 12 : 14, color: color),
          SizedBox(width: compact ? 4 : 6),
          Text(
            label,
            style: (compact ? AppTypography.caption : AppTypography.footnote)
                .copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
