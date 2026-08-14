import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  const LocalNotificationService._();

  static const String channelId = 'gym_updates';
  static const String channelName = 'Gym updates';
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        channelId,
        channelName,
        description: 'Workout reminders and gym announcements',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static Future<void>? _initialization;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      return;
    }
    if (_initialization != null) {
      return _initialization;
    }
    final initialization = _initializePlugin();
    _initialization = initialization;
    try {
      await initialization;
      _initialized = true;
    } finally {
      _initialization = null;
    }
  }

  static Future<void> _initializePlugin() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_steps'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: settings);
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  static Future<void> showRemoteMessage(
    RemoteMessage message, {
    bool dataOnly = false,
  }) async {
    if (kIsWeb || (dataOnly && message.notification != null)) {
      return;
    }
    if (!dataOnly && defaultTargetPlatform != TargetPlatform.android) {
      // Apple foreground presentation is handled by Firebase Messaging.
      return;
    }
    final title =
        message.notification?.title?.trim() ??
        message.data['title']?.toString().trim();
    final body =
        message.notification?.body?.trim() ??
        message.data['body']?.toString().trim() ??
        message.data['message']?.toString().trim();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    await initialize();
    await _plugin.show(
      id: _notificationId(message),
      title: title?.isNotEmpty == true ? title : 'Gym update',
      body: body?.isNotEmpty == true ? body : 'You have a new notification.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'Workout reminders and gym announcements',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'ic_stat_steps',
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  static int _notificationId(RemoteMessage message) {
    final stableValue =
        message.messageId ??
        message.sentTime?.millisecondsSinceEpoch.toString() ??
        DateTime.now().microsecondsSinceEpoch.toString();
    return stableValue.hashCode & 0x7fffffff;
  }
}
