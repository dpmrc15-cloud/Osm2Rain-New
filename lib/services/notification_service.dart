import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart'; // TODO: unused import
import 'package:osm2_app/pages/alert_detail_page.dart';

final FlutterLocalNotificationsPlugin _notificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static const String _channelId = 'rain_alert_channel';
  static const String _channelName = 'Rain Alerts';

  static Map<String, dynamic>? lastPayload;
  static bool shouldOpenAlert = false;

  static Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    debugPrint("DEBUG: NotificationService.init() called");

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('ic_stat_notification');
    debugPrint(
        "DEBUG: AndroidInitializationSettings ใช้ icon = ic_stat_notification");

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Channel for rain alerts',
      importance: Importance.high,
    );

    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint(
              "DEBUG: onDidReceiveNotificationResponse triggered payload=${response.payload}");
          _handleNotificationTap(response, navigatorKey);
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      debugPrint("DEBUG: _notificationsPlugin.initialize() completed");
    } catch (e) {
      debugPrint("DEBUG: NotificationService.init error: $e");
    }
  }

  static Future<void> initBackground() async {
    debugPrint("DEBUG: NotificationService.initBackground() called");
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    try {
      await _notificationsPlugin.initialize(initSettings);
      debugPrint("DEBUG: NotificationService.initBackground() completed");
    } catch (e) {
      debugPrint("DEBUG: initBackground error: $e");
    }
  }

  static void _handleNotificationTap(
      NotificationResponse response, GlobalKey<NavigatorState> navigatorKey) {
    debugPrint("DEBUG: _handleNotificationTap payload=${response.payload}");
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      debugPrint('DEBUG: Notification clicked but payload is empty');
      return;
    }
    try {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(jsonDecode(payload));
      debugPrint("DEBUG: Parsed payload=$data");

      final alertId = data['alert_id']?.toString();
      if (alertId == null || alertId.isEmpty) {
        debugPrint("DEBUG: alert_id missing → skip navigation");
        return;
      }

      // ✅ เปิดหน้า AlertDetailPage เสมอเมื่อกด notification
      lastPayload = data;
      shouldOpenAlert = true;
      debugPrint("DEBUG: shouldOpenAlert set to true, lastPayload updated");

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AlertDetailPage(alertData: data),
        ),
      );
      debugPrint(
          "DEBUG: Navigated to AlertDetailPage from _handleNotificationTap");
    } catch (e) {
      debugPrint('DEBUG: Payload parse error: $e, raw=$payload');
    }
  }

  static Future<void> showLocalNotification(
      String? title, String? body, Map<String, dynamic> data) async {
    debugPrint(
        "DEBUG: showLocalNotification called title=$title body=$body dataKeys=${data.keys}");

    final alertId = data['alert_id']?.toString();
    final safeTitle = title ?? '';
    final safeBody = body ?? '';

    if (alertId == null || alertId.isEmpty) {
      debugPrint("DEBUG: alert_id is null/empty → skip showing notification");
      return;
    }
    if (safeTitle.isEmpty && safeBody.isEmpty) {
      debugPrint("DEBUG: title & body empty → skip showing notification");
      return;
    }

    // ✅ กันซ้ำเฉพาะตอนแสดง notification
    if (alertId == lastPayload?['alert_id']?.toString()) {
      debugPrint(
          "DEBUG: Duplicate alert_id=$alertId → skip showing notification");
      return;
    }

    final String payloadString = jsonEncode(data);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      icon: 'ic_stat_notification', // ✅ ระบุ icon สีที่คุณสร้างไว้
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(safeBody),
    );
    debugPrint("DEBUG: AndroidNotificationDetails icon=${androidDetails.icon}");

    final NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    final int notifId = int.tryParse(alertId) ?? 0;

    try {
      await _notificationsPlugin.show(
        notifId,
        safeTitle.isEmpty ? 'Rain Alert' : safeTitle,
        safeBody.isEmpty ? 'No message content' : safeBody,
        platformDetails,
        payload: payloadString,
      );
      debugPrint(
          "DEBUG: Local notification shown id=$notifId payload(len)=${payloadString.length}");
    } catch (e) {
      debugPrint("DEBUG: showLocalNotification error: $e");
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  debugPrint("DEBUG: notificationTapBackground payload=${response.payload}");
  final payload = response.payload;
  if (payload == null || payload.isEmpty) {
    debugPrint('DEBUG: Background notification clicked but payload is empty');
    return;
  }
  try {
    final data = Map<String, dynamic>.from(jsonDecode(payload));
    debugPrint("DEBUG: Parsed background payload=$data");

    final alertId = data['alert_id']?.toString();
    if (alertId == null || alertId.isEmpty) {
      debugPrint("DEBUG: alert_id missing → skip background navigation");
      return;
    }

    NotificationService.lastPayload = data;
    NotificationService.shouldOpenAlert = true;
    debugPrint(
        "DEBUG: shouldOpenAlert set to true in background, lastPayload updated");
  } catch (e) {
    debugPrint('DEBUG: Payload parse error (background): $e, raw=$payload');
  }
}
