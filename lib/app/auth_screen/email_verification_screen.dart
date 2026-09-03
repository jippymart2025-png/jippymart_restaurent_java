// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:jippymart_restaurant/controller/merchant_otp_controller.dart';
// import 'package:jippymart_restaurant/themes/round_button_fill.dart';
// import 'package:jippymart_restaurant/themes/text_field_widget.dart';
//
// class EmailVerificationScreen extends StatelessWidget {
//   const EmailVerificationScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<MerchantOtpController>(
//       init: MerchantOtpController(),
//       builder: (controller) {
//         return Scaffold(
//           appBar: AppBar(title: const Text("Verify Email")),
//           body: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Obx(() => controller.otpSent.value
//                 ? _otpStep(controller)
//                 : _emailStep(controller)),
//           ),
//         );
//       },
//     );
//   }
//
//   // Wraps a field in a highlighted container (colored border + light fill)
//   // Widget _highlightedField({
//   //   required String title,
//   //   required TextEditingController controller,
//   //   required String hintText,
//   // }) {
//   //   return Container(
//   //     margin: const EdgeInsets.only(bottom: 16),
//   //     decoration: BoxDecoration(
//   //       color: const Color(0xFFFFF3E0), // light highlight background
//   //       borderRadius: BorderRadius.circular(10),
//   //       border: Border.all(color: const Color(0xFFEAE7E5), width: 1.4), // highlight border color
//   //     ),
//   //     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//   //     child: TextFieldWidget(
//   //       title: title,
//   //       controller: controller,
//   //       hintText: hintText,
//   //     ),
//   //   );
//   // }
//   Widget _highlightedField({
//     required String title,
//     required TextEditingController controller,
//     required String hintText,
//     List<TextInputFormatter>? inputFormatters,
//     TextInputType? textInputType,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFF3E0),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: const Color(0xFFEAE7E5), width: 1.4),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//       child: TextFieldWidget(
//         title: title,
//         controller: controller,
//         hintText: hintText,
//         inputFormatters: inputFormatters,
//         textInputType: textInputType,
//       ),
//     );
//   }
//   Widget _emailStep(MerchantOtpController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _highlightedField(
//           title: 'Email Address',
//           controller: controller.emailController.value,
//           hintText: 'Enter Email Address',
//         ),
//         _highlightedField(
//           title: 'Mobile Number',
//           controller: controller.mobileController.value,
//           hintText: 'Enter Mobile Number',
//         ),
//         const SizedBox(height: 20),
//         Obx(() => RoundedButtonFill(
//           title: controller.isLoading.value ? "Sending..." : "Send OTP",
//           color: const Color(0xFFC3BFBC), // Send OTP button color
//           textColor: Colors.white,
//           onPress: controller.isLoading.value ? () {} : () => controller.sendOtp(),
//         )),
//       ],
//     );
//   }
//
//   Widget _otpStep(MerchantOtpController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("OTP sent to ${controller.emailController.value.text}"),
//         const SizedBox(height: 12),
//         _highlightedField(
//           title: 'Enter OTP',
//           controller: controller.otpController.value,
//           hintText: '6-digit code',
//           textInputType: TextInputType.number,
//           inputFormatters: [
//             FilteringTextInputFormatter.digitsOnly,
//             LengthLimitingTextInputFormatter(6),
//           ],
//         ),
//         const SizedBox(height: 20),
//         Obx(() => RoundedButtonFill(
//           title: controller.isLoading.value ? "Verifying..." : "Verify",
//           color: const Color(0xFFEAE6E3),
//           textColor: Colors.white,
//           onPress: controller.isLoading.value ? () {} : () => controller.verifyOtp(),
//         )),
//         const SizedBox(height: 10),
//         Obx(() => TextButton(
//           onPressed: controller.resendSeconds.value == 0 ? () => controller.resendOtp() : null,
//           child: Text(controller.resendSeconds.value == 0
//               ? "Resend OTP"
//               : "Resend in ${controller.resendSeconds.value}s"),
//         )),
//       ],
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/controller/merchant_otp_controller.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/themes/text_field_widget.dart';
import 'package:jippymart_restaurant/widget/otp_box_input.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MerchantOtpController>(
      init: MerchantOtpController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text("Verify Email")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => controller.otpSent.value
                ? _otpStep(controller)
                : _emailStep(controller)),
          ),
        );
      },
    );
  }

  Widget _highlightedField({
    required String title,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAE7E5), width: 1.4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: TextFieldWidget(
        title: title,
        controller: controller,
        hintText: hintText,
      ),
    );
  }

  Widget _emailStep(MerchantOtpController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _highlightedField(
          title: 'Email Address',
          controller: controller.emailController.value,
          hintText: 'Enter Email Address',
        ),
        _highlightedField(
          title: 'Mobile Number',
          controller: controller.mobileController.value,
          hintText: 'Enter Mobile Number',
        ),
        const SizedBox(height: 20),
        Obx(() => RoundedButtonFill(
          title: controller.isLoading.value ? "Sending..." : "Send OTP",
          color: const Color(0xFFE8834A),
          textColor: Colors.white,
          onPress: controller.isLoading.value ? () {} : () => controller.sendOtp(),
        )),
      ],
    );
  }

  Widget _otpStep(MerchantOtpController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("OTP sent to ${controller.emailController.value.text}"),
        const SizedBox(height: 16),

        const Text("Enter OTP", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),

        OtpBoxInput(
          onChanged: (code) => controller.otpController.value.text = code,
        ),

        const SizedBox(height: 24),

        Obx(() => RoundedButtonFill(
          title: controller.isLoading.value ? "Verifying..." : "Verify",
          color: const Color(0xFFE8834A),
          textColor: Colors.white,
          onPress: controller.isLoading.value ? () {} : () => controller.verifyOtp(),
        )),

        const SizedBox(height: 10),

        Center(
          child: Obx(() => TextButton(
            onPressed: controller.resendSeconds.value == 0 ? () => controller.resendOtp() : null,
            child: Text(controller.resendSeconds.value == 0
                ? "Resend OTP"
                : "Resend in ${controller.resendSeconds.value}s"),
          )),
        ),
      ],
    );
  }
}