// import 'package:get/get.dart';
//
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/models/master_product_model.dart';
// import 'package:jippymart_restaurant/models/selected_product_model.dart';
// import 'package:jippymart_restaurant/models/vendor_category_model.dart';
// import 'package:jippymart_restaurant/service/food_api_service.dart' show FoodApiService, BulkStoreResponse;
// import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
// import 'package:jippymart_restaurant/utils/pricing_calculator.dart';
//
// class AddFromCatalogController extends GetxController {
//   RxBool isLoading = true.obs;
//   RxBool isLoadingProducts = false.obs;
//   RxBool isSaving = false.obs;
//
//   RxList<VendorCategoryModel> categoryList = <VendorCategoryModel>[].obs;
//   Rx<VendorCategoryModel?> selectedCategory = Rx<VendorCategoryModel?>(null);
//
//   RxList<MasterProductModel> masterProducts = <MasterProductModel>[].obs;
//   RxInt currentPage = 1.obs;
//   RxInt lastPage = 1.obs;
//   RxInt totalProducts = 0.obs;
//   static const int perPage = 10;
//   RxString searchQuery = ''.obs;
//
//   /// Selected products keyed by master product id. Value holds form data for store.
//   final selectedProducts = <String, SelectedProductModel>{}.obs;
//
//   /// Pricing params (from vendor profile or defaults)
//   RxBool hasSubscription = false.obs;
//   RxString planType = 'commission'.obs;
//   RxInt applyPercentage = 30.obs;
//   RxBool gstAgreed = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadCategories();
//   }
//
//   Future<void> loadCategories() async {
//     isLoading.value = true;
//     try {
//       final list = await FireStoreUtils.getVendorCategoryById();
//       if (list != null && list.isNotEmpty) {
//         categoryList.value = list;
//       } else {
//         categoryList.clear();
//       }
//     } catch (e) {
//       categoryList.clear();
//     }
//     isLoading.value = false;
//   }
//
//   Future<void> selectCategory(VendorCategoryModel? category) async {
//     selectedCategory.value = category;
//     if (category == null || category.id == null || category.id!.isEmpty) {
//       masterProducts.clear();
//       selectedProducts.clear();
//       return;
//     }
//     currentPage.value = 1;
//     await loadMasterProducts();
//   }
//
//   Future<void> loadMasterProducts({bool append = false}) async {
//     final cat = selectedCategory.value;
//     if (cat?.id == null) return;
//     if (!append) isLoadingProducts.value = true;
//     try {
//       final res = await FoodApiService.getMasterProductsByCategory(
//         cat!.id!,
//         page: currentPage.value,
//         perPage: perPage,
//         search: searchQuery.value.isEmpty ? null : searchQuery.value,
//       );
//       if (res != null) {
//         if (!append) masterProducts.assignAll(res.products);
//         if (res.pagination != null) {
//           lastPage.value = res.pagination!.lastPage;
//           totalProducts.value = res.pagination!.total;
//         }
//       }
//     } catch (_) {}
//     isLoadingProducts.value = false;
//   }
//
//   void setSearch(String query) {
//     searchQuery.value = query;
//   }
//
//   Future<void> searchProducts() async {
//     currentPage.value = 1;
//     await loadMasterProducts();
//   }
//
//   void goToPage(int page) {
//     if (page < 1 || page > lastPage.value) return;
//     currentPage.value = page;
//     loadMasterProducts();
//   }
//
//   bool isSelected(String masterProductId) => selectedProducts.containsKey(masterProductId);
//
//   void toggleSelection(MasterProductModel product) {
//     if (product.id == null) return;
//     final id = product.id!;
//     if (selectedProducts.containsKey(id)) {
//       selectedProducts.remove(id);
//       return;
//     }
//     double merchant = 0;
//     double online = 0;
//     double discount = 0;
//     bool publish = true;
//     bool available = true;
//     List<AddonItem> addons = [];
//     List<String> days = [];
//     Map<String, List<TimeRangeItem>> timings = {};
//     List<OptionItem> options = [];
//
//     if (product.isExisting == true) {
//       merchant = double.tryParse(product.vendorMerchantPrice ?? '') ?? (product.suggestedPrice ?? 0);
//       online = double.tryParse(product.vendorPrice ?? '') ?? merchant;
//       discount = double.tryParse(product.vendorDisPrice ?? '') ?? 0;
//       publish = product.vendorPublish ?? true;
//       available = product.vendorIsAvailable ?? true;
//       if (product.vendorAddOnsTitle != null && product.vendorAddOnsPrice != null) {
//         for (var i = 0; i < product.vendorAddOnsTitle!.length; i++) {
//           if (i < product.vendorAddOnsPrice!.length) {
//             addons.add(AddonItem(title: product.vendorAddOnsTitle![i], price: product.vendorAddOnsPrice![i]));
//           }
//         }
//       }
//       if (product.vendorAvailableDays != null) days = List.from(product.vendorAvailableDays!);
//       if (product.vendorAvailableTimings != null) {
//         for (final t in product.vendorAvailableTimings!) {
//           if (t.day != null && t.timeslot != null) {
//             timings[t.day!] = t.timeslot!.map((s) => TimeRangeItem(from: s.from ?? '', to: s.to ?? '')).toList();
//           }
//         }
//       }
//       if (product.vendorOptions != null) {
//         for (final o in product.vendorOptions!) {
//           options.add(OptionItem(id: o.id ?? '', title: o.title ?? '', price: o.price ?? '0', isAvailable: o.isAvailable ?? true));
//         }
//       }
//     } else {
//       merchant = product.suggestedPrice ?? 0;
//       online = PricingCalculator.calculateOnlinePrice(
//         merchantPrice: merchant,
//         hasSubscription: hasSubscription.value,
//         planType: planType.value,
//         applyPercentage: applyPercentage.value,
//         gstAgreed: gstAgreed.value,
//       );
//       if (product.options != null && product.options!.isNotEmpty) {
//         for (final o in product.options!) {
//           options.add(OptionItem(
//             id: o.id ?? '',
//             title: o.title ?? '',
//             price: (o.price ?? 0).toString(),
//             originalPrice: (o.price ?? 0).toString(),
//             isAvailable: true,
//           ));
//         }
//       }
//     }
//
//     selectedProducts[id] = SelectedProductModel(
//       masterProductId: id,
// productName: product.name,
// description: product.description,
// categoryId: product.categoryId,
// isVeg: product.veg ?? false,
//
//       vendorProductId: product.vendorProductId,
//       merchantPrice: merchant,
//       onlinePrice: online,
//       discountPrice: discount,
//       publish: publish,
//       isAvailable: available,
//       addons: addons,
//       availableDays: days,
//       availableTimings: timings,
//       options: options,
//     );
//   }
//
//   void updateMerchantPrice(String masterProductId, double value) {
//     final sel = selectedProducts[masterProductId];
//     if (sel == null) return;
//     sel.merchantPrice = value;
//     sel.onlinePrice = PricingCalculator.calculateOnlinePrice(
//       merchantPrice: value,
//       hasSubscription: hasSubscription.value,
//       planType: planType.value,
//       applyPercentage: applyPercentage.value,
//       gstAgreed: gstAgreed.value,
//     );
//     selectedProducts.refresh();
//   }
//
//   void updateOnlinePrice(String masterProductId, double value) {
//     final sel = selectedProducts[masterProductId];
//     if (sel == null) return;
//     sel.onlinePrice = value;
//     selectedProducts.refresh();
//   }
//
//   void updateDiscountPrice(String masterProductId, double value) {
//     final sel = selectedProducts[masterProductId];
//     if (sel == null) return;
//     sel.discountPrice = value;
//     selectedProducts.refresh();
//   }
//
//   void setPublish(String masterProductId, bool value) {
//     final sel = selectedProducts[masterProductId];
//     if (sel == null) return;
//     sel.publish = value;
//     selectedProducts.refresh();
//   }
//
//   void setAvailable(String masterProductId, bool value) {
//     final sel = selectedProducts[masterProductId];
//     if (sel == null) return;
//     sel.isAvailable = value;
//     selectedProducts.refresh();
//   }
//
//   void setAddons(String masterProductId, List<AddonItem> addons) {
//     final sel = selectedProducts[masterProductId];
//     if (sel == null) return;
//     sel.addons = addons;
//     selectedProducts.refresh();
//   }
//
//   void setAvailableDays(String masterProductId, List<String> days) {
//     final sel = selectedProducts[masterProductId];
//     if (sel == null) return;
//     sel.availableDays = days;
//     selectedProducts.refresh();
//   }
//
//   void setAvailableTimings(String masterProductId, Map<String, List<TimeRangeItem>> timings) {
//     final sel = selectedProducts[masterProductId];
//     if (sel == null) return;
//     sel.availableTimings = timings;
//     selectedProducts.refresh();
//   }
//
//   void setOptions(String masterProductId, List<OptionItem> options) {
//     final sel = selectedProducts[masterProductId];
//     if (sel == null) return;
//     sel.options = options;
//     selectedProducts.refresh();
//   }
//
//   String? validateForSave() {
//     if (selectedProducts.isEmpty) return 'Please select at least one product.';
//     for (final e in selectedProducts.entries) {
//       if (e.value.merchantPrice <= 0) return 'Merchant price must be greater than 0 for "${e.key}".';
//       if (e.value.discountPrice > e.value.onlinePrice) return 'Discount price cannot be greater than online price.';
//     }
//     return null;
//   }
//
//   Future<bool> save() async {
//     final err = validateForSave();
//     if (err != null) return false;
//     isSaving.value = true;
//     try {
//       final list = selectedProducts.values.toList();
//       final res = await FoodApiService.bulkStoreProducts(list);
//       isSaving.value = false;
//       if (res.success) {
//         return true;
//       }
//       return false;
//     } catch (_) {
//       isSaving.value = false;
//       return false;
//     }
//   }
//
//   BulkStoreResponse? lastStoreResponse;
//
//   Future<bool> saveAndCaptureResponse() async {
//     final err = validateForSave();
//     if (err != null) {
//       lastStoreResponse = BulkStoreResponse(success: false, message: err, imported: 0, errors: null, statusCode: 0);
//       return false;
//     }
//     isSaving.value = true;
//     lastStoreResponse = null;
//     try {
//       final list = selectedProducts.values.toList();
//       final res = await FoodApiService.bulkStoreProducts(list);
//       lastStoreResponse = res;
//       isSaving.value = false;
//       return res.success;
//     } catch (e) {
//       lastStoreResponse = BulkStoreResponse(success: false, message: e.toString(), imported: 0, errors: null, statusCode: 0);
//       isSaving.value = false;
//       return false;
//     }
//   }
// }



