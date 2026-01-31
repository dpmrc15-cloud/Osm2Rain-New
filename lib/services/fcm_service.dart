import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  /// ขอ unified token (Android/iOS)
  static Future<String?> getUnifiedToken() async {
    // ✅ ขอ permission บน iOS/Android 13+
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint("DEBUG: Notification permission status=${settings.authorizationStatus}");

    // ✅ iOS APNS Token
    final apns = await FirebaseMessaging.instance.getAPNSToken();
    if (apns != null) {
      debugPrint("DEBUG: APNS Token: $apns");
    }

    // ✅ FCM Token (Android + iOS)
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      debugPrint("DEBUG: FCM Token: $token");
    } else {
      debugPrint("DEBUG: FCM Token is null");
    }

    return token;
  }

  /// ใช้สำหรับ refresh token เมื่อมีการเปลี่ยนแปลง
  static void listenTokenRefresh(void Function(String token) onToken) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint("DEBUG: FCM Token refreshed: $newToken");
      onToken(newToken);
    });
  }
}