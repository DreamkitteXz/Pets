import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/screens/components/snackbar.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firebaseDatabase = FirebaseFirestore.instance;

class ValidacaoController {
  String userId = firebaseAuth.currentUser!.uid;

  Future<void> validadeVacTutor(String petId, String vacId) async {
    try {
      final validacaoRef = firebaseDatabase.collection("vaccines").doc(vacId);
      final now = Timestamp.now();

      await validacaoRef.update({
        "status": "approved",
        "validationDetails.tutorValidation": {
          "status": "approved",
          "validatedAt": now,
          "validatedBy": userId,
          "notes": "",
          "rejectionReason": "",
        }
      });

      // Show success message
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
          .showSnackBar(SnackBar(
        content: CustomSnackBar(successfulText: 'Vacina validada com sucesso!'),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ));
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
          .showSnackBar(SnackBar(
        content: CustomSnackBar(errorText: 'Erro ao validar vacina: $e'),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ));
    }
  }

  Future<void> rejectVacTutor(String petId, String vacId, String reason) async {
    try {
      final validacaoRef = firebaseDatabase.collection("vaccines").doc(vacId);
      final now = Timestamp.now();

      await validacaoRef.update({
        "status": "rejected",
        "validationDetails.tutorValidation": {
          "status": "rejected",
          "validatedAt": now,
          "validatedBy": userId,
          "notes": "",
          "rejectionReason": reason,
        }
      });

      // Show success message
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
          .showSnackBar(SnackBar(
        content:
            CustomSnackBar(successfulText: 'Vacina rejeitada com sucesso!'),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ));
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
          .showSnackBar(SnackBar(
        content: CustomSnackBar(errorText: 'Erro ao rejeitar vacina: $e'),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ));
    }
  }
}

// Navigation service to access context from anywhere
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
