import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:geolocator/geolocator.dart';
import 'package:osm2_app/utils/global.dart';
// import 'package:osm2_app/utils/utils.dart'; // TODO: unused import

class VillageEditWidget extends StatefulWidget {
  const VillageEditWidget({super.key});

  static const String ROUTE_ID = 'village_edit_widget';

  @override
  VillageEditWidgetState createState() => VillageEditWidgetState();
}

class VillageEditWidgetState extends State<VillageEditWidget> {
  late latLng.LatLng currentPosition =
      const latLng.LatLng(18.681452, 99.498509);

  late final MapController mapController;

  @override
  void initState() {
    super.initState();

    mapController = MapController();

    _getUserLocation().then((value) {
      if (mounted) {
        setState(() {
          currentPosition = latLng.LatLng(
            double.parse(Global.USER_LOCATION_LAT!),
            double.parse(Global.USER_LOCATION_LNG!),
          );
          mapController.move(currentPosition, 15.0);
        });
      }
    }).catchError((e) {
      print("❌ getUserLocation error in village_edit_widget init: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("พิกัดหมู่บ้าน"),
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
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}",
                subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
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
                  if (mounted) {
                    final selectedPosition = mapController.camera.center;
                    Navigator.pop(context, selectedPosition);
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                onPressed: () {
                  _changeToCurrentLocation();
                },
                child: const Icon(Icons.my_location),
              ),
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  height: 40.0,
                  width: 40.0,
                  child: Icon(
                    Icons.add_location,
                    color: Colors.redAccent,
                    size: 30.0,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _changeToCurrentLocation() {
    _getUserLocation().then((value) {
      if (mounted) {
        setState(() {
          currentPosition = latLng.LatLng(value.latitude, value.longitude);
          mapController.move(currentPosition, 15.0);
        });
      }
    }).catchError((e) {
      print("❌ getUserLocation error in village_edit_widget: $e");
    });
  }
}
