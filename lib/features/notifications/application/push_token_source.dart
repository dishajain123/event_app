import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// The notification feature is provider-neutral. Native builds can supply the
/// runtime FCM/APNs token through the PUSH_DEVICE_TOKEN integration point;
/// keeping token acquisition outside the API layer avoids coupling the app to
/// one vendor or leaking platform credentials into business code.
class PushTokenSource {
  const PushTokenSource();

  static final pendingDeepLink = ValueNotifier<String?>(null);

  Future<String?> getToken() async {
    try {
      await Firebase.initializeApp();
      await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      // A missing native Firebase configuration must not block authentication.
      const configured = String.fromEnvironment('PUSH_DEVICE_TOKEN');
      return configured.isEmpty ? null : configured;
    }
  }

  Stream<String> get tokenChanges => FirebaseMessaging.instance.onTokenRefresh;

  Future<void> initializeMessageHandlers(
      {required void Function(Map<String, dynamic>) onOpened}) async {
    try {
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
      FirebaseMessaging.onMessage.listen((message) => onOpened(message.data));
      FirebaseMessaging.onMessageOpenedApp
          .listen((message) => onOpened(message.data));
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) onOpened(initial.data);
    } catch (_) {
      // Native message handlers are optional until Firebase is configured.
    }
  }

  String get platform {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => 'other',
    };
  }
}
