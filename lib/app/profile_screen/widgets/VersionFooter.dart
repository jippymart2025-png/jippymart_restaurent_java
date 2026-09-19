import 'package:flutter/cupertino.dart';

import '../../../constant/constant.dart' show Constant;
import '../../../themes/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';

class VersionFooter extends StatelessWidget {
  const VersionFooter({required this.themeChange});
  final DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'V : ${Constant.appVersion}',
            style: TextStyle(
              fontFamily: AppThemeData.medium,
              fontSize: 14,
              color: themeChange.getThem()
                  ? AppThemeData.grey50
                  : AppThemeData.grey900,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}