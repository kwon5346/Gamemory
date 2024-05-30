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
    apiKey: 'AIzaSyCaCgCPxxCICZSNxeyIy4Bdtzxq4SlQOuQ',
    appId: '1:587188165243:web:8c6a7f36b9affcecb320de',
    messagingSenderId: '587188165243',
    projectId: 'gameory-32af9',
    authDomain: 'gameory-32af9.firebaseapp.com',
    storageBucket: 'gameory-32af9.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvJl_ANj1EozaPn8dfNPPGnRA5wbKIjCI',
    appId: '1:587188165243:android:efbce31789a5c996b320de',
    messagingSenderId: '587188165243',
    projectId: 'gameory-32af9',
    storageBucket: 'gameory-32af9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBPmpvJRKzuoIer5hLGC41WzKNwfYSgBw4',
    appId: '1:587188165243:ios:01da698b395e868cb320de',
    messagingSenderId: '587188165243',
    projectId: 'gameory-32af9',
    storageBucket: 'gameory-32af9.appspot.com',
    iosBundleId: 'com.example.gamemory',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBPmpvJRKzuoIer5hLGC41WzKNwfYSgBw4',
    appId: '1:587188165243:ios:01da698b395e868cb320de',
    messagingSenderId: '587188165243',
    projectId: 'gameory-32af9',
    storageBucket: 'gameory-32af9.appspot.com',
    iosBundleId: 'com.example.gamemory',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCaCgCPxxCICZSNxeyIy4Bdtzxq4SlQOuQ',
    appId: '1:587188165243:web:769fbea8c3ca5e39b320de',
    messagingSenderId: '587188165243',
    projectId: 'gameory-32af9',
    authDomain: 'gameory-32af9.firebaseapp.com',
    storageBucket: 'gameory-32af9.appspot.com',
  );
}
