import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore access for the top-level `users/{uid}` profile document
/// (name, age, due date). Shared by the dashboard, the profile screen,
/// and account deletion.
class UserProfileService {
  const UserProfileService(this.uid);

  final String uid;

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamProfile() =>
      _doc.snapshots();

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfile() => _doc.get();

  Future<void> saveProfile(Map<String, dynamic> data) {
    return _doc.set(data, SetOptions(merge: true));
  }

  Future<void> deleteProfile() => _doc.delete();
}
