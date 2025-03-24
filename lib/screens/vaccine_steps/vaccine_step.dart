import 'package:flutter/material.dart';
import 'package:pet_app/screens/components/text_input_auth.dart';
import 'package:pet_app/screens/components/weight_input.dart';
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações da Vacina',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1CB0F6),
            ),
          ),
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
          TextInput(
            inputTitle: 'Vacina',
            controller: vacinaController,
            textInputType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o nome da vacina';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          DatePickerInput(
            inputTitle: 'Data aplicada',
            controller: dataAplicadaController,
            isPastDateOnly: true,
            hint: 'Data da aplicação da vacina',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione a data de aplicação';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          DatePickerInput(
            inputTitle: 'Próxima aplicação',
            controller: proximaAplicacaoController,
            isFutureDateOnly: true,
            hint: 'Data da próxima dose',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione a data da próxima aplicação';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextInput(
            inputTitle: 'Peso do Pet (kg)',
            controller: pesoController,
            textInputType: TextInputType.text,
            hint: 'Ex: 10.5',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o peso do pet';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextInput(
            inputTitle: 'Lote',
            controller: loteController,
            textInputType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o lote da vacina';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextInput(
            inputTitle: 'Farmacêutica',
            controller: farmaceuticaController,
            textInputType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o nome da farmacêutica';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          DatePickerInput(
            inputTitle: 'Data de Validade',
            controller: dataValidadeController,
            hint: 'Selecione uma data',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione a data de validade';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextInput(
            inputTitle: 'Observações',
            controller: observacoesController,
            textInputType: TextInputType.name,
          ),
        ],
      ),
    );
  }
}
