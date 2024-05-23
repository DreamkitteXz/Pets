//TODO: VERIFICAR SE ISSO É BOM PARA A ORANIZAÇÃO DO CÓDIGO
import 'package:flutter/material.dart';
import 'package:pet_app/mvc_implementation/controllers/user_controller.dart';
import 'package:pet_app/mvc_implementation/models/user.dart';
import 'package:pet_app/mvc_implementation/screens/components/snackbar.dart';
import 'package:pet_app/mvc_implementation/screens/home_screen.dart';

void userLogin(BuildContext context, TextEditingController emailController,
    TextEditingController passwordController, UserController userController) {
  final Users user =
      Users(email: emailController.text, password: passwordController.text);
  userController.loginUser(user).then((String? erro) {
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: CustomSnackBar(errorText: erro),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: CustomSnackBar(successfulText: 'Login realizado com sucesso!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ));
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreenPage(),
          ));
    }
  });
}
