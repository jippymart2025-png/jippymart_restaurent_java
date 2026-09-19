import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../models/order_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/network_image_widget.dart';

class CustomerRow extends StatelessWidget {
  final OrderModel orderModel;
  final DarkThemeProvider themeChange;

  const CustomerRow({required this.orderModel, required this.themeChange});

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Row(
      children: [
        ClipOval(
          child: NetworkImageWidget(
            imageUrl: orderModel.author?.profilePictureURL ?? '',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderModel.author?.fullName() ?? '',
                style: TextStyle(
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                  fontSize: 14,
                  fontFamily: AppThemeData.semiBold,
                ),
              ),
              Text(
                orderModel.takeAway == true
                    ? 'Take Away'.tr
                    : orderModel.id ?? '',
                style: TextStyle(
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                  fontSize: 14,
                  fontFamily: AppThemeData.medium,
                ),
              ),
            ],
          ),
        ),
        // const Icon(Icons.chevron_right),
      ],
    );
  }
}
