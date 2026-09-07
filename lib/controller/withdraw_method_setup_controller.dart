import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/constant/collection_name.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/payment_model/flutter_wave_model.dart';
import 'package:jippymart_restaurant/models/payment_model/paypal_model.dart';
import 'package:jippymart_restaurant/models/payment_model/razorpay_model.dart';
import 'package:jippymart_restaurant/models/payment_model/stripe_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/withdraw_method_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

class WithdrawMethodSetupController extends GetxController {
  Rx<TextEditingController> accountNumberFlutterWave =
      TextEditingController().obs;
  Rx<TextEditingController> bankCodeFlutterWave = TextEditingController().obs;
  Rx<TextEditingController> emailPaypal = TextEditingController().obs;
  Rx<TextEditingController> accountIdRazorPay = TextEditingController().obs;
  Rx<TextEditingController> accountIdStripe = TextEditingController().obs;

  Rx<UserBankDetails> userBankDetails = UserBankDetails().obs;
  Rx<WithdrawMethodModel> withdrawMethodModel = WithdrawMethodModel().obs;

  RxBool isBankDetailsAdded = false.obs;

  RxBool isLoading = true.obs;
  Rx<RazorPayModel> razorPayModel = RazorPayModel().obs;
  Rx<PayPalModel> paypalDataModel = PayPalModel().obs;
  Rx<StripeModel> stripeSettingData = StripeModel().obs;
  Rx<FlutterWaveModel> flutterWaveSettingData = FlutterWaveModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getPaymentMethod();
    getPaymentSettings();
    super.onInit();
  }

  @override
  void onClose() {
    accountNumberFlutterWave.value.dispose();
    bankCodeFlutterWave.value.dispose();
    emailPaypal.value.dispose();
    accountIdRazorPay.value.dispose();
    accountIdStripe.value.dispose();
    super.onClose();
  }

  getPaymentMethod() async {
    isLoading.value = true;
    accountNumberFlutterWave.value.clear();
    bankCodeFlutterWave.value.clear();
    emailPaypal.value.clear();
    accountIdRazorPay.value.clear();
    accountIdStripe.value.clear();

    await FireStoreUtils.getWithdrawMethod().then(
      (value) {
        if (value != null) {
          withdrawMethodModel.value = value;

          if (withdrawMethodModel.value.flutterWave != null) {
            accountNumberFlutterWave.value.text =
                withdrawMethodModel.value.flutterWave!.accountNumber.toString();
            bankCodeFlutterWave.value.text =
                withdrawMethodModel.value.flutterWave!.bankCode.toString();
          }

          if (withdrawMethodModel.value.paypal != null) {
            emailPaypal.value.text =
                withdrawMethodModel.value.paypal!.email.toString();
          }

          if (withdrawMethodModel.value.razorpay != null) {
            accountIdRazorPay.value.text =
                withdrawMethodModel.value.razorpay!.accountId.toString();
          }
          if (withdrawMethodModel.value.stripe != null) {
            accountIdStripe.value.text =
                withdrawMethodModel.value.stripe!.accountId.toString();
          }
        }
      },
    );
    isLoading.value = false;
  }

  getPaymentSettings() async {
    userBankDetails.value = Constant.userModel!.userBankDetails!;
    isBankDetailsAdded.value = userBankDetails.value.accountNumber.isNotEmpty;

    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}settings/payment'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final paymentData = jsonResponse['data'];

          // Parse RazorPay settings
          if (paymentData['razorpaySettings'] != null) {
            razorPayModel.value = RazorPayModel.fromJson(paymentData['razorpaySettings']);
          }

          // Parse PayPal settings
          if (paymentData['paypalSettings'] != null) {
            paypalDataModel.value = PayPalModel.fromJson(paymentData['paypalSettings']);
          }

          // Parse Stripe settings
          if (paymentData['stripeSettings'] != null) {
            stripeSettingData.value = StripeModel.fromJson(paymentData['stripeSettings']);
          }

          // Parse FlutterWave settings
          if (paymentData['flutterWave'] != null) {
            flutterWaveSettingData.value = FlutterWaveModel.fromJson(paymentData['flutterWave']);
          }

        } else {
          debugPrint('Failed to load payment settings: ${jsonResponse['message']}');
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching payment settings: $e');
    }

    isLoading.value = false;
  }
}
