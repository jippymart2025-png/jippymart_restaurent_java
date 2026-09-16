import 'dart:convert';

// ─────────────────────────────────────────────────────────────────────────────
// Supporting models
// ─────────────────────────────────────────────────────────────────────────────

class AddonItem {
  String title;
  String price;
  AddonItem({required this.title, required this.price});
}

/// One from/to slot inside a day.
/// Serializes to: {"productAvailableTimingId":0,"from":"11:00","to":"22:00"}
class TimeRangeItem {
  int productAvailableTimingId;
  String from; // HH:MM
  String to;   // HH:MM

  TimeRangeItem({
    this.productAvailableTimingId = 0,
    required this.from,
    required this.to,
  });

  Map<String, dynamic> toJson() => {
    'productAvailableTimingId': productAvailableTimingId,
    'from': from,
    'to': to,
  };
}

/// One product option / variant.
class OptionItem {
  String id;
  String title;
  String? subtitle;
  String price;
  String? originalPrice;
  bool isAvailable;
  bool isFeatured;

  // ✅ IDs used for Java variant group payload
  int productVariantOptionsId;
  int productVariantGroupValuesId;
  int productVariantGroupsId;

  OptionItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.price,
    this.originalPrice,
    this.isAvailable = true,
    this.isFeatured = false,
    this.productVariantOptionsId = 0,
    this.productVariantGroupValuesId = 0,
    this.productVariantGroupsId = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle ?? '',
    'price': price,
    'original_price': originalPrice ?? price,
    'is_available': isAvailable,
    'is_featured': isFeatured,
  };

  factory OptionItem.fromJson(Map<String, dynamic> json) => OptionItem(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    subtitle: json['subtitle']?.toString(),
    price: json['price']?.toString() ?? '0',
    originalPrice: json['original_price']?.toString(),
    isAvailable: json['is_available'] as bool? ?? true,
    isFeatured: json['is_featured'] as bool? ?? false,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Main selection model
// ─────────────────────────────────────────────────────────────────────────────

/// In-memory model for a product selected in the "Add from catalog" flow.
class SelectedProductModel {
  String masterProductId;
  String? vendorProductId;

  double merchantPrice;
  double onlinePrice;
  double discountPrice;
  bool publish;
  bool isAvailable;

  // ✅ Extra fields used by the new Java endpoint
  String? productName;
  String? description;
  String? categoryId;
  String? categoryName;
  String? imageLink;
  bool? isVeg;
  bool hasProductVariants;

  List<AddonItem> addons;
  List<String> availableDays;
  Map<String, List<TimeRangeItem>> availableTimings;
  List<OptionItem> options;

  SelectedProductModel({
    required this.masterProductId,
    this.productName,
    this.description,
    this.categoryId,
    this.categoryName,
    this.imageLink,
    this.isVeg,
    this.hasProductVariants = false,
    this.vendorProductId,
    required this.merchantPrice,
    required this.onlinePrice,
    this.discountPrice = 0,
    this.publish = true,
    this.isAvailable = true,
    List<AddonItem>? addons,
    List<String>? availableDays,
    Map<String, List<TimeRangeItem>>? availableTimings,
    List<OptionItem>? options,
  })  : addons = addons ?? [],
        availableDays = availableDays ?? [],
        availableTimings = availableTimings ?? {},
        options = options ?? [];

  // ── Convenience mutators ────────────────────────────────────────────────

  void addAddon(String title, String price) =>
      addons.add(AddonItem(title: title, price: price));

  void removeAddonAt(int index) {
    if (index >= 0 && index < addons.length) addons.removeAt(index);
  }

  // ── Serialization helpers ───────────────────────────────────────────────

  /// [{"day":"Monday","timeslot":[{"from":"11:00","to":"22:00"}]}, ...]
  List<Map<String, dynamic>> get availabilityJson => availableDays
      .map((day) => {
    'day': day,
    'timeslot':
    (availableTimings[day] ?? []).map((t) => t.toJson()).toList(),
  })
      .toList();

  /// Only available options are sent to backend.
  List<Map<String, dynamic>> get optionsJson =>
      options.where((o) => o.isAvailable).map((o) => o.toJson()).toList();
}