class Amphur {
  String ampId;
  String ampName;

  Amphur({required this.ampId, required this.ampName});

  factory Amphur.fromJson(Map<String, dynamic> json) {
    return Amphur(
      ampId: json["amp_id"] as String,
      ampName: json["amp_name"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'amp_id': ampId,
    'amp_name': ampName,
  };
}
