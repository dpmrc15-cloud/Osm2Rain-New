import 'package:http/http.dart' as http;
// import 'package:osm2_app/models/amphur.dart'; // TODO: unused import
// import 'package:osm2_app/models/moo.dart'; // TODO: unused import
import 'dart:convert';
// import 'package:osm2_app/models/province.dart'; // TODO: unused import
// import 'package:osm2_app/models/tambon.dart'; // TODO: unused import
import 'package:osm2_app/models/water_uses.dart';
import 'package:osm2_app/models/waters.dart';
import 'package:osm2_app/utils/global.dart';

class WatersService {
  static Future<List<Waters>> findByUserPhone(String tel) async {
    List<Waters> resultList = [];

    final response = await http
        .get(Uri.parse('${Global.ROOT_URL}/waters/user-phone/$tel'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Waters.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<List<Waters>> findById(String id) async {
    List<Waters> resultList = [];

    final response =
        await http.get(Uri.parse('${Global.ROOT_URL}/waters/by-id/$id'));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Waters.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<Waters> createWaters(Waters item) async {
    final http.Response response = await http.post(
      Uri.parse('${Global.ROOT_URL}/waters/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("create water completed!");
      return Waters.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('Failed to create 409');
    } else {
      throw Exception('Failed to create');
    }
  }

  static Future<Waters> updateWaters(Waters item) async {
    final http.Response response = await http.put(
      Uri.parse('${Global.ROOT_URL}/waters/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("update water completed!");
      return Waters.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('Failed to update 409');
    } else {
      throw Exception('Failed to update');
    }
  }

  static Future<WatersUses> createWatersUses(WatersUses item) async {
    final http.Response response = await http.post(
      Uri.parse('${Global.ROOT_URL}/waters/waters-uses'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("create water uses completed!");
      return WatersUses.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('Failed to create 409');
    } else {
      throw Exception('Failed to create');
    }
  }

  static Future<List<Waters>> deleteWaters(String id) async {
    List<Waters> resultList = [];

    final response = await http
        .delete(Uri.parse('${Global.ROOT_URL}/waters/mobile/by-id/$id'));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Waters.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }
}
