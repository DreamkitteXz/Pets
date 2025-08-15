import 'package:flutter/material.dart';
import 'package:pet_app/controllers/user_controller.dart';
import 'package:pet_app/screens/components/form_auth_button.dart';
import 'package:pet_app/screens/components/logo.dart';
import 'package:pet_app/screens/components/subtitle.dart';
import 'package:pet_app/screens/components/text_input_auth.dart';
import 'package:pet_app/screens/components/titles.dart';
import 'package:pet_app/utils/input_formatters_utils.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _cpfController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _streetController = TextEditingController();

  final TextEditingController _neighbourhoodController =
      TextEditingController();

  final TextEditingController _numberController = TextEditingController();

  final TextEditingController _stateController = TextEditingController();

  final TextEditingController _cepController = TextEditingController();

  final TextEditingController _addressInfoController = TextEditingController();

  // Add new controllers for emergency contact
  final TextEditingController _emergencyNameController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  final TextEditingController _emergencyRelationController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final UserController userController = UserController();
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Logo(),
                const SizedBox(height: 36),
                Titles(
                  title: 'Crie sua conta',
                  fontSize: 32.0,
                  paddingL: 30.0,
                ),
                const SizedBox(height: 20),
                SubTitle(
                  subtitle:
                      'Bem vindo(a) ao Pets, preencha os campos com seus dados para criar sua conta.',
                  fontSize: 14.0,
                ),
                const SizedBox(height: 40),
                TextInput(
                    inputTitle: 'Nome',
                    controller: _nameController,
                    textInputType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      return null;
                    }),
                const SizedBox(height: 20),
                TextInput(
                  inputTitle: 'Email',
                  controller: _emailController,
                  textInputType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email é obrigatório';
                    }
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextInput(
                  inputTitle: 'CPF',
                  controller: _cpfController,
                  textInputType: TextInputType.number,
                  inputFormatter: InputFormatters.cpfFormatter,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'CPF é obrigatório';
                    }
                    if (value.length < 14) {
                      // Including dots and dash
                      return 'CPF inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextInput(
                    inputTitle: 'Telefone',
                    controller: _phoneController,
                    textInputType: TextInputType.phone,
                    inputFormatter: InputFormatters.phoneFormatter,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Telefone é obrigatório';
                      }
                      if (value.length < 15) {
                        // Including parentheses and dash
                        return 'Telefone inválido';
                      }
                      return null;
                    }),
                const SizedBox(height: 20),
                TextInput(
                  inputTitle: 'Senha',
                  controller: _passwordController,
                  isPassword: true,
                  textInputType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Senha é obrigatória';
                    }
                    if (value.length < 6) {
                      return 'Senha deve ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30.0),
                Titles(
                  title: 'Endereço',
                  fontSize: 30.0,
                  paddingL: 30.0,
                ),
                const SizedBox(height: 30.0),
                TextInput(
                  inputTitle: 'Rua',
                  controller: _streetController,
                  textInputType: TextInputType.streetAddress,
                ),
                const SizedBox(height: 20.0),
                TextInput(
                  inputTitle: 'Bairro',
                  controller: _neighbourhoodController,
                  textInputType: TextInputType.streetAddress,
                ),
                const SizedBox(height: 20.0),
                TextInput(
                  inputTitle: 'Número',
                  controller: _numberController,
                  textInputType: TextInputType.number,
                ),
                const SizedBox(height: 20.0),
                //TODO: DROPDOWN LIST Para os Estados
                TextInput(
                  inputTitle: 'Estado',
                  controller: _stateController,
                  textInputType: TextInputType.name,
                ),
                const SizedBox(height: 20.0),
                TextInput(
                  inputTitle: 'CEP',
                  controller: _cepController,
                  textInputType: TextInputType.number,
                  inputFormatter: InputFormatters.cepFormatter,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'CEP é obrigatório';
                    }
                    if (value.length < 9) {
                      // Including dash
                      return 'CEP inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextInput(
                    inputTitle: 'Complemento',
                    controller: _addressInfoController,
                    textInputType: TextInputType.name),
                const SizedBox(height: 30.0),
                Titles(
                  title: 'Contato de Emergência',
                  fontSize: 30.0,
                  paddingL: 30.0,
                ),
                const SizedBox(height: 30.0),
                TextInput(
                  inputTitle: 'Nome do Contato',
                  controller: _emergencyNameController,
                  textInputType: TextInputType.name,
                ),
                const SizedBox(height: 20.0),
                TextInput(
                  inputTitle: 'Telefone do Contato',
                  controller: _emergencyPhoneController,
                  textInputType: TextInputType.phone,
                  inputFormatter: InputFormatters.phoneFormatter,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Telefone do contato é obrigatório';
                    }
                    if (value.length < 15) {
                      // Including parentheses and dash
                      return 'Telefone inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextInput(
                  inputTitle: 'Relação com o Contato',
                  controller: _emergencyRelationController,
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 40.0),
                //FORBUTTON
                FormButton(
                  title: 'Criar Conta',
                  formKey: _formKey,
                  userController: userController,
                  nameController: _nameController,
                  emailController: _emailController,
                  cpfController: _cpfController,
                  phoneController: _phoneController,
                  passwordController: _passwordController,
                  streetController: _streetController,
                  neighbourhoodController: _neighbourhoodController,
                  numberController: _numberController,
                  stateController: _stateController,
                  cepController: _cepController,
                  addressInfoController: _addressInfoController,
                  emergencyNameController: _emergencyNameController,
                  emergencyPhoneController: _emergencyPhoneController,
                  emergencyRelationController: _emergencyRelationController,
                  type: 2, // 2 -> Create account button
                ),
                const SizedBox(height: 20.0),
                const SizedBox(height: 20.0),
              ]),
        ),
      ),
    ));
  }
}
