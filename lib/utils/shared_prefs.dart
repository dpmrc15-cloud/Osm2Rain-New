import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static final _instance = SharedPrefs();
  static SharedPrefs get instance => _instance;

  Future<String?> getValue(String key) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setValue(String key, String value) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> removeValue(String key) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clearAllValue() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}