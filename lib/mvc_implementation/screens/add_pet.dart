import 'package:flutter/material.dart';
import 'package:pet_app/mvc_implementation/controllers/id_controller.dart';
import 'package:pet_app/mvc_implementation/screens/components/subtitle.dart';
import 'package:pet_app/mvc_implementation/screens/components/text_input_auth.dart';
import 'package:pet_app/mvc_implementation/screens/components/titles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/mvc_implementation/controllers/pet_controller.dart';
import 'package:pet_app/mvc_implementation/models/pets.dart'; // Add this line to import the Pets class
import 'package:intl/intl.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({Key? key}) : super(key: key);

  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  final _speciesController =
      TextEditingController(); // Changed from tipoController
  final _breedController =
      TextEditingController(); // Changed from racaController
  final _colorController =
      TextEditingController(); // Changed from corController
  final _birthDateController =
      TextEditingController(); // Changed from dataNascController
  final _genderController =
      TextEditingController(); // Changed from sexoController
  final _chipNumberController =
      TextEditingController(); // Changed from chipController
  final _isNeuteredController =
      TextEditingController(); // Changed from isInteiroController

  final _formKey = GlobalKey<FormState>();

  final dropOptions1 = ['dog', 'cat']; // Changed to match schema
  final dropValue1 = ValueNotifier('');

  final dropOptions2 = ['male', 'female']; // Changed to match schema
  final dropValue2 = ValueNotifier('');

  final dropOptions3 = ['true', 'false']; // Changed for isNeutered boolean
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
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF212121),
                  size: 30,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              actions: const [],
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
                    TextInput(
                        inputTitle: 'Nome',
                        controller: _nameController,
                        textInputType: TextInputType.name),
                    const SizedBox(height: 10),
                    dropFormOptions('Tipo', 'Selecione o Tipo', dropValue1,
                        dropOptions1, _speciesController),
                    const SizedBox(height: 10),
                    TextInput(
                        inputTitle: 'Raça',
                        controller: _breedController,
                        textInputType: TextInputType.name),
                    const SizedBox(height: 10),
                    TextInput(
                        inputTitle: 'Cor',
                        controller: _colorController,
                        textInputType: TextInputType.name),
                    dropFormOptions('Sexo', 'Selecione o Sexo', dropValue2,
                        dropOptions2, _genderController),
                    const SizedBox(height: 10),
                    TextInput(
                        inputTitle: 'Data de Nascimento',
                        controller: _birthDateController,
                        dataPicker: true,
                        hint: 'DD/MM/AAAA',
                        textInputType: TextInputType.name),
                    dropFormOptions(
                        'Inteiro ou Castrado?',
                        'Inteiro ou Castrado?',
                        dropValue3,
                        dropOptions3,
                        _isNeuteredController),
                    const SizedBox(height: 10),
                    TextInput(
                        inputTitle: 'Chip',
                        controller: _chipNumberController,
                        textInputType: TextInputType.name),
                    const SizedBox(height: 30),
                    AddButton(
                        speciesController: _speciesController,
                        formKey: _formKey,
                        nameController: _nameController,
                        breedController: _breedController,
                        genderController: _genderController,
                        colorController: _colorController,
                        birthDateController: _birthDateController,
                        isNeuteredController: _isNeuteredController,
                        chipNumberController: _chipNumberController,
                        ownerId: FirebaseAuth.instance.currentUser?.uid,
                        ownerName: '' // Get this from user profile
                        ),
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
      TextEditingController controller) {
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
          child: dropDownOptions(hint, dropValue, dropOptions, controller),
        ),
      ],
    );
  }

  ValueListenableBuilder<String> dropDownOptions(
      String hint,
      ValueNotifier<String> dropValue,
      List<String> dropOptions,
      TextEditingController controller) {
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
              controller.text = escolha.toString();
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
            validator: (value1) {
              if (value1 != null && value1.isEmpty) {
                return 'Insira o Tipo';
              }
              return null;
            },
          );
        });
  }

  void _handleAddPet() async {
    if (_formKey.currentState!.validate()) {
      final pet = Pets(
        id: gerarPetsID(),
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        breed: _breedController.text.trim(),
        gender: _genderController.text.trim(),
        color: _colorController.text.trim(),
        birthDate: DateTime.parse(_birthDateController.text.trim()),
        isNeutered: _isNeuteredController.text.trim() == 'true',
        chipNumber: _chipNumberController.text.trim(),
        ownerId: FirebaseAuth.instance.currentUser?.uid,
        status: 'active',
      );

      final petController = PetController();
      await petController.createPet(pet);
      Navigator.pop(context);
    }
  }
}

class AddButton extends StatelessWidget {
  const AddButton({
    super.key,
    required TextEditingController speciesController,
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController breedController,
    required TextEditingController genderController,
    required TextEditingController colorController,
    required TextEditingController birthDateController,
    required TextEditingController isNeuteredController,
    required TextEditingController chipNumberController,
    required this.ownerId,
    required this.ownerName,
  })  : _speciesController = speciesController,
        _formKey = formKey,
        _nameController = nameController,
        _breedController = breedController,
        _genderController = genderController,
        _colorController = colorController,
        _birthDateController = birthDateController,
        _isNeuteredController = isNeuteredController,
        _chipNumberController = chipNumberController;

  final TextEditingController _speciesController;
  final GlobalKey<FormState> _formKey;
  final TextEditingController _nameController;
  final TextEditingController _breedController;
  final TextEditingController _genderController;
  final TextEditingController _colorController;
  final TextEditingController _birthDateController;
  final TextEditingController _isNeuteredController;
  final TextEditingController _chipNumberController;
  final String? ownerId;
  final String ownerName;

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
                  backgroundColor: const Color(0xFF041A23),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  side: const BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: const Text(
                  'Adicionar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final pet = Pets(
                      id: gerarPetsID(),
                      name: _nameController.text.trim(),
                      species: _speciesController.text.trim(),
                      breed: _breedController.text.trim(),
                      gender: _genderController.text.trim(),
                      color: _colorController.text.trim(),
                      birthDate: DateFormat('dd/MM/yyyy')
                          .parse(_birthDateController.text.trim()),
                      isNeutered: _isNeuteredController.text.trim() == 'true',
                      chipNumber: _chipNumberController.text.trim(),
                      ownerId: ownerId,
                      status: 'active',
                      vaccines: [],
                      veterinarians: [],
                    );

                    final petController = PetController();
                    await petController.createPet(pet);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
        ));
  }
}
