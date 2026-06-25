//==============================================================================
// Descrição: Classe com atributos dos Vermifugos para melhor manipulação deles.
// Autor: Kayque Amado
// Data: 09/03/2024
//==============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class Vermifugo {
  String? id;
  String? name;
  String? manufacturer;
  String? dosage;
  double? weight;
  DateTime? administrationDate;
  DateTime? nextDueDate;
  bool? isReinforcementNeeded;
  DateTime? reinforcementDate;

  // Pet information
  String? petId;
  String? petName;
  double? petWeight;

  // Owner information
  String? ownerId;
  String? ownerName;

  // Veterinarian information
  String? veterinarianId;
  String? veterinarianName;
  String? crmvNumber;

  // Clinical information
  String? clinicId;
  String? clinicName;
  Map<String, String>? clinicAddress;

  // Status and tracking
  String? status;
  String? effectivenessNotes;
  List<String>? sideEffects;
  String? observations;

  // Metadata
  DateTime? createdAt;
  DateTime? updatedAt;
  String? createdBy;

  Vermifugo({
    this.id,
    this.name,
    this.manufacturer,
    this.dosage,
    this.weight,
    this.administrationDate,
    this.nextDueDate,
    this.isReinforcementNeeded,
    this.reinforcementDate,
    this.petId,
    this.petName,
    this.petWeight,
    this.ownerId,
    this.ownerName,
    this.veterinarianId,
    this.veterinarianName,
    this.crmvNumber,
    this.clinicId,
    this.clinicName,
    this.clinicAddress,
    this.status = 'pending', // eixo único (F2.1/§3.1); era 'active'
    this.effectivenessNotes,
    this.sideEffects,
    this.observations,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  factory Vermifugo.fromMap(Map<String, dynamic> map) {
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

    return Vermifugo(
      id: map['id'],
      name: map['name'],
      manufacturer: map['manufacturer'],
      dosage: map['dosage'],
      weight: map['weight']?.toDouble(),
      administrationDate: parseDate(map['administrationDate']),
      nextDueDate: parseDate(map['nextDueDate']),
      isReinforcementNeeded: map['isReinforcementNeeded'],
      reinforcementDate: parseDate(map['reinforcementDate']),
      petId: map['petId'],
      petName: map['petName'],
      petWeight: map['petWeight']?.toDouble(),
      ownerId: map['ownerId'],
      ownerName: map['ownerName'],
      veterinarianId: map['veterinarianId'],
      veterinarianName: map['veterinarianName'],
      crmvNumber: map['crmvNumber'],
      clinicId: map['clinicId'],
      clinicName: map['clinicName'],
      clinicAddress: Map<String, String>.from(map['clinicAddress'] ?? {}),
      status: map['status'],
      effectivenessNotes: map['effectivenessNotes'],
      sideEffects: List<String>.from(map['sideEffects'] ?? []),
      observations: map['observations'],
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      createdBy: map['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'manufacturer': manufacturer,
      'dosage': dosage,
      'weight': weight,
      'administrationDate': administrationDate,
      'nextDueDate': nextDueDate,
      'isReinforcementNeeded': isReinforcementNeeded,
      'reinforcementDate': reinforcementDate,
      'petId': petId,
      'petName': petName,
      'petWeight': petWeight,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'veterinarianId': veterinarianId,
      'veterinarianName': veterinarianName,
      'crmvNumber': crmvNumber,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'status': status,
      'effectivenessNotes': effectivenessNotes,
      'sideEffects': sideEffects,
      'observations': observations,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
    };
  }
}
