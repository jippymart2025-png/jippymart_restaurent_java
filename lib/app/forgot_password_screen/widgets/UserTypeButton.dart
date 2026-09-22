import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart' show DarkThemeProvider;
import 'package:provider/provider.dart';

import '../../../themes/app_them_data.dart';

class UserTypeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const UserTypeButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final fillColor = isSelected
        ? AppThemeData.primary300
        : (themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100);
    final textColor = isSelected
        ? AppThemeData.grey50
        : (themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontFamily: AppThemeData.medium,
          ),
        ),
      ),
    );
  }
}
