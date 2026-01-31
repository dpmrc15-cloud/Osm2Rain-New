class WatersUses {
  String id;
  String mooId;
  String waterId;
  String userPhone;
  String uptodate;

  WatersUses({required this.id,
          required this.mooId,
          required this.waterId,
          required this.userPhone,
          required this.uptodate
  });

  factory WatersUses.fromJson(Map<String, dynamic> json) {
    return WatersUses(
      id: json["id"] as String,
      mooId: json["moo_id"] as String,
      waterId: json["water_id"] as String,
      userPhone: json["user_phone"] as String,
      uptodate: json["uptodate"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'moo_id': mooId,
    'water_id': waterId,
    'user_phone': userPhone,
    'uptodate': uptodate
  };
}
