import 'package:flutter/material.dart';
import 'package:osm2_app/models/address.dart';
import 'package:osm2_app/models/amphur.dart';
import 'package:osm2_app/models/moo.dart';
import 'package:osm2_app/models/province.dart';
import 'package:osm2_app/models/tambon.dart';
import 'package:osm2_app/models/users.dart';

import 'package:osm2_app/services/address_service.dart';
import 'package:osm2_app/services/users_service.dart';
import 'package:osm2_app/utils/global.dart';
import 'package:osm2_app/utils/utils.dart';

import '../utils/shared_prefs.dart';

class VillageSettingScreen extends StatefulWidget {
  const VillageSettingScreen({super.key});

  static const String ROUTE_ID = 'village_setting_screen';

  @override
  _VillageSettingScreenState createState() => _VillageSettingScreenState();
}

class _VillageSettingScreenState extends State<VillageSettingScreen> {
  final SharedPrefs _sharedPrefs = SharedPrefs.instance;

  late String _provinceValue = '00';
  late String _amphurValue = '0000';
  late String _tambonValue = '000000';
  late String _mooValue = '';

  List<Province> provinceMapList = [];
  List<Amphur> amphurMapList = [];
  List<Tambon> tambonMapList = [];
  List<Moo> mooMapList = [];

  late bool mudFlag = false;
  late bool cataractFlag = false;
  late bool landslideFlag = false;
  late bool wildfireFlag = false;
  late bool droughtFlag = false;
  late bool earthquakeFlag = false;

  bool createFlag = true;

  String userTel = "";

  @override
  void initState() {
    super.initState();

    if (!Utils.isNullOrEmpty(Global.PROVINCE_CODE)) {
      setState(() {
        _provinceValue = Global.PROVINCE_CODE!;
        _amphurValue = Global.AMPHUR_CODE!;
        _tambonValue = Global.TUMBON_CODE!;
        _mooValue = Global.MOO!;
      });

      _initProvinceList();

      AddressService.findAmphurByProvince(_provinceValue).then((value) {
        if (value.isNotEmpty) {
          setState(() {
            amphurMapList = value;
          });
        } else {
          print("No amphur data");
        }
      }).catchError((e) {
        print("❌ AddressService.findAmphurByProvince error: $e");
      });

      AddressService.findtambonByProvinceAndAmphurCode(
              _provinceValue, _amphurValue)
          .then((value) {
        if (value.isNotEmpty) {
          setState(() {
            tambonMapList = value;
          });
        } else {
          print("No tambon data");
        }
      }).catchError((e) {
        print("❌ AddressService.findtambonByProvinceAndAmphurCode error: $e");
      });

      AddressService.findMooByProvinceAndAmphurAndTambonCode(
              _provinceValue, _amphurValue, _tambonValue)
          .then((value) {
        if (value.isNotEmpty) {
          setState(() {
            mooMapList = value;
          });
        } else {
          print("No moo data");
        }
      }).catchError((e) {
        print(
            "❌ AddressService.findMooByProvinceAndAmphurAndTambonCode error: $e");
      });

      _checkProvinceIsNotNull();

      createFlag = false;
    } else {
      _initProvinceList();

      createFlag = true;
    }
  }

  _checkProvinceIsNotNull() {
    if (Utils.isNullOrEmpty(Global.PROVINCE_CODE)) {
      Utils.createToast("กรุณาตั้งค่าหมู่บ้านก่อน");
    } else {
      AddressService.findUserAddress(Global.PROVINCE_CODE!, Global.AMPHUR_CODE!,
              Global.TUMBON_CODE!, Global.MOO!)
          .then((value) {
        if (value.isNotEmpty) {
          if (mounted) {
            setState(() {
              Address addressObj = value.first;

              if (addressObj.mudFlag == '1') {
                mudFlag = true;
              }
              if (addressObj.cataractFlag == '1') {
                cataractFlag = true;
              }
              if (addressObj.wildfireFlag == '1') {
                wildfireFlag = true;
              }
              if (addressObj.droughtFlag == '1') {
                droughtFlag = true;
              }
              if (addressObj.landslideFlag == '1') {
                landslideFlag = true;
              }
              if (addressObj.earthquakeFlag == '1') {
                earthquakeFlag = true;
              }
            });
          }
        } else {
          print("No address data");
        }
      }).catchError((e) {
        print("❌ AddressService.findUserAddress error: $e");
      });
    }
  }

