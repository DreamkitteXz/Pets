import 'package:flutter/material.dart';
import 'package:pet_app/models/deworming_model.dart';
import 'package:pet_app/design/design.dart';

/// Detalhe do vermífugo (tutor) — repaginado sobre o design system.
/// O modelo Vermifugo não possui validationDetails/tutorAcknowledged, então
/// exibe status + dados (sem bloco de validação do vet / ciência — gap
/// sinalizado: exige campo no modelo + CF de validação de vermífugo).
class VermifugoPage extends StatelessWidget {
  final Vermifugo vermifugo;
  final String petId;
  const VermifugoPage(
      {super.key, required this.vermifugo, required this.petId});

  static const Map<AppStatus, String> _labels = {
    AppStatus.pending: 'Aguardando validação',
    AppStatus.approved: 'Aprovado',
    AppStatus.rejected: 'Rejeitado',
  };

  String _fmt(DateTime? d) => d == null
      ? 'N/D'
      : '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final v = vermifugo;
    final status = appStatusFromString(v.status);

    return AppScaffold(
      title: v.name ?? 'Vermífugo',
      showBack: true,
      bodyPadding: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: StatusChip(status: status, compact: true, labels: _labels),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl),
        children: [
          _statusCard(context, status),
          const SizedBox(height: AppSpacing.lg),
          AppInfoGroup(header: 'Dados do vermífugo', rows: {
            'Aplicado em': _fmt(v.administrationDate),
            if (v.isReinforcementNeeded == true)
              'Reforço': _fmt(v.reinforcementDate),
            'Fabricante': v.manufacturer ?? 'N/D',
            'Dosagem': v.dosage ?? 'N/D',
            if ((v.weight ?? 0) > 0) 'Peso do pet': '${v.weight} kg',
          }),
          const SizedBox(height: AppSpacing.lg),
          AppInfoGroup(header: 'Veterinário', rows: {
            'Nome': v.veterinarianName ?? 'N/D',
            'CRMV': v.crmvNumber ?? 'N/D',
          }),
          if ((v.clinicName ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            AppInfoGroup(header: 'Clínica', rows: {'Nome': v.clinicName!}),
          ],
          if ((v.effectivenessNotes ?? '').isNotEmpty ||
              (v.observations ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            AppInfoGroup(header: 'Observações', rows: {
              if ((v.effectivenessNotes ?? '').isNotEmpty)
                'Efetividade': v.effectivenessNotes!,
              if ((v.observations ?? '').isNotEmpty)
                'Gerais': v.observations!,
            }),
          ],
        ],
      ),
    );
  }

  Widget _statusCard(BuildContext context, AppStatus status) {
    final c = context.colors;
    Color color;
    IconData icon;
    String title;
    switch (status) {
      case AppStatus.approved:
        color = c.statusApproved;
        icon = Icons.check_circle_rounded;
        title = 'Vermífugo aprovado';
        break;
      case AppStatus.rejected:
        color = c.statusRejected;
        icon = Icons.cancel_rounded;
        title = 'Vermífugo rejeitado';
        break;
      case AppStatus.pending:
        color = c.statusPending;
        icon = Icons.schedule_rounded;
        title = 'Aguardando validação';
        break;
    }
    return AppCard(
      color: c.tint(color, 0.10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(title,
                style: AppTypography.headline.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
