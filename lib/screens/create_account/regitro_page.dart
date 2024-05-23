import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pet_app/authentication/component/show_snackbar.dart';
import 'package:pet_app/components/id.dart';

import '../Pet/home_screen.dart';
import 'design/icon_button.dart';
import 'design/theme.dart';
import 'design/widgets.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  //============================================================================
  //Estados Brasil
  final dropOptions1 = [
    'Acre',
    'Alagoas',
    'Amapá',
    'Amazonas',
    'Bahia',
    'Ceará',
    'Distrito Federal',
    'Espírito Santo',
    'Goiás',
    'Maranhão',
    'Mato Grosso',
    'Mato Grosso do Sul',
    'Minas Gerais',
    'Pará',
    'Paraíba',
    'Paraná',
    'Pernambuco',
    'Piauí',
    'Rio de Janeiro',
    'Rio Grande do Norte',
    'Rio Grande do Sul',
    'Rondônia',
    'Roraima',
    'Santa Catarina',
    'São Paulo',
    'Sergipe',
    'Tocantins'
  ];
  final dropValue1 = ValueNotifier('');

  //============================================================================

  //Text Controllers para o Envio dos dados

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _ruaController = TextEditingController();
  final _bairroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _cepController = TextEditingController();
  final _estadoController = TextEditingController();
  final _complementoController = TextEditingController();

  Future signIn() async {
    //Auth
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _senhaController.text.trim());
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          // ignore: use_build_context_synchronously
          return showSnackBar(
              context: context, texto: "Email já esta em uso.", isError: true);
      }
      return e.code;
    }

    //Adicionar Dados do Usuário

    addUserdatalhes(
        _nomeController.text.trim(),
        _emailController.text.trim(),
        _cpfController.text.trim(),
        _telefoneController.text.trim(),
        _senhaController.text.trim(),
        _ruaController.text.trim(),
        _bairroController.text.trim(),
        _cepController.text.trim(),
        _estadoController.text.trim(),
        _numeroController.text.trim(),
        _complementoController.text.trim());
  }

  bool _passwordVisible = false;

  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNumber = false;

  onPasswordChanged(String password) {
    final numericRegex = RegExp(r'[0-9]');

    setState(() {
      _isPasswordEightCharacters = false;
      if (password.length >= 8) _isPasswordEightCharacters = true;

      _hasPasswordOneNumber = false;
      if (numericRegex.hasMatch(password)) _hasPasswordOneNumber = true;
    });
  }

  void initState() {
    _passwordVisible = false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _ruaController.dispose();
    _bairroController.dispose();
    _cepController.dispose();
    _complementoController.dispose();
    _numeroController.dispose();
    _estadoController.dispose();

    super.dispose();
  }

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
          actions: const [],
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 12.0),

                      //===========================================================================================
                      //Textos do cabeçalho

                      // titulo
                      Text(
                        'Crie sua conta',
                        style: FlutterFlowTheme.of(context).displaySmall,
                      ),

                      // sub-texto
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
                        child: Text(
                          'Preencha os campos abaixo para criar sua conta',
                          style: FlutterFlowTheme.of(context).labelMedium,
                        ),
                      ),

                      //===========================================================================================
                      //Nome

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _nomeController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Nome completo',
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
                          validator: (String? value) {
                            if (value != null && value.isEmpty) {
                              return 'Insira o Nome';
                            }
                            return null;
                          },
                        ),
                      ),

                      //===========================================================================================
                      //Email

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _emailController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            hintText: 'exemplo@gmail.com',
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
                              return 'Insira o E-mail';
                            }

                            // Utilizando a função EmailValidator.validate do pacote email_validator
                            if (value != null &&
                                !EmailValidator.validate(value)) {
                              return 'E-mail inválido';
                            }
                            return null;
                          },
                        ),
                      ),

                      //===========================================================================================
                      //CPF

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: Container(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _cpfController,
                            inputFormatters: [
                              MaskTextInputFormatter(mask: '###.###.###-##')
                            ],
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'CPF',
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
                              if (value == null || value.isEmpty) {
                                return 'Digite o CPF';
                              } else if (!isValidCPF(value)) {
                                return 'CPF inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      //===========================================================================================
                      //Telefone

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                            controller: _telefoneController,
                            inputFormatters: [
                              MaskTextInputFormatter(mask: '(##) # ####-####')
                            ],
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Telefone',
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
                                return 'Insira o Telefone';
                              }
                              // Utilizando uma expressão regular para validar o número de telefone
                              if (value != null &&
                                  !RegExp(r'^\(\d{2}\) \d \d{4}-\d{4}$')
                                      .hasMatch(value)) {
                                return 'Telefone inválido';
                              }
                              return null;
                            }),
                      ),

                      //===========================================================================================
                      //Senha

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _senhaController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            labelText: 'Senha',
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
                            suffixIcon: InkWell(
                              onTap: () => setState(
                                () => _passwordVisible = !_passwordVisible,
                              ),
                              focusNode: FocusNode(skipTraversal: true),
                              child: Icon(
                                _passwordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 22,
                              ),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyLarge,
                          validator: (String? value) {
                            if (value != null && value.isEmpty) {
                              return 'Insira a Senha';
                            }
                            return null;
                          },
                        ),
                      ),

                      //===========================================================================================
                      //Endereço texto

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: Text(
                          'Endereço',
                          textAlign: TextAlign.start,
                          style: FlutterFlowTheme.of(context)
                              .displaySmall
                              .override(
                                fontFamily: 'Outfit',
                                fontSize: 28,
                              ),
                        ),
                      ),

                      //===========================================================================================
                      //Rua

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _ruaController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Rua',
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
                          validator: (String? value) {
                            if (value != null && value.isEmpty) {
                              return 'Insira a Rua';
                            }
                            return null;
                          },
                        ),
                      ),

                      //===========================================================================================
                      //Bairro

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _bairroController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Bairro',
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
                          validator: (String? value) {
                            if (value != null && value.isEmpty) {
                              return 'Insira o Bairro';
                            }
                            return null;
                          },
                        ),
                      ),

                      //===========================================================================================
                      //Numero

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _numeroController,
                          keyboardType: TextInputType.number,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Número',
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
                              return 'Insira o número';
                            }
                            return null;
                          },
                        ),
                      ),

                      //===========================================================================================
                      //Estado

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: ValueListenableBuilder(
                            valueListenable: dropValue1,
                            builder: (BuildContext context, String value, _) {
                              return DropdownButtonFormField<String>(
                                hint: const Text("Selecione o Estado"),
                                value: (value.isEmpty) ? null : value,
                                items: dropOptions1
                                    .map((opcao) => DropdownMenuItem(
                                        value: opcao, child: Text(opcao)))
                                    .toList(),
                                onChanged: (escolha) {
                                  dropValue1.value = escolha.toString();
                                  _estadoController.text = escolha.toString();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Estado',
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
                                    return 'Selecione o Estado';
                                  }
                                },
                              );
                            }),
                      ),
                      //===========================================================================================
                      //CEP

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _cepController,
                          inputFormatters: [
                            MaskTextInputFormatter(mask: '#####-###')
                          ],
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'CEP',
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
                              return 'Insira o CEP';
                            }
                          },
                        ),
                      ),

                      //===========================================================================================
                      //Complemento

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _complementoController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Complemento',
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
                          // validator: _complementoController.textController1Validator.asValidator(context),
                        ),
                      ),

                      //===========================================================================================
                      //Botão de Cadastrar

                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 16),
                        child: FFButtonWidget(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              signIn();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CadastroPet(),
                                  ));
                            }
                          },
                          text: 'Crie sua conta',
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
                      )

                      //===========================================================================================
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

  bool isValidCPF(String cpf) {
    // Remova caracteres não numéricos do CPF
    cpf = cpf.replaceAll(RegExp(r'[^\d]'), '');

    // Verifique se o CPF tem 11 dígitos
    if (cpf.length != 11) {
      return false;
    }

    // Verifique se todos os dígitos são iguais, o que torna o CPF inválido
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) {
      return false;
    }

    // Calcule o primeiro dígito verificador
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int resto = soma % 11;
    int digito1 = (resto < 2) ? 0 : 11 - resto;

    // Verifique o primeiro dígito verificador
    if (digito1 != int.parse(cpf[9])) {
      return false;
    }

    // Calcule o segundo dígito verificador
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    resto = soma % 11;
    int digito2 = (resto < 2) ? 0 : 11 - resto;

    // Verifique o segundo dígito verificador
    if (digito2 != int.parse(cpf[10])) {
      return false;
    }

    // Se chegou até aqui, o CPF é válido
    return true;
  }
}
