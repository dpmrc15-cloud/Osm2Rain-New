class Rain {
  String rainId;
  String mooId;
  String createDate;
  String lat;
  String lng;

  Rain({
    required this.rainId,
    required this.mooId,
    required this.createDate,
    required this.lat,
    required this.lng,
  });

  factory Rain.fromJson(Map<String, dynamic> json) {
    return Rain(
      rainId: json["rain_id"] as String,
      mooId: json["moo_id"] as String,
      createDate: json["created_date"] as String,
      lat: json["lat"] as String,
      lng: json["lng"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'rain_id': rainId,
    'moo_id': mooId,
    'created_date': createDate,
    'lat': lat,
    'lng': lng,
  };
}
