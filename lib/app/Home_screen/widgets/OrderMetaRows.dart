import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../constant/constant.dart';
import '../../../controller/home_controller.dart';
import '../../../models/order_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/round_button_fill.dart';
import '../../../utils/dark_theme_provider.dart';

class OrderMetaRows extends StatelessWidget {
  final OrderModel orderModel;
  final DarkThemeProvider themeChange;
  final double adminCommission;
  final HomeController controller;
  final BuildContext parentContext;

  const OrderMetaRows({
    required this.orderModel,
    required this.themeChange,
    required this.adminCommission,
    required this.controller,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _LabelValue(
          label: 'Order Date'.tr,
          value: Constant.timestampToDateTime(orderModel.createdAt ?? ''),
          themeChange: themeChange,
        ),
        if (Constant.adminCommission?.isEnabled == true) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Admin Commissions'.tr,
                  style: TextStyle(
                    color:
                    isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                    fontSize: 16,
                    fontFamily: AppThemeData.regular,
                  ),
                ),
              ),
              Text(
                '-${Constant.amountShow(amount: adminCommission.toString())}',
                style: const TextStyle(
                  color: AppThemeData.danger300,
                  fontSize: 16,
                  fontFamily: AppThemeData.semiBold,
                ),
              ),
            ],
          ),
        ],
        if (orderModel.notes?.isNotEmpty == true)
          GestureDetector(
            onTap: () => showDialog(
              context: parentContext,
              builder: (_) => _RemarkDialog(
                controller: controller,
                themeChange: themeChange,
                orderModel: orderModel,
              ),
            ),
            child: Text(
              'View Remarks'.tr,
              style: TextStyle(
                fontFamily: AppThemeData.regular,
                decoration: TextDecoration.underline,
                color: isDark
                    ? AppThemeData.secondary300
                    : AppThemeData.secondary300,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }
}


class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final DarkThemeProvider themeChange;

  const _LabelValue(
      {required this.label,
        required this.value,
        required this.themeChange});

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
              fontSize: 16,
              fontFamily: AppThemeData.regular,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
            fontSize: 14,
            fontFamily: AppThemeData.semiBold,
          ),
        ),
      ],
    );
  }
}

class _RemarkDialog extends StatelessWidget {
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final OrderModel orderModel;

  const _RemarkDialog({
    required this.controller,
    required this.themeChange,
    required this.orderModel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor:
      isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Text(
                  orderModel.notes ?? '',
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    color: isDark
                        ? AppThemeData.grey100
                        : AppThemeData.grey800,
                    fontSize: 18,
                  ),
                ),
              ),
              RoundedButtonFill(
                title: 'Cancel'.tr,
                color: isDark
                    ? AppThemeData.grey700
                    : AppThemeData.grey200,
                textColor: isDark
                    ? AppThemeData.grey100
                    : AppThemeData.grey800,
                onPress: Get.back,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
