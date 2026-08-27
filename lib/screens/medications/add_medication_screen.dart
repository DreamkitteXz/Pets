import 'package:flutter/material.dart';

import 'package:pet_app/controllers/id_controller.dart';
import 'package:pet_app/design/design.dart';
import 'package:pet_app/models/medication_model.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/repositories/medication_repository.dart';

/// Vias de administração sugeridas — mesmo vocabulário do campo `route` da
/// vacina na web (NewApplicationModal.jsx).
const List<String> kMedicationRoutes = [
  'Oral',
  'Tópica',
  'Subcutânea',
  'Intramuscular',
  'Intravenosa',
  'Ocular',
  'Otológica',
  'Outra',
];

/// Cadastro/edição de medicamento. Formulário único (não wizard): são poucos
/// campos e o tutor costuma preencher com a caixa do remédio na mão.
class AddMedicamentoPage extends StatefulWidget {
  final Pets pet;

  /// `null` = novo registro; preenchido = edição.
  final Medicamento? medicamento;

  const AddMedicamentoPage({super.key, required this.pet, this.medicamento});

  @override
  State<AddMedicamentoPage> createState() => _AddMedicamentoPageState();
}

class _AddMedicamentoPageState extends State<AddMedicamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = MedicationRepository();

  late final TextEditingController _name =
      TextEditingController(text: widget.medicamento?.name ?? '');
  late final TextEditingController _dosage =
      TextEditingController(text: widget.medicamento?.dosage ?? '');
  late final TextEditingController _frequency =
      TextEditingController(text: widget.medicamento?.frequency ?? '');
  late final TextEditingController _prescribedBy =
      TextEditingController(text: widget.medicamento?.prescribedBy ?? '');
  late final TextEditingController _notes =
      TextEditingController(text: widget.medicamento?.notes ?? '');

  late String? _route = widget.medicamento?.route;
  late DateTime? _startDate = widget.medicamento?.startDate ?? DateTime.now();
  late DateTime? _endDate = widget.medicamento?.endDate;
  late bool _continuous = widget.medicamento == null
      ? false
      : widget.medicamento!.isContinuous;

  bool _saving = false;

  bool get _isEditing => widget.medicamento != null;

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    _frequency.dispose();
    _prescribedBy.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AppScaffold(
      title: _isEditing ? 'Editar medicamento' : 'Novo medicamento',
      subtitle: widget.pet.name,
      showBack: true,
      bodyPadding: false,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _name,
                    label: 'Nome do medicamento',
                    hint: 'Ex.: Apoquel',
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Informe o nome do medicamento'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _dosage,
                    label: 'Dose',
                    hint: 'Ex.: 1 comprimido, 5 ml',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _frequency,
                    label: 'Frequência',
                    hint: 'Ex.: a cada 12 horas',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _RouteField(
                    value: _route,
                    onChanged: (value) => setState(() => _route = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateField(
                    label: 'Início do tratamento',
                    value: _startDate,
                    onPick: (date) => setState(() => _startDate = date),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _continuous,
                    onChanged: (value) => setState(() {
                      _continuous = value;
                      if (value) _endDate = null;
                    }),
                    title: Text('Uso contínuo',
                        style: AppTypography.callout
                            .copyWith(color: c.textPrimary)),
                    subtitle: Text('Sem data prevista para terminar',
                        style: AppTypography.footnote
                            .copyWith(color: c.textSecondary)),
                    activeThumbColor: c.accentBlue,
                  ),
                  if (!_continuous) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _DateField(
                      label: 'Término do tratamento',
                      value: _endDate,
                      hint: 'Selecione a data final',
                      onPick: (date) => setState(() => _endDate = date),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _prescribedBy,
                    label: 'Prescrito por',
                    hint: 'Nome do veterinário',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _notes,
                    label: 'Observações',
                    hint: 'Reações, cuidados, horários...',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // O tutor registra o que ele mesmo administra — deixar isso claro
            // evita que o medicamento seja lido como registro validado por vet.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text(
                'Este é o seu registro de acompanhamento. Ele não substitui a '
                'prescrição do veterinário nem entra na validação da carteira.',
                style: AppTypography.footnote.copyWith(color: c.textTertiary),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _isEditing ? 'Salvar alterações' : 'Adicionar medicamento',
              icon: Icons.check_rounded,
              loading: _saving,
              onPressed: _saving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_startDate == null) {
      _toast('Informe a data de início do tratamento.');
      return;
    }
    final end = _continuous ? null : _endDate;
    if (!_continuous && end == null) {
      _toast('Informe o término ou marque "Uso contínuo".');
      return;
    }
    if (end != null && end.isBefore(_startDate!)) {
      _toast('O término não pode ser anterior ao início.');
      return;
    }

    setState(() => _saving = true);

    String? trimmed(TextEditingController controller) {
      final value = controller.text.trim();
      return value.isEmpty ? null : value;
    }

    final medication = Medicamento(
      id: widget.medicamento?.id ?? gerarMedID(),
      name: _name.text.trim(),
      dosage: trimmed(_dosage),
      frequency: trimmed(_frequency),
      route: _route,
      startDate: _startDate,
      endDate: end,
      prescribedBy: trimmed(_prescribedBy),
      notes: trimmed(_notes),
      createdAt: widget.medicamento?.createdAt,
    );

    try {
      if (_isEditing) {
        await _repository.updateMedication(widget.pet.id, medication);
      } else {
        await _repository.addMedication(widget.pet.id, medication);
      }
      if (!mounted) return;
      Navigator.pop(context, medication);
      _toast(_isEditing ? 'Medicamento atualizado.' : 'Medicamento registrado.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _toast('Não foi possível salvar: $e');
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

/// Campo de data com o visual do design system (o `DatePickerInput` legado tem
/// cores fixas de tema claro e padding próprio — não combina com estas telas).
class _DateField extends StatefulWidget {
  final String label;
  final DateTime? value;
  final String? hint;
  final ValueChanged<DateTime> onPick;

  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
    this.hint,
  });

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  late final TextEditingController _controller =
      TextEditingController(text: _format(widget.value));

  static String _format(DateTime? d) => d == null
      ? ''
      : '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  void didUpdateWidget(covariant _DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return AppTextField(
      label: widget.label,
      hint: widget.hint ?? 'DD/MM/AAAA',
      readOnly: true,
      controller: _controller,
      suffix: const Icon(Icons.event_rounded, size: 20),
      onTap: () async {
        FocusScope.of(context).unfocus();
        final picked = await showDatePicker(
          context: context,
          initialDate: widget.value ?? now,
          firstDate: DateTime(now.year - 20),
          lastDate: DateTime(now.year + 20),
        );
        if (picked != null) widget.onPick(picked);
      },
    );
  }
}

/// Via de administração — lista curta, então vira um seletor de chips em vez de
/// mais um campo de texto livre.
class _RouteField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _RouteField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Via de administração',
            style: AppTypography.subhead.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final route in kMedicationRoutes)
              ChoiceChip(
                label: Text(route),
                selected: value == route,
                labelStyle: AppTypography.footnote.copyWith(
                  color: value == route ? c.accentBlue : c.textSecondary,
                  fontWeight:
                      value == route ? FontWeight.w600 : FontWeight.w500,
                ),
                backgroundColor: c.surfaceSecondary,
                selectedColor: c.tint(c.accentBlue, 0.12),
                showCheckmark: false,
                side: BorderSide.none,
                // Tocar de novo na via já escolhida limpa o campo (é opcional).
                onSelected: (selected) =>
                    onChanged(selected ? route : null),
              ),
          ],
        ),
      ],
    );
  }
}
