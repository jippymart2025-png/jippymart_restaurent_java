import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/currency_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/notification/notification_service.dart';
import 'package:get/get.dart';
import '../constant/collection_name.dart';
import '../utils/preferences.dart';

class GlobalSettingController extends GetxController {
  static const String _currencyCacheJsonKey = "active_currency_json";
  static const String _currencyCacheTimeMsKey = "active_currency_time_ms";
  static const Duration _currencyCacheTtl = Duration(hours: 24);

  @override
  void onInit() {
    notificationInit();
    // getCurrentCurrency();

    super.onInit();
  }

  /// Loads active currency then settings once. Both use cache when valid; getSettings is awaited so currency + settings are ready together.
  // getCurrentCurrency() async {
  //   // Smart cache (reduce server load): use cached currency for 24h.
  //   try {
  //     final cachedAtMs = Preferences.getInt(_currencyCacheTimeMsKey);
  //     final cachedJson = Preferences.getString(_currencyCacheJsonKey);
  //     if (cachedAtMs > 0 && cachedJson.isNotEmpty) {
  //       final cacheAge = DateTime.now()
  //           .difference(DateTime.fromMillisecondsSinceEpoch(cachedAtMs));
  //       if (cacheAge < _currencyCacheTtl) {
  //         final cachedMap = json.decode(cachedJson);
  //         Constant.currencyModel = CurrencyModel.fromJson(cachedMap);
  //         // Still refresh settings (already has its own TTL cache)
  //         // await FireStoreUtils.getSettings();
  //         return;
  //       }
  //     }
  //   } catch (_) {
  //     // Ignore cache parse errors; fall back to network.
  //   }
  //
  //   try {
  //     final response = await http.get(
  //       Uri.parse('${Constant.baseUrl}settings/getActiveCurrency'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
  //         Constant.currencyModel = CurrencyModel.fromJson(jsonResponse['data']);
  //
  //         // Persist cache for next launches.
  //         await Preferences.setString(
  //           _currencyCacheJsonKey,
  //           jsonEncode(jsonResponse['data']),
  //         );
  //         await Preferences.setInt(
  //           _currencyCacheTimeMsKey,
  //           DateTime.now().millisecondsSinceEpoch,
  //         );
  //       } else {
  //         _setDefaultCurrency();
  //       }
  //     } else {
  //       _setDefaultCurrency();
  //     }
  //   } catch (e) {
  //     _setDefaultCurrency();
  //   }
  //   // await FireStoreUtils.getSettings();
  // }
  _setDefaultCurrency() {
    Constant.currencyModel = CurrencyModel(
      id: "664d8fc37be19",
      code: "INR",
      decimalDigits: 2,
      enable: true,
      name: "Indian Rupee",
      symbol: "₹",
      symbolAtRight: false,
    );
  }

  NotificationService notificationService = NotificationService();

  /// On startup (after login): get FCM token and call profile update API with fcmToken.
  /// Runs from onInit when app opens; if user is logged in, updates server with current token.
  Future<void> notificationInit() async {
    try {
      if (Firebase.apps.isEmpty) {
        print("❌ Firebase not initialized, skipping notificationInit");
        return;
      }

      await notificationService.initInfo();

      final userId = await FireStoreUtils.getCurrentUid();
      if (userId.isEmpty) return;

      final token = await NotificationService.getToken();
      if (token == null || token.isEmpty) {
        print("⚠️ FCM token not available, skipping update");
        return;
      }

      final userModel = await FireStoreUtils.getUserProfile(userId);
      if (userModel == null) return;

      userModel.fcmToken = token;
      await FireStoreUtils.updateUser(userModel);
    } catch (e) {
      print("notificationInit error: $e");
    }
  }
}
