// // import 'package:cloud_firestore/cloud_firestore.dart';
// //
// // class ZoneModel {
// //   List<GeoPoint>? area;
// //   bool? publish;
// //   double? latitude;
// //   String? name;
// //   String? id;
// //   double? longitude;
// //
// //   ZoneModel(
// //       {this.area,
// //         this.publish,
// //         this.latitude,
// //         this.name,
// //         this.id,
// //         this.longitude});
// //
// //   ZoneModel.fromJson(Map<String, dynamic> json) {
// //     if (json['area'] != null) {
// //       area = <GeoPoint>[];
// //       json['area'].forEach((v) {
// //         area!.add(v);
// //       });
// //     }
// //
// //     publish = json['publish'];
// //     latitude = json['latitude'];
// //     name = json['name'];
// //     id = json['id'];
// //     longitude = json['longitude'];
// //   }
// //
// //   Map<String, dynamic> toJson() {
// //     final Map<String, dynamic> data = <String, dynamic>{};
// //     if (area != null) {
// //       data['area'] = area!.map((v) => v).toList();
// //     }
// //     data['publish'] = publish;
// //     data['latitude'] = latitude;
// //     data['name'] = name;
// //     data['id'] = id;
// //     data['longitude'] = longitude;
// //     return data;
// //   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ZoneModel {
//   final String? id;
//   final GeoPoint? location;
//   final List<GeoPoint>? area;
//   final String? name;
//   final int? publish;
//
//   ZoneModel({
//      this.id,
//      this.location,
//      this.area,
//      this.name,
//      this.publish,
//   });
//
//   factory ZoneModel.fromJson(Map<String, dynamic> json) {
//     return ZoneModel(
//       id: json['id'] ?? '',
//       location: GeoPoint(
//         (json['latitude'] as num?)?.toDouble() ?? 0.0,
//         (json['longitude'] as num?)?.toDouble() ?? 0.0,
//       ),
//       area: (json['area'] as List<dynamic>?)?.map((item) {
//         return GeoPoint(
//           (item['latitude'] as num).toDouble(),
//           (item['longitude'] as num).toDouble(),
//         );
//       }).toList() ?? [],
//       name: json['name'] ?? '',
//       publish: json['publish'] ?? 0,
//     );
//   }
// }