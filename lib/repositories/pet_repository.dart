import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/models/pet_model.dart';

class PetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPet(Pets pet) async {
    final doc = _firestore.collection('pets').doc();
    final petData = pet.toMap();
    petData['id'] = doc.id;
    // createdBy = quem cria o pet (no app, o próprio tutor). Necessário para a
    // rule de pets: delete exige createdBy==uid e update aceita createdBy OU
    // ownerId. Sem isso o delete do pet falha. F0.4/§5.
    petData['createdBy'] = FirebaseAuth.instance.currentUser?.uid;
    await doc.set(petData);
  }

  Future<void> removePet(Pets pet) async {
    if (pet.id.isEmpty) return;
    await _firestore.collection('pets').doc(pet.id).delete();
  }

  Future<List<Pets>> fetchPetsByOwner(String ownerId) async {
    final query = await _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .get();
    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Pets.fromMap(data);
    }).toList();
  }

  Stream<List<Pets>> petsStreamByOwner(String ownerId) {
    return _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Pets.fromMap(data);
            }).toList());
  }
}
