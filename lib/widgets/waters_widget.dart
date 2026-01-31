import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:osm2_app/models/integration.dart';
import 'package:osm2_app/models/objective.dart';
import 'package:osm2_app/models/provider.dart';
import 'package:osm2_app/models/type.dart';
import 'package:osm2_app/models/water_uses.dart';
import 'package:osm2_app/models/waters.dart';
import 'package:osm2_app/services/other_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:osm2_app/services/waters_service.dart';
import 'package:osm2_app/utils/global.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../utils/shared_prefs.dart';

class WatersWidget extends StatefulWidget {
  const WatersWidget({super.key});

  static const String ROUTE_ID = 'waters_widget';

  @override
  WatersWidgetState createState() => WatersWidgetState();
}

class WatersWidgetState extends State<WatersWidget> {
  final SharedPrefs _sharedPrefs = SharedPrefs.instance;

  late String mode = 'I';
  late String lat = "";
  late String lng = "";

  late String _watersStatusValue = '0';
  late String _sufficientWatersStatusValue = '0';
  late String _waterLevelStatusValue = '0';
  late String _providerValue = '1';
  late String _objectiveValue = '1';
  late String _integrationValue = '1';
  late String _typeValue = '1';

  late String _dropdown1Text = '';
  late String _dropdown2Text = '';
  late String _dropdown3Text = '';

  late TextEditingController _nameTxt;
  late TextEditingController _detailTxt;
  late TextEditingController _sizeAreaTxt;
  late TextEditingController _deepTxt;
  late TextEditingController _currentDeepTxt;
  late TextEditingController _depleteDateTxt;

  final watersStatusMapList = [
    {'Value': '0', 'Label': 'ไม่เพียงพอ'},
    {'Value': '1', 'Label': 'เพียงพอ'},
  ];

  final sufficientWatersStatusMapList = [
    {'Value': '0', 'Label': 'ไม่มีข้อมูล'},
    {'Value': '1', 'Label': 'เพียงพอ'},
    {'Value': '2', 'Label': 'ไม่เพียงพอ'},
  ];

  final waterLevelStatusMapList = [
    {'Value': '0', 'Label': 'คงที่'},
    {'Value': '1', 'Label': 'เพิ่ม'},
    {'Value': '2', 'Label': 'ลด'},
  ];

  List<Provider> providerMapList = [];
  List<Objective> objectiveMapList = [];
  List<Integration> integrationMapList = [];
  List<Type> typeMapList = [];

  late Waters watersObj;

  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _base64String = "";

  String userTel = "";

  @override
  void initState() {
    super.initState();

    _nameTxt = TextEditingController();
    _detailTxt = TextEditingController();
    _sizeAreaTxt = TextEditingController();
    _deepTxt = TextEditingController();
    _currentDeepTxt = TextEditingController();
    _depleteDateTxt = TextEditingController();

    _initDropdownList();

    if (!Global.NEW_WATERS_FLAG) {
      mode = "E";
      _initWatersValue(Global.WATERS_ID);
    }

    _onChangeDropdownText();
  }

