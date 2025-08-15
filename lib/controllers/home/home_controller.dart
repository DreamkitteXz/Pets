import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:async/async.dart';

class HomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream for activities (appointments, vaccines, deworming)
  Stream<List<Map<String, dynamic>>> getUpcomingActivities() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    final appointmentsStream = _firestore
        .collection('appointments')
        .where('tutorId', isEqualTo: uid)
        .where('date', isGreaterThan: Timestamp.now())
        .orderBy('date')
        .limit(3)
        .snapshots();

    final vaccinesStream = _firestore
        .collection('vaccines')
        .where('ownerId', isEqualTo: uid)
        .snapshots();

    final dewormingStream = _firestore
        .collection('deworming')
        .where('ownerId', isEqualTo: uid)
        .where('nextDueDate', isGreaterThan: Timestamp.now())
        .orderBy('nextDueDate')
        .limit(3)
        .snapshots();

    return StreamZip([appointmentsStream, vaccinesStream, dewormingStream])
        .map((snapshots) {
      // ...merge and process as in your widget, but here in the controller...
      // Return a List<Map<String, dynamic>> of activities
      // (copy your merging/filtering logic here)
      return [];
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
