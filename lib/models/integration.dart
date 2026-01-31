class Integration {
  String integrationId;
  String integrationName;

  Integration({required this.integrationId, required this.integrationName});

  factory Integration.fromJson(Map<String, dynamic> json) {
    return Integration(
      integrationId: json["Integration_id"] as String,
      integrationName: json["Integration_name"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'Integration_id': integrationId,
    'Integration_name': integrationName,
  };
}
