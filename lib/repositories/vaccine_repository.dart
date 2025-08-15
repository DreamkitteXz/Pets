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

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final userSnapshot = await _firestore.collection('users').doc(userId).get();
    return userSnapshot.exists ? userSnapshot.data() : null;
  }

  Future<Map<String, dynamic>?> getPetData(String userId, String? petId) async {
    if (petId == null) return null;
    final petSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(petId)
        .get();
    return petSnapshot.exists ? petSnapshot.data() : null;
  }

  Future<Map<String, dynamic>?> getVaccineData(
      String userId, String? petId, String? vacId) async {
    if (petId == null || vacId == null) return null;
    final vaccineSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(petId)
        .collection('vaccines')
        .doc(vacId)
        .get();
    return vaccineSnapshot.exists ? vaccineSnapshot.data() : null;
  }

  Future<void> addPendingVaccine(
      String? vacId, Map<String, dynamic> data) async {
    await _firestore.collection('pending_vaccines').doc(vacId).set(data);
  }

  Future<List<Map<String, dynamic>>> fetchAvailableVaccinesFromApi() async {
    final response = await http.get(Uri.parse(
        'https://run.mocky.io/v3/cb845c8e-efb3-4ce6-abda-636552e01a26'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load vaccines');
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

  /// Deletes a vaccine by its ID.
  Future<void> deleteVaccine(String vaccineId) async {
    await _firestore.collection('vaccines').doc(vaccineId).delete();
  }
}
