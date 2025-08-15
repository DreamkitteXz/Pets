import 'package:flutter/material.dart';
import 'package:pet_app/controllers/id_controller.dart';
import 'package:pet_app/screens/components/subtitle.dart';
import 'package:pet_app/screens/components/text_input_auth.dart';
import 'package:pet_app/screens/components/titles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/controllers/pets/pet_controller.dart';
import 'package:pet_app/models/pet_model.dart'; // Add this line to import the Pets class
import 'package:intl/intl.dart';
import 'package:pet_app/utils/gender_utils.dart';
import 'package:pet_app/utils/species_utils.dart';
import 'package:pet_app/utils/breed_utils.dart';
import 'package:dropdown_search/dropdown_search.dart';

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

  final dropOptions1 = ['Cachorro', 'Gato']; // Changed to match schema
  final dropValue1 = ValueNotifier('');

  final dropOptions2 = ['Macho', 'Fêmea']; // Changed to match schema
  final dropValue2 = ValueNotifier('');

  final dropOptions3 = [
    'Inteiro',
    'Castrado'
  ]; // Changed for isNeutered boolean
  final dropValue3 = ValueNotifier('');

  List<String> _dogBreeds = [];
  List<String> _catBreeds = [];
  List<String> _breedOptions = [];

  @override
  void initState() {
    super.initState();
    _prefetchBreeds();
    dropValue1.addListener(_onSpeciesChanged);
  }

  void _prefetchBreeds() async {
    _dogBreeds = await BreedUtils.fetchDogBreeds();
    _catBreeds = await BreedUtils.fetchCatBreeds();
    // Optionally, set default breed options if you want a default species selected
    setState(() {});
  }

  void _onSpeciesChanged() {
    setState(() {
      if (dropValue1.value.toLowerCase() == 'cachorro') {
        _breedOptions = _dogBreeds;
      } else if (dropValue1.value.toLowerCase() == 'gato') {
        _breedOptions = _catBreeds;
      } else {
        _breedOptions = [];
      }
      _breedController.clear();
    });
  }

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
                      textInputType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do pet';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    dropFormOptions('Tipo', 'Selecione o Tipo', dropValue1,
                        dropOptions1, _speciesController),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: DropdownSearch<String>(
                        items: _breedOptions,
                        selectedItem: _breedController.text.isNotEmpty
                            ? _breedController.text
                            : null,
                        onChanged: (value) {
                          _breedController.text = value ?? '';
                        },
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Raça',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          showSelectedItems: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              labelText: 'Digite ou selecione a raça',
                            ),
                          ),
                        ),
                        // Allow user to type a custom value
                        onSaved: (value) {
                          _breedController.text = value ?? '';
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, selecione ou digite a raça do pet';
                          }
                          return null;
                        },
                        // This enables custom input
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        // This allows the user to type a value not in the list
                        // and have it accepted as the selected value
                        // (if using dropdown_search >= 5.0.0)
                        // If not, you can add a TextFormField below as fallback
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextInput(
                      inputTitle: 'Cor',
                      controller: _colorController,
                      textInputType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a cor do pet';
                        }
                        return null;
                      },
                    ),
                    dropFormOptions('Sexo', 'Selecione o Sexo', dropValue2,
                        dropOptions2, _genderController),
                    const SizedBox(height: 10),
                    TextInput(
                      inputTitle: 'Data de Nascimento',
                      controller: _birthDateController,
                      dataPicker: true,
                      hint: 'DD/MM/AAAA',
                      textInputType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a data de nascimento do pet';
                        }
                        return null;
                      },
                    ),
                    dropFormOptions(
                      'Inteiro ou Castrado?',
                      'Inteiro ou Castrado?',
                      dropValue3,
                      dropOptions3,
                      _isNeuteredController,
                    ),
                    const SizedBox(height: 10),
                    TextInput(
                      inputTitle: 'Chip',
                      controller: _chipNumberController,
                      textInputType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o número do chip do pet';
                        }
                        return null;
                      },
                    ),
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
                      ownerName: '', // Get this from user profile
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
    TextEditingController controller,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 30.0),
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
          child: CustomDropdown(
            hint: hint,
            dropValue: dropValue,
            dropOptions: dropOptions,
            controller: controller,
          ),
        ),
      ],
    );
  }

  void _handleAddPet() async {
    if (_formKey.currentState!.validate()) {
      final pet = Pets(
        id: gerarPetsID(),
        name: _nameController.text.trim(),
        species: SpeciesUtils.toFirestore(_speciesController.text.trim()),
        breed: _breedController.text.trim(),
        gender: GenderUtils.toFirestore(_genderController.text.trim()),
        color: _colorController.text.trim(),
        birthDate:
            DateFormat('dd/MM/yyyy').parse(_birthDateController.text.trim()),
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
                    final user = FirebaseAuth.instance.currentUser;
                    final ownerId = user?.uid;
                    final ownerName = user?.displayName ?? 'Tutor Desconhecido';

                    final pet = Pets(
                      id: gerarPetsID(),
                      name: _nameController.text.trim(),
                      species: SpeciesUtils.toFirestore(
                          _speciesController.text.trim()),
                      breed: _breedController.text.trim(),
                      gender: GenderUtils.toFirestore(
                          _genderController.text.trim()),
                      color: _colorController.text.trim(),
                      birthDate: DateFormat('dd/MM/yyyy')
                          .parse(_birthDateController.text.trim()),
                      isNeutered: _isNeuteredController.text.trim() == 'true',
                      chipNumber: _chipNumberController.text.trim(),
                      ownerId: ownerId,
                      ownerName: ownerName,
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

class CustomDropdown extends StatelessWidget {
  final String hint;
  final ValueNotifier<String> dropValue;
  final List<String> dropOptions;
  final TextEditingController controller;

  const CustomDropdown({
    Key? key,
    required this.hint,
    required this.dropValue,
    required this.dropOptions,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: dropValue,
      builder: (BuildContext context, String value, _) {
        return DropdownButtonFormField<String>(
          hint: Text(hint),
          value: (value.isEmpty) ? null : value,
          items: dropOptions
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          onChanged: (choice) {
            dropValue.value = choice.toString();
            controller.text = choice.toString();
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
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: Color(0xFF041A23),
            fontSize: 16,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, selecione uma opção';
            }
            return null;
          },
        );
      },
    );
  }
}
