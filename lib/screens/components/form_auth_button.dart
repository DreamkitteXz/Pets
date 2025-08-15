// form_button.dart
import 'package:flutter/material.dart';
import 'package:pet_app/controllers/user_controller.dart';
import 'package:pet_app/models/user_model.dart';
import 'package:pet_app/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FormButton extends StatelessWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final UserController userController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? nameController;
  final TextEditingController? cpfController;
  final TextEditingController? phoneController;
  final TextEditingController? streetController;
  final TextEditingController? neighbourhoodController;
  final TextEditingController? numberController;
  final TextEditingController? stateController;
  final TextEditingController? cepController;
  final TextEditingController? addressInfoController;
  final TextEditingController? emergencyNameController;
  final TextEditingController? emergencyPhoneController;
  final TextEditingController? emergencyRelationController;
  final int type;

  const FormButton({
    Key? key,
    required this.title,
    required this.formKey,
    required this.userController,
    required this.emailController,
    required this.passwordController,
    this.nameController,
    this.cpfController,
    this.phoneController,
    this.streetController,
    this.neighbourhoodController,
    this.numberController,
    this.stateController,
    this.cepController,
    this.addressInfoController,
    this.emergencyNameController,
    this.emergencyPhoneController,
    this.emergencyRelationController,
    required this.type,
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
              backgroundColor: const Color(0xFF041A23),
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
                fontSize: 18,
              ),
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                switch (type) {
                  case 1:
                    bool loginSuccessful = await userController.loginUser(
                      Users(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      ),
                      context,
                    );
                    if (loginSuccessful) {
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomeScreenPage(user: currentUser),
                          ),
                        );
                      }
                    }
                    break;
                  case 2:
                    bool accountCreated = await userController.createUser(
                      Users(
                        name: nameController?.text.trim(),
                        email: emailController.text.trim(),
                        cpf: cpfController?.text.trim(),
                        phone: phoneController?.text.trim(),
                        password: passwordController.text.trim(),
                        street: streetController?.text.trim(),
                        neighbourhood: neighbourhoodController?.text.trim(),
                        number: numberController?.text.trim(),
                        state: stateController?.text.trim(),
                        cep: cepController?.text.trim(),
                        addressDetails: addressInfoController?.text.trim(),
                        role: 'tutor',
                        status: 'active',
                        profileCompleted: false,
                        emergencyContact: {
                          'name': emergencyNameController?.text.trim(),
                          'phone': emergencyPhoneController?.text.trim(),
                          'relationship':
                              emergencyRelationController?.text.trim(),
                        },
                      ),
                      context,
                    );
                    if (accountCreated) {
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomeScreenPage(user: currentUser),
                          ),
                        );
                      }
                    }
                    break;
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
