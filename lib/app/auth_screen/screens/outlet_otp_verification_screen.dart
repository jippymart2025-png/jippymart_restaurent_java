// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:jippymart_restaurant/controller/outlet_otp_controller.dart';
// import 'package:jippymart_restaurant/themes/round_button_fill.dart';
// import 'package:jippymart_restaurant/themes/text_field_widget.dart';
//
// class OutletOtpVerificationScreen extends StatelessWidget {
//   const OutletOtpVerificationScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<OutletOtpController>(
//       init: OutletOtpController(),
//       builder: (controller) {
//         return Scaffold(
//           appBar: AppBar(title: const Text("Verify to Add Outlet")),
//           body: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Obx(() {
//               if (controller.isResolvingEmail.value) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               return controller.otpSent.value
//                   ? _otpStep(controller)
//                   : _emailStep(controller);
//             }),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _emailStep(OutletOtpController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextFieldWidget(
//           title: 'Registered Email',
//           controller: TextEditingController(text: controller.merchantEmail),
//           hintText: '',
//           enable: false,
//         ),
//         const SizedBox(height: 20),
//         Obx(() => RoundedButtonFill(
//           title: controller.isLoading.value ? "Sending..." : "Send OTP",
//           color: const Color(0xFFC3BFBC),
//           textColor: Colors.white,
//           onPress: controller.isLoading.value ? () {} : () => controller.sendOtp(),
//         )),
//       ],
//     );
//   }
//
//   Widget _otpStep(OutletOtpController controller) {
//     final blocked = controller.isExpired.value || controller.isLockedOut.value;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("OTP sent to ${controller.merchantEmail}"),
//         const SizedBox(height: 8),
//
//         if (!controller.isExpired.value)
//           Text(
//             "Expires in ${controller.formattedTimeLeft}",
//             style: const TextStyle(color: Colors.grey),
//           )
//         else
//           const Text(
//             "This OTP has expired. Please resend.",
//             style: TextStyle(color: Colors.red),
//           ),
//
//         const SizedBox(height: 4),
//
//         if (!controller.isLockedOut.value && !controller.isExpired.value)
//           Text(
//             "${controller.attemptsLeft.value} attempt${controller.attemptsLeft.value == 1 ? '' : 's'} remaining",
//             style: const TextStyle(color: Colors.grey, fontSize: 12),
//           )
//         else if (controller.isLockedOut.value)
//           const Text(
//             "Maximum attempts reached. Please resend.",
//             style: TextStyle(color: Colors.red),
//           ),
//
//         const SizedBox(height: 12),
//
//         TextFieldWidget(
//           title: 'Enter OTP',
//           controller: controller.otpController.value,
//           hintText: '6-digit code',
//           enable: !blocked,
//           textInputType: TextInputType.number,
//           inputFormatters: [
//             FilteringTextInputFormatter.digitsOnly,
//             LengthLimitingTextInputFormatter(6),
//           ],
//         ),
//
//         const SizedBox(height: 20),
//
//         RoundedButtonFill(
//           title: controller.isLoading.value ? "Verifying..." : "Verify",
//           color: const Color(0xFFC3BFBC),
//           textColor: Colors.white,
//           onPress: (controller.isLoading.value || blocked)
//               ? () {}
//               : () => controller.verifyOtp(),
//         ),
//
//         const SizedBox(height: 10),
//
//         TextButton(
//           onPressed: controller.resendCooldown.value == 0
//               ? () => controller.resendOtp()
//               : null,
//           child: Text(controller.resendCooldown.value == 0
//               ? "Resend OTP"
//               : "Resend in ${controller.resendCooldown.value}s"),
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/controller/outlet_otp_controller.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/themes/text_field_widget.dart';
import 'package:jippymart_restaurant/widget/otp_box_input.dart';

class OutletOtpVerificationScreen extends StatelessWidget {
  const OutletOtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OutletOtpController>(
      init: OutletOtpController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text("Verify to Add Outlet")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              if (controller.isResolvingEmail.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return controller.otpSent.value
                  ? _otpStep(controller)
                  : _emailStep(controller);
            }),
          ),
        );
      },
    );
  }

  Widget _emailStep(OutletOtpController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldWidget(
          title: 'Registered Email',
          controller: TextEditingController(text: controller.merchantEmail),
          hintText: '',
          enable: false,
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

  Widget _otpStep(OutletOtpController controller) {
    final blocked = controller.isExpired.value || controller.isLockedOut.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("OTP sent to ${controller.merchantEmail}"),
        const SizedBox(height: 16),

        // No live countdown shown — expiry still enforced in the background,
        // only surfaced once it actually happens.
        if (controller.isExpired.value)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              "This OTP has expired. Please resend.",
              style: TextStyle(color: Colors.red),
            ),
          ),

        if (!controller.isLockedOut.value && !controller.isExpired.value)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              "${controller.attemptsLeft.value} attempt${controller.attemptsLeft.value == 1 ? '' : 's'} remaining",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else if (controller.isLockedOut.value)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              "Maximum attempts reached. Please resend.",
              style: TextStyle(color: Colors.red),
            ),
          ),

        const Text("Enter OTP", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),

        IgnorePointer(
          ignoring: blocked,
          child: Opacity(
            opacity: blocked ? 0.5 : 1,
            child: OtpBoxInput(
              onChanged: (code) => controller.otpController.value.text = code,
            ),
          ),
        ),

        const SizedBox(height: 24),

        RoundedButtonFill(
          title: controller.isLoading.value ? "Verifying..." : "Verify",
          color: const Color(0xFFE8834A),
          textColor: Colors.white,
          onPress: (controller.isLoading.value || blocked)
              ? () {}
              : () => controller.verifyOtp(),
        ),

        const SizedBox(height: 10),

        Center(
          child: TextButton(
            onPressed: controller.resendCooldown.value == 0
                ? () => controller.resendOtp()
                : null,
            child: Text(controller.resendCooldown.value == 0
                ? "Resend OTP"
                : "Resend in ${controller.resendCooldown.value}s"),
          ),
        ),
      ],
    );
  }
}