import 'package:flutter/material.dart';
import 'package:pet_app/screens/components/text_input_auth.dart';

class ClinicStep extends StatelessWidget {
  final TextEditingController cnpjController;
  final TextEditingController clinicController;
  final TextEditingController streetController;
  final TextEditingController neighborhoodController;
  final TextEditingController numberController;
  final TextEditingController cityController;

  const ClinicStep({
    Key? key,
    required this.cnpjController,
    required this.clinicController,
    required this.streetController,
    required this.neighborhoodController,
    required this.numberController,
    required this.cityController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          TextInput(
            inputTitle: 'CNPJ',
            controller: cnpjController,
            textInputType: TextInputType.number,
            readOnly: true,
          ),
          TextInput(
            inputTitle: 'Clínica',
            controller: clinicController,
            textInputType: TextInputType.name,
            readOnly: true,
          ),
          TextInput(
            inputTitle: 'Rua',
            controller: streetController,
            textInputType: TextInputType.streetAddress,
            readOnly: true,
          ),
          TextInput(
            inputTitle: 'Bairro',
            controller: neighborhoodController,
            textInputType: TextInputType.name,
            readOnly: true,
          ),
          TextInput(
            inputTitle: 'Número',
            controller: numberController,
            textInputType: TextInputType.number,
            readOnly: true,
          ),
          TextInput(
            inputTitle: 'Cidade',
            controller: cityController,
            textInputType: TextInputType.name,
            readOnly: true,
          ),
        ],
      ),
    );
  }
}
