import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:osm2_app/utils/routes.dart';
import 'dart:convert';
import 'package:marquee/marquee.dart';

/// ✅ ฟังก์ชันแปลงข้อมูล 3 วันให้ขึ้นบรรทัดใหม่และคำนวณยอดรวม
String formatLast3Days(dynamic raw) {
  if (raw == null || raw.toString().isEmpty) return "ไม่ระบุ";
  try {
    final List<dynamic> items =
        raw is String ? jsonDecode(raw) : raw as List<dynamic>;

    double totalAllDays = 0;
    List<String> lines = [];

    for (var e in items) {
      final date = e['report_date']?.toString() ?? "";
      final rainStr = e['total_rainfall']?.toString() ?? "0";
      final rainValue = double.tryParse(rainStr) ?? 0;

      totalAllDays += rainValue;
      lines.add("$date : $rainStr มม.");
    }

    // เพิ่มบรรทัดสรุปยอดรวม (ใช้ toStringAsFixed เพื่อจัดการจุดทศนิยม)
    if (lines.isNotEmpty) {
      lines.add("ฝนที่ตก 3 วัน : ${totalAllDays.toStringAsFixed(1)} มม.");
    } else {
      return "ไม่มีข้อมูลสะสม 3 วัน";
    }

    return lines.join("\n");
  } catch (e) {
    debugPrint("DEBUG: formatLast3Days error: $e");
    return raw.toString();
  }
}

class AlertDetailPage extends StatelessWidget {
  final Map<String, dynamic> alertData;

  const AlertDetailPage({super.key, required this.alertData});

  Future<void> _openMap() async {
    final lat = alertData['lat']?.toString();
    final lng = alertData['lng']?.toString();
    if (lat == null || lng == null || lat.isEmpty || lng.isEmpty) return;
    final url =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(url))
      await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _callPhone() async {
    final phone = alertData['phone']?.toString();
    if (phone == null || phone.isEmpty) return;
    final url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _openWebPage() async {
    final url = Uri.parse("http://164.115.233.121/osm2rain/#/rain-map");
    if (await canLaunchUrl(url))
      await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  /// ✅ ปรับปรุงให้รองรับหลายบรรทัด (Multiline)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // ให้หัวข้ออยู่บรรทัดบนสุด
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 16,
                  height: 1.4), // เพิ่ม height เพื่อให้อ่านง่ายขึ้น
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskIcon(String? riskLevel) {
    String iconPath;
    switch (riskLevel?.toLowerCase()) {
      case "เขียว":
        iconPath = "lib/asset/imgs/risk-rain-1.png";
        break;
      case "เหลือง":
        iconPath = "lib/asset/imgs/risk-rain-2.png";
        break;
      case "ส้ม":
        iconPath = "lib/asset/imgs/risk-rain-3.png";
        break;
      case "แดง":
        iconPath = "lib/asset/imgs/risk-rain-4.png";
        break;
      default:
        return const Text("ไม่ระบุระดับความเสี่ยง");
    }

    return Column(
      children: [
        Image.asset(
          iconPath,
          height: 120,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, color: Colors.red, size: 64),
        ),
        const SizedBox(height: 12),
        Text(
          "สถานะฝน: ${alertData['rain_status'] ?? "ไม่ระบุ"}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "ข้อควรปฏิบัติ: ${alertData['risk_message'] ?? "ไม่ระบุ"}",
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _confidenceColor(String? level) {
    switch (level?.toLowerCase()) {
      case "สูง":
      case "เขียว":
        return Colors.green;
      case "กลาง":
      case "เหลือง":
        return Colors.orange;
      case "ต่ำ":
      case "ส้ม":
        return Colors.deepOrange;
      case "รุนแรง":
      case "แดง":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Widget _confidenceMarquee(String? confidence) {
    final value = (confidence ?? "ไม่ระบุ").trim();
    final text = "ความถูกต้องของข้อมูล : $value";

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Marquee(
        text: text,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: _confidenceColor(value)),
        scrollAxis: Axis.horizontal,
        blankSpace: 80.0,
        velocity: 18.0,
        startPadding: 12.0,
        pauseAfterRound: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = (alertData['title'] ?? "แจ้งเตือน").toString();
    final body = (alertData['body'] ?? "").toString();

    return Scaffold(
      appBar: AppBar(title: const Text("รายละเอียดแจ้งเตือน")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(body, style: const TextStyle(fontSize: 16)),
            const Divider(height: 24),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _riskIcon(alertData['risk_level']?.toString()),
              ),
            ),

            const SizedBox(height: 16),
            _confidenceMarquee(alertData['confidence_level']?.toString()),

            const Divider(height: 24),
            _buildInfoRow("น้ำฝนที่รายงานปัจจุบัน",
                alertData['current_rainfall']?.toString() ?? "ไม่ระบุ"),
            _buildInfoRow("ปริมาณน้ำฝนสะสม",
                "${alertData['daily_rainfall'] ?? 0} มม. (${alertData['accumulated_hours'] ?? 0} ชม.)"),
            _buildInfoRow(
                "ปริมาณน้ำฝนสะสม 3 วัน",
                formatLast3Days(
                    alertData['last3days'])), // ✅ แสดงผลหลายบรรทัดพร้อมยอดรวม
            _buildInfoRow("ปริมาณน้ำฝนโทรมาตร",
                alertData['station_rainfall']?.toString() ?? "ไม่ระบุ"),
            _buildInfoRow("วัน/เวลาที่รายงาน",
                alertData['reported_at']?.toString() ?? "ไม่ระบุ"),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openMap,
              icon: const Icon(Icons.map),
              label: const Text("เปิดแผนที่"),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45)),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _callPhone,
              icon: const Icon(Icons.phone),
              label: const Text("โทรศัพท์"),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45)),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _openWebPage,
              icon: const Icon(Icons.web),
              label: const Text("รายละเอียดเพิ่มเติม"),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context)
                      .pushReplacementNamed(Routes.initScreen());
                }
              },
              icon: const Icon(Icons.check),
              label: const Text("OK"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
