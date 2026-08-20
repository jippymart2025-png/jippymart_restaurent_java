import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/dashboard_model.dart';
import 'package:jippymart_restaurant/config/app_config.dart';

import '../utils/fire_store_utils.dart';
import '../utils/preferences.dart';

/// Dashboard filter values supported by the API.
enum DashboardFilter {
  none,
  lastWeek,
  lastMonth,
}

extension DashboardFilterExt on DashboardFilter {
  /// PHP vendor dashboard query values.
  String? get queryValue {
    switch (this) {
      case DashboardFilter.none:
        return null;
      case DashboardFilter.lastWeek:
        return 'last_week';
      case DashboardFilter.lastMonth:
        return 'last_month';
    }
  }

  /// Java sales-report API filter values.
  String get javaQueryValue {
    switch (this) {
      case DashboardFilter.none:
        return 'ALL';
      case DashboardFilter.lastWeek:
        return 'LAST_WEEK';
      case DashboardFilter.lastMonth:
        return 'LAST_MONTH';
    }
  }
}

/// Fetches vendor dashboard data.
/// API: GET {{baseURL}}vendor/dashboard?vendor_id=...&filter=last_week|last_month
class DashboardApiService {
  static String get _baseUrl => Constant.baseUrl;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static final Map<String, _CachedDashboard> _cache = {};
  static const Duration _ttl = Duration(seconds: 90);

  static String _makeKey({
    required String vendorId,
    required String endpoint,
    required DashboardFilter filter,
  }) {
    return '$endpoint|$vendorId|${filter.queryValue ?? 'none'}';
  }

