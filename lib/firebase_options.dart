import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class ParkirFirebaseOptions {
  const ParkirFirebaseOptions._();

  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const _iosBundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');
  static const _androidClientId = String.fromEnvironment(
    'FIREBASE_ANDROID_CLIENT_ID',
  );
  static const _iosClientId = String.fromEnvironment('FIREBASE_IOS_CLIENT_ID');

  static const webVapidKey = String.fromEnvironment('FIREBASE_WEB_VAPID_KEY');

  static FirebaseOptions? get currentPlatform {
    if (_apiKey.isEmpty ||
        _appId.isEmpty ||
        _messagingSenderId.isEmpty ||
        _projectId.isEmpty) {
      return null;
    }

    return FirebaseOptions(
      apiKey: _apiKey,
      appId: _appId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      storageBucket: _storageBucket.isEmpty ? null : _storageBucket,
      androidClientId:
          defaultTargetPlatform == TargetPlatform.android &&
              _androidClientId.isNotEmpty
          ? _androidClientId
          : null,
      iosBundleId:
          defaultTargetPlatform == TargetPlatform.iOS && _iosBundleId.isNotEmpty
          ? _iosBundleId
          : null,
      iosClientId:
          defaultTargetPlatform == TargetPlatform.iOS && _iosClientId.isNotEmpty
          ? _iosClientId
          : null,
    );
  }
}
