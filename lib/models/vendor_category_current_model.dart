//
//
//
// import 'dart:convert';
// class VendorCategoryModel {
//   List<dynamic>? reviewAttributes;
//   String? photo;
//   String? description;
//   String? id; String? title;
//   bool? isActive;
//   VendorCategoryModel({
//     this.reviewAttributes,
//     this.photo,
//     this.description,
//     this.id,
//     this.title,
//     this.isActive, });
//   VendorCategoryModel.fromJson(Map<String, dynamic> json) {
//    final raw = json['review_attributes'];
//    if (raw is String) {
//      final s = raw.trim();
//      if (s.isEmpty) { reviewAttributes = <dynamic>[];
//      } else {
//        try {
//          final decoded = jsonDecode(s);
//          reviewAttributes = decoded is List ? decoded : <dynamic>[];
//        } catch (_) {
//          reviewAttributes = <dynamic>[];
//        }
//      }
//    } else if (raw is List) {
//      reviewAttributes = raw;
//    } else {
//      reviewAttributes = <dynamic>[];
//    } photo = json['photo'] ?? "";
//    description = json['description'] ?? '';
//    id = json['id']?.toString() ?? "";
//    title = json['title'] ?? ""; isActive = _parseBool(json['isActive']);
//   }
//   static bool? _parseBool(dynamic value) {
//     if (value == null) return null;
//     if (value is bool) return value;
//     if (value is int) return value != 0;
//     if (value is String) { final n = value.toLowerCase();
//       if (n == 'true' || n == '1') return true;
//       if (n == 'false' || n == '0') return false; } return null; }
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['review_attributes'] = reviewAttributes;
//     data['photo'] = photo; data['description'] = description;
//     data['id'] = id; data['title'] = title;
//     data['isActive'] = isActive;
//     return data;
//   }
// }