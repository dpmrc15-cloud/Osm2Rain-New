import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:osm2_app/main.dart';        // ✅ ใช้ navigatorKey
import 'package:osm2_app/utils/global.dart'; // ✅ ใช้ ROUTE_RAIN_SCREEN
// import 'package:osm2_app/pages/rain_screen.dart'; // TODO: unused import
class AlertDialogService {
  /// ✅ แสดง Dialog แจ้งเตือนน้ำฝนจาก FCM
  static Future<void> showRainAlertDialog({
    required String title,
    required String body,
    required String phone,
    required String lat,
    required String lng,
  }) async {
    final context = navigatorKey.currentContext;

    if (context == null) {
      print("❌ ERROR: navigatorKey.currentContext = null");
      return;
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              body,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          actions: [
            // ✅ โทรหาผู้รายงาน
            TextButton(
              child: const Text("โทร", style: TextStyle(color: Colors.green)),
              onPressed: () async {
                final Uri telUri = Uri(scheme: "tel", path: phone);
                if (await canLaunchUrl(telUri)) {
                  await launchUrl(telUri);
                }
              },
            ),

            // ✅ เปิด Google Maps
            TextButton(
              child: const Text("แผนที่", style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                final Uri mapUri = Uri.parse(
                    "https://www.google.com/maps/search/?api=1&query=$lat,$lng");
                if (await canLaunchUrl(mapUri)) {
                  await launchUrl(mapUri);
                }
              },
            ),

            // ✅ เปิดเว็บไซต์รายละเอียด
            TextButton(
              child:
                  const Text("รายละเอียด", style: TextStyle(color: Colors.orange)),
              onPressed: () async {
                final Uri webUri = Uri.parse(
                    "http://vlg-water-r.disaster.go.th/osm2rain/#/rain-map");
                if (await canLaunchUrl(webUri)) {
                  await launchUrl(webUri);
                }
              },
            ),

            // ✅ ปิด dialog และกลับไปหน้า RainScreen พร้อม refresh
            TextButton(
              child: const Text("ตกลง", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(ctx).pop();

                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  Global.ROUTE_RAIN_SCREEN,
                  (route) => false,
                  arguments: {"refresh": true},
                );
              },
            ),
          ],
        );
      },
    );
  }
}