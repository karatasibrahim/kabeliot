import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions — ${defaultTargetPlatform.name} desteklenmiyor.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyByBxlMYm4xkqnwda3usHKm0YN2qHl9RAg',
    authDomain: 'kabel-core.firebaseapp.com',
    projectId: 'kabel-core',
    storageBucket: 'kabel-core.firebasestorage.app',
    messagingSenderId: '286454387473',
    appId: '1:286454387473:web:6d1ab81b1ce07dda8272b0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDdyHpQa4Lm1-3ToRLEOK_E9Fq8v0wsVqs',
    authDomain: 'kabel-core.firebaseapp.com',
    projectId: 'kabel-core',
    storageBucket: 'kabel-core.firebasestorage.app',
    messagingSenderId: '286454387473',
    appId: '1:286454387473:android:29a3362ed692e2ef8272b0',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCgFketwJ3ZJeZcwkPnUjMslJ6cDrsRWxs',
    authDomain: 'kabel-core.firebaseapp.com',
    projectId: 'kabel-core',
    storageBucket: 'kabel-core.firebasestorage.app',
    messagingSenderId: '286454387473',
    appId: '1:286454387473:ios:a272d839fac0c31b8272b0',
    iosBundleId: 'com.kabel.core',
  );
}
