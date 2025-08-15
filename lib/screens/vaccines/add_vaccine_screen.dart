import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/controllers/id_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_app/controllers/vaccines/vaccine_controller.dart';
import 'package:pet_app/screens/vaccines/vaccine_steps/veterinarian_step.dart';
import 'package:pet_app/screens/vaccines/vaccine_steps/label_step.dart';
import 'package:pet_app/screens/vaccines/vaccine_steps/clinic_step.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pet_app/screens/vaccines/vaccine_steps/vaccine_step.dart';
import 'package:pet_app/screens/components/snackbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ignore: must_be_immutable
class AddVacPage extends StatefulWidget {
  String petId;
  AddVacPage({super.key, required this.petId});

  @override
  State<AddVacPage> createState() => _AddVacPageState();
}

class _AddVacPageState extends State<AddVacPage> {
  final TextEditingController _vacinaController = TextEditingController();

  final TextEditingController _dataAplicadaController = TextEditingController();

  final TextEditingController _proximaAplicacaoController =
      TextEditingController();

  final TextEditingController _pesoController = TextEditingController();

  final TextEditingController _loteController = TextEditingController();

  final TextEditingController _farmaceuticaController = TextEditingController();

  final TextEditingController _dataValidadeController = TextEditingController();

  final TextEditingController _observacoesController = TextEditingController();

  final TextEditingController _rotuloVacController = TextEditingController();

  final TextEditingController _nomeVetController = TextEditingController();

  final TextEditingController _crmvController = TextEditingController();

  final TextEditingController _cnpjController = TextEditingController();

  final TextEditingController _clinicaController = TextEditingController();

  final TextEditingController _ruaController = TextEditingController();

  final TextEditingController _bairroController = TextEditingController();

  final TextEditingController _numeroController = TextEditingController();

  final TextEditingController _cidadeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String imageURL = '';

  String? selectedVetId;
  List<Map<String, dynamic>> veterinarians = [];

  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _petSpeciesController = TextEditingController();
  final TextEditingController _petBreedController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerContactController = TextEditingController();

  final TextEditingController _tutorNameController = TextEditingController();
  final TextEditingController _tutorContactController = TextEditingController();

  int _currentStep = 0;

  String? selectedClinicId;
  List<Map<String, dynamic>> clinics = [];
  bool hasNoClinic = false;

  List<Map<String, dynamic>> availableVaccines = [];
  bool isLoadingVaccines = false;

  late final VaccineController vaccinesController;

  @override
  void initState() {
    super.initState();
    vaccinesController = VaccineController();
    fetchVeterinarians();
    fetchClinics();
    fetchPetDetails();
    fetchTutorDetails();
    fetchAvailableVaccines();
  }

  Future<void> fetchVeterinarians() async {
    final vetsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'veterinarian')
        .where('status', isEqualTo: 'active')
        .get();

