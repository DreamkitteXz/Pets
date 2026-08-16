import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pet_app/controllers/id_controller.dart';
import 'package:pet_app/design/design.dart';
import 'package:pet_app/firebase/schema.dart';
import 'deworming_steps/vermifugo_basic_info_step.dart';
import 'deworming_steps/vermifugo_dates_step.dart';
import 'deworming_steps/vermifugo_observations_step.dart';
import 'deworming_steps/vermifugo_veterinarian_step.dart';

class AddVermifugoPage extends StatefulWidget {
  final String? petId;

  const AddVermifugoPage({super.key, required this.petId});

  @override
  State<AddVermifugoPage> createState() => _AddVermifugoPageState();
}

class _AddVermifugoPageState extends State<AddVermifugoPage> {
  bool _mostrarReforco = false;

  // Controladores dos campos que receberão as informações da vacina
  final vermifugoController = TextEditingController();
  final primeiraDoseController = TextEditingController();
  final kiloGramaController = TextEditingController();
  final segundaDoseController = TextEditingController();
  final terceiraDoseController = TextEditingController();
  final pesoController = TextEditingController();

  // Add new controllers for additional fields
  final manufacturerController = TextEditingController();
  final dosageController = TextEditingController();
  final effectivenessNotesController = TextEditingController();
  final sideEffectsController = TextEditingController();
  final observationsController = TextEditingController();

  // Add veterinarian and clinic related fields
  String? selectedVetId;
  String? selectedClinicId;
  List<Map<String, dynamic>> veterinarians = [];
  List<Map<String, dynamic>> clinics = [];

  int _currentStep = 0;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchVeterinarians();
    fetchClinics();
  }

  // Add these methods to fetch vets and clinics
  Future<void> fetchVeterinarians() async {
    final vetsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'veterinarian')
        .where('status', isEqualTo: 'active')
        .get();

    setState(() {
      veterinarians = vetsSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
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
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    });
  }

  // ================================================================
  // Função de cadastro Vacina Firebase

  // Remove the old cadastroVermifugos function and update _submitForm
  Future<void> _submitForm() async {
    if (_saving) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      // Get pet data
      final petDoc = await FirebaseFirestore.instance
          .collection('pets')
          .doc(widget.petId)
          .get();

      if (!petDoc.exists) {
        throw Exception('Pet not found');
      }

      final petData = petDoc.data()!;
      final String dewormingId = gerarVersID();

      // Create deworming document — coleção canônica é 'deworming' (singular);
      // 'dewormings' (plural) cai no catch-all das rules (negado). §12.
      DocumentReference dewormingRef =
          FirebaseFirestore.instance.collection('deworming').doc(dewormingId);

      // Create batch for atomic operations
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Set deworming data
      batch.set(dewormingRef, {
        'id': dewormingId,
        'name': vermifugoController.text,
        'manufacturer': manufacturerController.text,
        'dosage': dosageController.text,
        'weight': double.tryParse(pesoController.text) ?? 0.0,
        'administrationDate': Timestamp.fromDate(
            DateFormat('dd/MM/yyyy').parse(primeiraDoseController.text)),
        'nextDueDate': _mostrarReforco
            ? Timestamp.fromDate(
                DateFormat('dd/MM/yyyy').parse(segundaDoseController.text))
            : null,
        'isReinforcementNeeded': _mostrarReforco,
        'reinforcementDate': _mostrarReforco
            ? Timestamp.fromDate(
                DateFormat('dd/MM/yyyy').parse(segundaDoseController.text))
            : null,

        // Pet information
        'petId': widget.petId,
        'petName': petData['name'],
        'petWeight': double.tryParse(pesoController.text) ?? 0.0,

        // Owner information
        'ownerId': petData['ownerId'],
        'ownerName': petData['ownerName'],

        // Veterinarian information
        'veterinarianId': selectedVetId,
        'veterinarianName': veterinarians.firstWhere(
          (vet) => vet['id'] == selectedVetId,
          orElse: () => {'name': null},
        )['name'],
        'crmvNumber': veterinarians.firstWhere(
          (vet) => vet['id'] == selectedVetId,
          orElse: () => {'crmv': null},
        )['crmv'],

        // Clinic information
        'clinicId': selectedClinicId,
        'clinicName': clinics.firstWhere(
          (clinic) => clinic['id'] == selectedClinicId,
          orElse: () => {'name': null},
        )['name'],
        'clinicAddress': clinics.firstWhere(
          (clinic) => clinic['id'] == selectedClinicId,
          orElse: () => {'address': null},
        )['address'],

        // Status and tracking — eixo único (F2.1/§3.1); era DewormingStatus.active
        'status': DewormingStatus.pending.name,
        'effectivenessNotes': effectivenessNotesController.text,
        'sideEffects': [],
        'observations': observationsController.text,

        // Metadata
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': FirebaseAuth.instance.currentUser?.uid,
      });

      // Update pet's deworming reference
      DocumentReference petRef =
          FirebaseFirestore.instance.collection('pets').doc(widget.petId);

      // NÃO grava mais pets.dewormings[] (deprecado, análogo a vaccines[] —
      // verdade é deworming.petId). Apenas atualiza o updatedAt. F0.3/§2.2.
      batch.update(petRef, {
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();

      navigator.pop();
      messenger.showSnackBar(const SnackBar(
        content: Text('Vermífugo registrado. Aguardando validação do '
            'veterinário.'),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(
        content: Text('Erro ao adicionar vermífugo: $e'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
  //=================================================================

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Informações Básicas'),
        content: VermifugoBasicInfoStep(
          vermifugoController: vermifugoController,
          pesoController: pesoController,
          manufacturerController: manufacturerController,
          dosageController: dosageController,
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Veterinário'),
        content: VermifugoVeterinarianStep(
          selectedVetId: selectedVetId,
          nameController: TextEditingController(
            text: veterinarians.firstWhere(
              (vet) => vet['id'] == selectedVetId,
              orElse: () => {'name': ''},
            )['name'],
          ),
          crmvController: TextEditingController(
            text: veterinarians.firstWhere(
              (vet) => vet['id'] == selectedVetId,
              orElse: () => {'crmv': ''},
            )['crmv'],
          ),
          veterinarians: veterinarians,
          onVetSelected: (vetId) {
            setState(() {
              selectedVetId = vetId;
            });
          },
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Datas'),
        content: VermifugoDatesStep(
          primeiraDoseController: primeiraDoseController,
          segundaDoseController: segundaDoseController,
          mostrarReforco: _mostrarReforco,
          onReforcoChanged: (value) {
            setState(() {
              _mostrarReforco = value;
            });
          },
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Observações'),
        content: VermifugoObservationsStep(
          effectivenessNotesController: effectivenessNotesController,
          observationsController: observationsController,
        ),
        isActive: _currentStep >= 3,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();
    return WizardShell(
      title: 'Novo vermífugo',
      currentStep: _currentStep,
      totalSteps: steps.length,
      stepTitle: (steps[_currentStep].title as Text).data ?? '',
      onBack: _currentStep == 0
          ? null
          : () => setState(() => _currentStep--),
      onNext: _validateStep,
      isLastStep: _currentStep == steps.length - 1,
      busy: _saving,
      formKey: _formKey,
      child: steps[_currentStep].content,
    );
  }

  void _validateStep() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentStep < _buildSteps().length - 1) {
        setState(() => _currentStep++);
      } else {
        _submitForm();
      }
    }
  }
}
