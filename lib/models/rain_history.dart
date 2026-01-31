class RainHistory {
  String rainHistoryId;
  String rainId;
  String oneHourRainfall;
  String twoHourRainfall;
  String threeHourRainfall;
  String sixHourRainfall;
  String twelveHourRainfall;
  String allDayRainfall;
  String userPhone;
  String createDate;
  String? rainImage;

  String? lat;
  String? lng;

  String? provName;
  String? ampName;
  String? tamName;
  String? mooName;
  String? moo;
  String? currentRainfall;

  RainHistory({
    required this.rainHistoryId,
    required this.rainId,
    required this.oneHourRainfall,
    required this.twoHourRainfall,
    required this.threeHourRainfall,
    required this.sixHourRainfall,
    required this.twelveHourRainfall,
    required this.allDayRainfall,
    required this.userPhone,
    required this.createDate,
    this.rainImage,
    this.lat,
    this.lng,
    this.provName,
    this.ampName,
    this.tamName,
    this.mooName,
    this.moo,
    this.currentRainfall,
  });

  // ✅ ฟังก์ชันแปลงค่าทุกชนิดให้เป็น String ปลอดภัย
  static String _toStr(dynamic v) {
    if (v == null) return "";
    return v.toString();
  }

  factory RainHistory.fromJson(Map<String, dynamic> json) {
    return RainHistory(
      rainHistoryId: _toStr(json["rain_history_id"]),
      rainId: _toStr(json["rain_id"]),
      oneHourRainfall: _toStr(json["onehour_rainfall"]),
      twoHourRainfall: _toStr(json["twohour_rainfall"]),
      threeHourRainfall: _toStr(json["threehour_rainfall"]),
      sixHourRainfall: _toStr(json["sixhour_rainfall"]),
      twelveHourRainfall: _toStr(json["twelvehour_rainfall"]),
      allDayRainfall: _toStr(json["allday_rainfall"]),
      userPhone: _toStr(json["user_phone"]),
      createDate: _toStr(json["create_date"]),
      rainImage: _toStr(json["rain_image"]),
      lat: _toStr(json["lat"]),
      lng: _toStr(json["lng"]),
      provName: _toStr(json["prov_name"]),
      ampName: _toStr(json["amp_name"]),
      tamName: _toStr(json["tam_name"]),
      mooName: _toStr(json["moo_name"]),
      moo: _toStr(json["moo"]),
      currentRainfall: _toStr(json["current_rainfall"]),
    );
  }

  Map<String, dynamic> toJson() => {
        'rain_history_id': rainHistoryId,
        'rain_id': rainId,
        'onehour_rainfall': oneHourRainfall,
        'twohour_rainfall': twoHourRainfall,
        'threehour_rainfall': threeHourRainfall,
        'sixhour_rainfall': sixHourRainfall,
        'twelvehour_rainfall': twelveHourRainfall,
        'allday_rainfall': allDayRainfall,
        'user_phone': userPhone,
        'create_date': createDate,
        'rain_image': rainImage,
        'lat': lat,
        'lng': lng,
        'prov_name': provName,
        'amp_name': ampName,
        'tam_name': tamName,
        'moo_name': mooName,
        'moo': moo,
        'current_rainfall': currentRainfall,
      };
}