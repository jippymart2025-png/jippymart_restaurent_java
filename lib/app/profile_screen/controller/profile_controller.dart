// import 'dart:developer';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/controller/merchant_outlet_controller.dart';
// import 'package:jippymart_restaurant/models/merchant_response_model.dart';
// import 'package:jippymart_restaurant/models/user_model.dart';
// import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
// import 'package:jippymart_restaurant/utils/preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:jippymart_restaurant/models/outlet_model.dart';
//
// class ProfileController extends GetxController {
//   RxBool isOutletContext = false.obs;
//   Rx<OutletModel> outletModel = OutletModel().obs;
//
//   RxBool isLoading = true.obs;
//
//   Rx<UserModel> userModel = UserModel().obs;
//   Rxn<MerchantModel> merchantModel = Rxn<MerchantModel>();
//
//   @override
//   void onInit() {
//     // TODO: implement onInit
//     getUserProfile();
//     getThem();
//     super.onInit();
//   }
//
//   // getUserProfile() async {
//   //   String userId = await FireStoreUtils.getCurrentUid();
//   //   await FireStoreUtils.getUserProfile(userId).then(
//   //         (value) {
//   //       if (value != null) {
//   //         userModel.value = value;
//   //         Constant.userModel = userModel.value;
//   //       }
//   //     },
//   //   );
//   //   isLoading.value = false;
//   // }
// // This is java related working method(start)
// //   getUserProfile() async {
// //     try {
// //       String merchantId = Preferences.getString('merchantId');
// //
// //       if (merchantId.isNotEmpty) {
// //         // Java API
// //         final value = await FireStoreUtils.getMerchantProfile(merchantId);
// //         if (value != null) {
// //           userModel.value = value;
// //           Constant.userModel = value;
// //         }
// //       } else {
// //         // Fallback: existing PHP/Firebase API
// //         String userId = await FireStoreUtils.getCurrentUid();
// //         final value = await FireStoreUtils.getUserProfile(userId);
// //         if (value != null) {
// //           userModel.value = value;
// //           Constant.userModel = value;
// //         }
// //       }
// //     } catch (e) {
// //       debugPrint('getUserProfile error: $e');
// //     }
// //     isLoading.value = false;
// //   }
//   getUserProfile() async {
//     try {
//       final outletId = Preferences.getInt('outletId');
//       isOutletContext.value = outletId > 0;
//
//       if (isOutletContext.value) {
//         final outlet = await FireStoreUtils.getOutletProfile(outletId);
//         if (outlet != null) outletModel.value = outlet;
//         isLoading.value = false;
//         return;
//       }
//
//       if (Preferences.getString('loginType') == 'MERCHANT' &&
//           Get.isRegistered<MerchantOutletController>()) {
//         final cached =
//             Get.find<MerchantOutletController>().merchantProfile.value;
//         if (cached != null) {
//           merchantModel.value = cached;
//           Constant.merchantModel = cached;
//           // Map merchant display fields into userModel for existing UI.
//           userModel.value.email = cached.merchantEmail ?? cached.merchantName ?? '';
//           userModel.value.phoneNumber = cached.merchantPhone;
//           Constant.userModel = userModel.value;
//           debugPrint('[Profile] Using cached merchant profile (no API call)');
//           isLoading.value = false;
//           return;
//         }
//       }
//
//       String merchantId = Preferences.getString('merchantId');
//       final value = await FireStoreUtils.getMerchantProfile(merchantId);
//       if (value != null) {
//         merchantModel.value = value;
//         Constant.merchantModel = value;
//         // Map merchant display fields into userModel for existing UI.
//         userModel.value.email = value.merchantEmail ?? value.merchantName ?? '';
//         userModel.value.phoneNumber = value.merchantPhone;
//         userModel.value.walletAmount = 0;
//         Constant.userModel = userModel.value;
//       }
//     } catch (e) {
//       debugPrint('getUserProfile error: $e');
//     }
//     isLoading.value = false;
//   }
// //(end)
//   RxString isDarkMode = "Light".obs;
//   RxBool isDarkModeSwitch = false.obs;
//
//   getThem() {
//     isDarkMode.value = Preferences.getString(Preferences.themKey);
//     if (isDarkMode.value == "Dark") {
//       isDarkModeSwitch.value = true;
//     } else if (isDarkMode.value == "Light") {
//       isDarkModeSwitch.value = false;
//     } else {
//       isDarkModeSwitch.value = false;
//     }
//     isLoading.value = false;
//   }
//
//   Future<bool> deleteUserFromServer() async {
//     var url = '${Constant.storeUrl}/api/delete-user';
//     try {
//       var response = await http.post(
//         Uri.parse(url),
//         body: {
//           'uuid': FireStoreUtils.getCurrentUid(),
//         },
//       );
//       log("deleteUserFromServer :: ${response.body}");
//       if (response.statusCode == 200) {
//         return true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       return false;
//     }
//   }
// }



