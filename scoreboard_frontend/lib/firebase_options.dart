import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not supported yet.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCmyxw6Rti3Qjxa4yc82QxHh9w0M5vH7N0',
    appId: '1:598585526117:android:22c06ef8afb4d26667c38c',
    messagingSenderId: '598585526117',
    projectId: 'kanlearn-scoreboard',
    storageBucket: 'kanlearn-scoreboard.firebasestorage.app',
  );
}
