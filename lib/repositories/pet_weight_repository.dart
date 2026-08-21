import 'package:cloud_firestore/cloud_firestore.dart';

class PetWeightRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _weightsRef(String petId) {
    return _firestore.collection('pets').doc(petId).collection('weights');
  }

  Future<void> addWeight(String petId, double weight, {String? notes}) async {
    final now = DateTime.now();
    await _weightsRef(petId).add({
      'weight': weight,
      'date': Timestamp.fromDate(now),
      'notes': notes ?? '',
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  Stream<List<Map<String, dynamic>>> weightsStream(String petId) {
    return _weightsRef(petId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  Future<void> updateWeight(String petId, String weightId, double weight,
      {String? notes}) async {
    await _weightsRef(petId).doc(weightId).update({
      'weight': weight,
      'notes': notes ?? '',
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteWeight(String petId, String weightId) async {
    await _weightsRef(petId).doc(weightId).delete();
  }

  /// Peso **informado pelo tutor**, gravado no próprio documento do pet.
  ///
  /// Não confundir com a subcoleção `weights`: aquela é prontuário clínico e
  /// a rule só deixa o vet vinculado escrever. Já `pets/{petId}` tem
  /// `allow update: if uid == ownerId`, então o dono pode manter o peso atual
  /// do seu pet sem depender de mudança de backend. São duas fontes distintas
  /// e a tela as mostra separadas — auto-relato não vira pesagem clínica.
  Future<void> updateSelfReportedWeight(String petId, double weight) async {
    await _firestore.collection('pets').doc(petId).update({
      'weight': weight.toString(),
      'weightUpdatedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }
}