  _initProvinceList() {
    AddressService.findAllProvince().then((value) {
      if (value.isNotEmpty) {
        if (mounted) {
          setState(() {
            provinceMapList = value;
            provinceMapList.add(Province(provId: '00', provName: ''));
          });
        }
      } else {
        print("No province data");
      }
    }).catchError((e) {
      print("❌ AddressService.findAllProvince error: $e");
    });
  }

  _loadAmphurList() {
    AddressService.findAmphurByProvince(_provinceValue).then((value) {
      if (value.isNotEmpty) {
        if (mounted) {
          setState(() {
            amphurMapList = value;
            amphurMapList.add(Amphur(ampId: '0000', ampName: ''));

            _amphurValue = '0000';
          });
        }
      } else {
        print("No amphur data");
      }
    }).catchError((e) {
      print("❌ AddressService.findAmphurByProvince error: $e");
    });
  }

  _loadTambonList() {
    AddressService.findtambonByProvinceAndAmphurCode(
            _provinceValue, _amphurValue)
        .then((value) {
      if (value.isNotEmpty) {
        if (mounted) {
          setState(() {
            tambonMapList = value;
            tambonMapList.add(Tambon(tamId: '000000', tamName: ''));

            _tambonValue = '000000';
          });
        }
      } else {
        print("No tambon data");
      }
    }).catchError((e) {
      print("❌ AddressService.findtambonByProvinceAndAmphurCode error: $e");
    });
  }

