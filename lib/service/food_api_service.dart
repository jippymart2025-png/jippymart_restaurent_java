import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/master_product_model.dart';
import 'package:jippymart_restaurant/models/selected_product_model.dart';

import '../models/bulkstore_product_model.dart';
import '../utils/fire_store_utils.dart';
import '../utils/preferences.dart';

/// API service for Add from Catalog flow: master-products and bulk store.
/// Categories use existing FireStoreUtils.getVendorCategoryById() (restaurant/vendor-categories).
/// Sends vendorID from Constant.userModel in the request (no auth token).
class FoodApiService {
  static final _baseUrl = Constant.baseUrl;

  static Map<String, String> _headers({bool formEncoded = false}) {
    return {
      'Content-Type': formEncoded ? 'application/x-www-form-urlencoded' : 'application/json',
      'Accept': 'application/json',
    };
  }

  static String? get _vendorId => Constant.userModel?.vendorID;

  /// GET /api/foods/master-products?category_id=...&vendorID=...&page=1&per_page=10&search=
  // static Future<MasterProductsResponse?> getMasterProductsByCategory(
  //   String categoryId, {
  //   int page = 1,
  //   int perPage = 10,
  //   String? search,
  // }) async {
  //   try {
  //     var url = '${_baseUrl}foods/master-products?category_id=${Uri.encodeComponent(categoryId)}&page=$page&per_page=$perPage';
  //     if (_vendorId != null && _vendorId!.isNotEmpty) {
  //       url += '&vendorID=${Uri.encodeComponent(_vendorId!)}';
  //     }
  //     if (search != null && search.trim().isNotEmpty) {
  //       url += '&search=${Uri.encodeComponent(search.trim())}';
  //     }
  //     final response = await http.get(Uri.parse(url), headers: _headers());
  //     if (response.statusCode != 200) {
  //       return MasterProductsResponse(success: false, message: '${response.statusCode}: ${response.body}', products: [], pagination: null);
  //     }
  //     final body = response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
  //     if (body.isEmpty) return null;
  //     final json = jsonDecode(body) as Map<String, dynamic>;
  //     final success = json['success'] == true;
  //     final productsList = json['products'] as List<dynamic>? ?? [];
  //     final products = productsList.map((e) => MasterProductModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  //     Map<String, dynamic>? paginationMap;
  //     if (json['pagination'] is Map) {
  //       paginationMap = Map<String, dynamic>.from(json['pagination'] as Map);
  //     }
  //     return MasterProductsResponse(
  //       success: success,
  //       message: json['message']?.toString(),
  //       products: products,
  //       pagination: paginationMap != null ? PaginationInfo.fromJson(paginationMap) : null,
  //     );
  //   } catch (e, st) {
  //     print('FoodApiService.getMasterProductsByCategory error: $e $st');
  //     return null;
  //   }
  // }

  static Future<MasterProductsResponse?> getMasterProductsByCategory(
      String categoryId, {
        int page = 1,
        int perPage = 10,
        String? search,
      }) async {
    try {
      String url =
          'http://187.127.156.147:8084/api/fm/master-products/category/$categoryId';
      if (search != null && search.trim().isNotEmpty) {
        url += '?keyword=${Uri.encodeComponent(search.trim())}';
      }

      print("Products URL => $url");
      final token = Preferences.getString('authToken');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },

      );

      print("Products Status => ${response.statusCode}");
      print("Products Response => ${response.body}");

      if (response.statusCode != 200) {
        return MasterProductsResponse(
          success: false,
          message: '${response.statusCode}: ${response.body}',
          products: [],
          pagination: null,
        );
      }

      final body =
      response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();

      if (body.isEmpty) {
        return MasterProductsResponse(
          success: false,
          message: 'Empty response',
          products: [],
          pagination: null,
        );
      }

      final json =
      jsonDecode(body) as Map<String, dynamic>;

      final success = json['success'] == true;

      final List<dynamic> productsList =
          json['data'] ?? [];

      final List<MasterProductModel> products =
      productsList
          .map(
            (e) => MasterProductModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();

      print("Products Count => ${products.length}");

      return MasterProductsResponse(
        success: success,
        message: json['message']?.toString(),
        products: products,
        pagination: null,
      );
    } catch (e, st) {
      print(
          'FoodApiService.getMasterProductsByCategory error: $e');
      print(st);
      return null;
    }
  }

  /// POST /api/foods/store with form-encoded selected_products. Sends vendorID in body.
