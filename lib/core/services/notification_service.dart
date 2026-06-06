import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Handles Firebase Cloud Messaging for CourtCall.
///
/// Responsibilities:
///   - Request notification permissions on first launch
///   - Retrieve and refresh FCM tokens, persisting them to Firestore
///     so the backend can target individual devices
///   - Show heads-up notifications when app is in foreground
///   - Expose tap callbacks so screens can navigate on notification tap
///
/// Usage — call [NotificationService.init] once in main.dart after
/// Firebase.initializeApp, passing the signed-in user's uid.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Callback invoked when the user taps a notification while app is open.
  void Function(RemoteMessage message)? onMessageTap;

  /// Tracks the currently signed-in uid so the token-refresh listener
  /// always persists to the right user even if [attachToUser] is called
  /// after [init].
  String? _currentUid;

  // ── Android notification channel ─────────────────────────────────────
  static const _channelId = 'courtcall_main';
  static const _channelName = 'CourtCall Notifications';
  static const _channelDesc =
      'Session invitations, RSVP reminders and cancellations';

  Future<void> init({String? uid}) async {
    // 1. Request permission (iOS + Android 13+)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Notification permission denied.');
      return;
    }

    // 2. Set up local notifications plugin (for foreground display)
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Payload is the FCM data map serialized as JSON string.
        // Navigation wiring goes here once Mohammed's router is ready.
      },
    );

    // 3. Create Android notification channel
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );

    // 4. Token management — FIX: persist to Firestore so backend can target
    // this device. Requires uid from the signed-in user (passed via init).
    final token = await _fcm.getToken();
    debugPrint('[FCM] Token: $token');
    if (uid != null) _currentUid = uid;
    if (token != null && _currentUid != null) {
      await _persistToken(_currentUid!, token);
    }

    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed: $newToken');
      if (_currentUid != null) {
        _persistToken(_currentUid!, newToken);
      }
    });

    // 5. Foreground messages → show local notification
    FirebaseMessaging.onMessage.listen(_handleForeground);

    // 6. Background/terminated tap → app opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onMessageTap?.call(message);
    });

    // 7. Check if app was launched from a terminated notification
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      onMessageTap?.call(initial);
    }
  }

  /// Call this after sign-in to attach the FCM token to the authenticated user.
  Future<void> attachToUser(String uid) async {
    _currentUid = uid;
    final token = await _fcm.getToken();
    if (token != null) {
      await _persistToken(uid, token);
    }
    // The onTokenRefresh listener registered in init() now reads _currentUid,
    // so no need to re-register it here — just updating _currentUid is enough.
  }

  Future<void> _persistToken(String uid, String token) async {
    try {
      await _db.collection('users').doc(uid).update({'fcmToken': token});
    } catch (e) {
      // Non-fatal — token will be written on next refresh or sign-in.
      debugPrint('[FCM] Failed to persist token: $e');
    }
  }

  void _handleForeground(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Subscribe to a topic (e.g. session-specific broadcasts).
  Future<void> subscribeToSession(String sessionId) =>
      _fcm.subscribeToTopic('session_$sessionId');

  /// Unsubscribe from a session topic on decline/leave.
  Future<void> unsubscribeFromSession(String sessionId) =>
      _fcm.unsubscribeFromTopic('session_$sessionId');
}

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized by the time this runs.
  debugPrint('[FCM Background] ${message.notification?.title}');
}
