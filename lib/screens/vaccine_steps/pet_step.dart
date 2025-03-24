import 'package:flutter/material.dart';
import 'package:pet_app/screens/components/text_input_auth.dart';

class PetStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController speciesController;
  final TextEditingController breedController;
  final TextEditingController weightController;

  const PetStep({
    Key? key,
    required this.nameController,
    required this.speciesController,
    required this.breedController,
    required this.weightController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          TextInput(
            inputTitle: 'Nome do Pet',
            controller: nameController,
            textInputType: TextInputType.name,
            readOnly: true,
          ),
          const SizedBox(height: 20.0),
          TextInput(
            inputTitle: 'Espécie do Pet',
            controller: speciesController,
            textInputType: TextInputType.name,
            readOnly: true,
          ),
          const SizedBox(height: 20.0),
          TextInput(
            inputTitle: 'Raça do Pet',
            controller: breedController,
            textInputType: TextInputType.name,
            readOnly: true,
          ),
          const SizedBox(height: 20.0),
          TextInput(
            inputTitle: 'Peso do Pet',
            controller: weightController,
            textInputType: TextInputType.number,
            readOnly: true,
          ),
        ],
      ),
    );
  }
}
