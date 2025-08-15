import 'package:flutter/material.dart';

class VermifugoObservationsStep extends StatelessWidget {
  final TextEditingController effectivenessNotesController;
  final TextEditingController observationsController;

  const VermifugoObservationsStep({
    super.key,
    required this.effectivenessNotesController,
    required this.observationsController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: effectivenessNotesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Notas de Efetividade',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: observationsController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Observações Gerais',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
