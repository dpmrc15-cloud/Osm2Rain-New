import 'package:flutter/material.dart';
import 'package:osm2_app/models/address.dart';
import 'package:osm2_app/services/address_service.dart';
import 'package:osm2_app/utils/global.dart';
import 'package:osm2_app/utils/utils.dart';
import 'package:osm2_app/widgets/village_edit_widget.dart';
import 'package:latlong2/latlong.dart' as latLng;

class VillageEditScreen extends StatefulWidget {
  const VillageEditScreen({super.key});

  static const String ROUTE_ID = 'village_edit_screen';

  @override
  _VillageEditScreenState createState() => _VillageEditScreenState();
}

class _VillageEditScreenState extends State<VillageEditScreen> {
  late bool mudFlag = false;
  late bool cataractFlag = false;
  late bool landslideFlag = false;
  late bool wildfireFlag = false;
  late bool droughtFlag = false;
  late bool earthquakeFlag = false;

  String maleText = '';
  String femaleText = '';
  String totalText = '';
  String houseHoldText = '';
  String latText = '';
  String lngText = '';
  String addressId = '';

  late TextEditingController _maleTxt;
  late TextEditingController _femaleTxt;
  late TextEditingController _houseHoldTxt;
  late TextEditingController _villageNameTxt;
  late TextEditingController _remarkTxt;
  late TextEditingController _locationTxt;

  @override
  void initState() {
    super.initState();

    _maleTxt = TextEditingController();
    _femaleTxt = TextEditingController();
    _houseHoldTxt = TextEditingController();
    _villageNameTxt = TextEditingController();
    _remarkTxt = TextEditingController();
    _locationTxt = TextEditingController();

    _checkProvinceIsNotNull();
  }

