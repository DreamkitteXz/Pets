import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/mvc_implementation/models/pets.dart';

class PetController {
  FirebaseFirestore firebaseDatabase = FirebaseFirestore.instance;

  Future<void> createPet(Pets pet) async {
    try {
      // Create pet in top-level pets collection
      await firebaseDatabase.collection('pets').doc(pet.id).set({
        ...pet.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add pet reference to user's pets array
      await firebaseDatabase.collection('users').doc(pet.ownerId).update({
        'pets': FieldValue.arrayUnion([pet.id])
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> remove(Pets model) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Remove pet document from main pets collection
      await firebaseDatabase.collection("pets").doc(model.id).delete();

      // Remove pet ID from user's pets array
      await firebaseDatabase.collection("users").doc(userId).update({
        'pets': FieldValue.arrayRemove([model.id])
      });
    } catch (e) {
      print('Error removing pet: $e');
      rethrow;
    }
  }
}
