class Tambon {
  String tamId;
  String tamName;

  Tambon({required this.tamId, required this.tamName});

  factory Tambon.fromJson(Map<String, dynamic> json) {
    return Tambon(
      tamId: json["tam_id"] as String,
      tamName: json["tam_name"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'tam_id': tamId,
    'tam_name': tamName,
  };
}
