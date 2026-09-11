// Auto-generated-style Firebase config (mirrors what `flutterfire configure`
// produces): one FirebaseOptions per platform, picked by currentPlatform.
// Android also keeps reading android/app/google-services.json natively via
// the Gradle plugin — the `android` options here just keep Dart-side
// initialization consistent so it never throws.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions is only configured for Android and Web in this project.',
        );
    }
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyC-zS3IyyU99ZIdV-oB96WyohR6YvFrfOU',
    appId: '1:54916060060:web:396f1fce49c171f7cdae59',
    messagingSenderId: '54916060060',
    projectId: 'moment-5aa79',
    authDomain: 'moment-5aa79.firebaseapp.com',
    storageBucket: 'moment-5aa79.firebasestorage.app',
    measurementId: 'G-KP0VSJKDD5',
  );

  // Mirrors android/app/google-services.json — kept in sync so
  // Firebase.initializeApp(options: ...) never throws on Android, even
  // though the native google-services Gradle plugin also reads that file.
  static const android = FirebaseOptions(
    apiKey: 'AIzaSyAPQ9zCcs7monehrlYMLGp8wxb-61eSFww',
    appId: '1:54916060060:android:cf8b6ed3fb62263acdae59',
    messagingSenderId: '54916060060',
    projectId: 'moment-5aa79',
    storageBucket: 'moment-5aa79.firebasestorage.app',
  );
}
