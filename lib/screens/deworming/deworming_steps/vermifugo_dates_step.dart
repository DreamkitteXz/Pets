import 'package:flutter/material.dart';
import 'package:pet_app/controllers/data_picker.dart';

class VermifugoDatesStep extends StatelessWidget {
  final TextEditingController primeiraDoseController;
  final TextEditingController segundaDoseController;
  final bool mostrarReforco;
  final ValueChanged<bool> onReforcoChanged;

  const VermifugoDatesStep({
    super.key,
    required this.primeiraDoseController,
    required this.segundaDoseController,
    required this.mostrarReforco,
    required this.onReforcoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // O título da etapa vem do WizardShell — aqui só os campos.
        DatePickerInput(
          inputTitle: 'Data da Primeira Dose',
          controller: primeiraDoseController,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('Dose de Reforço'),
          value: mostrarReforco,
          onChanged: (value) {
            if (value != null) {
              onReforcoChanged(value);
            }
          },
        ),
        if (mostrarReforco) ...[
          const SizedBox(height: 16),
          DatePickerInput(
            inputTitle: 'Data da Dose de Reforço',
            controller: segundaDoseController,
            isFutureDateOnly: true,
          ),
        ],
      ],
    );
  }
}