  _initDropdownList() {
    OtherService.findAllProvider().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          providerMapList = value;
        });
      } else {
        print("No provider data");
      }
    }).catchError((e) {
      print("❌ OtherService.findAllProvider error: $e");
    });

    OtherService.findAllObjective().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          objectiveMapList = value;
        });
      } else {
        print("No objective data");
      }
    }).catchError((e) {
      print("❌ OtherService.findAllObjective error: $e");
    });

    OtherService.findAllIntegration().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          integrationMapList = value;
        });
      } else {
        print("No integration data");
      }
    }).catchError((e) {
      print("❌ OtherService.findAllIntegration error: $e");
    });

    OtherService.findAllType().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          typeMapList = value;
        });
      } else {
        print("No type data");
      }
    }).catchError((e) {
      print("❌ OtherService.findAllType error: $e");
    });
  }

  _initWatersValue(watersId) {
    WatersService.findById(watersId).then((value) {
      if (value.isNotEmpty) {
        setState(() {
          watersObj = value.first;

          _providerValue = watersObj.providerId;
          _objectiveValue = watersObj.objectiveId;
          _integrationValue = watersObj.integrationId;
          _typeValue = watersObj.typeId;
          _watersStatusValue = watersObj.fullFill;
          _sufficientWatersStatusValue = watersObj.sufficientWater;
          _waterLevelStatusValue = watersObj.waterLevel;

          _nameTxt.text = watersObj.name;
          _detailTxt.text = watersObj.detail;
          _sizeAreaTxt.text = watersObj.sizeArea;
          _deepTxt.text = watersObj.deep;
          _currentDeepTxt.text = watersObj.currentDeep;
          _depleteDateTxt.text = watersObj.depleteDate;

          lat = watersObj.lat;
          lng = watersObj.lng;

          _base64String = watersObj.waterImage;
        });
      } else {
        print("No waters data");
      }
    }).catchError((e) {
      print("❌ WatersService.findById error: $e");
    });
  }

  _onChangeDropdownText() {
    if (_typeValue == '1') {
      _dropdown1Text = 'พื้นที่แหล่งน้ำ (ไร่)';
      _dropdown2Text = 'ความลึกกักเก็บ (เมตร)';
      _dropdown3Text = 'ความลึกคงเหลือ (เมตร)';
    } else if (_typeValue == '2') {
      _dropdown1Text = 'ขนาดเส้นผ่าศูนย์กลาง (นิ้ว)';
      _dropdown2Text = 'ความลึกบ่อบาดาล (เมตร)';
      _dropdown3Text = '';
    } else if (_typeValue == '3') {
      _dropdown1Text = 'ความกว้างลำน้ำ (เมตร)';
      _dropdown2Text = 'ความลึกกักเก็บ (เมตร)';
      _dropdown3Text = 'ความลึกคงเหลือ (เมตร)';
    } else if (_typeValue == '4') {
      _dropdown1Text = '';
      _dropdown2Text = '';
      _dropdown3Text = '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('th', 'TH'), // เพิ่มบรรทัดนี้
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _depleteDateTxt.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("ข้อมูลแหล่งน้ำ"),
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
                        children: [
                          const ListTile(
                            leading: Icon(Icons.article),
                            title: Text('ข้อมูลแหล่งน้ำ'),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'ชื่อแหล่งน้ำ',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              Expanded(
                                  flex: 7,
                                  child: SizedBox(
                                    height: 40.0,
                                    child: TextField(
                                      controller: _nameTxt,
                                      decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 10.0),
                                          border: OutlineInputBorder()),
                                    ),
                                  )),
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
                                  'รายละเอียด',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              Expanded(
                                  flex: 7,
                                  child: SizedBox(
                                    height: 120.0,
                                    child: TextField(
                                      controller: _detailTxt,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 8,
                                      maxLength: 500,
                                      decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 10.0),
                                          border: OutlineInputBorder()),
                                    ),
                                  )),
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
                                  'ประเภทแหล่งน้ำ',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              Expanded(
                                  flex: 7,
                                  child: SizedBox(
                                    height: 50.0,
                                    child: DropdownButton<String>(
                                      value: _typeValue,
                                      isExpanded: true,
                                      items: typeMapList.map((Type map) {
                                        return DropdownMenuItem<String>(
                                          value: map.typeId,
                                          child: Text(map.typeName),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _typeValue = value!;

                                          _onChangeDropdownText();
                                        });
                                      },
                                    ),
                                  )),
                            ],
                          ),
                          (_typeValue == '1' ||
                                  _typeValue == '2' ||
                                  _typeValue == '3')
                              ? const SizedBox(
                                  height: 10.0,
                                )
                              : const SizedBox(
                                  height: 0.0,
                                ),
                          (_typeValue == '1' ||
                                  _typeValue == '2' ||
                                  _typeValue == '3')
                              ? Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        _dropdown1Text,
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.6)),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: SizedBox(
                                          height: 40.0,
                                          child: TextField(
                                            controller: _sizeAreaTxt,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                                border: OutlineInputBorder()),
                                          ),
                                        )),
                                  ],
                                )
                              : Container(),
                          (_typeValue == '1' ||
                                  _typeValue == '2' ||
                                  _typeValue == '3')
                              ? const SizedBox(
                                  height: 10.0,
                                )
                              : const SizedBox(
                                  height: 0.0,
                                ),
                          (_typeValue == '1' ||
                                  _typeValue == '2' ||
                                  _typeValue == '3')
                              ? Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        _dropdown2Text,
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.6)),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: SizedBox(
                                          height: 40.0,
                                          child: TextField(
                                            controller: _deepTxt,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                                border: OutlineInputBorder()),
                                          ),
                                        )),
                                  ],
                                )
                              : Container(),
                          (_typeValue == '1' || _typeValue == '3')
                              ? const SizedBox(
                                  height: 10.0,
                                )
                              : const SizedBox(
                                  height: 0.0,
                                ),
                          (_typeValue == '1' || _typeValue == '3')
                              ? Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        _dropdown3Text,
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.6)),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: SizedBox(
                                          height: 40.0,
                                          child: TextField(
                                            controller: _currentDeepTxt,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                                border: OutlineInputBorder()),
                                          ),
                                        )),
                                  ],
                                )
                              : Container(),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'สถานะแหล่งน้ำ',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              Expanded(
                                  flex: 7,
                                  child: SizedBox(
                                    height: 50.0,
                                    child: DropdownButton<String>(
                                      value: _waterLevelStatusValue,
                                      isExpanded: true,
                                      items: waterLevelStatusMapList
                                          .map((Map item) {
                                        return DropdownMenuItem<String>(
                                          value: item['Value'],
                                          child: Text(item['Label']),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _waterLevelStatusValue = value!;
                                        });
                                      },
                                    ),
                                  )),
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
                                  'วัตถุประสงค์',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              Expanded(
                                  flex: 7,
                                  child: SizedBox(
                                    height: 50.0,
                                    child: DropdownButton<String>(
                                      value: _objectiveValue,
                                      isExpanded: true,
                                      items:
                                          objectiveMapList.map((Objective map) {
                                        return DropdownMenuItem<String>(
                                          value: map.objectiveId,
                                          child: Text(map.objectiveName),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _objectiveValue = value!;
                                        });
                                      },
                                    ),
                                  )),
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
                                  'ความต้องการฟื้นฟู',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              Expanded(
                                  flex: 7,
                                  child: SizedBox(
                                    height: 50.0,
                                    child: DropdownButton<String>(
                                      value: _integrationValue,
                                      isExpanded: true,
                                      items: integrationMapList
                                          .map((Integration map) {
                                        return DropdownMenuItem<String>(
                                          value: map.integrationId,
                                          child: Text(map.integrationName),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _integrationValue = value!;
                                        });
                                      },
                                    ),
                                  )),
                            ],
                          ),
                          (_typeValue == '4')
                              ? const SizedBox(
                                  height: 10.0,
                                )
                              : const SizedBox(
                                  height: 0.0,
                                ),
                          (_typeValue == '4')
                              ? Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'ความเพียงพอของน้ำประปา',
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.6)),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: SizedBox(
                                          height: 50.0,
                                          child: DropdownButton<String>(
                                            value: _sufficientWatersStatusValue,
                                            isExpanded: true,
                                            items: sufficientWatersStatusMapList
                                                .map((Map item) {
                                              return DropdownMenuItem<String>(
                                                value: item['Value'],
                                                child: Text(item['Label']),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _sufficientWatersStatusValue =
                                                    value!;
                                              });
                                            },
                                          ),
                                        )),
                                  ],
                                )
                              : Container(),
                          (_typeValue != '4')
                              ? const SizedBox(
                                  height: 10.0,
                                )
                              : const SizedBox(
                                  height: 0.0,
                                ),
                          (_typeValue == '1' ||
                                  _typeValue == '2' ||
                                  _typeValue == '3')
                              ? Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'มีพอตลอดปี',
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.6)),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 7,
                                        child: SizedBox(
                                          height: 50.0,
                                          child: DropdownButton<String>(
                                            value: _watersStatusValue,
                                            isExpanded: true,
                                            items: watersStatusMapList
                                                .map((Map item) {
                                              return DropdownMenuItem<String>(
                                                value: item['Value'],
                                                child: Text(item['Label']),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _watersStatusValue = value!;
                                              });
                                            },
                                          ),
                                        )),
                                  ],
                                )
                              : Container(),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'หน่วยงานที่รับผิดชอบ',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              Expanded(
                                  flex: 7,
                                  child: SizedBox(
                                    height: 50.0,
                                    child: DropdownButton<String>(
                                      value: _providerValue.isNotEmpty
                                          ? _providerValue
                                          : null,
                                      isExpanded: true,
                                      items:
                                          providerMapList.map((Provider map) {
                                        return DropdownMenuItem<String>(
                                          value: map.providerId,
                                          child: Text(map.providerName),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _providerValue = value!;
                                        });
                                      },
                                    ),
                                  )),
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
                                  'วันที่คาดว่าน้ำจะหมด',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              Expanded(
                                  flex: 5,
                                  child: SizedBox(
                                    height: 40.0,
                                    child: TextField(
                                      controller: _depleteDateTxt,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 10.0),
                                          border: OutlineInputBorder()),
                                    ),
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 2.0),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(5.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          backgroundColor:
                                              const Color(0xFF55D2E3),
                                        ),
                                        onPressed: () {
                                          _selectDate(context);
                                        },
                                        child: Icon(
                                          Icons.calendar_today,
                                          color: Colors.white,
                                        )),
                                  )),
                            ],
                          ),
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
                          SizedBox(
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
                                  padding: const EdgeInsets.all(15.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: const Color(0xFF55D2E3),
                                ),
                                onPressed: () {
                                  _imgFromCamera();
                                }),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          SizedBox(
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
                                  padding: const EdgeInsets.all(15.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: const Color(0xFF55D2E3),
                                ),
                                onPressed: () {
                                  _imgFromGallery();
                                }),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  mode == 'E'
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
                                        padding: const EdgeInsets.all(15.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        backgroundColor: Colors.green[400],
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
                                        padding: const EdgeInsets.all(15.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        backgroundColor: Colors.red[400],
                                      ),
                                      onPressed: () {
                                        _createConfirmDeleteDialog(context);
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
                            padding: const EdgeInsets.all(15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.green[400],
                          ),
                          onPressed: () {
                            _saveButtonOnClick(context);
                          }),
                ],
              )),
        ));
  }

  _saveButtonOnClick(context) async {
    userTel = await _sharedPrefs.getValue(Global.KEY_USER_TEL) ?? "";

    _showSpinner();

    Waters waterForm = Waters(
        id: mode == "I" ? "" : Global.WATERS_ID,
        name: _nameTxt.text,
        total: "",
        typeId: _typeValue,
        detail: _detailTxt.text,
        integrationId: _integrationValue,
        sizeArea: _sizeAreaTxt.text,
        deep: _deepTxt.text,
        currentDeep: _currentDeepTxt.text,
        oldCurrentDeep: "",
        upToDate: "",
        oldDate: "",
        fullFill: _watersStatusValue,
        depleteDate: _depleteDateTxt.text,
        providerId: _providerValue,
        objectiveId: _objectiveValue,
        waterSupply: _watersStatusValue,
        waterLevel: _waterLevelStatusValue,
        waterLevelDisparity: "",
        sufficientWater: _sufficientWatersStatusValue,
        waterImage: _image != null
            ? base64Encode(_image!.readAsBytesSync())
            : (_base64String ?? ""),
        waterImageUrl: "",
        lat: mode == "I" ? '${Global.LAT_ADDRESS}' : lat,
        lng: mode == "I" ? '${Global.LNG_ADDRESS}' : lng);

    if (mode == "I") {
      WatersService.createWaters(waterForm).then((value) {
        Waters item = value;

        WatersUses watersUses = WatersUses(
            id: "",
            mooId: _findMooId(),
            waterId: item.id,
            userPhone: userTel,
            uptodate: "");

        // Create waters
        WatersService.createWatersUses(watersUses).then((value) {
          if (mounted) {
            Navigator.pop(context);
            Navigator.pop(context, true);
          }
        }).catchError((e) {
          print("❌ WatersService.createWatersUses error: $e");
        });
      });
    } else {
      // Update waters
      WatersService.updateWaters(waterForm).then((value) {
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context, true);
        }
      }).catchError((e) {
        print("❌ WatersService.updateWaters error: $e");
      });
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
            content: const Text("คุณต้องการลบแหล่งน้ำนี้หรือไม่?"),
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

                  WatersService.deleteWaters(Global.WATERS_ID).then((value) {
                    if (mounted) {
                      Navigator.pop(contextRoot, true);
                    }
                  }).catchError((e) {
                    print("❌ WatersService.deleteWaters error: $e");
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
