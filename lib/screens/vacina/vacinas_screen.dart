import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/mvc_implementation/models/vacinas.dart';
import 'package:pet_app/screens/vacina/vacinas_detalhes.dart';

import '../create_account/design/icon_button.dart';
import '../create_account/design/theme.dart';
import 'add_vacina.dart';
import 'edit_vacina.dart';

class VacinasPet extends StatelessWidget {
  final String? petId;
  final String? petSexo;
  final String? petTipo;

  const VacinasPet({this.petId, this.petSexo, this.petTipo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: Text(
          'Vacinas',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
              ),
        ),
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30,
          borderWidth: 1,
          buttonSize: 60,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 30,
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        actions: const [],
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddVacinaWidget(petId: petId),
            ),
          );
        },
        backgroundColor: FlutterFlowTheme.of(context).primary,
        elevation: 8,
        child: Icon(
          Icons.add,
          color: FlutterFlowTheme.of(context).primaryBackground,
          size: 24,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('Pets')
            .doc(petId)
            .collection("Vacinas")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
            ;
          }

          List<Vacinas> listVac = snapshot.data!.docs.map((document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            print(data);
            return Vacinas.fromMap(data);
          }).toList();

          return ListView.builder(
            itemCount: listVac.length,
            itemBuilder: (context, index) {
              Vacinas model = listVac[index];
              print(model.vacina);
              return Dismissible(
                  key: ValueKey<Vacinas>(model),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Excluir'),
                              content: const Text(
                                  'Tem ceterteza que quer deletar este item?'),
                              actions: <Widget>[
                                ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Sim')),
                                ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text(' Não'))
                              ],
                            );
                          });
                    }
                  },
                  onDismissed: (direction) {
                    remove(model);
                  },
                  child: GestureDetector(
                    onLongPress: (() => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditVacinaScreen(petId: petId, vacina: model),
                          ),
                        )),
                    onTap: (() => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VacinaWidget(vacina: model),
                          ),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 3,
                              color: Color(0x411D2429),
                              offset: Offset(0, 1),
                            )
                          ],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 1, 1, 1),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 1, 1, 1),
                                      child: Container(
                                        width: 70,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .lineColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: petTipo == 'cachorro' ||
                                                petTipo == 'Cachorro'
                                            ? (petSexo == 'macho' ||
                                                    petSexo == 'Macho'
                                                ? Image.asset(
                                                    'lib/assets/vacinadogmacho-removebg-preview.png')
                                                : Image.asset(
                                                    'lib/assets/vacinadog-removebg-preview.png'))
                                            : (petTipo == 'gato' ||
                                                    petTipo == 'Gato'
                                                ? (petSexo == 'macho' ||
                                                        petSexo == 'macho'
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      8, 8, 4, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        model.vacina,
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor4,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0, 4, 8, 0),
                                          child: Text(
                                            model.dataAplicada,
                                            textAlign: TextAlign.start,
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0, 4, 8, 0),
                                          child: Text(
                                            model.proximaAplicacao,
                                            textAlign: TextAlign.start,
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: const [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 4, 0, 0),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      color: Color(0xFF57636C),
                                      size: 24,
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
            },
          );
        },
      ),
    );
    ;
  }

  void remove(Vacinas model) {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("Pets")
        .doc(petId)
        .collection("Vacinas")
        .doc(model.id)
        .delete();
  }
}
