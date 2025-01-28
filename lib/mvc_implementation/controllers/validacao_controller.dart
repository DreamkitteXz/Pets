import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//TODO: VERIFICAR O POR QUÊ DO WARNING DO BUILD CONTEXT NA HORA DE MOSTRAR O SNACK BAR

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firebaseDatabase = FirebaseFirestore.instance;

class ValidacaoController {
  String userId = firebaseAuth.currentUser!.uid;
  Future<void> validadeVacTutor(String petId, String vacId) async {
    final validacaoRef = firebaseDatabase
        .collection("Users")
        .doc(userId)
        .collection("Pets")
        .doc(petId)
        .collection("Vacinas")
        .doc(vacId);
    validacaoRef.update({"isValidadoTutor": 'true'}).then(
        (value) => print("DocumentSnapshot successfully updated!"),
        onError: (e) => print("Error updating document $e"));
  }
}
