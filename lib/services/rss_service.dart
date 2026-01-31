import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flutter/foundation.dart';

class RssService {
  final Map<String, String> _stationMap = {
    "เชียงราย": "48303",
    "Chiang Rai": "48303",
    "เชียงใหม่": "48327",
    "Chiang Mai": "48327",
    "พะเยา": "48309",
    "Phayao": "48309",
    "แม่ฮ่องสอน": "48301",
    "Mae Hong Son": "48301",
    "น่าน": "48307",
    "Nan": "48307",
    "แพร่": "48310",
    "Phrae": "48310",
    "ลำปาง": "48328",
    "Lampang": "48328",
    "ลำพูน": "48329",
    "Lamphun": "48329",
    "อุตรดิตถ์": "48335",
    "Uttaradit": "48335",
    "ตาก": "48376",
    "Tak": "48376",
    "สุโขทัย": "48375",
    "Sukhothai": "48375",
    "พิษณุโลก": "48378",
    "Phitsanulok": "48378",
    "กำแพงเพชร": "48380",
    "Kamphaeng Phet": "48380",
    "นครสวรรค์": "48400",
    "Nakhon Sawan": "48400",
    "เพชรบูรณ์": "48379",
    "Phetchabun": "48379",
    "กรุงเทพมหานคร": "48455",
    "Bangkok": "48455",
    "นนทบุรี": "48455",
    "Nonthaburi": "48455",
    "ปทุมธานี": "48456",
    "Pathum Thani": "48456",
    "ขอนแก่น": "48381",
    "Khon Kaen": "48381",
    "นครราชสีมา": "48431",
    "Nakhon Ratchasima": "48431",
    "ภูเก็ต": "48565",
    "Phuket": "48565",
    "สุราษฎร์ธานี": "48552",
    "Surat Thani": "48552",
    "สงขลา": "48568",
    "Songkhla": "48568",
    "ชลบุรี": "48461",
    "Chon Buri": "48461",
  };

  /// ✅ รายชื่อจังหวัดภาคเหนือ
  final List<String> northernProvinces = [
    "เชียงราย",
    "Chiang Rai",
    "เชียงใหม่",
    "Chiang Mai",
    "พะเยา",
    "Phayao",
    "แม่ฮ่องสอน",
    "Mae Hong Son",
    "น่าน",
    "Nan",
    "แพร่",
    "Phrae",
    "ลำปาง",
    "Lampang",
    "ลำพูน",
    "Lamphun",
    "อุตรดิตถ์",
    "Uttaradit",
    "ตาก",
    "Tak",
    "สุโขทัย",
    "Sukhothai",
    "พิษณุโลก",
    "Phitsanulok",
    "กำแพงเพชร",
    "Kamphaeng Phet",
    "นครสวรรค์",
    "Nakhon Sawan",
    "เพชรบูรณ์",
    "Phetchabun",
  ];

  /// ✅ พยากรณ์อากาศตามจังหวัด (เฉพาะภาคเหนือ)
  Future<Map<String, dynamic>> fetchForecastByProvince(
      String provinceFromApi) async {
    try {
      String province = provinceFromApi
          .replaceAll('จังหวัด', '')
          .replaceAll('Province', '')
          .trim();

      // ตรวจสอบว่าอยู่ในภาคเหนือ
      if (!northernProvinces.contains(province)) {
        return {"error": "ข้อมูลนี้ไม่อยู่ในเขตภาคเหนือ"};
      }

      String stationId = _stationMap[province] ?? "48303";
      final url =
          "https://www.tmd.go.th/api/xml/weather-report?stationnumber=$stationId";
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(utf8.decode(response.bodyBytes));
        final items = document.findAllElements("item");

        if (items.isNotEmpty) {
          final item = items.first;
          String rawDescription =
              item.getElement("description")?.innerText ?? "";
          List<String> lines = rawDescription.split("<br/>");

          String temp = "",
              humidity = "",
              condition = "",
              pressure = "",
              wind = "",
              visibility = "",
              rain = "",
              sunrise = "",
              sunset = "";

          for (var line in lines) {
            line = line.replaceAll(RegExp(r"<[^>]*>"), "").trim();
            if (line.contains("อุณหภูมิ"))
              temp = line.replaceAll("อุณหภูมิ :", "").trim();
            if (line.contains("ความชื้นสัมพัทธ์"))
              humidity = line.replaceAll("ความชื้นสัมพัทธ์ :", "").trim();
            if (line.contains("ความกดอากาศ"))
              pressure = line.replaceAll("ความกดอากาศ :", "").trim();
            if (line.contains("ทิศทางลม"))
              wind = line.replaceAll("ทิศทางลม :", "").trim();
            if (line.contains("ทัศนวิสัย"))
              visibility = line.replaceAll("ทัศนวิสัย :", "").trim();
            if (line.contains("ลักษณะอากาศ"))
              condition = line.replaceAll("ลักษณะอากาศ :", "").trim();
            if (line.contains("ฝนสะสมวันนี้"))
              rain = line.replaceAll("ฝนสะสมวันนี้ :", "").trim();
            if (line.contains("พระอาทิตย์ขึ้น"))
              sunrise =
                  line.replaceAll("พระอาทิตย์ขึ้นเช้าพรุ่งนี้:", "").trim();
            if (line.contains("พระอาทิตย์ตก"))
              sunset = line.replaceAll("พระอาทิตย์ตกเย็นวันนี้:", "").trim();
          }

          return {
            "province": province,
            "temp": temp,
            "humidity": humidity,
            "pressure": pressure,
            "wind": wind,
            "visibility": visibility,
            "condition": condition,
            "rain": rain,
            "sunrise": sunrise,
            "sunset": sunset,
          };
        }
      }
    } catch (e) {
      debugPrint("RSS Error: $e");
    }
    return {"error": "ไม่สามารถดึงข้อมูลพยากรณ์อากาศได้"};
  }

  /// ✅ เส้นทางพายุ (กรองเฉพาะภาคเหนือ)
  Future<String> fetchStormTrack() async {
    try {
      const url = "https://www.tmd.go.th/api/xml/storm-tracking";
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(utf8.decode(response.bodyBytes));
        final items = document.findAllElements("item");

        if (items.isNotEmpty) {
          final firstItem = items.first;
          final title = firstItem.getElement("title")?.innerText ?? "";
          final desc = firstItem.getElement("description")?.innerText ?? "";

          // กรองเฉพาะข้อความที่เกี่ยวข้องกับจังหวัดภาคเหนือ
          final focusNorth = northernProvinces
              .any((p) => desc.contains(p) || title.contains(p));
          if (focusNorth) {
            return "🆕 NEW | $title - $desc";
          } else {
            return "🌪️ ไม่มีพายุในเขตภาคเหนือ";
          }
        }
      }
    } catch (e) {
      debugPrint("Storm RSS Error: $e");
    }
    return "ไม่สามารถดึงข้อมูลเส้นทางพายุได้";
  }
}
