import 'package:flutter/material.dart';

import 'package:osm2_app/models/address.dart';
import 'package:osm2_app/models/users.dart';
import 'package:osm2_app/pages/basic_setting_screen.dart';
import 'package:osm2_app/services/address_service.dart';
import 'package:osm2_app/services/users_service.dart';
import 'package:osm2_app/utils/global.dart';
import 'package:osm2_app/utils/utils.dart';
import 'package:osm2_app/pages/home_screen.dart';

import '../utils/shared_prefs.dart';
import '../services/device_register_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String ROUTE_ID = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final SharedPrefs _sharedPrefs = SharedPrefs.instance;

  late TextEditingController _userTel;

  String userTel = "";

  @override
  void initState() {
    super.initState();
    _userTel = TextEditingController();
    _getSharedPreferencesData();
  }

  _getSharedPreferencesData() async {
    userTel = await _sharedPrefs.getValue(Global.KEY_USER_TEL) ?? "";
    if (userTel != "") {
      _userTel.text = userTel;
    } else {
      _userTel.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: const Color(0xFFD4EBF3),
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(30.0),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Column(
              children: <Widget>[
                SizedBox(height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage("lib/asset/imgs/osm2-icon.png"),
                      height: 160,
                      width: 160,
                    ),
                    Image(
                      image: AssetImage("lib/asset/imgs/main-image-v2-3.png"),
                      height: 160,
                      width: 160,
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "ข้อมูลเบอร์โทรศัพท์",
                    style: TextStyle(
                      color: Colors.black87,
                      letterSpacing: 1.5,
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "โปรดใส่เบอร์โทรศัพท์ในการติดต่อของคุณ",
                    style: TextStyle(
                      color: Colors.black87,
                      letterSpacing: 1.5,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _userTel,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(20.0),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
              icon: const Icon(
                Icons.arrow_forward_ios_sharp,
                color: Colors.white,
              ),
              label: const Text(
                'ต่อไป',
                style: TextStyle(
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
              onPressed: _onLogin),
        ]),
      ),
    ));
  }

  _onLogin() async {
    if (_userTel.text.length != 10) {
      Utils.createToast(
          "รูปแบบเบอร์โทรศัพท์ไม่ถูกต้อง (ต้องมี 10 หลักเท่านั้น)");
      return;
    }
    if (!_isNumeric(_userTel.text)) {
      Utils.createToast("รูปแบบเบอร์โทรศัพท์ไม่ถูกต้อง (เป็นตัวเลขเท่านั้น)");
      return;
    }

    // เก็บเบอร์โทรไว้ใน SharedPreferences
    await _sharedPrefs.setValue(Global.KEY_USER_TEL, _userTel.text);

    UsersService.findByUserPhone(_userTel.text).then((value) async {
      if (value.isNotEmpty) {
        // ✅ ผู้ใช้เดิม
        Users users = value.first;

        Global.PROVINCE_CODE = users.provId;
        Global.AMPHUR_CODE = users.ampId;
        Global.TUMBON_CODE = users.tamId;
        Global.MOO_CODE = users.mooId;

        Global.PROVINCE_NAME = users.provName;
        Global.AMPHUR_NAME = users.ampName;
        Global.TUMBON_NAME = users.tamName;
        Global.MOO_NAME = users.mooName;
        Global.MOO = users.moo;

        // เก็บลง SharedPreferences เพิ่มเติม
        await _sharedPrefs.setValue(Global.KEY_PROVINCE_CODE, users.provId);
        await _sharedPrefs.setValue(Global.KEY_DISTRICT_CODE, users.ampId);
        await _sharedPrefs.setValue(Global.KEY_SUBDISTRICT_CODE, users.tamId);
        await _sharedPrefs.setValue(Global.KEY_MOO, users.moo);

        AddressService.findUserAddress(
                users.provId, users.ampId, users.tamId, users.moo)
            .then((value) {
          if (value.isNotEmpty) {
            Address addressObj = value.first;
            Global.USER_LOCATION_LAT = addressObj.lat;
            Global.USER_LOCATION_LNG = addressObj.lng;
          } else {
            print("No address data");
          }
        }).catchError((e) {
          print("❌ Address service error: $e");
        });

        // ✅ ลงทะเบียน device หลัง login สำเร็จ (ผู้ใช้เดิม)
        await DeviceRegisterService.registerDeviceIfReady();

        if (mounted) {
          Navigator.pushReplacementNamed(context, HomeScreen.ROUTE_ID);
        }
      } else {
        // ✅ ผู้ใช้ใหม่
        print("No user data");
        if (mounted) {
          Navigator.pushReplacementNamed(context, BasicSettingScreen.ROUTE_ID);
        }
      }
    }).catchError((e) {
      print("❌ User service error: $e");
      if (mounted) {
        Utils.createToast("เกิดข้อผิดพลาด: $e");
      }
    });
  }

  bool _isNumeric(String result) {
    return double.tryParse(result) != null;
  }
}
