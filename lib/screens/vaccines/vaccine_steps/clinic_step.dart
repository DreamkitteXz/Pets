import 'package:flutter/material.dart';

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

  // Widget personalizado para campos de texto seguindo o mesmo padrão de design
  Widget _buildCustomTextField({
    required String labelText,
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 16,
            color: readOnly ? Color(0xFF666666) : Color(0xFF333333),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFBAD36),
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: readOnly ? Color(0xFFF8F8F8) : Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          _buildCustomTextField(
            labelText: 'CNPJ',
            controller: cnpjController,
            hintText: '00.000.000/0000-00',
            keyboardType: TextInputType.number,
            readOnly: true,
          ),
          const SizedBox(height: 20.0),
          _buildCustomTextField(
            labelText: 'Clínica',
            controller: clinicController,
            hintText: 'Nome da clínica',
            keyboardType: TextInputType.name,
            readOnly: true,
          ),
          const SizedBox(height: 20.0),
          _buildCustomTextField(
            labelText: 'Rua',
            controller: streetController,
            hintText: 'Nome da rua',
            keyboardType: TextInputType.streetAddress,
            readOnly: true,
          ),
          const SizedBox(height: 20.0),
          _buildCustomTextField(
            labelText: 'Bairro',
            controller: neighborhoodController,
            hintText: 'Nome do bairro',
            keyboardType: TextInputType.name,
            readOnly: true,
          ),
          const SizedBox(height: 20.0),
          _buildCustomTextField(
            labelText: 'Número',
            controller: numberController,
            hintText: 'Número do endereço',
            keyboardType: TextInputType.number,
            readOnly: true,
          ),
          const SizedBox(height: 20.0),
          _buildCustomTextField(
            labelText: 'Cidade',
            controller: cityController,
            hintText: 'Nome da cidade',
            keyboardType: TextInputType.name,
            readOnly: true,
          ),
        ],
      ),
    );
  }
}
