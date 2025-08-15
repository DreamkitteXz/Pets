import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/models/deworming_model.dart';
import 'package:pet_app/screens/deworming/add_deworming_screen.dart';
import 'package:pet_app/screens/deworming/deworming_screen.dart';

class VermifugosPage extends StatelessWidget {
  final Pets pet;

  const VermifugosPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Vermífugos',
            style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: Color(0xFF080809)),
          ),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 30,
              color: Color(0xFF212121),
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionVermifugo(petId: pet.id!),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('dewormings')
              .where('petId', isEqualTo: pet.id)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Vermifugo> listVerm = snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Vermifugo.fromMap(data);
            }).toList();

            return ListView.builder(
              itemCount: listVerm.length,
              itemBuilder: (context, index) {
                Vermifugo model = listVerm[index];
                return Dismissible(
                    confirmDismiss: (DismissDirection direction) async {
                      if (direction == DismissDirection.endToStart) {
                        return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return deleteVermifugo(context);
                            });
                      }
                      return null;
                    },
                    key: ValueKey<Vermifugo>(model),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8))),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      remove(model);
                    },
                    child: GestureDetector(
                      onLongPress:
                          () {} /*Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditVacinaScreen(petId: petId, vacina: model),
                            ),
                          )*/

                      ,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VermifugoPage(
                              vermifugo: model,
                              petId: pet.id!,
                            ),
                          ),
                        );
                        print(FirebaseAuth.instance.currentUser);
                      },
                      child: CardVermifugo(pet: pet, model: model),
                    ));
              },
            );
          },
        ),
      ),
    );
  }

  void remove(Vermifugo model) {
    FirebaseFirestore.instance.collection("dewormings").doc(model.id).delete();
  }
}

class CardVermifugo extends StatelessWidget {
  const CardVermifugo({
    super.key,
    required this.pet,
    required this.model,
  });

  final Pets pet;
  final Vermifugo model;

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
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
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.medication_rounded,
                              size: 32,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                model.name ?? 'Unknown Dewormer',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (model.manufacturer != null)
                                Text(
                                  model.manufacturer!,
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
                  _buildStatusBadge(model.status),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFF43A047),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Aplicado: ${formatDate(model.administrationDate)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF707070),
                        ),
                      ),
                    ],
                  ),
                  if (model.isReinforcementNeeded == true)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECB3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.event_repeat,
                            size: 16,
                            color: Color(0xFFFFB300),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reforço: ${formatDate(model.reinforcementDate)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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

  Widget _buildStatusBadge(String? status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'active':
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF43A047);
        displayText = 'ATIVO';
        break;
      case 'completed':
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        displayText = 'COMPLETO';
        break;
      case 'expired':
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFE53935);
        displayText = 'EXPIRADO';
        break;
      default:
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF9800);
        displayText = 'PENDENTE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

AlertDialog deleteVermifugo(BuildContext context) {
  return AlertDialog(
    title: const Text('Excluir'),
    content: const Text('Tem ceterteza que quer deletar este Vermífugo?'),
    actions: <Widget>[
      ElevatedButton(
          style: const ButtonStyle(
              backgroundColor:
                  MaterialStatePropertyAll<Color>(Color(0xFF212121))),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Sim')),
      ElevatedButton(
          style: const ButtonStyle(
              backgroundColor:
                  MaterialStatePropertyAll<Color>(Color(0xFF212121))),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(' Não'))
    ],
  );
}

class FloatingActionVermifugo extends StatelessWidget {
  String petId;
  FloatingActionVermifugo({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddVermifugoPage(
                petId: petId,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF212121),
        elevation: 8,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
