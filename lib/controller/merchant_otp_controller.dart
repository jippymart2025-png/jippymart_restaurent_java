import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/app/auth_screen/signup_screen.dart';

import '../service/merchant_otp_service.dart';

class MerchantOtpController extends GetxController {
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> mobileController = TextEditingController().obs;
  Rx<TextEditingController> otpController = TextEditingController().obs;

  RxBool otpSent = false.obs;
  RxInt resendSeconds = 0.obs;
  RxBool isLoading = false.obs;

  bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email);
  }

  Future<void> sendOtp() async {
    final email = emailController.value.text.trim();
    final mobile = mobileController.value.text.trim();

    if (email.isEmpty || !isValidEmail(email)) {
      ShowToastDialog.showToast("Please enter a valid email");
      return;
    }
    if (mobile.isEmpty || mobile.length != 10) {
      ShowToastDialog.showToast("Please enter a valid 10-digit mobile number");
      return;
    }

    isLoading.value = true;
    final res = await MerchantOtpService.sendSignupOtp(email: email, mobile: mobile);
    isLoading.value = false;

    if (res.success) {
      otpSent.value = true;
      _startResendTimer();
      ShowToastDialog.showToast("OTP sent to $email");
    } else {
      ShowToastDialog.showToast(res.statusMsg.isNotEmpty ? res.statusMsg : "Failed to send OTP");
    }
  }

  Future<void> verifyOtp() async {
    final email = emailController.value.text.trim();
    final otp = otpController.value.text.trim();

    if (otp.isEmpty) {
      ShowToastDialog.showToast("Please enter the OTP");
      return;
    }

    isLoading.value = true;
    final res = await MerchantOtpService.verifySignupOtp(email: email, otp: otp);
    isLoading.value = false;

    if (res.success) {
      Get.off(() => const SignupScreen(), arguments: {
        'type': 'emailVerified',
        'email': email,
        'mobile': mobileController.value.text.trim(),
      });
    } else {
      ShowToastDialog.showToast("Invalid OTP, please try again");
    }
  }

  Future<void> resendOtp() async {
    final email = emailController.value.text.trim();
    final mobile = mobileController.value.text.trim();

    final res = await MerchantOtpService.resendSignupOtp(email: email, mobile: mobile);
    if (res.success) {
      _startResendTimer();
      ShowToastDialog.showToast("OTP resent");
    } else {
      ShowToastDialog.showToast(res.statusMsg.isNotEmpty ? res.statusMsg : "Failed to resend OTP");
    }
  }

  void _startResendTimer() {
    resendSeconds.value = 120;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      resendSeconds.value--;
      return resendSeconds.value > 0;
    });
  }

  @override
  void onClose() {
    emailController.value.dispose();
    mobileController.value.dispose();
    otpController.value.dispose();
    super.onClose();
  }
}