import 'package:flutter/material.dart';

import '../../../themes/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';

class OrderCardShell extends StatelessWidget {
  final DarkThemeProvider themeChange;
  final List<Widget> children;

  const OrderCardShell({
    required this.themeChange,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: ShapeDecoration(
          color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
