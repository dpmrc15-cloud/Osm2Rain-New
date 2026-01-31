import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:marquee/marquee.dart';
import 'package:geolocator/geolocator.dart';

import 'package:osm2_app/pages/login_screen.dart';
import 'package:osm2_app/utils/global.dart';
import 'package:osm2_app/utils/utils.dart';
import '../utils/shared_prefs.dart';
import '../services/air_quality_service.dart';
import '../services/rss_service.dart';

class AuthScreen extends StatefulWidget {
  static const String ROUTE_ID = 'auth_screen';

  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final SharedPrefs _sharedPrefs = SharedPrefs.instance;
  bool _isLoggedIn = false;

  Map<String, dynamic>? _nearestStation;

  // RSS fields
  String? _rssTemp;
  String? _forecastDesc;
  String? _rssHumidity;
  String? _rssPressure;
  String? _rssWind;
  String? _rssVisibility;
  String? _rssRain;
  String? _rssSunrise;
  String? _rssSunset;

  // Storm track
  String? _stormMessage;
  bool _loadingStorm = false;

  bool _loadingAir = false;
  bool _loadingForecast = false;
  String? _errorAir;
  String? _errorForecast;

  @override
  void initState() {
    super.initState();
    _loadAirQuality();
    _loadStormTrack();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Utils.createToast("กรุณาเปิด GPS ก่อนใช้งาน");
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Utils.createToast("ผู้ใช้ยังไม่อนุญาตสิทธิ์ Location");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Utils.createToast("สิทธิ์ Location ถูกบล็อก ต้องไปเปิดเองใน Settings");
      return;
    }
  }

  Future<void> _loadAirQuality() async {
    setState(() {
      _loadingAir = true;
      _errorAir = null;
    });
    try {
      await _checkLocationPermission();
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final data = await AirQualityService()
          .fetchNearestStation(pos.latitude, pos.longitude);

      setState(() {
        _nearestStation = data;
      });

      if (data["province"] != null) {
        _loadForecast(data["province"]);
      }
    } catch (e) {
      setState(() {
        _errorAir = "ไม่สามารถโหลดข้อมูลพิกัดได้";
      });
    } finally {
      setState(() {
        _loadingAir = false;
      });
    }
  }

  Future<void> _loadForecast(String province) async {
    setState(() {
      _loadingForecast = true;
      _errorForecast = null;
    });
    try {
      final response = await RssService().fetchForecastByProvince(province);
      if (response.containsKey("error")) {
        setState(() {
          _errorForecast = response["error"];
        });
      } else {
        setState(() {
          _rssTemp = response["temp"] ?? "-";
          _forecastDesc = response["condition"] ?? "-";
          _rssHumidity = response["humidity"] ?? "-";
          _rssPressure = response["pressure"] ?? "-";
          _rssWind = response["wind"] ?? "-";
          _rssVisibility = response["visibility"] ?? "-";
          _rssRain = response["rain"] ?? "-";
          _rssSunrise = response["sunrise"] ?? "-";
          _rssSunset = response["sunset"] ?? "-";
        });
      }
    } catch (e) {
      setState(() {
        _errorForecast = e.toString();
      });
    } finally {
      setState(() {
        _loadingForecast = false;
      });
    }
  }

  Future<void> _loadStormTrack() async {
    setState(() => _loadingStorm = true);
    try {
      final msg = await RssService().fetchStormTrack();
      setState(() => _stormMessage = msg);
    } catch (e) {
      setState(() => _stormMessage = "ไม่สามารถโหลดข้อมูลเส้นทางพายุ");
    } finally {
      setState(() => _loadingStorm = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year + 543}";
    final formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildHeader(),
                const SizedBox(height: 30),
                _buildLoginButtons(context),
                const SizedBox(height: 40),
                _buildDashboardSection(formattedDate, formattedTime),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardSection(String date, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("ข้อมูลล่าสุด",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("$date $time", style: const TextStyle(color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 15),
        // การ์ดคุณภาพอากาศ
        _buildInfoCard(
          icon: Icons.air,
          iconColor: Colors.green,
          title: "คุณภาพอากาศ",
          child: _loadingAir
              ? const LinearProgressIndicator()
              : _errorAir != null
                  ? Text(_errorAir!, style: const TextStyle(color: Colors.red))
                  : _nearestStation == null
                      ? const Text("ไม่มีข้อมูล")
                      : _nearestStation!.containsKey("error")
                          ? Text("❌ ${_nearestStation!['error']}",
                              style: const TextStyle(color: Colors.red))
                          : (_nearestStation!['aqi'] == null ||
                                  _nearestStation!['aqi'] == 0)
                              ? const Text("❌ สถานีนี้ไม่มีรายงานข้อมูลล่าสุด",
                                  style: TextStyle(color: Colors.red))
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                        "${_nearestStation!['province']} - ${_nearestStation!['station_name']}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("AQI: ${_nearestStation!['aqi']}",
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent,
                                            )),
                                        const SizedBox(width: 20),
                                        Text(
                                            "PM2.5: ${_nearestStation!['pm25']} µg/m³",
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
        ),
        const SizedBox(height: 12),
        // การ์ดสภาพอากาศ
        _buildInfoCard(
          icon: Icons.wb_sunny_outlined,
          iconColor: Colors.orange,
          title: "สภาพอากาศประจำวัน",
          child: _loadingForecast
              ? const LinearProgressIndicator()
              : _errorForecast != null
                  ? Text("❌ $_errorForecast",
                      style: const TextStyle(color: Colors.red))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ข้อมูลกรมอุตุฯ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildKV("☁️ สภาพอากาศ", _forecastDesc),
                        _buildKV("💧 ความชื้นสัมพัทธ์", _rssHumidity),
                        _buildKV("📈 ความกดอากาศ", _rssPressure),
                        _buildKV("🌬️ ลม", _rssWind),
                        _buildKV("👁️ ทัศนวิสัย", _rssVisibility),
                        _buildKV("🌧️ ฝนสะสมวันนี้", _rssRain),
                        _buildKV("🌅 พระอาทิตย์ขึ้น", _rssSunrise),
                        _buildKV("🌇 พระอาทิตย์ตก", _rssSunset),
                      ],
                    ),
        ),
        const SizedBox(height: 12),
        // ข้อความวิ่งเส้นทางพายุ
        _buildStormMarquee(),
      ],
    );
  }

  Widget _buildKV(String label, String? value) {
    final v = (value == null || value.trim().isEmpty) ? "-" : value.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          children: [
            TextSpan(
                text: "$label: ",
                style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: v),
          ],
        ),
      ),
    );
  }

  Widget _buildStormMarquee() {
    if (_loadingStorm) {
      return const LinearProgressIndicator();
    }

    final hasNew = _stormMessage != null && _stormMessage!.isNotEmpty;
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
    final colorIndex = DateTime.now().second % colors.length;

    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Marquee(
        text: hasNew ? "🆕 NEW | 🌪️ ${_stormMessage!}" : "🌪️ ไม่มีข้อมูลพายุ",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: colors[colorIndex],
        ),
        scrollAxis: Axis.horizontal,
        blankSpace: 50.0,
        velocity: 40.0,
        pauseAfterRound: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          "APPLICATION รายงานข้อมูล",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const Text(
          "แหล่งน้ำชุมชน และ ปริมาณน้ำฝน",
          style: TextStyle(
              fontSize: 18,
              color: Colors.blueAccent,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("lib/asset/imgs/osm2-icon.png", height: 90, width: 90),
            const SizedBox(width: 20),
            Image.asset("lib/asset/imgs/main-image-v2-3.png",
                height: 90, width: 90),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          "ศูนย์ป้องกันและบรรเทาสาธารณภัย เขต 15 เชียงราย",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Text(
          "กรมป้องกันและบรรเทาสาธารณภัย",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildLoginButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _onLoginWithGoogle(context),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: Colors.grey),
            ),
          ),
          child: const Text("เข้าสู่ระบบด้วย Google",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, LoginScreen.ROUTE_ID),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text("เข้าสู่ระบบด้วยเบอร์โทรศัพท์",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  _onLoginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        setState(() {
          _isLoggedIn = true;
          _sharedPrefs.setValue(
              Global.KEY_USER_EMAIL, googleSignInAccount.email);
          Navigator.pushReplacementNamed(context, LoginScreen.ROUTE_ID);
        });
      }
    } catch (err) {
      Utils.createToast('เกิดข้อผิดพลาดในการเข้าสู่ระบบ $err');
    }
  }
}
