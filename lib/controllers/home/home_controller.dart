import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/utils/firestore_date.dart';
import 'package:async/async.dart';

class HomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream for activities (appointments, vaccines, deworming)
  Stream<List<Map<String, dynamic>>> getUpcomingActivities() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    // appointments: a rule é vet-only → o tutor não pode ler. Não consultamos
    // (evita PERMISSION_DENIED).
    final vaccinesStream = _firestore
        .collection('vaccines')
        .where('ownerId', isEqualTo: uid)
        .snapshots();

    // ownerId-only + filtro/ordenação no cliente: evita o índice composto
    // (ownerId + nextDueDate), que não existe para o mobile (FAILED_PRECONDITION).
    final dewormingStream = _firestore
        .collection('deworming')
        .where('ownerId', isEqualTo: uid)
        .snapshots();

    return StreamZip([vaccinesStream, dewormingStream]).map((snapshots) {
      final QuerySnapshot vacsSnap = snapshots[0] as QuerySnapshot;
      final QuerySnapshot dewsSnap = snapshots[1] as QuerySnapshot;

      final now = DateTime.now();
      final List<Map<String, dynamic>> activities = [];

      // Vaccines (filtra nextDueDate > now se existir)
      for (final doc in vacsSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final DateTime? dt = readFirestoreDate(data['nextDueDate']) ??
            readFirestoreDate(data['date']);
        if (dt == null || dt.isBefore(now)) continue;
        activities.add({
          'type': 'vaccine',
          'title': data['name'] ?? data['vaccineName'] ?? 'Vacina',
          'time': dt,
          'color': const Color(0xFF7EC8B3),
          'icon': Icons.vaccines,
          'raw': data,
        });
      }

      // Deworming
      for (final doc in dewsSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final DateTime? dt = readFirestoreDate(data['nextDueDate']);
        if (dt == null || dt.isBefore(now)) continue;
        activities.add({
          'type': 'deworming',
          'title': data['name'] ?? 'Vermífugo',
          'time': dt,
          'color': const Color(0xFFFFB300),
          'icon': Icons.event_repeat,
          'raw': data,
        });
      }

      // Ordena por data e limita a 3 itens
      activities.sort(
          (a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));
      return activities.take(3).toList();
    });
  }

  // Stream for user's pets (limit 3)
  Stream<List<Pets>> getUserPets({int limit = 3}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: uid)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Pets.fromJson(data);
            }).toList());
  }
}
