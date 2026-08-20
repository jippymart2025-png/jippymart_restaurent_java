// import 'package:get/get.dart';
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/models/product_model.dart';
// import 'package:jippymart_restaurant/models/user_model.dart';
// import 'package:jippymart_restaurant/models/vendor_category_model.dart';
// import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
// import 'package:jippymart_restaurant/config/app_config.dart';
//
// class ProductListController extends GetxController {
//   @override
//   void onInit() {
//     super.onInit();
//     // Load profile then products; categories are refreshed after productList is set (inside getProduct).
//     getUserProfile();
//   }
//
//   Rx<UserModel> userModel = UserModel().obs;
//   RxBool isLoading = true.obs;
//
//   getUserProfile() async {
//     String userId = await FireStoreUtils.getCurrentUid();
//     await FireStoreUtils.getUserProfile(userId).then(
//       (value) {
//         if (value != null) {
//           Constant.userModel = value;
//           userModel.value = value;
//         }
//       },
//     );
//     await getProduct();
//     isLoading.value = false;
//   }
//
//   RxList<ProductModel> productList = <ProductModel>[].obs;
//   RxList<VendorCategoryModel> categoryList = <VendorCategoryModel>[].obs;
//   Rx<VendorCategoryModel?> selectedCategory = Rx<VendorCategoryModel?>(null);
//   Future<void> getProduct() async {
//     await FireStoreUtils.getProduct().then(
//       (value) {
//         if (value != null) {
//           productList.value = value;
//         }
//       },
//     );
//     await refreshCategoriesWithProducts();
//   }
//   Future<void> refreshCategoriesWithProducts() async {
//     if (productList.isEmpty) return;
//
//     final allProductCategoryIds = productList
//         .map((p) => p.categoryID?.toString())
//         .whereType<String>()
//         .where((s) => s.isNotEmpty)
//         .toSet();
//     final categories = await FireStoreUtils.getVendorCategoryById();
//     if (categories != null && categories.isNotEmpty) {
//       if (allProductCategoryIds.isEmpty) {
//         categoryList.value = List.from(categories)
//           ..sort((a, b) => (a.title ?? '').toLowerCase().compareTo((b.title ?? '').toLowerCase()));
//       } else {
//         final matched = categories
//             .where((cat) {
//               final catId = cat.id?.toString() ?? '';
//               return catId.isNotEmpty && allProductCategoryIds.contains(catId);
//             })
//             .toList();
//         matched.sort((a, b) => (a.title ?? '').toLowerCase().compareTo((b.title ?? '').toLowerCase()));
//         categoryList.value = matched;
//       }
//       return;
//     }
//
//     if (allProductCategoryIds.isNotEmpty) {
//       categoryList.value = allProductCategoryIds.map((id) => VendorCategoryModel(
//         id: id,
//         title: 'Category',
//         isActive: true,
//       )).toList()..sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
//     }
//   }
//
//   Future<void> getCategories() async {
//     await refreshCategoriesWithProducts();
//   }
//
//   updateList(String productId, bool isPublish) async {
//     int mainIndex = productList.indexWhere((p) => p.id == productId);
//     if (mainIndex != -1) {
//       ProductModel productModel = productList[mainIndex];
//       productModel.publish = !isPublish;
//       productList[mainIndex] = productModel;
//       update();
//       await FireStoreUtils.setProduct(productModel);
//     }
//   }
//
//   updateAvailableStatus(String productId, bool isAvailable) async {
//     int mainIndex = productList.indexWhere((p) => p.id == productId);
//     if (mainIndex != -1) {
//       ProductModel productModel = productList[mainIndex];
//       productModel.isAvailable = !isAvailable;
//       productList[mainIndex] = productModel;
//       update();
//       await FireStoreUtils.updateProductIsAvailable(productModel.id!, productModel.isAvailable!);
//     }
//   }
//
//   Future<void> deleteProduct(int index) async {
//     final product = productList[index];
//     await FireStoreUtils.deleteProduct(product);
//     productList.removeAt(index);
//     update();
//   }
//   List<ProductModel> get filteredProductList {
//     if (selectedCategory.value == null) {
//       return productList;
//     }
//     final selectedId = selectedCategory.value!.id?.toString() ?? '';
//     if (selectedId.isEmpty) return productList;
//     return productList
//         .where((product) => (product.categoryID?.toString() ?? '') == selectedId)
//         .toList();
//   }
//
//
//   Future<void> toggleCategoryActive(int index) async {
//     final category = categoryList[index];
//     final newStatus = !(category.isActive ?? true);
//     final categoryId = category.id;
//     if (AppConfig.enableDebugLogs) {
//       // ignore: avoid_print
//       print("toggleCategoryActive $index");
//     }
//     categoryList[index] = VendorCategoryModel(
//       reviewAttributes: category.reviewAttributes,
//       photo: category.photo,
//       description: category.description,
//       id: category.id,
//       title: category.title,
//       isActive: newStatus,
//     );
//     for (int i = 0; i < productList.length; i++) {
//       if ((productList[i].categoryID?.toString() ?? '') == (categoryId?.toString() ?? '')) {
//         productList[i].isAvailable = newStatus;
//       }
//     }
//     productList.value = List.from(productList);
//     update();
//     await FireStoreUtils.updateCategoryIsActive(category.id!, newStatus);
//     await FireStoreUtils.setAllProductsAvailabilityForCategory(
//       category.id!,
//       newStatus,
//     );
//     FireStoreUtils.invalidateProductCache(Constant.userModel?.vendorID);
//   }
//   // Future<void> toggleCategoryActive(int index) async {
//   //   final category = categoryList[index];
//   //   final newStatus = !(category.isActive ?? true);
//   //   print("toggleCategoryActive ${newStatus} ");
//   //   // Update category in local list immediately
//   //   categoryList[index] = VendorCategoryModel(
//   //     reviewAttributes: category.reviewAttributes,
//   //     photo: category.photo,
//   //     description: category.description,
//   //     id: category.id,
//   //     title: category.title,
//   //     isActive: newStatus,
//   //   );
//   //   // for (var product in productList) {
//   //   //   if (product.categoryID == category.id) {
//   //   //     product.isAvailable = newStatus;
//   //   //   }
//   //   // }
//   //   productList.value = List.from(productList);
//   //   update();
//   //   try {
//   //     // Sync with server
//   //     await FireStoreUtils.updateCategoryIsActive(category.id!, newStatus);
//   //     await FireStoreUtils.setAllProductsAvailabilityForCategory(category.id!, newStatus);
//   //     await Future.delayed(Duration(milliseconds: 500));
//   //     await getProduct();
//   //     getCategories();
//   //   } catch (e) {
//   //     print('Error toggling category active: $e');
//   //     // Revert local changes on error
//   //     categoryList[index] = category;
//   //     await getProduct(); // Refresh to get correct state from server
//   //     getCategories();
//   //     rethrow;
//   //   }
//   // }
// }



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/config/app_config.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/product_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/inventory_unavailability_flow.dart';
import '../utils/preferences.dart';

