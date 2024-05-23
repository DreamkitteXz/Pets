import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/mvc_implementation/models/pets.dart';

class PetController {
  FirebaseFirestore firebaseDatabase = FirebaseFirestore.instance;

  void remove(Pets model) {
    firebaseDatabase
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("Pets")
        .doc(model.id)
        .delete();
  }
}
