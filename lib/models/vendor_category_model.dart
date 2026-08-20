import 'dart:convert';

class VendorCategoryModel {
  List<dynamic>? reviewAttributes;

  /// Old fields used in UI
  String? photo;
  String? description;
  String? id;
  String? title;
  bool? isActive;

  /// New Backend Fields
  String? categoryType;
  String? categoryImageUrl;

  /// Java outlet-category link id
  int? outletCategoryId;

  VendorCategoryModel({
    this.reviewAttributes,
    this.photo,
    this.description,
    this.id,
    this.title,
    this.isActive,
    this.categoryType,
    this.categoryImageUrl,
    this.outletCategoryId,
  });

  factory VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    return VendorCategoryModel(
      /// Existing UI fields
      id: (json['categoryId'] ?? json['id'])?.toString() ?? '',

      title: (json['categoryName'] ??
          json['title'] ??
          json['name'])
          ?.toString() ??
          '',

      description: json['description']?.toString() ?? '',

      /// New API returns categoryImageUrl instead of photo
      photo: (json['categoryImageUrl'] ??
          json['photo'])
          ?.toString(),

      categoryImageUrl:
      json['categoryImageUrl']?.toString(),

      categoryType:
      json['categoryType']?.toString(),

      reviewAttributes: const [],

      isActive: _parseBool(json['isActive']),

      outletCategoryId:
      _parseInt(json['outletCategoryId']) ??
          _parseInt(json['outlet_category_id']) ??
          _parseInt(json['outletCategoryID']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "categoryId": id,
      "categoryName": title,
      "categoryType": categoryType,
      "categoryImageUrl": categoryImageUrl,
      "outletCategoryId": outletCategoryId,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;

    if (value is bool) return value;

    if (value is int) return value != 0;

    if (value is String) {
      switch (value.toLowerCase()) {
        case "true":
        case "1":
          return true;
        case "false":
        case "0":
          return false;
      }
    }

    return null;
  }
  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['review_attributes'] = reviewAttributes;
  //   data['photo'] = photo;
  //   data['description'] = description;
  //   data['id'] = id;
  //   data['title'] = title;
  //   data['isActive'] = isActive;
  //   return data;
  // }
  // Map<String, dynamic> toJson() {
  //   return {
  //     "categoryId": id,
  //     "categoryName": title,
  //   };
  // }


}