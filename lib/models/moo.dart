class Moo {
  String mooId;
  String moo;
  String mooName;

  Moo({required this.mooId, required this.moo, required this.mooName});

  factory Moo.fromJson(Map<String, dynamic> json) {
    return Moo(
      mooId: json["moo_id"] as String,
      moo: json["moo"] as String,
      mooName: json["moo_name"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'moo_id': mooId,
    'moo': moo,
    'moo_name': mooName,
  };
}
