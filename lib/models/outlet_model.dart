import 'package:flutter/foundation.dart';

class OutletModel {
  int? outletId;
  String? outletName;
  int? merchantId;
  int? outletCategoryId;
  String? cuisineType;
  String? outletPhone;
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

  // Bank
  String? accountNumber;
  String? ifscCode;
  String? bankName;
  String? accountHolderName;
  final String? fssaiNumber;
  final String? gstNumber;

  OutletModel({
    this.outletId,
    this.outletName,
    this.merchantId,
    this.outletCategoryId,
    this.cuisineType,
    this.outletPhone,
    this.fssaiNumber,
    this.gstNumber,
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

// Bank
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.accountHolderName,
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
        outletCategoryId: parseIntSafe(sanitized['outletCategoryId']),
        cuisineType: sanitized['cuisineType']?.toString(),
        outletPhone: sanitized['outletPhone']?.toString(),
        fssaiNumber: json['fssaiNumber'],
        gstNumber: json['gstNumber'],
        // Address
        buildingNumber: sanitized['buildingNumber']?.toString(),
        road: sanitized['road']?.toString(),
        landmark: sanitized['landmark']?.toString(),
        stateId: parseIntSafe(sanitized['stateId']),
        cityId: parseIntSafe(sanitized['cityId']),
        areaId: parseIntSafe(sanitized['areaId']),
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
