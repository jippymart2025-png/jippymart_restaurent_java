// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/location_model.dart';
// import '../utils/preferences.dart';
//
// class LocationApiService {
//   //static String get _baseUrl => Constant.baseUrl;
//   static Future<Map<String, String>> getHeaders() async {
//     final token = await Preferences.getString('authToken');
//
//     return {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       'Authorization': 'Bearer ${token ?? ''}',
//     };
//   }
//
//   /// =========================
//   /// FETCH STATES
//   /// GET /location/fetchStates
//   /// =========================
//   static Future<List<StateModel>> fetchStates() async {
//     try {
//       final url = 'http://187.127.156.147:8084/api/fm/location/fetchStates';
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: await getHeaders(),
//       );
//
//       if (response.statusCode != 200) {
//         return [];
//       }
//
//       final body =
//       response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
//
//       if (body.isEmpty) {
//         return [];
//       }
//
//       final List<dynamic> data =
//       jsonDecode(body) as List<dynamic>;
//
//       return data
//           .map(
//             (e) => StateModel.fromJson(
//           Map<String, dynamic>.from(e),
//         ),
//       )
//           .toList();
//     } catch (e) {
//       print('fetchStates error: $e');
//       return [];
//     }
//   }
//
//   /// =========================
//   /// FETCH CITIES
//   /// GET /location/fetchCityInState?stateId=1
//   /// =========================
//   static Future<List<CityModel>> fetchCities(
//       int stateId,
//       ) async {
//     try {
//       final url =
//           'http://187.127.156.147:8084/api/fm/location/fetchCityInState?stateId=$stateId';
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: await getHeaders(),
//       );
//
//       if (response.statusCode != 200) {
//         return [];
//       }
//
//       final body =
//       response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
//
//       if (body.isEmpty) {
//         return [];
//       }
//
//       final List<dynamic> data =
//       jsonDecode(body) as List<dynamic>;
//
//       return data
//           .map(
//             (e) => CityModel.fromJson(
//           Map<String, dynamic>.from(e),
//         ),
//       )
//           .toList();
//     } catch (e) {
//       print('fetchCities error: $e');
//       return [];
//     }
//   }
//
//   /// =========================
//   /// FETCH AREAS
//   /// GET /location/fetchAreaInCity?cityId=1
//   /// =========================
//   static Future<List<AreaModel>> fetchAreas(
//       int cityId,
//       ) async {
//     try {
//       final url =
//           'http://187.127.156.147:8084/api/fm/location/fetchAreaInCity?cityId=$cityId';
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: await getHeaders(),
//       );
//
//       if (response.statusCode != 200) {
//         return [];
//       }
//
//       final body =
//       response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
//
//       if (body.isEmpty) {
//         return [];
//       }
//
//       final List<dynamic> data =
//       jsonDecode(body) as List<dynamic>;
//
//       return data
//           .map(
//             (e) => AreaModel.fromJson(
//           Map<String, dynamic>.from(e),
//         ),
//       )
//           .toList();
//     } catch (e) {
//       print('fetchAreas error: $e');
//       return [];
//     }
//   }
// }




import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constant/constant.dart';
import '../models/location_model.dart';
import '../utils/common.dart';


class LocationApiService {
  /// =========================
  /// FETCH STATES
  /// GET /location/fetchStates
  /// =========================
  static Future<List<StateModel>> fetchStates() async {
    try {
      final url = '${Constant.baseUrl}fm/location/fetchStates';
      final headers = await getHeaders();
      print('fetchStates URL: $url');
      print('fetchStates headers: $headers');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('fetchStates status: ${response.statusCode}');
      print('fetchStates body: ${response.body}');

      if (response.statusCode != 200) {
        return [];
      }

      final body = response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
      if (body.isEmpty) return [];

      final List<dynamic> data = jsonDecode(body) as List<dynamic>;
      return data.map((e) => StateModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      print('fetchStates error: $e');
      return [];
    }
  }
  /// =========================
  /// FETCH CITIES
  /// GET /location/fetchCityInState?stateId=1
  /// =========================
  static Future<List<CityModel>> fetchCities(int stateId) async {
    try {
      final url = '${Constant.baseUrl}fm/location/fetchCityInState?stateId=$stateId';

      final response = await http.get(
        Uri.parse(url),
        headers: await getHeaders(),
      );

      if (response.statusCode != 200) {
        return [];
      }

      final body = response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
      if (body.isEmpty) return [];

      final List<dynamic> data = jsonDecode(body) as List<dynamic>;

      return data
          .map((e) => CityModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('fetchCities error: $e');
      return [];
    }
  }

  /// =========================
  /// FETCH AREAS
  /// GET /location/fetchAreaInCity?cityId=1
  /// =========================
  static Future<List<AreaModel>> fetchAreas(int cityId) async {
    try {
      final url = '${Constant.baseUrl}fm/location/fetchAreaInCity?cityId=$cityId';

      final response = await http.get(
        Uri.parse(url),
        headers: await getHeaders(),
      );

      if (response.statusCode != 200) {
        return [];
      }

      final body = response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
      if (body.isEmpty) return [];

      final List<dynamic> data = jsonDecode(body) as List<dynamic>;

      return data
          .map((e) => AreaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('fetchAreas error: $e');
      return [];
    }
  }
}