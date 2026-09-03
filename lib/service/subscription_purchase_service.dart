import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/subscription_plan_model.dart';

/// Creates subscription purchase history on the backend (SQL `subscription_history` table).
/// Columns (from schema): id, createdAt, updated_at, payment_type, zone, user_id, expiry_date, subscription_plan.
class SubscriptionPurchaseService {
  static String get _baseUrl => Constant.baseUrl;

  static Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Sends subscription purchase to backend.
  /// Adjust [endpoint] or body field names if your API differs.
  static Future<bool> createSubscriptionHistory({
    required SubscriptionPlanModel plan,
    required String userId,
    required String zoneId,
    required String paymentType,
    DateTime? expiryDate,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}subscription-history');
      final body = <String, dynamic>{
        'user_id': userId,
        'payment_type': paymentType,
        'zone': zoneId,
        // Send the exact plan ID from backend (what user actually bought)
        'subscription_plan_id': plan.subscriptionPlanId,
        // Full snapshot of the plan details at purchase time
        'subscription_plan': jsonEncode(plan.toJson()),
      };
      if (expiryDate != null) {
        body['expiry_date'] = expiryDate.toIso8601String();
      }

      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      print('createSubscriptionHistory failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (e, st) {
      print('createSubscriptionHistory error: $e $st');
      return false;
    }
  }
}

