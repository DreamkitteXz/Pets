import 'package:flutter/material.dart';

import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/medication_model.dart';

/// Cor da fase do tratamento.
///
/// Deliberadamente NÃO usa `statusPending/Approved/Rejected`: aquelas cores
/// carregam o significado "decisão do veterinário", e medicamento é auto-relato
/// do tutor. Ver [MedicationStage].
Color medicationStageColor(BuildContext context, MedicationStage stage) {
  final c = context.colors;
  switch (stage) {
    case MedicationStage.ongoing:
      return c.accentGreen;
    case MedicationStage.scheduled:
      return c.accentBlue;
    case MedicationStage.finished:
      return c.textTertiary;
  }
}

IconData medicationStageIcon(MedicationStage stage) {
  switch (stage) {
    case MedicationStage.ongoing:
      return Icons.play_circle_fill_rounded;
    case MedicationStage.scheduled:
      return Icons.schedule_rounded;
    case MedicationStage.finished:
      return Icons.check_circle_rounded;
  }
}

/// Pílula "Em uso / Agendado / Encerrado" — mesmo desenho do [StatusChip]
/// (pílula tonalizada com ícone + rótulo), outro vocabulário.
class MedicationStageChip extends StatelessWidget {
  final MedicationStage stage;
  final bool compact;

  const MedicationStageChip({
    super.key,
    required this.stage,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = medicationStageColor(context, stage);

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
          Icon(medicationStageIcon(stage),
              size: compact ? 12 : 14, color: color),
          SizedBox(width: compact ? 4 : 6),
          Text(
            medicationStageLabels[stage]!,
            style: (compact ? AppTypography.caption : AppTypography.footnote)
                .copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
