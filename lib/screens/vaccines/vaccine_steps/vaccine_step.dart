import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pet_app/design/design.dart';

/// Formato único das datas do wizard. Os pickers gravavam
/// "${day}/${month}/${year}" sem zero à esquerda ("5/3/2026"), o que quebrava
/// a conversão para Timestamp na hora de salvar.
final DateFormat kWizardDateFormat = DateFormat('dd/MM/yyyy');

class VaccineStep extends StatelessWidget {
  final TextEditingController vacinaController;
  final TextEditingController dataAplicadaController;
  final TextEditingController proximaAplicacaoController;
  final TextEditingController pesoController;
  final TextEditingController loteController;
  final TextEditingController farmaceuticaController;
  final TextEditingController dataValidadeController;
  final TextEditingController observacoesController;
  final List<Map<String, dynamic>> availableVaccines;
  final bool isLoadingVaccines;
  final void Function(Map<String, dynamic> vaccine)? onVaccineSelected;

  const VaccineStep({
    super.key,
    required this.vacinaController,
    required this.dataAplicadaController,
    required this.proximaAplicacaoController,
    required this.pesoController,
    required this.loteController,
    required this.farmaceuticaController,
    required this.dataValidadeController,
    required this.observacoesController,
    this.availableVaccines = const [],
    this.isLoadingVaccines = false,
    this.onVaccineSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preencha os dados da vacina aplicada, incluindo o peso atual do pet.',
          style: AppTypography.footnote.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isLoadingVaccines)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: AppLoading(),
          )
        else
          _Labeled(
            label: 'Vacina',
            child: DropdownButtonFormField<String>(
              initialValue: vacinaController.text.isNotEmpty
                  ? vacinaController.text
                  : null,
              hint: const Text('Selecione a vacina'),
              isExpanded: true,
              items: availableVaccines.map((vaccine) {
                return DropdownMenuItem<String>(
                  value: vaccine['name'] as String?,
                  child: Text(vaccine['name'] as String? ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                final selected = availableVaccines.firstWhere(
                  (v) => v['name'] == value,
                  orElse: () => <String, dynamic>{},
                );
                vacinaController.text = value ?? '';
                farmaceuticaController.text =
                    selected['manufacturer'] as String? ?? '';
                onVaccineSelected?.call(selected);
              },
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Selecione a vacina'
                  : null,
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        _DateField(
          label: 'Data aplicada',
          hint: 'Quando a vacina foi aplicada',
          controller: dataAplicadaController,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          initialDate: DateTime.now(),
          validatorMessage: 'Selecione a data de aplicação',
        ),
        const SizedBox(height: AppSpacing.lg),
        _DateField(
          label: 'Próxima aplicação',
          hint: 'Quando vence a próxima dose',
          controller: proximaAplicacaoController,
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 10),
          initialDate: DateTime.now().add(const Duration(days: 30)),
          validatorMessage: 'Selecione a data da próxima aplicação',
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: pesoController,
          label: 'Peso do pet (kg)',
          hint: 'Ex.: 10,5',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Informe o peso do pet'
              : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: loteController,
          label: 'Lote',
          hint: 'Número do lote da vacina',
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Informe o lote da vacina'
              : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: farmaceuticaController,
          label: 'Farmacêutica',
          hint: 'Fabricante da vacina',
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Informe a farmacêutica'
              : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        _DateField(
          label: 'Data de validade',
          hint: 'Validade impressa no frasco',
          controller: dataValidadeController,
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 10),
          initialDate: DateTime.now().add(const Duration(days: 365)),
          validatorMessage: 'Selecione a data de validade',
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: observacoesController,
          label: 'Observações (opcional)',
          hint: 'Algo que o veterinário precise saber',
          keyboardType: TextInputType.multiline,
          maxLines: 3,
        ),
      ],
    );
  }
}

class _Labeled extends StatelessWidget {
  final String label;
  final Widget child;
  const _Labeled({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.subhead
                .copyWith(color: context.colors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialDate;
  final String validatorMessage;

  const _DateField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
    required this.validatorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _Labeled(
      label: label,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: AppTypography.callout.copyWith(color: c.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: Icon(Icons.calendar_month_rounded,
              size: 20, color: c.textTertiary),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? validatorMessage : null,
        onTap: () async {
          DateTime seed = initialDate;
          if (controller.text.isNotEmpty) {
            try {
              seed = kWizardDateFormat.parse(controller.text);
            } catch (_) {
              // Texto inválido: cai no initialDate.
            }
          }
          if (seed.isBefore(firstDate)) seed = firstDate;
          if (seed.isAfter(lastDate)) seed = lastDate;

          final picked = await showDatePicker(
            context: context,
            initialDate: seed,
            firstDate: firstDate,
            lastDate: lastDate,
            helpText: label,
          );
          if (picked != null) {
            controller.text = kWizardDateFormat.format(picked);
          }
        },
      ),
    );
  }
}