class ProductListController extends GetxController {
  // ── Observables ────────────────────────────────────────────────────────────
  final Rx<UserModel> userModel = UserModel().obs;
  final RxBool isLoading = true.obs;
  final RxString loadError = ''.obs;
  final RxList<ProductModel> productList = <ProductModel>[].obs;
  final RxList<VendorCategoryModel> categoryList = <VendorCategoryModel>[].obs;
  final Rx<VendorCategoryModel?> selectedCategory =
  Rx<VendorCategoryModel?>(null);

  final List<_PendingCatalogEntry> _pendingCatalogEntries = [];
  int _loadedOutletId = 0;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    refreshInventory();
  }

  // ── Computed (no extra storage) ────────────────────────────────────────────
  bool get isOutletInventoryMode =>
      FireStoreUtils.resolveActiveOutletId() > 0;

  List<ProductModel> get filteredProductList {
    final catId = selectedCategory.value?.id?.toString() ?? '';
    if (catId.isEmpty) return productList.toList();
    return productList
        .where((p) => (p.categoryID?.toString() ?? '') == catId)
        .toList();
  }

  /// Clears inventory scoped to a previous outlet before switching dashboards.
  void prepareForOutletSwitch(int outletId) {
    _loadedOutletId = outletId;
    _purgePendingForOtherOutlets(outletId);
    productList.clear();
    categoryList.clear();
    selectedCategory.value = null;
  }

  void clearOutletInventoryState() {
    _loadedOutletId = 0;
    _pendingCatalogEntries.clear();
    productList.clear();
    categoryList.clear();
    selectedCategory.value = null;
  }

  void _purgePendingForOtherOutlets(int outletId) {
    _pendingCatalogEntries.removeWhere((entry) => entry.outletId != outletId);
  }

  /// Keeps freshly saved catalog products visible until outlet menu API returns them.
  void stageCatalogProducts(
    List<ProductModel> products, {
    VendorCategoryModel? category,
    int? outletId,
  }) {
    final scopedOutletId = outletId ?? FireStoreUtils.resolveActiveOutletId();
    if (scopedOutletId <= 0) return;

    for (final product in products) {
      final duplicate = _pendingCatalogEntries.any(
        (entry) =>
            entry.outletId == scopedOutletId &&
            _isSameProduct(entry.product, product),
      );
      if (!duplicate) {
        _pendingCatalogEntries.add(
          _PendingCatalogEntry(
            product: product,
            category: category,
            outletId: scopedOutletId,
          ),
        );
      }
    }
  }

  Future<void> refreshAfterCatalogSave({
    required List<ProductModel> savedProducts,
    VendorCategoryModel? category,
    int? outletId,
  }) async {
    final scopedOutletId = outletId ?? FireStoreUtils.resolveActiveOutletId();
    stageCatalogProducts(
      savedProducts,
      category: category,
      outletId: scopedOutletId,
    );
    selectedCategory.value = null;
    await refreshInventory(forceRefresh: true, outletId: scopedOutletId);
  }

  bool _isSameProduct(ProductModel a, ProductModel b) {
    final aId = a.id?.toString() ?? '';
    final bId = b.id?.toString() ?? '';
    if (aId.isNotEmpty && aId == bId) return true;

    final aName = a.name?.trim().toLowerCase() ?? '';
    final bName = b.name?.trim().toLowerCase() ?? '';
    return aName.isNotEmpty && aName == bName;
  }

  void _applyPendingCatalogEntries({
    required int outletId,
    List<ProductModel>? apiProducts,
  }) {
    if (_pendingCatalogEntries.isEmpty || outletId <= 0) return;

    _purgePendingForOtherOutlets(outletId);

    for (final entry in List<_PendingCatalogEntry>.from(_pendingCatalogEntries)) {
      if (entry.outletId != outletId) continue;

      final product = entry.product;
      if (!productList.any((p) => _isSameProduct(p, product))) {
        productList.add(product);
      }

      final category = entry.category;
      if (category != null && (category.id?.isNotEmpty ?? false)) {
        final exists = categoryList
            .any((c) => c.id?.toString() == category.id?.toString());
        if (!exists) {
          categoryList.add(category);
        }
      }
    }

    final confirmedByApi = apiProducts ?? const <ProductModel>[];
    if (confirmedByApi.isNotEmpty) {
      _pendingCatalogEntries.removeWhere(
        (entry) =>
            entry.outletId == outletId &&
            confirmedByApi.any((p) => _isSameProduct(p, entry.product)),
      );
    }

    productList.refresh();
    categoryList.refresh();
  }

  // ── Data loading ───────────────────────────────────────────────────────────
  Future<void> refreshInventory({
    bool forceRefresh = true,
    int? outletId,
  }) async {
    isLoading.value = true;
    loadError.value = '';
    try {
      final resolvedOutletId = outletId ?? FireStoreUtils.resolveActiveOutletId();
      if (resolvedOutletId <= 0) {
        final uid = await FireStoreUtils.getCurrentUid();
        final profile = await FireStoreUtils.getUserProfile(uid);
        if (profile != null) {
          Constant.userModel = profile;
          userModel.value = profile;
        }
      }
      await getProduct(forceRefresh: forceRefresh, outletId: outletId);
    } catch (e) {
      loadError.value = 'Failed to load inventory';
      _log('refreshInventory error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserProfile() async => refreshInventory();

  Future<void> getProduct({
    bool forceRefresh = false,
    int? outletId,
  }) async {
    final resolvedOutletId = outletId ?? FireStoreUtils.resolveActiveOutletId();
    loadError.value = '';

    if (resolvedOutletId > 0) {
      if (_loadedOutletId != resolvedOutletId) {
        prepareForOutletSwitch(resolvedOutletId);
      }

      _log(
        'getProduct outlet mode outletId=$resolvedOutletId force=$forceRefresh',
      );
      final outletResult = await FireStoreUtils.getOutletProducts(
        outletId: resolvedOutletId,
        forceRefresh: forceRefresh,
      );
      if (outletResult != null) {
        productList.assignAll(outletResult.products);
        categoryList.assignAll(outletResult.categories);
        _applyPendingCatalogEntries(
          outletId: resolvedOutletId,
          apiProducts: outletResult.products,
        );
        _log(
          'getProduct loaded ${productList.length} products '
          'for outlet $resolvedOutletId',
        );
        return;
      }
      loadError.value =
          FireStoreUtils.lastOutletProductsError ??
          'Could not load outlet menu. Pull to retry or tap Items again.';
      if (_pendingCatalogEntries
          .where((entry) => entry.outletId == resolvedOutletId)
          .isEmpty) {
        productList.clear();
        categoryList.clear();
      }
      _applyPendingCatalogEntries(outletId: resolvedOutletId);
      return;
    }

    _loadedOutletId = 0;
    _pendingCatalogEntries.clear();

    final value = await FireStoreUtils.getProduct();
    if (value != null) productList.value = value;
    await _syncCategories();
  }

  Future<void> _syncCategories() async {
    if (productList.isEmpty) return;

    final usedIds = productList
        .map((p) => p.categoryID?.toString())
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toSet();

    final remote = await FireStoreUtils.getMerchantCategoryById();

    if (remote != null && remote.isNotEmpty) {
      final list = usedIds.isEmpty
          ? remote
          : remote.where((c) {
        final id = c.id?.toString() ?? '';
        return id.isNotEmpty && usedIds.contains(id);
      }).toList();
      list.sort((a, b) => (a.title ?? '')
          .toLowerCase()
          .compareTo((b.title ?? '').toLowerCase()));
      categoryList.value = list;
      return;
    }

    // Fallback: synthesise placeholder categories from product data
    if (usedIds.isNotEmpty) {
      categoryList.value = usedIds
          .map((id) =>
          VendorCategoryModel(id: id, title: 'Category', isActive: true))
          .toList()
        ..sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
    }
  }

  // ── Product mutations ──────────────────────────────────────────────────────
  Future<void> updateList(String productId, bool currentPublish) async {
    if (isOutletInventoryMode) return;

    final idx = productList.indexWhere((p) => p.id == productId);
    if (idx == -1) return;
    productList[idx].publish = !currentPublish;
    productList.refresh();
    await FireStoreUtils.setProduct(productList[idx]);
  }

  Future<void> updateAvailableStatus(
      String productId, bool currentAvailable) async {
    final idx = productList.indexWhere((p) => p.id == productId);
    if (idx == -1) return;
    final toggled = !currentAvailable;
    productList[idx].isAvailable = toggled;
    productList.refresh();

    if (isOutletInventoryMode) {
      // Java: type=PRODUCT, unavailabilityId=productId
      final productIdInt = int.tryParse(productId) ?? 0;
      if (productIdInt <= 0) {
        productList[idx].isAvailable = currentAvailable;
        productList.refresh();
        return;
      }

      final success = toggled
          ? await FireStoreUtils.restoreOutletItemAvailability(
              type: 'PRODUCT',
              unavailabilityId: productIdInt,
              reason: 'Product made available',
            )
          : await FireStoreUtils.postOutletItemUnavailability(
              type: 'PRODUCT',
              unavailabilityId: productIdInt,
              reason: 'Product made unavailable',
            );

      if (!success) {
        productList[idx].isAvailable = currentAvailable;
        productList.refresh();
        return;
      }

      FireStoreUtils.invalidateOutletProductCache();
      return;
    }

    try {
      await FireStoreUtils.updateProductIsAvailable(productId, toggled);
    } catch (_) {
      productList[idx].isAvailable = currentAvailable;
      productList.refresh();
    }
  }

  /// Outlet inventory: confirm + duration picker when turning OFF; PATCH restore when ON.
  Future<void> handleProductAvailabilityToggle(
    BuildContext context,
    String productId,
    bool currentAvailable,
  ) async {
    if (!isOutletInventoryMode) {
      await updateAvailableStatus(productId, currentAvailable);
      return;
    }

    final idx = productList.indexWhere((p) => p.id == productId);
    if (idx == -1) return;

    final productIdInt = int.tryParse(productId) ?? 0;
    if (productIdInt <= 0) return;

    if (!currentAvailable) {
      final success = await FireStoreUtils.restoreOutletItemAvailability(
        type: 'PRODUCT',
        unavailabilityId: productIdInt,
        reason: 'Product made available',
      );
      if (!success) {
        ShowToastDialog.showToast('Failed to update product availability');
        return;
      }
      productList[idx].isAvailable = true;
      productList.refresh();
      FireStoreUtils.invalidateOutletProductCache();
      return;
    }

    final dates = await InventoryUnavailabilityFlow.runCloseFlow(
      context,
      InventoryUnavailabilityKind.product,
    );
    if (dates == null) return;

    final success = await FireStoreUtils.postOutletItemUnavailability(
      type: 'PRODUCT',
      unavailabilityId: productIdInt,
      reason: 'Product made unavailable',
      fromDate: dates.from,
      toDate: dates.to,
    );

    if (!success) {
      ShowToastDialog.showToast('Failed to update product availability');
      return;
    }

    productList[idx].isAvailable = false;
    productList.refresh();
    FireStoreUtils.invalidateOutletProductCache();
  }

  Future<void> deleteProduct(int index) async {
    final product = productList[index];
    await FireStoreUtils.deleteProduct(product);
    productList.removeAt(index);
  }

  // ── Category mutations ─────────────────────────────────────────────────────
  int _resolveOutletCategoryUnavailabilityId(VendorCategoryModel cat) {
    if (cat.outletCategoryId != null && cat.outletCategoryId! > 0) {
      return cat.outletCategoryId!;
    }
    return int.tryParse(cat.id ?? '') ?? 0;
  }

  Future<void> toggleCategoryActive(int index) async {
    final cat = categoryList[index];
    final newStatus = !(cat.isActive ?? true);
    _log('toggleCategoryActive idx=$index newStatus=$newStatus');

    // Optimistic local update
    categoryList[index] = VendorCategoryModel(
      id: cat.id,
      title: cat.title,
      photo: cat.photo,
      description: cat.description,
      reviewAttributes: cat.reviewAttributes,
      isActive: newStatus,
      outletCategoryId: cat.outletCategoryId,
    );
    categoryList.refresh();
    final catId = cat.id?.toString() ?? '';
    for (int i = 0; i < productList.length; i++) {
      if ((productList[i].categoryID?.toString() ?? '') == catId) {
        productList[i].isAvailable = newStatus;
      }
    }
    productList.refresh();

    if (isOutletInventoryMode) {
      final outletCategoryId = _resolveOutletCategoryUnavailabilityId(cat);
      if (outletCategoryId <= 0) {
        _log('toggleCategoryActive — missing outletCategoryId for ${cat.id}');
        categoryList[index] = cat;
        categoryList.refresh();
        for (int i = 0; i < productList.length; i++) {
          if ((productList[i].categoryID?.toString() ?? '') == catId) {
            productList[i].isAvailable = cat.isActive ?? true;
          }
        }
        productList.refresh();
        ShowToastDialog.showToast(
          'Category id missing. Please refresh the menu.',
        );
        return;
      }

      _log(
        'toggleCategoryActive OUTLET_CATEGORY id=$outletCategoryId '
        'available=$newStatus',
      );

      final success = newStatus
          ? await FireStoreUtils.restoreOutletItemAvailability(
              type: 'OUTLET_CATEGORY',
              unavailabilityId: outletCategoryId,
              reason: 'Category made available',
            )
          : await FireStoreUtils.postOutletItemUnavailability(
              type: 'OUTLET_CATEGORY',
              unavailabilityId: outletCategoryId,
              reason: 'Category made unavailable',
            );

      if (!success) {
        categoryList[index] = cat;
        categoryList.refresh();
        for (int i = 0; i < productList.length; i++) {
          if ((productList[i].categoryID?.toString() ?? '') == catId) {
            productList[i].isAvailable = !(newStatus);
          }
        }
        productList.refresh();
        ShowToastDialog.showToast('Failed to update category availability');
        return;
      }

      FireStoreUtils.invalidateOutletProductCache();
      return;
    }

    // Legacy PHP — persist both changes in parallel
    await Future.wait([
      FireStoreUtils.updateCategoryIsActive(cat.id!, newStatus),
      FireStoreUtils.setAllProductsAvailabilityForCategory(cat.id!, newStatus),
    ]);
    FireStoreUtils.invalidateProductCache(Constant.userModel?.vendorID);
  }

  /// Outlet inventory: confirm + duration picker when turning OFF; PATCH restore when ON.
  Future<void> handleCategoryActiveToggle(
    BuildContext context,
    int index,
  ) async {
    if (!isOutletInventoryMode) {
      await toggleCategoryActive(index);
      return;
    }

    final cat = categoryList[index];
    final currentActive = cat.isActive ?? true;
    final catId = cat.id?.toString() ?? '';

    final outletCategoryId = _resolveOutletCategoryUnavailabilityId(cat);
    if (outletCategoryId <= 0) {
      ShowToastDialog.showToast(
        'Category id missing. Please refresh the menu.',
      );
      return;
    }

    if (!currentActive) {
      final success = await FireStoreUtils.restoreOutletItemAvailability(
        type: 'OUTLET_CATEGORY',
        unavailabilityId: outletCategoryId,
        reason: 'Category made available',
      );
      if (!success) {
        ShowToastDialog.showToast('Failed to update category availability');
        return;
      }

      categoryList[index] = VendorCategoryModel(
        id: cat.id,
        title: cat.title,
        photo: cat.photo,
        description: cat.description,
        reviewAttributes: cat.reviewAttributes,
        isActive: true,
        outletCategoryId: cat.outletCategoryId,
      );
      categoryList.refresh();
      for (int i = 0; i < productList.length; i++) {
        if ((productList[i].categoryID?.toString() ?? '') == catId) {
          productList[i].isAvailable = true;
        }
      }
      productList.refresh();
      FireStoreUtils.invalidateOutletProductCache();
      return;
    }

    final dates = await InventoryUnavailabilityFlow.runCloseFlow(
      context,
      InventoryUnavailabilityKind.outletCategory,
    );
    if (dates == null) return;

    final success = await FireStoreUtils.postOutletItemUnavailability(
      type: 'OUTLET_CATEGORY',
      unavailabilityId: outletCategoryId,
      reason: 'Category made unavailable',
      fromDate: dates.from,
      toDate: dates.to,
    );

    if (!success) {
      ShowToastDialog.showToast('Failed to update category availability');
      return;
    }

    categoryList[index] = VendorCategoryModel(
      id: cat.id,
      title: cat.title,
      photo: cat.photo,
      description: cat.description,
      reviewAttributes: cat.reviewAttributes,
      isActive: false,
      outletCategoryId: cat.outletCategoryId,
    );
    categoryList.refresh();
    for (int i = 0; i < productList.length; i++) {
      if ((productList[i].categoryID?.toString() ?? '') == catId) {
        productList[i].isAvailable = false;
      }
    }
    productList.refresh();
    FireStoreUtils.invalidateOutletProductCache();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _log(String msg) {
    if (AppConfig.enableDebugLogs) {
      // ignore: avoid_print
      print('ProductListController.$msg');
    }
  }
}

class _PendingCatalogEntry {
  final ProductModel product;
  final VendorCategoryModel? category;
  final int outletId;

  _PendingCatalogEntry({
    required this.product,
    required this.outletId,
    this.category,
  });
}