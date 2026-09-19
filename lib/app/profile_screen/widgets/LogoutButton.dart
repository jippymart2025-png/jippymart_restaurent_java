import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../themes/app_them_data.dart';
import '../../../themes/custom_dialog_box.dart' show CustomDialogBox;
import '../../../utils/dark_theme_provider.dart';
import '../../auth_screen/controllers/login_controller.dart';
import '../controller/profile_controller.dart';
import 'ProfileRow.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    required this.controller,
    required this.loginController,
    required this.themeChange,
  });

  final ProfileController controller;
  final LoginController loginController;
  final DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: themeChange.getThem()
            ? AppThemeData.grey900
            : AppThemeData.grey50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      child: ProfileRow(
        controller: controller,
        icon: SvgPicture.asset(
          'assets/icons/ic_logout.svg',
        ),
        title: 'Log out',
        danger: true,
        onTap: () => _confirmLogout(context),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomDialogBox(
        title: 'Log out'.tr,
        descriptions:
        'Are you sure you want to log out? You will need to enter your credentials to log back in.'
            .tr,
        positiveString: 'Log out'.tr,
        negativeString: 'Cancel'.tr,
        positiveClick: () => loginController.logoutFunction(),
        negativeClick: () => Get.back(),
        img: Image.asset(
          'assets/images/ic_logout.gif',
          height: 50,
          width: 50,
        ),
      ),
    );
  }
}
