import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../constant/constant.dart';
import '../../../models/order_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/network_image_widget.dart';

class CustomerRow extends StatelessWidget {
  final OrderModel orderModel;
  final DarkThemeProvider themeChange;

  const CustomerRow({required this.orderModel, required this.themeChange});

  /// The outlet summary API does not always include the customer, so fall back
  /// to the order number instead of rendering an empty title.
  String get _customerName =>
      orderModel.author?.fullName().toString().trim() ?? '';

  String get _orderNumber {
    final id = orderModel.id?.trim() ?? '';
    return id.isEmpty ? '' : '#$id';
  }

  String get _statusText {
    final status = orderModel.status?.trim() ?? '';
    if (status.isEmpty) return '';
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  String get _title {
    if (_customerName.isNotEmpty) return _customerName;
    return _orderNumber.isNotEmpty ? _orderNumber : 'Order'.tr;
  }

  String get _subtitle {
    if (orderModel.takeAway == true) return 'Take Away'.tr;
    if (_customerName.isNotEmpty) return _orderNumber;
    return _statusText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    final profilePicture = orderModel.author?.profilePictureURL?.trim() ?? '';

    return Row(
      children: [
        ClipOval(
          child: profilePicture.isNotEmpty
              ? NetworkImageWidget(
                  imageUrl: profilePicture,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  Constant.userPlaceHolder,
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
                _title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                  fontSize: 14,
                  fontFamily: AppThemeData.semiBold,
                ),
              ),
              if (_subtitle.isNotEmpty)
                Text(
                  _subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
