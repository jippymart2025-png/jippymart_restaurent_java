import 'package:jippymart_restaurant/models/product_model.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';

/// Parsed response from GET /api/fm/outlets/getOutletDetails
class OutletDetailsModel {
  final int? outletId;
  final String? outletName;
  final String? outletPhone;
  final bool? isFavourite;
  final bool? isAvailable;
  final List<OutletCategoryModel> categories;

  OutletDetailsModel({
    this.outletId,
    this.outletName,
    this.outletPhone,
    this.isFavourite,
    this.isAvailable,
    this.categories = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      if (outletId != null) 'outletId': outletId,
      if (outletName != null) 'outletName': outletName,
      if (outletPhone != null) 'outletPhone': outletPhone,
      if (isFavourite != null) 'isFavourite': isFavourite,
      if (isAvailable != null) 'isAvailable': isAvailable,
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }

  OutletDetailsModel copyWithUpdatedProduct({
    required int productId,
    required OutletProductModel updatedProduct,
  }) {
    final nextCategories = categories.map((category) {
      final nextProducts = category.products.map((product) {
        if (product.productId == productId) return updatedProduct;
        return product;
      }).toList();
      return OutletCategoryModel(
        categoryId: category.categoryId,
        outletCategoryId: category.outletCategoryId,
        categoryName: category.categoryName,
        isAvailable: category.isAvailable,
        products: nextProducts,
      );
    }).toList();

    return OutletDetailsModel(
      outletId: outletId,
      outletName: outletName,
      outletPhone: outletPhone,
      isFavourite: isFavourite,
      isAvailable: isAvailable,
      categories: nextCategories,
    );
  }

  OutletProductModel? findProductById(int productId) {
    for (final category in categories) {
      for (final product in category.products) {
        if (product.productId == productId) return product;
      }
    }
    return null;
  }

  factory OutletDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];
    final categories = <OutletCategoryModel>[];
    if (rawCategories is List) {
      for (final item in rawCategories) {
        if (item is Map) {
          categories.add(
            OutletCategoryModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return OutletDetailsModel(
      outletId: _parseInt(json['outletId']),
      outletName: json['outletName']?.toString(),
      outletPhone: json['outletPhone']?.toString(),
      isFavourite: _parseBool(json['isFavourite']),
      isAvailable: _parseBool(json['isAvailable']),
      categories: categories,
    );
  }

  /// Flatten nested categories → UI models used by Restaurant Inventory.
  OutletProductsResult toProductsResult() {
    final products = <ProductModel>[];
    final categories = <VendorCategoryModel>[];

    for (final category in this.categories) {
      final categoryId = category.categoryId?.toString() ?? '';
      if (categoryId.isNotEmpty) {
        categories.add(
          VendorCategoryModel(
            id: categoryId,
            title: category.categoryName ?? 'Category',
            isActive: category.isAvailable ?? true,
            outletCategoryId:
                category.outletCategoryId ?? category.categoryId,
          ),
        );
      }

      for (final product in category.products) {
        products.add(product.toProductModel(categoryId: categoryId));
      }
    }

    categories.sort(
      (a, b) => (a.title ?? '')
          .toLowerCase()
          .compareTo((b.title ?? '').toLowerCase()),
    );

    return OutletProductsResult(
      products: products,
      categories: categories,
    );
  }
}

 class OutletCategoryModel {
  final int? categoryId;
  final int? outletCategoryId;
  final String? categoryName;
  final bool? isAvailable;
  final List<OutletProductModel> products;

  OutletCategoryModel({
    this.categoryId,
    this.outletCategoryId,
    this.categoryName,
    this.isAvailable,
    this.products = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      if (categoryId != null) 'categoryId': categoryId,
      if (outletCategoryId != null) 'outletCategoryId': outletCategoryId,
      if (categoryName != null) 'categoryName': categoryName,
      if (isAvailable != null) 'isAvailable': isAvailable,
      'products': products.map((e) => e.toJson()).toList(),
    };
  }

  factory OutletCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    final products = <OutletProductModel>[];
    if (rawProducts is List) {
      for (final item in rawProducts) {
        if (item is Map) {
          products.add(
            OutletProductModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return OutletCategoryModel(
      categoryId: _parseInt(json['categoryId']),
      outletCategoryId: _parseOutletCategoryId(json),
      categoryName: json['categoryName']?.toString(),
      isAvailable: _parseBool(json['isAvailable']),
      products: products,
    );
  }

  static int? _parseOutletCategoryId(Map<String, dynamic> json) {
    return _parseInt(json['outletCategoryId']) ??
        _parseInt(json['outlet_category_id']) ??
        _parseInt(json['outletCategoryID']) ??
        _parseInt(json['id']);
  }
}

class OutletProductModel {
  final int? productId;
  final String? productName;
  final String? description;
  final num? merchantPrice;
  final bool? isVeg;
  final bool? hasProductVariants;
  final bool? isAvailable;
  final num? price;
  final List<OutletProductVariantModel> variants;
  final List<OutletProductTimingModel> productTimings;

  OutletProductModel({
    this.productId,
    this.productName,
    this.description,
    this.merchantPrice,
    this.isVeg,
    this.hasProductVariants,
    this.isAvailable,
    this.price,
    this.variants = const [],
    this.productTimings = const [],
  });

  OutletProductModel copyWith({
    int? productId,
    String? productName,
    String? description,
    num? merchantPrice,
    bool? isVeg,
    bool? hasProductVariants,
    bool? isAvailable,
    num? price,
    List<OutletProductVariantModel>? variants,
    List<OutletProductTimingModel>? productTimings,
  }) {
    return OutletProductModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      merchantPrice: merchantPrice ?? this.merchantPrice,
      isVeg: isVeg ?? this.isVeg,
      hasProductVariants: hasProductVariants ?? this.hasProductVariants,
      isAvailable: isAvailable ?? this.isAvailable,
      price: price ?? this.price,
      variants: variants ?? this.variants,
      productTimings: productTimings ?? this.productTimings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (productId != null) 'productId': productId,
      if (productName != null) 'productName': productName,
      if (description != null) 'description': description,
      if (merchantPrice != null) 'merchantPrice': merchantPrice,
      if (isVeg != null) 'isVeg': isVeg,
      if (hasProductVariants != null) 'hasProductVariants': hasProductVariants,
      if (isAvailable != null) 'isAvailable': isAvailable,
      'variants': variants.map((e) => e.toJson()).toList(),
      'productTimings': productTimings.map((e) => e.toJson()).toList(),
      if (price != null) 'price': price,
    };
  }

  factory OutletProductModel.fromJson(Map<String, dynamic> json) {
    final rawVariants = json['variants'];
    final variants = <OutletProductVariantModel>[];
    if (rawVariants is List) {
      for (final item in rawVariants) {
        if (item is Map) {
          variants.add(
            OutletProductVariantModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    final rawTimings = json['productTimings'];
    final timings = <OutletProductTimingModel>[];
    if (rawTimings is List) {
      for (final item in rawTimings) {
        if (item is Map) {
          timings.add(
            OutletProductTimingModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return OutletProductModel(
      productId: _parseInt(json['productId']),
      productName: json['productName']?.toString(),
      description: json['description']?.toString(),
      merchantPrice: _parseNum(json['merchantPrice']),
      isVeg: _parseBool(json['isVeg']),
      hasProductVariants: _parseBool(json['hasProductVariants']),
      isAvailable: _parseBool(json['isAvailable']),
      price: _parseNum(json['price']),
      variants: variants,
      productTimings: timings,
    );
  }

  ProductModel toProductModel({required String categoryId}) {
    final merchant = merchantPrice ?? price ?? 0;
    final online = price ?? merchant;

    ItemAttribute? itemAttribute;
    if (variants.isNotEmpty) {
      itemAttribute = ItemAttribute(
        attributes: [],
        variants: variants
            .map(
              (v) => Variants(
                variantId: v.variantId?.toString(),
                variantSku: v.variantName,
                variantMerchantPrice: (v.merchantPrice ?? 0).toString(),
                variantPrice: (v.price ?? v.merchantPrice ?? 0).toString(),
              ),
            )
            .toList(),
      );
    }

    return ProductModel(
      id: productId?.toString(),
      name: productName,
      description: description,
      categoryID: categoryId,
      merchant_price: merchant.toString(),
      price: online.toString(),
      disPrice: '0',
      veg: isVeg ?? false,
      nonveg: !(isVeg ?? false),
      publish: true,
      isAvailable: isAvailable ?? true,
      availableTimings: _mapTimingsForUi(productTimings),
      itemAttribute: itemAttribute,
    );
  }

  static List<dynamic> _mapTimingsForUi(
    List<OutletProductTimingModel> timings,
  ) {
    if (timings.isEmpty) return [];

    final byDay = <String, List<Map<String, String>>>{};
    for (final timing in timings) {
      final day = timing.day?.trim() ?? '';
      if (day.isEmpty) continue;
      byDay.putIfAbsent(day, () => []).add({
        'from': _formatClock(timing.startTime),
        'to': _formatClock(timing.endTime),
      });
    }

    return byDay.entries
        .map(
          (entry) => {
            'day': entry.key,
            'timeslot': entry.value,
          },
        )
        .toList();
  }

  static String _formatClock(OutletClockModel? clock) {
    if (clock == null) return '00:00';
    final hour = (clock.hour ?? 0).clamp(0, 23);
    final minute = (clock.minute ?? 0).clamp(0, 59);
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }
}

class OutletProductVariantModel {
  final int? variantId;
  final String? variantName;
  final num? merchantPrice;
  final num? price;

  OutletProductVariantModel({
    this.variantId,
    this.variantName,
    this.merchantPrice,
    this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      if (variantId != null) 'variantId': variantId,
      if (variantName != null) 'variantName': variantName,
      if (merchantPrice != null) 'merchantPrice': merchantPrice,
      if (price != null) 'price': price,
    };
  }

  factory OutletProductVariantModel.fromJson(Map<String, dynamic> json) {
    return OutletProductVariantModel(
      variantId: _parseInt(json['variantId']),
      variantName: json['variantName']?.toString(),
      merchantPrice: _parseNum(json['merchantPrice']),
      price: _parseNum(json['price']),
    );
  }
}

class OutletProductTimingModel {
  final String? day;
  final OutletClockModel? startTime;
  final OutletClockModel? endTime;

  OutletProductTimingModel({
    this.day,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      if (day != null) 'day': day,
      if (startTime != null) 'startTime': startTime!.toJson(),
      if (endTime != null) 'endTime': endTime!.toJson(),
    };
  }

  factory OutletProductTimingModel.fromJson(Map<String, dynamic> json) {
    return OutletProductTimingModel(
      day: json['day']?.toString(),
      startTime: OutletClockModel.fromJson(json['startTime']),
      endTime: OutletClockModel.fromJson(json['endTime']),
    );
  }
}

class OutletClockModel {
  final int? hour;
  final int? minute;
  final int? second;
  final int? nano;

  OutletClockModel({
    this.hour,
    this.minute,
    this.second,
    this.nano,
  });

  Map<String, dynamic> toJson() {
    return {
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (second != null) 'second': second,
      if (nano != null) 'nano': nano,
    };
  }

  factory OutletClockModel.fromJson(dynamic json) {
    if (json is! Map) return OutletClockModel();
    return OutletClockModel(
      hour: _parseInt(json['hour']),
      minute: _parseInt(json['minute']),
      second: _parseInt(json['second']),
      nano: _parseInt(json['nano']),
    );
  }
}

class OutletProductsResult {
  final List<ProductModel> products;
  final List<VendorCategoryModel> categories;

  const OutletProductsResult({
    required this.products,
    required this.categories,
  });
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

num? _parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim());
  return null;
}

bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}
