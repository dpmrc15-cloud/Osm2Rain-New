import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:osm2_app/models/rain.dart';
import 'package:osm2_app/models/rain_history.dart';
import 'package:osm2_app/services/rain_service.dart';
import 'package:osm2_app/utils/global.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:osm2_app/utils/utils.dart';
import 'package:flutter/services.dart';
import '../utils/shared_prefs.dart';

class RainWidget extends StatefulWidget {
  const RainWidget({super.key});

  static const String ROUTE_ID = 'rain_widget';

  @override
  RainWidgetState createState() => RainWidgetState();
}

class RainWidgetState extends State<RainWidget> {
  final SharedPrefs _sharedPrefs = SharedPrefs.instance;

  late String mode = 'I';
  late String rainMode = 'I';
  late bool btnRainFlag = true;
  late bool isHide = true;

  late TextEditingController _rainTxt;

  late RainHistory rainObj;

  String? _oneHourRainfall = "";
  String? _twoHourRainfall = "";
  String? _threeHourRainfall = "";
  String? _sixHourRainfall = "";
  String? _twelveHourRainfall = "";
  String? _allDayRainfall = "";

  String? _provName = "";
  String? _ampName = "";
  String? _tamName = "";
  String? _mooName = "";
  String? _moo = "";
  String? _lat = "";
  String? _lng = "";
  String? _tel = "";

  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _base64String = "";

  String userTel = "";

  @override
  void initState() {
    super.initState();

    btnRainFlag = Global.BTN_RAIN_FLAG;

    _rainTxt = TextEditingController();

    initLoad();
  }

  initLoad() async {
    userTel = await _sharedPrefs.getValue(Global.KEY_USER_TEL) ?? "";

    if (!Global.NEW_RAIN_FLAG) {
      mode = "E";
      _initRainValue(Global.RAIN_ID);
    } else {
      setState(() {
        _provName = Global.PROVINCE_NAME;
        _ampName = Global.AMPHUR_NAME;
        _tamName = Global.TUMBON_NAME;
        _mooName = Global.MOO_NAME;
        _moo = Global.MOO;
        _tel = userTel;
      });
    }
  }

