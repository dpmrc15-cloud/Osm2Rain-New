class Provider {
  String providerId;
  String providerName;

  Provider({required this.providerId, required this.providerName});

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      providerId: json["provider_id"] as String,
      providerName: json["provider_name"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'provider_id': providerId,
    'provider_name': providerName,
  };
}
