import 'package:http/http.dart' as http;
import 'package:osm2_app/models/integration.dart';
import 'package:osm2_app/models/objective.dart';
import 'package:osm2_app/models/provider.dart';
import 'package:osm2_app/models/type.dart';
import 'package:osm2_app/utils/global.dart';
import 'dart:convert';

class OtherService {
  static Future<List<Provider>> findAllProvider() async {
    List<Provider> resultList = [];

    final response = await http.get(Uri.parse('${Global.ROOT_URL}/provider/'));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Provider.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<List<Objective>> findAllObjective() async {
    List<Objective> resultList = [];

    final response = await http.get(Uri.parse('${Global.ROOT_URL}/objective/'));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Objective.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<List<Integration>> findAllIntegration() async {
    List<Integration> resultList = [];

    final response =
        await http.get(Uri.parse('${Global.ROOT_URL}/integration/'));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Integration.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }

  static Future<List<Type>> findAllType() async {
    List<Type> resultList = [];

    final response = await http.get(Uri.parse('${Global.ROOT_URL}/type/'));
    if (response.statusCode == 200) {
      List dataItem = json.decode(response.body);
      for (var i in dataItem) {
        resultList.add(Type.fromJson(i));
      }
      return resultList;
    } else if (response.statusCode == 404) {
      return resultList;
    } else {
      throw Exception('Failed to load resource');
    }
  }
}
