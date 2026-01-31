import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:osm2_app/models/rain.dart';
import 'package:osm2_app/models/rain_history.dart';
import 'package:osm2_app/utils/global.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class RainService {
  static Future<List<Rain>> findAll() async {
    List<Rain> resultList = [];

    final response = await http.get(Uri.parse('${Global.ROOT_URL}/rain/'));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Rain.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<List<RainHistory>> findByDateAndRainId(
      String formDate, String toDate, String rainId) async {
    List<RainHistory> resultList = [];

    final response = await http.get(Uri.parse(
        '${Global.ROOT_URL}/rain/by-date/rain/$formDate/$toDate/$rainId'));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(RainHistory.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<RainHistory> createRainHistory(RainHistory item) async {
    final http.Response response = await http.post(
      Uri.parse('${Global.ROOT_URL}/rain/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("create rain history completed!");
      return RainHistory.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('Failed to create 409');
    } else {
      throw Exception('Failed to create');
    }
  }

  static Future<RainHistory> updateRainHistory(RainHistory item) async {
    final http.Response response = await http.put(
      Uri.parse('${Global.ROOT_URL}/rain/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("update rain history completed!");
      return RainHistory.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('Failed to update 409');
    } else {
      throw Exception('Failed to update');
    }
  }

  static Future<List<RainHistory>> findByDate(
      String formDate, String toDate) async {
    List<RainHistory> resultList = [];

    final response = await http
        .get(Uri.parse('${Global.ROOT_URL}/rain/by-date/$formDate/$toDate'));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(RainHistory.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<List<RainHistory>> findByToDayAndCurrentUser(
      String toDay, String tel) async {
    List<RainHistory> resultList = [];

    final response = await http
        .get(Uri.parse('${Global.ROOT_URL}/rain/by-today-user/$toDay/$tel'));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(RainHistory.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<List<RainHistory>> findByUserPhone(String tel) async {
    List<RainHistory> resultList = [];

    final response =
        await http.get(Uri.parse('${Global.ROOT_URL}/rain/user-phone/$tel'));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(RainHistory.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<Rain> createRain(Rain item) async {
    final http.Response response = await http.post(
      Uri.parse('${Global.ROOT_URL}/rain/new-rain'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("create rain completed!");
      return Rain.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('Failed to create 409');
    } else {
      throw Exception('Failed to create');
    }
  }

  static Future<List<RainHistory>> findLatest() async {
    final response = await http
        .get(
          Uri.parse("${Global.ROOT_URL}/rain/latest"),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => RainHistory.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load latest rain data");
    }
  }

  static Future<void> sendMyToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await http.post(
      Uri.parse('${Global.ROOT_URL}/fcm/send-notification'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fcm_token1": token,
        "rain_id": Global.RAIN_ID.toString(),
      }),
    );
  }

  static Future<List<RainHistory>> deleteRainHistory(String id) async {
    List<RainHistory> resultList = [];

    final response = await http
        .delete(Uri.parse('${Global.ROOT_URL}/rain/mobile/by-id/$id'));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(RainHistory.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }
}
