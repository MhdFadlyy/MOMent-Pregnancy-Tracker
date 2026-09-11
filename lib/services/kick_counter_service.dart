import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore access for a user's kick-counter sessions.
class KickCounterService {
  const KickCounterService(this.uid);

  final String uid;

  CollectionReference<Map<String, dynamic>> get _kicks => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('kicks');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamSessions() {
    return _kicks.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> saveSession({required int count, required int durationMinutes}) {
    return _kicks.add({
      'count': count,
      'duration_minutes': durationMinutes,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSession(String docId) {
    return _kicks.doc(docId).delete();
  }
}
