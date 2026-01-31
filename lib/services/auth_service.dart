import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:osm2_app/utils/global.dart';

class UserLocation {
  final String provId;
  final String ampId;
  final String tamId;

  UserLocation(this.provId, this.ampId, this.tamId);
}

class AuthService {
  static Future<UserLocation> getUserLocation(String phone) async {
    final url = Uri.parse("${Global.ROOT_URL}/users/tel/$phone");
    final res = await http.get(url).timeout(const Duration(seconds: 10));

    final List<dynamic> dataList = jsonDecode(res.body);
    if (dataList.isEmpty) {
      throw Exception('No user data returned from API');
    }
    final data = dataList[0];

    return UserLocation(
      data["prov_id"].toString(),
      data["amp_id"].toString(),
      data["tam_id"].toString(),
    );
  }
}