import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:jippymart_restaurant/controller/product_list_controller.dart';
import 'package:jippymart_restaurant/models/master_product_model.dart';
import 'package:jippymart_restaurant/models/product_model.dart';
import 'package:jippymart_restaurant/models/selected_product_model.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';
import 'package:jippymart_restaurant/service/food_api_service.dart'
    show FoodApiService, BulkStoreResponse;
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/pricing_calculator.dart';

class AddFromCatalogController extends GetxController {
  AddFromCatalogController({this.initialCategory});

  /// When provided, controller skips the category dropdown step and
  /// immediately loads products for this category.
  final VendorCategoryModel? initialCategory;
  // ── Observables ────────────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isSaving = false.obs;

  final RxList<VendorCategoryModel> categoryList =
      <VendorCategoryModel>[].obs;

  final Rx<VendorCategoryModel?> selectedCategory =
  Rx<VendorCategoryModel?>(null);

  final RxList<MasterProductModel> masterProducts =
      <MasterProductModel>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalProducts = 0.obs;
  final RxString searchQuery = ''.obs;

  static const int perPage = 10;

  /// Selected products keyed by master product id.
  final RxMap<String, SelectedProductModel> selectedProducts =
      <String, SelectedProductModel>{}.obs;

  // ── Pricing params ─────────────────────────────────────────────────────────
  final RxBool hasSubscription = false.obs;
  final RxString planType = 'commission'.obs;
  final RxInt applyPercentage = 30.obs;
  final RxBool gstAgreed = false.obs;

