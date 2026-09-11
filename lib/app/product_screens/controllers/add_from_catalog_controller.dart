import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:jippymart_restaurant/app/product_screens/controllers/product_list_controller.dart';

import 'package:jippymart_restaurant/models/master_product_model.dart';
import 'package:jippymart_restaurant/models/product_model.dart';
import 'package:jippymart_restaurant/models/selected_product_model.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';
import 'package:jippymart_restaurant/service/food_api_service.dart'
    show FoodApiService;
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/pricing_calculator.dart';

import '../../../models/addproduct_from _masterproduct.dart';
import '../../../models/variant_group_model.dart';

class AddFromCatalogController extends GetxController {
  final TextEditingController categorySearchController = TextEditingController();
  final RxString categorySearchText = ''.obs;
  AddFromCatalogController({
    this.initialCategory,
  });

  // ---------------------------------------------------------------------------
  // INITIAL CATEGORY
  // ---------------------------------------------------------------------------

  /// If provided, category selection screen is skipped.
  final VendorCategoryModel? initialCategory;

  // ---------------------------------------------------------------------------
  // LOADING
  // ---------------------------------------------------------------------------

  final RxBool isLoading = true.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isSaving = false.obs;

  // ---------------------------------------------------------------------------
  // CATEGORIES
  // ---------------------------------------------------------------------------

  final RxList<VendorCategoryModel> categoryList =
      <VendorCategoryModel>[].obs;

  /// Categories displayed after applying the search text.
  List<VendorCategoryModel> get filteredCategories {
    final search = categorySearchText.value.trim().toLowerCase();

    // If search box is empty, show all categories.
    if (search.isEmpty) {
      return categoryList.toList();
    }

    // Otherwise filter categories locally.
    return categoryList.where((category) {
      final categoryName = category.title ?? '';

      return categoryName.toLowerCase().contains(search);
    }).toList();
  }
  final Rx<VendorCategoryModel?> selectedCategory =
  Rx<VendorCategoryModel?>(null);

  // ---------------------------------------------------------------------------
  // MASTER PRODUCTS
  // ---------------------------------------------------------------------------

  final RxList<MasterProductModel> masterProducts =
      <MasterProductModel>[].obs;

  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalProducts = 0.obs;

  static const int perPage = 10;

  final RxString searchQuery = ''.obs;
  final TextEditingController productSearchController =
  TextEditingController();
  Timer? _searchDebounce;
  // ---------------------------------------------------------------------------
  // SELECTED PRODUCTS
  // ---------------------------------------------------------------------------

  /// Key = master product ID
  /// Value = selected product data
  final RxMap<String, SelectedProductModel> selectedProducts =
      <String, SelectedProductModel>{}.obs;

  // ---------------------------------------------------------------------------
  // PRICING
  // ---------------------------------------------------------------------------

  final RxBool hasSubscription = false.obs;

  final RxString planType = 'commission'.obs;

  final RxInt applyPercentage = 30.obs;

  final RxBool gstAgreed = false.obs;

  // ---------------------------------------------------------------------------
  // LAST JAVA API RESPONSE
  // ---------------------------------------------------------------------------

  AddProductsFromMasterResponse? lastStoreResponse;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();

