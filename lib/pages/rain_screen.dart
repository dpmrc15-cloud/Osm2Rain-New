import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:osm2_app/models/rain_history.dart';
import 'package:osm2_app/services/rain_service.dart';
import 'package:osm2_app/utils/global.dart';
import 'package:osm2_app/utils/utils.dart';
import 'package:osm2_app/widgets/rain_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/shared_prefs.dart';

class RainScreen extends StatefulWidget {
  const RainScreen({super.key});

  static const String ROUTE_ID = 'rain_screen';

  @override
  RainScreenState createState() => RainScreenState();
}

class RainScreenState extends State<RainScreen> {
  final SharedPrefs _sharedPrefs = SharedPrefs.instance;

  late latLng.LatLng currentPosition =
      const latLng.LatLng(18.681452, 99.498509);
  late latLng.LatLng userPosition = const latLng.LatLng(18.681452, 99.498509);
  late MapController mapController;

  late List<Marker> markers;
  late List<Marker> markersTemp;
  late List<Marker> markersLimit;
  late List<RainHistory> rainList;

  RainHistory? rainHistory;

  bool tapAddFlag = false;
  bool canAddFlag = false;
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
    markersLimit = [];
    rainList = [];

    initLoad();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  initLoad() async {
    userTel = await _sharedPrefs.getValue(Global.KEY_USER_TEL) ?? "";

    _checkAddFlag();

    _getUserLocation().then((value) {
      setState(() {
        userPosition = latLng.LatLng(value.latitude, value.longitude);
        currentPosition = latLng.LatLng(
          double.parse(Global.USER_LOCATION_LAT ?? value.latitude.toString()),
          double.parse(Global.USER_LOCATION_LNG ?? value.longitude.toString()),
        );
        mapController.move(currentPosition, 15.0);
      });
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

  _checkAddFlag() async {
    await RainService.findByUserPhone(userTel).then((value) {
      if (value.isNotEmpty) {
        if (mounted) {
          setState(() {
            rainHistory = value.first;
            canAddFlag = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            canAddFlag = true;
          });
        }
      }
    }).catchError((e) {
      print("❌ RainService.findByUserPhone error: $e");
    });
  }

  _createMarker(context, double lat, double lng, String rainId,
      String userPhone, String? rainAllDay) {
    var imgName = "marker-gray";
    var sumRain = 0.0;
/*
    if (rainAllDay != null && rainAllDay != "") {
      sumRain = double.tryParse(rainAllDay) ?? 0.0;
*/
    // ✅ Debug ค่า rainAllDay
    debugPrint("DEBUG rainAllDay for rainId=$rainId : ${rainAllDay ?? 'NULL'}");

    if (rainAllDay != null && rainAllDay.trim().isNotEmpty) {
      sumRain = double.tryParse(rainAllDay.trim()) ?? 0.0;
      debugPrint("DEBUG parsed sumRain=$sumRain");

/*
      if (sumRain == 0.0) {
        imgName = "marker-gray";
      } else if (sumRain > 0.0 && sumRain <= 49.9) {
              imgName = "marker-rain-default";
      } else if (sumRain > 49.9 && sumRain <= 99.9) {
        imgName = "marker-rain-level-1";
      } else if (sumRain > 99.9 && sumRain <= 149.9) {
        imgName = "marker-rain-level-2";
      } else if (sumRain > 149.9) {
        imgName = "marker-rain-level-3";
      }
    } else {
      imgName = "marker-gray";
    }
*/
      if (sumRain > 0.0 && sumRain <= 49.9) {
        imgName = "marker-rain-default";
      } else if (sumRain > 49.9 && sumRain <= 99.9) {
        imgName = "marker-rain-level-1";
      } else if (sumRain > 99.9 && sumRain <= 149.9) {
        imgName = "marker-rain-level-2";
      } else if (sumRain > 149.9) {
        imgName = "marker-rain-level-3";
      }
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
          if (userPhone == userTel) {
            Global.BTN_RAIN_FLAG = true;
          } else {
            Global.BTN_RAIN_FLAG = false;
          }

          // ส่ง rainId ไปให้ RainWidget ใช้ดึงปริมาณน้ำฝนสะสม
          _openRainWidget(context, false, rainId);
        },
      ),
    );
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

  _initMapMarker({bool forceRefresh = false}) async {
    var dateFormatter = DateFormat('yyyy-MM-dd');
    var dateString = dateFormatter.format(DateTime.now());

    await RainService.findByToDayAndCurrentUser(dateString, userTel)
        .then((value) {
      if (mounted) {
        setState(() {
          if (forceRefresh) {
            markers.clear();
            markersTemp.clear();
            markersLimit.clear();
          }

          rainList = value;

          Set<String> seenRainIds = {};

          for (var rain in rainList) {
            final latStr = (rain.lat ?? "").trim();
            final lngStr = (rain.lng ?? "").trim();

            if (latStr.isEmpty || lngStr.isEmpty) continue;

            final lat = double.tryParse(latStr);
            final lng = double.tryParse(lngStr);

            if (lat == null || lng == null) continue;

            if (seenRainIds.contains(rain.rainId)) continue;
            seenRainIds.add(rain.rainId);

            markers.add(_createMarker(context, lat, lng, rain.rainId,
                rain.userPhone, rain.allDayRainfall));
          }
          // user marker
          markers.add(_createUserMarker());
        });
      }
    }).catchError((e) {
      print("❌ RainService.findByToDayAndCurrentUser error: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("รายงานข้อมูลน้ำฝน"),
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
                onTap: (tapPosition, point) {
                  // ถ้าจะใช้ tapAddFlag + การเพิ่มหมุดใหม่ผ่านการแตะจอ
                  // สามารถเรียก _onTapNewMarker(point) ตรงนี้ได้
                  if (canAddFlag && tapAddFlag) {
                    _onTapNewMarker(point);
                  }
                },
              ),
              children: [
                TileLayer(
                    urlTemplate:
                        "https://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}",
                    subdomains: const ['mt0', 'mt1', 'mt2', 'mt3']),
                MarkerLayer(markers: markers),
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
                    (canAddFlag && tapAddFlag)
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
                    (canAddFlag && !tapAddFlag)
                        ? Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'เพิ่มน้ำฝนใหม่',
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
                                      tapAddFlag = true;

                                      markers = [];
                                      markersTemp = [];

                                      // create dialog
                                      _createNewRainMarkerDialog();
                                    });
                                  }),
                            ),
                          )
                        : Container(),
                    (canAddFlag && tapAddFlag)
                        ? Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton.icon(
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
                                      tapAddFlag = false;

                                      _initMapMarker();
                                    });
                                  }),
                            ),
                          )
                        : Container(),
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
                              "http://vlg-water-r.disaster.go.th/osm2rain/#/rain-map");
                        }),
                  ],
                ),
              ),
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
                          _changeToRainPosition();
                        },
                        child: const Icon(Icons.cloud),
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
            (canAddFlag && tapAddFlag)
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

  _openRainWidget(context, newRainFlag, rainId) async {
    Global.NEW_RAIN_FLAG = newRainFlag;
    Global.RAIN_ID = rainId;

    await Navigator.pushNamed(context, RainWidget.ROUTE_ID).then((value) {
      if (value == null && Global.NEW_RAIN_FLAG) {
        if (mounted) {
          setState(() {
            if (markers.isNotEmpty) {
              markers.removeLast();
            }
          });
        }
      } else if (value == true) {
        if (mounted) {
          setState(() {
            markers = [];
            markersTemp = [];
            rainList = [];
          });
          Utils.createToast("ประมวลผลสำเร็จ!");
        }
      }

      tapAddFlag = false;
      Timer(const Duration(seconds: 1), () {
        _checkAddFlag();
        _initMapMarker();
      });
    });
  }

  _onTapNewMarker(latLng.LatLng point) {
    setState(() {
      if (markersTemp.isNotEmpty) {
        markers.removeLast();
      } else {
        markersTemp = [];
        markersTemp.add(_createMarker(
            context, point.latitude, point.longitude, "", "", ""));
      }

      // onTap
      tapFlag = true;
      Global.LAT_ADDRESS = point.latitude;
      Global.LNG_ADDRESS = point.longitude;

      markers.add(
          _createMarker(context, point.latitude, point.longitude, "", "", ""));

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

      _openRainWidget(context, true, "");
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

  _createNewRainMarkerDialog() {
    markers.add(_createUserMarker());

    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text("คำแนะนำ"),
            content: const Text(
                "กรุณาเลื่อนหมุดไปยังตำแหน่งที่ต้องการ เพื่อเพิ่มน้ำฝนใหม่"),
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

  _changeToRainPosition() {
    if (rainHistory != null &&
        (rainHistory!.lat ?? "").isNotEmpty &&
        (rainHistory!.lng ?? "").isNotEmpty) {
      final lat = double.tryParse(rainHistory!.lat!);
      final lng = double.tryParse(rainHistory!.lng!);

      if (lat != null && lng != null) {
        setState(() {
          currentPosition = latLng.LatLng(lat, lng);
          mapController.move(latLng.LatLng(lat, lng), 15.0);
        });
      } else {
        Utils.createToast("ตำแหน่งน้ำฝนไม่ถูกต้อง!");
      }
    } else {
      Utils.createToast("ไม่พบข้อมูลน้ำฝน!");
    }
  }
}