import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/merchant_outlet_controller.dart';
import 'package:jippymart_restaurant/models/merchant_response_model.dart';
import 'package:jippymart_restaurant/models/outlet_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

class ProfileController extends GetxController {
  // ─────────────────────────── Reactive state ───────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isOutletContext = false.obs;

  final Rx<UserModel> userModel = UserModel().obs;
  final Rx<OutletModel> outletModel = OutletModel().obs;
  final Rxn<MerchantModel> merchantModel = Rxn<MerchantModel>();

  final RxString isDarkMode = 'Light'.obs;
  final RxBool isDarkModeSwitch = false.obs;

  @override
  void onInit() {
    super.onInit();
    isOutletContext.value = Preferences.getInt('outletId') > 0;
    getUserProfile();
    getThem();
  }

  // ─────────────────────────── Profile loading ───────────────────────────
  Future<void> getUserProfile() async {
    try {
      final outletId = Preferences.getInt('outletId');
      isOutletContext.value = outletId > 0;

      if (isOutletContext.value) {
        await _loadOutletProfile(outletId);
      } else {
        await _loadMerchantProfile();
      }
    } catch (e, st) {
      debugPrint('ProfileController.getUserProfile error: $e\n$st');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadOutletProfile(int outletId) async {
    final outlet = await FireStoreUtils.getOutletProfile(outletId);
    if (outlet == null) return;

    outletModel.value = outlet;
    debugPrint('[Profile] Loaded outlet: ${outlet.outletName}');
  }

  Future<void> _loadMerchantProfile() async {
    // Fast path — reuse cached merchant profile if the controller already has it.
    if (Preferences.getString('loginType') == 'MERCHANT' &&
        Get.isRegistered<MerchantOutletController>()) {
      final cached =
          Get.find<MerchantOutletController>().merchantProfile.value;
      if (cached != null) {
        _applyMerchantProfile(cached);
        debugPrint('[Profile] Using cached merchant profile (no API call)');
        return;
      }
    }

    // Slow path — fetch from server.
    final merchantId = Preferences.getString('merchantId');
    final value = await FireStoreUtils.getMerchantProfile(merchantId);
    if (value != null) {
      _applyMerchantProfile(value);
    }
  }

  /// Single source of truth for mapping a [MerchantModel] into the app's
  /// UI-facing state — keeps `userModel` and `merchantModel` in sync.
  void _applyMerchantProfile(MerchantModel value) {
    merchantModel.value = value;
    Constant.merchantModel = value;

    // Map merchant fields into userModel for the existing UI.
    userModel.value.email =
        value.merchantEmail ?? value.merchantName ?? '';
    userModel.value.phoneNumber = value.merchantPhone;
    userModel.value.walletAmount = 0;
    Constant.userModel = userModel.value;
  }

  // ─────────────────────────── Theme ───────────────────────────
  void getThem() {
    isDarkMode.value = Preferences.getString(Preferences.themKey);
    isDarkModeSwitch.value = isDarkMode.value == 'Dark';
    isLoading.value = false;
  }

  void onDarkModeToggled(bool enabled) {
    isDarkModeSwitch.value = enabled;
    if (enabled) {
      Preferences.setString(Preferences.themKey, 'Dark');
    } else if (isDarkMode.value == 'Light') {
      Preferences.setString(Preferences.themKey, 'Light');
    } else {
      Preferences.setString(Preferences.themKey, '');
    }
  }

  // ─────────────────────────── Account deletion ───────────────────────────
  Future<bool> deleteUserFromServer() async {
    final url = Uri.parse('${Constant.storeUrl}/api/delete-user');
    try {
      final response = await http.post(
        url,
        body: {'uuid': FireStoreUtils.getCurrentUid()},
      );
      log('deleteUserFromServer :: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('deleteUserFromServer error: $e');
      return false;
    }
  }
}