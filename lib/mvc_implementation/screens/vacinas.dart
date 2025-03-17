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
import 'package:pet_app/mvc_implementation/services/vaccine_card_generator.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';

class VacinasPage extends StatelessWidget {
  final Pets pet;

  const VacinasPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    print("VacinasPage - Pet received: $pet"); // Add this debug print
    print("VacinasPage - Pet ID: ${pet.id}"); // Add this debug print

    if (pet.id == null) {
      print("VacinasPage - Pet ID is null!"); // Add this debug print
      // Return a more informative error screen
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vacinas'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Pet ID not found'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
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
                color: Color(0xFF080809)),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: GestureDetector(
                onTap: () async {
                  try {
                    final snapshot = await FirebaseFirestore.instance
                        .collection('vaccines')
                        .where('petId', isEqualTo: pet.id)
                        .get();

                    List<Vacinas> vaccines = snapshot.docs.map((doc) {
                      Map<String, dynamic> data = doc.data();
                      data['id'] = doc.id;
                      return Vacinas.fromMap(data);
                    }).toList();

                    final path = await VaccineCardGenerator.generateVaccineCard(
                        pet, vaccines);
                    final result = await OpenFile.open(
                      path,
                      type: 'application/pdf',
                    );

                    if (result.type != ResultType.done) {
                      throw Exception(result.message);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error opening PDF: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
        floatingActionButton: FloatingActionVac(petId: pet.id!),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vaccines')
              .where('petId', isEqualTo: pet.id)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              //  return Image.network(
              //"https://iconscout.com/lottie-animations/cute-cat");
              return const Center(child: CircularProgressIndicator());
            }

            List<Vacinas> listVac = snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              // Add document ID to the data
              data['id'] = document.id;
              return Vacinas.fromMap(data);
            }).toList();

            return ListView.builder(
              itemCount: listVac.length,
              itemBuilder: (context, index) {
                Vacinas model = listVac[index];
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
                                VacinaPage(vacina: model, petId: pet.id!),
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
    FirebaseFirestore.instance.collection("vaccines").doc(model.id).delete();
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
                            child: pet.species == 'dog'
                                ? (pet.gender == 'male'
                                    ? Image.asset(
                                        'lib/assets/vacinadogmacho-removebg-preview.png')
                                    : Image.asset(
                                        'lib/assets/vacinadog-removebg-preview.png'))
                                : (pet.gender == 'male'
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
                                    'Unknown Vaccine', // Changed from model.vacina
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lote: ${model.batchNumber ?? 'N/A'}',
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
                          : model.status == 'rejected'
                              ? Colors.red.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      model.status?.toUpperCase() ?? 'PENDING',
                      style: TextStyle(
                        color: model.status == 'approved'
                            ? Colors.green
                            : model.status == 'rejected'
                                ? Colors.red
                                : Colors.orange,
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

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  try {
    if (await Permission.storage.request().isGranted) {
      // Get the application files directory
      final directory = await getApplicationDocumentsDirectory();
      final appFlutterDir = Directory('${directory.path}/app_flutter');
      if (!await appFlutterDir.exists()) {
        await appFlutterDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final filePath = '${appFlutterDir.path}/vacinas_pet_$timestamp.pdf';
      final file = File(filePath);

      // Generate PDF content
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('vaccines')
          .where('petId', isEqualTo: petId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        graphics.drawString(
          'Vacinas do Pet',
          PdfStandardFont(PdfFontFamily.helvetica, 18,
              style: PdfFontStyle.bold),
          bounds: const Rect.fromLTWH(0, 0, 500, 30),
        );

        double offsetY = 40;
        for (var doc in snapshot.docs) {
          final Vacinas vacina =
              Vacinas.fromMap(doc.data() as Map<String, dynamic>);

          final String text =
              'Vacina: ${vacina.name}, Data Aplicada: ${formatDate(vacina.administrationDate)}, '
              'Status: ${vacina.status?.toUpperCase() ?? 'PENDING'}';

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

      // Save the PDF
      List<int> bytes = await document.save();
      document.dispose();
      await file.writeAsBytes(bytes);

      print('PDF saved at: ${file.path}');

      try {
        final result = await OpenFile.open(
          file.path,
          type: 'application/pdf',
          uti: 'com.adobe.pdf',
        );

        if (result.type != ResultType.done) {
          throw Exception(result.message);
        }
      } catch (e) {
        throw Exception('Could not open the PDF file: $e');
      }
    } else {
      throw Exception('Storage permission denied');
    }
  } catch (e) {
    print('Error generating PDF: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao gerar PDF: $e'),
        backgroundColor: Colors.red,
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
