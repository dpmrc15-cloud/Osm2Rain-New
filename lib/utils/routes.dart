import 'package:flutter/material.dart';
import 'package:osm2_app/pages/basic_setting_screen.dart';
import 'package:osm2_app/pages/login_screen.dart';
import 'package:osm2_app/pages/village_setting_screen.dart';
import 'package:osm2_app/pages/village_edit_screen.dart';
import 'package:osm2_app/pages/home_screen.dart';
import 'package:osm2_app/pages/waters_screen.dart';
import 'package:osm2_app/pages/rain_screen.dart';
import 'package:osm2_app/widgets/rain_widget.dart';
import 'package:osm2_app/widgets/village_edit_widget.dart';
import 'package:osm2_app/widgets/waters_widget.dart';
import 'package:osm2_app/pages/auth_screen.dart';
import 'package:osm2_app/pages/alert_detail_page.dart';

class Routes {
  // ✅ ประกาศชื่อ route ให้ชัดเจน
  static const String initScreenRoute = '/initScreen';
  static const String alertDetailRoute = '/alertDetail';

  /// รวมทุก route ของแอป
  static Map<String, WidgetBuilder> routes() {
    return {
      // ✅ route สำหรับ initScreen → ใช้ AuthScreen เป็นหน้าแรก
      initScreenRoute: (context) => AuthScreen(),

      AuthScreen.ROUTE_ID: (context) => AuthScreen(),
      LoginScreen.ROUTE_ID: (context) => LoginScreen(),
      VillageSettingScreen.ROUTE_ID: (context) => VillageSettingScreen(),
      VillageEditScreen.ROUTE_ID: (context) => VillageEditScreen(),
      HomeScreen.ROUTE_ID: (context) => HomeScreen(),
      WatersScreen.ROUTE_ID: (context) => WatersScreen(),
      RainScreen.ROUTE_ID: (context) => RainScreen(),
      WatersWidget.ROUTE_ID: (context) => WatersWidget(),
      RainWidget.ROUTE_ID: (context) => RainWidget(),
      VillageEditWidget.ROUTE_ID: (context) => VillageEditWidget(),
      BasicSettingScreen.ROUTE_ID: (context) => BasicSettingScreen(),

      // ✅ route สำหรับ AlertDetailPage
      alertDetailRoute: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final data = (args is Map<String, dynamic>) ? args : <String, dynamic>{};
        return AlertDetailPage(alertData: data);
      },
    };
  }

  /// กำหนดหน้าแรกของระบบ
  static String initScreen() {
    return initScreenRoute; // ✅ คืนค่าเป็น '/initScreen'
  }
}