import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/models/vaccine_model.dart';
import 'package:pet_app/screens/vaccines/add_vaccine_screen.dart';
import 'package:pet_app/screens/vaccines/vaccine_screen.dart';

class VacinasScreen extends StatelessWidget {
  const VacinasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Vacinas'),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: const Center(child: Text('Usuário não autenticado')),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Vacinas',
            style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vaccines')
              .where('userId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text('Nenhuma vacina encontrada.'));
            }
            final vacinas = docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return Vacinas.fromMap(data);
            }).toList();
            return ListView.builder(
              itemCount: vacinas.length,
              itemBuilder: (context, index) {
                final vacina = vacinas[index];
                // Create a minimal Pets object for CardVacinas
                final pet = Pets(
                  id: vacina.petId ?? '',
                  name: vacina.petName ?? '',
                  species: vacina.petSpecies ?? 'cachorro',
                  gender: vacina.petName ?? 'macho',
                  // ...add other required fields with defaults if needed...
                );
                return CardVacinas(
                  pet: pet,
                  model: vacina,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CardVacinas extends StatelessWidget {
  const CardVacinas({
    super.key,
    required this.pet,
    required this.model,
  });

  final Pets pet;
  final Vacinas model;

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime? date) {
      if (date == null) return 'N/A';
      return '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x411D2429),
              offset: Offset(0, 4),
            )
          ],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: pet.species == 'cachorro'
                                ? (pet.gender == 'macho'
                                    ? Image.asset(
                                        'lib/assets/vacinadogmacho-removebg-preview.png')
                                    : Image.asset(
                                        'lib/assets/vacinadog-removebg-preview.png'))
                                : (pet.gender == 'macho'
                                    ? Image.asset(
                                        'lib/assets/catmachovac-removebg-preview.png')
                                    : Image.asset(
                                        'lib/assets/catfemeavac-removebg-preview.png')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                model.name ??
                                    'Vacina Desconhecida', // Changed from model.vacina
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lote: ${model.batchNumber ?? 'N/D'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF707070),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: model.status == 'approved'
                          ? Colors.green.withOpacity(0.1)
                          : model.status == 'rejected' ||
                                  model.status == 'vetRejected' ||
                                  model.status == 'tutorRejected'
                              ? Colors.red.withOpacity(0.1)
                              : model.status == 'vetApproved' ||
                                      model.status == 'tutorApproved'
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(model.status ?? 'pending'),
                      style: TextStyle(
                        color: model.status == 'approved'
                            ? Colors.green
                            : model.status == 'rejected' ||
                                    model.status == 'vetRejected' ||
                                    model.status == 'tutorRejected'
                                ? Colors.red
                                : model.status == 'vetApproved' ||
                                        model.status == 'tutorApproved'
                                    ? Colors.orange
                                    : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF707070),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Aplicada: ${formatDate(model.administrationDate)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF707070),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.event_repeat,
                        size: 16,
                        color: Color(0xFF707070),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Próxima: ${formatDate(model.nextDueDate)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF707070),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'APROVADO';
      case 'vetApproved':
        return 'APROVADO VET';
      case 'tutorApproved':
        return 'APROVADO TUTOR';
      case 'rejected':
      case 'vetRejected':
      case 'tutorRejected':
        return 'REJEITADO';
      case 'pending':
      default:
        return 'PENDENTE';
    }
  }
}

class FloatingActionVac extends StatelessWidget {
  final String petId;

  const FloatingActionVac({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddVacPage(petId: petId),
          ),
        );
      },
      backgroundColor: const Color(0xFF4B39EF),
      elevation: 8,
      child: const Icon(
        Icons.add_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

Widget deleteVac(BuildContext context) {
  return AlertDialog(
    title: const Text('Confirmar Exclusão'),
    content: const Text('Tem certeza que deseja excluir esta vacina?'),
    actions: <Widget>[
      TextButton(
        child: const Text('Cancelar'),
        onPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
      TextButton(
        child: const Text('Excluir'),
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      ),
    ],
  );
}
