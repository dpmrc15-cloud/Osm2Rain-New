import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:osm2_app/utils/global.dart';

class AirQualityService {
  Future<Map<String, dynamic>> fetchNearestStation(
      double lat, double lon) async {
    final url =
        "${Global.ROOT_URL}/app/Alert/config/air_quality_api.php?lat=$lat&lon=$lon";
    print("📡 เรียก API: $url");

    try {
      // ✅ เพิ่ม timeout 10 วินาที
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      print("📦 Status Code: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // ✅ ตรวจสอบ JSON ว่าง/null
        if (decoded == null || decoded.isEmpty) {
          throw Exception("API ไม่คืนข้อมูลสถานี");
        }

        // ✅ ตรวจสอบ error key
        if (decoded is Map<String, dynamic> && decoded.containsKey("error")) {
          throw Exception("API Error: ${decoded['error']}");
        }

        print("✅ JSON Decode สำเร็จ: $decoded");
        return decoded;
      } else {
        throw Exception(
            "โหลดข้อมูลไม่สำเร็จ: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("❌ เกิดข้อผิดพลาด: $e");
      throw Exception("ไม่สามารถโหลดข้อมูลคุณภาพอากาศได้: $e");
    }
  }
}
