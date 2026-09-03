class ProductVariantGroupModel {
  final int productVariantGroupsId;
  final String groupName;
  final String selectionType;
  final int minSelection;
  final int maxSelection;
  final int displayOrder;
  final bool isActive;

  ProductVariantGroupModel({
    required this.productVariantGroupsId,
    required this.groupName,
    required this.selectionType,
    required this.minSelection,
    required this.maxSelection,
    required this.displayOrder,
    required this.isActive,
  });

  factory ProductVariantGroupModel.fromJson(
      Map<String, dynamic> json) {
    return ProductVariantGroupModel(
      productVariantGroupsId:
      json['productVariantGroupsId'] ?? 0,
      groupName: json['groupName']?.toString() ?? '',
      selectionType:
      json['selectionType']?.toString() ?? '',
      minSelection: json['minSelection'] ?? 0,
      maxSelection: json['maxSelection'] ?? 0,
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }
}