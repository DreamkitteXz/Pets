import 'package:cloud_firestore/cloud_firestore.dart';

//==========================================================================
// Descrição: Classe com atributos das Vacinas para melhor manipulação delas.
// Autor: Kayque Amado
// Data: 09/03/2024
//==========================================================================

// Eixo ÚNICO de status (alinhado à web/rules/CF): pending | approved | rejected.
// Ciência do tutor é um campo à parte (tutorAcknowledged). F2.1/§3.1.
enum VaccineStatus { pending, approved, rejected }

class Vacinas {
  String? id;
  String? name;
  String? manufacturer;
  String? batchNumber;
  DateTime? expirationDate;
  DateTime? administrationDate;
  DateTime? nextDueDate;

  // Pet information
  String? petId;
  String? petName;
  String? petSpecies;
  String? petBreed;
  double? petWeight;

  // Owner information
  String? ownerId;
  String? ownerName;
  String? ownerContact;

  // Veterinarian information
  String? veterinarianId;
  String? veterinarianName;
  String? crmvNumber;
  String? clinicName;
  String? clinicCnpj;

  // Clinic address
  Map<String, String>? clinicAddress;

  // Validation status
  String? status;
  // Só vetValidation (preenchido pela CF updateVaccineStatus). A ciência do
  // tutor é o campo tutorAcknowledged, não um bloco aqui. F2.1/§3.1.
  Map<String, dynamic>? validationDetails = {
    'vetValidation': {
      'status': null,
      'validatedAt': null,
      'validatedBy': null,
      'notes': null,
      'rejectionReason': null,
    },
  };

  // Ciência do tutor (único campo que o tutor pode atualizar — rule tutorAckOnly)
  bool? tutorAcknowledged;
  DateTime? tutorAcknowledgedAt;

  // Additional information
  String? labelImage;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;

  Vacinas({
    this.id,
    this.name,
    this.manufacturer,
    this.batchNumber,
    this.expirationDate,
    this.administrationDate,
    this.nextDueDate,
    this.petId,
    this.petName,
    this.petSpecies,
    this.petBreed,
    this.petWeight,
    this.ownerId,
    this.ownerName,
    this.ownerContact,
    this.veterinarianId,
    this.veterinarianName,
    this.crmvNumber,
    this.clinicName,
    this.clinicCnpj,
    this.clinicAddress,
    this.status = 'pending',
    this.validationDetails,
    this.tutorAcknowledged,
    this.tutorAcknowledgedAt,
    this.labelImage,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Vacinas.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          final parts = value.split('/');
          if (parts.length == 3) {
            return DateTime(
                int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        } catch (e) {
          print('Error parsing date string: $e');
        }
      }
      return null;
    }

    return Vacinas(
      id: map['id'],
      name: map['name'],
      manufacturer: map['manufacturer'],
      batchNumber: map['batchNumber'],
      expirationDate: parseDate(map['expirationDate']),
      administrationDate: parseDate(map['administrationDate']),
      nextDueDate: parseDate(map['nextDueDate']),
      petId: map['petId'],
      petName: map['petName'],
      petSpecies: map['petSpecies'],
      petBreed: map['petBreed'],
      petWeight: map['petWeight'] != null && map['petWeight'] != ""
          ? (map['petWeight'] is String
              ? double.tryParse(map['petWeight']) ?? 0.0
              : map['petWeight'] is int
                  ? (map['petWeight'] as int).toDouble()
                  : map['petWeight'] as double)
          : 0.0,
      ownerId: map['ownerId'],
      ownerName: map['ownerName'],
      ownerContact: map['ownerContact'],
      veterinarianId: map['veterinarianId'],
      veterinarianName: map['veterinarianName'],
      crmvNumber: map['crmvNumber'],
      clinicName: map['clinicName'],
      clinicCnpj: map['clinicCnpj'],
      clinicAddress: Map<String, String>.from(map['clinicAddress'] ?? {}),
      status: map['status'],
      validationDetails: map['validationDetails'] ??
          {
            'vetValidation': {
              'status': null,
              'validatedAt': null,
              'validatedBy': null,
              'notes': null,
              'rejectionReason': null,
            },
          },
      tutorAcknowledged: map['tutorAcknowledged'],
      tutorAcknowledgedAt: parseDate(map['tutorAcknowledgedAt']),
      labelImage: map['labelImage'],
      notes: map['notes'],
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'manufacturer': manufacturer,
      'batchNumber': batchNumber,
      'expirationDate': expirationDate,
      'administrationDate': administrationDate,
      'nextDueDate': nextDueDate,
      'petId': petId,
      'petName': petName,
      'petSpecies': petSpecies,
      'petBreed': petBreed,
      'petWeight': petWeight,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerContact': ownerContact,
      'veterinarianId': veterinarianId,
      'veterinarianName': veterinarianName,
      'crmvNumber': crmvNumber,
      'clinicName': clinicName,
      'clinicCnpj': clinicCnpj,
      'clinicAddress': clinicAddress,
      'status': status,
      'validationDetails': validationDetails,
      'labelImage': labelImage,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'labelImage': labelImage,
      'administrationDate': administrationDate?.toIso8601String(),
      'nextDueDate': nextDueDate?.toIso8601String(),
      'batchNumber': batchNumber,
      'manufacturer': manufacturer,
      'expirationDate': expirationDate?.toIso8601String(),
      'petWeight': petWeight,
      'notes': notes,
      'veterinarianName': veterinarianName,
      'crmvNumber': crmvNumber,
      'clinicName': clinicName,
      'clinicCnpj': clinicCnpj,
      'clinicAddress': clinicAddress,
      'validationDetails': validationDetails,
    };
  }
}
