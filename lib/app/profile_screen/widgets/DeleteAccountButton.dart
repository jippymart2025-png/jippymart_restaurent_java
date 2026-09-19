import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../constant/show_toast_dialog.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/custom_dialog_box.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';
import '../controller/profile_controller.dart';

class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({
    required this.controller,
    required this.themeChange,
  });

  final ProfileController controller;
  final DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: InkWell(
        onTap: () => _confirmDelete(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/ic_delete.svg'),
            const SizedBox(width: 10),
            Text(
              'Delete Account'.tr,
              style: const TextStyle(
                fontFamily: AppThemeData.medium,
                fontSize: 16,
                color: AppThemeData.danger300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomDialogBox(
        title: 'Delete Account'.tr,
        descriptions:
        'Are you sure you want to delete your account? This action is irreversible and will permanently remove all your data.'
            .tr,
        positiveString: 'Delete'.tr,
        negativeString: 'Cancel'.tr,
        positiveClick: () async {
          ShowToastDialog.showLoader('Please wait'.tr);
          await controller.deleteUserFromServer();
          await FireStoreUtils().deleteUser();
          ShowToastDialog.closeLoader();
        },
        negativeClick: () => Get.back(),
        img: Image.asset(
          'assets/icons/delete_dialog.gif',
          height: 50,
          width: 50,
        ),
      ),
    );
  }
}