  _checkProvinceIsNotNull() {
    if (Utils.isNullOrEmpty(Global.PROVINCE_CODE)) {
      Utils.createToast("กรุณาตั้งค่าหมู่บ้านก่อน");
    } else {
      AddressService.findUserAddress(Global.PROVINCE_CODE!, Global.AMPHUR_CODE!,
              Global.TUMBON_CODE!, Global.MOO!)
          .then((value) {
        if (value.isNotEmpty) {
          setState(() {
            Address addressObj = value.first;

            maleText = addressObj.male;
            femaleText = addressObj.female;
            totalText = addressObj.total;
            houseHoldText = addressObj.houseHold;

            _maleTxt.text = addressObj.male;
            _femaleTxt.text = addressObj.female;
            _houseHoldTxt.text = addressObj.houseHold;

            _villageNameTxt.text = addressObj.mooName;
            _remarkTxt.text = addressObj.remark;
            _locationTxt.text = '${addressObj.lat}, ${addressObj.lng}';

            latText = addressObj.lat;
            lngText = addressObj.lng;
            addressId = addressObj.id;

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
        } else {
          print("No address data");
        }
      }).catchError((e) {
        print("❌ AddressService.findUserAddress error: $e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("แก้ไขข้อมูลหมู่บ้าน"),
        backgroundColor: const Color(0xFF98CFE2),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.article),
                    title: Text('ข้อมูลที่ตั้งค่าไว้'),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'รหัสหมู่บ้าน: ${Global.MOO_CODE ?? ""}',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                      Text(
                        'หมู่บ้าน: ${Global.MOO ?? ""}',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                      Text(
                        'แขวง/ตำบล: ${Global.TUMBON_NAME ?? ""}',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                      Text(
                        'เขต/อำเภอ: ${Global.AMPHUR_NAME ?? ""}',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                      Text(
                        'จังหวัด: ${Global.PROVINCE_NAME ?? ""}',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                      const SizedBox(
                        height: 10.0,
                      )
                    ],
                  ),
                ],
              ),
            )),
            Card(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.article),
                    title: Text('จำนวนประชากรในหมู่บ้านล่าสุด'),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ชาย: $maleText',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                      Text(
                        'หญิง: $femaleText',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                      Text(
                        'จำนวนประชากรทั้งหมด: $totalText',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                      Text(
                        'จำนวนครัวเรือน: $houseHoldText',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                      const SizedBox(
                        height: 10.0,
                      )
                    ],
                  )
                ],
              ),
            )),
            Card(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.article),
                    title: Text('จำนวนประชากรในหมู่บ้านปัจจุบัน'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'ชาย',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      Expanded(
                          flex: 8,
                          child: SizedBox(
                            height: 40.0,
                            child: TextField(
                              controller: _maleTxt,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0),
                                  border: OutlineInputBorder()),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'หญิง',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      Expanded(
                          flex: 8,
                          child: SizedBox(
                            height: 40.0,
                            child: TextField(
                              controller: _femaleTxt,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0),
                                  border: OutlineInputBorder()),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'จำนวนครัวเรือน',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      Expanded(
                          flex: 8,
                          child: SizedBox(
                            height: 40.0,
                            child: TextField(
                              controller: _houseHoldTxt,
                              keyboardType: TextInputType.number,
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
                  )
                ],
              ),
            )),
            Card(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.article),
                    title: Text('ข้อมูลทั่วไป'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'ชื่อหมู่บ้าน',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      Expanded(
                          flex: 8,
                          child: SizedBox(
                            height: 40.0,
                            child: TextField(
                              controller: _villageNameTxt,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0),
                                  border: OutlineInputBorder()),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'หมายเหตุ',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      Expanded(
                          flex: 8,
                          child: SizedBox(
                            height: 40.0,
                            child: TextField(
                              controller: _remarkTxt,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0),
                                  border: OutlineInputBorder()),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'พิกัดหมู่บ้าน',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      Expanded(
                          flex: 6,
                          child: SizedBox(
                            height: 40.0,
                            child: TextField(
                              controller: _locationTxt,
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
                                  backgroundColor: const Color(0xFF55D2E3),
                                  padding: const EdgeInsets.all(5.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  _openMapWidget(context);
                                },
                                child: Icon(
                                  Icons.add_location,
                                  color: Colors.white,
                                )),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: Text(
                      'ภัยประจำหมู่บ้าน',
                      style: TextStyle(
                          color: Colors.black.withOpacity(1.0), fontSize: 20.0),
                    ),
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
                ],
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
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
          ],
        ),
      ),
    );
  }

  _saveButtonOnClick(context) {
    Address item = Address(
      id: addressId,
      provId: "",
      provName: "",
      ampId: "",
      ampName: "",
      tamId: "",
      tamName: "",
      mooId: "",
      moo: "",
      mooName: _villageNameTxt.text,
      female: _femaleTxt.text,
      male: _maleTxt.text,
      total: "",
      houseHold: _houseHoldTxt.text,
      currentFemale: "",
      currentMale: "",
      currentTotal: "",
      currentHousehold: "",
      lat: latText,
      lng: lngText,
      remark: _remarkTxt.text,
      contact: "",
      mudFlag: mudFlag ? '1' : '0',
      cataractFlag: cataractFlag ? '1' : '0',
      wildfireFlag: wildfireFlag ? '1' : '0',
      droughtFlag: droughtFlag ? '1' : '0',
      landslideFlag: landslideFlag ? '1' : '0',
      earthquakeFlag: earthquakeFlag ? '1' : '0',
    );

    AddressService.updateVillageEdit(item);

    Utils.createToast("บันทึกสำเร็จ!");
    Navigator.pop(context);
  }

  _openMapWidget(context) async {
    await Navigator.pushNamed(context, VillageEditWidget.ROUTE_ID)
        .then((value) {
      setState(() {
        if (value != null) {
          latLng.LatLng position = value as latLng.LatLng;
          _locationTxt.text = '${position.latitude}, ${position.longitude}';

          latText = '${position.latitude}';
          lngText = '${position.longitude}';
        } else {
          print("position is null");
        }
      });
    });
  }
}
