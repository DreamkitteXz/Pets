import 'package:flutter/material.dart';
import 'package:pet_app/design/design.dart';

class VermifugoBasicInfoStep extends StatelessWidget {
  final TextEditingController vermifugoController;
  final TextEditingController pesoController;
  final TextEditingController manufacturerController;
  final TextEditingController dosageController;

  const VermifugoBasicInfoStep({
    super.key,
    required this.vermifugoController,
    required this.pesoController,
    required this.manufacturerController,
    required this.dosageController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // O título da etapa vem do WizardShell — aqui só os campos.
        AppTextField(
          controller: vermifugoController,
          label: 'Nome do vermífugo',
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: pesoController,
          label: 'Peso do pet (kg)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: manufacturerController,
          label: 'Fabricante',
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: dosageController,
          label: 'Dosagem',
        ),
      ],
    );
  }
}
