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
  ///
  /// Retorna `true` se o write passou. Quem chama precisa saber: a UI marca a
  /// ciência de forma otimista e não pode manter "Ciente" se o Firestore
  /// recusou.
  Future<bool> darCiencia(String vacId) async {
    try {
      await firebaseDatabase.collection("vaccines").doc(vacId).update({
        "tutorAcknowledged": true,
        "tutorAcknowledgedAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _snack(CustomSnackBar(errorText: 'Erro ao registrar ciência: $e'));
      return false;
    }
    // Fora do try: falhar em mostrar o snackbar não pode virar "não gravou".
    _snack(CustomSnackBar(successfulText: 'Ciência registrada!'));
    return true;
  }

  void _snack(Widget content) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: content,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ));
  }
}

// Navigation service to access context from anywhere
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
