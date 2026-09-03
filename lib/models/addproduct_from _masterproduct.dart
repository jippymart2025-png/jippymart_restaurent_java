class AddProductsFromMasterRequest {
  final int outletId;
  final int categoryId;
  final List<AddProductFromMasterItem> products;

  AddProductsFromMasterRequest({
    required this.outletId,
    required this.categoryId,
    required this.products,
  });

  Map<String, dynamic> toJson() {
    return {
      "outletId": outletId,
      "categoryId": categoryId,
      "products": products.map((e) => e.toJson()).toList(),
    };
  }
}

class AddProductFromMasterItem {
  final int masterProductId;
  final String productName;
  final String description;
  final bool isVeg;
  final bool hasProductVariants;
  final double merchantPrice;
  //final String imageLink;
  final String csvTiming;
  final String csvDayOfWeek;
  final List<ProductTimingRequest> timings;
  final List<VariantGroupRequest> variantGroups;

  AddProductFromMasterItem({
    required this.masterProductId,
    required this.productName,
    required this.description,
    required this.isVeg,
    required this.hasProductVariants,
    required this.merchantPrice,
    //required this.imageLink,
    required this.csvTiming,
    required this.csvDayOfWeek,
    required this.timings,
    required this.variantGroups,
  });

  Map<String, dynamic> toJson() {
    return {
      "masterProductId": masterProductId,
      "productName": productName,
      "description": description,
      "isVeg": isVeg,
      "hasProductVariants": hasProductVariants,
      "merchantPrice": merchantPrice,
      //"imageLink": imageLink,
      "csvTiming": csvTiming,
      "csvDayOfWeek": csvDayOfWeek,
      "timings": timings.map((e) => e.toJson()).toList(),
      "variantGroups": variantGroups.map((e) => e.toJson()).toList(),
    };
  }
}

class ProductTimingRequest {
  final int productAvailableTimingId;
  final int dayOfWeekId;
  final String startTime;
  final String endTime;

  ProductTimingRequest({
    required this.productAvailableTimingId,
    required this.dayOfWeekId,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      "productAvailableTimingId": productAvailableTimingId,
      "dayOfWeekId": dayOfWeekId,
      "startTime": startTime,
      "endTime": endTime,
    };
  }
}

class VariantGroupRequest {
  final int productVariantGroupsId;
  final List<VariantOptionRequest> options;

  VariantGroupRequest({
    required this.productVariantGroupsId,
    required this.options,
  });

  Map<String, dynamic> toJson() {
    return {
      "productVariantGroupsId": productVariantGroupsId,
      "options": options.map((e) => e.toJson()).toList(),
    };
  }
}

class VariantOptionRequest {
  final int productVariantOptionsId;
  final int productVariantGroupValuesId;
  final String priceType;
  final double variantPrice;

  VariantOptionRequest({
    required this.productVariantOptionsId,
    required this.productVariantGroupValuesId,
    required this.priceType,
    required this.variantPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      "productVariantOptionsId": productVariantOptionsId,
      "productVariantGroupValuesId": productVariantGroupValuesId,
      "priceType": priceType,
      "variantPrice": variantPrice,
    };
  }
}
class AddProductsFromMasterResponse {
  final int savedCount;
  final int skippedCount;
  final List<String> savedNames;
  final List<String> skippedNames;

  AddProductsFromMasterResponse({
    this.savedCount = 0,
    this.skippedCount = 0,
    this.savedNames = const [],
    this.skippedNames = const [],
  });

  factory AddProductsFromMasterResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return AddProductsFromMasterResponse(
      savedCount: _parseInt(json['savedCount']),
      skippedCount: _parseInt(json['skippedCount']),
      savedNames: _parseStringList(json['savedNames']),
      skippedNames: _parseStringList(json['skippedNames']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Useful for your UI where the old code expected `message`.
  String get message {
    if (savedCount > 0 && skippedCount == 0) {
      return 'Saved $savedCount product(s) successfully.';
    }

    if (savedCount > 0 && skippedCount > 0) {
      return 'Saved $savedCount product(s), skipped $skippedCount product(s).';
    }

    if (savedCount == 0 && skippedCount > 0) {
      return 'All $skippedCount product(s) were skipped.';
    }

    return 'No products were saved.';
  }

  /// Keeps compatibility with your existing screen code.
  List<String> get errors => skippedNames;
}