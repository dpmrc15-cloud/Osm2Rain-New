class Province {
  String provId;
  String provName;

  Province({required this.provId, required this.provName});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      provId: json["prov_id"] as String,
      provName: json["prov_name"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'prov_id': provId,
    'prov_name': provName,
  };
}
