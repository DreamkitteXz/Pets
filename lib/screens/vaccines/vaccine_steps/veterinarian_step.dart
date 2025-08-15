import 'package:flutter/material.dart';
import 'package:pet_app/screens/components/text_input_auth.dart';

class VeterinarianStep extends StatelessWidget {
  final String? selectedVetId;
  final TextEditingController nameController;
  final TextEditingController crmvController;
  final List<Map<String, dynamic>> veterinarians;
  final Function(String) onVetSelected;

  const VeterinarianStep({
    Key? key,
    required this.selectedVetId,
    required this.nameController,
    required this.crmvController,
    required this.veterinarians,
    required this.onVetSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Selecione o Veterinário',
                border: OutlineInputBorder(),
              ),
              value: selectedVetId,
              items: veterinarians.map<DropdownMenuItem<String>>((vet) {
                return DropdownMenuItem<String>(
                  value: vet['id'] as String,
                  child: Text(vet['name'] ?? ''),
                );
              }).toList(),
              onChanged: (String? vetId) {
                if (vetId != null) {
                  onVetSelected(vetId);
                }
              },
            ),
          ),
          const SizedBox(height: 20.0),
          TextInput(
            inputTitle: 'Nome',
            controller: nameController,
            textInputType: TextInputType.name,
            readOnly: true,
          ),
          const SizedBox(height: 20.0),
          TextInput(
            inputTitle: 'CRMV',
            controller: crmvController,
            textInputType: TextInputType.number,
            readOnly: true,
          ),
        ],
      ),
    );
  }
}
