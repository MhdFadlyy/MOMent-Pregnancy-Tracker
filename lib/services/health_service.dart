import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore access for a user's health logs (weight / diet / exercise).
/// Keeps the collection path in one place instead of repeated inline
/// `FirebaseFirestore.instance.collection('users')...` chains across screens.
class HealthService {
  const HealthService(this.uid);

  final String uid;

  CollectionReference<Map<String, dynamic>> get _logs => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('health_logs');

  Future<void> addLog(Map<String, dynamic> data) {
    return _logs.add({...data, 'timestamp': FieldValue.serverTimestamp()});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamLogs() {
    return _logs.orderBy('timestamp', descending: true).snapshots();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      fetchLogsForReport() async {
    final snapshot =
        await _logs.orderBy('timestamp', descending: true).get();
    return snapshot.docs;
  }
}