  // ── Last API response (for error display) ─────────────────────────────────
  BulkStoreResponse? lastStoreResponse;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    if (initialCategory != null) {
      // Reuse the same flow as a manual selection so that
      // pagination / state is set up identically.
      selectCategory(initialCategory);
    } else {
      loadCategories();
    }
  }

  // ── Category ───────────────────────────────────────────────────────────────
  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      final outletCategoryMap = await _loadOutletCategoryIdMap();
      final list = await FireStoreUtils.getMerchantCategoryById();
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
    } catch (_) {
      categoryList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Maps master categoryId → outletCategoryId for the active outlet.
  Future<Map<String, int>> _loadOutletCategoryIdMap() async {
    final outletId = FireStoreUtils.resolveActiveOutletId();
    if (outletId <= 0) return {};

    final outletResult = await FireStoreUtils.getOutletProducts(
      outletId: outletId,
    );
    if (outletResult == null) return {};

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
  }

  int resolveOutletCategoryIdForSave() {
    final cat = selectedCategory.value;
    if (cat?.outletCategoryId != null && cat!.outletCategoryId! > 0) {
      return cat.outletCategoryId!;
    }

    final categoryId = cat?.id?.toString() ?? '';
    if (categoryId.isNotEmpty) {
      for (final item in categoryList) {
        if (item.id == categoryId &&
            item.outletCategoryId != null &&
            item.outletCategoryId! > 0) {
          return item.outletCategoryId!;
        }
      }
      // New master category not yet on outlet — use categoryId so API is called.
      final parsed = int.tryParse(categoryId);
      if (parsed != null && parsed > 0) return parsed;
    }

    if (selectedProducts.isNotEmpty) {
      final fromProduct =
          int.tryParse(selectedProducts.values.first.categoryId ?? '');
      if (fromProduct != null && fromProduct > 0) return fromProduct;
    }

    return 0;
  }

  Future<void> selectCategory(VendorCategoryModel? category) async {
    selectedCategory.value = category;
    masterProducts.clear();
    selectedProducts.clear();
    if (category?.id?.isNotEmpty == true) {
      if (category!.outletCategoryId == null || category.outletCategoryId! <= 0) {
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
      }
      currentPage.value = 1;
      await loadMasterProducts();
    }
  }
  //__________ CREATE CATEGORY _____________________
Future<void> createCategory({
required String categoryName,
required String categoryType,
required String categoryImageUrl,
required int createdBy,
}) async {
    if (categoryName.trim().isEmpty) return;

    final success =
    await FireStoreUtils.createCategory(
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

  // ── Products ───────────────────────────────────────────────────────────────
  // Future<void> loadMasterProducts({bool append = false}) async {
  //   final cat = selectedCategory.value;
  //   if (cat?.id == null) return;
  //   if (!append) isLoadingProducts.value = true;
  //   try {
  //     final res = await FoodApiService.getMasterProductsByCategory(
  //       cat!.id!,
  //       page: currentPage.value,
  //       perPage: perPage,
  //       search: searchQuery.value.isEmpty ? null : searchQuery.value,
  //     );
  //     if (res != null) {
  //       if (!append) masterProducts.assignAll(res.products);
  //       if (res.pagination != null) {
  //         lastPage.value = res.pagination!.lastPage;
  //         totalProducts.value = res.pagination!.total;
  //       }
  //     }
  //   } catch (_) {
  //     // silently fail — UI already shows empty state
  //   } finally {
  //     isLoadingProducts.value = false;
  //   }
  // }


  Future<void> loadMasterProducts({bool append = false}) async {
    final cat = selectedCategory.value;

    if (cat?.id == null) return;

    if (!append) {
      isLoadingProducts.value = true;
    }

    try {
      final res = await FoodApiService.getMasterProductsByCategory(
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

        // Java API does not return pagination
        totalProducts.value = res.products.length;

        print(
            "Loaded Products Count => ${res.products.length}");
      }
    } catch (e) {
      print("loadMasterProducts Error => $e");
    } finally {
      isLoadingProducts.value = false;
    }
  }
  void setSearch(String query) => searchQuery.value = query;

  Future<void> searchProducts() async {
    currentPage.value = 1;
    await loadMasterProducts();
  }

  void goToPage(int page) {
    if (page < 1 || page > lastPage.value) return;
    currentPage.value = page;
    loadMasterProducts();
  }

  // ── Selection ──────────────────────────────────────────────────────────────
  bool isSelected(String id) => selectedProducts.containsKey(id);

  void toggleSelection(MasterProductModel product) {
    final id = product.id;
    if (id == null) return;

    if (selectedProducts.containsKey(id)) {
      selectedProducts.remove(id);
      return;
    }

    selectedProducts[id] = _buildSelection(product);
  }

  SelectedProductModel _buildSelection(MasterProductModel product) {
    final id = product.id!;

    if (product.isExisting == true) {
      final addons = <AddonItem>[];
      final titles = product.vendorAddOnsTitle ?? [];
      final prices = product.vendorAddOnsPrice ?? [];
      for (int i = 0; i < titles.length && i < prices.length; i++) {
        addons.add(AddonItem(title: titles[i], price: prices[i]));
      }

      final timings = <String, List<TimeRangeItem>>{};
      for (final t in product.vendorAvailableTimings ?? []) {
        if (t.day != null && t.timeslot != null) {
          // Ensure we always end up with List<TimeRangeItem>
          final slots = t.timeslot!
              .map<TimeRangeItem>((s) =>
                  TimeRangeItem(from: s.from ?? '', to: s.to ?? ''))
              .toList();
          timings[t.day!] = slots;
        }
      }

      final options = (product.vendorOptions ?? []).map((o) => OptionItem(
        id: o.id ?? '',
        title: o.title ?? '',
        price: o.price ?? '0',
        originalPrice: o.price ?? '0',
        isAvailable: o.isAvailable ?? true,
      )).toList();

      final merchant =
          double.tryParse(product.vendorMerchantPrice ?? '') ??
              (product.suggestedPrice ?? 0);


      return SelectedProductModel(
        masterProductId: id,

        // ADD THESE 4 LINES
        productName: product.name,
        description: product.description,
        categoryId: product.categoryId ?? selectedCategory.value?.id,
        isVeg: product.veg ?? false,

        vendorProductId: product.vendorProductId,
        merchantPrice: merchant,
        onlinePrice:
        double.tryParse(product.vendorPrice ?? '') ?? merchant,
        discountPrice:
        double.tryParse(product.vendorDisPrice ?? '') ?? 0,
        publish: product.vendorPublish ?? true,
        isAvailable: product.vendorIsAvailable ?? true,
        addons: addons,
        availableDays: List.from(product.vendorAvailableDays ?? []),
        availableTimings: timings,
        options: options,
      );
      // return SelectedProductModel(
      //   masterProductId: id,
      //   vendorProductId: product.vendorProductId,
      //   merchantPrice: merchant,
      //   onlinePrice:
      //   double.tryParse(product.vendorPrice ?? '') ?? merchant,
      //   discountPrice:
      //   double.tryParse(product.vendorDisPrice ?? '') ?? 0,
      //   publish: product.vendorPublish ?? true,
      //   isAvailable: product.vendorIsAvailable ?? true,
      //   addons: addons,
      //   availableDays:
      //   List.from(product.vendorAvailableDays ?? []),
      //   availableTimings: timings,
      //   options: options,
      // );
    }

    // New product
    // final merchant = product.suggestedPrice ?? 0;
    // final online = PricingCalculator.calculateOnlinePrice(
    //   merchantPrice: merchant,
    //   hasSubscription: hasSubscription.value,
    //   planType: planType.value,
    //   applyPercentage: applyPercentage.value,
    //   gstAgreed: gstAgreed.value,
    // );
    // final options = (product.options ?? []).map((o) => OptionItem(
    //   id: o.id ?? '',
    //   title: o.title ?? '',
    //   subtitle: o.subtitle, // carry master option subtitle into UI
    //   price: (o.price ?? 0).toString(),
    //   originalPrice: (o.price ?? 0).toString(),
    //   // New catalog options start disabled; vendor must enable explicitly.
    //   isAvailable: false,
    // )).toList();
    //
    // return SelectedProductModel(
    //   masterProductId: id,
    //   merchantPrice: merchant,
    //   onlinePrice: online,
    //   discountPrice: 0,
    //   publish: true,
    //   isAvailable: true,
    //   addons: [],
    //   availableDays: [],
    //   availableTimings: {},
    //   options: options,
    // );

    final merchant = product.suggestedPrice ?? 0;

    final online = PricingCalculator.calculateOnlinePrice(
      merchantPrice: merchant,
      hasSubscription: hasSubscription.value,
      planType: planType.value,
      applyPercentage: applyPercentage.value,
      gstAgreed: gstAgreed.value,
    );

    final options = (product.options ?? []).map((o) => OptionItem(
      id: o.id ?? '',
      title: o.title ?? '',
      subtitle: o.subtitle,
      price: (o.price ?? 0).toString(),
      originalPrice: (o.price ?? 0).toString(),
      isAvailable: false,
    )).toList();

    return SelectedProductModel(
      masterProductId: id,

      // ADD THESE 4 LINES
      productName: product.name,
      description: product.description,
      categoryId: product.categoryId ?? selectedCategory.value?.id,
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

  // ── Field updates (all follow same null-guard + refresh pattern) ───────────
  void _update(String id, void Function(SelectedProductModel s) fn) {
    final sel = selectedProducts[id];
    if (sel == null) return;
    fn(sel);
    selectedProducts.refresh();
  }

  void updateMerchantPrice(String id, double value) => _update(id, (s) {
    s.merchantPrice = value;
    s.onlinePrice = PricingCalculator.calculateOnlinePrice(
      merchantPrice: value,
      hasSubscription: hasSubscription.value,
      planType: planType.value,
      applyPercentage: applyPercentage.value,
      gstAgreed: gstAgreed.value,
    );
  });

  void updateOnlinePrice(String id, double value) =>
      _update(id, (s) => s.onlinePrice = value);

  void updateDiscountPrice(String id, double value) =>
      _update(id, (s) => s.discountPrice = value);

  void setPublish(String id, bool value) =>
      _update(id, (s) => s.publish = value);

  void setAvailable(String id, bool value) =>
      _update(id, (s) => s.isAvailable = value);

  void setAddons(String id, List<AddonItem> addons) =>
      _update(id, (s) => s.addons = addons);

  void setAvailableDays(String id, List<String> days) =>
      _update(id, (s) => s.availableDays = days);

  void setAvailableTimings(
      String id, Map<String, List<TimeRangeItem>> timings) =>
      _update(id, (s) => s.availableTimings = timings);

  void setOptions(String id, List<OptionItem> options) =>
      _update(id, (s) => s.options = options);

  // ── Validation & save ──────────────────────────────────────────────────────
  String? validateForSave() {
    if (selectedProducts.isEmpty) return 'Please select at least one product.';
    for (final e in selectedProducts.entries) {
      if (e.value.merchantPrice <= 0) {
        return 'Merchant price must be greater than 0.';
      }
      if (e.value.discountPrice > e.value.onlinePrice) {
        return 'Discount price cannot be greater than online price.';
      }
      for (final opt in e.value.options) {
        if (!opt.isAvailable) continue;
        final price = double.tryParse(opt.price) ?? 0;
        if (price <= 0) {
          return 'Option "${opt.title}" must have a price greater than 0.';
        }
      }
    }
    return null;
  }

  List<ProductModel> _toInventoryProducts(List<SelectedProductModel> saved) {
    final category = selectedCategory.value;
    final categoryId = category?.id?.toString() ?? '';

    return saved
        .map(
          (sel) => ProductModel(
            id: sel.masterProductId,
            name: sel.productName,
            description: sel.description,
            categoryID: sel.categoryId ?? categoryId,
            merchant_price: sel.merchantPrice.toStringAsFixed(0),
            price: sel.merchantPrice.toStringAsFixed(0),
            disPrice: '0',
            veg: sel.isVeg ?? false,
            nonveg: !(sel.isVeg ?? false),
            publish: sel.publish,
            isAvailable: sel.isAvailable,
            quantity: 0,
          ),
        )
        .toList();
  }

  Future<void> _refreshInventoryAfterSave(
      List<SelectedProductModel> saved) async {
    final outletId = FireStoreUtils.resolveActiveOutletId();
    FireStoreUtils.invalidateOutletProductCache(outletId);
    FireStoreUtils.invalidateVendorCategoryCache();

    if (!Get.isRegistered<ProductListController>()) {
      Get.put(ProductListController(), permanent: true);
    }

    await Get.find<ProductListController>().refreshAfterCatalogSave(
      savedProducts: _toInventoryProducts(saved),
      category: selectedCategory.value,
      outletId: outletId,
    );
  }

  Future<bool> saveAndCaptureResponse() async {
    final err = validateForSave();
    if (err != null) {
      lastStoreResponse = BulkStoreResponse(
          success: false,
          message: err,
          imported: 0,
          errors: null,
          statusCode: 0);
      return false;
    }

    isSaving.value = true;
    lastStoreResponse = null;
    try {
      final outletCategoryId = resolveOutletCategoryIdForSave();

      final res = await FoodApiService.bulkStoreProducts(
        selectedProducts.values.toList(),
        outletCategoryId: outletCategoryId,
      );
      lastStoreResponse = res;
      if (res.success) {
        await _refreshInventoryAfterSave(selectedProducts.values.toList());
      }
      return res.success;
    } catch (e) {
      lastStoreResponse = BulkStoreResponse(
          success: false,
          message: e.toString(),
          imported: 0,
          errors: null,
          statusCode: 0);
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}