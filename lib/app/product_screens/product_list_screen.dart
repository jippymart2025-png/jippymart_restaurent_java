import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/app/add_restaurant_screen/add_restaurant_screen.dart';
import 'package:jippymart_restaurant/app/product_screens/add_from_catalog_screen.dart';
import 'package:jippymart_restaurant/app/product_screens/add_product_screen.dart';
import 'package:jippymart_restaurant/app/verification_screen/verification_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/product_list_controller.dart';
import 'package:jippymart_restaurant/controller/merchant_outlet_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/responsive.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';
import 'package:jippymart_restaurant/config/app_config.dart';


import '../../models/product_model.dart';
import '../../utils/fire_store_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProductToggles — identical look, removed redundant IgnorePointer wrapper
// ─────────────────────────────────────────────────────────────────────────────
class ProductToggles extends StatelessWidget {
  const ProductToggles({
    required this.isAvailable,
    required this.onAvailableChanged,
    this.showPublish = true,
    this.isPublished = false,
    this.onPublishChanged,
    super.key,
  });

  final bool showPublish;
  final bool isPublished;
  final bool isAvailable;
  final ValueChanged<bool>? onPublishChanged;
  final ValueChanged<bool> onAvailableChanged;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 350;
    final available = _toggleRow('Available', isAvailable, onAvailableChanged);

    if (!showPublish) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [available],
      );
    }

    final publish = _toggleRow(
      'Publish',
      isPublished,
      onPublishChanged ?? (_) {},
    );

    return isSmall
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [publish, available],
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [publish, const SizedBox(width: 12), available],
    );
  }

  Widget _toggleRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Transform.scale(
          scale: 0.7,
          child: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF229954),
          ),
        ),
      ],
    );
  }

  /// Compact vertical toggle for product card trailing column.
  static Widget compactToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        Transform.scale(
          scale: 0.62,
          child: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF229954),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProductListScreen
// ─────────────────────────────────────────────────────────────────────────────
class ProductListScreen extends GetView<ProductListController> {
  const ProductListScreen({super.key});

  // ── Price helpers ──────────────────────────────────────────────────────────

  /// Safely parses a string to double; returns 0.0 on any failure.
  static double _safeParseDouble(String? value) =>
      double.tryParse(value?.trim() ?? '') ?? 0.0;

  /// Resolves the display price pair (price, disPrice) for a product.
  static (String, String) _resolvePrices(ProductModel product) {
    final variants = product.itemAttribute?.variants;
    final hasVariants = variants?.isNotEmpty == true;

    if (hasVariants) {
      final keys = (product.itemAttribute!.attributes ?? [])
          .map((a) => a.attributeOptions?.isNotEmpty == true
          ? a.attributeOptions![0]
          : null)
          .whereType<String>()
          .toList();

      if (keys.isNotEmpty) {
        final sku = keys.join('-');
        final match = variants!.firstWhere(
              (v) => v.variantSku == sku,
          orElse: Variants.new,
        );
        if (match.variantPrice?.isNotEmpty == true) {
          return (match.variantPrice!, '0');
        }
      }
    }

    // Direct price fallback
    final p = product.merchant_price?.toString() ?? '0.0';
    return (p, p);
  }

