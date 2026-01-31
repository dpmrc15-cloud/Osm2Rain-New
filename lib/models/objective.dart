class Objective {
  String objectiveId;
  String objectiveName;

  Objective({required this.objectiveId, required this.objectiveName});

  factory Objective.fromJson(Map<String, dynamic> json) {
    return Objective(
      objectiveId: json["objective_id"] as String,
      objectiveName: json["objective_name"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'objective_id': objectiveId,
    'objective_name': objectiveName,
  };
}
