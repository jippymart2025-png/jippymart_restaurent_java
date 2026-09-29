import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/app/auth_screen/controllers/login_controller.dart';
import 'package:mime/mime.dart';
import 'package:jippymart_restaurant/app/chat_screens/ChatVideoContainer.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/advertisement_model.dart';
import 'package:jippymart_restaurant/models/conversation_model.dart';
import 'package:jippymart_restaurant/models/inbox_model.dart';
import 'package:jippymart_restaurant/models/notification_model.dart';
import 'package:jippymart_restaurant/models/product_model.dart';
import 'package:jippymart_restaurant/models/rating_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';
import 'package:jippymart_restaurant/models/wallet_transaction_model.dart';
import 'package:jippymart_restaurant/models/withdraw_method_model.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/create_master_product_model.dart';
import '../models/cuisine_type_model.dart';
import '../models/merchant_response_model.dart';
import '../models/merchant_request_model.dart';
import '../models/outlet_details_model.dart';
import '../models/outlet_fetch_result.dart';
import '../models/outlet_model.dart';
import '../models/outlet_product_model.dart';
import '../models/promotion_models.dart';
import '../models/variant_group_model.dart';
import 'common.dart';

class _ProductCacheEntry {
  final List<ProductModel> list;
  final DateTime cachedAt;
  _ProductCacheEntry(this.list, this.cachedAt);
}

class _OutletProductsCacheEntry {
  final OutletProductsResult result;
  final DateTime cachedAt;
  _OutletProductsCacheEntry(this.result, this.cachedAt);
}

class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static VendorModel? _cachedVendor;
  static String? _cachedVendorId;
  static DateTime? _vendorCacheTime;
  static const Duration _vendorCacheTTL = Duration(minutes: 5);

  // Product list cache: keyed by vendorID, TTL 3 minutes
  static final Map<String, _ProductCacheEntry> _productCache = {};
  static const Duration _productCacheTTL = Duration(minutes: 3);

  // Outlet inventory cache: keyed by outletId, TTL 3 minutes
  static final Map<int, _OutletProductsCacheEntry> _outletProductCache = {};
  static String? _lastOutletProductsError;

  static String? get lastOutletProductsError => _lastOutletProductsError;

  // Resolved outlet id cache: avoids a getMerchantOutlets API call on every
  // menu access. Cleared when the logged-in merchant/outlet session changes.
  static int? _cachedResolvedOutletId;
  static DateTime? _cachedResolvedOutletTime;
  static const Duration _resolvedOutletCacheTTL = Duration(minutes: 5);

  // In-flight guard: if two callers request the same merchant's outlets while
  // a request is already running, they share one network call instead of two.
  static final Map<int, Future<List<OutletModel>>> _merchantOutletsInFlight = {
  };

  // Vendor categories cache: one global list per app session, TTL 3 minutes
  static List<VendorCategoryModel>? _cachedVendorCategories;
  static DateTime? _vendorCategoriesCacheTime;
  static const Duration _vendorCategoriesCacheTTL = Duration(minutes: 3);

  static void clearVendorCategoriesCache() {
    _cachedVendorCategories = null;
    _vendorCategoriesCacheTime = null;
  }

  static List<VariantGroupModel>? _cachedVariantGroups;
  static DateTime? _variantGroupsCacheTime;

  static const Duration _variantGroupsCacheTTL =
  Duration(minutes: 30);
  final loginController = Get.find<LoginController>(); // Finds existing instance


  static void _invalidateVendorCache() {
    _cachedVendor = null;
    _cachedVendorId = null;
    _vendorCacheTime = null;
  }

  /// Call after create/update vendor so next getVendorById() fetches fresh data from server.
  static void invalidateVendorCache() {
    _invalidateVendorCache();
  }


  static Future<String> getCurrentUid() async {
    // final firebaseId = await getFirebaseId() ?? '';
    // if (firebaseId.isNotEmpty) return firebaseId;

    final userId = Preferences.getInt('userId');
    if (userId > 0) return userId.toString();

    final userIdStr = Preferences.getString('user_id');
    if (userIdStr.isNotEmpty) return userIdStr;

    return '';
  }

  static Future<bool> isLogin() async {
    final token = Preferences.getString('authToken');
    final loggedIn = Preferences.pref.getBool('is_logged_in') ?? false;

    // Java API session — token + logged-in flag saved on login.
    if (loggedIn && token.isNotEmpty) {
      return true;
    }

    return false;
  }



