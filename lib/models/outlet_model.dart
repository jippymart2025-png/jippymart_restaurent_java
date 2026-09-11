import 'package:flutter/foundation.dart';

class OutletModel {
  int? outletId;
  String? outletName;
  int? merchantId;
 // int? outletCategoryId;
  List<int>? cuisineTypeIds;
  String? outletPhone;
  String? alternateOutletPhone;
  String? isActive;
  String? outletLoginId;
  String? outletPassword;
  // ADDED — needed for Edit Profile (outlet mode)
  String? outletEmail;
  int? radius;
  bool? isApproved;
  String? outletPicUrl;
  double? latitude;
  double? longitude;
  // Address
  String? buildingNumber;
  String? road;
  String? landmark;
  int? stateId;
  int? cityId;
  int? areaId;
  final String? cuisineTypeNames;
  final bool? isVegOutlet;
  final String? stateName;
  final String? cityName;
  final String? areaName;
  List<Map<String, dynamic>>? operatingDays;
  // Bank
  String? accountNumber;
  String? ifscCode;
  String? bankName;
  String? accountHolderName;
  final String? fssaiNumber;
  final String? gstNumber;
  final bool? isGstApplied;
  // Document URLs (verification)
  final String? aadhaarNumberUrl;
  final String? panNumberUrl;
  final String? fssaiNumberUrl;
  final String? gstNumberUrl;

  OutletModel({
    this.outletId,
    this.outletName,
    this.merchantId,
    //this.outletCategoryId,
    this.cuisineTypeIds,
    this.outletPhone,
    this.alternateOutletPhone,
    this.fssaiNumber,
    this.gstNumber,
    this.isGstApplied,
    this.isActive,
    this.outletLoginId,
    this.outletPassword,
    // ADDED — needed for Edit Profile (outlet mode)
    this.outletEmail,
    this.radius,
    this.isApproved,
    this.outletPicUrl,
    this.latitude,
    this.longitude,
    // Address
    this.buildingNumber,
    this.road,
    this.landmark,
    this.stateId,
    this.cityId,
    this.areaId,
    this.cuisineTypeNames,
    this.isVegOutlet,
    this.stateName,
    this.cityName,
    this.areaName,
    this.operatingDays,
// Bank
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.accountHolderName,
    this.aadhaarNumberUrl,
    this.panNumberUrl,
    this.fssaiNumberUrl,
    this.gstNumberUrl,
  });

  factory OutletModel.fromJson(Map<String, dynamic> json) =>
      OutletModel.fromJsonSafe(json);

  /// Safe parser — ignores malformed [outletLocation] and nested envelope data.
  factory OutletModel.fromJsonSafe(Map<String, dynamic> json) {
    try {
      final sanitized = _sanitizeOutletMap(json);
      return OutletModel(
        outletId: parseOutletIdFromMap(sanitized),
        outletName: sanitized['outletName']?.toString(),
        merchantId: parseIntSafe(sanitized['merchantId']),
        //outletCategoryId: parseIntSafe(sanitized['outletCategoryId']),
        cuisineTypeIds: _parseCuisineTypeIds(sanitized['cuisineType']),
        outletPhone: sanitized['outletPhone']?.toString(),
        alternateOutletPhone: sanitized['alternateOutletPhone']?.toString(),
        fssaiNumber: json['fssaiNumber'],
        gstNumber: json['gstNumber'],
        isGstApplied: json['isGstApplied'] is bool ? json['isGstApplied'] as bool : null,
        isVegOutlet: parseBoolSafe(sanitized['isVegOutlet']),
        //isVegOutlet: sanitized['isVegOutlet'] is bool ? sanitized['isVegOutlet'] as bool : null,
        // Address
        buildingNumber: sanitized['buildingNumber']?.toString(),
        road: sanitized['road']?.toString(),
        landmark: sanitized['landmark']?.toString(),
        stateId: parseIntSafe(sanitized['stateId']),
        cityId: parseIntSafe(sanitized['cityId']),
        areaId: parseIntSafe(sanitized['areaId']),
        operatingDays: _parseOperatingDays(sanitized['operatingDays']),
        // Bank
        accountNumber: sanitized['accountNumber']?.toString(),
        ifscCode: sanitized['ifscCode']?.toString(),
        bankName: sanitized['bankName']?.toString(),
        accountHolderName: sanitized['accountHolderName']?.toString(),
        isActive: sanitized['isActive']?.toString(),
        outletLoginId: sanitized['outletLoginId']?.toString(),
        outletPassword: sanitized['outletPassword']?.toString(),
        // ADDED
        outletEmail: sanitized['outletEmail']?.toString(),
        radius: parseIntSafe(sanitized['radius']),
        isApproved: sanitized['isApproved'] is bool
            ? sanitized['isApproved'] as bool
            : null,
        outletPicUrl: sanitized['outletPicUrl']?.toString(),
        latitude: parseDoubleSafe(sanitized['latitude']),
        longitude: parseDoubleSafe(sanitized['longitude']),
        aadhaarNumberUrl: sanitized['aadhaarNumberUrl']?.toString(),
        panNumberUrl: sanitized['panNumberUrl']?.toString(),
        fssaiNumberUrl: sanitized['fssaiNumberUrl']?.toString(),
        gstNumberUrl: sanitized['gstNumberUrl']?.toString(),
      );
    } catch (e, stackTrace) {
      debugPrint('[OutletModel] fromJsonSafe fallback — $e\n$stackTrace');
      return OutletModel(
        outletId: parseOutletIdFromMap(json),
        merchantId: parseIntSafe(json['merchantId']),
        outletName: json['outletName']?.toString(),
      );
    }
  }

