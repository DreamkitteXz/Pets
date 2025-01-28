import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_app/mvc_implementation/models/pets.dart';
import 'package:pet_app/mvc_implementation/models/vacinas.dart';
import 'package:pet_app/mvc_implementation/screens/add_vac.dart';
import 'package:pet_app/mvc_implementation/screens/vacina.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class VacinasPage extends StatelessWidget {
  final Pets pet;

  const VacinasPage({super.key, required this.pet});

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
                onTap: () async {
                  await _createPDF(context, pet.id);
                },
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
              return Image.network(
                  "https://iconscout.com/lottie-animations/cute-cat");
              //Center(child: CircularProgressIndicator())
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
                      return null;
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
                      onLongPress: () {},
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
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 4, 8, 0),
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
                        size: 24,
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
        await _createPDF(context, petId);
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

Future<void> _createPDF(BuildContext context, String petId) async {
  final PdfDocument document = PdfDocument();
  final PdfPage page = document.pages.add();
  final PdfGraphics graphics = page.graphics;
  final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);

  try {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Pets')
        .doc(petId)
        .collection("Vacinas")
        .get();

    if (snapshot.docs.isNotEmpty) {
      graphics.drawString(
        'Vacinas do Pet',
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold),
        bounds: const Rect.fromLTWH(0, 0, 500, 30),
      );

      double offsetY = 40;
      for (var doc in snapshot.docs) {
        final Vacinas vacina =
            Vacinas.fromMap(doc.data() as Map<String, dynamic>);

        final String text =
            'Vacina: ${vacina.vacina}, Data Aplicada: ${vacina.dataAplicada}, Validado: ${vacina.isValidadoVet == 'true' && vacina.isValidadoTutor == 'true' ? 'Sim' : 'Não'}';

        graphics.drawString(text, font,
            bounds: Rect.fromLTWH(0, offsetY, 500, 20));
        offsetY += 20;
      }
    } else {
      graphics.drawString(
        'Nenhuma vacina encontrada para este pet.',
        font,
        bounds: const Rect.fromLTWH(0, 0, 500, 20),
      );
    }

    List<int> bytes = await document.save();
    document.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/vacinas_pet.pdf');
    await file.writeAsBytes(bytes);

    OpenFile.open(file.path);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao gerar PDF: $e'),
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
