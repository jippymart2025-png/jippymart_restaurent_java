import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

import '../service/outlet_otp_service.dart';

class OutletOtpController extends GetxController {
  static const int otpValiditySeconds = 10 * 60; // 10 minutes
  static const int maxAttempts = 5;
  static const int resendCooldownSeconds = 120;

  Rx<TextEditingController> otpController = TextEditingController().obs;

  RxBool otpSent = false.obs;
  RxBool isLoading = false.obs;
  RxBool isResolvingEmail = false.obs;
  RxBool isVerified = false.obs;

  RxInt resendCooldown = 0.obs;      // for "Resend" button throttling
  RxInt otpSecondsLeft = 0.obs;      // for the 10-min validity window
  RxInt attemptsLeft = maxAttempts.obs;
  RxBool isExpired = false.obs;
  RxBool isLockedOut = false.obs;    // true after 5 failed attempts

  Timer? _resendTimer;
  Timer? _expiryTimer;

  int merchantId = 0;
  String merchantEmail = '';

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    _expiryTimer?.cancel();
    otpController.value.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    final loginType = Preferences.getString('loginType');
    if (loginType != 'MERCHANT') {
      ShowToastDialog.showToast("Only merchant accounts can create outlets");
      Get.back();
      return;
    }

    merchantId = int.tryParse(Preferences.getString('merchantId')) ?? 0;
    if (merchantId <= 0) {
      ShowToastDialog.showToast("Merchant ID not found. Please log in again.");
      Get.back();
      return;
    }

    isResolvingEmail.value = true;

    if (Constant.userModel?.email != null && Constant.userModel!.email!.isNotEmpty) {
      merchantEmail = Constant.userModel!.email!;
    } else {
      final cached = Preferences.getString('merchantEmail');
      if (cached.isNotEmpty) {
        merchantEmail = cached;
      } else {
        try {
          final profile = await FireStoreUtils.getMerchantProfile(merchantId.toString());
          if (profile?.email != null && profile!.email!.isNotEmpty) {
            merchantEmail = profile.email!;
            await Preferences.setString('merchantEmail', merchantEmail);
          }
        } catch (e) {
          debugPrint('OutletOtpController email resolution failed: $e');
        }
      }
    }

    isResolvingEmail.value = false;

    if (merchantEmail.isEmpty) {
      ShowToastDialog.showToast("Unable to find your registered email. Please contact support.");
      Get.back();
      return;
    }
  }

  Future<void> sendOtp() async {
    if (merchantId <= 0) return;

    isLoading.value = true;
    final res = await OutletOtpService.sendCreateOutletOtp(merchantId: merchantId);
    isLoading.value = false;

    if (res.success) {
      otpSent.value = true;
      isExpired.value = false;
      isLockedOut.value = false;
      attemptsLeft.value = maxAttempts;
      otpController.value.clear();
      _startResendCooldown();
      _startExpiryTimer();
      ShowToastDialog.showToast("OTP sent to $merchantEmail");
    } else {
      ShowToastDialog.showToast(res.statusMsg.isNotEmpty ? res.statusMsg : "Failed to send OTP");
    }
  }

  Future<void> verifyOtp() async {
    if (isExpired.value) {
      ShowToastDialog.showToast("OTP expired. Please resend.");
      return;
    }
    if (isLockedOut.value) {
      ShowToastDialog.showToast("Too many attempts. Please resend a new OTP.");
      return;
    }

    final otp = otpController.value.text.trim();
    if (otp.isEmpty) {
      ShowToastDialog.showToast("Please enter the OTP");
      return;
    }

    isLoading.value = true;
    final res = await OutletOtpService.verifyCreateOutletOtp(email: merchantEmail, otp: otp);
    isLoading.value = false;

    if (res.success) {
      isVerified.value = true;
      _expiryTimer?.cancel();
      Get.back(result: true);
    } else {
      attemptsLeft.value -= 1;
      if (attemptsLeft.value <= 0) {
        isLockedOut.value = true;
        ShowToastDialog.showToast("Maximum attempts reached. Please resend a new OTP.");
      } else {
        ShowToastDialog.showToast(
          "Invalid OTP. ${attemptsLeft.value} attempt${attemptsLeft.value == 1 ? '' : 's'} left.",
        );
      }
    }
  }

  Future<void> resendOtp() async {
    if (resendCooldown.value > 0) return;

    final res = await OutletOtpService.resendCreateOutletOtp(merchantId: merchantId);
    if (res.success) {
      isExpired.value = false;
      isLockedOut.value = false;
      attemptsLeft.value = maxAttempts;
      otpController.value.clear();
      _startResendCooldown();
      _startExpiryTimer();
      ShowToastDialog.showToast("OTP resent");
    } else {
      ShowToastDialog.showToast(res.statusMsg.isNotEmpty ? res.statusMsg : "Failed to resend OTP");
    }
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    resendCooldown.value = resendCooldownSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      resendCooldown.value--;
      if (resendCooldown.value <= 0) {
        timer.cancel();
      }
    });
  }

  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    otpSecondsLeft.value = otpValiditySeconds;
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      otpSecondsLeft.value--;
      if (otpSecondsLeft.value <= 0) {
        isExpired.value = true;
        timer.cancel();
      }
    });
  }

  String get formattedTimeLeft {
    final m = (otpSecondsLeft.value ~/ 60).toString().padLeft(2, '0');
    final s = (otpSecondsLeft.value % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}