//   static Future<BulkStoreResponse> bulkStoreProducts(List<SelectedProductModel> selected) async {
//     final pairs = buildStoreFormBody(selected);
//     if (_vendorId != null && _vendorId!.isNotEmpty) {
//       pairs.insert(0, MapEntry('vendorID', _vendorId!));
//     }
//     final body = encodeFormBody(pairs);
//     try {
//       final response = await http.post(
//         Uri.parse('${_baseUrl}foods/store'),
//         headers: _headers(formEncoded: true),
//         body: body,
//       );
//       final bodyStr = response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
//       Map<String, dynamic> json = {};
//       if (bodyStr.isNotEmpty) {
//         try {
//           json = jsonDecode(bodyStr) as Map<String, dynamic>;
//         } catch (_) {}
//       }
//       final success = json['success'] == true && response.statusCode >= 200 && response.statusCode < 300;
//       return BulkStoreResponse(
//         success: success,
//         message: json['message']?.toString() ?? (success ? 'Success' : 'Request failed'),
//         imported: (json['imported'] is int) ? json['imported'] as int : (success ? selected.length : 0),
//         errors: json['errors'] is Map ? Map<String, dynamic>.from(json['errors'] as Map) : null,
//         statusCode: response.statusCode,
//       );
//     } catch (e, st) {
//       print('FoodApiService.bulkStoreProducts error: $e $st');
//       return BulkStoreResponse(success: false, message: e.toString(), imported: 0, errors: null, statusCode: 0);
//     }
//   }
// }

  static Future<BulkStoreResponse> bulkStoreProducts(
    List<SelectedProductModel> selected, {
    required int outletCategoryId,
  }) async {
    try {
      final outletId = Preferences.getInt('outletId');
      final List<BulkStoreProductItemModel> productRequests = selected.map((p) {return BulkStoreProductItemModel(
          productName: p.productName ?? "",
          description: p.description ?? "",
          merchantPrice: (p.merchantPrice ?? 0).toDouble(),
          isVeg: p.isVeg ?? false,
          hasProductVariants: false,
          variants: [],
          masterProductId: int.tryParse(
            p.masterProductId ?? "0",
          ) ??
              0,
          categoryId: int.tryParse(
            p.categoryId ?? "0",
          ) ??
              0,
        );
      }).toList();
      final token = Preferences.getString('authToken');
      final requestBody = BulkStoreProductModel(
        outletId: outletId,
        outletCategoryId: outletCategoryId,
        products: productRequests,
      ).toJson();
      print("REQUEST = ${jsonEncode(requestBody)}");
      print(jsonEncode(requestBody));
      final response = await http.post(
        Uri.parse(
            'http://187.127.156.147:8084/api/fm/products/from-master'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print("STATUS CODE = ${response.statusCode}");
      print("RESPONSE = ${response.body}");

      final bodyStr =
      response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();

      Map<String, dynamic> json = {};

      if (bodyStr.isNotEmpty) {
        try {
          json = jsonDecode(bodyStr) as Map<String, dynamic>;
        } catch (e) {
          print("JSON Decode Error: $e");
        }
      }

      final httpSuccess =
          response.statusCode >= 200 && response.statusCode < 300;

      final savedCount = _parseCount(json['savedCount']);
      final skippedCount = _parseCount(json['skippedCount']);
      final apiMessage = json['message']?.toString();
      final success = httpSuccess && savedCount > 0;

      if (success) {
        FireStoreUtils.invalidateOutletProductCache(outletId);
        FireStoreUtils.invalidateVendorCategoryCache();
      }

      return BulkStoreResponse(
        success: success,
        message: success
            ? 'Saved: $savedCount, Skipped: $skippedCount'
            : (apiMessage?.isNotEmpty == true
                ? apiMessage!
                : 'Request failed (${response.statusCode})'),
        imported: savedCount,
        errors: null,
        statusCode: response.statusCode,
      );
    } catch (e, st) {
      print('FoodApiService.bulkStoreProducts error: $e');
      print(st);

      return BulkStoreResponse(
        success: false,
        message: e.toString(),
        imported: 0,
        errors: null,
        statusCode: 0,
      );
    }
  }

  static int _parseCount(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }




}
class MasterProductsResponse {
  final bool success;
  final String? message;
  final List<MasterProductModel> products;
  final PaginationInfo? pagination;

  MasterProductsResponse({required this.success, this.message, required this.products, this.pagination});
}

class PaginationInfo {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int? from;
  final int? to;

  PaginationInfo({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    this.from,
    this.to,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: (json['current_page'] is int) ? json['current_page'] as int : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      perPage: (json['per_page'] is int) ? json['per_page'] as int : int.tryParse(json['per_page']?.toString() ?? '10') ?? 10,
      total: (json['total'] is int) ? json['total'] as int : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      lastPage: (json['last_page'] is int) ? json['last_page'] as int : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      from: json['from'] is int ? json['from'] as int : int.tryParse(json['from']?.toString() ?? ''),
      to: json['to'] is int ? json['to'] as int : int.tryParse(json['to']?.toString() ?? ''),
    );
  }
}

class BulkStoreResponse {
  final bool success;
  final String message;
  final int imported;
  final Map<String, dynamic>? errors;
  final int statusCode;

  BulkStoreResponse({required this.success, required this.message, required this.imported, this.errors, required this.statusCode});
}
