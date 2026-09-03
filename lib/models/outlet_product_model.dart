// models/outlet_single_product_model.dart

class OutletSingleProductModel {
  final int? productId;
  final int? outletCategoryId;
  final String? productName;
  final String? description;
  final bool? isVeg;
  final bool? hasProductVariants;
  final num? merchantPrice;
  final String? imageLink;
  final String? photos;
  final String? thumbnail;
  final List<ProductTimingModel> timings;
  final List<ProductVariantGroupModel> variantGroups;

  OutletSingleProductModel({
    this.productId,
    this.outletCategoryId,
    this.productName,
    this.description,
    this.isVeg,
    this.hasProductVariants,
    this.merchantPrice,
    this.imageLink,
    this.photos,
    this.thumbnail,
    this.timings = const [],
    this.variantGroups = const [],
  });

  /// Parses the full GET response.
  factory OutletSingleProductModel.fromJson(Map<String, dynamic> json) {
    return OutletSingleProductModel(
      productId: json['productId'] is int
          ? json['productId']
          : int.tryParse(json['productId']?.toString() ?? ''),
      outletCategoryId: json['outletCategoryId'] is int
          ? json['outletCategoryId']
          : int.tryParse(json['outletCategoryId']?.toString() ?? ''),
      productName: json['productName']?.toString(),
      description: json['description']?.toString(),
      isVeg: json['isVeg'] == true,
      hasProductVariants: json['hasProductVariants'] == true,
      merchantPrice: json['merchantPrice'] is num
          ? json['merchantPrice']
          : num.tryParse(json['merchantPrice']?.toString() ?? ''),
      imageLink: json['imageLink']?.toString(),
      photos: json['photos']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      timings: (json['timings'] as List<dynamic>? ?? [])
          .map((e) => ProductTimingModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      variantGroups: (json['variantGroups'] as List<dynamic>? ?? [])
          .map((e) => ProductVariantGroupModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  /// Builds the PUT body — only fields updateCategoryAndProductDetails accepts.
  /// Edited scalar fields are passed in explicitly; timings/variantGroups
  /// are carried over from what was loaded (or replaced if the UI supports
  /// editing them later).
  Map<String, dynamic> toUpdateJson({
    required String productName,
    required int outletCategoryId,
    required String description,
    required bool isVeg,
    required bool hasProductVariants,
    required num merchantPrice,
    required String imageLink,
    String? photos,
    String? thumbnail,
    List<ProductTimingModel>? timingsOverride,
    List<ProductVariantGroupModel>? variantGroupsOverride,
  }) {
    return {
      "productName": productName,
      "outletCategoryId": outletCategoryId,
      "description": description,
      "isVeg": isVeg,
      "hasProductVariants": hasProductVariants,
      "merchantPrice": merchantPrice,
      "imageLink": imageLink,
      "photos": photos ?? this.photos,
      "thumbnail": thumbnail ?? this.thumbnail,
      "timings": (timingsOverride ?? timings).map((t) => t.toUpdateJson()).toList(),
      "variantGroups":
          (variantGroupsOverride ?? variantGroups).map((g) => g.toUpdateJson()).toList(),
    };
  }
}

class ProductTimingModel {
  final int? productAvailableTimingId;
  final int? dayOfWeekId;
  final String? dayName; // read-only, GET only
  final String? startTime;
  final String? endTime;

  ProductTimingModel({
    this.productAvailableTimingId,
    this.dayOfWeekId,
    this.dayName,
    this.startTime,
    this.endTime,
  });

  factory ProductTimingModel.fromJson(Map<String, dynamic> json) {
    return ProductTimingModel(
      productAvailableTimingId: json['productAvailableTimingId'] is int
          ? json['productAvailableTimingId']
          : int.tryParse(json['productAvailableTimingId']?.toString() ?? ''),
      dayOfWeekId: json['dayOfWeekId'] is int
          ? json['dayOfWeekId']
          : int.tryParse(json['dayOfWeekId']?.toString() ?? ''),
      dayName: json['dayName']?.toString(),
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
    );
  }

  /// PUT shape — no dayName (server-derived).
  Map<String, dynamic> toUpdateJson() {
    return {
      "productAvailableTimingId": productAvailableTimingId,
      "dayOfWeekId": dayOfWeekId,
      "startTime": startTime,
      "endTime": endTime,
    };
  }
}

class ProductVariantGroupModel {
  final int? productVariantGroupsId;
  final String? groupName; // read-only, GET only
  final String? selectionType; // read-only, GET only
  final int? minSelection; // read-only, GET only
  final int? maxSelection; // read-only, GET only
  final int? displayOrder; // read-only, GET only
  final List<ProductVariantOptionModel> options;

  ProductVariantGroupModel({
    this.productVariantGroupsId,
    this.groupName,
    this.selectionType,
    this.minSelection,
    this.maxSelection,
    this.displayOrder,
    this.options = const [],
  });

  factory ProductVariantGroupModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantGroupModel(
      productVariantGroupsId: json['productVariantGroupsId'] is int
          ? json['productVariantGroupsId']
          : int.tryParse(json['productVariantGroupsId']?.toString() ?? ''),
      groupName: json['groupName']?.toString(),
      selectionType: json['selectionType']?.toString(),
      minSelection: json['minSelection'] is int
          ? json['minSelection']
          : int.tryParse(json['minSelection']?.toString() ?? ''),
      maxSelection: json['maxSelection'] is int
          ? json['maxSelection']
          : int.tryParse(json['maxSelection']?.toString() ?? ''),
      displayOrder: json['displayOrder'] is int
          ? json['displayOrder']
          : int.tryParse(json['displayOrder']?.toString() ?? ''),
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => ProductVariantOptionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  /// PUT shape — only id + options (no groupName/selectionType/min/max/order).
  Map<String, dynamic> toUpdateJson() {
    return {
      "productVariantGroupsId": productVariantGroupsId,
      "options": options.map((o) => o.toUpdateJson()).toList(),
    };
  }
}

class ProductVariantOptionModel {
  final int? productVariantOptionsId;
  final int? productVariantGroupValuesId;
  final String? variantName; // read-only, GET only
  final String? priceType;
  final num? variantPrice;

  ProductVariantOptionModel({
    this.productVariantOptionsId,
    this.productVariantGroupValuesId,
    this.variantName,
    this.priceType,
    this.variantPrice,
  });

  factory ProductVariantOptionModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantOptionModel(
      productVariantOptionsId: json['productVariantOptionsId'] is int
          ? json['productVariantOptionsId']
          : int.tryParse(json['productVariantOptionsId']?.toString() ?? ''),
      productVariantGroupValuesId: json['productVariantGroupValuesId'] is int
          ? json['productVariantGroupValuesId']
          : int.tryParse(json['productVariantGroupValuesId']?.toString() ?? ''),
      variantName: json['variantName']?.toString(),
      priceType: json['priceType']?.toString(),
      variantPrice: json['variantPrice'] is num
          ? json['variantPrice']
          : num.tryParse(json['variantPrice']?.toString() ?? ''),
    );
  }

  /// PUT shape — no variantName.
  Map<String, dynamic> toUpdateJson() {
    return {
      "productVariantOptionsId": productVariantOptionsId,
      "productVariantGroupValuesId": productVariantGroupValuesId,
      "priceType": priceType,
      "variantPrice": variantPrice,
    };
  }
}