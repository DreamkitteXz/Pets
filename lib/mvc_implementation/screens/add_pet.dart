import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_app/mvc_implementation/controllers/id_controller.dart';
import 'package:pet_app/mvc_implementation/screens/components/logo.dart';
import 'package:pet_app/mvc_implementation/screens/components/subtitle.dart';
import 'package:pet_app/mvc_implementation/screens/components/text_input_auth.dart';
import 'package:pet_app/mvc_implementation/screens/components/titles.dart';
import 'package:pet_app/mvc_implementation/screens/login.dart';
import 'package:pet_app/screens/create_account/design/icon_button.dart';
import 'package:pet_app/screens/create_account/design/theme.dart';
import 'package:pet_app/screens/create_account/design/widgets.dart';

import '../../components/id.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({Key? key}) : super(key: key);

  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  final _tipoController = TextEditingController();
  final _racaController = TextEditingController();
  final _corController = TextEditingController();
  final _dataNascController = TextEditingController();
  final _sexoController = TextEditingController();
  final _chipController = TextEditingController();
  final _isInteiroController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final dropOptions1 = ['Cachorro', 'Gato'];
  final dropValue1 = ValueNotifier('');

  final dropOptions2 = ['Fêmea', 'Macho'];
  final dropValue2 = ValueNotifier('');

  final dropOptions3 = ['Inteiro', 'Castrado'];
  final dropValue3 = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Form(
        key: _formKey,
        child: SafeArea(
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              leading: GestureDetector(
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF212121),
                  size: 30,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              actions: [],
              centerTitle: true,
              elevation: 0,
            ),
            body: Align(
              alignment: const AlignmentDirectional(0, 0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Titles(
                      title: 'Registre seu Pet',
                      fontSize: 32.0,
                      paddingL: 30.0,
                    ),
                    const SizedBox(height: 20),
                    SubTitle(
                      subtitle:
                          'Aqui você consegue registrar seu Pet, prencha os campos abaixo.',
                      fontSize: 16.0,
                    ),
                    const SizedBox(height: 40),
                    TextInput(inputTitle: 'Nome', controller: _nameController),
                    const SizedBox(height: 10),
                    dropFormOptions('Tipo', 'Selecione o Tipo', dropValue1,
                        dropOptions1, _tipoController),
                    const SizedBox(height: 10),
                    TextInput(inputTitle: 'Raça', controller: _racaController),
                    const SizedBox(height: 10),
                    TextInput(inputTitle: 'Cor', controller: _corController),
                    dropFormOptions('Sexo', 'Selecione o Sexo', dropValue2,
                        dropOptions2, _sexoController),
                    const SizedBox(height: 10),
                    TextInput(
                      inputTitle: 'Data de Nascimento',
                      controller: _dataNascController,
                      dataPicker: true,
                      hint: 'DD/MM/AAAA',
                    ),
                    dropFormOptions(
                        'Inteiro ou Castrado?',
                        'Inteiro ou Castrado?',
                        dropValue3,
                        dropOptions3,
                        _isInteiroController),
                    const SizedBox(height: 10),
                    TextInput(inputTitle: 'Chip', controller: _chipController),
                    const SizedBox(height: 30),
                    AddButton(
                        tipoController: _tipoController,
                        formKey: _formKey,
                        nameController: _nameController,
                        racaController: _racaController,
                        sexoController: _sexoController,
                        corController: _corController,
                        dataNascController: _dataNascController,
                        isInteiroController: _isInteiroController,
                        chipController: _chipController),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column dropFormOptions(
      String label,
      String hint,
      ValueNotifier<String> dropValue,
      List<String> dropOptions,
      TextEditingController _controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(
            left: 30.0,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF041A23),
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: dropDownOptions(hint, dropValue, dropOptions, _controller),
        ),
      ],
    );
  }

  ValueListenableBuilder<String> dropDownOptions(
      String hint,
      ValueNotifier<String> dropValue,
      List<String> dropOptions,
      TextEditingController _controller) {
    return ValueListenableBuilder(
        valueListenable: dropValue,
        builder: (BuildContext context, String value, _) {
          return DropdownButtonFormField<String>(
            hint: Text(hint),
            value: (value.isEmpty) ? null : value,
            items: dropOptions
                .map((opcao) =>
                    DropdownMenuItem(value: opcao, child: Text(opcao)))
                .toList(),
            onChanged: (escolha) {
              dropValue.value = escolha.toString();
              _controller.text = escolha.toString();
            },
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF041A23),
                fontSize: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFCAC6C6),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFCAC6C6),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFFDA29B),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFFDA29B),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            style: FlutterFlowTheme.of(context).bodyLarge,
            validator: (value1) {
              if (value1 != null && value1.isEmpty) {
                return 'Insira o Tipo';
              }
            },
          );
        });
  }
}

class AddButton extends StatelessWidget {
  const AddButton({
    super.key,
    required TextEditingController tipoController,
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController racaController,
    required TextEditingController sexoController,
    required TextEditingController corController,
    required TextEditingController dataNascController,
    required TextEditingController isInteiroController,
    required TextEditingController chipController,
  })  : _tipoController = tipoController,
        _formKey = formKey,
        _nameController = nameController,
        _racaController = racaController,
        _sexoController = sexoController,
        _corController = corController,
        _dataNascController = dataNascController,
        _isInteiroController = isInteiroController,
        _chipController = chipController;

  final TextEditingController _tipoController;
  final GlobalKey<FormState> _formKey;
  final TextEditingController _nameController;
  final TextEditingController _racaController;
  final TextEditingController _sexoController;
  final TextEditingController _corController;
  final TextEditingController _dataNascController;
  final TextEditingController _isInteiroController;
  final TextEditingController _chipController;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF041A23),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  side: const BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: Text(
                  'Adicionar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                onPressed: () async {
                  print(_tipoController.text);
                  if (_formKey.currentState!.validate()) {
                    await cadastroPet(
                        gerarPetsID(),
                        _nameController.text.trim(),
                        _tipoController.text.trim(),
                        _racaController.text.trim(),
                        _sexoController.text.trim(),
                        _corController.text.trim(),
                        _dataNascController.text.trim(),
                        _isInteiroController.text.trim(),
                        _chipController.text.trim());
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
        ));
  }
}
