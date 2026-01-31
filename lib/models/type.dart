class Type {
  String typeId;
  String typeName;

  Type({required this.typeId, required this.typeName});

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      typeId: json["type_id"] as String,
      typeName: json["type_name"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'type_id': typeId,
    'type_name': typeName,
  };
}
