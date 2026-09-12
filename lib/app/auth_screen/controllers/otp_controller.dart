import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';

class OtpController extends GetxController {
  Rx<TextEditingController> otpController = TextEditingController().obs;

  RxString countryCode = "".obs;
  RxString phoneNumber = "".obs;
  RxString verificationId = "".obs;
  RxInt resendToken = 0.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      countryCode.value = argumentData['countryCode'];
      phoneNumber.value = argumentData['phoneNumber'];
      verificationId.value = argumentData['verificationId'];
    }
    isLoading.value = false;
    update();
  }

  @override
  void onClose() {
    otpController.value.dispose();
    super.onClose();
  }
}
