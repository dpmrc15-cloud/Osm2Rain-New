import 'package:http/http.dart' as http;
// import 'package:osm2_app/models/amphur.dart'; // TODO: unused import
// import 'package:osm2_app/models/moo.dart'; // TODO: unused import
import 'dart:convert';
// import 'package:osm2_app/models/province.dart'; // TODO: unused import
// import 'package:osm2_app/models/tambon.dart'; // TODO: unused import
import 'package:osm2_app/models/users.dart';
// import 'package:osm2_app/models/waters.dart'; // TODO: unused import
import 'package:osm2_app/utils/global.dart';

class UsersService {
  static Future<List<Users>> findByUserPhone(String tel) async {
    List<Users> resultList = [];

    final response = await http
        .get(Uri.parse('${Global.ROOT_URL}/users/tel/$tel'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Users.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<Users> createUser(Users item) async {
    final http.Response response = await http.post(
      Uri.parse('${Global.ROOT_URL}/users/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Users.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('Failed to create 409');
    } else {
      throw Exception('Failed to create');
    }
  }

  static Future<Users> updateUser(Users item) async {
    final http.Response response = await http.put(
      Uri.parse('${Global.ROOT_URL}/users/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Users.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('Failed to update 409');
    } else {
      throw Exception('Failed to update');
    }
  }
}
