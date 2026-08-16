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

  /// Vacinas de um pet.
  ///
  /// O filtro por [ownerId] NÃO é redundante: a rule de `vaccines` libera
  /// leitura com `isVet() || isOwner()`, e o Firestore avalia rules de query
  /// contra a QUERY, não contra os documentos. Sem um `where` em `ownerId`
  /// (ou `veterinarianId`) o servidor não consegue provar que todo resultado
  /// é permitido e recusa a consulta inteira com PERMISSION_DENIED.
  /// Dois filtros de igualdade não exigem índice composto.
  Stream<List<Map<String, dynamic>>> vaccinesStreamByPet(
    String petId, {
    required String ownerId,
  }) {
    return _firestore
        .collection('vaccines')
        .where('ownerId', isEqualTo: ownerId)
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
