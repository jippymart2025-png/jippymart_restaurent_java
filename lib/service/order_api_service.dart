import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jippymart_restaurant/constant/constant.dart';

import '../utils/common.dart';

/// Preparation time bounds accepted by the backend
/// (`AcceptOrRejectOrderByOutletDto.preparationTimeInMins`).
const int kMinPreparationTimeInMins = 1;
const int kMaxPreparationTimeInMins = 15;

/// Actions supported by the outlet accept/reject endpoint.
enum OutletOrderAction {
  accept,
  reject;

  String get apiValue => this == OutletOrderAction.accept ? 'ACCEPT' : 'REJECT';
}

/// Outcome of [OrderApiService.acceptOrRejectOrderByOutlet].
///
/// The endpoint answers HTTP 200 even when a business rule rejects the request
/// (the message is then the response body), so callers must check [success]
/// rather than only the HTTP status.
class OutletOrderStatusResult {
  final bool success;
  final String message;

  const OutletOrderStatusResult.success([this.message = ''])
      : success = true;

  const OutletOrderStatusResult.failure(this.message) : success = false;
}

/// Order lifecycle calls against the customer & order service.
class OrderApiService {
  static String get _baseUrl => Constant.baseUrl;

  static const String _endpoint = 'co/acceptOrRejectOrderByOutlet';
  static const String _successKeyword = 'updated successfully';

  /// POST /api/co/acceptOrRejectOrderByOutlet
  ///
  /// [preparationTimeInMins] is required (1..15) for [OutletOrderAction.accept]
  /// and [rejectionReason] is required for [OutletOrderAction.reject]; the
  /// missing one is never sent so the unused field cannot trip validation.
  static Future<OutletOrderStatusResult> acceptOrRejectOrderByOutlet({
    required String orderId,
    required int outletId,
    required OutletOrderAction action,
    int? preparationTimeInMins,
    String? rejectionReason,
  }) async {
    final reason = rejectionReason?.trim() ?? '';

    if (action == OutletOrderAction.accept) {
      if (preparationTimeInMins == null) {
        return const OutletOrderStatusResult.failure(
            'Preparation time is required when accepting an order');
      }
      if (preparationTimeInMins < kMinPreparationTimeInMins ||
          preparationTimeInMins > kMaxPreparationTimeInMins) {
        return OutletOrderStatusResult.failure(
            'Preparation time must be between $kMinPreparationTimeInMins and $kMaxPreparationTimeInMins minutes');
      }
    } else if (reason.isEmpty) {
      return const OutletOrderStatusResult.failure(
          'Rejection reason is required when rejecting an order');
    }

    final url = Uri.parse('$_baseUrl$_endpoint');
    final payload = <String, dynamic>{
      'orderId': orderId,
      'outletId': outletId,
      'orderStatus': action.apiValue,
      if (action == OutletOrderAction.accept)
        'preparationTimeInMins': preparationTimeInMins,
      if (reason.isNotEmpty) 'rejectionReason': reason,
    };

    try {
      final response = await http
          .post(
            url,
            headers: await getHeaders(),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200 && response.statusCode != 201) {
        return OutletOrderStatusResult.failure(
            _extractErrorMessage(response.statusCode, response.body));
      }

      return _parseSuccessResponse(response.body);
    } on TimeoutException {
      return const OutletOrderStatusResult.failure(
          'Request timed out. Please try again.');
    } catch (e) {
      print('OrderApiService.$_endpoint error: $e');
      return const OutletOrderStatusResult.failure(
          'Unable to reach the server. Please try again.');
    }
  }

  /// Reads the estimated-time text produced by the duration picker
  /// ("12 minutes" / "1:05") and converts it to whole minutes.
  static int? parsePreparationTimeInMins(String? raw) {
    final text = raw?.trim().toLowerCase() ?? '';
    if (text.isEmpty) return null;

    final labelled =
        RegExp(r'(\d+)\s*(?:minutes?|min)').firstMatch(text);
    if (labelled != null) return int.tryParse(labelled.group(1)!);

    final parts = text.split(':');
    if (parts.length == 2) {
      final hours = int.tryParse(parts[0].trim()) ?? 0;
      final minutes = int.tryParse(parts[1].trim()) ?? 0;
      return hours * 60 + minutes;
    }

    return int.tryParse(text);
  }

  static OutletOrderStatusResult _parseSuccessResponse(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return const OutletOrderStatusResult.success();

    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map && decoded['errorMessage'] != null) {
          return OutletOrderStatusResult.failure(
              decoded['errorMessage'].toString());
        }
      } catch (_) {}
      return const OutletOrderStatusResult.success();
    }

    if (trimmed.toLowerCase().contains(_successKeyword)) {
      return const OutletOrderStatusResult.success();
    }

    return OutletOrderStatusResult.failure(trimmed);
  }

  static String _extractErrorMessage(int statusCode, String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return 'Request failed ($statusCode)';

    if (trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          for (final key in ['errorMessage', 'message', 'error']) {
            final value = decoded[key];
            if (value != null && value.toString().isNotEmpty) {
              return value.toString();
            }
          }
        }
      } catch (_) {}
    }

    return trimmed.length > 200
        ? '${trimmed.substring(0, 200)}...'
        : trimmed;
  }
}
