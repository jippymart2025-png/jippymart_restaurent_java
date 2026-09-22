import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/merchant_response_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

class BankDetailsController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<TextEditingController> bankNameController = TextEditingController().obs;
  Rx<TextEditingController> branchNameController = TextEditingController().obs;
  Rx<TextEditingController> holderNameController = TextEditingController().obs;
  Rx<TextEditingController> accountNoController = TextEditingController().obs;
  Rx<TextEditingController> otherInfoController = TextEditingController().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getCurrentUser();
    super.onInit();
  }

  saveBank() async {
    ShowToastDialog.showLoader("Please wait".tr);
    final profile = Constant.merchantModel;
    if (profile == null) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Profile not found".tr);
      return;
    }
    profile
      ..accountNumber = accountNoController.value.text
      ..bankName = bankNameController.value.text
      ..ifscCode = branchNameController.value.text
      ..accountHolderName = holderNameController.value.text;
    final merchantId =
        profile.merchantId?.toString() ?? Preferences.getString('merchantId');
    final saved = await FireStoreUtils.updateMerchantProfile(merchantId, profile);
    ShowToastDialog.closeLoader();
    ShowToastDialog.showToast(
        saved ? "Bank details saved".tr : "Failed to save bank details".tr);
    Get.back();
    Get.back();
  }

  getCurrentUser() async {
    MerchantModel? profile = Constant.merchantModel;
    if (profile == null) {
      profile = await FireStoreUtils.getMerchantProfile(
        Preferences.getString('merchantId'),
      );
    }
    if (profile != null) {
      Constant.merchantModel = profile;
      bankNameController.value.text = profile.bankName ?? '';
      branchNameController.value.text = profile.ifscCode ?? '';
      holderNameController.value.text = profile.accountHolderName ?? '';
      accountNoController.value.text = profile.accountNumber ?? '';
      otherInfoController.value.text = '';
    }
    isLoading.value = false;
  }

  @override
  void onClose() {
    bankNameController.value.dispose();
    branchNameController.value.dispose();
    holderNameController.value.dispose();
    accountNoController.value.dispose();
    otherInfoController.value.dispose();
    super.onClose();
  }
}