  _loadMooList() {
    AddressService.findMooByProvinceAndAmphurAndTambonCode(
            _provinceValue, _amphurValue, _tambonValue)
        .then((value) {
      if (value.isNotEmpty) {
        if (mounted) {
          setState(() {
            mooMapList = value;
            mooMapList.add(Moo(mooId: '', moo: '', mooName: ''));

            _mooValue = '';
          });
        }
      } else {
        print("No moo data");
      }
    }).catchError((e) {
      print(
          "❌ AddressService.findMooByProvinceAndAmphurAndTambonCode error: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ตั้งค่าหมู่บ้าน"),
        backgroundColor: const Color(0xFF98CFE2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("จังหวัด",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black.withOpacity(0.6)))
                ],
              ),
              DropdownButton<String>(
                value: _provinceValue.isNotEmpty ? _provinceValue : null,
                isExpanded: true,
                items: provinceMapList.map((Province map) {
                  return DropdownMenuItem<String>(
                    value: map.provId,
                    child: Text(map.provName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _provinceValue = value!;
                    _loadAmphurList();

                    _tambonValue = '000000';
                    _mooValue = '00';

                    tambonMapList = [];
                    mooMapList = [];
                  });
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("อำเภอ",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black.withOpacity(0.6)))
                ],
              ),
              DropdownButton<String>(
                value: _amphurValue.isNotEmpty ? _amphurValue : null,
                isExpanded: true,
                items: amphurMapList.map((Amphur map) {
                  return DropdownMenuItem<String>(
                    value: map.ampId,
                    child: Text(map.ampName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _amphurValue = value!;
                    _loadTambonList();

                    _mooValue = '00';

                    mooMapList = [];
                  });
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("ตำบล",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black.withOpacity(0.6)))
                ],
              ),
              DropdownButton<String>(
                value: _tambonValue.isNotEmpty ? _tambonValue : null,
                isExpanded: true,
                items: tambonMapList.map((Tambon map) {
                  return DropdownMenuItem<String>(
                    value: map.tamId,
                    child: Text(map.tamName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tambonValue = value!;
                    _loadMooList();
                  });
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("หมู่ที่",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black.withOpacity(0.6)))
                ],
              ),
              DropdownButton<String>(
                value: _mooValue.isNotEmpty ? _mooValue : null,
                isExpanded: true,
                items: mooMapList.map((Moo map) {
                  return DropdownMenuItem<String>(
                    value: map.moo,
                    child: Text(map.moo),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _mooValue = value!;
                  });
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                'ภัยประจำหมู่บ้าน',
                style: TextStyle(
                    color: Colors.black.withOpacity(0.6), fontSize: 20.0),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  Checkbox(
                    value: mudFlag,
                    onChanged: (value) {
                      setState(() {
                        mudFlag = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'น้ำป่าไหลหลาก/ดินโคล่นถล่ม',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: cataractFlag,
                    onChanged: (value) {
                      setState(() {
                        cataractFlag = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'น้ำท่วม/น้ำล้นตลิ่ง',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: landslideFlag,
                    onChanged: (value) {
                      setState(() {
                        landslideFlag = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'ดินสไลด์/ดินถล่ม',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: wildfireFlag,
                    onChanged: (value) {
                      setState(() {
                        wildfireFlag = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'ไฟป่า/หมอกควัน',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: droughtFlag,
                    onChanged: (value) {
                      setState(() {
                        droughtFlag = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'ภัยแล้ง',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: earthquakeFlag,
                    onChanged: (value) {
                      setState(() {
                        earthquakeFlag = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'แผนดินไหว',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              ElevatedButton.icon(
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
            ],
          ),
        ),
      ),
    );
  }

  _saveButtonOnClick(context) async {
    userTel = await _sharedPrefs.getValue(Global.KEY_USER_TEL) ?? "";

    if (provinceMapList.isEmpty ||
        amphurMapList.isEmpty ||
        tambonMapList.isEmpty ||
        mooMapList.isEmpty) {
      Utils.createToast("กรุณากรอกข้อมูลให้ครบถ้วน");
    } else {
      Users item = Users(
          userTel: userTel,
          provId: _provinceValue,
          ampId: _amphurValue,
          tamId: _tambonValue,
          mooId: findMoo(_mooValue).mooId,
          moo: _mooValue);

      if (createFlag) {
        UsersService.createUser(item);
      } else {
        UsersService.updateUser(item);
      }

      setState(() {
        Global.PROVINCE_CODE = _provinceValue;
        Global.AMPHUR_CODE = _amphurValue;
        Global.TUMBON_CODE = _tambonValue;
        Global.MOO = _mooValue;

        Global.PROVINCE_NAME = findProvince(_provinceValue).provName;
        Global.AMPHUR_NAME = findAmphur(_amphurValue).ampId;
        Global.TUMBON_NAME = findTambon(_tambonValue).tamId;
        Global.MOO_NAME = findMoo(_mooValue).mooName;
        Global.MOO_CODE = findMoo(_mooValue).mooId;

        AddressService.findUserAddress(
                _provinceValue, _amphurValue, _tambonValue, _mooValue)
            .then((value) {
          if (value.isNotEmpty) {
            if (mounted) {
              setState(() {
                Address addressObj = value.first;

                Global.USER_LOCATION_LAT = addressObj.lat;
                Global.USER_LOCATION_LNG = addressObj.lng;
              });
            }
          } else {
            print("No address data");
          }
        }).catchError((e) {
          print("❌ AddressService.findUserAddress error: $e");
        });
      });

      Address addressItem = Address(
        id: "",
        provId: _provinceValue,
        provName: "",
        ampId: _amphurValue,
        ampName: "",
        tamId: _tambonValue,
        tamName: "",
        mooId: "",
        moo: _mooValue,
        mooName: "",
        female: "",
        male: "",
        total: "",
        houseHold: "",
        currentFemale: "",
        currentMale: "",
        currentTotal: "",
        currentHousehold: "",
        lat: "",
        lng: "",
        remark: "",
        contact: "",
        mudFlag: mudFlag ? '1' : '0',
        cataractFlag: cataractFlag ? '1' : '0',
        wildfireFlag: wildfireFlag ? '1' : '0',
        droughtFlag: droughtFlag ? '1' : '0',
        landslideFlag: landslideFlag ? '1' : '0',
        earthquakeFlag: earthquakeFlag ? '1' : '0',
      );

      AddressService.updateVillageEditByPATM(addressItem);

      Utils.createToast("บันทึกสำเร็จ!");
      Navigator.pop(context);
    }
  }

  Province findProvince(String id) =>
      provinceMapList.firstWhere((prov) => prov.provId == id);

  Amphur findAmphur(String id) =>
      amphurMapList.firstWhere((amp) => amp.ampId == id);

  Tambon findTambon(String id) =>
      tambonMapList.firstWhere((tam) => tam.tamId == id);

  Moo findMoo(String id) => mooMapList.firstWhere((moo) => moo.moo == id);
}
