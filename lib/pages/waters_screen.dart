import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:osm2_app/models/waters.dart';
import 'package:osm2_app/services/waters_service.dart';
import 'package:osm2_app/utils/global.dart';
import 'package:osm2_app/utils/utils.dart';
import 'package:osm2_app/widgets/waters_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/shared_prefs.dart';

class WatersScreen extends StatefulWidget {
  const WatersScreen({super.key});

  static const String ROUTE_ID = 'waters_screen';

  @override
  WatersScreenState createState() => WatersScreenState();
}

class WatersScreenState extends State<WatersScreen> {
  final SharedPrefs _sharedPrefs = SharedPrefs.instance;

  late latLng.LatLng currentPosition =
      const latLng.LatLng(18.681452, 99.498509);
  late latLng.LatLng userPosition = const latLng.LatLng(18.681452, 99.498509);
  late MapController mapController;

  late List<Marker> markers;
  late List<Marker> markersTemp;
  late List<Waters> waterList;

  int currentWatersIndex = 0;
  int maxWatersIndex = 0;

  bool addFlag = false;
  bool tapFlag = false;
  double iconSize = 40.0;

  final _streamController = StreamController<double>();
  Stream<double> get onZoomChanged => _streamController.stream;

  String userTel = "";

  @override
  void initState() {
    super.initState();

    mapController = MapController();
    markers = [];
    markersTemp = [];
    waterList = [];

    initLoad();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  initLoad() async {
    userTel = await _sharedPrefs.getValue(Global.KEY_USER_TEL) ?? "";

    _getUserLocation().then((value) {
      if (mounted) {
        setState(() {
          userPosition = latLng.LatLng(value.latitude, value.longitude);
          currentPosition = latLng.LatLng(
              double.parse(Global.USER_LOCATION_LAT!),
              double.parse(Global.USER_LOCATION_LNG!));
          mapController.move(
              latLng.LatLng(double.parse(Global.USER_LOCATION_LAT!),
                  double.parse(Global.USER_LOCATION_LNG!)),
              15.0);
        });
      }
    }).catchError((e) {
      print("❌ getUserLocation error in waters_screen init: $e");
    });

    _initMapMarker();

    onZoomChanged.listen((event) {
      _resizeIcon(event);
    });
  }

  Future<Position> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  _createMarker(
      context, lat, lng, waterId, waterType, depleteDate, waterSupply) {
    var imgName = "";
    var imgPrefix = "";

    if (waterType == '4') {
      if (waterSupply == '1') {
        imgPrefix = "default";
      } else {
        imgPrefix = _calculateDepleteDateForMarker(depleteDate);
      }
    } else {
      imgPrefix = _calculateDepleteDateForMarker(depleteDate);
    }

    if (waterType == '1') {
      imgName = "marker-lake-$imgPrefix";
    } else if (waterType == '2') {
      imgName = "marker-ground-water-$imgPrefix";
    } else if (waterType == '3') {
      imgName = "marker-river-$imgPrefix";
    } else if (waterType == '4') {
      imgName = "marker-tap-water-$imgPrefix";
    } else {
      // imgName = "osm2-icon";
      imgName = "marker-lake-level-3";
    }

    return Marker(
      width: iconSize,
      height: iconSize,
      point: latLng.LatLng(lat, lng),
      child: GestureDetector(
        child: Image(
          image: AssetImage("lib/asset/imgs/$imgName.png"),
          height: 200,
          width: 200,
        ),
        onTap: () {
          _openWatersWidget(context, false, waterId);
        },
      ),
    );
  }

  _calculateDepleteDateForMarker(depleteDate) {
    if (depleteDate != "") {
      DateTime depDate = DateTime.parse(depleteDate);
      DateTime crrDate = DateTime.now();

      var difference = depDate.difference(crrDate).inDays;

      if (difference <= 7) {
        return "level-3";
      } else if (difference > 7 && difference <= 15) {
        return "level-2";
      } else if (difference > 15 && difference <= 30) {
        return "level-1";
      } else {
        return "default";
      }
    } else {
      return "default";
    }
  }

  _createUserMarker() {
    return Marker(
      width: iconSize,
      height: iconSize,
      point: userPosition,
      child: SizedBox(
          height: iconSize,
          width: iconSize,
          child: const Icon(
            Icons.my_location,
            color: Colors.blueAccent,
          )),
    );
  }

  _initMapMarker() async {
    await WatersService.findByUserPhone(userTel).then((value) {
      if (value.isNotEmpty) {
        if (mounted) {
          setState(() {
            waterList = value;

            print("waterList length ${waterList.length}");

            maxWatersIndex = waterList.length;
            currentWatersIndex = 0;

            for (var water in waterList) {
              markers.add(_createMarker(
                  context,
                  double.parse(water.lat),
                  double.parse(water.lng),
                  water.id,
                  water.typeId,
                  water.depleteDate,
                  water.sufficientWater));
            }
          });
        }
      } else {
        print("waters is null");
      }

      markers.add(_createUserMarker());
    }).catchError((e) {
      print("❌ WatersService.findByUserPhone error: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("รายงานข้อมูลแหล่งน้ำ"),
          backgroundColor: const Color(0xFF98CFE2),
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: latLng.LatLng(
                    currentPosition.latitude, currentPosition.longitude),
                initialZoom: 15.0,
                maxZoom: 18.0,
                onPositionChanged: (position, hasGesture) {
                  final zoom = position.zoom;
                  if (zoom != null) {
                    _streamController.sink.add(zoom);
                  }
                },
                onTap: (tapPosition, latlng) {
                  // if(addFlag){
                  //   _onTapNewMarker(latlng);
                  // }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}",
                  subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                ),
                MarkerLayer(
                  markers: markers,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      addFlag
                          ? ElevatedButton.icon(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'บันทึก',
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[500],
                                padding: const EdgeInsets.all(7.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _onTapNewMarker(mapController.camera.center);
                                });
                              })
                          : Container(),
                      !addFlag
                          ? ElevatedButton.icon(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'เพิ่มแหล่งน้ำใหม่',
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF55D2E3),
                                padding: const EdgeInsets.all(7.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  addFlag = true;

                                  markers = [];
                                  markersTemp = [];

                                  // create dialog
                                  _createNewWaterMarkerDialog();
                                });
                              })
                          : ElevatedButton.icon(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'ยกเลิก',
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[500],
                                padding: const EdgeInsets.all(7.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  addFlag = false;

                                  _initMapMarker();
                                });
                              }),
                      ElevatedButton.icon(
                          icon: const Icon(
                            Icons.web,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'เปิดเว็บไซต์',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.0,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[500],
                            padding: const EdgeInsets.all(7.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            launch(
                                "http://vlg-water-r.disaster.go.th/osm2rain/#/waters-graph");
                          }),
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: "btn1",
                        onPressed: () {
                          _changeToWatersPosition();
                        },
                        child: const Icon(Icons.waves),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      FloatingActionButton(
                        heroTag: "btn2",
                        onPressed: () {
                          _changeToCurrentLocation();
                        },
                        child: const Icon(Icons.my_location),
                      )
                    ],
                  )),
            ),
            addFlag
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          height: iconSize,
                          width: iconSize,
                          child: const Icon(
                            Icons.add_location,
                            color: Colors.redAccent,
                            size: 30.0,
                          ),
                        ),
                      )
                    ],
                  )
                : Container()
          ],
        ));
  }

  _openWatersWidget(context, newWatersFlag, waterId) async {
    Global.NEW_WATERS_FLAG = newWatersFlag;
    Global.WATERS_ID = waterId;

    await Navigator.pushNamed(context, WatersWidget.ROUTE_ID).then((value) {
      if (value == null && Global.NEW_WATERS_FLAG) {
        if (mounted) {
          setState(() {
            markers.removeLast();
          });
        }
      } else if (value == true) {
        if (mounted) {
          setState(() {
            markers = [];
            markersTemp = [];
            waterList = [];
          });
          Utils.createToast("ประมวลผลสำเร็จ!");
        }
      }

      addFlag = false;
      Timer(const Duration(seconds: 1), () {
        _initMapMarker();
      });
    });
  }

  _onTapNewMarker(point) {
    setState(() {
      if (markersTemp.isNotEmpty) {
        markers.removeLast();
      } else {
        markersTemp = [];
        markersTemp.add(_createMarker(
            context, point.latitude, point.longitude, "", "", "", ""));
      }

      // onTap
      tapFlag = true;
      Global.LAT_ADDRESS = point.latitude;
      Global.LNG_ADDRESS = point.longitude;

      markers.add(_createMarker(
          context, point.latitude, point.longitude, "", "", "", ""));

      _onSaveNewMarker();
    });
  }

  _onSaveNewMarker() {
    if (!tapFlag) {
      Utils.createToast("กรุณาเลือกหมุดก่อน!");
    } else {
      setState(() {
        markersTemp = [];
        tapFlag = false;
      });

      _openWatersWidget(context, true, "");
    }
  }

  _resizeIcon(double zoom) {
    setState(() {
      if (zoom > 1.0 && zoom <= 3.0) {
        iconSize = 5.0;
      } else if (zoom > 3.0 && zoom <= 6.0) {
        iconSize = 10.0;
      } else if (zoom > 6.0 && zoom <= 9.0) {
        iconSize = 20.0;
      } else if (zoom > 9.0 && zoom <= 12.0) {
        iconSize = 30.0;
      } else if (zoom > 12.0 && zoom <= 15.0) {
        iconSize = 40.0;
      } else if (zoom > 15.0 && zoom <= 18.0) {
        iconSize = 50.0;
      } else if (zoom > 18.0 && zoom <= 20.0) {
        iconSize = 60.0;
      }
    });
  }

  _createNewWaterMarkerDialog() {
    markers.add(_createUserMarker());

    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text("คำแนะนำ"),
            content: const Text(
                "กรุณาเลื่อนหมุดไปยังตำแหน่งที่ต้องการ เพื่อเพิ่มแหล่งน้ำใหม่"),
            actions: <Widget>[
              TextButton(
                child: const Text('ปิด', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ]);
      },
    );
  }

  _changeToCurrentLocation() {
    _getUserLocation().then((value) {
      if (mounted) {
        setState(() {
          currentPosition = latLng.LatLng(value.latitude, value.longitude);
          mapController.move(
              latLng.LatLng(value.latitude, value.longitude), 15.0);
        });
      }
    }).catchError((e) {
      print("❌ getUserLocation error in _changeToCurrentLocation: $e");
    });
  }

  _changeToWatersPosition() {
    if (waterList.isNotEmpty) {
      setState(() {
        if (currentWatersIndex == maxWatersIndex) {
          currentWatersIndex = 0;
        }

        currentPosition = latLng.LatLng(
            double.parse(waterList[currentWatersIndex].lat),
            double.parse(waterList[currentWatersIndex].lng));
        mapController.move(
            latLng.LatLng(double.parse(waterList[currentWatersIndex].lat),
                double.parse(waterList[currentWatersIndex].lng)),
            15.0);

        currentWatersIndex++;
      });
    } else {
      Utils.createToast("ไม่พบข้อมูลแหล่งน้ำ!");
    }
  }
}
