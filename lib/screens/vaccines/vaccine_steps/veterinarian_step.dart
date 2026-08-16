import 'package:flutter/material.dart';
import 'package:pet_app/design/design.dart';

class VeterinarianStep extends StatelessWidget {
  final String? selectedVetId;
  final TextEditingController nameController;
  final TextEditingController crmvController;
  final List<Map<String, dynamic>> veterinarians;
  final Function(String) onVetSelected;

  const VeterinarianStep({
    super.key,
    required this.selectedVetId,
    required this.nameController,
    required this.crmvController,
    required this.veterinarians,
    required this.onVetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (veterinarians.isEmpty) {
      return Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: c.textTertiary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Nenhum veterinário ativo disponível no momento.',
              style: AppTypography.callout.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Veterinário',
            style: AppTypography.subhead.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: selectedVetId,
          hint: const Text('Escolha um veterinário'),
          items: veterinarians.map<DropdownMenuItem<String>>((vet) {
            return DropdownMenuItem<String>(
              value: vet['id'] as String,
              child: Text(vet['name'] as String? ?? ''),
            );
          }).toList(),
          onChanged: (vetId) {
            if (vetId != null) onVetSelected(vetId);
          },
          validator: (value) => (value == null || value.isEmpty)
              ? 'Selecione um veterinário'
              : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        // Nome e CRMV vêm do cadastro do veterinário — só leitura.
        AppTextField(
          controller: nameController,
          label: 'Nome',
          hint: 'Nome do veterinário',
          readOnly: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: crmvController,
          label: 'CRMV',
          hint: 'Número do CRMV',
          readOnly: true,
        ),
      ],
    );
  }
}
