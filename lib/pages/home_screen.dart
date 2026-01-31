import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:osm2_app/pages/rain_screen.dart';
import 'package:osm2_app/pages/village_edit_screen.dart';
import 'package:osm2_app/pages/village_setting_screen.dart';
import 'package:osm2_app/pages/waters_screen.dart';
import 'package:osm2_app/utils/global.dart';
import 'package:osm2_app/utils/utils.dart';
import '../utils/shared_prefs.dart';
import '../utils/navigation_helper.dart'; // ✅ ใช้ helper สำหรับ logout

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String ROUTE_ID = 'home_screen';

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final SharedPrefs _sharedPrefs = SharedPrefs.instance;

  @override
  void initState() {
    super.initState();
    _loadUserLocationFromPrefs();
    _checkProvinceIsNotNull();
  }

  Future<void> _loadUserLocationFromPrefs() async {
    Global.PROVINCE_CODE =
        await _sharedPrefs.getValue(Global.KEY_PROVINCE_CODE);
    Global.AMPHUR_CODE = await _sharedPrefs.getValue(Global.KEY_DISTRICT_CODE);
    Global.TUMBON_CODE =
        await _sharedPrefs.getValue(Global.KEY_SUBDISTRICT_CODE);
    Global.MOO = await _sharedPrefs.getValue(Global.KEY_MOO);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("หน้าแรก"),
        backgroundColor: const Color(0xFF98CFE2),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () =>
                navigateToAuthScreen(context), // ✅ กลับไปหน้า AuthScreen
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "ข้อมูลหมู่บ้านที่ตั้งค่าไว้",
                  style: TextStyle(
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    fontSize: 15,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "ชื่อหมู่บ้าน : ${Global.MOO_NAME ?? ""}",
                  style: const TextStyle(
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    fontSize: 15,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "หมู่ที่ : ${Global.MOO ?? ""}",
                  style: const TextStyle(
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    fontSize: 15,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "ตำบล : ${Global.TUMBON_NAME ?? ""}",
                  style: const TextStyle(
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    fontSize: 15,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "อำเภอ : ${Global.AMPHUR_NAME ?? ""}",
                  style: const TextStyle(
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    fontSize: 15,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "จังหวัด : ${Global.PROVINCE_NAME ?? ""}",
                  style: const TextStyle(
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("lib/asset/imgs/osm2-icon.png"),
                    height: 160,
                    width: 160,
                  ),
                  Image(
                    image: AssetImage("lib/asset/imgs/home-icon-2.jpg"),
                    height: 160,
                    width: 160,
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "รายงานข้อมูลสาธารณภัย",
                  style: TextStyle(
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    fontSize: 25,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              _menuButton(
                icon: Icons.account_balance,
                label: "ตั้งค่าหมู่บ้าน",
                onPressed: () => _openVillageSettingScreen(context),
              ),
              const SizedBox(height: 10.0),
              _menuButton(
                icon: Icons.wysiwyg,
                label: "แก้ไขข้อมูลหมู่บ้าน",
                onPressed: () => _openVillageEditScreen(context),
              ),
              const SizedBox(height: 10.0),
              _menuButton(
                icon: Icons.waves,
                label: "รายงานข้อมูลแหล่งน้ำ",
                onPressed: () => _openWatersScreen(context),
              ),
              const SizedBox(height: 10.0),
              _menuButton(
                icon: Icons.cloud,
                label: "รายงานข้อมูลน้ำฝน",
                onPressed: () => _openRainScreen(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String label,
    required Function onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF55D2E3),
          padding: const EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => onPressed(),
      ),
    );
  }

  _openVillageSettingScreen(context) async {
    await Navigator.pushNamed(context, VillageSettingScreen.ROUTE_ID);
    setState(() {});
  }

  _openVillageEditScreen(context) async {
    await Navigator.pushNamed(context, VillageEditScreen.ROUTE_ID);
  }

  _openWatersScreen(context) async {
    await Navigator.pushNamed(context, WatersScreen.ROUTE_ID);
  }

  _openRainScreen(context) async {
    await Navigator.pushNamed(context, RainScreen.ROUTE_ID);
  }

  _checkProvinceIsNotNull() {
    if (Utils.isNullOrEmpty(Global.PROVINCE_CODE)) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(context, VillageSettingScreen.ROUTE_ID)
            .then((value) {
          setState(() {});
        });
      });
    }
  }
}
