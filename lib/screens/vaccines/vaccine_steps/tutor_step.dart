import 'package:flutter/material.dart';
import 'package:pet_app/screens/components/text_input_auth.dart';

class TutorStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController contactController;

  const TutorStep({
    Key? key,
    required this.nameController,
    required this.contactController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          TextInput(
            inputTitle: 'Nome do Tutor',
            controller: nameController,
            textInputType: TextInputType.name,
            readOnly: true,
          ),
          const SizedBox(height: 20.0),
          TextInput(
            inputTitle: 'Contato do Tutor',
            controller: contactController,
            textInputType: TextInputType.phone,
            readOnly: true,
          ),
        ],
      ),
    );
  }
}
