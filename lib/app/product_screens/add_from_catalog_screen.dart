import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/app/product_screens/widgets/AddFromCatalogProductScreen.dart';
import 'package:jippymart_restaurant/app/product_screens/widgets/ProductCard.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:provider/provider.dart';

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/add_from_catalog_controller.dart';
import 'package:jippymart_restaurant/models/master_product_model.dart';
import 'package:jippymart_restaurant/models/selected_product_model.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';
import '../../models/variant_group_model.dart';
import 'add_masterproduct_screen.dart';

class AddFromCatalogScreen extends StatelessWidget {
  const AddFromCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey900 : const Color(0xFFF5F6FA),
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: ColorConst.orange,
        elevation: 0,
        title: Text(
          'Add from Catalog'.tr,
          style: const TextStyle(
            color: AppThemeData.grey50,
            fontSize: 15,
            fontFamily: AppThemeData.semiBold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                _showCreateCategoryDialog(context);
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal:15,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Add Category'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: AppThemeData.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: AppThemeData.grey50),
      ),
      body: const _CategorySelectionStep(),

    );
  }
}
void _showCreateCategoryDialog(BuildContext context) {
  final TextEditingController categoryController =
  TextEditingController();
  final TextEditingController imageController =
  TextEditingController();

  final controller =
  Get.find<AddFromCatalogController>();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: ColorConst.orange.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child:  Icon(
                Icons.category_outlined,
                color: ColorConst.orange,
                size: 32,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Create Category",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Add a new category for your products",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                hintText: "e.g. Biryani Specials",
                prefixIcon:  Icon(
                  Icons.local_offer_outlined,
                  color: ColorConst.orange,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                  borderSide:  BorderSide(
                    color: ColorConst.orange,
                    width: 2,
                  ),
                ),
              ),
            ),
            TextField(
              controller: imageController,
              decoration: InputDecoration(
                hintText: "Category Image URL",
                prefixIcon: Icon(
                  Icons.image_outlined,
                  color: ColorConst.orange,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize:
                      const Size.fromHeight(48),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final categoryName = categoryController.text.trim();

                      final categoryImageUrl = imageController.text.trim();
                     final Outletid= Preferences.getInt("outletId");

                      if (categoryName.isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Please enter category name",
                        );
                        return;
                      }

                      final success = await FireStoreUtils.createCategory(
                        categoryName: categoryName,
                        categoryType: "ALL",
                        categoryImageUrl: categoryImageUrl,
                        createdBy:Outletid // Replace with the logged-in user's ID if available
                      );

                      if (success) {

                        FireStoreUtils
                            .clearVendorCategoriesCache();

                        await controller
                            .loadCategories();

                        Get.back();

                        Get.snackbar(
                          "Success",
                          "Category created successfully",
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      ColorConst.orange,
                      minimumSize:
                      const Size.fromHeight(48),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Create",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Step 1 – pick a category on a clean, simple screen.
class _CategorySelectionStep extends StatelessWidget {
  const _CategorySelectionStep();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DarkThemeProvider>(context);
    final isDark = theme.getThem();

    return GetX<AddFromCatalogController>(
      init: AddFromCatalogController(),
      builder: (c) {
        if (c.isLoading.value) return Constant.loader();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a category'.tr,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  fontSize: 16,
                  color:
                      isDark ? AppThemeData.grey100 : AppThemeData.grey900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'We’ll show products from the category you pick.'
                    .tr,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      isDark ? AppThemeData.grey400 : AppThemeData.grey600,
                ),
              ),
              const SizedBox(height: 16),
// CATEGORY SEARCH
              TextField(
                controller: c.categorySearchController,
                onChanged: c.setCategorySearch,
                decoration: InputDecoration(
                  hintText: 'Search categories...'.tr,

                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                  ),
                  suffixIcon: c.categorySearchText.value.isNotEmpty
                      ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      size: 20,
                    ),
                    onPressed: () {
                      c.categorySearchController.clear();
                      c.setCategorySearch('');
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppThemeData.grey800
                      : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: c.filteredCategories.isEmpty &&
                    c.categorySearchText.value.isNotEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: isDark
                            ? AppThemeData.grey400
                            : AppThemeData.grey500,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No categories found'.tr,
                        style: TextStyle(
                          fontFamily: AppThemeData.semiBold,
                          fontSize: 15,
                          color: isDark
                              ? AppThemeData.grey200
                              : AppThemeData.grey800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try searching with a different name.'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppThemeData.grey400
                              : AppThemeData.grey600,
                        ),
                      ),
                    ],
                  ),
                )
               : ListView.separated(
                 // itemCount: c.categoryList.length,
                  itemCount: c.filteredCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    //final cat = c.categoryList[i];
                    final cat = c.filteredCategories[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Remember the chosen category, then open the
                        // products screen. When products screen finishes
                        // with result == true, bubble that up so the
                        // product list screen can refresh.
                        c.selectCategory(cat);
                        Get.to(() => const AddFromCatalogProductScreen())
                            ?.then((v) {
                          if (v == true) {
                            Get.back(result: true);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppThemeData.grey800
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorConst.orange
                                    .withOpacity(0.12),
                              ),
                              child:  Icon(
                                Icons.category_rounded,
                                size: 18,
                                color: ColorConst.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.title ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily:
                                          AppThemeData.semiBold,
                                      fontSize: 14,
                                      color: isDark
                                          ? AppThemeData.grey100
                                          : AppThemeData.grey900,
                                    ),
                                  ),
                                  if ((cat.description ?? '')
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      cat.description!,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppThemeData.grey400,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class AddFromCatalogBody extends StatelessWidget {
  const AddFromCatalogBody({
    super.key,
    this.initialCategory,
    this.themeOverride,
  });

  /// If provided, products for this category are loaded directly (step 2).
  /// If null, controller will behave like the old flow and can be used
  /// from existing screens that just call `const AddFromCatalogBody()`.
  final VendorCategoryModel? initialCategory;

  /// Optional theme override for cases where a parent already has it.
  final DarkThemeProvider? themeOverride;

  @override
  Widget build(BuildContext context) {
    final theme =
        themeOverride ?? Provider.of<DarkThemeProvider>(context);

    final bool hasExistingController =
        Get.isRegistered<AddFromCatalogController>();

    return GetX<AddFromCatalogController>(
      // When we come from the category step we already have a controller,
      // so don't create a new one or we lose selectedProducts.
      init: initialCategory != null
          ? AddFromCatalogController(initialCategory: initialCategory)
          : (hasExistingController ? null : AddFromCatalogController()),
      builder: (c) {
        if ((c.isLoading.value || c.isLoadingProducts.value) &&
            c.masterProducts.isEmpty) {
          return Constant.loader();
        }

        return Column(
          children: [
            _FilterPanel(ctrl: c, theme: theme),
            Expanded(child: _ProductSection(ctrl: c, theme: theme)),
            if (!c.isLoadingProducts.value && c.lastPage.value > 1)
              _Pagination(ctrl: c, theme: theme),
            _BottomBar(ctrl: c, theme: theme),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter panel
// Selecting a category auto-loads products. "Load All" removed.
// Only a search field + icon button remains after category is chosen.
// ─────────────────────────────────────────────────────────────────────────────
class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.ctrl, required this.theme});
  final AddFromCatalogController ctrl;
  final DarkThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.getThem();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ctrl.selectedCategory.value?.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: 14,
                    color: isDark
                        ? AppThemeData.grey100
                        : AppThemeData.grey900,
                  ),
                ),
              ),
              Text(
                '${ctrl.totalProducts.value} items'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppThemeData.grey400
                      : AppThemeData.grey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(
                () => TextField(
              controller: ctrl.productSearchController,
              onChanged: ctrl.setSearch,

              decoration: InputDecoration(
                hintText: 'Search products...'.tr,

                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                ),

                suffixIcon: ctrl.searchQuery.value.isNotEmpty
                    ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 20,
                  ),
                  onPressed: () {
                    ctrl.productSearchController.clear();
                    ctrl.setSearch('');
                  },
                )
                    : null,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),

                filled: true,

                fillColor: isDark
                    ? AppThemeData.grey700
                    : const Color(0xFFF5F6FA),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product section
// ─────────────────────────────────────────────────────────────────────────────
class _ProductSection extends StatelessWidget {
  const _ProductSection({required this.ctrl, required this.theme});
  final AddFromCatalogController ctrl;
  final DarkThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    if (ctrl.selectedCategory.value == null) {
      return _EmptyHint(
        icon: Icons.category_outlined,
        message: 'Select a category to browse products'.tr,
        theme: theme,
      );
    }
    if (ctrl.isLoadingProducts.value) return Constant.loader();
    if (ctrl.masterProducts.isEmpty) {
      return _EmptyHint(
        icon: Icons.inventory_2_outlined,
        message: 'No products in this category'.tr,
        theme: theme,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      itemCount: ctrl.masterProducts.length,
      itemBuilder: (_, i) => ProductCard(
        product: ctrl.masterProducts[i],
        ctrl: ctrl,
        theme: theme,
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(
      {required this.icon, required this.message, required this.theme});
  final IconData icon;
  final String message;
  final DarkThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.getThem();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 48,
              color: isDark ? AppThemeData.grey500 : AppThemeData.grey400),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
              fontFamily: AppThemeData.regular,
            ),
          ),
        ],
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Pagination
// ─────────────────────────────────────────────────────────────────────────────
class _Pagination extends StatelessWidget {
  const _Pagination({required this.ctrl, required this.theme});
  final AddFromCatalogController ctrl;
  final DarkThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.getThem();
    final cur = ctrl.currentPage.value;
    final last = ctrl.lastPage.value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isDark ? AppThemeData.grey900 : const Color(0xFFF5F6FA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PageArrow(
            icon: Icons.chevron_left,
            enabled: cur > 1,
            isDark: isDark,
            onTap: () => ctrl.goToPage(cur - 1),
          ),
          const SizedBox(width: 12),
          Text(
            '$cur / $last',
            style: TextStyle(
              fontFamily: AppThemeData.semiBold,
              fontSize: 13,
              color: isDark ? AppThemeData.grey200 : AppThemeData.grey800,
            ),
          ),
          const SizedBox(width: 12),
          _PageArrow(
            icon: Icons.chevron_right,
            enabled: cur < last,
            isDark: isDark,
            onTap: () => ctrl.goToPage(cur + 1),
          ),
        ],
      ),
    );
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({
    required this.icon,
    required this.enabled,
    required this.isDark,
    required this.onTap,
  });
  final IconData icon;
  final bool enabled;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled
              ? ColorConst.orange.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled
              ? ColorConst.orange
              : (isDark ? AppThemeData.grey600 : AppThemeData.grey300),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom save bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.ctrl, required this.theme});
  final AddFromCatalogController ctrl;
  final DarkThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.getThem();

    return Obx(() {
      final count = ctrl.selectedProducts.length;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey900 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.07),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: SafeArea(
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: count > 0
                      ? ColorConst.orange.withOpacity(0.12)
                      : (isDark
                          ? AppThemeData.grey700
                          : AppThemeData.grey100),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count > 0 ? '$count selected'.tr : 'None selected'.tr,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: 13,
                    color: count > 0
                        ? ColorConst.orange
                        : (isDark
                            ? AppThemeData.grey400
                            : AppThemeData.grey500),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RoundedButtonFill(
                  title: 'Save'.tr,
                  color:
                      count > 0 ? ColorConst.orange : Colors.grey.shade400,
                  width: 60,
                  height: 5.5,
                  textColor: AppThemeData.grey50,
                  onPress: () async {
                    if (count == 0) return;
                    final err = ctrl.validateForSave();
                    if (err != null) {
                      ShowToastDialog.showToast(err);
                      return;
                    }
                    ShowToastDialog.showLoader('Saving...'.tr);
                    final ok = await ctrl.saveAndCaptureResponse();
                    ShowToastDialog.closeLoader();
                    if (ok) {
                      ShowToastDialog.showToast(
                          ctrl.lastStoreResponse?.message ??
                              'Successfully imported.'.tr);
                      Get.back(result: true);
                    } else {
                      final msg = ctrl.lastStoreResponse?.message ??
                          'Save failed.'.tr;
                      final response = ctrl.lastStoreResponse;

                      String display;

                      if (response == null) {
                        display = 'Save failed.'.tr;
                      } else if (response.savedCount > 0 && response.skippedCount == 0) {
                        display = 'Saved ${response.savedCount} product(s) successfully.';
                      } else if (response.savedCount > 0 && response.skippedCount > 0) {
                        display =
                        'Saved ${response.savedCount} product(s), '
                            'skipped ${response.skippedCount} product(s).';

                        if (response.skippedNames.isNotEmpty) {
                          display += '\nSkipped: ${response.skippedNames.join(', ')}';
                        }
                      } else {
                        display = 'No products were saved.';

                        if (response.skippedNames.isNotEmpty) {
                          display += '\nSkipped: ${response.skippedNames.join(', ')}';
                        }
                      }

                      ShowToastDialog.showToast(display);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
