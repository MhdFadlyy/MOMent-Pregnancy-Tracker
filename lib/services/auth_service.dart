import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around [FirebaseAuth] so screens depend on one call site
/// instead of reaching into `FirebaseAuth.instance` directly.
class AuthService {
  const AuthService();

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<void> signIn({required String email, required String password}) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({required String email, required String password}) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => FirebaseAuth.instance.signOut();

  /// Deletes the currently signed-in auth user. Throws [FirebaseAuthException]
  /// with code `requires-recent-login` if the session is too old.
  Future<void> deleteCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) await user.delete();
  }
}
