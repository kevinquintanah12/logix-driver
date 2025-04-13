import 'package:firebase_core/firebase_core.dart';  // Importamos toda la librería sin 'show'
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';  // Importación normal

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDV1PjwrDKq0wPGOcUnWQuo7cJLpkhqa4s',
    appId: '1:462154546729:web:4c306e3e1689ea33fa2638',
    messagingSenderId: '462154546729',
    projectId: 'app-driver-d1bfb',
    authDomain: 'app-driver-d1bfb.firebaseapp.com',
    storageBucket: 'app-driver-d1bfb.firebasestorage.app',
    measurementId: 'G-R3TR7MDDHL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB48tb0KGN8rHRJx8UBoGWu_QP51hspR0I',
    appId: '1:462154546729:android:8d8dd7941a77e6ebfa2638',
    messagingSenderId: '462154546729',
    projectId: 'app-driver-d1bfb',
    storageBucket: 'app-driver-d1bfb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtxrJHOeoWVyJ9qMMqDybACUe2_zNlrgM',
    appId: '1:462154546729:ios:84b96839d8e9d45bfa2638',
    messagingSenderId: '462154546729',
    projectId: 'app-driver-d1bfb',
    storageBucket: 'app-driver-d1bfb.firebasestorage.app',
    iosBundleId: 'com.example.shop',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBtxrJHOeoWVyJ9qMMqDybACUe2_zNlrgM',
    appId: '1:462154546729:ios:84b96839d8e9d45bfa2638',
    messagingSenderId: '462154546729',
    projectId: 'app-driver-d1bfb',
    storageBucket: 'app-driver-d1bfb.firebasestorage.app',
    iosBundleId: 'com.example.shop',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDV1PjwrDKq0wPGOcUnWQuo7cJLpkhqa4s',
    appId: '1:462154546729:web:84a6722b0033c9a2fa2638',
    messagingSenderId: '462154546729',
    projectId: 'app-driver-d1bfb',
    authDomain: 'app-driver-d1bfb.firebaseapp.com',
    storageBucket: 'app-driver-d1bfb.firebasestorage.app',
    measurementId: 'G-6VW4T78RXN',
  );

}