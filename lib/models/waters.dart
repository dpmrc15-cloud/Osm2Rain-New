class Waters {
  String id;
  String name;
  String total;
  String typeId;
  String detail;
  String integrationId;
  String sizeArea;
  String deep;
  String currentDeep;
  String oldCurrentDeep;
  String upToDate;
  String oldDate;
  String fullFill;
  String depleteDate;
  String providerId;
  String objectiveId;
  String waterSupply;
  String waterLevel;
  String waterLevelDisparity;
  String sufficientWater;
  String waterImage;
  String waterImageUrl;
  String lat;
  String lng;

  Waters({required this.id,
          required this.name,
          required this.total,
          required this.typeId,
          required this.detail,
          required this.integrationId,
          required this.sizeArea,
          required this.deep,
          required this.currentDeep,
          required this.oldCurrentDeep,
          required this.upToDate,
          required this.oldDate,
          required this.fullFill,
          required this.depleteDate,
          required this.providerId,
          required this.objectiveId,
          required this.waterSupply,
          required this.waterLevel,
          required this.waterLevelDisparity,
          required this.sufficientWater,
          required this.waterImage,
          required this.waterImageUrl,
          required this.lat,
          required this.lng});

  factory Waters.fromJson(Map<String, dynamic> json) {
    return Waters(
      id: json["id"] as String,
      name: json["name"] as String,
      total: json["total"] as String,
      typeId: json["type_id"] as String,
      detail: json["detail"] as String,
      integrationId: json["Integration_id"] as String,
      sizeArea: json["size_area"] as String,
      deep: json["deep"] as String,
      currentDeep: json["current_deep"] as String,
      oldCurrentDeep: json["old_current_deep"] as String,
      upToDate: json["uptodate"] as String,
      oldDate: (json["old_date"] == null ? "" : json["old_date"] as String),
      fullFill: json["fullfill"] as String,
      depleteDate: (json["deplete_date"] == null ? "" : json["deplete_date"] as String),
      providerId: json["provider_id"] as String,
      objectiveId: json["objective_id"] as String,
      waterSupply: json["water_supply"] as String,
      waterLevel: json["water_level"] as String,
      waterLevelDisparity: json["water_level_disparity"] as String,
      sufficientWater: json["sufficient_water"] as String,
      waterImage: (json["water_image"] == null ? "" : json["water_image"] as String),
      waterImageUrl: (json["water_image_url"] == null ? "" : json["water_image_url"] as String),
      lat: json["lat"] as String,
      lng: json["lng"] as String
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'total': total,
    'type_id': typeId,
    'detail': detail,
    'Integration_id': integrationId,
    'size_area': sizeArea,
    'deep': deep,
    'current_deep': currentDeep,
    'old_current_deep': oldCurrentDeep,
    'uptodate': upToDate,
    'old_date': oldDate,
    'fullfill': fullFill,
    'deplete_date': depleteDate,
    'provider_id': providerId,
    'objective_id': objectiveId,
    'water_supply': waterSupply,
    'water_level': waterLevel,
    'water_level_disparity': waterLevelDisparity,
    'sufficient_water': sufficientWater,
    'water_image': waterImage,
    'water_image_url': waterImageUrl,
    'lat': lat,
    'lng': lng
  };
}
