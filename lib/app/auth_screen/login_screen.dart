import 'dart:io';

import 'package:jippymart_restaurant/app/auth_screen/signup_screen.dart';
import 'package:jippymart_restaurant/app/forgot_password_screen/forgot_password_screen.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/login_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/themes/text_field_widget.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../terms_and_condition/terms_and_condition_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: LoginController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem()
                  ? AppThemeData.surfaceDark
                  : AppThemeData.surface,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Restaurant Partner Login".tr,
                      style: TextStyle(
                          color: themeChange.getThem()
                              ? AppThemeData.grey50
                              : AppThemeData.grey900,
                          fontSize: 22,
                          fontFamily: AppThemeData.semiBold),
                    ),
                    Text(
                      "Log in to manage your restaurant account, accept orders, and handle reservations."
                          .tr,
                      style: TextStyle(
                          color: themeChange.getThem()
                              ? AppThemeData.grey400
                              : AppThemeData.grey500,
                          fontSize: 16,
                          fontFamily: AppThemeData.regular),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    TextFieldWidget(
                      title: 'Username'.tr,
                      controller: controller.emailEditingController.value,
                      hintText: 'Enter userName'.tr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          "assets/icons/ic_mail.svg",
                          colorFilter: ColorFilter.mode(
                            themeChange.getThem()
                                ? AppThemeData.grey300
                                : AppThemeData.grey600,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    TextFieldWidget(
                      title: 'Password'.tr,
                      controller: controller.passwordEditingController.value,
                      hintText: 'Enter Password'.tr,
                      obscureText: controller.passwordVisible.value,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          "assets/icons/ic_lock.svg",
                          colorFilter: ColorFilter.mode(
                            themeChange.getThem()
                                ? AppThemeData.grey300
                                : AppThemeData.grey600,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      suffix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: InkWell(
                            onTap: () {
                              controller.passwordVisible.value =
                                  !controller.passwordVisible.value;
                            },
                            child: controller.passwordVisible.value
                                ? SvgPicture.asset(
                                    "assets/icons/ic_password_close.svg",
                                    colorFilter: ColorFilter.mode(
                                      themeChange.getThem()
                                          ? AppThemeData.grey300
                                          : AppThemeData.grey600,
                                      BlendMode.srcIn,
                                    ),
                                  )
                                : SvgPicture.asset(
                                      "assets/icons/ic_password_show.svg",
                                    colorFilter: ColorFilter.mode(
                                      themeChange.getThem()
                                          ? AppThemeData.grey300
                                          : AppThemeData.grey600,
                                      BlendMode.srcIn,
                                    ),
                                  )),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Get.to(const ForgotPasswordScreen());
                        },
                        child: Text(
                          "Forgot Password".tr,
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: AppThemeData.secondary300,
                              color: AppThemeData.secondary300,
                              fontSize: 14,
                              fontFamily: AppThemeData.regular),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    RoundedButtonFill(
                      title: "Login".tr,
                      color: AppThemeData.secondary300,
                      textColor: AppThemeData.grey50,
                      onPress: () async {
                        if (controller.emailEditingController.value.text.trim().isEmpty) {
                          ShowToastDialog.showToast("Please enter valid email".tr);
                        } else if (controller.passwordEditingController.value.text.trim().isEmpty) {
                          ShowToastDialog.showToast("Please enter valid password".tr);
                        } else {
                          controller.loginWithEmailAndPassword();
                        }
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),

                  ],
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding:
              EdgeInsets.symmetric(vertical: Platform.isAndroid ? 60 : 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Existing sign up text
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: 'Didn’t have an account?'.tr,
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                              fontFamily: AppThemeData.medium,
                              fontWeight: FontWeight.w500,
                            )),
                        const WidgetSpan(
                            child: SizedBox(
                              width: 10,
                            )),
                        TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(const SignupScreen());
                              },
                            text: 'Sign up'.tr,
                            style: TextStyle(
                              color: AppThemeData.secondary300,
                              fontFamily: AppThemeData.bold,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              decorationColor: AppThemeData.secondary300,
                            )),
                      ],
                    ),
                  ),
                  // Terms and Privacy buttons
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Terms and Conditions button
                      InkWell(
                        onTap: () {
                          Get.to(const TermsAndConditionScreen(
                            type: "termAndCondition",
                          ));
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey800
                                    : AppThemeData.grey100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(120),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: SvgPicture.asset(
                                  "assets/icons/ic_terms_condition.svg",
                                  colorFilter: ColorFilter.mode(
                                    themeChange.getThem()
                                        ? AppThemeData.grey300
                                        : AppThemeData.grey600,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Terms and Conditions".tr,
                              style: TextStyle(
                                fontSize: 10,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey900,
                                fontFamily: AppThemeData.medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Privacy Policy button
                      InkWell(
                        onTap: () {
                          Get.to(const TermsAndConditionScreen(
                            type: "privacy",
                          ));
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey800
                                    : AppThemeData.grey100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(120),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: SvgPicture.asset(
                                  "assets/icons/ic_privacyPolicy.svg",
                                  colorFilter: ColorFilter.mode(
                                    themeChange.getThem()
                                        ? AppThemeData.grey300
                                        : AppThemeData.grey600,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Privacy Policy".tr,
                              style: TextStyle(
                                fontSize: 10,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey900,
                                fontFamily: AppThemeData.medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),          );
        });
  }


}