    if (initialCategory != null) {
      selectCategory(initialCategory);
    } else {
      loadCategories();
    }
  }
  void onClose() {
    _searchDebounce?.cancel();

    categorySearchController.dispose();
    productSearchController.dispose();

    super.onClose();
  }
  // ---------------------------------------------------------------------------
  // LOAD CATEGORIES
  // ---------------------------------------------------------------------------

  Future<void> loadCategories() async {
    isLoading.value = true;

    try {
      final outletCategoryMap = await _loadOutletCategoryIdMap();

      final list = await FireStoreUtils.getAllMasterCategories();

      if (list == null || list.isEmpty) {
        categoryList.clear();
        return;
      }

      categoryList.value = list.map((cat) {
        final categoryId = cat.id?.toString() ?? '';

        final outletCatId = outletCategoryMap[categoryId];

        if (outletCatId != null && outletCatId > 0) {
          return VendorCategoryModel(
            id: cat.id,
            title: cat.title,
            photo: cat.photo,
            description: cat.description,
            reviewAttributes: cat.reviewAttributes,
            isActive: cat.isActive,
            categoryType: cat.categoryType,
            categoryImageUrl: cat.categoryImageUrl,
            outletCategoryId: outletCatId,
          );
        }

        return cat;
      }).toList();
    } catch (e) {
      print("loadCategories error: $e");

      categoryList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD OUTLET CATEGORY ID MAP
  // ---------------------------------------------------------------------------

  Future<Map<String, int>> _loadOutletCategoryIdMap() async {
    final outletId = FireStoreUtils.resolveActiveOutletId();

    if (outletId <= 0) {
      return {};
    }

    try {
      final outletResult = await FireStoreUtils.getOutletDetailsWithProducts(
        outletId: outletId,
      );

      if (outletResult == null) {
        return {};
      }

      final map = <String, int>{};

      for (final cat in outletResult.categories) {
        final categoryId = cat.id?.toString() ?? '';

        final outletCatId = cat.outletCategoryId;

        if (categoryId.isNotEmpty &&
            outletCatId != null &&
            outletCatId > 0) {
          map[categoryId] = outletCatId;
        }
      }

      return map;
    } catch (e) {
      print("_loadOutletCategoryIdMap error: $e");

      return {};
    }
  }

  // ---------------------------------------------------------------------------
  // RESOLVE CATEGORY ID FOR SAVE
  // ---------------------------------------------------------------------------

  int resolveOutletCategoryIdForSave() {
    final cat = selectedCategory.value;

    // First preference:
    // outletCategoryId
    if (cat?.outletCategoryId != null &&
        cat!.outletCategoryId! > 0) {
      return cat.outletCategoryId!;
    }

    // Second preference:
    // selected category ID
    final categoryId = cat?.id?.toString() ?? '';

    if (categoryId.isNotEmpty) {
      for (final item in categoryList) {
        if (item.id == categoryId &&
            item.outletCategoryId != null &&
            item.outletCategoryId! > 0) {
          return item.outletCategoryId!;
        }
      }

      final parsed = int.tryParse(categoryId);

      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }

    // Third preference:
    // selected product category ID
    if (selectedProducts.isNotEmpty) {
      final fromProduct = int.tryParse(
        selectedProducts.values.first.categoryId ?? '',
      );

      if (fromProduct != null && fromProduct > 0) {
        return fromProduct;
      }
    }

    return 0;
  }

  // ---------------------------------------------------------------------------
  // SELECT CATEGORY
  // ---------------------------------------------------------------------------

  // Future<void> selectCategory(
  //     VendorCategoryModel? category,
  //     ) async {
  //   selectedCategory.value = category;
  //
  //   masterProducts.clear();
  //
  //   selectedProducts.clear();
  //
  //   if (category?.id?.isNotEmpty != true) {
  //     return;
  //   }
  //
  //   // If outletCategoryId isn't already available,
  //   // try to resolve it from outlet categories.
  //   if (category!.outletCategoryId == null ||
  //       category.outletCategoryId! <= 0) {
  //     final map = await _loadOutletCategoryIdMap();
  //
  //     final outletCatId = map[category.id!];
  //
  //     if (outletCatId != null && outletCatId > 0) {
  //       selectedCategory.value = VendorCategoryModel(
  //         id: category.id,
  //         title: category.title,
  //         photo: category.photo,
  //         description: category.description,
  //         reviewAttributes: category.reviewAttributes,
  //         isActive: category.isActive,
  //         categoryType: category.categoryType,
  //         categoryImageUrl: category.categoryImageUrl,
  //         outletCategoryId: outletCatId,
  //       );
  //     }
  //   }
  //
  //   currentPage.value = 1;
  //
  //   await loadMasterProducts();
  // }
  Future<void> selectCategory(
      VendorCategoryModel? category,
      ) async {
    selectedCategory.value = category;

    masterProducts.clear();
    selectedProducts.clear();

    searchQuery.value = '';
    productSearchController.clear();

    if (category?.id?.isNotEmpty != true) {
      return;
    }

    currentPage.value = 1;

    // Start product loading without waiting.
    loadMasterProducts();

    // Resolve outlet category separately.
    if (category!.outletCategoryId == null ||
        category.outletCategoryId! <= 0) {
      _resolveOutletCategoryId(category);
    }
  }
  Future<void> _resolveOutletCategoryId(
      VendorCategoryModel category,
      ) async {
    try {
      final map = await _loadOutletCategoryIdMap();

      final outletCatId = map[category.id!];

      if (outletCatId != null && outletCatId > 0) {
        selectedCategory.value = VendorCategoryModel(
          id: category.id,
          title: category.title,
          photo: category.photo,
          description: category.description,
          reviewAttributes: category.reviewAttributes,
          isActive: category.isActive,
          categoryType: category.categoryType,
          categoryImageUrl: category.categoryImageUrl,
          outletCategoryId: outletCatId,
        );
      }
    } catch (e) {
      print('Resolve outlet category ID error: $e');
    }
  }
  // ---------------------------------------------------------------------------
  // CREATE CATEGORY
  // ---------------------------------------------------------------------------

  Future<void> createCategory({
    required String categoryName,
    required String categoryType,
    required String categoryImageUrl,
    required int createdBy,
  }) async {
    if (categoryName.trim().isEmpty) {
      return;
    }

    final success = await FireStoreUtils.createCategory(
      categoryName: categoryName.trim(),
      categoryType: categoryType,
      categoryImageUrl: categoryImageUrl,
      createdBy: createdBy,
    );

    if (success) {
      await loadCategories();

      Get.snackbar(
        "Success",
        "Category Created",
      );
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD MASTER PRODUCTS
  // ---------------------------------------------------------------------------

  Future<void> loadMasterProducts({
    bool append = false,
  }) async {
    final cat = selectedCategory.value;

    if (cat?.id == null) {
      return;
    }

    if (!append) {
      isLoadingProducts.value = true;
    }

    try {
      final res = await FoodApiService.getMasterProductsByCategoryId(
        cat!.id!,
        page: currentPage.value,
        perPage: perPage,
        search: searchQuery.value.isEmpty
            ? null
            : searchQuery.value,
      );

      if (res != null) {
        if (!append) {
          masterProducts.assignAll(res.products);
        } else {
          masterProducts.addAll(res.products);
        }

        // Java API currently does not return pagination.
        totalProducts.value = res.products.length;

        print(
          "Loaded Products Count => ${res.products.length}",
        );
      }
    } catch (e) {
      print(
        "loadMasterProducts Error => $e",
      );
    } finally {
      isLoadingProducts.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------
  void setCategorySearch(String query) {
    categorySearchText.value = query;
  }

  void setSearch(String query) {
    searchQuery.value = query;

    // Cancel the previous timer.
    _searchDebounce?.cancel();

    // If search is empty, reload all products immediately.
    if (query.trim().isEmpty) {
      currentPage.value = 1;
      loadMasterProducts();
      return;
    }

    // Wait until the user stops typing.
    _searchDebounce = Timer(
      const Duration(milliseconds: 100),
          () {
        currentPage.value = 1;
        loadMasterProducts();
      },
    );
  }
  Future<void> searchProducts() async {
    currentPage.value = 1;

    await loadMasterProducts();
  }

  // ---------------------------------------------------------------------------
  // PAGINATION
  // ---------------------------------------------------------------------------

  void goToPage(int page) {
    if (page < 1 || page > lastPage.value) {
      return;
    }

    currentPage.value = page;

    loadMasterProducts();
  }

  // ---------------------------------------------------------------------------
  // PRODUCT SELECTION
  // ---------------------------------------------------------------------------

  bool isSelected(String id) {
    return selectedProducts.containsKey(id);
  }

  void toggleSelection(
      MasterProductModel product,
      ) {
    final id = product.id;

    if (id == null) {
      return;
    }

    if (selectedProducts.containsKey(id)) {
      selectedProducts.remove(id);
      return;
    }

    selectedProducts[id] = _buildSelection(product);
  }

  // ---------------------------------------------------------------------------
  // BUILD SELECTED PRODUCT
  // ---------------------------------------------------------------------------

  SelectedProductModel _buildSelection(
      MasterProductModel product,
      ) {
    final id = product.id!;

    // -------------------------------------------------------------------------
    // EXISTING PRODUCT
    // -------------------------------------------------------------------------

    if (product.isExisting == true) {
      final addons = <AddonItem>[];

      final titles = product.vendorAddOnsTitle ?? [];

      final prices = product.vendorAddOnsPrice ?? [];

      for (int i = 0;
      i < titles.length && i < prices.length;
      i++) {
        addons.add(
          AddonItem(
            title: titles[i],
            price: prices[i],
          ),
        );
      }

      final timings = <String, List<TimeRangeItem>>{};

      for (final t in product.vendorAvailableTimings ?? []) {
        if (t.day != null && t.timeslot != null) {
          final slots = t.timeslot!
              .map<TimeRangeItem>(
                (s) => TimeRangeItem(productAvailableTimingId: s.productAvailableTimingId ?? 0,
              from: s.from ?? '',
              to: s.to ?? '',
            ),
          )
              .toList();

          timings[t.day!] = slots;
        }
      }

      final options =
      (product.vendorOptions ?? [])
          .map(
            (o) => OptionItem(
          id: o.id ?? '',
          title: o.title ?? '',
          price: o.price ?? '0',
          originalPrice: o.price ?? '0',
          isAvailable: o.isAvailable ?? true,
        ),
      )
          .toList();

      final merchant =
          double.tryParse(
            product.vendorMerchantPrice ?? '',
          ) ??
              (product.suggestedPrice ?? 0);

      return SelectedProductModel(
        masterProductId: id,

        productName: product.name,

        description: product.description,

        categoryId:
        product.categoryId ??
            selectedCategory.value?.id,

        isVeg: product.veg ?? false,

        vendorProductId: product.vendorProductId,

        merchantPrice: merchant,

        onlinePrice:
        double.tryParse(
          product.vendorPrice ?? '',
        ) ??
            merchant,

        discountPrice:
        double.tryParse(
          product.vendorDisPrice ?? '',
        ) ??
            0,

        publish:
        product.vendorPublish ?? true,

        isAvailable:
        product.vendorIsAvailable ?? true,

        addons: addons,

        availableDays:
        List.from(
          product.vendorAvailableDays ?? [],
        ),

        availableTimings: timings,

        options: options,
      );
    }

    // -------------------------------------------------------------------------
    // NEW PRODUCT FROM MASTER CATALOG
    // -------------------------------------------------------------------------

    final merchant =
        product.suggestedPrice ?? 0;

    final online =
    PricingCalculator.calculateOnlinePrice(
      merchantPrice: merchant,
      hasSubscription: hasSubscription.value,
      planType: planType.value,
      applyPercentage: applyPercentage.value,
      gstAgreed: gstAgreed.value,
    );

    final options =
    (product.options ?? [])
        .map(
          (o) => OptionItem(
        id: o.id ?? '',
        title: o.title ?? '',
        subtitle: o.subtitle,
        price:
        (o.price ?? 0).toString(),
        originalPrice:
        (o.price ?? 0).toString(),
        isAvailable: false,
      ),
    )
        .toList();

    return SelectedProductModel(
      masterProductId: id,

      productName: product.name,

      description: product.description,

      categoryId:
      product.categoryId ??
          selectedCategory.value?.id,

      isVeg: product.veg ?? false,

      merchantPrice: merchant,

      onlinePrice: online,

      discountPrice: 0,

      publish: true,

      isAvailable: true,

      addons: [],

      availableDays: [],

      availableTimings: {},

      options: options,
    );
  }

  // ---------------------------------------------------------------------------
  // GENERIC UPDATE
  // ---------------------------------------------------------------------------

  void _update(
      String id,
      void Function(SelectedProductModel s) fn,
      ) {
    final sel = selectedProducts[id];

    if (sel == null) {
      return;
    }

    fn(sel);

    selectedProducts.refresh();
  }

  // ---------------------------------------------------------------------------
  // PRICE UPDATES
  // ---------------------------------------------------------------------------

  void updateMerchantPrice(
      String id,
      double value,
      ) {
    _update(
      id,
          (s) {
        s.merchantPrice = value;

        s.onlinePrice =
            PricingCalculator.calculateOnlinePrice(
              merchantPrice: value,
              hasSubscription:
              hasSubscription.value,
              planType: planType.value,
              applyPercentage:
              applyPercentage.value,
              gstAgreed: gstAgreed.value,
            );
      },
    );
  }

  void updateOnlinePrice(
      String id,
      double value,
      ) {
    _update(
      id,
          (s) {
        s.onlinePrice = value;
      },
    );
  }

  void updateDiscountPrice(
      String id,
      double value,
      ) {
    _update(
      id,
          (s) {
        s.discountPrice = value;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // PUBLISH / AVAILABILITY
  // ---------------------------------------------------------------------------

  void setPublish(
      String id,
      bool value,
      ) {
    _update(
      id,
          (s) {
        s.publish = value;
      },
    );
  }

  void setAvailable(
      String id,
      bool value,
      ) {
    _update(
      id,
          (s) {
        s.isAvailable = value;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ADDONS
  // ---------------------------------------------------------------------------

  void setAddons(
      String id,
      List<AddonItem> addons,
      ) {
    _update(
      id,
          (s) {
        s.addons = addons;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // AVAILABLE DAYS
  // ---------------------------------------------------------------------------

  void setAvailableDays(
      String id,
      List<String> days,
      ) {
    _update(
      id,
          (s) {
        s.availableDays = days;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // AVAILABLE TIMINGS
  // ---------------------------------------------------------------------------

  void setAvailableTimings(
      String id,
      Map<String, List<TimeRangeItem>> timings,
      ) {
    _update(
      id,
          (s) {
        s.availableTimings = timings;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // OPTIONS
  // ---------------------------------------------------------------------------

  void setOptions(
      String id,
      List<OptionItem> options,
      ) {
    _update(
      id,
          (s) {
        s.options = options;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // VALIDATION
  // ---------------------------------------------------------------------------

  String? validateForSave() {
    if (selectedProducts.isEmpty) {
      return 'Please select at least one product.';
    }

    for (final e in selectedProducts.entries) {
      final product = e.value;

      if (product.merchantPrice <= 0) {
        return 'Merchant price must be greater than 0.';
      }

      if (product.discountPrice >
          product.onlinePrice) {
        return 'Discount price cannot be greater than online price.';
      }

      for (final opt in product.options) {
        if (!opt.isAvailable) {
          continue;
        }

        final price =
            double.tryParse(opt.price) ?? 0;

        if (price <= 0) {
          return 'Option "${opt.title}" must have a price greater than 0.';
        }
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // CONVERT TO INVENTORY PRODUCTS
  // ---------------------------------------------------------------------------

  List<ProductModel> _toInventoryProducts(
      List<SelectedProductModel> saved,
      ) {
    final category =
        selectedCategory.value;

    final categoryId =
        category?.id?.toString() ?? '';

    return saved
        .map(
          (sel) => ProductModel(
        id: sel.masterProductId,

        name: sel.productName,

        description: sel.description,

        categoryID:
        sel.categoryId ?? categoryId,

        merchant_price:
        sel.merchantPrice
            .toStringAsFixed(0),

        price:
        sel.merchantPrice
            .toStringAsFixed(0),

        disPrice: '0',

        veg:
        sel.isVeg ?? false,

        nonveg:
        !(sel.isVeg ?? false),

        publish:
        sel.publish,

        isAvailable:
        sel.isAvailable,

        quantity: 0,
      ),
    )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // REFRESH INVENTORY AFTER JAVA API SAVE
  // ---------------------------------------------------------------------------

  Future<void> _refreshInventoryAfterSave(
      List<SelectedProductModel> saved,
      ) async {
    final outletId =
    FireStoreUtils.resolveActiveOutletId();

    FireStoreUtils.invalidateOutletProductCache(
      outletId,
    );

    FireStoreUtils.invalidateVendorCategoryCache();

    if (!Get.isRegistered<ProductListController>()) {
      Get.put(
        ProductListController(),
        permanent: true,
      );
    }

    await Get.find<ProductListController>()
        .refreshAfterCatalogSave(
      savedProducts:
      _toInventoryProducts(saved),

      category:
      selectedCategory.value,

      outletId:
      outletId,
    );
  }

  // ---------------------------------------------------------------------------
  // SAVE PRODUCTS
  // ---------------------------------------------------------------------------

  Future<bool> saveAndCaptureResponse() async {
    // Validate selected products
    final err = validateForSave();

    if (err != null) {
      print(
        "Validation Error: $err",
      );

      lastStoreResponse =
          AddProductsFromMasterResponse(
            savedCount: 0,
            skippedCount: 0,
            savedNames: [],
            skippedNames: [],
          );

      return false;
    }

    isSaving.value = true;

    lastStoreResponse = null;

    try {
      // -----------------------------------------------------------------------
      // Resolve category ID
      // -----------------------------------------------------------------------

      final categoryId =
      resolveOutletCategoryIdForSave();

      if (categoryId <= 0) {
        print(
          "ERROR: Invalid categoryId = $categoryId",
        );

        lastStoreResponse =
            AddProductsFromMasterResponse(
              savedCount: 0,
              skippedCount: 0,
              savedNames: [],
              skippedNames: [],
            );

        return false;
      }

      // -----------------------------------------------------------------------
      // Selected products
      // -----------------------------------------------------------------------

      final selected =
      selectedProducts.values.toList();

      print(
        "====================================",
      );

      print(
        "ADD PRODUCTS FROM MASTER",
      );

      print(
        "Category ID: $categoryId",
      );

      print(
        "Selected Products: ${selected.length}",
      );

      print(
        "====================================",
      );

      // -----------------------------------------------------------------------
      // CALL NEW JAVA API
      // -----------------------------------------------------------------------

      final res =
      await FoodApiService.addProductsToOutletFromMaster(
        selected,
        categoryId: categoryId,
      );

      // -----------------------------------------------------------------------
      // Store actual Java response
      // -----------------------------------------------------------------------

      lastStoreResponse = res;

      print(
        "====================================",
      );

      print(
        "JAVA API RESPONSE",
      );

      print(
        "Saved Count: ${res.savedCount}",
      );

      print(
        "Skipped Count: ${res.skippedCount}",
      );

      print(
        "Saved Names: ${res.savedNames}",
      );

      print(
        "Skipped Names: ${res.skippedNames}",
      );

      print(
        "====================================",
      );

      // -----------------------------------------------------------------------
      // If at least one product saved
      // -----------------------------------------------------------------------

      if (res.savedCount > 0) {
        await _refreshInventoryAfterSave(
          selected,
        );
      }

      // -----------------------------------------------------------------------
      // Return true only if at least one product saved
      // -----------------------------------------------------------------------

      return res.savedCount > 0;
    } catch (e, st) {
      print(
        "AddFromCatalogController.saveAndCaptureResponse error: $e",
      );

      print(st);

      lastStoreResponse =
          AddProductsFromMasterResponse(
            savedCount: 0,
            skippedCount: 0,
            savedNames: [],
            skippedNames: [],
          );

      return false;
    } finally {
      isSaving.value = false;
    }
  }
}