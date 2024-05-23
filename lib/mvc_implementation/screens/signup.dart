import 'package:flutter/material.dart';
import 'package:pet_app/mvc_implementation/controllers/user_controller.dart';
import 'package:pet_app/mvc_implementation/screens/components/logo.dart';
import 'package:pet_app/mvc_implementation/screens/components/subtitle.dart';
import 'package:pet_app/mvc_implementation/screens/components/text_input_auth.dart';
import 'package:pet_app/mvc_implementation/screens/components/titles.dart';
import 'package:pet_app/mvc_implementation/screens/login.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

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
                TextInput(inputTitle: 'Nome', controller: _nameController),
                const SizedBox(height: 20),
                TextInput(
                  inputTitle: 'Email',
                  controller: _emailController,
                ),
                const SizedBox(height: 20.0),
                TextInput(inputTitle: 'CPF', controller: _cpfController),
                const SizedBox(height: 20),
                TextInput(inputTitle: 'Telefone', controller: _phoneController),
                const SizedBox(height: 20),
                TextInput(
                  inputTitle: 'Senha',
                  controller: _passwordController,
                  isPassword: true,
                ),
                const SizedBox(height: 30.0),
                Titles(
                  title: 'Endereço',
                  fontSize: 30.0,
                  paddingL: 30.0,
                ),
                const SizedBox(height: 30.0),
                TextInput(inputTitle: 'Rua', controller: _streetController),
                const SizedBox(height: 20.0),
                TextInput(
                    inputTitle: 'Bairro', controller: _neighbourhoodController),
                const SizedBox(height: 20.0),
                TextInput(inputTitle: 'Número', controller: _numberController),
                const SizedBox(height: 20.0),
                //TODO: DROPDOWN LIST Para os Estados
                TextInput(inputTitle: 'Estado', controller: _stateController),
                const SizedBox(height: 20.0),
                TextInput(inputTitle: 'CEP', controller: _cepController),
                const SizedBox(height: 20.0),
                TextInput(
                    inputTitle: 'Complemento',
                    controller: _addressInfoController),
                const SizedBox(height: 40.0),
                //FORBUTTON
                const SizedBox(height: 20.0),
                const SizedBox(height: 20.0),
              ]),
        ),
      ),
    ));
  }
}
