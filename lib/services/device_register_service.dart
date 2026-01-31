import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:osm2_app/utils/global.dart';
import 'package:osm2_app/utils/shared_prefs.dart';

class DeviceRegisterService {
  static final SharedPrefs _sharedPrefs = SharedPrefs.instance;

  static Future<String> _getDeviceId() async {
    final info = DeviceInfoPlugin();
    final android = await info.androidInfo;
    return android.id;
  }

  static Future<String?> _getFcmToken() async {
    await FirebaseMessaging.instance.requestPermission();
    final token = await FirebaseMessaging.instance.getToken();
    print("✅ FCM Token: $token");
    return token;
  }

  /// เรียกใช้หลังจาก user login สำเร็จและข้อมูลจังหวัด/อำเภอ/ตำบลถูกบันทึกแล้ว
  static Future<void> registerDeviceIfReady() async {
    final userPhone = await _sharedPrefs.getValue(Global.KEY_USER_TEL) ?? '';

    final provinceCode =
        await _sharedPrefs.getValue(Global.KEY_PROVINCE_CODE) ?? '';
    final districtCode =
        await _sharedPrefs.getValue(Global.KEY_DISTRICT_CODE) ?? '';
    final subdistrictCode =
        await _sharedPrefs.getValue(Global.KEY_SUBDISTRICT_CODE) ?? '';

    if (userPhone.isEmpty ||
        provinceCode.isEmpty ||
        districtCode.isEmpty ||
        subdistrictCode.isEmpty) {
      print("⚠️ Device register skipped: user/location data not ready");
      return;
    }

    final fcmToken = await _getFcmToken();
    if (fcmToken == null) {
      print("❌ Cannot register device: FCM token is null");
      return;
    }

    final deviceId = await _getDeviceId();
    final url = Uri.parse("${Global.ROOT_URL}/alert/fcm/register-token");

    final body = {
      "device_id": deviceId,
      "user_phone": userPhone,
      "fcm_token": fcmToken,
      "province_code": provinceCode,
      "district_code": districtCode,
      "subdistrict_code": subdistrictCode,
    };

    try {
      final res = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "User-Agent": "OSM2App/1.0",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 || res.statusCode == 201) {
        print("✅ Device register successful: ${res.statusCode}");
      } else if (res.statusCode == 400) {
        print("⚠️ Device register failed: Invalid request (400)");
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        print("⚠️ Device register failed: Unauthorized (${res.statusCode})");
      } else if (res.statusCode >= 500) {
        print("⚠️ Device register failed: Server error (${res.statusCode})");
      } else {
        print("⚠️ Device register response: ${res.statusCode}");
      }
    } catch (e) {
      print("❌ Device register error: $e");
    }
  }
}
