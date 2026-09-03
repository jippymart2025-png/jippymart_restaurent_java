class CuisineTypeModel {
  final int cuisineTypeId;
  final String cuisineTypeName;

  CuisineTypeModel({
    required this.cuisineTypeId,
    required this.cuisineTypeName,
  });

  factory CuisineTypeModel.fromJson(Map<String, dynamic> json) {
    return CuisineTypeModel(
      cuisineTypeId: _parseInt(json['cuisineTypeId']),
      cuisineTypeName: json['cuisineTypeName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cuisineTypeId': cuisineTypeId,
      'cuisineTypeName': cuisineTypeName,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}