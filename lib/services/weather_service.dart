import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  final String apiKey = "77c05a2d42d5bdef9297f9622b71d2dc"; // 🔑 API key ของคุณ

  /// ✅ ดึงอุณหภูมิ โดยใช้ Geolocator หา Lat/Lon เอง
  Future<double?> fetchTemperature() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final lat = pos.latitude;
      final lon = pos.longitude;

      print("📍 พิกัดที่ได้: Lat=$lat, Lon=$lon");

      final url = Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey");

      print("🌐 เรียก API: $url");

      final response = await http.get(url);

      print("🔎 Status code: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data["main"]["temp"]?.toDouble();
        print("🌡️ อุณหภูมิที่ได้: $temp °C");
        return temp;
      } else {
        throw Exception("โหลดข้อมูลไม่สำเร็จ: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error: $e");
      return null;
    }
  }

  /// ✅ ดึงอุณหภูมิ โดยรับ Position จากภายนอก
  Future<double?> fetchTemperatureWithPos(Position pos) async {
    try {
      final url = Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&units=metric&appid=$apiKey");

      print("🌐 เรียก API: $url");

      final response = await http.get(url);

      print("🔎 Status code: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data["main"]["temp"]?.toDouble();
        print("🌡️ อุณหภูมิที่ได้: $temp °C");
        return temp;
      } else {
        throw Exception("โหลดข้อมูลไม่สำเร็จ: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Weather Error: $e");
      return null;
    }
  }
}