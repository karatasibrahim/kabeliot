import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase konfigürasyon dosyası.
///
/// ⚠️ KURULUM:
/// 1. Firebase Console → kabel-core → Android app ekle
///    package: com.kabelteknoloji.kabeliot_app
///    → google-services.json indir → android/app/ klasörüne koy
/// 2. Firebase Console → iOS app ekle
///    → GoogleService-Info.plist indir → ios/Runner/ klasörüne koy
/// 3. Bu dosyadaki androidAppId ve iosAppId değerlerini
///    indirilen dosyalardan alarak güncelle.
///
/// Veya: `flutterfire configure --project=kabel-core` komutunu çalıştır.
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

  // ── Web ──────────────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyByBxlMYm4xkqnwda3usHKm0YN2qHl9RAg',
    authDomain: 'kabel-core.firebaseapp.com',
    projectId: 'kabel-core',
    storageBucket: 'kabel-core.firebasestorage.app',
    messagingSenderId: '286454387473',
    appId: '1:286454387473:web:6d1ab81b1ce07dda8272b0',
  );

  // ── Android ──────────────────────────────────────────────────────────────
  // ⚠️ androidAppId değerini google-services.json → client[0].client_info.mobilesdk_app_id'den al
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyByBxlMYm4xkqnwda3usHKm0YN2qHl9RAg',
    authDomain: 'kabel-core.firebaseapp.com',
    projectId: 'kabel-core',
    storageBucket: 'kabel-core.firebasestorage.app',
    messagingSenderId: '286454387473',
    appId: 'ANDROID_APP_ID_BURAYA', // ← google-services.json'dan al
  );

  // ── iOS ──────────────────────────────────────────────────────────────────
  // ⚠️ iosAppId ve iosBundleId değerlerini GoogleService-Info.plist'ten al
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyByBxlMYm4xkqnwda3usHKm0YN2qHl9RAg',
    authDomain: 'kabel-core.firebaseapp.com',
    projectId: 'kabel-core',
    storageBucket: 'kabel-core.firebasestorage.app',
    messagingSenderId: '286454387473',
    appId: 'IOS_APP_ID_BURAYA', // ← GoogleService-Info.plist → GOOGLE_APP_ID
    iosBundleId: 'IOS_BUNDLE_ID_BURAYA', // ← BUNDLE_ID
  );
}
