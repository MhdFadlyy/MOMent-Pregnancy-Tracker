import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore access for a user's contraction-timer history.
class ContractionService {
  const ContractionService(this.uid);

  final String uid;

  CollectionReference<Map<String, dynamic>> get _contractions =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('contractions');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamContractions() {
    return _contractions.orderBy('start_time', descending: true).snapshots();
  }

  Future<void> saveContraction({
    required DateTime startTime,
    required int durationSeconds,
  }) {
    return _contractions.add({
      'start_time': startTime,
      'duration_seconds': durationSeconds,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteContraction(String docId) {
    return _contractions.doc(docId).delete();
  }
}
