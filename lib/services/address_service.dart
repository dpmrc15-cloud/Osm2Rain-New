import 'package:http/http.dart' as http;
import 'package:osm2_app/models/address.dart';
import 'package:osm2_app/models/amphur.dart';
import 'package:osm2_app/models/moo.dart';
import 'dart:convert';
import 'package:osm2_app/models/province.dart';
import 'package:osm2_app/models/tambon.dart';
import 'package:osm2_app/utils/global.dart';

class AddressService {
  static Future<List<Province>> findAllProvince() async {
    List<Province> resultList = [];

    final response = await http
        .get(Uri.parse('${Global.ROOT_URL}/address/province'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Province.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<List<Amphur>> findAmphurByProvince(String provCode) async {
    List<Amphur> resultList = [];

    final response = await http
        .get(Uri.parse('${Global.ROOT_URL}/address/amphur/$provCode'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Amphur.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<List<Tambon>> findtambonByProvinceAndAmphurCode(
      String provCode, String ampCode) async {
    List<Tambon> resultList = [];

    final response = await http
        .get(Uri.parse('${Global.ROOT_URL}/address/tumbon/$provCode/$ampCode'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Tambon.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<List<Moo>> findMooByProvinceAndAmphurAndTambonCode(
      String provCode, String ampCode, String tamCode) async {
    List<Moo> resultList = [];

    final response = await http
        .get(Uri.parse(
            '${Global.ROOT_URL}/address/moo/$provCode/$ampCode/$tamCode'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Moo.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<List<Address>> findUserAddress(
      String provCode, String ampCode, String tamCode, String moo) async {
    List<Address> resultList = [];

    final response = await http.get(Uri.parse(
        '${Global.ROOT_URL}/address/user/$provCode/$ampCode/$tamCode/$moo'));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Address.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<Address> updateVillageEdit(Address item) async {
    final http.Response response = await http.put(
      Uri.parse('${Global.ROOT_URL}/address/edit-village'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Address.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('Failed to update 409');
    } else {
      throw Exception('Failed to update');
    }
  }

  static Future<Address> updateVillageEditByPATM(Address item) async {
    final http.Response response = await http.put(
      Uri.parse('${Global.ROOT_URL}/address/edit-village/patm'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Address.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('Failed to update 409');
    } else {
      throw Exception('Failed to update');
    }
  }
}
