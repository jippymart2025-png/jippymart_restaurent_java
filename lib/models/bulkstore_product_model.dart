class BulkStoreProductModel {
  final int outletId;
  final int outletCategoryId;
  final List<BulkStoreProductItemModel> products;

  BulkStoreProductModel({
    required this.outletId,
   required this.outletCategoryId,
    required this.products,
  });

  Map<String, dynamic> toJson() {
    return {
      "outletId": outletId,
      "outletCategoryId": outletCategoryId,
      "products": products.map((e) => e.toJson()).toList(),
    };
  }
}

class BulkStoreProductItemModel {
  final String productName;
  final String description;
  final double merchantPrice;
  final bool isVeg;
  final bool hasProductVariants;
  final List<dynamic> variants;
  final int masterProductId;
  final int categoryId;

  BulkStoreProductItemModel({
    required this.productName,
    required this.description,
    required this.merchantPrice,
    required this.isVeg,
    required this.hasProductVariants,
    required this.variants,
    required this.masterProductId,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      "productName": productName,
      "description": description,
      "merchantPrice": merchantPrice,
      "isVeg": isVeg,
      "hasProductVariants": hasProductVariants,
      "variants": variants,
      "masterProductId": masterProductId,
      "categoryId": categoryId,
      "csvDayOfWeek": "MONDAY",
      "csvTiming": "09:00-22:00",
      "timings": [
        {
          "dayOfWeekId": 1,
          "startTime": "09:00",
          "endTime": "22:00",
        }
      ]
    };
  }
}
class TimingRequest {
  int dayOfWeekId;
  String startTime;
  String endTime;

  TimingRequest({
    required this.dayOfWeekId,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      "dayOfWeekId": dayOfWeekId,
      "startTime": startTime,
      "endTime": endTime,
    };
  }
}