static Future<MerchantModel?> getMerchantProfile(String merchantId) async {
    try {
      if (merchantId
          .trim()
          .isEmpty) {
        debugPrint("Merchant ID is empty");
        return null;
      }

      final headers = await getHeaders();
      final url =
          '${Constant
          .baseUrl}fm/merchants/getMerchantProfile?merchantId=$merchantId';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        debugPrint("Merchant Profile JSON = $jsonData");

        final profileData = jsonData is Map<String, dynamic> &&
            jsonData['data'] is Map
            ? Map<String, dynamic>.from(jsonData['data'] as Map)
            : Map<String, dynamic>.from(jsonData as Map);

        print(profileData);
        return MerchantModel.fromJson(profileData);
      }

      debugPrint(
        "Failed to fetch profile. Status: ${response.statusCode}",
      );
      return null;
    } catch (e, stackTrace) {
      debugPrint("getMerchantProfile Error: $e");
      print(stackTrace);
      return null;
    }
  }


  static Future<bool> updateMerchantProfile(String merchantId,
      MerchantModel merchant) async {
    try {
      final headers = await getHeaders();
      final parsedMerchantId = int.tryParse(merchantId);
      if (parsedMerchantId == null) {
        log("updateMerchantProfile error: invalid merchantId '$merchantId'");
        return false;
      }

      final Map<String, dynamic> body = {
        'merchantId': parsedMerchantId,
        'merchantName': merchant.merchantName,
        'businessType': merchant.merchantBusinessType,
        //'status': merchant.status,
        'merchantEmail': merchant.merchantEmail,
        'merchantPhone': merchant.merchantPhone,
        'bankId': merchant.bankId,
        'recipientId': merchant.recipientId,
        'accountNumber': merchant.accountNumber,
        'ifscCode': merchant.ifscCode,
        'bankName': merchant.bankName,
        'accountHolderName': merchant.accountHolderName,
        'userType': 'MERCHANT',
        'aadharNumber': merchant.addharNumber,
        'panNumber': merchant.panNumber,
      };

      debugPrint("===== UPDATE MERCHANT REQUEST =====");
      debugPrint(json.encode(body));

      final response = await http.put(
        Uri.parse('${Constant.baseUrl}fm/merchants/updateMerchantProfile'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("updateMerchantProfile success: ${response.body}");
        return true;
      } else {
        log("updateMerchantProfile failed: ${response.statusCode} - ${response
            .body}");
        return false;
      }
    } catch (e) {
      log("updateMerchantProfile error: $e");
      return false;
    }
  }

  //(end)
//  THIS IS JAVA API OF CREATE MERCHANT PROFILE   create merchant profile
  static Future<MerchantModel?> createMerchant(
      MerchantRequestModel request,) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse(
          '${Constant.baseUrl}fm/merchants/createMerchant',
        ),
        headers: headers,
        body: jsonEncode(
          request.toJson(),
        ),
      );

      debugPrint("Status Code : ${response.statusCode}");
      debugPrint("Response : ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final jsonResponse =
        jsonDecode(response.body);

        return MerchantModel.fromJson(
          jsonResponse['data'],
        );
      }

      return null;
    } catch (e) {
      debugPrint("createMerchant Error : $e");
      return null;
    }
  }

  // end
  // THIS IS THE CODE OF JAVA GETTING THE LIST OF OUTLETS BY USING THE MERCHANT ID
  static Future<List<OutletModel>> getMerchantOutlets(int merchantId) async {
    // Share one network call between concurrent callers for the same merchant.
    final inFlight = _merchantOutletsInFlight[merchantId];
    if (inFlight != null) return inFlight;

    final future = _getMerchantOutlets(merchantId);
    _merchantOutletsInFlight[merchantId] = future;
    try {
      return await future;
    } finally {
      if (identical(_merchantOutletsInFlight[merchantId], future)) {
        _merchantOutletsInFlight.remove(merchantId);
      }
    }
  }

  static Future<List<OutletModel>> _getMerchantOutlets(int merchantId) async {
    try {
      //final token = Preferences.getString('authToken');
      final headers = await getHeaders();
      final url = '${Constant.baseUrl}fm/outlets/merchant/$merchantId';

      debugPrint("===== getMerchantOutlets API =====");
      debugPrint("URL: $url");
      debugPrint("merchantId: $merchantId");

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        final dynamic rawData = jsonResponse['data'];
        final List<dynamic> data = rawData is List
            ? rawData
            : rawData == null
            ? <dynamic>[]
            : <dynamic>[];

        debugPrint("API DATA COUNT = ${data.length}");

        final outlets = data
            .map((e) {
          try {
            if (e is Map<String, dynamic>) {
              return OutletModel.fromJsonSafe(e);
            }
            if (e is Map) {
              return OutletModel.fromJsonSafe(
                Map<String, dynamic>.from(e),
              );
            }
          } catch (parseError) {
            debugPrint("Outlet list item parse warning: $parseError");
          }
          return null;
        })
            .whereType<OutletModel>()
            .toList();

        debugPrint("PARSED OUTLET COUNT = ${outlets.length}");

        return outlets;
      }

      if (response.statusCode == 404) {
        debugPrint("getMerchantOutlets: no outlets found (404)");
        return [];
      }

      return [];
    } catch (e, stackTrace) {
      debugPrint("getMerchantOutlets Error = $e");
      print(stackTrace);
      return [];
    }
  }

  /// Fetches a single outlet by ID with safe parsing and structured result.
  static Future<OutletFetchResult> fetchOutletById(int outletId) async {
    try {
      //final token = Preferences.getString('authToken');
      final headers = await getHeaders();
      final url = '${Constant.baseUrl}fm/outlets/getOutletById/$outletId';

      debugPrint("===== getOutletById API =====");
      debugPrint("URL: $url");
      debugPrint("outletId: $outletId");

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      final parsed = _parseOutletFetchResult(response.body, outletId);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint("[getOutletById] HTTP failure — ${response.statusCode}");
        if (parsed.isSuccess && parsed.outletId != null) {
          return parsed;
        }
        return OutletFetchResult.httpError(
          response.statusCode,
          response.body,
        );
      }

      return parsed;
    } catch (e, stackTrace) {
      debugPrint("getOutletById Error = $e");
      print(stackTrace);
      return OutletFetchResult.parseError(e.toString());
    }
  }

  static OutletFetchResult _parseOutletFetchResult(String body,
      int requestedOutletId,) {
    Map<String, dynamic>? decoded;
    try {
      final raw = jsonDecode(body);
      if (raw is Map<String, dynamic>) {
        decoded = raw;
      } else if (raw is Map) {
        decoded = Map<String, dynamic>.from(raw);
      }
    } catch (decodeError, stackTrace) {
      debugPrint("[getOutletById] JSON decode error — $decodeError");
      print(stackTrace);

      final fallbackMerchantId = OutletModel.extractMerchantIdFromRaw(body);
      if (fallbackMerchantId != null && fallbackMerchantId > 0) {
        debugPrint(
          "[getOutletById] Fallback merchantId=$fallbackMerchantId from raw body",
        );
        final fallbackOutletId = OutletModel.extractOutletIdFromRaw(body);
        if (fallbackOutletId != null && fallbackOutletId > 0) {
          return OutletFetchResult.success(
            outlet: OutletModel(
              outletId: fallbackOutletId,
              merchantId: fallbackMerchantId,
            ),
            merchantId: fallbackMerchantId,
            outletId: fallbackOutletId,
            hadParseWarning: true,
          );
        }
      }
      return OutletFetchResult.parseError(decodeError.toString());
    }

    if (decoded == null) {
      return OutletFetchResult.empty();
    }

    if (decoded['success'] == false) {
      final msg =
          decoded['message']?.toString() ?? 'API returned success=false';
      debugPrint("[getOutletById] API failure — $msg");
      return OutletFetchResult.apiError(msg);
    }

    final dynamic rawData = decoded['data'] ?? decoded;
    if (rawData is! Map) {
      debugPrint("[getOutletById] No outlet data map in response");
      return OutletFetchResult.empty();
    }

    final dataMap = Map<String, dynamic>.from(rawData);

    OutletModel outlet;
    var hadParseWarning = false;
    try {
      outlet = OutletModel.fromJsonSafe(dataMap);
    } catch (parseError, stackTrace) {
      hadParseWarning = true;
      debugPrint("[getOutletById] Model parse warning — $parseError");
      print(stackTrace);
      outlet = OutletModel(
        outletId: OutletModel.parseOutletIdFromMap(dataMap),
        merchantId: OutletModel.extractMerchantId(dataMap),
        outletName: dataMap['outletName']?.toString(),
      );
    }

    final merchantId =
        outlet.merchantId ?? OutletModel.extractMerchantId(dataMap);
    final resolvedOutletId = outlet.outletId ??
        OutletModel.parseOutletIdFromMap(dataMap);

    if (resolvedOutletId == null || resolvedOutletId <= 0) {
      debugPrint('[getOutletById] outletId missing in response body');
      return OutletFetchResult.apiError('outletId missing in outlet response');
    }

    debugPrint(
      "[getOutletById] Parsed merchantId=$merchantId outletId=$resolvedOutletId",
    );

    if (merchantId == null || merchantId <= 0) {
      final fallbackMerchantId = OutletModel.extractMerchantIdFromRaw(body);
      if (fallbackMerchantId != null && fallbackMerchantId > 0) {
        debugPrint(
            "[getOutletById] Using fallback merchantId=$fallbackMerchantId");
        return OutletFetchResult.success(
          outlet: OutletModel(
            outletId: resolvedOutletId,
            merchantId: fallbackMerchantId,
            outletName: outlet.outletName,
          ),
          merchantId: fallbackMerchantId,
          outletId: resolvedOutletId,
          hadParseWarning: true,
        );
      }
      return OutletFetchResult.apiError(
        'merchantId missing in outlet response',
      );
    }

    return OutletFetchResult.success(
      outlet: outlet.outletId != null
          ? outlet
          : OutletModel(
        outletId: resolvedOutletId,
        merchantId: merchantId,
        outletName: outlet.outletName,
        // outletCategoryId: outlet.outletCategoryId,
      ),
      merchantId: merchantId,
      outletId: resolvedOutletId,
      hadParseWarning: hadParseWarning,
    );
  }

  /// Backward-compatible wrapper — returns outlet model or null.
  static Future<OutletModel?> getOutletById(int outletId) async {
    final result = await fetchOutletById(outletId);
    return result.isSuccess ? result.outlet : null;
  }

  static Future<bool> updateUser(UserModel userModel) async {
    bool isUpdate = false;
    try {
      // String? userId = await getFirebaseId();
      // userModel.id = userId;
      debugPrint("updateUser  ${ userModel.toJson()}");
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/updateUser'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(userModel.toJson()),
      );

      if (response.statusCode == 200) {
        Constant.userModel = userModel;
        isUpdate = true;
      } else {
        log("Failed to update user: ${response.statusCode} - ${response.body}");
        isUpdate = false;
      }
    } catch (error) {
      log("Failed to update users: $error");
      isUpdate = false;
    }
    return isUpdate;
  }


  /// Active outlet for merchant/outlet sessions (outlet login or merchant picked outlet).
  static int resolveActiveOutletId() {
    final outletId = Preferences.getInt('outletId');
    if (outletId > 0) return outletId;
    return Preferences.getInt('selectedOutletId');
  }

  /// Resolves the outlet id to use for getOutletDetails (merchant list is source of truth).
  static Future<int?> resolveOutletIdForMenu({int? preferredId}) async {
    final loginType = Preferences.getString('loginType').trim().toUpperCase();

    // Fast path: reuse the previously resolved outlet id. This avoids
    // hitting getMerchantOutlets/fetchOutletById APIs on every menu access.
    if (preferredId == null ||
        preferredId == _cachedResolvedOutletId) {
      final cached = _cachedResolvedOutletId;
      if (cached != null &&
          cached > 0 &&
          _cachedResolvedOutletTime != null &&
          DateTime.now().difference(_cachedResolvedOutletTime!) <
              _resolvedOutletCacheTTL) {
        return cached;
      }
    }

    if (loginType == 'MERCHANT') {
      final merchantId = int.tryParse(Preferences.getString('merchantId')) ?? 0;
      if (merchantId <= 0) {
        _lastOutletProductsError =
        'Merchant session not found. Please log in again.';
        return null;
      }

      final outlets = await getMerchantOutlets(merchantId);
      if (outlets.isEmpty) {
        _lastOutletProductsError = 'No outlets found for this merchant.';
        return null;
      }

      final storedId = preferredId ?? resolveActiveOutletId();
      final storedName = Preferences.getString('selectedOutletName').trim();

      if (storedId > 0) {
        for (final outlet in outlets) {
          final id = outlet.outletId;
          if (id != null && id > 0 && id == storedId) {
            await _syncOutletPreferences(id, outletName: outlet.outletName);
            debugPrint('[resolveOutletIdForMenu] using list outletId=$id');
            _cachedResolvedOutletId = id;
            _cachedResolvedOutletTime = DateTime.now();
            return id;
          }
        }
      }

      if (storedName.isNotEmpty) {
        for (final outlet in outlets) {
          final name = (outlet.outletName ?? '').trim();
          final id = outlet.outletId;
          if (id != null &&
              id > 0 &&
              name.isNotEmpty &&
              name.toLowerCase() == storedName.toLowerCase()) {
            debugPrint(
              '[resolveOutletIdForMenu] corrected $storedId -> $id '
                  'for outlet "$storedName"',
            );
            await _syncOutletPreferences(id, outletName: outlet.outletName);
            _cachedResolvedOutletId = id;
            _cachedResolvedOutletTime = DateTime.now();
            return id;
          }
        }
      }

      _lastOutletProductsError =
      'Selected outlet not found. Go back and select your outlet again.';
      return null;
    }

    final candidate = preferredId ?? resolveActiveOutletId();
    if (candidate <= 0) return null;

    final result = await fetchOutletById(candidate);
    if (!result.isSuccess ||
        result.outletId == null ||
        result.outletId! <= 0) {
      _lastOutletProductsError =
          result.message ?? 'Outlet session is invalid. Please log in again.';
      return null;
    }

    await _syncOutletPreferences(
      result.outletId!,
      outletName: result.outlet?.outletName,
    );
    _cachedResolvedOutletId = result.outletId;
    _cachedResolvedOutletTime = DateTime.now();
    return result.outletId;
  }

  static Future<void> _syncOutletPreferences(int outletId, {
    String? outletName,
  }) async {
    await Preferences.setInt('outletId', outletId);
    await Preferences.setInt('selectedOutletId', outletId);
    if (outletName != null && outletName
        .trim()
        .isNotEmpty) {
      await Preferences.setString('selectedOutletName', outletName.trim());
    }
  }

  /// GET /api/fm/outlets/getOutletDetails — outlet-scoped inventory (Java API).
  /// Does not replace [getProduct]; use when an outlet is selected.
  static Future<OutletProductsResult?> getOutletDetailsWithProducts({
    int? outletId,
    bool forceRefresh = false,
  }) async {
    _lastOutletProductsError = null;

    final verifiedOutletId =
    await resolveOutletIdForMenu(preferredId: outletId);
    if (verifiedOutletId == null || verifiedOutletId <= 0) {
      _lastOutletProductsError =
      'Invalid outlet session. Please go back and select your outlet again.';
      return null;
    }

    final resolvedOutletId = verifiedOutletId;

    if (!forceRefresh) {
      final entry = _outletProductCache[resolvedOutletId];
      if (entry != null &&
          DateTime.now().difference(entry.cachedAt) < _productCacheTTL) {
        return entry.result;
      }
    }

    try {
      //final loginType = Preferences.getString('loginType').trim().toUpperCase();
      //final userType = loginType == 'OUTLET' ? 'OUTLET' : 'MERCHANT';
      final userType = 'MERCHANT';
      //final token = Preferences.getString('authToken');
      final headers = await getHeaders();
      final url =
          '${Constant.baseUrl}fm/outlets/getOutletDetails'
          '?outletId=$resolvedOutletId&userType=$userType';

      debugPrint('getOutletProducts => $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      debugPrint('getOutletProducts status => ${response.statusCode}');
      debugPrint('getOutletProducts body => ${response.body}');

      if (response.statusCode != 200) {
        debugPrint(
          'getOutletProducts failed: ${response.statusCode} — ${response.body}',
        );
        try {
          final errBody = json.decode(response.body);
          if (errBody is Map && errBody['message'] != null) {
            _lastOutletProductsError = errBody['message'].toString();
          } else {
            _lastOutletProductsError =
            'Failed to load outlet menu (HTTP ${response.statusCode})';
          }
        } catch (_) {
          _lastOutletProductsError =
          'Failed to load outlet menu (HTTP ${response.statusCode})';
        }
        return null;
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map) {
        debugPrint('getOutletProducts: response is not a JSON object');
        _lastOutletProductsError = 'Invalid menu response from server';
        return const OutletProductsResult(products: [], categories: []);
      }

      final map = Map<String, dynamic>.from(decoded);
      if (map['success'] == false) {
        final msg = map['message']?.toString() ??
            'Could not load outlet menu';
        debugPrint('getOutletProducts API error: $msg');
        _lastOutletProductsError = msg;
        return null;
      }

      final dynamic rawData = map['data'] ?? map;
      Map<String, dynamic> detailsMap;
      if (rawData is Map) {
        detailsMap = Map<String, dynamic>.from(rawData);
      } else {
        debugPrint('getOutletProducts: no outlet details object in response');
        return const OutletProductsResult(products: [], categories: []);
      }

      final details = OutletDetailsModel.fromJson(detailsMap);
      final result = details.toProductsResult();
      debugPrint("========== PARSED PRODUCTS ==========");

      for (final p in result.products) {
        debugPrint(
          "Name=${p.name}, "
              "Id=${p.id}, "
              "Category=${p.categoryID}",
        );
      }

      debugPrint("Total Parsed Products = ${result.products.length}");
      _outletProductCache[resolvedOutletId] =
          _OutletProductsCacheEntry(result, DateTime.now());

      debugPrint(
        'getOutletProducts loaded ${result.products.length} products, '
            '${result.categories.length} categories',
      );

      return result;
    } catch (error, stackTrace) {
      debugPrint('getOutletProducts error: $error');
      print(stackTrace);
      _lastOutletProductsError = 'Failed to load outlet menu';
      return null;
    }
  }

  /// Call after outlet product writes to force next [getOutletProducts] to hit the API.
  static void invalidateOutletProductCache([int? outletId]) {
    if (outletId != null) {
      _outletProductCache.remove(outletId);
    } else {
      _outletProductCache.clear();
      // Outlet session may have changed; force re-resolving the outlet id.
      _cachedResolvedOutletId = null;
      _cachedResolvedOutletTime = null;
    }
  }

  static Future<List<
      PromotionOutletProductModel>?> getOutletProductsDetailsOnlyForPromotions(
      {required int outletId}) async {
    try {
      final headers = await getHeaders();
      final url = '${Constant.baseUrl}fm/products/outlet/$outletId';
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) =>
              PromotionOutletProductModel.fromJson(
                  Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      log('getOutletProductsFlat failed: ${response.statusCode} — ${response
          .body}');
      return null;
    } catch (e) {
      log('getOutletProductsFlat error: $e');
      return null;
    }
  }

  static Future<OutletSingleProductModel?> getOutletSingleProductDetails(
      int productId) async {
    try {
      final headers = await getHeaders();
      final url = '${Constant
          .baseUrl}fm/products/getCompleteProductDetails/$productId';

      debugPrint('getOutletSingleProductDetails => $url');
      final response = await http.get(Uri.parse(url), headers: headers);
      debugPrint(
          'getOutletSingleProductDetails status => ${response.statusCode}');
      debugPrint('getOutletSingleProductDetails body => ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return OutletSingleProductModel.fromJson(decoded);
        }
      }
      return null;
    } catch (e) {
      log('getOutletSingleProductDetails error: $e');
      return null;
    }
  }

  static Future<bool> updateSingleOutletProductDetails({
    required int productId,
    required OutletSingleProductModel originalProduct,
    required int categoryId,
    required String productName,
    required String description,
    required bool isVeg,
    required bool hasProductVariants,
    required num merchantPrice,
    required String imageLink,
    int? outletId,
    List<ProductVariantGroupModel>? variantGroupsOverride,
    List<ProductTimingModel>? timingsOverride,
  }) async {
    try {
      final headers = await getHeaders();
      final url =
          '${Constant
          .baseUrl}fm/products/updateCategoryAndProductDetails/$productId';

      final body = json.encode(
        originalProduct.toUpdateJson(
          productName: productName,
          outletCategoryId: categoryId,
          description: description,
          isVeg: isVeg,
          hasProductVariants: hasProductVariants,
          merchantPrice: merchantPrice,
          imageLink: imageLink,
          variantGroupsOverride: variantGroupsOverride,
          timingsOverride: timingsOverride,
        ),
      );

      debugPrint('updateSingleOutletProductDetails => $url');
      debugPrint('updateSingleOutletProductDetails body => $body');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      debugPrint(
        'updateSingleOutletProductDetails status => ${response.statusCode}',
      );
      debugPrint(
        'updateSingleOutletProductDetails resp => ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        invalidateOutletProductCache(outletId);
        return true;
      }

      return false;
    } catch (e) {
      log('updateSingleOutletProductDetails error: $e');
      return false;
    }
  }



  /// Call after any product write (set/update/delete) to force next getProduct() to hit the API.
  static void invalidateProductCache([String? vendorID]) {
    if (vendorID != null) {
      _productCache.remove(vendorID);
    } else {
      _productCache.clear();
    }
  }

  /// Call after category or product bulk updates so next getVendorCategoryById() hits the API.
  static void invalidateVendorCategoryCache() {
    _cachedVendorCategories = null;
    _vendorCategoriesCacheTime = null;
  }

  static Future<List<AdvertisementModel>?> getAdvertisement() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${Constant.baseUrl}advertisements?vendorId=${Constant.userModel!
                .vendorID}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          List<AdvertisementModel> advertisementList = [];

          for (var element in responseData['data']) {
            AdvertisementModel advertisementModel = AdvertisementModel.fromJson(
                element);
            advertisementList.add(advertisementModel);
          }
          advertisementList.sort((a, b) {
            if (a.createdAt == null || b.createdAt == null) return 0;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          return advertisementList;
        } else {
          log('API returned success: false');
          return null;
        }
      } else {
        log('HTTP Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (error) {
      log(error.toString());
      return null;
    }
  }


  /// GET /api/fm/product-variant-groups — cached, same TTL pattern as categories.
  static Future<List<VariantGroupModel>?> getProductVariantGroups() async {
    if (_cachedVariantGroups != null &&
        _variantGroupsCacheTime != null &&
        DateTime.now().difference(_variantGroupsCacheTime!) <
            _variantGroupsCacheTTL) {
      return _cachedVariantGroups!;
    }

    try {
      final url = '${Constant.baseUrl}fm/product-variant-groups';
      final headers = await getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      debugPrint("getProductVariantGroups => $url");
      debugPrint("Status Code => ${response.statusCode}");
      debugPrint("Response => ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
            "Failed to load variant groups: ${response.statusCode}");
      }

      final List<dynamic> data = jsonDecode(response.body);
      final groups = data
          .map((e) => VariantGroupModel.fromJson(Map<String, dynamic>.from(e)))
          .where((g) => g.isActive)
          .toList();

      _cachedVariantGroups = groups;
      _variantGroupsCacheTime = DateTime.now();
      return groups;
    } catch (e) {
      debugPrint("Error fetching variant groups: $e");
      return null;
    }
  }

  /// GET /api/fm/product-variant-groups/{groupId}/values — not cached long-term
  /// since values can be added mid-session; caller (controller) should cache
  /// per groupId for the lifetime of the sheet only.
  static Future<List<VariantGroupValueModel>?> getVariantGroupValues(
      int groupId) async {
    try {
      final url = '${Constant
          .baseUrl}fm/product-variant-groups/$groupId/values';
      final headers = await getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      debugPrint("getVariantGroupValues => $url");
      debugPrint("Status Code => ${response.statusCode}");
      debugPrint("Response => ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Failed to load values: ${response.statusCode}");
      }

      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) =>
          VariantGroupValueModel.fromJson(Map<String, dynamic>.from(e)))
          .where((v) => v.isActive)
          .toList();
    } catch (e) {
      debugPrint("Error fetching group values: $e");
      return null;
    }
  }

  /// POST /api/fm/product-variant-groups/{groupId}/values — called when the
  /// merchant types a value name that isn't in the dropdown yet.
  static Future<VariantGroupValueModel?> createVariantGroupValue({
    required int groupId,
    required String variantName,
  }) async {
    try {
      final url = '${Constant
          .baseUrl}fm/product-variant-groups/$groupId/values';
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'variantName': variantName}),
      );

      debugPrint("createVariantGroupValue => $url : $variantName");
      debugPrint("Status Code => ${response.statusCode}");
      debugPrint("Response => ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Failed to create value: ${response.statusCode}");
      }

      return VariantGroupValueModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      debugPrint("Error creating group value: $e");
      return null;
    }
  }

  /// GET /api/fm/products/{productId}/variant-options
  /// Loads whatever variants already exist on this outlet product.
  /// The endpoint only returns groupName (a string), never the group's id,
  /// so we resolve the real groupId by matching against the master group list.
  static Future<List<StagedVariantGroup>?> getProductVariantOptions(
      int productId, {
        List<VariantGroupModel>? knownGroups,
      }) async {
    try {
      final headers = await getHeaders();
      final url = '${Constant.baseUrl}fm/products/$productId/variant-options';
      final response = await http.get(Uri.parse(url), headers: headers);

      debugPrint('getProductVariantOptions => $url');
      debugPrint('Status Code => ${response.statusCode}');
      debugPrint('Response => ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load variant options: ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) return [];

      final groups = knownGroups ?? await getProductVariantGroups() ?? [];
      final groupsByName = {for (final g in groups) g.groupName: g};

      final Map<String, List<StagedVariantOption>> grouped = {};
      for (final raw in data) {
        final json = Map<String, dynamic>.from(raw);
        final groupName = json['groupName'] as String? ?? 'Unknown';
        grouped.putIfAbsent(groupName, () => []).add(
          StagedVariantOption(
            productVariantOptionsId: json['productVariantOptionsId'] ?? 0,
            productVariantGroupValuesId: json['productVariantGroupValuesId'] ??
                0,
            variantName: json['variantName'] ?? '',
            priceType: json['priceType'] ?? 'MAIN',
            variantPrice: (json['variantPrice'] as num?)?.toDouble() ?? 0,
          ),
        );
      }

      return grouped.entries.map((e) {
        final matched = groupsByName[e.key];
        // groupId falls back to 0 only if the group was renamed/deleted
        // server-side since this option was saved — an edge case worth
        // logging if it ever actually happens.
        return StagedVariantGroup(
          groupId: matched?.id ?? 0,
          groupName: e.key,
          options: e.value,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching product variant options: $e');
      return null;
    }
  }

  /// POST /api/fm/products/{productId}/variant-options — adds ONE new option row.
  static Future<bool> addProductVariantOption({
    required int productId,
    required int productVariantGroupValuesId,
    required String priceType,
    required double variantPrice,
  }) async {
    try {
      final headers = await getHeaders();
      final url = '${Constant.baseUrl}fm/products/$productId/variant-options';
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'productVariantGroupValuesId': productVariantGroupValuesId,
          'priceType': priceType,
          'variantPrice': variantPrice,
        }),
      );
      debugPrint('addProductVariantOption => $url');
      debugPrint('Status Code => ${response.statusCode}');
      debugPrint('Response => ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error adding variant option: $e');
      return false;
    }
  }

  /// DELETE /api/fm/products/{productId}/variant-options/{optionId}
  static Future<bool> deleteProductVariantOption({
    required int productId,
    required int optionId,
  }) async {
    try {
      final headers = await getHeaders();
      final url = '${Constant
          .baseUrl}fm/products/$productId/variant-options/$optionId';
      final response = await http.delete(Uri.parse(url), headers: headers);
      debugPrint('deleteProductVariantOption => $url');
      debugPrint('Status Code => ${response.statusCode}');
      debugPrint('Response => ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting variant option: $e');
      return false;
    }
  }

  static Future<CreateMasterProductResponse?> createMasterProduct(
      CreateMasterProductRequest request,) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse(
          '${Constant.baseUrl}fm/master-products/create',
        ),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      debugPrint(response.body);

      return CreateMasterProductResponse.fromJson(
        jsonDecode(response.body),
      );
    } catch (e) {
      debugPrint(
        "createMasterProduct Error => $e",
      );
      return null;
    }
  }


  /// Updates a master product via the Java API PUT endpoint.
  static Future<bool> updateMasterProduct(int masterProductId,
      Map<String, dynamic> payload) async {
    try {
      // final token = Preferences.getString('authToken');
      final headers = await getHeaders();
      final url = '${Constant.baseUrl}fm/master-products/$masterProductId';
      log('updateMasterProduct PUT $url');
      log('updateMasterProduct payload: ${json.encode(payload)}');
      final response = await http.put(
        Uri.parse(url),
        headers: headers,

        body: json.encode(payload),
      );
      log('updateMasterProduct response: ${response.statusCode} ${response
          .body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        invalidateProductCache(Constant.userModel?.vendorID);
        return true;
      } else {
        debugPrint(
            'updateMasterProduct failed: ${response.statusCode} - ${response
                .body}');
        return false;
      }
    } catch (e) {
      debugPrint('updateMasterProduct error: $e');
      return false;
    }
  }

  static Future<bool> deleteProduct(ProductModel productModel) async {
    bool isDeleted = false;

    try {
      final response = await http.delete(
        Uri.parse('${Constant.baseUrl}restaurant/products/${productModel.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        invalidateProductCache(Constant.userModel?.vendorID);
        invalidateVendorCategoryCache();
        isDeleted = true;
      } else {
        debugPrint(
            "Failed to delete product: ${response.statusCode} - ${response
                .body}");
        isDeleted = false;
      }
    } catch (error) {
      debugPrint("Failed to delete product: $error");
      isDeleted = false;
    }

    return isDeleted;
  }

  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    List<WalletTransactionModel> walletTransactionList = [];

    try {
      final String userId = await FireStoreUtils
          .getCurrentUid(); // Get current user ID

      final response = await http.get(
        Uri.parse(
            '${Constant.baseUrl}restaurant/wallet/transactions?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          // Parse the list of transactions from the response
          List<dynamic> transactions = responseData['data'];

          for (var transactionData in transactions) {
            try {
              WalletTransactionModel walletTransactionModel =
              WalletTransactionModel.fromJson(transactionData);
              walletTransactionList.add(walletTransactionModel);
            } catch (e) {
              log('Error parsing transaction: $e');
            }
          }

          // Sort by date in descending order (most recent first)
          walletTransactionList.sort((a, b) {
            // Handle different date types - API returns String, Firebase uses Timestamp
            DateTime? dateA = _parseDate(a.date);
            DateTime? dateB = _parseDate(b.date);

            // Handle null cases
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1; // Put null dates at the end
            if (dateB == null) return -1; // Put null dates at the end

            return dateB.compareTo(dateA); // Descending order
          });
        }
      } else {
        throw Exception(
            'Failed to load wallet transactions: ${response.statusCode}');
      }
    } catch (error) {
      log('getWalletTransaction error: $error');
      return null;
    }

    return walletTransactionList;
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;

    if (date is String) {
      // Remove extra quotes if they exist
      String dateString = date.replaceAll('"', '');
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        log('Error parsing date string: $dateString');
        return null;
      }
    } else if (date is Timestamp) {
      return date.toDate();
    } else if (date is DateTime) {
      return date;
    }

    return null;
  }


  static Future<VendorModel?> getVendorById(String vendorId,
      {bool forceRefresh = false}) async {
    VendorModel? vendorModel;
    try {
      // Performance Optimization: Check cache first (transparent to caller)
      if (!forceRefresh &&
          _cachedVendor != null &&
          _cachedVendorId == vendorId &&
          _vendorCacheTime != null) {
        final cacheAge = DateTime.now().difference(_vendorCacheTime!);
        if (cacheAge < _vendorCacheTTL) {
          log("getVendorById: Returning cached data (age: ${cacheAge
              .inSeconds}s)");
          return _cachedVendor;
        }
      }

      debugPrint("getVendorById  ");
      if (vendorId.isNotEmpty) {
        final response = await http.get(
          Uri.parse('${Constant.baseUrl}restaurant/vendors/$vendorId'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 30));
        if (response.statusCode == 200) {
          debugPrint("getVendorById  ${response.body}");
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData['success'] == true && responseData['data'] != null) {
            vendorModel = VendorModel.fromJson(responseData['data']);
            debugPrint("getVendorById  ${response.body}");

            // Performance Optimization: Cache the result
            _cachedVendor = vendorModel;
            _cachedVendorId = vendorId;
            _vendorCacheTime = DateTime.now();
          }
        } else if (response.statusCode == 404) {
          return null;
        } else {
          throw Exception('Failed to load vendor: ${response.statusCode}');
        }
      }
    } catch (e, s) {
      log('getVendorById error: $e $s');
      return null;
    }
    return vendorModel;
  }


  static Future<List<VendorCategoryModel>?> getAllMasterCategories() async {
    if (_cachedVendorCategories != null &&
        _vendorCategoriesCacheTime != null &&
        DateTime.now().difference(_vendorCategoriesCacheTime!) <
            _vendorCategoriesCacheTTL) {
      return _cachedVendorCategories!;
    }

    try {
      String url = '${Constant.baseUrl}fm/getHomeOrAllCategories?filter=ALL';

      debugPrint("getVendorCategoryById => $url");
      //final token = Preferences.getString('authToken');
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      debugPrint("Status Code => ${response.statusCode}");
      debugPrint("Response => ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
            "Failed to load categories: ${response.statusCode}");
      }

      final Map<String, dynamic> jsonResponse =
      jsonDecode(response.body);

      if (jsonResponse["success"] != true) {
        throw Exception(
            jsonResponse["message"] ?? "Failed to load categories");
      }

      final List<dynamic> data =
          jsonResponse["data"]["categories"] ?? [];

      final List<VendorCategoryModel> categories =
      data.map((item) {
        return VendorCategoryModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();

      _cachedVendorCategories = categories;
      _vendorCategoriesCacheTime = DateTime.now();

      debugPrint(
          "Loaded Categories => ${categories.length}");

      return categories;
    } catch (e) {
      debugPrint(
          "Error fetching categories: $e");
      return null;
    }
  }

  static Future<bool> createCategory({
    required String categoryName,
    required String categoryType,
    required File categoryImage,
    required int createdBy,
  }) async {
    try {
      final headers = await getHeaders();

      final uri = Uri.parse(
        '${Constant.baseUrl}fm/createCategory',
      );

      final request = http.MultipartRequest(
        'POST',
        uri,
      );



      headers.forEach((key, value) {
        // Don't print full JWT in production logs
        if (key.toLowerCase() == 'authorization') {
          final auth = value ?? '';

          if (auth.length > 20) {
            debugPrint(
                '$key: ${auth.substring(0, 20)}...'
            );
          } else {
            debugPrint('$key: $auth');
          }
        } else {
          debugPrint('$key: $value');
        }
      });


      request.headers.addAll({
        'Accept': '*/*',
        'Authorization': headers['Authorization'] ?? '',
      });
      // ============================================================
      // DEBUG - FORM FIELDS
      // ============================================================

      request.fields['categoryName'] = categoryName;
      request.fields['categoryType'] = categoryType;
      request.fields['createdBy'] = createdBy.toString();


      if (await categoryImage.exists()) {
        final fileSize = await categoryImage.length();

        debugPrint(
          'Size         : ${(fileSize / 1024).toStringAsFixed(2)} KB',
        );

        debugPrint(
          'File name    : ${categoryImage.path.split('/').last}',
        );
      }

      // ============================================================
      // ADD IMAGE
      // ============================================================

      final multipartFile = await http.MultipartFile.fromPath(
        'categoryImageUrl',
        categoryImage.path,
      );



      request.files.add(multipartFile);

      // ============================================================
      // FINAL REQUEST DEBUG
      // ============================================================

      debugPrint('');
      debugPrint('REQUEST HEADERS AFTER ADD:');

      request.headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization') {
          if (value.length > 20) {
            debugPrint(
              '$key: ${value.substring(0, 20)}...',
            );
          } else {
            debugPrint('$key: $value');
          }
        } else {
          debugPrint('$key: $value');
        }
      });

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);

          debugPrint('Category ID    : ${data['categoryId']}');
          debugPrint('Category Name  : ${data['categoryName']}');
          debugPrint(
            'Category Image : ${data['categoryImageUrl']}',
          );
        } catch (e) {
          debugPrint(
            'Response parsing error: $e',
          );
        }

        return true;
      }

      return false;
    } catch (e, stackTrace) {
      return false;
    }
  }


  static Future<InboxModel> addRestaurantInbox(InboxModel inboxModel) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}chat-restaurant/inbox'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(inboxModel.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return inboxModel;
      } else {
        throw Exception('Failed to add restaurant inbox: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add restaurant inbox: $e');
    }
  }


  static Future<InboxModel> addAdminInbox(InboxModel inboxModel) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}chat-admin/inbox'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(inboxModel.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return inboxModel;
      } else {
        throw Exception('Failed to add admin inbox: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add admin inbox: $e');
    }
  }


  static Future<ConversationModel> addRestaurantChat(ConversationModel conversationModel) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}chat-restaurant/thread'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: conversationModel.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return conversationModel;
      } else {
        throw Exception('Failed to add chat: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add chat: $e');
    }
  }

  static Future<ConversationModel> addAdminChat(ConversationModel conversationModel) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}chat-admin/thread'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(conversationModel.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return conversationModel;
      } else {
        throw Exception('Failed to add admin chat: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add admin chat: $e');
    }
  }

  // THIS IS JAVA API OF CREATING NEW OUTLET API POST METHOD
  static Future<OutletModel?> createOutlet(Map<String, dynamic> body) async {

    try {
      //final token = Preferences.getString('authToken');
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse(
          '${Constant.baseUrl}fm/outlets/createOutlet',
        ),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint("STATUS CODE = ${response.statusCode}");
      debugPrint("RESPONSE = ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'];
        if (data is Map<String, dynamic>) {
          return OutletModel.fromJsonSafe(data);
        }
        if (data is Map) {
          return OutletModel.fromJsonSafe(Map<String, dynamic>.from(data));
        }
      }

      return null;

    } catch (e) {
      debugPrint("CREATE OUTLET ERROR = $e");
      return null;
    }
  }
