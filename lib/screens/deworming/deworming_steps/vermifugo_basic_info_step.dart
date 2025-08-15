import 'package:flutter/material.dart';

class VermifugoBasicInfoStep extends StatelessWidget {
  final TextEditingController vermifugoController;
  final TextEditingController pesoController;
  final TextEditingController manufacturerController;
  final TextEditingController dosageController;

  const VermifugoBasicInfoStep({
    super.key,
    required this.vermifugoController,
    required this.pesoController,
    required this.manufacturerController,
    required this.dosageController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informações do Vermífugo',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF041A23),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: vermifugoController,
          decoration: InputDecoration(
            labelText: 'Nome do Vermífugo',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: pesoController,
          decoration: InputDecoration(
            labelText: 'Peso do Pet',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: manufacturerController,
          decoration: InputDecoration(
            labelText: 'Fabricante',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: dosageController,
          decoration: InputDecoration(
            labelText: 'Dosagem',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
