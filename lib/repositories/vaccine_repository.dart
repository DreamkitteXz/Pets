import 'package:cloud_firestore/cloud_firestore.dart';

class VaccineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveVaccine(String id, Map<String, dynamic> data) async {
    await _firestore.collection('vaccines').doc(id).set(data);
  }

  Future<List<Map<String, dynamic>>> getVaccinesByOwner(String ownerId) async {
    final query = await _firestore
        .collection('vaccines')
        .where('ownerId', isEqualTo: ownerId)
        .get();
    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // [F1.3/§2.10] Removidos getUserData/getPetData/getVaccineData e
  // addPendingVaccine: liam a subcoleção antiga users/{uid}/pets/... (hoje
  // pets/vacinas são top-level) e escreviam em pending_vaccines (coleção sem
  // rule = negada). Toda a cadeia era código morto (addVaccineToQueue).

  /// Catálogo controlado de vacinas (coleção `vaccineCatalog`, leitura liberada
  /// a qualquer autenticado pela rule). Substitui o antigo fetch via mocky.io +
  /// lista hardcoded. Itens: {name, manufacturer, species:[...], reforcoDias}.
  /// F2.5/§2.8.
  Future<List<Map<String, dynamic>>> fetchVaccineCatalog() async {
    final query = await _firestore.collection('vaccineCatalog').get();
    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Returns a stream of vaccine maps for a given pet.
  Stream<List<Map<String, dynamic>>> vaccinesStreamByPet(String petId) {
    return _firestore
        .collection('vaccines')
        .where('petId', isEqualTo: petId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // [F2.3/§5] deleteVaccine removido: hard delete é negado por rule
  // (allow delete: if false). Registro clínico não é excluído pelo tutor.
}
