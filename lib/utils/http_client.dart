import 'dart:convert';
import 'package:http/http.dart' as http_orig;
import 'package:flutter/foundation.dart';
import 'package:jippymart_restaurant/utils/common.dart';
import 'package:jippymart_restaurant/constant/constant.dart';

export 'package:http/http.dart' hide get, post, put, delete, patch, read, readBytes, MultipartRequest;

bool _isRefreshing = false;

Future<bool> refreshJwtToken() async {
  if (_isRefreshing) return false;
  _isRefreshing = true;
  try {
    final oldToken = await getAuthToken();
    final refreshToken = await getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      _isRefreshing = false;
      return false;
    }

    final response = await http_orig.post(
      Uri.parse('${Constant.baseUrl}fm/auth/refresh'),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'refreshToken': refreshToken
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      final newJwt = decoded['jwtToken'];
      if (newJwt != null) {
        await saveAuthToken(newJwt);
        final newRefreshToken = decoded['refreshToken'];
        if (newRefreshToken != null) {
          await saveRefreshToken(newRefreshToken);
        }
        _isRefreshing = false;
        return true;
      }
    }
  } catch (e) {
    debugPrint('Token refresh failed: $e');
  }
  _isRefreshing = false;
  return false;
}

Future<http_orig.Response> _retryWithRefreshToken(
  Future<http_orig.Response> Function(Map<String, String>?) requestAction,
  Map<String, String>? originalHeaders,
) async {
  var response = await requestAction(originalHeaders);
  if (response.statusCode == 403 || response.statusCode == 401) {
    bool success = await refreshJwtToken();
    if (success) {
      final newToken = await getAuthToken();
      final newHeaders = Map<String, String>.from(originalHeaders ?? {});
      if (newToken != null) {
        newHeaders['Authorization'] = newToken;
      }
      response = await requestAction(newHeaders);
    }
  }
  return response;
}

Future<http_orig.Response> get(Uri url, {Map<String, String>? headers}) async {
  return _retryWithRefreshToken((h) => http_orig.get(url, headers: h), headers);
}

Future<http_orig.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  return _retryWithRefreshToken((h) => http_orig.post(url, headers: h, body: body, encoding: encoding), headers);
}

Future<http_orig.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  return _retryWithRefreshToken((h) => http_orig.put(url, headers: h, body: body, encoding: encoding), headers);
}

Future<http_orig.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  return _retryWithRefreshToken((h) => http_orig.delete(url, headers: h, body: body, encoding: encoding), headers);
}

Future<http_orig.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  return _retryWithRefreshToken((h) => http_orig.patch(url, headers: h, body: body, encoding: encoding), headers);
}

class MultipartRequest extends http_orig.MultipartRequest {
  MultipartRequest(String method, Uri url) : super(method, url);

  @override
  Future<http_orig.StreamedResponse> send() async {
    var response = await super.send();
    if (response.statusCode == 403 || response.statusCode == 401) {
      bool success = await refreshJwtToken();
      if (success) {
        final newToken = await getAuthToken();
        if (newToken != null) {
          // We have to recreate the request since streams are consumed
          final newRequest = http_orig.MultipartRequest(method, url);
          newRequest.headers.addAll(headers);
          newRequest.headers['Authorization'] = newToken;
          newRequest.fields.addAll(fields);
          for (var file in files) {
            // This is a bit tricky, if the file was a stream it might be consumed.
            // But if it was from path, we could in theory clone it.
            // Let's assume files stream are still valid or we just pass them.
            newRequest.files.add(file);
          }
          response = await newRequest.send();
        }
      }
    }
    return response;
  }
}
