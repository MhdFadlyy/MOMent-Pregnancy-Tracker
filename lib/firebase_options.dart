// Auto-generated-style Firebase config for the Web target (mirrors what
// `flutterfire configure` produces). Android keeps using
// android/app/google-services.json natively via the Gradle plugin; this file
// only covers `flutter run -d chrome` / `flutter build web`.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'Android uses android/app/google-services.json natively; '
          'this options object only covers Web.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions is only configured for Web in this project.',
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
}
