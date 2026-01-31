// import 'dart:io'; // TODO: unused import
import 'package:osm2_app/pages/rain_screen.dart';

class Global {
  // ### ROOT_URL ###
  static const String ROOT_URL = 'http://vlg-water-r.disaster.go.th/osm2-api';

  // ### SHARED PREFERENCES KEYS ###
  static const String KEY_USER_TEL = "userTel";
  static const String KEY_USER_EMAIL = "userEmail";

  static const String KEY_PROVINCE_CODE = "province_code";
  static const String KEY_DISTRICT_CODE = "district_code";
  static const String KEY_SUBDISTRICT_CODE = "subdistrict_code";
  static const String KEY_MOO = "moo";

  // ### GLOBAL_VARIABLE ###
  static int LIMIT_MARKER = 1;

  // ### ADDRESS_VARIABLE ###
  static String? PROVINCE_CODE;
  static String? AMPHUR_CODE;
  static String? TUMBON_CODE;
  static String? MOO_CODE;

  static String? PROVINCE_NAME;
  static String? AMPHUR_NAME;
  static String? TUMBON_NAME;
  static String? MOO_NAME;
  static String? MOO;

  static String? USER_LOCATION_LAT;
  static String? USER_LOCATION_LNG;

  // ### LOCATION_VARIABLE ###
  static double LAT_ADDRESS = 0;
  static double LNG_ADDRESS = 0;

  // ### NAVIGATOR_VARIABLE ###
  static bool NEW_WATERS_FLAG = true;
  static String WATERS_ID = "";
  static bool NEW_RAIN_FLAG = true;
  static String RAIN_ID = "";
  static bool BTN_RAIN_FLAG = true;

  static const String ROUTE_RAIN_SCREEN = RainScreen.ROUTE_ID;
}
