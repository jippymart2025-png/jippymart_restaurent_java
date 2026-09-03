class ProductVariantValueModel {
  final int productVariantGroupValuesId;
  final int productVariantGroupsId;
  final String variantName;
  final bool isActive;

  ProductVariantValueModel({
    required this.productVariantGroupValuesId,
    required this.productVariantGroupsId,
    required this.variantName,
    required this.isActive,
  });

  factory ProductVariantValueModel.fromJson(
      Map<String, dynamic> json) {
    return ProductVariantValueModel(
      productVariantGroupValuesId:
      json['productVariantGroupValuesId'] ?? 0,
      productVariantGroupsId:
      json['productVariantGroupsId'] ?? 0,
      variantName:
      json['variantName']?.toString() ?? '',
      isActive:
      json['isActive'] ?? false,
    );
  }
}