import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../themes/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../terms_and_condition/terms_and_condition_screen.dart';
import '../../verification_screen/verification_screen.dart';
import '../controller/profile_controller.dart';
import '../profile_screen.dart';
import 'ProfileRow.dart';
import 'SectionTitle.dart' show SectionTitle;

class LegalSection extends StatelessWidget {
  const LegalSection({
    required this.controller,
    required this.themeChange,
  });

  final ProfileController controller;
  final DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    final bg = themeChange.getThem()
        ? AppThemeData.grey800
        : AppThemeData.grey100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Legal'),
        const SizedBox(height: 10),
        SectionCard(
          children: [
            ProfileRow(
              controller: controller,
              icon: IconBubble(
                asset: 'assets/icons/ic_documention.svg',
                bgColor: bg,
              ),
              title: 'Document Verifications',
              onTap: () => Get.to(const VerificationScreen()),
            ),
            ProfileRow(
              controller: controller,
              icon: IconBubble(
                asset: 'assets/icons/ic_terms_condition.svg',
                bgColor: bg,
              ),
              title: 'Terms and Conditions',
              onTap: () => Get.to(
                const TermsAndConditionScreen(type: 'termAndCondition'),
              ),
            ),
            ProfileRow(
              controller: controller,
              icon: IconBubble(
                asset: 'assets/icons/ic_privacyPolicy.svg',
                bgColor: bg,
              ),
              title: 'Privacy Policy',
              onTap: () => Get.to(
                const TermsAndConditionScreen(type: 'privacy'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