  Widget _buildPriceDisplay(
      String price, String disPrice, DarkThemeProvider themeChange) {
    if (AppConfig.enablePerfLogs) {
      // ignore: avoid_print
      print("🔍 Price: '$price'  DisPrice: '$disPrice'");
    }

    final parsedPrice = _safeParseDouble(price);
    final parsedDisPrice = _safeParseDouble(disPrice);
    final isDark = themeChange.getThem();
    final shouldShowDiscounted =
        parsedDisPrice > 0 && parsedDisPrice < parsedPrice;

    if (!shouldShowDiscounted) {
      return Text(
        Constant.amountShow(amount: parsedPrice.toString()),
        style: TextStyle(
          fontSize: 16,
          color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
          fontFamily: AppThemeData.semiBold,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Row(
      children: [
        Text(
          Constant.amountShow(amount: parsedDisPrice.toString()),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
            fontFamily: AppThemeData.semiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          Constant.amountShow(amount: parsedPrice.toString()),
          style: TextStyle(
            fontSize: 14,
            decoration: TextDecoration.lineThrough,
            decorationColor:
            isDark ? AppThemeData.grey500 : AppThemeData.grey400,
            color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
            fontFamily: AppThemeData.semiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── AppBar action visibility ───────────────────────────────────────────────
  static bool _hasActiveOutlet() =>
      FireStoreUtils.resolveActiveOutletId() > 0;

  static bool _canShowActions(ProductListController c) {
    final pendingVerify = !MerchantOutletController.isCurrentSessionApproved ||
        (Constant.isRestaurantVerification == true &&
            c.userModel.value.isDocumentVerify == false);

    // Merchant/outlet session with a resolved outlet id
    if (_hasActiveOutlet()) {
      return !pendingVerify;
    }

    final noVendor = c.userModel.value.vendorID?.isEmpty != false;
    return !pendingVerify && !noVendor;
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    if (!Get.isRegistered<ProductListController>()) {
      Get.put(ProductListController(), permanent: true);
    }

    return Obx(() => Scaffold(
        appBar: AppBar(
          backgroundColor: ColorConst.orange,
          centerTitle: false,
          title: Text(
            'Restaurant Inventory'.tr,
            style: const TextStyle(
              color: AppThemeData.grey50,
              fontSize: 18,
              fontFamily: AppThemeData.medium,
            ),
          ),
          actions: [
            if (_canShowActions(controller))
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // From catalog (tap target preserved, content commented out as original)
                  InkWell(
                    onTap: () => Get.to(const AddFromCatalogScreen())
                        ?.then((v) {
                      if (v == true) controller.getProduct();
                    }),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      // Intentionally empty — matches original commented-out UI
                    ),
                  ),
                  // Add product
                  InkWell(
                    onTap: () => Get.to(const AddFromCatalogScreen())
                        ?.then((v) {
                      if (v == true) controller.refreshInventory(forceRefresh: true);
                    }),
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.add,
                              color: AppThemeData.grey50),
                          const SizedBox(width: 5),
                          Text(
                            'Add'.tr,
                            style: const TextStyle(
                              color: AppThemeData.grey50,
                              fontSize: 18,
                              fontFamily: AppThemeData.medium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: controller.isLoading.value
            ? Constant.loader()
            : _buildBody(context, themeChange, controller),
      ));
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(
      BuildContext context,
      DarkThemeProvider themeChange,
      ProductListController controller,
      ) {
    // Document verification pending
    if (!MerchantOutletController.isCurrentSessionApproved ||
        (Constant.isRestaurantVerification == true &&
            controller.userModel.value.isDocumentVerify == false)) {
      return _EmptyState(
        svgAsset: 'assets/icons/ic_document.svg',
        title: 'Document Verification in Pending'.tr,
        subtitle:
        'Your documents are being reviewed. We will notify you once the verification is complete.'
            .tr,
        buttonLabel: 'View Status'.tr,
        onTap: () => Get.to(const VerificationScreen()),
        themeChange: themeChange,
      );
    }

    // API failed to load outlet menu
    if (controller.loadError.value.isNotEmpty) {
      return _EmptyState(
        svgAsset: 'assets/icons/ic_knife_fork.svg',
        title: 'Unable to Load Menu'.tr,
        subtitle: controller.loadError.value,
        buttonLabel: 'Retry'.tr,
        onTap: () => controller.refreshInventory(forceRefresh: true),
        themeChange: themeChange,
      );
    }

    // No outlet / restaurant linked
    if (!_hasActiveOutlet() &&
        controller.userModel.value.vendorID?.isEmpty != false) {
      return _EmptyState(
        svgAsset: 'assets/icons/ic_building_two.svg',
        title: 'Add Your First Restaurant'.tr,
        subtitle:
        'Get started by adding your restaurant details to manage your menu, orders, and reservations.'
            .tr,
        buttonLabel: 'Add Restaurant'.tr,
        onTap: () async {
          final result = await Get.to(const AddRestaurantScreen());
          if (result == true) await controller.getUserProfile();
        },
        themeChange: themeChange,
      );
    }

    // No products — outlet catalog flow (Add from Catalog)
    if (controller.productList.isEmpty) {
      return _EmptyState(
        svgAsset: 'assets/icons/ic_knife_fork.svg',
        svgColorFilter: ColorFilter.mode(
          themeChange.getThem()
              ? AppThemeData.grey400
              : AppThemeData.grey500,
          BlendMode.srcIn,
        ),
        title: 'No Products Available'.tr,
        subtitle:
        'Your menu is currently empty. Pick a category from the catalog to add your first product.'
            .tr,
        buttonLabel: 'Add from Catalog'.tr,
        onTap: () => Get.to(const AddFromCatalogScreen())
            ?.then((v) {
          if (v == true) controller.refreshInventory(forceRefresh: true);
        }),
        themeChange: themeChange,
      );
    }

    // Product list
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Category filter row ─────────────────────────────────────────
        SizedBox(
          height: 56,
          child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: controller.categoryList.length + 1,
            itemBuilder: (_, index) {
              if (index == 0) {
                final isSelected =
                    controller.selectedCategory.value == null;
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('All'.tr),
                    selected: isSelected,
                    onSelected: (_) =>
                    controller.selectedCategory.value = null,
                    selectedColor: AppThemeData.secondary300,
                    backgroundColor: AppThemeData.grey200,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppThemeData.grey900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              final category =
              controller.categoryList[index - 1];
              final isSelected =
                  controller.selectedCategory.value?.id ==
                      category.id;
              final isActive = category.isActive ?? true;

              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 4),
                child: Opacity(
                  opacity: isActive ? 1.0 : 0.4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChoiceChip(
                        label: Text(
                          (category.title ?? '').trim().isEmpty
                              ? 'Category'
                              : category.title!.trim(),
                        ),
                        selected: isSelected,
                        onSelected: isActive
                            ? (_) => controller
                            .selectedCategory.value = category
                            : null,
                        selectedColor: AppThemeData.secondary300,
                        backgroundColor: AppThemeData.grey200,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppThemeData.grey900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: isActive,
                        onChanged: (_) =>
                            controller.handleCategoryActiveToggle(
                              context,
                              index - 1,
                            ),
                        activeColor: AppThemeData.secondary300,
                        thumbColor:
                        const MaterialStatePropertyAll(
                            Colors.white),
                        trackColor: const MaterialStatePropertyAll(
                            Color(0xFFE74C3C)),
                        materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
        ),

        // ── Product list ────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            // Materialize the filtered list once per build instead of once per
            // item access (the getter re-runs the where/toList every call).
            final products = controller.filteredProductList;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, index) {
                final product = products[index];
                final (price, disPrice) = _resolvePrices(product);

                if (AppConfig.enablePerfLogs) {
                  // ignore: avoid_print
                  print(
                      '🛒 ${product.name} price=$price dis=$disPrice');
                }

                return _ProductCard(
                  product: product,
                  index: index,
                  controller: controller,
                  themeChange: themeChange,
                  priceWidget:
                  _buildPriceDisplay(price, disPrice, themeChange),
                  context: context,
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProductCard — extracted from itemBuilder; identical visual output
// ─────────────────────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.index,
    required this.controller,
    required this.themeChange,
    required this.priceWidget,
    required this.context,
  });

  final ProductModel product;
  final int index;
  final ProductListController controller;
  final DarkThemeProvider themeChange;
  final Widget priceWidget;
  final BuildContext context;

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text(
            'Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteProduct(index);
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFC0392B))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext _) {
    final isDark = themeChange.getThem();
    final isAvailable = product.isAvailable != false;

    return InkWell(
      onTap: !isAvailable
          ? null
          : () => Get.to(() => AddProductScreen(product: product))
                  ?.then((v) {
                if (v == true) controller.getProduct();
              }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
          child: Container(
            decoration: ShapeDecoration(
              color: !isAvailable
                  ? Colors.grey[300]
                  : isDark
                  ? AppThemeData.grey900
                  : AppThemeData.grey50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ProductImage(
                    imageUrl: product.photo,
                    height: Responsive.height(10, context),
                    width: Responsive.width(20, context),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                            fontFamily: AppThemeData.semiBold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        priceWidget,
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/ic_star.svg',
                              height: 14,
                              width: 14,
                              colorFilter: const ColorFilter.mode(
                                  AppThemeData.warning300,
                                  BlendMode.srcIn),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${Constant.calculateReview(reviewCount: (product.reviewsCount ?? 0).toStringAsFixed(0), reviewSum: (product.reviewsSum ?? 0).toString())} (${(product.reviewsCount ?? 0).toStringAsFixed(0)})',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey900,
                                fontFamily: AppThemeData.regular,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if ((product.description ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            product.description.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppThemeData.grey400
                                  : AppThemeData.grey600,
                              fontFamily: AppThemeData.regular,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!controller.isOutletInventoryMode)
                        ProductToggles.compactToggle(
                          label: 'Publish',
                          value: product.publish ?? false,
                          onChanged: (_) => controller.updateList(
                            product.id!,
                            product.publish ?? false,
                          ),
                        ),
                      ProductToggles.compactToggle(
                        label: 'Available',
                        value: product.isAvailable ?? true,
                        onChanged: (_) =>
                            controller.handleProductAvailabilityToggle(
                          context,
                          product.id!,
                          product.isAvailable ?? true,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: const Icon(
                          Icons.delete,
                          color: Color(0xFFC0392B),
                          size: 20,
                        ),
                        onPressed: _confirmDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProductImage — network image with gradient overlay + placeholder fallback
// ─────────────────────────────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.height,
    required this.width,
    required this.isDark,
  });

  final String? imageUrl;
  final double height;
  final double width;
  final bool isDark;

  bool get _hasImage {
    final url = imageUrl?.trim() ?? '';
    return url.isNotEmpty && url != 'null';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: SizedBox(
        height: height,
        width: width,
        child: _hasImage
            ? Stack(
          fit: StackFit.expand,
          children: [
            NetworkImageWidget(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              height: height,
              width: width,
            ),
            // Gradient overlay (same as original)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(0, -1),
                  end: const Alignment(0, 1),
                  colors: [
                    Colors.black.withOpacity(0),
                    const Color(0xFF111827),
                  ],
                ),
              ),
            ),
          ],
        )
            : _Placeholder(isDark: isDark),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fastfood_rounded,
            size: 32,
            color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
          ),
          const SizedBox(height: 4),
          // Text(
          //   'No Image',
          //   style: TextStyle(
          //     fontSize: 10,
          //     fontFamily: AppThemeData.regular,
          //     color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
          //   ),
          // ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyState — deduplicates the 3 identical empty-state blocks
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
    required this.themeChange,
    this.svgColorFilter,
  });

  final String svgAsset;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;
  final DarkThemeProvider themeChange;
  final ColorFilter? svgColorFilter;

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: ShapeDecoration(
              color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(120)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SvgPicture.asset(svgAsset,
                  colorFilter: svgColorFilter),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
              fontSize: 22,
              fontFamily: AppThemeData.semiBold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppThemeData.grey50 : AppThemeData.grey500,
              fontSize: 16,
              fontFamily: AppThemeData.bold,
            ),
          ),
          const SizedBox(height: 20),
          RoundedButtonFill(
            title: buttonLabel,
            width: 55,
            height: 5.5,
            color: AppThemeData.secondary300,
            textColor: AppThemeData.grey50,
            onPress: onTap,
          ),
        ],
      ),
    );
  }
}