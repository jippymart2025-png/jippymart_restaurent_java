
class VariantGroupModel {
  final int id;
  final String groupName;
  final String selectionType; // 'SINGLE' | 'MULTIPLE'
  final int minSelection;
  final int maxSelection;
  final int displayOrder;
  final bool isActive;

  VariantGroupModel({
    required this.id,
    required this.groupName,
    required this.selectionType,
    required this.minSelection,
    required this.maxSelection,
    required this.displayOrder,
    required this.isActive,
  });

  factory VariantGroupModel.fromJson(Map<String, dynamic> json) {
    return VariantGroupModel(
      id: json['productVariantGroupsId'] ?? 0,
      groupName: json['groupName'] ?? '',
      selectionType: json['selectionType'] ?? 'SINGLE',
      minSelection: json['minSelection'] ?? 0,
      maxSelection: json['maxSelection'] ?? 1,
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }
}


class VariantGroupValueModel {
  final int id;
  final int groupId;
  final String variantName;
  final bool isActive;

  VariantGroupValueModel({
    required this.id,
    required this.groupId,
    required this.variantName,
    required this.isActive,
  });
  factory VariantGroupValueModel.fromJson(Map<String, dynamic> json) {
    return VariantGroupValueModel(
      id: json['productVariantGroupValuesId'] ?? 0,
      groupId: json['productVariantGroupsId'] ?? 0,
      variantName: json['variantName'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productVariantGroupValuesId': id,
      'productVariantGroupsId': groupId,
      'variantName': variantName,
      'isActive': isActive,
    };
  }



}
class StagedVariantGroup {
  final int groupId;
  final String groupName;
  final List<StagedVariantOption> options;

  StagedVariantGroup({
    required this.groupId,
    required this.groupName,
    required this.options,
  });

  StagedVariantGroup copyWith({
    int? groupId,
    String? groupName,
    List<StagedVariantOption>? options,
  }) {
    return StagedVariantGroup(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      options: options ?? this.options,
    );
  }
}

class StagedVariantOption {
  final int productVariantOptionsId;
  final int productVariantGroupValuesId;
  final String variantName;
  final String priceType;
  final double variantPrice;

  StagedVariantOption({
    this.productVariantOptionsId = 0,
    required this.productVariantGroupValuesId,
    required this.variantName,
    this.priceType = "MAIN",
    this.variantPrice = 0.0,
  });

  StagedVariantOption copyWith({
    int? productVariantOptionsId,
    int? productVariantGroupValuesId,
    String? variantName,
    String? priceType,
    double? variantPrice,
  }) {
    return StagedVariantOption(
      productVariantOptionsId:
      productVariantOptionsId ?? this.productVariantOptionsId,
      productVariantGroupValuesId:
      productVariantGroupValuesId ??
          this.productVariantGroupValuesId,
      variantName: variantName ?? this.variantName,
      priceType: priceType ?? this.priceType,
      variantPrice: variantPrice ?? this.variantPrice,
    );
  }
}