  _initRainValue(rainId) {
    var dateFormatter = DateFormat('yyyy-MM-dd');
    var dateString = dateFormatter.format(DateTime.now());

    RainService.findByDateAndRainId(dateString, dateString, rainId)
        .then((value) {
      if (value.isNotEmpty) {
        rainMode = "E";

        setState(() {
          rainObj = value.first;

          _oneHourRainfall = rainObj.oneHourRainfall;
          _twoHourRainfall = rainObj.twoHourRainfall;
          _threeHourRainfall = rainObj.threeHourRainfall;
          _sixHourRainfall = rainObj.sixHourRainfall;
          _twelveHourRainfall = rainObj.twelveHourRainfall;
          _allDayRainfall = rainObj.allDayRainfall;

          _provName = rainObj.provName;
          _ampName = rainObj.ampName;
          _tamName = rainObj.tamName;
          _mooName = rainObj.mooName;
          _moo = rainObj.moo;
          _lat = rainObj.lat;
          _lng = rainObj.lng;
          _tel = rainObj.userPhone;

          _base64String = rainObj.rainImage;
        });
      } else {
        rainMode = "I";

        setState(() {
          _provName = Global.PROVINCE_NAME;
          _ampName = Global.AMPHUR_NAME;
          _tamName = Global.TUMBON_NAME;
          _mooName = Global.MOO_NAME;
          _moo = Global.MOO;
          _tel = userTel;
        });
      }
    }).catchError((e) {
      print("❌ RainService.findByDateAndRainId error: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("ข้อมูลน้ำฝน"),
          backgroundColor: const Color(0xFF98CFE2),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const ListTile(
                              leading: Icon(Icons.article),
                              title: Text('ปริมาณน้ำฝน'),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'ชื่อหมู่บ้าน',
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                Expanded(flex: 1, child: Container()),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    _mooName != ""
                                        ? '$_mooName'
                                        : "ไม่พบข้อมูล",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'หมู่ที่',
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                Expanded(flex: 1, child: Container()),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    _moo != "" ? '$_moo' : "ไม่พบข้อมูล",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'ตำบล',
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                Expanded(flex: 1, child: Container()),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    _tamName != ""
                                        ? '$_tamName'
                                        : "ไม่พบข้อมูล",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'อำเภอ',
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                Expanded(flex: 1, child: Container()),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    _ampName != ""
                                        ? '$_ampName'
                                        : "ไม่พบข้อมูล",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'จังหวัด',
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                Expanded(flex: 1, child: Container()),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    _provName != ""
                                        ? '$_provName'
                                        : "ไม่พบข้อมูล",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'ละติจูด',
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                Expanded(flex: 1, child: Container()),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    _lat != "" ? '$_lat' : "ไม่พบข้อมูล",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'ลองจิจูด',
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                Expanded(flex: 1, child: Container()),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    _lng != "" ? '$_lng' : "ไม่พบข้อมูล",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'เบอร์ผู้รายงาน',
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                Expanded(flex: 1, child: Container()),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    _tel != "" ? '$_tel' : "ไม่พบข้อมูล",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            !isHide
                                ? Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'ปริมาณน้ำฝน 1 ชั่วโมง',
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                          Expanded(flex: 1, child: Container()),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              _oneHourRainfall != ""
                                                  ? '$_oneHourRainfall'
                                                  : "ไม่พบข้อมูล",
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'ปริมาณน้ำฝน 2 ชั่วโมง',
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                          Expanded(flex: 1, child: Container()),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              _twoHourRainfall != ""
                                                  ? '$_twoHourRainfall'
                                                  : "ไม่พบข้อมูล",
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'ปริมาณน้ำฝน 3 ชั่วโมง',
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                          Expanded(flex: 1, child: Container()),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              _threeHourRainfall != ""
                                                  ? '$_threeHourRainfall'
                                                  : "ไม่พบข้อมูล",
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'ปริมาณน้ำฝน 6 ชั่วโมง',
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                          Expanded(flex: 1, child: Container()),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              _sixHourRainfall != ""
                                                  ? '$_sixHourRainfall'
                                                  : "ไม่พบข้อมูล",
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'ปริมาณน้ำฝน 12 ชั่วโมง',
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                          Expanded(flex: 1, child: Container()),
                                          Expanded(
                                            flex: 6,
                                            child: Text(
                                              _twelveHourRainfall != ""
                                                  ? '$_twelveHourRainfall'
                                                  : "ไม่พบข้อมูล",
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Container(),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Stack(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Divider(
                                      color: Color(0xFF55D2E3),
                                      thickness: 1.5,
                                    ),
                                  ),
                                ),
                                isHide
                                    ? Center(
                                        child: ElevatedButton.icon(
                                            icon: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            label: const Text(
                                              '     ขยาย     ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                letterSpacing: 1.0,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF55D2E3),
                                              padding:
                                                  const EdgeInsets.all(7.5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isHide = false;
                                              });
                                            }),
                                      )
                                    : Center(
                                        child: ElevatedButton.icon(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            label: const Text(
                                              '     ย่อ     ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                letterSpacing: 1.0,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF55D2E3),
                                              padding:
                                                  const EdgeInsets.all(7.5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isHide = true;
                                              });
                                            }),
                                      )
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'ปริมาณน้ำฝนทั้งวัน',
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                Expanded(flex: 1, child: Container()),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    _allDayRainfall != ""
                                        ? '$_allDayRainfall'
                                        : "ไม่พบข้อมูล",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            btnRainFlag
                                ? Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'ปริมาณน้ำฝน (มม.)',
                                          style: TextStyle(
                                              color: Colors.black
                                                  .withOpacity(0.6)),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 7,
                                        child: SizedBox(
                                          height: 40.0,
                                          child: TextField(
                                            controller: _rainTxt,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly, // ✅ กันตัวหนังสือ
                                              LengthLimitingTextInputFormatter(
                                                  3), // ✅ จำกัดไม่เกิน 3 หลัก
                                            ],
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 10.0),
                                              border: OutlineInputBorder(),
                                            ),
                                            onChanged: (value) {
                                              if (value.isEmpty) return;
                                              final num = int.tryParse(value);
                                              if (num == null ||
                                                  num < 0 ||
                                                  num > 300) {
                                                _rainTxt.text = "";
                                                _rainTxt.selection =
                                                    TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset:
                                                          _rainTxt.text.length),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "กรุณากรอกตัวเลขระหว่าง 0–300"),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Center(
                              child: _base64String != ""
                                  ? Container(
                                      color: Colors.grey,
                                      height: 200,
                                      width: 200,
                                      child: Image.memory(
                                          base64Decode(_base64String!)),
                                    )
                                  : Container(
                                      child: const Text("ยังไม่ได้เลือกรูป"),
                                    ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            btnRainFlag
                                ? SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'ถ่ายรูป',
                                          style: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF55D2E3),
                                          padding: const EdgeInsets.all(15.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () {
                                          _imgFromCamera();
                                        }),
                                  )
                                : Container(),
                            const SizedBox(
                              height: 10.0,
                            ),
                            btnRainFlag
                                ? SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.file_copy,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'เลือกรูปจากคลัง',
                                          style: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF55D2E3),
                                          padding: const EdgeInsets.all(15.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () {
                                          _imgFromGallery();
                                        }),
                                  )
                                : Container(),
                            const SizedBox(
                              height: 10.0,
                            ),
                          ]),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  btnRainFlag
                      ? Container(
                          child: mode == "E"
                              ? Row(
                                  children: [
                                    Expanded(
                                        flex: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: ElevatedButton.icon(
                                              icon: const Icon(
                                                Icons.save,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'บันทึก',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  letterSpacing: 1.5,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.green[400],
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () {
                                                _saveButtonOnClick(context);
                                              }),
                                        )),
                                    Expanded(
                                        flex: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: ElevatedButton.icon(
                                              icon: const Icon(
                                                Icons.restore_from_trash,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'ลบ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  letterSpacing: 1.5,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red[400],
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () {
                                                _createConfirmDeleteDialog(
                                                    context);
                                              }),
                                        )),
                                  ],
                                )
                              : ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.save,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'บันทึก',
                                    style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[400],
                                    padding: const EdgeInsets.all(15.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    _saveButtonOnClick(context);
                                  }),
                        )
                      : Container(),
                ],
              )),
        ));
  }

  _saveButtonOnClick(context) {
    if (_rainTxt.text == "") {
      Utils.createToast("กรุณากรอกปริมาณน้ำฝน!");
      return;
    }
    // ตรวจสอบว่าเป็นตัวเลขและอยู่ในช่วง 0–300
    final num = int.tryParse(_rainTxt.text);
    if (num == null || num < 0 || num > 300) {
      Utils.createToast("กรุณากรอกตัวเลขระหว่าง 0–300!");
      return;
    }

    _showSpinner();

    var rainType = "";
    var oneHourRainfall = "0";
    var twoHourRainfall = "0";
    var threeHourRainfall = "0";
    var sixHourRainfall = "0";
    var twelveHourRainfall = "0";
    var allDayRainfall = 0.0;
    var dateFormatter = DateFormat('HH');
    var dateString = dateFormatter.format(DateTime.now());

    // set time
    if (int.parse(dateString) == 7) {
      rainType = "1";
      oneHourRainfall = _rainTxt.text;
    } else if (int.parse(dateString) > 7 && int.parse(dateString) <= 9) {
      rainType = "2";
      twoHourRainfall = _rainTxt.text;
    } else if (int.parse(dateString) > 9 && int.parse(dateString) <= 12) {
      rainType = "3";
      threeHourRainfall = _rainTxt.text;
    } else if (int.parse(dateString) > 12 && int.parse(dateString) <= 18) {
      rainType = "4";
      sixHourRainfall = _rainTxt.text;
    } else {
      rainType = "5";
      twelveHourRainfall = _rainTxt.text;
    }

    if (mode == "I") {
      Rain rainItem = Rain(
          rainId: "",
          mooId: _findMooId(),
          createDate: "",
          lat: '${Global.LAT_ADDRESS}',
          lng: '${Global.LNG_ADDRESS}');

      RainService.createRain(rainItem).then((value) {
        RainHistory rainHistory = RainHistory(
            rainHistoryId: rainMode == "I" ? "" : rainObj.rainHistoryId,
            rainId: value.rainId,
            oneHourRainfall: oneHourRainfall,
            twoHourRainfall: twoHourRainfall,
            threeHourRainfall: threeHourRainfall,
            sixHourRainfall: sixHourRainfall,
            twelveHourRainfall: twelveHourRainfall,
            allDayRainfall: _rainTxt.text,
            userPhone: userTel,
            createDate: "",
            rainImage:
                _image != null ? base64Encode(_image!.readAsBytesSync()) : "",
            moo: Global.MOO,
            mooName: Global.MOO_NAME,
            tamName: Global.TUMBON_NAME,
            ampName: Global.AMPHUR_NAME,
            provName: Global.PROVINCE_NAME,
            lat: '${Global.LAT_ADDRESS}',
            lng: '${Global.LNG_ADDRESS}');

        // Create rain
        RainService.createRainHistory(rainHistory).then((value) {
          if (mounted) {
            Navigator.pop(context);
            Navigator.pop(context, true);
          }
        }).catchError((e) {
          print("❌ RainService.createRainHistory error: $e");
        });
      });
    } else {
      // first time of the day
      if (rainMode == "I") {
        RainHistory rainHistory = RainHistory(
            rainHistoryId: rainMode == "I" ? "" : rainObj.rainHistoryId,
            rainId: Global.RAIN_ID,
            oneHourRainfall: oneHourRainfall,
            twoHourRainfall: twoHourRainfall,
            threeHourRainfall: threeHourRainfall,
            sixHourRainfall: sixHourRainfall,
            twelveHourRainfall: twelveHourRainfall,
            allDayRainfall: _rainTxt.text,
            userPhone: userTel,
            createDate: "",
            rainImage:
                _image != null ? base64Encode(_image!.readAsBytesSync()) : "",
            moo: Global.MOO,
            mooName: Global.MOO_NAME,
            tamName: Global.TUMBON_NAME,
            ampName: Global.AMPHUR_NAME,
            provName: Global.PROVINCE_NAME,
            lat: '${Global.LAT_ADDRESS}',
            lng: '${Global.LNG_ADDRESS}');

        // Create rain
        RainService.createRainHistory(rainHistory).then((value) {
          Navigator.pop(context);
          Navigator.pop(context, true);
        });
      } else {
        if (rainType == '1') {
          rainObj.oneHourRainfall = _rainTxt.text;
        } else if (rainType == '2') {
          rainObj.twoHourRainfall = _rainTxt.text;
        } else if (rainType == '3') {
          rainObj.threeHourRainfall = _rainTxt.text;
        } else if (rainType == '4') {
          rainObj.sixHourRainfall = _rainTxt.text;
        } else if (rainType == '5') {
          rainObj.twelveHourRainfall = _rainTxt.text;
        }
        allDayRainfall = (double.tryParse(rainObj.oneHourRainfall) ?? 0.0) +
            (double.tryParse(rainObj.twoHourRainfall) ?? 0.0) +
            (double.tryParse(rainObj.threeHourRainfall) ?? 0.0) +
            (double.tryParse(rainObj.sixHourRainfall) ?? 0.0) +
            (double.tryParse(rainObj.twelveHourRainfall) ?? 0.0);

        RainHistory rainHistory = RainHistory(
            rainHistoryId: rainMode == "I" ? "" : rainObj.rainHistoryId,
            rainId: Global.RAIN_ID,
            oneHourRainfall: rainObj.oneHourRainfall,
            twoHourRainfall: rainObj.twoHourRainfall,
            threeHourRainfall: rainObj.threeHourRainfall,
            sixHourRainfall: rainObj.sixHourRainfall,
            twelveHourRainfall: rainObj.twelveHourRainfall,
            allDayRainfall: '$allDayRainfall',
            userPhone: userTel,
            createDate: "",
            rainImage:
                _image != null ? base64Encode(_image!.readAsBytesSync()) : "",
            moo: Global.MOO,
            mooName: Global.MOO_NAME,
            tamName: Global.TUMBON_NAME,
            ampName: Global.AMPHUR_NAME,
            provName: Global.PROVINCE_NAME,
            lat: '${Global.LAT_ADDRESS}',
            lng: '${Global.LNG_ADDRESS}');

        // Update rain
        RainService.updateRainHistory(rainHistory).then((value) {
          if (mounted) {
            Navigator.pop(context);
            Navigator.pop(context, true);
          }
        }).catchError((e) {
          print("❌ RainService.updateRainHistory error: $e");
        });
      }
    }
  }

  _findMooId() {
    String tamId = Global.TUMBON_CODE!;
    String moo = Global.MOO!;

    if (moo.length == 1) {
      return "${tamId}0$moo";
    } else {
      return tamId + moo;
    }
  }

  _imgFromCamera() async {
    XFile? xFile =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    if (xFile != null) {
      setState(() {
        _image = File(xFile.path);
        _base64String = base64Encode(_image!.readAsBytesSync());
      });
    }
  }

  _imgFromGallery() async {
    XFile? xFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (xFile != null) {
      setState(() {
        _image = File(xFile.path);
        _base64String = base64Encode(_image!.readAsBytesSync());
      });
    }
  }

  _createConfirmDeleteDialog(contextRoot) {
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text("แจ้งเตือน"),
            content: const Text("คุณต้องการลบน้ำฝนนี้หรือไม่?"),
            actions: <Widget>[
              TextButton(
                child:
                    const Text('ยกเลิก', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child:
                    const Text('ตกลง', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  Navigator.pop(context);

                  RainService.deleteRainHistory(Global.RAIN_ID).then((value) {
                    if (mounted) {
                      Navigator.pop(contextRoot, true);
                    }
                  }).catchError((e) {
                    print("❌ RainService.deleteRainHistory error: $e");
                  });
                },
              ),
            ]);
      },
    );
  }

  _showSpinner() async {
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return const SpinKitWave(
          color: Colors.blueAccent,
          size: 50.0,
        );
      },
    );
  }
}
