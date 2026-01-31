class Users {
  String? userId;
  String userTel;
  String provId;
  String ampId;
  String tamId;
  String mooId;
  String moo;

  String? provName;
  String? ampName;
  String? tamName;
  String? mooName;

  Users({this.userId,
          required this.userTel,
          required this.provId,
          required this.ampId,
          required this.tamId,
          required this.mooId,
          required this.moo,
          this.provName,
          this.ampName,
          this.tamName,
          this.mooName
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: (json["user_id"] == null ? "" : json["user_id"] as String),
      userTel: json["user_tel"] as String,
      provId: json["prov_id"] as String,
      ampId: json["amp_id"] as String,
      tamId: json["tam_id"] as String,
      mooId: json["moo_id"] as String,
      moo: json["moo"] as String,
      provName: (json["prov_name"] == null ? "" : json["prov_name"] as String),
      ampName: (json["amp_name"] == null ? "" : json["amp_name"] as String),
      tamName: (json["tam_name"] == null ? "" : json["tam_name"] as String),
      mooName: (json["moo_name"] == null ? "" : json["moo_name"] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'user_tel': userTel,
    'prov_id': provId,
    'amp_id': ampId,
    'tam_id': tamId,
    'moo_id': mooId,
    'moo': moo,
    'prov_name': provName,
    'amp_name': ampName,
    'tam_name': tamName,
    'moo_name': mooName,
  };
}
