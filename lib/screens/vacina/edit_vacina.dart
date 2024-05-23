import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_app/mvc_implementation/models/vacinas.dart';

import '../create_account/design/icon_button.dart';
import '../create_account/design/theme.dart';
import '../create_account/design/widgets.dart';

class EditVacinaScreen extends StatefulWidget {
  final Vacinas vacina;
  final String? petId;

  EditVacinaScreen({required this.vacina, required this.petId});

  @override
  _EditVacinaScreenState createState() => _EditVacinaScreenState();
}

class _EditVacinaScreenState extends State<EditVacinaScreen> {
  // Controladores dos campos que receberão as informações da vacina
  late TextEditingController nameController;
  late TextEditingController dataAplicadaController;
  late TextEditingController pesoController;
  late TextEditingController proximaAplicacaoController;
  late TextEditingController nomeVetController;
  late TextEditingController crmvController;
  late TextEditingController loteController;
  late TextEditingController farmaceuticaController;
  late TextEditingController dataValidadeController;
  late String imageURL;

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize the TextEditingController inside the initState method
    nameController = TextEditingController(text: widget.vacina.vacina);
    dataAplicadaController =
        TextEditingController(text: widget.vacina.dataAplicada);
    pesoController =
        TextEditingController(text: widget.vacina.pesoDataAplicacao);
    proximaAplicacaoController =
        TextEditingController(text: widget.vacina.proximaAplicacao);
    nomeVetController = TextEditingController(text: widget.vacina.nomeVet);
    crmvController = TextEditingController(text: widget.vacina.crmv);
    loteController = TextEditingController(text: widget.vacina.lote);
    farmaceuticaController =
        TextEditingController(text: widget.vacina.farmaceutica);
    dataValidadeController =
        TextEditingController(text: widget.vacina.dataValidade);
    imageURL = widget.vacina.imageRotulo;
  }

  @override
  void dispose() {
    // Dispose the TextEditingController when the state is disposed
    nameController.dispose();
    dataAplicadaController.dispose();
    super.dispose();
  }

  //=================================================================
  //Pegar dados da vacina

  // ================================================================
  // Função de cadastro Vacina Firebase

  Future cadastroVacinas(
    String vacina,
    String id,
    String dataAplicacao,
    String proximaAplicacao,
    String pesoAplicacao,
    String lote,
    String farmaceutica,
    String dataValidade,
    String nomeVet,
    String crmv,
    String imagemRotulo,
  ) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("Pets")
        .doc(widget.petId)
        .collection("Vacinas")
        .doc(id)
        .set({
      "Id": id,
      "Vacina": vacina,
      "Data Aplicada": dataAplicacao,
      "Peso do Pet": pesoAplicacao,
      "Próxima aplicação": proximaAplicacao,
      "Lote": lote,
      "Farmaceutica": farmaceutica,
      "Data de Validade": dataValidade,
      "Nome do Veterinário(a)": nomeVet,
      "CRMV do Veterinário(a)": crmv,
      "Imagem do Rótulo": imagemRotulo,
    });
  }

  //=================================================================

  final _formKey = GlobalKey<FormState>();
  File? _selectedImage; // Variável para armazenar a imagem selecionada

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
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
        ),
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0, 0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(32, 32, 32, 32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editar a vacina',
                      style: FlutterFlowTheme.of(context).displaySmall.override(
                            fontFamily: 'Outfit',
                            fontSize: 30,
                          ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
                      child: Text(
                        'Preencha os campos abaixo para editar as informações da vacina.',
                        style: FlutterFlowTheme.of(context).labelMedium,
                      ),
                    ),
                    // =======================================================================
                    // Nome da vacina
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: TextFormField(
                        controller: nameController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Vacina',
                          hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        validator: (String? value) {
                          if (value != null && value.isEmpty) {
                            return 'Insira a Vacina';
                          }
                          return null;
                        },
                      ),
                    ),
                    // =======================================================================
                    // Data Aplicada

                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: TextFormField(
                        readOnly: true,
                        controller: dataAplicadaController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Data aplicada',
                          hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        onTap: () async {
                          DateTime? pickedDate = await _showDataPicker();
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                              dataAplicadaController.text =
                                  formatDateToString(pickedDate);
                            });
                          }
                        },
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return 'Insira a data aplicada';
                          }
                          return null;
                        },
                      ),
                    ),

                    // =======================================================================
                    // Próxima aplicação

                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: TextFormField(
                        controller: proximaAplicacaoController,
                        readOnly: true,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Próxima aplicação',
                          hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        onTap: () async {
                          DateTime? pickedDate = await _showDataPicker();
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                              proximaAplicacaoController.text =
                                  formatDateToString(pickedDate);
                            });
                          }
                        },
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return 'Insira a data da próxima aplicação';
                          }
                          return null;
                        },
                      ),
                    ),
                    // =======================================================================
                    // Peso

                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: TextFormField(
                        controller: pesoController,
                        obscureText: false,
                        decoration: InputDecoration(
                          suffixText: 'kg',
                          labelText: 'Peso no dia da aplicação',
                          hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return 'Insira a Peso';
                          }
                          return null;
                        },
                      ),
                    ),

                    // =======================================================================
                    // Lote

                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: TextFormField(
                        controller: loteController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Lote',
                          hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return 'Insira o lote da vacina';
                          }
                          return null;
                        },
                      ),
                    ),

                    // =======================================================================
                    // Farmaceutica

                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: TextFormField(
                        controller: farmaceuticaController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Farmacêutica',
                          hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return 'Insira a Farmacêutica';
                          }
                          return null;
                        },
                      ),
                    ),

                    // =======================================================================
                    // Data Validade

                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: TextFormField(
                        readOnly: true,
                        controller: dataValidadeController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Data de validade',
                          hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await _showDataPicker();
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                              dataValidadeController.text =
                                  formatDateToString(pickedDate);
                            });
                          }
                        },
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return 'Insira a data de validade';
                          }
                          return null;
                        },
                      ),
                    ),

                    // =======================================================================
                    // Texto Rótulo e orientações

                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: Text(
                        'Rótulo da vacina',
                        style:
                            FlutterFlowTheme.of(context).displaySmall.override(
                                  fontFamily: 'Outfit',
                                  fontSize: 24,
                                ),
                      ),
                    ),
                    Text(
                      'Orientações:',
                      style: FlutterFlowTheme.of(context).displaySmall.override(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                          ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Tire a foto do Rótulo da vacina com o selo da vacina, assinatura e carimbo do veteriário(a).',
                              textAlign: TextAlign.start,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //==================================================================

                    if (imageURL.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageURL,
                            width: 300,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      const SizedBox(),

                    //==================================================================
                    // Botão camera Upload

                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
                      child: FFButtonWidget(
                        onPressed: () async {
                          //==============================================================
                          //Abrir a camera
                          ImagePicker imagePicker = ImagePicker();
                          XFile? file = await imagePicker.pickImage(
                              source: ImageSource.camera);

                          if (file == null) return;

                          String uniqueFileName =
                              DateTime.now().microsecondsSinceEpoch.toString();

                          //==============================================================
                          //Upload para o Firebase Storage

                          Reference referenceRoot =
                              FirebaseStorage.instance.ref();
                          Reference referenceDirRoot =
                              referenceRoot.child('images');
                          Reference referenceImageToUpload =
                              referenceDirRoot.child(uniqueFileName);

                          //==============================================================
                          //Tratando os erros

                          try {
                            //Guardar a imagem

                            await referenceImageToUpload
                                .putFile(File(file.path));

                            //download url

                            imageURL =
                                await referenceImageToUpload.getDownloadURL();

                            setState(() {});
                          } catch (error) {}

                          //==============================================================
                        },
                        text: 'Imagen do Rótulo',
                        icon: Icon(
                          Icons.photo_camera,
                          size: 15,
                        ),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 44,
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                  ),
                          elevation: 2,
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    //==================================================================
                    // Dados do Veterinário text

                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: Text(
                        'Dados do Veterinário(a)',
                        style:
                            FlutterFlowTheme.of(context).displaySmall.override(
                                  fontFamily: 'Outfit',
                                  fontSize: 24,
                                ),
                      ),
                    ),
                    //==================================================================
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: TextFormField(
                        controller: nomeVetController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        validator: (String? value) {
                          if (value != null && value.isEmpty) {
                            return 'Insira o Nome do(a) veterinário(a)';
                          }
                          return null;
                        },
                      ),
                    ),

                    //==================================================================

                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: TextFormField(
                        controller: crmvController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'CRMV',
                          hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFD0D5DD),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDA29B),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        validator: (String? value) {
                          if (value != null && value.isEmpty) {
                            return 'Insira o CRMV';
                          }
                          return null;
                        },
                      ),
                    ),

                    //==================================================================

                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: FFButtonWidget(
                        onPressed: () {
                          print(imageURL);

                          if (_formKey.currentState!.validate()) {
                            if (imageURL.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Faça o upload da imagem')));
                            }
                            cadastroVacinas(
                              nameController.text.trim(),
                              widget.vacina.id,
                              dataAplicadaController.text.trim(),
                              proximaAplicacaoController.text.trim(),
                              pesoController.text.trim(),
                              loteController.text.trim(),
                              farmaceuticaController.text.trim(),
                              dataValidadeController.text.trim(),
                              nomeVetController.text.trim(),
                              crmvController.text.trim(),
                              imageURL,
                            );
                            Navigator.pop(context);
                          }
                        },
                        text: 'Edite',
                        options: FFButtonOptions(
                          width: 370,
                          height: 44,
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                  ),
                          elevation: 3,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ===============================================================
  // Função DataPicker e Função de formatação para aparecer na Tela

  String formatDateToString(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<DateTime?> _showDataPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );

    return picked;
  }
  //===============================================================
}