// END OF THIS APIJ
// GET OUTLET PROFILE STARTED
  static Future<OutletModel?> getOutletProfile(int outletId) async {
    try {
      if (outletId <= 0) {
        debugPrint("Outlet ID is invalid");
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      //final token = prefs.getString('authToken') ?? '';
      final headers = await getHeaders();
      final url = '${Constant.baseUrl}fm/outlets/getOutletById/$outletId';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      debugPrint("getOutletProfile Status: ${response.statusCode}");
      debugPrint("getOutletProfile Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final data = jsonData is Map<String, dynamic> && jsonData['data'] is Map
            ? Map<String, dynamic>.from(jsonData['data'] as Map)
            : Map<String, dynamic>.from(jsonData as Map);
        return OutletModel.fromJson(data);
      }
      return null;
    } catch (e, st) {
      debugPrint("getOutletProfile Error: $e");
      print(st);
      return null;
    }
  }
//END
 // UPDATE OUTLET PROFILE  STARTED
  static Future<bool> updateOutletProfile(int outletId, Map<String, dynamic> body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      //final token = prefs.getString('authToken') ?? '';
     final headers = await getHeaders();
      final url =
          '${Constant.baseUrl}fm/outlets/updateOutletDetailsByMerchant/$outletId';

      debugPrint("===== UPDATE OUTLET REQUEST =====");
      debugPrint(json.encode(body));

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      debugPrint("updateOutletProfile Status: ${response.statusCode}");
      debugPrint("updateOutletProfile Body: ${response.body}");

      if (response.statusCode == 200) {
        log("updateOutletProfile success: ${response.body}");
        return true;
      } else {
        log("updateOutletProfile failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      log("updateOutletProfile error: $e");
      return false;
    }
  }
//ENDED
// UPLOAD OUTLET IMAGE STARTED
  /// POST /api/fm/outlets/{outletId}/image — uploads the outlet image to the
  /// Java backend via multipart/form-data. Returns the uploaded image URL on
  /// success, otherwise null.
  static Future<String?> uploadOutletImage({
    required int outletId,
    required File image,
  }) async {
    try {
      if (outletId <= 0 || !image.existsSync()) {
        debugPrint("uploadOutletImage: invalid outletId or image file");
        return null;
      }

      final token = await getAuthToken();
      final url = '${Constant.baseUrl}fm/outlets/$outletId/image';

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = token;
      }

      final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          filename: image.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
      );

      debugPrint("uploadOutletImage URL: $url");

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      debugPrint("uploadOutletImage Status: ${response.statusCode}");
      debugPrint("uploadOutletImage Body: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is Map<String, dynamic> &&
            jsonData['success'] == true &&
            jsonData['data'] != null) {
          final url = jsonData['data'].toString();
          if (url.isNotEmpty) return url;
        }
      }
      return null;
    } catch (e, st) {
      debugPrint("uploadOutletImage Error: $e");
      print(st);
      return null;
    }
  }
