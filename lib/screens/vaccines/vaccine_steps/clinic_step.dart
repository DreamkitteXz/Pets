import 'package:flutter/material.dart';
import 'package:pet_app/design/design.dart';

/// Dados da clínica: todos vêm do cadastro escolhido no passo anterior, então
/// os campos são de leitura — servem para o tutor conferir antes de finalizar.
class ClinicStep extends StatelessWidget {
  final TextEditingController cnpjController;
  final TextEditingController clinicController;
  final TextEditingController streetController;
  final TextEditingController neighborhoodController;
  final TextEditingController numberController;
  final TextEditingController cityController;

  const ClinicStep({
    super.key,
    required this.cnpjController,
    required this.clinicController,
    required this.streetController,
    required this.neighborhoodController,
    required this.numberController,
    required this.cityController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: clinicController,
          label: 'Clínica',
          hint: 'Nome da clínica',
          readOnly: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: cnpjController,
          label: 'CNPJ',
          hint: '00.000.000/0000-00',
          readOnly: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: AppTextField(
                controller: streetController,
                label: 'Rua',
                hint: 'Nome da rua',
                readOnly: true,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: numberController,
                label: 'Número',
                hint: 'Nº',
                readOnly: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: neighborhoodController,
          label: 'Bairro',
          hint: 'Nome do bairro',
          readOnly: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: cityController,
          label: 'Cidade',
          hint: 'Nome da cidade',
          readOnly: true,
        ),
      ],
    );
  }
}
