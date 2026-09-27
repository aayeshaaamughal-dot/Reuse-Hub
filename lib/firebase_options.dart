import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTqmXy95-FD0GOtgm_uCHuBEmgOftt3WE',
    appId: '1:584134537995:android:6500f086be17b4adf1680e',
    messagingSenderId: '584134537995',
    projectId: 'untitled5-6636d',
    storageBucket: 'untitled5-6636d.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCTqmXy95-FD0GOtgm_uCHuBEmgOftt3WE',
    appId: '1:584134537995:web:6500f086be17b4adf1680e',
    messagingSenderId: '584134537995',
    projectId: 'untitled5-6636d',
    storageBucket: 'untitled5-6636d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCTqmXy95-FD0GOtgm_uCHuBEmgOftt3WE',
    appId: '1:584134537995:ios:6500f086be17b4adf1680e',
    messagingSenderId: '584134537995',
    projectId: 'untitled5-6636d',
    storageBucket: 'untitled5-6636d.firebasestorage.app',
    iosBundleId: 'com.example.untitled5',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCTqmXy95-FD0GOtgm_uCHuBEmgOftt3WE',
    appId: '1:584134537995:ios:6500f086be17b4adf1680e',
    messagingSenderId: '584134537995',
    projectId: 'untitled5-6636d',
    storageBucket: 'untitled5-6636d.firebasestorage.app',
    iosBundleId: 'com.example.untitled5',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCTqmXy95-FD0GOtgm_uCHuBEmgOftt3WE',
    appId: '1:584134537995:web:6500f086be17b4adf1680e',
    messagingSenderId: '584134537995',
    projectId: 'untitled5-6636d',
    storageBucket: 'untitled5-6636d.firebasestorage.app',
  );
}