//ENDED
  /// POST /api/fm/outlets/saveOrUpdateDocuments — uploads verification
  /// documents (Aadhaar/PAN for a merchant, FSSAI/GST for an outlet) via
  /// multipart/form-data. Only the provided files are attached.
  static Future<bool> saveOrUpdateDocuments({
    required int entityId,
    required String entityType,
    File? aadharFile,
    File? panFile,
    File? fssaiFile,
    File? gstFile,
    File? rcCopyFile,
    File? drivingLicenseFile,
  }) async {
    try {
      if (entityId <= 0) {
        debugPrint("saveOrUpdateDocuments: invalid entityId");
        return false;
      }

      final token = await getAuthToken();
      final url = '${Constant.baseUrl}fm/outlets/saveOrUpdateDocuments';

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = token;
      }

      request.fields['entityId'] = entityId.toString();
      request.fields['entityType'] = entityType;

      Future<void> attach(String field, File? file) async {
        if (file == null || !file.existsSync()) return;
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        request.files.add(
          await http.MultipartFile.fromPath(
            field,
            file.path,
            filename: file.path.split('/').last,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      await attach('aadharFile', aadharFile)
          .then((_) => attach('panFile', panFile))
          .then((_) => attach('fssaiFile', fssaiFile))
          .then((_) => attach('gstFile', gstFile))
          .then((_) => attach('rcCopyFile', rcCopyFile))
          .then((_) => attach('drivingLicenseFile', drivingLicenseFile));

      debugPrint("saveOrUpdateDocuments URL: $url");
      debugPrint(
          "saveOrUpdateDocuments entityId=$entityId entityType=$entityType files=${request.files.length}");

      final streamed =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);

      debugPrint("saveOrUpdateDocuments Status: ${response.statusCode}");
      debugPrint("saveOrUpdateDocuments Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body =
            response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
        if (body.isNotEmpty) {
          try {
            final json = jsonDecode(body);
            if (json is Map && json['success'] == true) return true;
          } catch (_) {}
        }
        return true;
      }
      return false;
    } catch (e, st) {
      debugPrint("saveOrUpdateDocuments Error: $e");
      print(st);
      return false;
    }
  }


  static Future<List<CuisineTypeModel>> getCuisineTypes() async {
    try {
      final headers = await getHeaders();
      final url = '${Constant.baseUrl}fm/cuisine-types';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      debugPrint("getCuisineTypes Status: ${response.statusCode}");
      debugPrint("getCuisineTypes Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final data = jsonData['data'];

        if (data is List) {
          return data
              .map((e) => CuisineTypeModel.fromJson(
              Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("getCuisineTypes Error: $e");
      return [];
    }
  }


   Future<bool?> deleteUser() async {
    try {
      String userId = await getCurrentUid();
      final response = await http.delete(
        Uri.parse('${Constant.baseUrl}restaurant/user_delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": userId,
        }),
      );
      if (response.statusCode == 200) {
        loginController.logoutFunction();
        return true;
      } else {
        log('Delete user API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e, s) {
      log('FireStoreUtils.deleteUser $e $s');
      return false;
    }
  }

  static Future<Url> uploadChatImageToFireStorage(
      File image, BuildContext context) async {
    ShowToastDialog.showLoader("Please wait");
    var uniqueID = const Uuid().v4();
    Reference upload =
        FirebaseStorage.instance.ref().child('images/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(image);
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    ShowToastDialog.closeLoader();
    return Url(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<ChatVideoContainer?> uploadChatVideoToFireStorage(
      BuildContext context, File video) async {
    try {
      ShowToastDialog.showLoader("Uploading video...");
      final String uniqueID = const Uuid().v4();
      final Reference videoRef =
          FirebaseStorage.instance.ref('videos/$uniqueID.mp4');
      final UploadTask uploadTask = videoRef.putFile(
        video,
        SettableMetadata(contentType: 'video/mp4'),
      );
      await uploadTask;
      final String videoUrl = await videoRef.getDownloadURL();
      ShowToastDialog.showLoader("Generating thumbnail...");
      File thumbnail = await VideoCompress.getFileThumbnail(
        video.path,
        quality: 75, // 0 - 100
        position: -1, // Get the first frame
      );
      final String thumbnailID = const Uuid().v4();
      final Reference thumbnailRef =
          FirebaseStorage.instance.ref('thumbnails/$thumbnailID.jpg');
      final UploadTask thumbnailUploadTask = thumbnailRef.putData(
        thumbnail.readAsBytesSync(),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      await thumbnailUploadTask;
      final String thumbnailUrl = await thumbnailRef.getDownloadURL();
      var metaData = await thumbnailRef.getMetadata();
      ShowToastDialog.closeLoader();

      return ChatVideoContainer(
          videoUrl: Url(
              url: videoUrl.toString(),
              mime: metaData.contentType ?? 'video',
              videoThumbnail: thumbnailUrl),
          thumbnailUrl: thumbnailUrl);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error: ${e.toString()}");
      return null;
    }
  }

  static Future<String> uploadImageOfStory(
      File image, BuildContext context, String extansion) async {
    final data = await image.readAsBytes();
    final mime = lookupMimeType('', headerBytes: data);

    Reference upload = FirebaseStorage.instance.ref().child(
          'Story/images/${image.path.split('/').last}',
        );
    UploadTask uploadTask =
        upload.putFile(image, SettableMetadata(contentType: mime));
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    ShowToastDialog.closeLoader();
    return downloadUrl.toString();
  }

  static Future<File> _compressVideo(File file) async {
    MediaInfo? info = await VideoCompress.compressVideo(file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 24);
    if (info != null) {
      File compressedVideo = File(info.path!);
      return compressedVideo;
    } else {
      return file;
    }
  }
  static Future<String?> uploadVideoStory(
      File video, BuildContext context) async {
    var uniqueID = const Uuid().v4();
    Reference upload =
        FirebaseStorage.instance.ref().child('Story/$uniqueID.mp4');
    File compressedVideo = await _compressVideo(video);
    SettableMetadata metadata = SettableMetadata(contentType: 'video');
    UploadTask uploadTask = upload.putFile(compressedVideo, metadata);
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    ShowToastDialog.closeLoader();
    return downloadUrl.toString();
  }
  static Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    Reference upload =
        FirebaseStorage.instance.ref().child('thumbnails/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(file);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<WithdrawMethodModel?> getWithdrawMethod() async {
    try {
      // Make API call
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/wallet/withdraw-method?userId=${getCurrentUid()}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];

          if (data.isNotEmpty) {
            WithdrawMethodModel withdrawMethodModel = WithdrawMethodModel.fromJson(data.first);
            return withdrawMethodModel;
          } else {
            return null; // No withdraw method found
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load withdraw method: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      return null;
    }
  }
  static Future<WithdrawMethodModel?> setWithdrawMethod(
      WithdrawMethodModel withdrawMethodModel) async {
    try {
      String userId = await FireStoreUtils.getCurrentUid();
      // Prepare the data
      if (withdrawMethodModel.id == null) {
        withdrawMethodModel.id = const Uuid().v4();
        withdrawMethodModel.userId = userId;
      }
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/wallet/withdraw-method'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(withdrawMethodModel.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (responseData['data'] != null) {
            WithdrawMethodModel updatedModel = WithdrawMethodModel.fromJson(responseData['data']);
            return updatedModel;
          } else {
            return withdrawMethodModel;
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to set withdraw method: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      return null;
    }
  }

  static Future<NotificationModel?> getNotificationContent(String type) async {
    try {
      // Make API call
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/notifications/$type'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // If API returns the notification data
          if (responseData['data'] != null) {
            debugPrint("------>");
            debugPrint(responseData['data']);

            NotificationModel notificationModel =
            NotificationModel.fromJson(responseData['data']);
            return notificationModel;
          } else {
            // No notification found - return default
            return NotificationModel(
              id: "",
              message: "Notification setup is pending",
              subject: "setup notification",
              type: type,
            );
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else if (response.statusCode == 404) {
        // Notification not found - return default
        return NotificationModel(
          id: "",
          message: "Notification setup is pending",
          subject: "setup notification",
          type: type,
        );
      } else {
        throw Exception('Failed to load notification: ${response.statusCode}');
      }
    } catch (error) {
      log("Error fetching notification: $error");
      // Return default notification on error
      return NotificationModel(
        id: "",
        message: "Notification setup is pending",
        subject: "setup notification",
        type: type,
      );
    }
  }




  static Future<String> uploadUserImageToFireStorage(
      File image, String userID) async {
    Reference upload =
        FirebaseStorage.instance.ref().child('images/$userID.png');
    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<AdvertisementModel> firebaseCreateAdvertisement(
      AdvertisementModel model) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}advertisements'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(model.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (responseData['data'] != null) {
            return AdvertisementModel.fromJson(responseData['data']);
          } else {
            return model;
          }
        } else {
          log('API returned success: false for create advertisement');
          throw Exception('Failed to create advertisement: ${responseData['message']}');
        }
      } else {
        log('HTTP Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create advertisement: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      throw Exception('Failed to create advertisement: $error');
    }
  }

  static Future<AdvertisementModel> removeAdvertisement(
      AdvertisementModel model) async {
    try {
      final response = await http.delete(
        Uri.parse('${Constant.baseUrl}advertisements/${model.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return model;
        } else {
          log('API returned success: false for delete advertisement');
          throw Exception('Failed to delete advertisement: ${responseData['message']}');
        }
      } else {
        log('HTTP Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to delete advertisement: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      throw Exception('Failed to delete advertisement: $error');
    }
  }
  static Future<AdvertisementModel> pauseAndResumeAdvertisement(
      AdvertisementModel model) async {
    try {
      final response = await http.put(
        Uri.parse('${Constant.baseUrl}advertisements/${model.id}/pause-resume'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(model.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // If the API returns the updated advertisement data, use it
          if (responseData['data'] != null) {
            return AdvertisementModel.fromJson(responseData['data']);
          } else {
            return model;
          }
        } else {
          log('API returned success: false for pause/resume advertisement ');
          throw Exception('Failed to pause/resume advertisement: ${responseData['message']}');
        }
      } else {
        log('HTTP Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to pause/resume advertisement: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      throw Exception('Failed to pause/resume advertisement: $error');
    }
  }

  static Future<List<RatingModel>> getOrderReviewsByVenderId({
    required String venderId
  }) async {
    List<RatingModel> ratingModelList = [];
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/reviews/vendor/$venderId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> reviewsData = jsonResponse['data'];
          debugPrint("======>");
          print(reviewsData.length);
          for (final reviewData in reviewsData) {
            ratingModelList.add(RatingModel.fromJson(reviewData));
          }
        } else {
          debugPrint("No reviews found or API returned error");
        }
      } else {
        debugPrint("Failed to fetch reviews: ${response.statusCode} - ${response.body}");
      }
    } catch (error) {
      debugPrint("Error fetching reviews: $error");
    }

    return ratingModelList;
  }

  static Future<List<UserModel>> getAvalibleDrivers({String? zoneId}) async {
    List<UserModel> driverList = [];
    try {
      // String? userId = await getFirebaseId();
      // log("getAvalibleDrivers :: 22  $userId");
      // Make API call
      String url = "";
      if(zoneId==null){
        url = '${Constant.baseUrl}drivers/available';
      }else{
        url = '${Constant.baseUrl}drivers/available?zoneId=$zoneId';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      log("getAvalibleDrivers ${response.body} ");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          if (data.isNotEmpty) {
            for (var element in data) {
              driverList.add(UserModel.fromJson(element));
            }
            // Sort by createdAt descending (to match Firebase orderBy behavior)
            driverList.sort((a, b) {
              if (a.createdAt == null && b.createdAt == null) return 0;
              if (a.createdAt == null) return 1;
              if (b.createdAt == null) return -1;
              return b.createdAt!.compareTo(a.createdAt!);
            });
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load available drivers: ${response.statusCode}');
      }
    } catch (e) {
      log("Error fetching drivers: ${e.toString()}");
    }
    return driverList;
  }
  static Future<List<UserModel>> getAllDrivers() async {
    List<UserModel> driverList = [];
    try {
      // Make API call
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}drivers/all?vendorID=${Constant.userModel?.vendorID}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          if (data.isNotEmpty) {
            for (var element in data) {
              driverList.add(UserModel.fromJson(element));
            }
            // Sort by createdAt descending (to match Firebase orderBy behavior)
            driverList.sort((a, b) {
              if (a.createdAt == null && b.createdAt == null) return 0;
              if (a.createdAt == null) return 1;
              if (b.createdAt == null) return -1;
              return b.createdAt!.compareTo(a.createdAt!);
            });
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load drivers: ${response.statusCode}');
      }
    } catch (e) {
      log("Error fetching drivers: ${e.toString()}");
    }
    return driverList;
  }

  static Future<void> updateProductIsAvailable(String productId, bool isAvailable) async {
    try {
      final response = await http.put(
        Uri.parse('${Constant.baseUrl}restaurant/products/$productId/availability'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'isAvailable': isAvailable,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        invalidateProductCache(Constant.userModel?.vendorID);
        debugPrint('Product availability updated successfully');
      } else {
        debugPrint("Failed to update product availability: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to update product availability');
      }
    } catch (error) {
      debugPrint("Failed to update product availability: $error");
      throw error;
    }
  }


  static Future<void> updateCategoryIsActive(String categoryId, bool isActive) async {
    try {
      debugPrint("updateCategoryIsActive ${isActive}");
      String url  = '${Constant.baseUrl}restaurant/vendor-categories/$categoryId/active';
          // 'restaurant/categories/$categoryId/products-availability'
      // ;
      debugPrint("updateCategoryIsActive $url vendorID ${Constant.userModel!.vendorID}  isAvailable ${isActive ? 1 : 0}");
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          // 'vendorID': Constant.userModel!.vendorID, // Assuming you have vendorID in user model
          'isActive': isActive , // Convert bool to int (1 for true, 0 for false)
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        invalidateProductCache(Constant.userModel?.vendorID);
        invalidateVendorCategoryCache();
        debugPrint('Category availability updated successfully');
      } else {
        debugPrint("Failed to update category availability: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to update category availability');
      }
    } catch (error) {
      debugPrint("Failed to update category availability: $error");
      throw error;
    }
  }


  static Future<void> setAllProductsAvailabilityForCategory(
      String categoryId,
      bool isAvailable
      ) async {
    try {
      final url = Uri.parse('${Constant.baseUrl}restaurant/categories/$categoryId/products-availability');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "vendorID": Constant.userModel!.vendorID,
          "isAvailable": isAvailable ? 1 : 0, // Convert bool to int
        }),
      );

      if (response.statusCode == 200) {
        invalidateProductCache(Constant.userModel?.vendorID);
        debugPrint('Products availability updated successfully');
      } else {
        debugPrint('Failed to update products availability: ${response.statusCode}');
        throw Exception('Failed to update products availability');
      }
    } catch (e) {
      debugPrint('Error updating products availability: $e');
      throw e;
    }
  }


  static Future<bool> postOutletItemUnavailability({
    required String type,
    required int unavailabilityId,
    String reason = 'Temporarily unavailable',
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final now = DateTime.now();

      // Keep at least 1 minute buffer before API call.
      final minimumAllowedTime = now.add(
        const Duration(minutes: 1),
      );

      // If selected start time is current/past,
      // automatically move it into the future.
      final selectedFrom = fromDate ?? minimumAllowedTime;

      final from = selectedFrom.isBefore(minimumAllowedTime)
          ? minimumAllowedTime
          : selectedFrom;

      // Default end date.
      var to = toDate ??
          DateTime(
            2099,
            12,
            31,
            23,
            59,
            59,
          );

      // End date must always be after start date.
      if (!to.isAfter(from)) {
        to = from.add(
          const Duration(hours: 1),
        );
      }

      //final token = Preferences.getString('authToken');
      final headers = await getHeaders();
      final body = {
        'type': type.toUpperCase(),
        'unavailabilityId': unavailabilityId,

        // Removes milliseconds because backend expects:
        // yyyy-MM-ddTHH:mm:ss
        'unavailabilityFromDate':
        from.toIso8601String().split('.').first,

        'unavailabilityToDate':
        to.toIso8601String().split('.').first,

        'reason': reason,
      };

      debugPrint('==========================================');
      debugPrint('POST OUTLET ITEM UNAVAILABILITY');
      debugPrint('Current time     : $now');
      debugPrint('Original from    : $fromDate');
      debugPrint('Final from       : $from');
      debugPrint('Original to      : $toDate');
      debugPrint('Final to         : $to');
      debugPrint('Request body     : ${jsonEncode(body)}');
      debugPrint('==========================================');

      final response = await http.post(
        Uri.parse(
          '${Constant.baseUrl}fm/outlet-unavailability',
        ),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint(
        'postOutletItemUnavailability status => ${response.statusCode}',
      );

      debugPrint(
        'postOutletItemUnavailability body => ${response.body}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return false;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['success'] == false) {
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('postOutletItemUnavailability error: $e');
      debugPrint('$stackTrace');
      return false;
    }
  }

  /// PATCH /api/fm/outlet-unavailability/restore — restore availability.
  static Future<bool> restoreOutletItemAvailability({
    required String type,
    required int unavailabilityId,
    String reason = 'Restored availability',
  }) async {
    try {
      //final token = Preferences.getString('authToken');
      final headers = await getHeaders();
      final body = {
        'type': type.toUpperCase(),
        'unavailabilityId': unavailabilityId,
        'reason': reason,
      };

      final response = await http.patch(
        Uri.parse(
          '${Constant.baseUrl}fm/outlet-unavailability/restore',
        ),
         headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('restoreOutletItemAvailability => ${jsonEncode(body)}');
      debugPrint('restoreOutletItemAvailability status => ${response.statusCode}');
      debugPrint('restoreOutletItemAvailability body => ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        return false;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['success'] == false) {
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('restoreOutletItemAvailability error: $e');
      print(stackTrace);
      return false;
    }
  }
// ── Promotion APIs ──────────────────────────────────────────────────────────

  static Future<bool> restoreOnlyOutletItemAvailability({
    required String type,
    required int unavailabilityId,
    String reason = 'Restored availability',
  }) async {
    try {
      //final token = Preferences.getString('authToken');
      final headers = await getHeaders();
      final body = {
        'outletId': unavailabilityId,
        'isToggle' : true,
      };

      final response = await http.put(
        Uri.parse(
          '${Constant.baseUrl}fm/outlets/toggleForOutlet',
        ),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('restoreOutletItemAvailability => ${jsonEncode(body)}');
      debugPrint('restoreOutletItemAvailability status => ${response.statusCode}');
      debugPrint('restoreOutletItemAvailability body => ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        return false;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['success'] == false) {
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('restoreOutletItemAvailability error: $e');
      print(stackTrace);
      return false;
    }
  }



  // GET /api/fm/promotion-plans/outlets/{outletId}/counts
  static Future<PromotionCountsModel> getPromotionCounts(int outletId) async {
    try {
      final headers = await getHeaders();
      final url = '${Constant.baseUrl}fm/promotion-plans/outlets/$outletId/counts';
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['data'] != null) {
          return PromotionCountsModel.fromJson(decoded['data']);
        }
      }
      return PromotionCountsModel();
    } catch (e) {
      log('getPromotionCounts error: $e');
      return PromotionCountsModel();
    }
  }

  // GET /api/fm/promotion-plans/outlets/{outletId}?status={status}&page={page}&size={size}
  static Future<List<PromotionPlanModel>> getPromotionPlansByOutlet({
    required int outletId,
    required String status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final headers = await getHeaders();
      final url =
          '${Constant.baseUrl}fm/promotion-plans/outlets/$outletId?status=$status&page=$page&size=$size&sortBy=promotionPlanId&direction=DESC';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['data'] != null && decoded['data']['content'] != null) {
          final List<dynamic> list = decoded['data']['content'];
          return list.map((e) => PromotionPlanModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      log('getPromotionPlansByOutlet error: $e');
      return [];
    }
  }

  // GET /api/fm/promotion-plan-types
  static Future<List<PromotionPlanTypeModel>> getPromotionPlanTypes() async {
    try {
      final headers = await getHeaders();
      final baseUrl = Constant.baseUrl.endsWith('/')
          ? Constant.baseUrl
          : '${Constant.baseUrl}/';
      final url = '${baseUrl}fm/promotion-plan-types';

      debugPrint('===== GET PROMOTION PLAN TYPES =====');
      debugPrint('Request URL: $url');
      final response = await http.get(Uri.parse(url), headers: headers);

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          rawList = decoded['data'];
        }

        final list = rawList.map((e) {
          if (e is Map<String, dynamic>) {
            return PromotionPlanTypeModel.fromJson(e);
          }
          return PromotionPlanTypeModel.fromJson(Map<String, dynamic>.from(e as Map));
        }).toList();

        debugPrint('Parsed Plan Types: ${list.length}');
        return list;
      } else {
        log('getPromotionPlanTypes failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      log('getPromotionPlanTypes error: $e');
      log(stackTrace.toString());
      return [];
    }
  }
  static Map<String, dynamic>? _tryDecode(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/fm/promotion-plans

  // POST /api/fm/promotion-plans
  static Future<PromotionApiResult> createPromotionPlan(PromotionPlanModel model) async {
    try {
      final headers = await getHeaders();
      final url = '${Constant.baseUrl}fm/promotion-plans';
      final body = json.encode(model.toCreateUpdateJson());

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      final decoded = _tryDecode(response.body);
      final apiMessage = decoded != null ? decoded['message']?.toString() : null;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PromotionApiResult(success: true, message: apiMessage ?? 'Plan created successfully');
      }
      return PromotionApiResult(success: false, message: apiMessage ?? 'Failed to create promotion plan');
    } catch (e) {
      log('createPromotionPlan error: $e');
      return PromotionApiResult(success: false, message: 'Something went wrong. Please try again.');
    }
  }
  // DELETE /api/fm/promotion-plans/{promotionPlanId}
  static Future<bool> deletePromotionPlan(int promotionPlanId) async {
    try {
      final headers = await getHeaders();
      final url = '${Constant.baseUrl}fm/promotion-plans/$promotionPlanId';
      final response = await http.delete(Uri.parse(url), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      log('deletePromotionPlan error: $e');
      return false;
    }
  }

  static Future<PromotionPlanModel?> getPromotionPlanDetails(int promotionPlanId) async {
    try {
      final headers = await getHeaders();
      final url = '${Constant.baseUrl}fm/promotion-plans/$promotionPlanId';
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // Note: this endpoint returns the plan object directly,
        // NOT wrapped in a "data" key like the list/counts endpoints.
        return PromotionPlanModel.fromJson(decoded);
      }
      log('getPromotionPlanDetails failed: ${response.statusCode} — ${response.body}');
      return null;
    } catch (e) {
      log('getPromotionPlanDetails error: $e');
      return null;
    }
  }
  static Future<PromotionApiResult> updatePromotionPlan(int promotionPlanId, PromotionPlanModel model) async {
    try {
      final headers = await getHeaders();
      final url = '${Constant.baseUrl}fm/promotion-plans/$promotionPlanId';
      final body = json.encode(model.toCreateUpdateJson());

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      final decoded = _tryDecode(response.body);
      final apiMessage = decoded != null ? decoded['message']?.toString() : null;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PromotionApiResult(success: true, message: apiMessage ?? 'Plan updated successfully');
      }
      return PromotionApiResult(success: false, message: apiMessage ?? 'Failed to update promotion plan');
    } catch (e) {
      log('updatePromotionPlan error: $e');
      return PromotionApiResult(success: false, message: 'Something went wrong. Please try again.');
    }
  }

  static Future<Map<String, dynamic>?> sendLoginOtpForNumber({
    required String userType,
    required String mobileNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${Constant.baseUrl}fm/auth/send-login-otp',
        ),
        headers: await getHeaders(),
        body: jsonEncode({
          "userType": userType,
          "mobileNumber": mobileNumber,
        }),
      );

      debugPrint(
        "Send OTP Status: ${response.statusCode}",
      );

      debugPrint(
        "Send OTP Response: ${response.body}",
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        "error": true,
        "message":
        "Failed to send OTP (${response.statusCode})",
      };
    } catch (e) {
      debugPrint(
        "Send OTP Error: $e",
      );

      return {
        "error": true,
        "message": e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>?> verifyLoginOtpForNumber({
    required String userType,
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${Constant.baseUrl}fm/auth/verify-login-otp',
        ),
        headers: await getHeaders(),
        body: jsonEncode({
          "userType": userType,
          "mobileNumber": mobileNumber,
          "otp": otp,
        }),
      );

      debugPrint(
        "Verify OTP Status: ${response.statusCode}",
      );

      debugPrint(
        "Verify OTP Response: ${response.body}",
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        "error": true,
        "message":
        "Invalid OTP (${response.statusCode})",
      };
    } catch (e) {
      debugPrint(
        "Verify OTP Error: $e",
      );

      return {
        "error": true,
        "message": e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>?> resendLoginOtpForNumber({
    required String userType,
    required String mobileNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${Constant.baseUrl}fm/auth/resend-login-otp',
        ),
        headers: await getHeaders(),
        body: jsonEncode({
          "userType": userType,
          "mobileNumber": mobileNumber,
        }),
      );

      debugPrint(
        "Resend OTP Status: ${response.statusCode}",
      );

      debugPrint(
        "Resend OTP Response: ${response.body}",
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        "error": true,
        "message":
        "Failed to resend OTP (${response.statusCode})",
      };
    } catch (e) {
      debugPrint(
        "Resend OTP Error: $e",
      );

      return {
        "error": true,
        "message": e.toString(),
      };
    }
  }


}
