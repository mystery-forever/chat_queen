// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
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
    apiKey: 'AIzaSyCKW3mYq4v2F72oitRbf_hjWnQc2SIoouU',
    appId: '1:327055931373:web:14c0e9b7406b3e647699e4',
    messagingSenderId: '327055931373',
    projectId: 'chatqueen-85c89',
    authDomain: 'chatqueen-85c89.firebaseapp.com',
    storageBucket: 'chatqueen-85c89.firebasestorage.app',
    measurementId: 'G-7SZ5FZMVJ4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3o75aEMrCcVJbwlmwL4LRZrSG_PzbJ0w',
    appId: '1:327055931373:android:529165916479bfaa7699e4',
    messagingSenderId: '327055931373',
    projectId: 'chatqueen-85c89',
    storageBucket: 'chatqueen-85c89.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDC4NdACiAj4Yij59kJgRFXSZ64hiUG5cE',
    appId: '1:327055931373:ios:dab17877ee59ca7b7699e4',
    messagingSenderId: '327055931373',
    projectId: 'chatqueen-85c89',
    storageBucket: 'chatqueen-85c89.firebasestorage.app',
    iosBundleId: 'com.example.chatQueen',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDC4NdACiAj4Yij59kJgRFXSZ64hiUG5cE',
    appId: '1:327055931373:ios:dab17877ee59ca7b7699e4',
    messagingSenderId: '327055931373',
    projectId: 'chatqueen-85c89',
    storageBucket: 'chatqueen-85c89.firebasestorage.app',
    iosBundleId: 'com.example.chatQueen',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCKW3mYq4v2F72oitRbf_hjWnQc2SIoouU',
    appId: '1:327055931373:web:428f926ecacd11e77699e4',
    messagingSenderId: '327055931373',
    projectId: 'chatqueen-85c89',
    authDomain: 'chatqueen-85c89.firebaseapp.com',
    storageBucket: 'chatqueen-85c89.firebasestorage.app',
    measurementId: 'G-PY8MTDMRBT',
  );
}
