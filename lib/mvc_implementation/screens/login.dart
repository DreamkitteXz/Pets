import 'package:flutter/material.dart';
import 'package:pet_app/mvc_implementation/controllers/user_controller.dart';
import 'package:pet_app/mvc_implementation/models/user.dart';
import 'package:pet_app/mvc_implementation/screens/components/action_text.dart';
import 'package:pet_app/mvc_implementation/screens/components/form_auth_button.dart';
import 'package:pet_app/mvc_implementation/screens/components/logo.dart';
import 'package:pet_app/mvc_implementation/screens/components/snackbar.dart';
import 'package:pet_app/mvc_implementation/screens/components/subtitle.dart';
import 'package:pet_app/mvc_implementation/screens/components/text_input_auth.dart';
import 'package:pet_app/mvc_implementation/screens/components/titles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final CustomSnackBar snackBar = CustomSnackBar();

  Users _createUserFromControllers() {
    return Users(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

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
                  title: 'Login',
                  fontSize: 32.0,
                  paddingL: 30.0,
                ),
                const SizedBox(height: 20),
                SubTitle(
                  subtitle:
                      'Bem vindo(a) de volta, preencha os campos com seus dados.',
                  fontSize: 14,
                ),
                const SizedBox(height: 40),
                TextInput(
                  inputTitle: 'Email',
                  controller: _emailController,
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20.0),
                TextInput(
                  inputTitle: 'Senha',
                  controller: _passwordController,
                  isPassword: true,
                  textInputType: TextInputType.name,
                ),
                const SizedBox(height: 40.0),
                FormButton(
                  title: 'Login',
                  formKey: _formKey,
                  userController: userController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  type: 1, //1 -> Login button
                ),
                const SizedBox(height: 20.0),
                ActionText(
                  text: 'Não tem uma conta? ',
                  //TODO: COLOCAR REDIRECIONAMENTO PARA A TELA SIGNUP!
                  textAction: 'Crie uma',
                ),
                const SizedBox(height: 20.0),
              ]),
        ),
      ),
    ));
  }
}

//TODO: COLOCAR ESSES COMPONENETES EM ARQUIVOS SEPARADOS

