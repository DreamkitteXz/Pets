import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/models/pets.dart';
import 'package:pet_app/models/vacinas.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firebaseDatabase = FirebaseFirestore.instance;
String? vacId;

class VacController {
  Future<void> cadastroVacinas(
    String name,
    String id,
    String administrationDate,
    String nextDueDate,
    String weight,
    String batchNumber,
    String manufacturer,
    String expirationDate,
    String veterinarianName,
    String crmvNumber,
    String labelImage,
    String notes,
    String clinicCnpj,
    String clinicName,
    String street,
    String neighborhood,
    String number,
    String city,
    String validatedByVet,
    String validatedByTutor,
    String petId,
    String veterinarianId, // Add this parameter
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    DateTime? parseDate(String date) {
      try {
        final parts = date.split('/');
        if (parts.length == 3) {
          return DateTime(
              int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
      return null;
    }

    await FirebaseFirestore.instance.collection('vaccines').doc(id).set({
      'name': name,
      'manufacturer': manufacturer,
      'batchNumber': batchNumber,
      'expirationDate': parseDate(expirationDate),
      'administrationDate': parseDate(administrationDate),
      'nextDueDate': parseDate(nextDueDate),

      // Pet information
      'petId': petId,
      'petWeight': double.tryParse(weight) ?? 0.0,

      // Owner information
      'ownerId': user?.uid,
      'ownerName': user?.displayName,
      'ownerContact': user?.email,

      // Veterinarian information
      'veterinarianName': veterinarianName,
      'veterinarianId': veterinarianId, // Add this field
      'crmvNumber': crmvNumber,
      'clinicName': clinicName,
      'clinicCnpj': clinicCnpj,

      // Clinic address
      'clinicAddress': {
        'street': street,
        'number': number,
        'neighborhood': neighborhood,
        'city': city,
      },

      // Validation status
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
    });
    vacId = id;
  }

  Future<void> addVacInQueue(String? petId) async {
    try {
      var userId = FirebaseAuth.instance.currentUser!.uid;

      // Get tutor data
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!userSnapshot.exists) {
        print('Tutor not found');
        return;
      }
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> address =
          userData['address'] as Map<String, dynamic>;

      // Get pet data
      DocumentSnapshot petSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .get();
      if (!petSnapshot.exists) {
        print('Pet not found');
        return;
      }
      Map<String, dynamic> petData = petSnapshot.data() as Map<String, dynamic>;
      Pets pet = Pets.fromMap(petData);

      // Get vaccine data
      DocumentSnapshot vaccineSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .collection('vaccines')
          .doc(vacId)
          .get();
      if (!vaccineSnapshot.exists) {
        print('Vaccine not found');
        return;
      }
      Map<String, dynamic> vaccineData =
          vaccineSnapshot.data() as Map<String, dynamic>;

      // Add to pending vaccines collection
      await FirebaseFirestore.instance
          .collection('pending_vaccines')
          .doc(vacId)
          .set({
        'owner': {
          'name': userData['name'],
          'cpf': userData['cpf'],
          'phone': userData['phone'],
          'address': address,
        },
        'pet': {
          'id': pet.id,
          'name': pet.name,
          'species': pet.species,
          'breed': pet.breed,
          'color': pet.color,
          'gender': pet.gender,
          'birthDate': pet.birthDate,
          'isNeutered': pet.isNeutered,
          'chipNumber': pet.chipNumber,
        },
        'vaccine': vaccineData,
      });
    } catch (e) {
      print('Error adding vaccine to queue: $e');
      rethrow;
    }
  }
}
