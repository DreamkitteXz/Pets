import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WeightInput extends StatelessWidget {
  final TextEditingController controller;
  final String inputTitle;
  final bool readOnly;
  final String? Function(String?)? validator;

  const WeightInput({
    Key? key,
    required this.controller,
    required this.inputTitle,
    this.readOnly = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Text(
            inputTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF041A23),
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            validator: validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o peso';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null) {
                    return 'Por favor, insira um peso válido';
                  }
                  if (weight <= 0) {
                    return 'O peso deve ser maior que 0';
                  }
                  if (weight > 200) {
                    return 'Por favor, verifique o peso inserido';
                  }
                  return null;
                },
            decoration: InputDecoration(
              hintText: 'Digite o peso (ex: 12.5)',
              helperText: 'Peso em quilogramas (kg)',
              helperStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              suffixText: 'kg',
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFCAC6C6),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF4B39EF),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
