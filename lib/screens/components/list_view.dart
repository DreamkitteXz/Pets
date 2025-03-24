import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/controllers/pet_controller.dart';
import 'package:pet_app/models/pets.dart';
import 'package:pet_app/screens/pet_information.dart';

class PetsList extends StatelessWidget {
  const PetsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pets')
                .where('ownerId', isEqualTo: userId)
                .where('status', isEqualTo: 'active')
                .snapshots(),
            builder: bringData));
  }

  Widget bringData(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasError) {
      print('Error in snapshot: ${snapshot.error}');
      return const Center(child: Text('Something went wrong'));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      print('No data available in snapshot');
      return const Center(child: Text('No pets found'));
    }

    List<Pets> listPet = snapshot.data!.docs.map((document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      // Set the document ID directly in the data
      data['id'] = document.id;
      print('Processing pet - Document ID: ${document.id}');
      return Pets.fromMap(data);
    }).toList();

    // Verify IDs are set correctly
    for (var pet in listPet) {
      print('Loaded pet - ID: ${pet.id}, Name: ${pet.name}');
    }

    return PetsCard(listPet);
  }

  ListView PetsCard(List<Pets> listPet) {
    const String imagemcaoMacho = 'lib/assets/dog-removebg-preview.png';
    const String imagemcaoFemea = 'lib/assets/dogfemea-removebg-preview.png';
    const String imagemgatoMacho = 'lib/assets/cat-removebg-preview.png';
    const String imagemgatoFemea = 'lib/assets/catfemea-removebg-preview.png';
    return ListView.builder(
        itemCount: listPet.length,
        itemBuilder: (context, index) {
          Pets model = listPet[index];
          return Dismissible(
              confirmDismiss: (DismissDirection direction) async {
                if (direction == DismissDirection.endToStart) {
                  return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return deletePet(context);
                      });
                }
                return null;
              },
              key: ValueKey<Pets>(model),
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
                //TODO:REMOVE
                PetController petController = PetController();
                petController.remove(model);
              },
              child: GestureDetector(
                onLongPress: (() {
                  print(model.id);
                }), // TODO: EDIT
                onTap: (() => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetInformation(
                          pet: model,
                        ),
                      ),
                    )),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 17), //OK
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 90, //OK 90 -- 100
                    decoration: BoxDecoration(
                      color: Colors.white, //OK
                      boxShadow: const [
                        //OK
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x411D2429),
                          offset: Offset(0, 4),
                        )
                      ],
                      borderRadius: BorderRadius.circular(8), //OK
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          12, 12, 25, 12), //OK
                      child: Row(
                        //OK
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 1, 1, 1),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 1, 1, 1),
                                  child: Container(
                                      width: 70,
                                      height: 100,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          boxShadow: const [
                                            BoxShadow(
                                              blurRadius: 4,
                                              color: Color(0x411D2429),
                                              offset: Offset(0, 4),
                                            )
                                          ]),
                                      child: model.species == 'dog'
                                          ? (model.gender == 'male'
                                              ? Image.asset(imagemcaoMacho)
                                              : Image.asset(imagemcaoFemea))
                                          : (model.species == 'cat'
                                              ? (model.gender == 'male'
                                                  ? Image.asset(imagemgatoMacho)
                                                  : Image.asset(
                                                      imagemgatoFemea))
                                              : Image.asset(imagemcaoMacho))),
                                )),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  3, 0, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 3),
                                    child: Text(model.name ?? 'Unknown name',
                                        style: const TextStyle(
                                            color: Color(0xFF080809),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              5, 4, 8, 0),
                                      child: Text(
                                          model.breed ?? 'Unknown breed',
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                              color: Color(0XFF707070),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              5, 4, 8, 0),
                                      child: Text(
                                        model.gender ?? 'Unknown',
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                            color: Color(0XFF707070),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF707070),
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
        });
  }

  AlertDialog deletePet(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir'),
      content: const Text('Tem ceterteza que quer deletar este Pet?'),
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
}
