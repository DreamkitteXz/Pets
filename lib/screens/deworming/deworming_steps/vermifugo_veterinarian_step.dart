import 'package:flutter/material.dart';
import 'package:pet_app/design/design.dart';

class VermifugoVeterinarianStep extends StatelessWidget {
  final String? selectedVetId;
  final TextEditingController nameController;
  final TextEditingController crmvController;
  final List<Map<String, dynamic>> veterinarians;
  final Function(String) onVetSelected;

  const VermifugoVeterinarianStep({
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
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: c.tint(c.statusPending, 0.10),
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.schedule_rounded, size: 18, color: c.statusPending),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nenhum veterinário disponível',
                      style:
                          AppTypography.subhead.copyWith(color: c.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    'Você pode registrar o vermífugo mesmo assim. Ele fica '
                    'aguardando validação até um veterinário ser associado '
                    'ao registro.',
                    style: AppTypography.footnote
                        .copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          hint: const Text('Selecione'),
          items: veterinarians.map<DropdownMenuItem<String>>((vet) {
            return DropdownMenuItem<String>(
              value: vet['id'] as String,
              child: Text(vet['name'] as String? ?? ''),
            );
          }).toList(),
          onChanged: (vetId) {
            if (vetId != null) onVetSelected(vetId);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        // Nome e CRMV vêm do cadastro do vet — só leitura.
        AppTextField(
          controller: nameController,
          label: 'Nome',
          readOnly: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: crmvController,
          label: 'CRMV',
          readOnly: true,
        ),
      ],
    );
  }
}
