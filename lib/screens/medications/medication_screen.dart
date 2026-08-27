import 'package:flutter/material.dart';

import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/medication_model.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/repositories/medication_repository.dart';
import 'package:pet_app/screens/medications/add_medication_screen.dart';
import 'package:pet_app/screens/medications/medication_stage_chip.dart';

/// Detalhe do medicamento: fase do tratamento, posologia, período e ações
/// (editar / encerrar hoje / remover da lista).
class MedicamentoPage extends StatefulWidget {
  final Pets pet;
  final Medicamento medicamento;

  const MedicamentoPage({
    super.key,
    required this.pet,
    required this.medicamento,
  });

  @override
  State<MedicamentoPage> createState() => _MedicamentoPageState();
}

class _MedicamentoPageState extends State<MedicamentoPage> {
  final MedicationRepository _repository = MedicationRepository();

  /// Cópia local para a tela refletir a edição sem esperar a lista recarregar.
  late Medicamento _medicamento = widget.medicamento;
  bool _busy = false;

  String _fmt(DateTime? d) => d == null
      ? 'N/D'
      : '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final m = _medicamento;
    final stage = m.stage;

    return AppScaffold(
      title: m.name ?? 'Medicamento',
      subtitle: widget.pet.name,
      showBack: true,
      bodyPadding: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: MedicationStageChip(stage: stage, compact: true),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl),
        children: [
          _StageCard(medicamento: m, fmt: _fmt),
          const SizedBox(height: AppSpacing.lg),
          AppInfoGroup(header: 'Posologia', rows: {
            'Dose': m.dosage ?? 'N/D',
            'Frequência': m.frequency ?? 'N/D',
            'Via': m.route ?? 'N/D',
          }),
          const SizedBox(height: AppSpacing.lg),
          AppInfoGroup(header: 'Tratamento', rows: {
            'Início': _fmt(m.startDate),
            'Término': m.isContinuous ? 'Uso contínuo' : _fmt(m.endDate),
            if ((m.prescribedBy ?? '').isNotEmpty) 'Prescrito por':
                m.prescribedBy!,
            if ((m.notes ?? '').isNotEmpty) 'Observações': m.notes!,
          }),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Editar',
            icon: Icons.edit_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: _busy ? null : _edit,
          ),
          // Encerrar = fixar o término em hoje. Só aparece no que está em uso:
          // num tratamento que ainda nem começou a ação certa é editar a data
          // ou remover.
          if (stage == MedicationStage.ongoing) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Encerrar tratamento hoje',
              icon: Icons.event_busy_rounded,
              variant: AppButtonVariant.secondary,
              loading: _busy,
              onPressed: _busy ? null : _finishToday,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Remover da lista',
            icon: Icons.delete_outline_rounded,
            variant: AppButtonVariant.destructive,
            onPressed: _busy ? null : _archive,
          ),
        ],
      ),
    );
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<Medicamento>(
      context,
      MaterialPageRoute<Medicamento>(
        builder: (_) =>
            AddMedicamentoPage(pet: widget.pet, medicamento: _medicamento),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _medicamento = updated);
    }
  }

  Future<void> _finishToday() async {
    final today = DateTime.now();

    setState(() => _busy = true);
    final updated = _medicamento
        .copyWith(endDate: DateTime(today.year, today.month, today.day));
    try {
      await _repository.updateMedication(widget.pet.id, updated);
      if (!mounted) return;
      setState(() {
        _medicamento = updated;
        _busy = false;
      });
      _toast('Tratamento encerrado.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('Não foi possível encerrar: $e');
    }
  }

  Future<void> _archive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover medicamento'),
        content: Text(
          '"${_medicamento.name ?? 'Este medicamento'}" sai da lista de '
          '${widget.pet.name ?? 'seu pet'}. Você pode registrar de novo '
          'quando precisar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: context.colors.accentRed),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await _repository.archiveMedication(widget.pet.id, _medicamento.id);
      if (!mounted) return;
      Navigator.pop(context);
      _toast('Medicamento removido.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('Não foi possível remover: $e');
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

/// Card proeminente da fase do tratamento — equivalente ao `_StatusCard` da
/// vacina, mas falando de duração em vez de validação.
class _StageCard extends StatelessWidget {
  final Medicamento medicamento;
  final String Function(DateTime?) fmt;

  const _StageCard({required this.medicamento, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final stage = medicamento.stage;
    final color = medicationStageColor(context, stage);

    String subtitle;
    switch (stage) {
      case MedicationStage.ongoing:
        subtitle = medicamento.isContinuous
            ? 'Uso contínuo desde ${fmt(medicamento.startDate)}.'
            : 'Até ${fmt(medicamento.endDate)}.';
        break;
      case MedicationStage.scheduled:
        subtitle = 'Começa em ${fmt(medicamento.startDate)}.';
        break;
      case MedicationStage.finished:
        subtitle = 'Encerrado em ${fmt(medicamento.endDate)}.';
        break;
    }

    return AppCard(
      color: c.tint(color, 0.10),
      child: Row(
        children: [
          Icon(medicationStageIcon(stage), color: color, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicationStageLabels[stage]!,
                    style: AppTypography.headline.copyWith(color: color)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTypography.footnote
                        .copyWith(color: c.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
