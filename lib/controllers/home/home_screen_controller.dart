import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/models/vaccine_model.dart';
import 'package:pet_app/repositories/pet_repository.dart';
import 'package:pet_app/repositories/vaccine_repository.dart';
import 'package:pet_app/repositories/user_repository.dart';

class HomeScreenController {
  final User user;
  final Future<void> Function() onLogout;
  final void Function(String) onUserData;
  final PetRepository _petRepository = PetRepository();
  final VaccineRepository _vaccineRepository = VaccineRepository();
  final UserRepository _userRepository = UserRepository();

  HomeScreenController({
    required this.user,
    required this.onLogout,
    required this.onUserData,
  });

  Future<void> getUserData() async {
    final userData = await _userRepository.getUserById(user.uid);
    if (userData != null && userData.name != null) {
      onUserData(userData.name!);
    }
  }

  Future<List<Pets>> fetchPets() async {
    return await _petRepository.fetchPetsByOwner(user.uid);
  }

  Future<List<Map<String, dynamic>>> fetchVaccines() async {
    return await _vaccineRepository.getVaccinesByOwner(user.uid);
  }

  Future<List<Vacinas>> fetchVaccinesList() async {
    final vaccinesData = await fetchVaccines();
    return vaccinesData.map((e) => Vacinas.fromMap(e)).toList();
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await onLogout();
  }
}
