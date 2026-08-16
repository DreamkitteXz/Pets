import 'package:flutter/material.dart';
import 'package:pet_app/design/design.dart';

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
        AppTextField(
          controller: effectivenessNotesController,
          label: 'Notas de efetividade',
          hint: 'Como o pet reagiu ao vermífugo',
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: observationsController,
          label: 'Observações gerais',
          maxLines: 3,
        ),
      ],
    );
  }
}
