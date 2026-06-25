import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/screens/components/snackbar.dart';

FirebaseFirestore firebaseDatabase = FirebaseFirestore.instance;

class ValidacaoController {
  /// Ciência do tutor sobre uma vacina já validada pelo veterinário.
  ///
  /// O tutor NÃO aprova nem rejeita: `status` e `validationDetails` só mudam
  /// via Cloud Function (autoridade do vet). Pelas rules (tutorAckOnly), o
  /// dono só pode atualizar `tutorAcknowledged`/`tutorAcknowledgedAt`
  /// (+`updatedAt`); tocar qualquer outro campo dá permission-denied.
  /// F2.2/§5. (Substitui validadeVacTutor/rejectVacTutor, que escreviam
  /// status+validationDetails.tutorValidation e eram negados.)
  Future<void> darCiencia(String vacId) async {
    try {
      await firebaseDatabase.collection("vaccines").doc(vacId).update({
        "tutorAcknowledged": true,
        "tutorAcknowledgedAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
          .showSnackBar(SnackBar(
        content: CustomSnackBar(successfulText: 'Ciência registrada!'),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ));
    } catch (e) {
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
          .showSnackBar(SnackBar(
        content: CustomSnackBar(errorText: 'Erro ao registrar ciência: $e'),
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
