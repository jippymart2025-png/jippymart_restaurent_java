import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';

import '../../../themes/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';
import '../controller/profile_controller.dart';

class ProfileRow extends StatelessWidget {
  const ProfileRow({
    required this.controller,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.danger = false,
  });

  final ProfileController controller;
  final Widget icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap == null
            ? null
            : () async {
          FocusManager.instance.primaryFocus?.unfocus();
          onTap!.call();
        },
        child: Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title.tr,
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 16,
                  color: danger
                      ? AppThemeData.danger300
                      : themeChange.getThem()
                      ? AppThemeData.grey100
                      : AppThemeData.grey800,
                ),
              ),
            ),
            trailing ?? const Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }
}
