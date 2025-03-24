//========================================================================
// Descrição: Classe com atributos dos Pets para melhor manipulação deles.
// Autor: Kayque Amado
// Data: 09/03/2024
//========================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class Pets {
  String? name;
  String? species; // changed from 'tipo'
  String? breed; // changed from 'raca'
  DateTime? birthDate; // changed from string to DateTime
  String? color;
  String? gender; // changed from 'sexo'
  bool? isNeutered; // changed from string to boolean
  String? chipNumber;
  String? id;
  String? ownerId;
  String? ownerName;
  List<String>? vaccines;
  List<String>? veterinarians;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? medicalNotes;
  List<String>? allergies;
  String? chronicConditions;

  Pets({
    this.name,
    this.species,
    this.breed,
    this.birthDate,
    this.color,
    this.gender,
    this.isNeutered,
    this.chipNumber,
    this.id,
    this.ownerId,
    this.ownerName,
    this.vaccines,
    this.veterinarians,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
    this.medicalNotes,
    this.allergies,
    this.chronicConditions,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'birthDate': birthDate,
      'color': color,
      'gender': gender,
      'isNeutered': isNeutered,
      'chipNumber': chipNumber,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'vaccines': vaccines ?? [],
      'veterinarians': veterinarians ?? [],
      'status': status ?? 'active',
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': updatedAt ?? DateTime.now(),
      'medicalNotes': medicalNotes,
      'allergies': allergies ?? [],
      'chronicConditions': chronicConditions,
    };
  }

  factory Pets.fromMap(Map<String, dynamic> map) {
    DateTime? convertToDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return Pets(
      id: map['id'], // Make sure this is first to properly capture document ID
      name: map['name'],
      species: map['species'],
      breed: map['breed'],
      birthDate: convertToDateTime(map['birthDate']),
      color: map['color'],
      gender: map['gender'],
      isNeutered: map['isNeutered'],
      chipNumber: map['chipNumber'],
      ownerId: map['ownerId'],
      ownerName: map['ownerName'],
      vaccines: List<String>.from(map['vaccines'] ?? []),
      veterinarians: List<String>.from(map['veterinarians'] ?? []),
      status: map['status'],
      createdAt: convertToDateTime(map['createdAt']),
      updatedAt: convertToDateTime(map['updatedAt']),
      medicalNotes: map['medicalNotes'],
      allergies: List<String>.from(map['allergies'] ?? []),
      chronicConditions: map['chronicConditions'],
    );
  }
}
