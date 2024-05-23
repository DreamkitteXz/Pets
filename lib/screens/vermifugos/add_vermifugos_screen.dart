import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_app/mvc_implementation/controllers/id_controller.dart';
import 'package:pet_app/teste_ate_padronizar/teste.dart';

import '../../components/id.dart';
import '../create_account/design/icon_button.dart';
import '../create_account/design/theme.dart';
import '../create_account/design/widgets.dart';

class AddVermifugoScreen extends StatefulWidget {
  final String? petId;

  AddVermifugoScreen({required this.petId});

  @override
  _AddVermifugoScreenState createState() => _AddVermifugoScreenState();
}

class _AddVermifugoScreenState extends State<AddVermifugoScreen> {
  DateTime? _selectedDate;
  bool _mostrarReforco = false;

  // Controladores dos campos que receberão as informações da vacina
  final vermifugoController = TextEditingController();
  final primeiraDoseController = TextEditingController();
  final kiloGramaController = TextEditingController();
  final segundaDoseController = TextEditingController();
  final terceiraDoseController = TextEditingController();
  final pesoController = TextEditingController();

  // ================================================================
  // Função de cadastro Vacina Firebase

  Future cadastroVermifugos(
    String vermifugo,
    String id,
    String primeiraDose,
    String doseReforco,
    String kiloGrama,
    String peso,
  ) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("Pets")
        .doc(widget.petId)
        .collection("Vermifugos")
        .doc(id)
        .set({
      "Id": id,
      "Vermifugo": vermifugo,
      "Primeira Dose": primeiraDose,
      "Dose de Reforço": doseReforco,
      "Kilogramas": kiloGrama,
      "Peso": peso,
    });
  }
  //=================================================================

  final _formKey = GlobalKey<FormState>();

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
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(32, 32, 32, 32),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adicione um Vermífugo',
                  style: FlutterFlowTheme.of(context).displaySmall.override(
                        fontFamily: 'Outfit',
                        fontSize: 28,
                      ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
                  child: Text(
                    'Preencha os campos abaixo para adicionar um Vermífugo.',
                    style: FlutterFlowTheme.of(context).labelMedium,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                  child: TextFormField(
                    controller: vermifugoController,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: 'Vermífugo',
                      hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                  child: TextFormField(
                    controller: pesoController,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: 'Peso ',
                      hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                  child: TextFormField(
                    readOnly: true,
                    controller: primeiraDoseController,
                    obscureText: false,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return 'Insira a data da primeira dose';
                      }
                      return null;
                    },
                    onTap: () async {
                      DateTime? pickedDate = await _showDataPicker();
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                          primeiraDoseController.text =
                              formatDateToString(pickedDate);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Primeira dose',
                      hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_month,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 22,
                      ),
                    ),
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Theme(
                        data: ThemeData(
                          checkboxTheme: CheckboxThemeData(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          unselectedWidgetColor:
                              FlutterFlowTheme.of(context).secondaryText,
                        ),
                        child: Checkbox(
                          value: _mostrarReforco,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _mostrarReforco = newValue!;
                            });
                          },
                          activeColor: FlutterFlowTheme.of(context).primary,
                          checkColor: FlutterFlowTheme.of(context).info,
                        ),
                      ),
                      Text(
                        'Dose de Reforço',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                    ],
                  ),
                ),
                _mostrarReforco
                    ? // Generated code for this TextField Widget...
                    Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          readOnly: true,
                          controller: segundaDoseController,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return 'Insira a data da dose de reforço';
                            }
                            return null;
                          },
                          onTap: () async {
                            DateTime? pickedDate = await _showDataPicker();
                            if (pickedDate != null) {
                              setState(() {
                                _selectedDate = pickedDate;
                                segundaDoseController.text =
                                    formatDateToString(pickedDate);
                              });
                            }
                          },
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Dose de Reforço',
                            hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0x00000000),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0x00000000),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0x00000000),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: Icon(
                              Icons.calendar_month,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 22,
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyLarge,
                        ),
                      )
                    : const SizedBox(),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                  child: FFButtonWidget(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        cadastroVermifugos(
                          vermifugoController.text.trim(),
                          gerarVersID(),
                          primeiraDoseController.text.trim(),
                          segundaDoseController.text.trim(),
                          kiloGramaController.text.trim(),
                          pesoController.text.trim(),
                        );
                        Navigator.pop(context);
                      }
                    },
                    text: 'Adicione',
                    options: FFButtonOptions(
                      width: 370,
                      height: 44,
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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

  Future<DateTime?> _showDataPickerhoje() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    return picked;
  }
  //===============================================================
}
