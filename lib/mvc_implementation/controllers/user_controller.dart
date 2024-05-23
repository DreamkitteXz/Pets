import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/mvc_implementation/models/user.dart';
import 'package:pet_app/mvc_implementation/screens/components/snackbar.dart';

//TODO: VERIFICAR O POR QUÊ DO WARNING DO BUILD CONTEXT NA HORA DE MOSTRAR O SNACK BAR

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firebaseDatabase = FirebaseFirestore.instance;

class UserController {
  Future<String?> getCurrentUser() async {
    return firebaseAuth.currentUser?.uid;
  }

  //ADD NEW USER
  Future addUser(String uid, Users user) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: user.email!, password: user.password!);
      await firebaseDatabase.collection("Users").doc(uid).set(user.toMap());
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return CustomSnackBar(errorText: 'Email já está em uso.');
      }
      return CustomSnackBar(errorText: e.code);
    }
  }

  //LOGIN
  Future<String?> loginUser(Users user) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: user.email, password: user.password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuário não encontrado!';
        case 'wrong-password':
          return 'Senha Incorreta!';
        case 'invalid-email':
          return 'Email Invalido!';
      }
      print('E.CODE: ${e.code}');
      return '$e.code';
    }
    return null;
  }
}
