import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_app/mvc_implementation/models/pets.dart';
import 'package:pet_app/mvc_implementation/models/vacinas.dart';
import 'package:pet_app/mvc_implementation/screens/add_vac.dart';
import 'package:pet_app/mvc_implementation/screens/vacina.dart';

class VacinasPage extends StatelessWidget {
  final Pets pet;

  const VacinasPage({required this.pet});

  @override
  Widget build(BuildContext context) {
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
                color: Color(0xFF080809)),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                right: 22.0,
              ),
              child: GestureDetector(
                onTap: () async {},
                child: SvgPicture.asset(
                  'lib/mvc_implementation/screens/assets/docs.svg',
                  width: 25,
                  height: 25,
                ),
              ),
            )
          ],
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
        floatingActionButton: FloatingActionVac(petId: pet.id),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('Pets')
              .doc(pet.id)
              .collection("Vacinas")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
              ;
            }

            List<Vacinas> listVac = snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              print(data);
              return Vacinas.fromMap(data);
            }).toList();

            return ListView.builder(
              itemCount: listVac.length,
              itemBuilder: (context, index) {
                Vacinas model = listVac[index];
                print(model.vacina);
                return Dismissible(
                    confirmDismiss: (DismissDirection direction) async {
                      if (direction == DismissDirection.endToStart) {
                        return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return deleteVac(context);
                            });
                      }
                    },
                    key: ValueKey<Vacinas>(model),
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
                            builder: (context) =>
                                VacinaPage(vacina: model, petId: pet.id),
                          ),
                        );
                        print(FirebaseAuth.instance.currentUser);
                      },
                      child: CardVacinas(pet: pet, model: model),
                    ));
              },
            );
          },
        ),
      ),
    );
    ;
  }

  void remove(Vacinas model) {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("Pets")
        .doc(pet.id)
        .collection("Vacinas")
        .doc(model.id)
        .delete();
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x411D2429),
              offset: Offset(0, 4),
            )
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 1, 1, 1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 1, 1, 1),
                      child: Container(
                        width: 70,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: pet.tipo == 'cachorro' || pet.tipo == 'Cachorro'
                            ? (pet.sexo == 'macho' || pet.sexo == 'Macho'
                                ? Image.asset(
                                    'lib/assets/vacinadogmacho-removebg-preview.png')
                                : Image.asset(
                                    'lib/assets/vacinadog-removebg-preview.png'))
                            : (pet.tipo == 'gato' || pet.tipo == 'Gato'
                                ? (pet.sexo == 'macho' || pet.sexo == 'macho'
                                    ? Image.asset(
                                        'lib/assets/catmachovac-removebg-preview.png')
                                    : Image.asset(
                                        'lib/assets/catfemeavac-removebg-preview.png'))
                                : Image.asset(
                                    'lib/assets/catfemeavac-removebg-preview.png')),
                      ),
                    ),
                  )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 4, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.vacina,
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w600),
                      ),
                      Flexible(
                        child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 4, 8, 0),
                            child: Row(
                              children: [
                                Text(
                                  (model.isValidadoVet == 'true' &&
                                          model.isValidadoTutor == 'true')
                                      ? 'Validado'
                                      : 'Aguardando validação',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SvgPicture.asset(
                                  (model.isValidadoVet == 'true' &&
                                          model.isValidadoTutor == 'true')
                                      ? 'lib/mvc_implementation/screens/assets/validado.svg'
                                      : 'lib/mvc_implementation/screens/assets/aguardando.svg',
                                  width: 18,
                                  height: 18,
                                )
                              ],
                            )),
                      ),
                      Flexible(
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 4, 8, 0),
                          child: Text(
                            model.dataAplicada,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 25.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF57636C),
                        size: 32,
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
}

AlertDialog deleteVac(BuildContext context) {
  return AlertDialog(
    title: const Text('Excluir'),
    content: const Text('Tem ceterteza que quer deletar esta Vacina?'),
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

class FloatingActionVac extends StatelessWidget {
  String petId;
  FloatingActionVac({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddVacPage(
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
