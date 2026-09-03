class StateModel {
  final int stateId;
  final String stateName;

  StateModel({
    required this.stateId,
    required this.stateName,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      stateId: json['stateId'] ?? 0,
      stateName: json['stateName'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StateModel &&
              runtimeType == other.runtimeType &&
              stateId == other.stateId;

  @override
  int get hashCode => stateId.hashCode;
}
class CityModel {
  final int cityId;
  final String cityName;

  CityModel({
    required this.cityId,
    required this.cityName,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      cityId: json['cityId'] ?? 0,
      cityName: json['cityName'] ?? '',
    );
  }
}

class AreaModel {
  final int areaId;
  final String areaName;

  AreaModel({
    required this.areaId,
    required this.areaName,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      areaId: json['areaId'] ?? 0,
      areaName: json['areaName'] ?? '',
    );
  }
}