  static DashboardModel? _getFromCache(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }
    return entry.data;
  }

  static void _saveToCache(String key, DashboardModel data) {
    _cache[key] = _CachedDashboard(
      data: data,
      expiresAt: DateTime.now().add(_ttl),
    );
    if (AppConfig.enableDebugLogs) {
      // ignore: avoid_print
      print('DashboardApiService cache saved for key=$key');
    }
  }

  /// GET vendor/dashboard?vendor_id=...&filter=...
  /// [vendorId] current vendor ID (e.g. Constant.userModel?.vendorID).
  /// [filter] optional: last_week, last_month; omit for all data.
  static Future<DashboardModel?> getDashboard({
    required String vendorId,
    DashboardFilter filter = DashboardFilter.none,
    bool forceRefresh = false,
  }) async {
    final id = vendorId.trim();
    if (id.isEmpty) return null;

    final cacheKey = _makeKey(
      vendorId: id,
      endpoint: 'dashboard',
      filter: filter,
    );
    if (!forceRefresh) {
      final cached = _getFromCache(cacheKey);
      if (cached != null) {
        if (AppConfig.enableDebugLogs) {
          // ignore: avoid_print
          print('DashboardApiService.getDashboard using cached data for $cacheKey');
        }
        return cached;
      }
    }

    try {
      final queryParams = <String>['vendor_id=${Uri.encodeComponent(id)}'];
      final filterValue = filter.queryValue;
      if (filterValue != null && filterValue.isNotEmpty) {
        queryParams.add('filter=${Uri.encodeComponent(filterValue)}');
      }
      final url = '${_baseUrl}vendor/dashboard?${queryParams.join('&')}';
      final response = await http.get(Uri.parse(url), headers: _headers);

      final bodyStr = response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
      if (bodyStr.isEmpty) return null;

      final json = jsonDecode(bodyStr) as Map<String, dynamic>;
      final model = DashboardModel.fromJson(json);
      _saveToCache(cacheKey, model);
      return model;
    } catch (e, st) {
      print('DashboardApiService.getDashboard error: $e $st');
      return null;
    }
  }

  /// GET vendor/SettledReport?vendor_id=...&filter=...
  /// Same response shape as dashboard. Use for "Settled earnings" report.
  static Future<DashboardModel?> getSettledReport({
    required String vendorId,
    DashboardFilter filter = DashboardFilter.none,
    bool forceRefresh = false,
  }) async {
    final id = vendorId.trim();
    if (id.isEmpty) return null;

    final cacheKey = _makeKey(
      vendorId: id,
      endpoint: 'settled',
      filter: filter,
    );
    if (!forceRefresh) {
      final cached = _getFromCache(cacheKey);
      if (cached != null) {
        if (AppConfig.enableDebugLogs) {
          // ignore: avoid_print
          print('DashboardApiService.getSettledReport using cached data for $cacheKey');
        }
        return cached;
      }
    }

    try {
      final queryParams = <String>['vendor_id=${Uri.encodeComponent(id)}'];
      final filterValue = filter.queryValue;
      if (filterValue != null && filterValue.isNotEmpty) {
        queryParams.add('filter=${Uri.encodeComponent(filterValue)}');
      }
      final url = '${_baseUrl}vendor/SettledReport?${queryParams.join('&')}';
      final response = await http.get(Uri.parse(url), headers: _headers);

      final bodyStr = response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
      if (bodyStr.isEmpty) return null;

      final json = jsonDecode(bodyStr) as Map<String, dynamic>;
      final model = DashboardModel.fromJson(json);
      _saveToCache(cacheKey, model);
      return model;
    } catch (e, st) {
      print('DashboardApiService.getSettledReport error: $e $st');
      return null;
    }
  }

  static String _javaSalesCacheKey({
    required int merchantId,
    int? outletId,
    required DashboardFilter filter,
    required String endpoint,
  }) {
    return 'java-$endpoint|$merchantId|${outletId ?? 'all'}|${filter.javaQueryValue}';
  }

  static Future<DashboardModel?> _fetchJavaSalesReport({
    required String endpoint,
    required int merchantId,
    int? outletId,
    DashboardFilter filter = DashboardFilter.none,
    bool forceRefresh = false,
  }) async {
    if (merchantId <= 0) return null;

    final cacheKey = _javaSalesCacheKey(
      merchantId: merchantId,
      outletId: outletId,
      filter: filter,
      endpoint: endpoint,
    );
    if (!forceRefresh) {
      final cached = _getFromCache(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final queryParams = <String>[
        'merchantId=$merchantId',
        'filter=${filter.javaQueryValue}',
      ];
      if (outletId != null && outletId > 0) {
        queryParams.add('outletId=$outletId');
      }

      final token = Preferences.getString('authToken');
      final url =
          'http://187.127.156.147:8084/api/$endpoint?${queryParams.join('&')}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (AppConfig.enableDebugLogs) {
        // ignore: avoid_print
        print('DashboardApiService.$endpoint url=$url');
        // ignore: avoid_print
        print('DashboardApiService.$endpoint status=${response.statusCode}');
      }

      final bodyStr = response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
      if (bodyStr.isEmpty ||
          response.statusCode < 200 ||
          response.statusCode >= 300) {
        return null;
      }

      final decoded = jsonDecode(bodyStr);
      final DashboardModel model;
      if (decoded is List) {
        model = DashboardModel.fromJavaSettlementListJson(decoded);
      } else if (decoded is Map) {
        model = DashboardModel.fromJavaSalesReportJson(
          Map<String, dynamic>.from(decoded as Map),
        );
      } else {
        return null;
      }
      _saveToCache(cacheKey, model);
      return model;
    } catch (e, st) {
      print('DashboardApiService.$endpoint error: $e $st');
      return null;
    }
  }

  /// Java API: GET `http://187.127.156.147:8084/api/co/sales-report`
  /// Coming / pending earnings.
  static Future<DashboardModel?> getComingEarningsReport({
    required int merchantId,
    int? outletId,
    DashboardFilter filter = DashboardFilter.none,
    bool forceRefresh = false,
  }) {
    return _fetchJavaSalesReport(
      endpoint: 'co/sales-report',
      merchantId:merchantId,
      outletId: outletId,
      filter: filter,
      forceRefresh: forceRefresh,
    );
  }

  /// Java API: GET `http://187.127.156.147:8084/api/div`
  /// Settled earnings.
  static Future<DashboardModel?> getSettledEarningsReport({
    required int merchantId,
    int? outletId,
    DashboardFilter filter = DashboardFilter.none,
    bool forceRefresh = false,
  }) {
    return _fetchJavaSalesReport(
      endpoint: 'div',
      merchantId: merchantId,
      outletId: outletId,
      filter: filter,
      forceRefresh: forceRefresh,
    );
  }

  /// Backwards-compatible wrappers (avoid touching unrelated callers).
  static Future<DashboardModel?> getJavaSalesReport({
    required int merchantId,
    int? outletId,
    DashboardFilter filter = DashboardFilter.none,
    bool forceRefresh = false,
  }) {
    return getComingEarningsReport(
      merchantId: merchantId,
      outletId: outletId,
      filter: filter,
      forceRefresh: forceRefresh,
    );
  }

  static Future<DashboardModel?> getJavaSettledSalesReport({
    required int merchantId,
    int? outletId,
    DashboardFilter filter = DashboardFilter.none,
    bool forceRefresh = false,
  }) {
    return getSettledEarningsReport(
      merchantId: merchantId,
      outletId: outletId,
      filter: filter,
      forceRefresh: forceRefresh,
    );
  }

  static Future<bool> restoreOutletAvailability({
    required String type,
    required int unavailabilityId,
    required String reason,
  }) async {
    // OUTLET open — PATCH /api/fm/outlet-unavailability/restore (type=OUTLET, id=outletId)
    return FireStoreUtils.restoreOutletItemAvailability(
      type: type,
      unavailabilityId: unavailabilityId,
      reason: reason,
    );
  }


}

class _CachedDashboard {
  _CachedDashboard({
    required this.data,
    required this.expiresAt,
  });

  final DashboardModel data;
  final DateTime expiresAt;
}
