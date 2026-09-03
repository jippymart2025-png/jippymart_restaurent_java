class PromotionCountsModel {
  final int active;
  final int scheduled;
  final int ended;
  final int total;

  PromotionCountsModel({
    this.active = 0,
    this.scheduled = 0,
    this.ended = 0,
    this.total = 0,
  });

  factory PromotionCountsModel.fromJson(Map<String, dynamic> json) {
    return PromotionCountsModel(
      active: (json['active'] as num?)?.toInt() ?? 0,
      scheduled: (json['scheduled'] as num?)?.toInt() ?? 0,
      ended: (json['ended'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class PromotionOutletProductModel {
  final int productId;
  final String productName;
  final int outletCategoryId;
  final String categoryName;

  PromotionOutletProductModel({
    required this.productId,
    required this.productName,
    required this.outletCategoryId,
    required this.categoryName,
  });

  factory PromotionOutletProductModel.fromJson(Map<String, dynamic> json) {
    return PromotionOutletProductModel(
      productId: json['productId'] is int
          ? json['productId']
          : int.tryParse(json['productId']?.toString() ?? '') ?? 0,
      productName: json['productName']?.toString() ?? '',
      outletCategoryId: json['outletCategoryId'] is int
          ? json['outletCategoryId']
          : int.tryParse(json['outletCategoryId']?.toString() ?? '') ?? 0,
      categoryName: json['categoryName']?.toString() ?? '',
    );
  }
}
class PromotionApiResult {
  final bool success;
  final String message;

  PromotionApiResult({required this.success, required this.message});
}

class PromotionPlanTypeModel {
  final int promotionPlanTypesId;
  final String planName;

  PromotionPlanTypeModel({
    required this.promotionPlanTypesId,
    required this.planName,
  });

  factory PromotionPlanTypeModel.fromJson(Map<String, dynamic> json) {
    return PromotionPlanTypeModel(
      promotionPlanTypesId: (json['promotionPlanTypesId'] ?? json['id'] ?? 0) as int,
      planName: (json['planName'] ?? json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'promotionPlanTypesId': promotionPlanTypesId,
    'planName': planName,
  };
}
class PromotionPlanModel {
  final int? promotionPlanId;
  final int? outletId;
  final int? promotionPlanTypeId;
  final String? promotionPlanType;
  final String planStartDate;
  final String planEndDate;
  final String planStartTime;
  final String planEndTime;
  final String offerName;
  final double minimumOrderValue;
  final double offerAmount;
  final String offerType;
  final List<int> productIds;
  final List<int> outletCategoryIds;
  final int maxSelection;
  final String status;

  PromotionPlanModel({
    this.promotionPlanId,
    this.outletId,
    this.promotionPlanTypeId,
    this.promotionPlanType,
    required this.planStartDate,
    required this.planEndDate,
    required this.planStartTime,
    required this.planEndTime,
    required this.offerName,
    required this.minimumOrderValue,
    required this.offerAmount,
    required this.offerType,
    required this.productIds,
    required this.outletCategoryIds,
    this.maxSelection = -1,
    this.status = 'ACTIVE',
  });

  factory PromotionPlanModel.fromJson(Map<String, dynamic> json) {
    String parseTime(dynamic timeVal) {
      if (timeVal == null) return '00:00:00';
      if (timeVal is String) return timeVal;
      if (timeVal is Map) {
        final h = (timeVal['hour'] ?? 0).toString().padLeft(2, '0');
        final m = (timeVal['minute'] ?? 0).toString().padLeft(2, '0');
        final s = (timeVal['second'] ?? 0).toString().padLeft(2, '0');
        return '$h:$m:$s';
      }
      return '00:00:00';
    }

    return PromotionPlanModel(
      promotionPlanId: json['promotionPlanId'],
      outletId: json['outletId'],
      promotionPlanTypeId: json['promotionPlanTypeId'],
      promotionPlanType: json['promotionPlanType'] ?? '',
      planStartDate: json['planStartDate'] ?? '',
      planEndDate: json['planEndDate'] ?? '',
      planStartTime: parseTime(json['planStartTime']),
      planEndTime: parseTime(json['planEndTime']),
      offerName: json['offerName'] ?? '',
      minimumOrderValue: (json['minimumOrderValue'] as num?)?.toDouble() ?? 0.0,
      offerAmount: (json['offerAmount'] as num?)?.toDouble() ?? 0.0,
      offerType: json['offerType'] ?? 'FLAT',
      productIds: List<int>.from(json['productIds'] ?? []),
      outletCategoryIds: List<int>.from(json['outletCategoryIds'] ?? []),
      maxSelection: json['maxSelection'] ?? -1,
      status: (json['status'] ?? 'ACTIVE').toString().toUpperCase(),
    );
  }
  Map<String, dynamic> toCreateUpdateJson() {
    // Format time strictly to "HH:mm:ss"
    String formatTimeString(String time) {
      if (time.trim().isEmpty) return "00:00:00";
      final parts = time.split(':');
      final h = parts.isNotEmpty ? parts[0].padLeft(2, '0') : '00';
      final m = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
      final s = parts.length > 2 ? parts[2].padLeft(2, '0') : '00';
      return "$h:$m:$s";
    }

    // Normalize offerType to match the backend enum


    return {
      'outletId': outletId,
      'promotionPlanTypeId': promotionPlanTypeId,
      'planStartDate': planStartDate,
      'planEndDate': planEndDate,
      'planStartTime': formatTimeString(planStartTime), // Outputs "10:00:00"
      'planEndTime': formatTimeString(planEndTime),     // Outputs "22:00:00"
      'offerName': offerName,
      'minimumOrderValue': minimumOrderValue.round(),
      'offerAmount': offerAmount.round(),
      'offerType':offerType,
      'productIds': productIds,
      'outletCategoryIds': outletCategoryIds,
      'maxSelection': maxSelection,
    };
  }
}