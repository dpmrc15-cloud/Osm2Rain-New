class Address {
  String id;
  String provId;
  String provName;
  String ampId;
  String ampName;
  String tamId;
  String tamName;
  String mooId;
  String moo;
  String mooName;
  String female;
  String male;
  String total;
  String houseHold;
  String currentFemale;
  String currentMale;
  String currentTotal;
  String currentHousehold;
  String lat;
  String lng;
  String remark;
  String contact;
  String? oldDate;
  String? updateAt;
  String? mudFlag;
  String? cataractFlag;
  String? wildfireFlag;
  String? droughtFlag;
  String? landslideFlag;
  String? earthquakeFlag;

  Address({required this.id,
          required this.provId,
          required this.provName,
          required this.ampId,
          required this.ampName,
          required this.tamId,
          required this.tamName,
          required this.mooId,
          required this.moo,
          required this.mooName,
          required this.female,
          required this.male,
          required this.total,
          required this.houseHold,
          required this.currentFemale,
          required this.currentMale,
          required this.currentTotal,
          required this.currentHousehold,
          required this.lat,
          required this.lng,
          required this.remark,
          required this.contact,
          this.oldDate,
          this.updateAt,
          this.mudFlag,
          this.cataractFlag,
          this.wildfireFlag,
          this.droughtFlag,
          this.landslideFlag,
          this.earthquakeFlag,
          });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json["id"] as String,
      provId: json["prov_id"] as String,
      provName: json["prov_name"] as String,
      ampId: json["amp_id"] as String,
      ampName: json["amp_name"] as String,
      tamId: json["tam_id"] as String,
      tamName: json["tam_name"] as String,
      mooId: json["moo_id"] as String,
      mooName: json["moo_name"] as String,
      moo: json["moo"] as String,
      female: json["female"] as String,
      male: json["male"] as String,
      total: json["total"] as String,
      houseHold: json["household"] as String,
      currentFemale: json["current_female"] as String,
      currentMale: json["current_male"] as String,
      currentTotal: json["current_total"] as String,
      currentHousehold: json["current_household"] as String,
      lat: json["lat"] as String,
      lng: json["lng"] as String,
      remark: json["remark"] as String,
      contact: json["contact"] as String,
      oldDate: (json["old_date"] == null ? "" : json["old_date"] as String),
      updateAt: (json["update_at"] == null ? "" : json["update_at"] as String),
      mudFlag: (json["mud_flag"] == null ? "" : json["mud_flag"] as String),
      cataractFlag: (json["cataract_flag"] == null ? "" : json["cataract_flag"] as String),
      wildfireFlag: (json["wildfire_flag"] == null ? "" : json["wildfire_flag"] as String),
      droughtFlag: (json["drought_flag"] == null ? "" : json["drought_flag"] as String),
      landslideFlag: (json["landslide_flag"] == null ? "" : json["landslide_flag"] as String),
      earthquakeFlag: (json["earthquake_flag"] == null ? "" : json["earthquake_flag"] as String)
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'prov_id': provId,
    'prov_name': provName,
    'amp_id': ampId,
    'amp_name': ampName,
    'tam_id': tamId,
    'tam_name': tamName,
    'moo_id': mooId,
    'moo_name': mooName,
    'moo': moo,
    'female': female,
    'male': male,
    'total': total,
    'household': houseHold,
    'current_female': currentFemale,
    'current_male': currentMale,
    'current_total': currentTotal,
    'current_household': currentHousehold,
    'lat': lat,
    'lng': lng,
    'remark': remark,
    'contact': contact,
    'old_date': oldDate,
    'update_at': updateAt,
    'mud_flag': mudFlag,
    'cataract_flag': cataractFlag,
    'wildfire_flag': wildfireFlag,
    'drought_flag': droughtFlag,
    'landslide_flag': landslideFlag,
    'earthquake_flag': earthquakeFlag
  };
}
