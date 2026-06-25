import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

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

  Future<List<Map<String, dynamic>>> fetchAvailableVaccinesFromApi() async {
    try {
      final response = await http.get(Uri.parse(
          'https://run.mocky.io/v3/cb845c8e-efb3-4ce6-abda-636552e01a26'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load vaccines');
      }
    } catch (e) {
      // Fallback local list
      return [
        {
          'id': 'vac1',
          'name': 'V8',
          'description': 'Vacina múltipla para cães',
          'species': 'cachorro',
        },
        {
          'id': 'vac2',
          'name': 'Antirrábica',
          'description': 'Protege contra raiva',
          'species': 'cachorro',
        },
        {
          'id': 'vac3',
          'name': 'Tríplice Felina',
          'description': 'Protege contra três doenças felinas',
          'species': 'gato',
        },
        {
          'id': 'vac4',
          'name': 'Quádrupla Felina',
          'description': 'Protege contra quatro doenças felinas',
          'species': 'gato',
        },
      ];
    }
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
