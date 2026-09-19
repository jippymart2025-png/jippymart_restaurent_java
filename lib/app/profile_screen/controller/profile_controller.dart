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