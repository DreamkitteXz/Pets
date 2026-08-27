import 'package:flutter/material.dart';

import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/medication_model.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/repositories/medication_repository.dart';
import 'package:pet_app/screens/medications/add_medication_screen.dart';
import 'package:pet_app/screens/medications/medication_screen.dart';
import 'package:pet_app/screens/medications/medication_stage_chip.dart';

/// Medicamentos do pet, agrupados por fase do tratamento (Em uso / Agendados /
/// Encerrados). Registro do tutor — sem eixo de validação do veterinário.
class MedicamentosPage extends StatelessWidget {
  final Pets pet;

  const MedicamentosPage({super.key, required this.pet});

  static const List<MedicationStage> _order = [
    MedicationStage.ongoing,
    MedicationStage.scheduled,
    MedicationStage.finished,
  ];

  static const Map<MedicationStage, String> _sectionTitles = {
    MedicationStage.ongoing: 'EM USO',
    MedicationStage.scheduled: 'AGENDADOS',
    MedicationStage.finished: 'ENCERRADOS',
  };

  @override
  Widget build(BuildContext context) {
    final repository = MedicationRepository();

    return AppScaffold(
      title: 'Medicamentos',
      subtitle: pet.name,
      showBack: true,
      bodyPadding: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        backgroundColor: context.colors.accentBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: StreamBuilder<List<Medicamento>>(
        stream: repository.medicationsStream(pet.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const AppErrorState(
                message:
                    'Não foi possível carregar os medicamentos deste pet.');
          }
          if (!snapshot.hasData) return const AppLoading();

          final medications = snapshot.data!;
          if (medications.isEmpty) {
            return AppEmptyState(
              icon: Icons.medication_liquid_rounded,
              title: 'Nenhum medicamento',
              message: 'Registre o que ${pet.name ?? 'seu pet'} está tomando '
                  'para acompanhar dose, frequência e duração do tratamento.',
              actionLabel: 'Adicionar medicamento',
              onAction: () => _openForm(context),
            );
          }

          final children = <Widget>[];
          for (final stage in _order) {
            final group = medications.where((m) => m.stage == stage).toList();
            if (group.isEmpty) continue;
            children.add(Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
              child: Text(
                _sectionTitles[stage]!,
                style: AppTypography.caption.copyWith(
                    color: context.colors.textTertiary, letterSpacing: 0.5),
              ),
            ));
            for (final medication in group) {
              children.add(CardMedicamento(pet: pet, model: medication));
            }
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxl + 56),
            children: children,
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => AddMedicamentoPage(pet: pet)),
    );
  }
}

/// Card do medicamento: nome + fase, dose/frequência e o período do tratamento.
class CardMedicamento extends StatelessWidget {
  final Pets pet;
  final Medicamento model;

  const CardMedicamento({super.key, required this.pet, required this.model});

  static String fmt(DateTime? d) => d == null
      ? 'N/D'
      : '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final stage = model.stage;
    final color = medicationStageColor(context, stage);

    final posologia = [
      if ((model.dosage ?? '').isNotEmpty) model.dosage!,
      if ((model.frequency ?? '').isNotEmpty) model.frequency!,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => MedicamentoPage(pet: pet, medicamento: model),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Acento lateral no que está em uso agora.
              if (stage == MedicationStage.ongoing)
                Container(width: 4, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.tint(color, 0.12),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(AppRadius.md)),
                            ),
                            child: Icon(Icons.medication_liquid_rounded,
                                color: color, size: 22),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.name ?? 'Medicamento',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.headline
                                      .copyWith(color: c.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  posologia.isEmpty
                                      ? 'Sem posologia informada'
                                      : posologia,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.footnote
                                      .copyWith(color: c.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          MedicationStageChip(stage: stage, compact: true),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Icon(Icons.event_available_rounded,
                              size: 14, color: c.textTertiary),
                          const SizedBox(width: 4),
                          Text('Início: ${fmt(model.startDate)}',
                              style: AppTypography.caption
                                  .copyWith(color: c.textSecondary)),
                          const SizedBox(width: AppSpacing.lg),
                          Icon(
                              model.isContinuous
                                  ? Icons.all_inclusive_rounded
                                  : Icons.event_busy_rounded,
                              size: 14,
                              color: c.textTertiary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              model.isContinuous
                                  ? 'Uso contínuo'
                                  : 'Término: ${fmt(model.endDate)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption
                                  .copyWith(color: c.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
