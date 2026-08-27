import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/models/vaccine_model.dart';
import 'package:pet_app/repositories/pet_repository.dart';
import 'package:pet_app/repositories/vaccine_repository.dart';

class HomeScreenController {
  final User user;
  final void Function(String) onUserData;
  final PetRepository _petRepository = PetRepository();
  final VaccineRepository _vaccineRepository = VaccineRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomeScreenController({
    required this.user,
    required this.onUserData,
  });

/*  Future<void> getUserData() async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData['nome'] != null) {
          onUserData(userData['nome']);
        } else {
          // Se não houver dados no Firestore, usar displayName do Auth
          onUserData(user.displayName ?? 'Usuário');
        }
      } else {
        // Se o documento não existir, criar um novo com dados básicos
        await _firestore.collection('users').doc(user.uid).set({
          'nome': user.displayName ?? 'Usuário',
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        onUserData(user.displayName ?? 'Usuário');
      }
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
      onUserData('Usuário');
    }
  }
*/
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

  /// Encerra a sessão. Quem decide a tela seguinte é o RoteadorTelas, que
  /// escuta o estado de autenticação — a UI não navega na mão.
  ///
  /// Antes isto chamava um callback `onLogout` que, no main_screen, chamava
  /// este mesmo método de volta: recursão infinita, que só não estourava
  /// porque nenhuma tela chegava a invocá-lo.
  Future<void> logout() => FirebaseAuth.instance.signOut();

  Future<Map<String, dynamic>?> fetchUserDocument() async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar documento do usuário: $e');
      return null;
    }
  }
}
