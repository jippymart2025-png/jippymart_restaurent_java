class SubscriptionPlanModel {
  final int subscriptionPlanId;
  final String planName;
  final num price;
  final int durationInDays;
  final int bannerDurationInDays;
  final num radiusInKms;
  final int bannerSlot;
  final int bestRestaurantSlot;
  final int dealsSlot;
  final String? whatsappBroadcast;
  final String? videoCredits;
  final int? stateId;
  final int? cityId;
  final int? areaId;

  SubscriptionPlanModel({
    required this.subscriptionPlanId,
    required this.planName,
    required this.price,
    required this.durationInDays,
    required this.bannerDurationInDays,
    required this.radiusInKms,
    required this.bannerSlot,
    required this.bestRestaurantSlot,
    required this.dealsSlot,
    this.whatsappBroadcast,
    this.videoCredits,
    this.stateId,
    this.cityId,
    this.areaId,
  });

  factory SubscriptionPlanModel.fromJson(
      Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      subscriptionPlanId:
      json['subscriptionPlanId'] ?? 0,
      planName: json['planName'] ?? '',
      price: json['price'] ?? 0,
      durationInDays:
      json['durationInDays'] ?? 0,
      bannerDurationInDays:
      json['bannerDurationInDays'] ?? 0,
      radiusInKms:
      json['radiusInKms'] ?? 0,
      bannerSlot:
      json['bannerSlot'] ?? 0,
      bestRestaurantSlot:
      json['bestRestaurantSlot'] ?? 0,
      dealsSlot:
      json['dealsSlot'] ?? 0,
      whatsappBroadcast:
      json['whatsappBroadcast']
          ?.toString(),
      videoCredits:
      json['videoCredits']
          ?.toString(),
      stateId: json['stateId'],
      cityId: json['cityId'],
      areaId: json['areaId'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'subscriptionPlanId': subscriptionPlanId,
      'planName': planName,
      'price': price,
      'durationInDays': durationInDays,
      'bannerDurationInDays': bannerDurationInDays,
      'radiusInKms': radiusInKms,
      'bannerSlot': bannerSlot,
      'bestRestaurantSlot': bestRestaurantSlot,
      'dealsSlot': dealsSlot,
      'whatsappBroadcast': whatsappBroadcast,
      'videoCredits': videoCredits,
      'stateId': stateId,
      'cityId': cityId,
      'areaId': areaId,
    };
  }
}