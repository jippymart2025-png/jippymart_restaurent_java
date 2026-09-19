import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';

import '../../../themes/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Text(
      title.tr,
      style: TextStyle(
        color: themeChange.getThem()
            ? AppThemeData.grey400
            : AppThemeData.grey500,
        fontFamily: AppThemeData.semiBold,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
