import 'package:flutter/material.dart';
import 'package:pet_app/screens/components/text_input_auth.dart';
import 'package:pet_app/controllers/data_picker.dart';

class VaccineStep extends StatelessWidget {
  final TextEditingController vacinaController;
  final TextEditingController dataAplicadaController;
  final TextEditingController proximaAplicacaoController;
  final TextEditingController pesoController;
  final TextEditingController loteController;
  final TextEditingController farmaceuticaController;
  final TextEditingController dataValidadeController;
  final TextEditingController observacoesController;
  final List<Map<String, dynamic>> availableVaccines;
  final bool isLoadingVaccines;
  final void Function(Map<String, dynamic> vaccine)? onVaccineSelected;

  const VaccineStep({
    Key? key,
    required this.vacinaController,
    required this.dataAplicadaController,
    required this.proximaAplicacaoController,
    required this.pesoController,
    required this.loteController,
    required this.farmaceuticaController,
    required this.dataValidadeController,
    required this.observacoesController,
    this.availableVaccines = const [],
    this.isLoadingVaccines = false,
    this.onVaccineSelected,
  }) : super(key: key);

  // Método para criar o InputDecoration padrão baseado na imagem
  static InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF333333),
      ),
      hintStyle: const TextStyle(
        fontSize: 16,
        color: Color(0xFF999999),
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      fillColor: Colors.white,
    );
  }

  // Widget personalizado para campos de texto
  Widget _buildCustomTextField({
    required String labelText,
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
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
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
            ),
            suffixIcon: suffixIcon,
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
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // Widget personalizado para campos de data
  Widget _buildDateField({
    required String labelText,
    required TextEditingController controller,
    String? hintText,
    String? Function(String?)? validator,
    VoidCallback? onTap,
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
          validator: validator,
          readOnly: true,
          onTap: onTap,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
            ),
            suffixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFF666666),
                size: 24,
              ),
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
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // Widget personalizado para dropdown
  Widget _buildDropdownField({
    required String labelText,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
    String? hintText,
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
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
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
            fillColor: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Preencha os dados da vacina aplicada, incluindo o peso atual do pet.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),

          // Campo Vacina (Dropdown)
          isLoadingVaccines
              ? const CircularProgressIndicator()
              : _buildDropdownField(
                  labelText: 'Vacina',
                  value: vacinaController.text.isNotEmpty
                      ? vacinaController.text
                      : null,
                  hintText: 'Selecione a vacina',
                  items: availableVaccines.map((vaccine) {
                    return DropdownMenuItem<String>(
                      value: vaccine['name'],
                      child: Text(vaccine['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final selected = availableVaccines.firstWhere(
                      (v) => v['name'] == value,
                      orElse: () => {},
                    );
                    vacinaController.text = value ?? '';
                    farmaceuticaController.text =
                        selected['manufacturer'] ?? '';
                    if (onVaccineSelected != null) {
                      onVaccineSelected!(selected);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecione a vacina';
                    }
                    return null;
                  },
                ),

          const SizedBox(height: 20),

          // Campo Data Aplicada
          _buildDateField(
            labelText: 'Data aplicada',
            controller: dataAplicadaController,
            hintText: 'Selecione a data de aplicação',
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                dataAplicadaController.text =
                    "${picked.day}/${picked.month}/${picked.year}";
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione a data de aplicação';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Campo Próxima Aplicação
          _buildDateField(
            labelText: 'Próxima aplicação',
            controller: proximaAplicacaoController,
            hintText: 'Selecione a data da próxima dose',
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                proximaAplicacaoController.text =
                    "${picked.day}/${picked.month}/${picked.year}";
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione a data da próxima aplicação';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Campo Peso
          _buildCustomTextField(
            labelText: 'Peso',
            controller: pesoController,
            hintText: 'Ex: 10.5 kg',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o peso do pet';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Campo Lote
          _buildCustomTextField(
            labelText: 'Lote',
            controller: loteController,
            hintText: 'Número do lote da vacina',
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o lote da vacina';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Campo Farmacêutica
          _buildCustomTextField(
            labelText: 'Farmacêutica',
            controller: farmaceuticaController,
            hintText: 'Nome da farmacêutica',
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o nome da farmacêutica';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Campo Data de Validade
          _buildDateField(
            labelText: 'Data de Validade',
            controller: dataValidadeController,
            hintText: 'Selecione a data de validade',
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(Duration(days: 365)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                dataValidadeController.text =
                    "${picked.day}/${picked.month}/${picked.year}";
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione a data de validade';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Campo Observações
          _buildCustomTextField(
            labelText: 'Observações',
            controller: observacoesController,
            hintText: 'Observações adicionais (opcional)',
            keyboardType: TextInputType.multiline,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
