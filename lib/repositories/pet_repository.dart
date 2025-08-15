import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_app/models/pet_model.dart';

class PetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPet(Pets pet) async {
    final doc = _firestore.collection('pets').doc();
    final petData = pet.toMap();
    petData['id'] = doc.id;
    await doc.set(petData);
  }

  Future<void> removePet(Pets pet) async {
    if (pet.id == null) return;
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