    setState(() {
      veterinarians = vetsSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    });
  }

  Future<void> fetchClinics() async {
    final clinicsSnapshot = await FirebaseFirestore.instance
        .collection('clinics')
        .where('status', isEqualTo: 'active')
        .get();

    setState(() {
      clinics = clinicsSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    });
  }

  Future<void> fetchPetDetails() async {
    final petDoc = await FirebaseFirestore.instance
        .collection('pets')
        .doc(widget.petId)
        .get();
    if (petDoc.exists) {
      final petData = petDoc.data()!;
      setState(() {
        _petNameController.text = petData['name'] ?? '';
        _petSpeciesController.text = petData['species'] ?? '';
        _petBreedController.text = petData['breed'] ?? '';
        //  _petWeightController.text = petData['weight']?.toString() ?? '';
        _ownerNameController.text = petData['ownerName'] ?? '';
        _ownerContactController.text = petData['ownerContact'] ?? '';
      });
    }
  }

  Future<void> fetchTutorDetails() async {
    final petDoc = await FirebaseFirestore.instance
        .collection('pets')
        .doc(widget.petId)
        .get();
    if (petDoc.exists) {
      final petData = petDoc.data()!;
      final tutorId = petData['ownerId'];
      if (tutorId != null) {
        final tutorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(tutorId)
            .get();
        if (tutorDoc.exists) {
          final tutorData = tutorDoc.data()!;
          setState(() {
            _tutorNameController.text = tutorData['name'] ?? '';
            _tutorContactController.text = tutorData['phone'] ?? '';
          });
        }
      }
    }
  }

  Future<void> fetchAvailableVaccines() async {
    setState(() => isLoadingVaccines = true);
    try {
      final vaccines = await vaccinesController.fetchAvailableVaccines();
      setState(() {
        availableVaccines = vaccines;
        isLoadingVaccines = false;
      });
    } catch (e) {
      setState(() => isLoadingVaccines = false);
      // Optionally handle error
    }
  }

  void _updateVeterinarianFields(String vetId) async {
    final vet = veterinarians.firstWhere((v) => v['id'] == vetId);
    setState(() {
      selectedVetId = vetId; // Make sure to store the vetId
      _nomeVetController.text = vet['name'] ?? '';
      _crmvController.text = vet['crmv'] ?? '';
    });

    if (vet['clinicId'] != null) {
      try {
        final clinicDoc = await FirebaseFirestore.instance
            .collection('clinics')
            .doc(vet['clinicId'])
            .get();

        if (clinicDoc.exists) {
          final clinicData = clinicDoc.data()!;
          setState(() {
            _cnpjController.text = clinicData['cnpj'] ?? '';
            _clinicaController.text = clinicData['name'] ?? '';
            _ruaController.text = clinicData['address']['street'] ?? '';
            _bairroController.text =
                clinicData['address']['neighborhood'] ?? '';
            _numeroController.text = clinicData['address']['number'] ?? '';
            _cidadeController.text = clinicData['address']['city'] ?? '';
          });
        }
      } catch (e) {
        print('Error fetching clinic data: $e');
      }
    }
  }

  void _updateClinicFields(String? clinicId) {
    if (clinicId == null) {
      setState(() {
        selectedClinicId = null;
        _cnpjController.text = '';
        _clinicaController.text = '';
        _ruaController.text = '';
        _bairroController.text = '';
        _numeroController.text = '';
        _cidadeController.text = '';
        hasNoClinic = true;
      });
      return;
    }

    final clinic = clinics.firstWhere((c) => c['id'] == clinicId);
    setState(() {
      selectedClinicId = clinicId;
      hasNoClinic = false;
      _cnpjController.text = clinic['cnpj'] ?? '';
      _clinicaController.text = clinic['name'] ?? '';
      _ruaController.text = clinic['address']['street'] ?? '';
      _bairroController.text = clinic['address']['neighborhood'] ?? '';
      _numeroController.text = clinic['address']['number'] ?? '';
      _cidadeController.text = clinic['address']['city'] ?? '';
    });
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Vacina'),
        content: VaccineStep(
          vacinaController: _vacinaController,
          dataAplicadaController: _dataAplicadaController,
          proximaAplicacaoController: _proximaAplicacaoController,
          pesoController: _pesoController,
          loteController: _loteController,
          farmaceuticaController: _farmaceuticaController,
          dataValidadeController: _dataValidadeController,
          observacoesController: _observacoesController,
          availableVaccines: availableVaccines, // Pass the list
          isLoadingVaccines: isLoadingVaccines,
          onVaccineSelected: (vaccine) {
            _vacinaController.text = vaccine['name'] ?? '';
            _farmaceuticaController.text = vaccine['manufacturer'] ?? '';
          },
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Rótulo'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Foto do Rótulo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF041A23),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Tire uma foto clara do rótulo da vacina, incluindo selo, assinatura e carimbo do veterinário.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            LabelStep(
              imageURL: imageURL,
              onImageUploaded: (String url) {
                setState(() {
                  imageURL = url;
                  _rotuloVacController.text = url;
                });
              },
              rotuloController: _rotuloVacController,
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Veterinário'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados do Veterinário',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF041A23),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Selecione o veterinário responsável pela aplicação da vacina.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            VeterinarianStep(
              selectedVetId: selectedVetId,
              nameController: _nomeVetController,
              crmvController: _crmvController,
              veterinarians: veterinarians,
              onVetSelected: _updateVeterinarianFields,
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Clínica'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações da Clínica',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF041A23),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Selecione a clínica onde a vacina foi aplicada.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                labelText: 'Selecione a Clínica',
                border: OutlineInputBorder(),
              ),
              value: selectedClinicId,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Sem vínculo com clínica'),
                ),
                ...clinics.map((clinic) {
                  return DropdownMenuItem<String>(
                    value: clinic['id'],
                    child: Text(clinic['name']),
                  );
                }).toList(),
              ],
              onChanged: _updateClinicFields,
            ),
            if (!hasNoClinic) ...[
              const SizedBox(height: 20),
              ClinicStep(
                cnpjController: _cnpjController,
                clinicController: _clinicaController,
                streetController: _ruaController,
                neighborhoodController: _bairroController,
                numberController: _numeroController,
                cityController: _cidadeController,
              ),
            ],
          ],
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  void _validateStep() async {
    switch (_currentStep) {
      case 0: // Vaccine step
        if (_formKey.currentState?.validate() ?? false) {
          setState(() => _currentStep += 1);
        }
        break;
      case 1: // Label step
        if (imageURL.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: CustomSnackBar(
                errorText: 'Por favor, faça o upload da imagem do rótulo'),
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            elevation: 0,
          ));
        } else {
          setState(() => _currentStep += 1);
        }
        break;
      case 2: // Veterinarian step
        if (selectedVetId == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: CustomSnackBar(
                errorText: 'Por favor, selecione um veterinário'),
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            elevation: 0,
          ));
        } else {
          setState(() => _currentStep += 1);
        }
        break;
      case 3: // Clinic step
        print("SubmitForm: $_currentStep");

        _submitForm();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentStep + 1) / _buildSteps().length;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF041A23),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
          title: LinearPercentIndicator(
            width: MediaQuery.of(context).size.width - 100,
            lineHeight: 8.0,
            percent: progress,
            backgroundColor: Colors.grey.shade200,
            progressColor: const Color(0xFF58CC02),
            barRadius: const Radius.circular(8),
          ),
        ),
        body: Form(
          // Move Form widget here to wrap all content
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: _buildSteps()[_currentStep].content,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _currentStep -= 1;
                            });
                          },
                          child:
                              const Icon(Icons.arrow_back, color: Colors.grey),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF041A23),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _validateStep,
                        child: Text(
                          _currentStep == _buildSteps().length - 1
                              ? 'FINALIZAR'
                              : 'CONTINUAR',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    print("SubmitForm");

    if (imageURL.isEmpty || selectedVetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: CustomSnackBar(
            errorText: imageURL.isEmpty
                ? 'Faça o upload da imagem'
                : 'Selecione um veterinário'),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ));
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      DocumentReference petRef =
          FirebaseFirestore.instance.collection('pets').doc(widget.petId);
      String vaccineId = gerarVacsID();

      Map<String, dynamic> clinicData = hasNoClinic
          ? {}
          : {
              'clinicId': selectedClinicId,
              'cnpj': _cnpjController.text,
              'clinicName': _clinicaController.text,
              'clinicAddress': {
                'street': _ruaController.text,
                'neighborhood': _bairroController.text,
                'number': _numeroController.text,
                'city': _cidadeController.text,
              },
            };

      // Fetch image metadata
      final imageRef = FirebaseStorage.instance.refFromURL(imageURL);
      final imageMetadata = await imageRef.getMetadata();

      // Get the user's location
      Position position = await _determinePosition();
      final location = {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };

      // Get current user information
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data()!;

      // Updated vaccine document structure
      await FirebaseFirestore.instance
          .collection('vaccines')
          .doc(vaccineId)
          .set({
        'id': vaccineId,
        'name': _vacinaController.text,
        'administrationDate': _dataAplicadaController.text,
        'nextDueDate': _proximaAplicacaoController.text,
        'petWeight': _pesoController.text, // Store as string directly
        'batchNumber': _loteController.text,
        'manufacturer': _farmaceuticaController.text,
        'expirationDate': _dataValidadeController.text,
        'veterinarianName': _nomeVetController.text,
        'crmvNumber': _crmvController.text,
        'labelImage': imageURL,
        'labelImageMetadata': {
          'name': imageMetadata.name,
          'size': imageMetadata.size.toString(),
          'contentType': imageMetadata.contentType,
          'timeCreated': imageMetadata.timeCreated.toString(),
          'updated': imageMetadata.updated.toString(),
          'location': location,
        },
        'notes': _observacoesController.text,
        'clinicCnpj': clinicData['cnpj'] ?? '',
        'clinicName': clinicData['clinicName'] ?? '',
        'clinicAddress': clinicData['clinicAddress'] ?? {},
        'status': 'pending',
        'validationDetails': {
          'vetValidation': {
            'status': 'pending',
            'validatedAt': null,
            'validatedBy': null,
            'notes': '',
            'rejectionReason': '',
          },
          'tutorValidation': {
            'status': 'pending',
            'validatedAt': null,
            'validatedBy': null,
            'notes': '',
            'rejectionReason': '',
          }
        },
        'petId': widget.petId,
        'petName': _petNameController.text,
        'petSpecies': _petSpeciesController.text,
        'petBreed': _petBreedController.text,
        'ownerId': user.uid, // Set ownerId from current user
        'ownerName': userData['name'], // Set ownerName from current user
        'ownerContact': userData['phone'], // Set ownerContact from current user
        'veterinarianId': selectedVetId,
        'clinicId': selectedClinicId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update pet's vaccines array
      await petRef.update({
        'vaccines': FieldValue.arrayUnion([vaccineId]),
        'veterinarians': FieldValue.arrayUnion([selectedVetId])
      });

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            CustomSnackBar(successfulText: 'Vacina adicionada com sucesso!'),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ));

      // Navigate back to vaccines page
      Navigator.pop(context, true); // Pass true to indicate successful addition
    } catch (e) {
      // Close loading dialog if error occurs
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: CustomSnackBar(errorText: 'Erro ao adicionar vacina: $e'),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
