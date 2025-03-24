import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pet_app/controllers/id_controller.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pet_app/screens/components/snackbar.dart';
import 'package:pet_app/firebase/schema.dart';
import 'package:pet_app/controllers/data_picker.dart';

class AddVermifugoPage extends StatefulWidget {
  final String? petId;

  const AddVermifugoPage({super.key, required this.petId});

  @override
  _AddVermifugoPageState createState() => _AddVermifugoPageState();
}

class _AddVermifugoPageState extends State<AddVermifugoPage> {
  DateTime? _selectedDate;
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
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            const Center(child: CircularProgressIndicator()),
      );

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

      // Create deworming document
      DocumentReference dewormingRef =
          FirebaseFirestore.instance.collection('dewormings').doc(dewormingId);

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

        // Status and tracking
        'status': DewormingStatus.active.name,
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

      batch.update(petRef, {
        'dewormings': FieldValue.arrayUnion([dewormingId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();

      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context); // Return to previous screen

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            CustomSnackBar(successfulText: 'Vermífugo adicionado com sucesso!'),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ));
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: CustomSnackBar(errorText: 'Erro ao adicionar vermífugo: $e'),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ));
    }
  }
  //=================================================================

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Informações Básicas'),
        content: Column(
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
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Datas'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datas de Aplicação',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF041A23),
              ),
            ),
            const SizedBox(height: 16),
            DatePickerInput(
              inputTitle: 'Data da Primeira Dose',
              controller: primeiraDoseController,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Dose de Reforço'),
              value: _mostrarReforco,
              onChanged: (bool? value) {
                setState(() {
                  _mostrarReforco = value ?? false;
                });
              },
            ),
            if (_mostrarReforco) ...[
              const SizedBox(height: 16),
              DatePickerInput(
                inputTitle: 'Data da Dose de Reforço',
                controller: segundaDoseController,
                isFutureDateOnly: true,
              ),
            ],
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Observações'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: effectivenessNotesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notas de Efetividade',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: observationsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Observações Gerais',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentStep + 1) / _buildSteps().length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF041A23),
        elevation: 0,
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
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: _buildSteps()[_currentStep].content,
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
                onPressed: () => setState(() => _currentStep--),
                child: const Icon(Icons.arrow_back, color: Colors.grey),
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
              onPressed: () => _validateStep(),
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
