import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/controllers/id_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_app/controllers/vaccines/vaccine_controller.dart';
import 'package:pet_app/screens/vaccines/vaccine_steps/veterinarian_step.dart';
import 'package:pet_app/screens/vaccines/vaccine_steps/label_step.dart';
import 'package:pet_app/screens/vaccines/vaccine_steps/clinic_step.dart';
import 'package:pet_app/screens/vaccines/vaccine_steps/vaccine_step.dart';
import 'package:pet_app/design/design.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddVacPage extends StatefulWidget {
  final String petId;
  const AddVacPage({super.key, required this.petId});

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
  bool _saving = false;

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

  /// Lista os veterinários cadastrados.
  ///
  /// Hoje a rule de `users` só libera o próprio documento
  /// (`request.auth.uid == userId`), então nenhuma consulta por `role` é
  /// satisfazível pelo tutor e isto retorna PERMISSION_DENIED. O erro é
  /// tratado como "lista vazia" para não travar o cadastro: sem vet, a vacina
  /// é registrada assim mesmo e a associação fica para depois.
  /// Quando existir um caminho de leitura no backend, esta consulta passa a
  /// devolver dados sem mais nenhuma mudança aqui.
  Future<void> fetchVeterinarians() async {
    try {
      final vetsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'veterinarian')
          .where('status', isEqualTo: 'active')
          .get();

      if (!mounted) return;
      setState(() {
        veterinarians = vetsSnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
      });
    } catch (e) {
      debugPrint('Lista de veterinários indisponível: $e');
      if (!mounted) return;
      setState(() => veterinarians = const []);
    }
  }

  /// Mesma situação da lista de veterinários: a rule de `clinics` exige que o
  /// solicitante esteja em `veterinarians`, o que nunca vale para o tutor.
  Future<void> fetchClinics() async {
    try {
      final clinicsSnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .where('status', isEqualTo: 'active')
          .get();

      if (!mounted) return;
      setState(() {
        clinics = clinicsSnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
      });
    } catch (e) {
      debugPrint('Lista de clínicas indisponível: $e');
      if (!mounted) return;
      setState(() => clinics = const []);
    }
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
        debugPrint('Error fetching clinic data: $e');
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
              ),
              initialValue: selectedClinicId,
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

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _validateStep() {
    switch (_currentStep) {
      case 0: // Vaccine step
        if (_formKey.currentState?.validate() ?? false) {
          setState(() => _currentStep += 1);
        }
        break;
      case 1: // Label step
        if (imageURL.isEmpty) {
          _toast('Faça o upload da foto do rótulo.');
        } else {
          setState(() => _currentStep += 1);
        }
        break;
      case 2: // Veterinarian step
        // Vet deixou de ser obrigatório: quando não há nenhum disponível o
        // tutor registra assim mesmo e a associação fica para depois. Só
        // insiste se existir lista e ele não tiver escolhido.
        if (selectedVetId == null && veterinarians.isNotEmpty) {
          _toast('Selecione um veterinário.');
          return;
        }
        setState(() => _currentStep += 1);
        break;
      case 3: // Clinic step
        _submitForm();
        break;
      default:
        break;
    }
  }

  // Função para obter o título dinâmico baseado no passo atual
  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Informações da vacina';
      case 1:
        return 'Foto do rótulo';
      case 2:
        return 'Dados do veterinário';
      case 3:
        return 'Informações da clínica';
      default:
        return 'Informações da vacina';
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();
    return WizardShell(
      title: 'Nova vacina',
      stepTitle: _getStepTitle(),
      currentStep: _currentStep,
      totalSteps: steps.length,
      onBack:
          _currentStep == 0 ? null : () => setState(() => _currentStep -= 1),
      onNext: _validateStep,
      isLastStep: _currentStep == steps.length - 1,
      busy: _saving,
      formKey: _formKey,
      child: steps[_currentStep].content,
    );
  }

  /// Datas dos campos chegam como texto dd/MM/yyyy. O restante do sistema
  /// (web, CFs, os cards do app) lê `Timestamp` — gravar String aqui deixava
  /// a vacina fora de "Próximos cuidados" e quebrava o cast no dashboard.
  Timestamp? _asTimestamp(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    try {
      return Timestamp.fromDate(kWizardDateFormat.parse(text));
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (_saving) return;

    if (imageURL.isEmpty) {
      _toast('Faça o upload da foto do rótulo.');
      return;
    }
    if (selectedVetId == null && veterinarians.isNotEmpty) {
      _toast('Selecione um veterinário.');
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);

    try {
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
        // Datas como Timestamp (eram String dd/MM/yyyy) e peso como número.
        'administrationDate': _asTimestamp(_dataAplicadaController.text),
        'nextDueDate': _asTimestamp(_proximaAplicacaoController.text),
        'petWeight':
            double.tryParse(_pesoController.text.replaceAll(',', '.')) ?? 0.0,
        'batchNumber': _loteController.text,
        'manufacturer': _farmaceuticaController.text,
        'expirationDate': _asTimestamp(_dataValidadeController.text),
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
        // Só vetValidation (a CF updateVaccineStatus preenche na validação).
        // Sem tutorValidation — ciência do tutor é tutorAcknowledged. F2.1/§3.1.
        'validationDetails': {
          'vetValidation': {
            'status': 'pending',
            'validatedAt': null,
            'validatedBy': null,
            'notes': '',
            'rejectionReason': '',
          },
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

      // Vincula o vet ao pet (canônico). NÃO grava mais pets.vaccines[]
      // (deprecado — verdade é vaccines.petId). F0.3/§2.2.
      await petRef.update({
        'veterinarians': FieldValue.arrayUnion([selectedVetId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      navigator.pop(true); // true = cadastro concluído
      messenger.showSnackBar(const SnackBar(
        content:
            Text('Vacina registrada. Aguardando validação do veterinário.'),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(
        content: Text('Erro ao adicionar vacina: $e'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  /// A localização é registrada junto com a foto do rótulo (onde o registro
  /// foi feito). Continua obrigatória, mas as mensagens agora explicam o que
  /// falta — antes vazavam strings em inglês do Geolocator para o snackbar.
  Future<Position> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception(
          'Ative a localização do aparelho para registrar a vacina.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Precisamos da localização para registrar onde a foto '
          'do rótulo foi feita. Libere o acesso nas configurações.');
    }

    return Geolocator.getCurrentPosition();
  }
}
