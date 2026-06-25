import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_app/models/vaccine_model.dart';
import 'package:pet_app/repositories/vaccine_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VaccineController {
  final VaccineRepository _repository = VaccineRepository();

  // Helper to parse date from dd/MM/yyyy
  DateTime? _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return null;
  }

  /// Registers a new vaccine in the database.
  Future<void> registerVaccine({
    required String name,
    required String id,
    required String administrationDate,
    required String nextDueDate,
    required String weight,
    required String batchNumber,
    required String manufacturer,
    required String expirationDate,
    required String veterinarianName,
    required String crmvNumber,
    required String labelImage,
    required String notes,
    required String clinicCnpj,
    required String clinicName,
    required String street,
    required String neighborhood,
    required String number,
    required String city,
    required String petId,
    required String veterinarianId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final vaccineData = {
      'name': name,
      'manufacturer': manufacturer,
      'batchNumber': batchNumber,
      'expirationDate': _parseDate(expirationDate),
      'administrationDate': _parseDate(administrationDate),
      'nextDueDate': _parseDate(nextDueDate),
      'petId': petId,
      'petWeight': double.tryParse(weight) ?? 0.0,
      'ownerId': user.uid,
      'ownerName': user.displayName,
      'ownerContact': user.email,
      'veterinarianName': veterinarianName,
      'veterinarianId': veterinarianId,
      'crmvNumber': crmvNumber,
      'clinicName': clinicName,
      'clinicCnpj': clinicCnpj,
      'clinicAddress': {
        'street': street,
        'number': number,
        'neighborhood': neighborhood,
        'city': city,
      },
      'status': 'pending',
      'validationDetails': {
        'validatedAt': null,
        'validatedBy': null,
        'notes': notes,
        'rejectionReason': null,
      },
      'labelImage': labelImage,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _repository.saveVaccine(id, vaccineData);
  }

  /// Fetches all vaccines for the current user.
  Future<List<Vacinas>> fetchVaccinesForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final vaccines = await _repository.getVaccinesByOwner(user.uid);
    return vaccines.map((data) {
      data['id'] ??= '';
      return Vacinas.fromMap(data);
    }).toList();
  }

  /// Fetches available vaccines from the API.
  Future<List<Map<String, dynamic>>> fetchAvailableVaccines() async {
    return await _repository.fetchAvailableVaccinesFromApi();
  }

  // [F1.3/§2.9/§2.10] Removido addVaccineToQueue: lia a subcoleção antiga
  // users/{uid}/pets/... e escrevia em pending_vaccines (coleção negada por
  // rule). Era código morto. A submissão de vacina pelo tutor depende da
  // decisão §13.2 (direto em vaccines status:'pending' vs. via CF).

  /// Returns a stream of vaccines for a given pet.
  Stream<List<Vacinas>> vaccinesStreamForPet(String petId) {
    return _repository
        .vaccinesStreamByPet(petId)
        .map((list) => list.map((data) {
              data['id'] ??= '';
              return Vacinas.fromMap(data);
            }).toList());
  }

  /// Deletes a vaccine by its ID.
  Future<void> deleteVaccine(String vaccineId) async {
    await _repository.deleteVaccine(vaccineId);
  }
}
