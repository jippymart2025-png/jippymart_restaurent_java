import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../constant/constant.dart';
import '../../../models/cart_product_model.dart';
import '../../../models/order_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../widget/my_separator.dart';
import '../../product_rating_view_screen/product_rating_view_screen.dart';

class ProductList extends StatelessWidget {
  final OrderModel orderModel;
  final DarkThemeProvider themeChange;
  final bool showViewRatings;

  const ProductList({
    required this.orderModel,
    required this.themeChange,
    this.showViewRatings = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    final products = orderModel.products ?? const <CartProductModel>[];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: MySeparator(
          color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
        ),
      ),
      itemBuilder: (_, i) =>
          _ProductItem(
            product: products[i],
            orderModel: orderModel,
            themeChange: themeChange,
            showViewRatings: showViewRatings,
          ),
    );
  }
}


class _ProductItem extends StatelessWidget {
  final CartProductModel product;
  final OrderModel orderModel;
  final DarkThemeProvider themeChange;
  final bool showViewRatings;

  const _ProductItem({
    required this.product,
    required this.orderModel,
    required this.themeChange,
    this.showViewRatings = false,
  });

  String get _priceText {
    final price = double.tryParse(product.merchant_price ?? '0') ?? 0;
    final qty = double.tryParse(product.quantity?.toString() ?? '1') ?? 1;
    return Constant.amountShow(amount: (price * qty).toString());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${product.quantity}x ${product.name}'.tr,
                style: TextStyle(
                  color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppThemeData.semiBold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _priceText,
                  style: TextStyle(
                    color:
                    isDark ? AppThemeData.grey100 : AppThemeData.grey800,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppThemeData.semiBold,
                  ),
                ),
                if (showViewRatings)
                  GestureDetector(
                    onTap: () => Get.to(
                      const ProductRatingViewScreen(),
                      arguments: {
                        'orderModel': orderModel,
                        'productId': product.id,
                      },
                    ),
                    child: Text(
                      'View Ratings'.tr,
                      style:  TextStyle(
                        color: AppThemeData.secondary300,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        fontFamily: AppThemeData.semiBold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (product.variantInfo?.variantOptions?.isNotEmpty == true)
          _VariantChips(product: product, themeChange: themeChange),
        if (product.extras?.isNotEmpty == true)
          _AddonChips(product: product, themeChange: themeChange),
      ],
    );
  }
}

class _VariantChips extends StatelessWidget {
  final CartProductModel product;
  final DarkThemeProvider themeChange;

  const _VariantChips(
      {required this.product, required this.themeChange});

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    final options = product.variantInfo!.variantOptions!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variants'.tr,
            style: TextStyle(
              fontFamily: AppThemeData.semiBold,
              color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: options.keys
                .where((key) => key != 'merchant_price')
                .map((key) {
              return _Chip(
                label: '$key : ${options[key]}',
                themeChange: themeChange,
              );
            }).toList(),
          ),        ],
      ),
    );
  }
}

class _AddonChips extends StatelessWidget {
  final CartProductModel product;
  final DarkThemeProvider themeChange;

  const _AddonChips(
      {required this.product, required this.themeChange});

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    final qty = double.tryParse(product.quantity?.toString() ?? '1') ?? 1;
    final extrasTotal =
        double.tryParse(product.extrasPrice?.toString() ?? '0') ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Addons'.tr,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              Constant.amountShow(amount: (extrasTotal * qty).toString()),
              style:  TextStyle(
                fontFamily: AppThemeData.semiBold,
                color: AppThemeData.secondary300,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: product.extras!
              .map((e) =>
              _Chip(label: e.toString(), themeChange: themeChange))
              .toList(),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final DarkThemeProvider themeChange;

  const _Chip({required this.label, required this.themeChange});

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Container(
      decoration: ShapeDecoration(
        color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppThemeData.medium,
          color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
        ),
      ),
    );
  }
}
