import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/models/user_model.dart';
import 'package:pet_app/screens/components/snackbar.dart';
import 'package:pet_app/repositories/user_repository.dart';

//TODO: VERIFICAR O POR QUÊ DO WARNING DO BUILD CONTEXT NA HORA DE MOSTRAR O SNACK BAR

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firebaseDatabase = FirebaseFirestore.instance;

// usercontroller.dart

class UserController {
  final UserRepository _userRepository = UserRepository();

  Future<Users?> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await _userRepository.getUserById(user.uid);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _userRepository.updateUser(userId, data);
  }

  Future<bool> createUser(Users user, BuildContext context) async {
    try {
      // Create auth user
      UserCredential credential =
          await firebaseAuth.createUserWithEmailAndPassword(
              email: user.email, password: user.password);

      // Set additional user data in Firestore
      await firebaseDatabase
          .collection("users") // Changed from "Users" to "users"
          .doc(credential.user!.uid)
          .set({
        ...user.toMap(),
        'id': credential.user!.uid, // Ensure ID is set
        'createdAt': FieldValue.serverTimestamp(), // Use server timestamp
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
