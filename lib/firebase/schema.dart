// Firestore schema in Dart for Flutter
import 'package:cloud_firestore/cloud_firestore.dart';

// Enums for various field types
enum UserRole { veterinarian, tutor }

enum UserStatus { active, pending, suspended }

enum VaccineStatus { pending, approved, rejected }

enum PetStatus { active, inactive }

enum ClinicStatus { active, inactive }

enum AppointmentType { checkup, vaccination, emergency, surgery }

enum AppointmentStatus { scheduled, completed, cancelled }

class FirestoreSchema {
  // Users collection
  static Map<String, dynamic> users(String userId) => {
        userId: {
          // Basic information for all users
          'email': String,
          'name': String,
          'cpf': String,
          'phone': String,
          'profileCompleted': bool,
          'role': UserRole.values.map((e) => e.name).toList(), // Enum in Dart
          'status':
              UserStatus.values.map((e) => e.name).toList(), // Enum in Dart
          'createdAt': Timestamp,
          'updatedAt': Timestamp,

          // Shared address information
          'address': {
            'street': String,
            'number': String,
            'complement': String,
            'neighborhood': String,
            'city': String,
            'state': String,
            'zipCode': String,
          },

          // Veterinarian specific information
          // Note: These fields would only be populated for veterinarians
          'crmv': String, // Optional: only for veterinarians
          'specialties': List<String>, // Optional: only for veterinarians
          'yearsOfExperience': int, // Optional: only for veterinarians
          'clinicId': String, // Optional: only for veterinarians

          // Tutor specific information
          'pets': List<String>, // Optional: only for tutors, Array of petIds
          'preferredVetId': String, // Optional: only for tutors
          'emergencyContact': {
            // Optional: only for tutors
            'name': String,
            'phone': String,
            'relationship': String,
          },
        }
      };

  // Vaccines collection
  static Map<String, dynamic> vaccines(String vaccineId) => {
        vaccineId: {
          // Basic vaccine information
          'name': String,
          'manufacturer': String,
          'batchNumber': String,
          'expirationDate': Timestamp,
          'administrationDate': Timestamp,
          'nextDueDate': Timestamp,

          // Pet information
          'petId': String,
          'petName': String,
          'petSpecies': String,
          'petBreed': String,
          'petWeight': double,

          // Owner information
          'ownerId': String,
          'ownerName': String,
          'ownerContact': String,

          // Veterinarian information
          'veterinarianId': String,
          'veterinarianName': String,
          'crmvNumber': String,
          'clinicName': String,
          'clinicCnpj': String,

          // Clinic address
          'clinicAddress': {
            'street': String,
            'number': String,
            'neighborhood': String,
            'city': String,
            'state': String,
          },

          // Validation status
          'status':
              VaccineStatus.values.map((e) => e.name).toList(), // Enum in Dart
          'validationDetails': {
            'validatedAt': Timestamp,
            'validatedBy': String, // validating vet's userId
            'notes': String,
            'rejectionReason': String,
          },

          // Additional information
          'labelImage': String, // URL to Firebase Storage
          'notes': String,
          'createdAt': Timestamp,
          'updatedAt': Timestamp,
        }
      };

  // Pets collection
  static Map<String, dynamic> pets(String petId) => {
        petId: {
          'name': String,
          'species': String,
          'breed': String,
          'birthDate': Timestamp,
          'color': String,
          'gender': String,
          'weight': double,
          'isNeutered': bool,
          'chipNumber': String,

          // Owner information
          'ownerId': String,
          'ownerName': String,

          // Vaccination history
          'vaccines': List<String>, // Array of vaccineIds

          'veterinarians': List<String>, // Array of veterinarianIds

          'status':
              PetStatus.values.map((e) => e.name).toList(), // Enum in Dart
          'createdAt': Timestamp,
          'updatedAt': Timestamp,
          'createdBy': String, // veterinarianId

          // Enhanced owner information
          'tutorId': String, // Reference to users collection
          'emergencyContacts':
              List<Map<String, dynamic>>, // List of emergency contacts

          // Medical history
          'medicalNotes': String,
          'allergies': List<dynamic>,
          'chronicConditions': String,
        }
      };

  // Clinics collection
  static Map<String, dynamic> clinics(String clinicId) => {
        clinicId: {
          'name': String,
          'cnpj': String,
          'phone': String,
          'email': String,

          'address': {
            'street': String,
            'number': String,
            'complement': String,
            'neighborhood': String,
            'city': String,
            'state': String,
            'zipCode': String,
          },

          'veterinarians': List<String>, // Array of veterinarianIds
          'status':
              ClinicStatus.values.map((e) => e.name).toList(), // Enum in Dart
          'createdAt': Timestamp,
          'updatedAt': Timestamp,
        }
      };

  // Appointments collection
  static Map<String, dynamic> appointments(String appointmentId) => {
        appointmentId: {
          'petId': String,
          'tutorId': String,
          'veterinarianId': String,
          'clinicId': String,
          'date': Timestamp,
          'type': AppointmentType.values
              .map((e) => e.name)
              .toList(), // Enum in Dart
          'status': AppointmentStatus.values
              .map((e) => e.name)
              .toList(), // Enum in Dart
          'notes': String,
          'createdAt': Timestamp,
          'updatedAt': Timestamp,
        }
      };
}
