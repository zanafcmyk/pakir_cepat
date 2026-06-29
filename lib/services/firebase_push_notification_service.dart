import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../firebase_options.dart';
import 'supabase_push_notification_service.dart';

enum PushRegistrationStatus {
  registered,
  signedOut,
  firebaseNotConfigured,
  permissionDenied,
  tokenUnavailable,
  failed,
}

@pragma('vm:entry-point')
Future<void> parkirFirebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await _ensureFirebaseInitialized();
}

class FirebasePushNotificationService {
  FirebasePushNotificationService({
    SupabaseClient? client,
    SupabasePushNotificationService? tokenService,
  }) : _client = client ?? Supabase.instance.client,
       _tokenService = tokenService ?? SupabasePushNotificationService();

  final SupabaseClient _client;
  final SupabasePushNotificationService _tokenService;
  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _backgroundHandlerRegistered = false;

  Future<PushRegistrationStatus> registerCurrentUserDevice() async {
    if (_client.auth.currentUser == null) {
      return PushRegistrationStatus.signedOut;
    }

    final firebaseReady = await _ensureFirebase();
    if (!firebaseReady) {
      return PushRegistrationStatus.firebaseNotConfigured;
    }

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return PushRegistrationStatus.permissionDenied;
    }

    final token = await messaging.getToken(
      vapidKey: kIsWeb && ParkirFirebaseOptions.webVapidKey.isNotEmpty
          ? ParkirFirebaseOptions.webVapidKey
          : null,
    );
    if (token == null || token.trim().isEmpty) {
      return PushRegistrationStatus.tokenUnavailable;
    }

    await _tokenService.registerCurrentDeviceToken(
      token: token,
      platform: _platformLabel(),
      deviceName: _deviceNameLabel(),
    );
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = messaging.onTokenRefresh.listen((newToken) {
      unawaited(
        _tokenService.registerCurrentDeviceToken(
          token: newToken,
          platform: _platformLabel(),
          deviceName: _deviceNameLabel(),
        ),
      );
    });

    return PushRegistrationStatus.registered;
  }

  Future<void> unregisterCurrentUserDevice() async {
    final firebaseReady = await _ensureFirebase();
    if (!firebaseReady) {
      return;
    }

    final token = await FirebaseMessaging.instance.getToken(
      vapidKey: kIsWeb && ParkirFirebaseOptions.webVapidKey.isNotEmpty
          ? ParkirFirebaseOptions.webVapidKey
          : null,
    );
    if (token != null && token.trim().isNotEmpty) {
      await _tokenService.unregisterDeviceToken(token);
    }
    await FirebaseMessaging.instance.deleteToken();
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  Future<bool> _ensureFirebase() async {
    try {
      await _ensureFirebaseInitialized();
      if (!_backgroundHandlerRegistered) {
        FirebaseMessaging.onBackgroundMessage(
          parkirFirebaseMessagingBackgroundHandler,
        );
        _backgroundHandlerRegistered = true;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  String _platformLabel() {
    if (kIsWeb) {
      return 'web';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }

  String _deviceNameLabel() {
    if (kIsWeb) {
      return 'Web browser';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android device',
      TargetPlatform.iOS => 'iOS device',
      TargetPlatform.macOS => 'macOS device',
      TargetPlatform.windows => 'Windows device',
      TargetPlatform.linux => 'Linux device',
      TargetPlatform.fuchsia => 'Fuchsia device',
    };
  }
}

Future<void> _ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }

  final options = ParkirFirebaseOptions.currentPlatform;
  if (options != null) {
    await Firebase.initializeApp(options: options);
    return;
  }

  await Firebase.initializeApp();
}
