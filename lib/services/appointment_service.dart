import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore access for a user's prenatal appointments.
class AppointmentService {
  const AppointmentService(this.uid);

  final String uid;

  CollectionReference<Map<String, dynamic>> get _appointments =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('appointments');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAppointments() {
    return _appointments.orderBy('date', descending: false).snapshots();
  }

  Future<void> addAppointment(Map<String, dynamic> data) {
    return _appointments.add(data);
  }
}
