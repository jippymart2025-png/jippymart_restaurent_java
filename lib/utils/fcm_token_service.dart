import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:jippymart_restaurant/constant/constant.dart';

class FCMTokenService {
  static String saveTokenUrl = '${Constant.baseUrl}notification/device-token';

  static Future<Map<String, dynamic>?> saveToken({
    required int userId,
    required String userType,
    required String fcmToken,
    required String deviceType,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = jsonEncode({
        'userId': userId,
        'userType': userType,
        'deviceType': deviceType,
        'fcmToken': fcmToken,
      });

      final response = await http.post(
        Uri.parse(saveTokenUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        debugPrint('Save FCM token failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Save FCM token error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> removeToken({
    required int userId,
    required String userType,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = jsonEncode({
        'userId': userId,
        'userType': userType,
        'fcmToken': '',
      });

      final response = await http.post(
        Uri.parse(saveTokenUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        debugPrint('Remove FCM token failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Remove FCM token error: $e');
      return null;
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await Preferences.getString('authToken');

    return {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      if (token != null && token.isNotEmpty) 'Authorization': token,
    };
  }
}