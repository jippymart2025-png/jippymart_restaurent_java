import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

String formatAuthToken(String token, {String tokenType = 'Bearer'}) {
  final trimmed = token.trim();
  if (trimmed.isEmpty) return trimmed;
  if (trimmed.toLowerCase().startsWith('bearer ')) {
    return trimmed;
  }
  return '$tokenType $trimmed';
}

/// Save token after login across both storage mechanisms
Future<void> saveAuthToken(
    String accessToken, {
      String tokenType = 'Bearer',
    }) async {
  final trimmed = accessToken.trim();
  if (trimmed.isEmpty) return;

  final formattedToken = formatAuthToken(trimmed, tokenType: tokenType);

  // 1. Save to secure storage
  await _secureStorage.write(
    key: 'api_token',
    value: formattedToken,
  );

  // 2. Save raw and formatted to SharedPreferences for legacy sync
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('authToken', trimmed);
  await prefs.setString('api_token', formattedToken);
}

/// Get saved token (checks SecureStorage first, falls back to SharedPreferences)
Future<String?> getAuthToken() async {
  // 1. Try secure storage
  String? token = await _secureStorage.read(key: 'api_token');
  if (token != null && token.trim().isNotEmpty) {
    return formatAuthToken(token);
  }

  // 2. Fallback to SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  token = prefs.getString('authToken') ?? prefs.getString('api_token');
  if (token != null && token.trim().isNotEmpty) {
    return formatAuthToken(token);
  }

  return null;
}

/// Remove token on logout
Future<void> clearAuthToken() async {
  await _secureStorage.delete(key: 'api_token');
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken');
  await prefs.remove('api_token');
}

/// Common headers for all API calls
Future<Map<String, String>> getHeaders() async {
  final token = await getAuthToken();

  return {
    'Content-Type': 'application/json',
    'Accept': '*/*',
    if (token != null && token.isNotEmpty) 'Authorization': token,
  };
}