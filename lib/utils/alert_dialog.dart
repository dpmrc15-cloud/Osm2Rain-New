import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart'; // ใช้ navigatorKey จาก main.dart

void showRainAlertDialog({
  required String title,
  required String body,
  String? phone,
  String? lat,
  String? lng,
}) {
  final ctx = navigatorKey.currentState?.overlay?.context;
  if (ctx == null) return;

  showDialog(
    context: ctx,
    builder: (context) {
      return AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () {
                Navigator.of(context).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigatorKey.currentState?.pushNamedAndRemoveUntil(
                    'rain_screen',
                    (route) => false,
                    arguments: {"refresh": true},
                  );
                });
              },
              tooltip: 'ปิด',
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text("ตกลง", style: TextStyle(fontSize: 14)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      navigatorKey.currentState?.pushNamedAndRemoveUntil(
                        'rain_screen',
                        (route) => false,
                        arguments: {"refresh": true},
                      );
                    });
                  },
                ),
                if (phone != null && phone.isNotEmpty)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text("โทรหาผู้แจ้ง", style: TextStyle(fontSize: 14)),
                    onPressed: () => launchUrl(
                      Uri.parse("tel:$phone"),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                if (lat != null && lng != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text("นำทาง", style: TextStyle(fontSize: 14)),
                    onPressed: () {
                      final url = Uri.parse(
                        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
                      );
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                  ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.info, size: 18),
                  label: const Text("รายละเอียด", style: TextStyle(fontSize: 14)),
                  onPressed: () {
                    final url = Uri.parse(
                      "http://vlg-water-r.disaster.go.th/osm2rain/#/rain-map",
                    );
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}