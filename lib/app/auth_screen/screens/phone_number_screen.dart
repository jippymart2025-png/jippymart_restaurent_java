import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/controller/phone_number_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/themes/text_field_widget.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class PhoneNumberScreen extends StatelessWidget {
  const PhoneNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.getThem();

    // Create (or fetch) the controller ONCE, outside of any GetX/Obx builder.
    final controller = Get.put(PhoneNumberController());

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: PhoneNumberBody(controller: controller, isDark: isDark),
      ),
    );
  }
}

/// The screen body — scrollable, responsive, with the primary action
/// pinned to the bottom on tall screens.
class PhoneNumberBody extends StatelessWidget {
  const PhoneNumberBody({
    super.key,
    required this.controller,
    required this.isDark,
  });

  final PhoneNumberController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Scrollable content ────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Title
                Text(
                  "Login with Mobile Number".tr,
                  style: TextStyle(
                    color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                    fontSize: 22,
                    fontFamily: AppThemeData.semiBold,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  "Enter your mobile number to receive a verification code.".tr,
                  style: TextStyle(
                    color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                    fontSize: 16,
                    fontFamily: AppThemeData.regular,
                  ),
                ),

                const SizedBox(height: 32),

                // Mobile number input
                TextFieldWidget(
                  title: 'Mobile Number'.tr,
                  controller: controller.phoneNUmberEditingController.value,
                  hintText: 'Enter Mobile Number'.tr,
                  textInputType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: false,
                  ),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  prefix: _buildCountryPrefix(isDark),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // ── Fixed footer with primary action ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: RoundedButtonFill(
            title: "Send OTP".tr,
            color: AppThemeData.secondary300,
            textColor: AppThemeData.grey50,
            onPress: () async => await controller.sendLoginOtp(),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryPrefix(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇮🇳', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            '+91',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
              fontFamily: AppThemeData.medium,
            ),
          ),
        ],
      ),
    );
  }
}