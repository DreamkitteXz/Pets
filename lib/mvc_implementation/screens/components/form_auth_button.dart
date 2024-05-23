//IMPLEMENTAR LÓGICA DE CONTROLLER E DECISÃO SE É LOGIN OU CREATE ACCOUNT
import 'package:flutter/material.dart';
import 'package:pet_app/mvc_implementation/controllers/user_controller.dart';

class FormButton extends StatelessWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final UserController userController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const FormButton({
    Key? key,
    required this.title,
    required this.formKey,
    required this.userController,
    required this.emailController,
    required this.passwordController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: const Color(0xFF041A23),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              side: const BorderSide(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                //userLogin(context);
              }
            },
          ),
        ),
      ),
    );
  }
}
