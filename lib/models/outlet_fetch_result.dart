import 'package:jippymart_restaurant/models/outlet_model.dart';

enum OutletFetchStatus {
  loading,
  success,
  empty,
  httpError,
  apiError,
  parseError,
}

class OutletFetchResult {
  final OutletFetchStatus status;
  final OutletModel? outlet;
  final int? merchantId;
  final int? outletId;
  final int? httpStatusCode;
  final String? message;
  final bool hadParseWarning;

  const OutletFetchResult({
    required this.status,
    this.outlet,
    this.merchantId,
    this.outletId,
    this.httpStatusCode,
    this.message,
    this.hadParseWarning = false,
  });

  bool get isSuccess => status == OutletFetchStatus.success;

  bool get hasMerchantId => merchantId != null && merchantId! > 0;

  factory OutletFetchResult.loading() => const OutletFetchResult(
        status: OutletFetchStatus.loading,
      );

  factory OutletFetchResult.success({
    required OutletModel outlet,
    required int merchantId,
    required int outletId,
    bool hadParseWarning = false,
  }) =>
      OutletFetchResult(
        status: OutletFetchStatus.success,
        outlet: outlet,
        merchantId: merchantId,
        outletId: outletId,
        hadParseWarning: hadParseWarning,
      );

  factory OutletFetchResult.httpError(int code, String body) =>
      OutletFetchResult(
        status: OutletFetchStatus.httpError,
        httpStatusCode: code,
        message: 'HTTP $code',
      );

  factory OutletFetchResult.apiError(String message) => OutletFetchResult(
        status: OutletFetchStatus.apiError,
        message: message,
      );

  factory OutletFetchResult.parseError(String message) => OutletFetchResult(
        status: OutletFetchStatus.parseError,
        message: message,
      );

  factory OutletFetchResult.empty() => const OutletFetchResult(
        status: OutletFetchStatus.empty,
        message: 'No outlet data',
      );
}
