import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_app/mvc_implementation/controllers/id_controller.dart';

import '../../components/id.dart';
import '../create_account/design/icon_button.dart';
import '../create_account/design/theme.dart';
import '../create_account/design/widgets.dart';

class AddPetWidget extends StatefulWidget {
  const AddPetWidget({Key? key}) : super(key: key);

  @override
  _AddPetWidgetState createState() => _AddPetWidgetState();
}

class _AddPetWidgetState extends State<AddPetWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  final _tipoController = TextEditingController();
  final _racaController = TextEditingController();
  final _corController = TextEditingController();
  final _dataNascController = TextEditingController();
  final _sexoController = TextEditingController();
  final _chipController = TextEditingController();
  final _isInteiroController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final dropOptions1 = ['Cachorro', 'Gato'];
  final dropValue1 = ValueNotifier('');

  final dropOptions2 = ['Fêmea', 'Macho'];
  final dropValue2 = ValueNotifier('');

  final dropOptions3 = ['Inteiro', 'Castrado'];
  final dropValue3 = ValueNotifier('');

  DateTime? _selectedDate;

  // ===============================================================
  // Função DataPicker e Função de formatação para aparecer na Tela

  String formatDateToString(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<DateTime?> _showDataPickernasc() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 20),
      lastDate: DateTime.now(),
    );

    return picked;
  }
  //===============================================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Form(
        key: _formKey,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
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
            // ignore: prefer_const_literals_to_create_immutables
            actions: [],
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
            top: true,
            child: Align(
              alignment: const AlignmentDirectional(0, 0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(32, 12, 32, 32),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registre seu Pet',
                        style: FlutterFlowTheme.of(context).displaySmall,
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
                        child: Text(
                          'Preencha os campos abaixo para adicionar seu Pet.',
                          style: FlutterFlowTheme.of(context).labelMedium,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                            controller: _nameController,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Nome',
                              hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFD0D5DD),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFD0D5DD),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFFDA29B),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFFDA29B),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            style: FlutterFlowTheme.of(context).bodyLarge,
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return 'Insira o Nome';
                              }
                            }),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: ValueListenableBuilder(
                            valueListenable: dropValue1,
                            builder: (BuildContext context, String value, _) {
                              return DropdownButtonFormField<String>(
                                hint: const Text("Selecione o Tipo"),
                                value: (value.isEmpty) ? null : value,
                                items: dropOptions1
                                    .map((opcao) => DropdownMenuItem(
                                        value: opcao, child: Text(opcao)))
                                    .toList(),
                                onChanged: (escolha) {
                                  dropValue1.value = escolha.toString();
                                  _tipoController.text = escolha.toString();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Tipo',
                                  hintStyle:
                                      FlutterFlowTheme.of(context).bodyLarge,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D5DD),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D5DD),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFDA29B),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFDA29B),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: FlutterFlowTheme.of(context).bodyLarge,
                                validator: (value1) {
                                  if (value1 != null && value1.isEmpty) {
                                    return 'Insira o Tipo';
                                  }
                                },
                              );
                            }),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _racaController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Raça',
                            hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D5DD),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D5DD),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFFDA29B),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFFDA29B),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyLarge,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return 'Insira a Raça';
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _corController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Cor',
                            hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D5DD),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D5DD),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFFDA29B),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFFDA29B),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyLarge,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return 'Insira a Cor';
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: ValueListenableBuilder(
                            valueListenable: dropValue2,
                            builder: (BuildContext context, String value, _) {
                              return DropdownButtonFormField<String>(
                                hint: const Text("Selecione o Sexo"),
                                value: (value.isEmpty) ? null : value,
                                items: dropOptions2
                                    .map((opcao) => DropdownMenuItem(
                                        value: opcao, child: Text(opcao)))
                                    .toList(),
                                onChanged: (escolha) {
                                  dropValue2.value = escolha.toString();
                                  _sexoController.text = escolha.toString();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Sexo',
                                  hintStyle:
                                      FlutterFlowTheme.of(context).bodyLarge,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D5DD),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D5DD),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFDA29B),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFDA29B),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: FlutterFlowTheme.of(context).bodyLarge,
                                validator: (value) {
                                  if (value != null && value.isEmpty) {
                                    return 'Insira o Sexo';
                                  }
                                },
                              );
                            }),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dataNascController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Data de nascimento',
                            hintText: "dd/mm/aaaa",
                            hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D5DD),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D5DD),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFFDA29B),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFFDA29B),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await _showDataPickernasc();
                            if (pickedDate != null) {
                              setState(() {
                                _selectedDate = pickedDate;
                                _dataNascController.text =
                                    formatDateToString(pickedDate);
                              });
                            }
                          },
                          style: FlutterFlowTheme.of(context).bodyLarge,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return 'Insira a Data';
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: ValueListenableBuilder(
                            valueListenable: dropValue3,
                            builder: (BuildContext context, String value, _) {
                              return DropdownButtonFormField<String>(
                                hint: const Text("Inteiro ou Castrado?"),
                                value: (value.isEmpty) ? null : value,
                                items: dropOptions3
                                    .map((opcao) => DropdownMenuItem(
                                        value: opcao, child: Text(opcao)))
                                    .toList(),
                                onChanged: (escolha) {
                                  dropValue3.value = escolha.toString();
                                  _isInteiroController.text =
                                      escolha.toString();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Inteiro ou Castrado?',
                                  hintStyle:
                                      FlutterFlowTheme.of(context).bodyLarge,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D5DD),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D5DD),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFDA29B),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFDA29B),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: FlutterFlowTheme.of(context).bodyLarge,
                                validator: (value) {
                                  if (value != null && value.isEmpty) {
                                    return 'Informe se o seu Pet é castrado ou Inteiro';
                                  }
                                },
                              );
                            }),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _chipController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Chip',
                            hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D5DD),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D5DD),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFFDA29B),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFFDA29B),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyLarge,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: FFButtonWidget(
                          onPressed: () {
                            print(_tipoController.text);
                            if (_formKey.currentState!.validate()) {
                              cadastroPet(
                                  gerarPetsID(),
                                  _nameController.text.trim(),
                                  _tipoController.text.trim(),
                                  _racaController.text.trim(),
                                  _sexoController.text.trim(),
                                  _corController.text.trim(),
                                  _dataNascController.text.trim(),
                                  _isInteiroController.text.trim(),
                                  _chipController.text.trim());
                              Navigator.pop(context);
                            }
                          },
                          text: 'Adicione',
                          options: FFButtonOptions(
                            width: 370,
                            height: 44,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
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
      ),
    );
  }
}
