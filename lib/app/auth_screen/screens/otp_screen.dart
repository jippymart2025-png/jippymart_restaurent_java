import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../controllers/otp_controller.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.getThem();

    // Create (or fetch) the controller ONCE, outside of any GetX/Obx builder.
    final controller = Get.put(OtpController());

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: OtpBody(controller: controller, isDark: isDark),
      ),
    );
  }
}

/// The screen body. Kept as a separate StatelessWidget so it rebuilds
/// independently from the Scaffold / AppBar.
class OtpBody extends StatelessWidget {
  const OtpBody({
    super.key,
    required this.controller,
    required this.isDark,
  });

  final OtpController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Scrollable top content ────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Title
                Text(
                  "Verify Your Number 📱".tr,
                  style: TextStyle(
                    color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                    fontSize: 22,
                    fontFamily: AppThemeData.semiBold,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle — only this depends on mobileNumber, so wrap in Obx
                Obx(
                      () => Text(
                    "Enter the OTP sent to your mobile number ${controller.mobileNumber.value}",
                    style: TextStyle(
                      color: isDark
                          ? AppThemeData.grey200
                          : AppThemeData.grey700,
                      fontSize: 16,
                      fontFamily: AppThemeData.regular,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // OTP input
                _PinField(controller: controller, isDark: isDark),

                const SizedBox(height: 40),

                // Resend text
                _ResendText(controller: controller, isDark: isDark),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // ── Fixed footer with the primary action ──────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: RoundedButtonFill(
            title: "Verify & Next".tr,
            color: AppThemeData.secondary300,
            textColor: AppThemeData.grey50,
            onPress: () async => await controller.verifyOtp(),
          ),
        ),
      ],
    );
  }
}

/// Responsive 6-box OTP input that scales down on very narrow screens.
class _PinField extends StatelessWidget {
  const _PinField({required this.controller, required this.isDark});

  final OtpController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fillColor = isDark ? AppThemeData.grey900 : AppThemeData.grey50;

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const maxFieldWidth = 50.0;
          const spacing = 8.0;
          const totalSpacing = spacing * 5; // 5 gaps between 6 boxes
          final availableWidth = constraints.maxWidth - totalSpacing;
          final fieldWidth = (availableWidth / 6).clamp(36.0, maxFieldWidth);
          final fieldHeight = fieldWidth * 1.1;

          return SizedBox(
            width: fieldWidth * 6 + totalSpacing,
            child: PinCodeTextField(
              length: 6,
              appContext: context,
              keyboardType: TextInputType.number,
              enablePinAutofill: true,
              hintCharacter: "-",
              hintStyle: TextStyle(
                color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
                fontFamily: AppThemeData.regular,
              ),
              textStyle: TextStyle(
                color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                fontFamily: AppThemeData.regular,
                fontSize: 18,
              ),
              pinTheme: PinTheme(
                fieldHeight: fieldHeight,
                fieldWidth: fieldWidth,
                inactiveFillColor: fillColor,
                selectedFillColor: fillColor,
                activeFillColor: fillColor,
                selectedColor: AppThemeData.secondary300,
                activeColor: AppThemeData.secondary300,
                inactiveColor: fillColor,
                disabledColor: fillColor,
                shape: PinCodeFieldShape.box,
                errorBorderColor:
                isDark ? AppThemeData.grey600 : AppThemeData.grey300,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                borderWidth: 1.5,
              ),
              cursorColor: AppThemeData.secondary300,
              enableActiveFill: true,
              controller: controller.otpController.value,
              onCompleted: (value) => debugPrint("OTP Completed: $value"),
              onChanged: (_) {},
            ),
          );
        },
      ),
    );
  }
}

/// "Didn't receive any code? Send Again" rich text.
class _ResendText extends StatelessWidget {
  const _ResendText({required this.controller, required this.isDark});

  final OtpController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "${'Didn’t receive any code?'.tr} ",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          fontFamily: AppThemeData.medium,
          color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
        ),
        children: [
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () async => await controller.resendOtp(),
            text: 'Send Again'.tr,
            style: TextStyle(
              color: AppThemeData.secondary300,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              fontFamily: AppThemeData.medium,
              decoration: TextDecoration.underline,
              decorationColor: AppThemeData.secondary300,
            ),
          ),
        ],
      ),
    );
  }
}