  // ADDED — safely parses cuisineType as List<int>, handles null/malformed input
  static List<int>? _parseCuisineTypeIds(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value
          .map((e) => parseIntSafe(e))
          .whereType<int>()
          .toList();
    }
    return null;
  }
  // ADDED — parses flat operatingDays list from GET response
  static List<Map<String, dynamic>>? _parseOperatingDays(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return null;
  }
// ADDED — mirrors parseIntSafe
  static double? parseDoubleSafe(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }
  /// Strips fields that may contain deeply nested / invalid envelope structures.
  static Map<String, dynamic> _sanitizeOutletMap(Map<String, dynamic> json) {
    final copy = <String, dynamic>{};
    for (final entry in json.entries) {
      if (entry.key == 'outletLocation' ||
          entry.key == 'location' ||
          entry.key == 'envelope') {
        continue;
      }
      final value = entry.value;
      if (value is Map && _isEnvelopeLike(value)) {
        continue;
      }
      copy[entry.key] = value;
    }
    return copy;
  }

  static bool _isEnvelopeLike(Map map) {
    return map.containsKey('envelope') ||
        map.containsKey('coordinates') ||
        map.containsKey('type');
  }
// ADDED — safely parses bool from bool/String, mirrors parseIntSafe
  static bool? parseBoolSafe(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return null;
  }

  static int? parseIntSafe(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  /// Resolves outlet id from API maps — never treats [merchantId] as outlet id.
  static int? parseOutletIdFromMap(Map<String, dynamic> json) {
    final explicit =
        parseIntSafe(json['outletId']) ?? parseIntSafe(json['outlet_id']);
    if (explicit != null && explicit > 0) return explicit;

    final merchantId = parseIntSafe(json['merchantId']);
    final userId = parseIntSafe(json['userId']);
    final id = parseIntSafe(json['id']);

    if (id != null &&
        id > 0 &&
        id != merchantId &&
        id != userId) {
      return id;
    }
    return null;
  }

  /// Extract merchantId directly from a raw map without parsing nested fields.
  static int? extractMerchantId(Map<String, dynamic> json) {
    return parseIntSafe(json['merchantId']);
  }

  /// Last-resort extraction from raw JSON string when decode fails.
  static int? extractMerchantIdFromRaw(String body) {
    final match =
        RegExp(r'"merchantId"\s*:\s*"?(\d+)"?').firstMatch(body);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  static int? extractOutletIdFromRaw(String body) {
    final match = RegExp(r'"outletId"\s*:\s*"?(\d+)"?').firstMatch(body);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }
}
