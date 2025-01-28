import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/mvc_implementation/models/user.dart';
import 'package:pet_app/mvc_implementation/screens/components/snackbar.dart';

//TODO: VERIFICAR O POR QUÊ DO WARNING DO BUILD CONTEXT NA HORA DE MOSTRAR O SNACK BAR

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firebaseDatabase = FirebaseFirestore.instance;

// usercontroller.dart

class UserController {
  Future<String?> getCurrentUser() async {
    return firebaseAuth.currentUser?.uid;
  }

  Future<bool> createUser(Users user, BuildContext context) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: user.email, password: user.password);
      await firebaseDatabase
          .collection("Users")
          .doc(firebaseAuth.currentUser!.uid)
          .set(user.toMap());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: CustomSnackBar(successfulText: 'Conta criada com sucesso!'),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ));
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: CustomSnackBar(errorText: 'Email já está em uso.'),
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            elevation: 0,
          ));
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: CustomSnackBar(errorText: e.code),
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            elevation: 0,
          ));
      }
      return false;
    }
  }

  Future<bool> loginUser(Users user, BuildContext context) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: user.email, password: user.password);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: CustomSnackBar(successfulText: 'Usuário logado com sucesso!'),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ));
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Usuário não encontrado!';
          break;
        case 'wrong-password':
          errorMessage = 'Senha Incorreta!';
          break;
        case 'invalid-email':
          errorMessage = 'Email Inválido!';
          break;
        default:
          errorMessage = e.code;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: CustomSnackBar(errorText: errorMessage),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ));
      return false;
    }
  }
}
