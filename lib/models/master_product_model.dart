/// Model for a product from the master catalog (GET /api/foods/master-products).
/// When is_existing is true, vendor_* fields are populated.
class MasterProductModel {
  String? id;
  String? name;
  String? description;
  String? photo;
  String? categoryId;
  String? categoryName;
  double? suggestedPrice;
  bool? nonveg;
  bool? veg;
  bool? isExisting;

  /// Master product options (size/variant options).
  List<MasterProductOption>? options;

  // --- When is_existing == true (vendor already has this product) ---
  String? vendorProductId;
  String? vendorPrice;
  String? vendorMerchantPrice;
  String? vendorDisPrice;
  bool? vendorPublish;
  bool? vendorIsAvailable;
  List<String>? vendorAddOnsTitle;
  List<String>? vendorAddOnsPrice;
  List<String>? vendorAvailableDays;
  List<VendorTimingSlot>? vendorAvailableTimings;
  List<VendorOptionOverride>? vendorOptions;

  MasterProductModel({
    this.id,
    this.name,
    this.description,
    this.categoryId,
    this.categoryName,
    this.photo,
    this.suggestedPrice,
    this.nonveg,
    this.veg,
    this.isExisting,
    this.options,
    this.vendorProductId,
    this.vendorPrice,
    this.vendorMerchantPrice,
    this.vendorDisPrice,
    this.vendorPublish,
    this.vendorIsAvailable,
    this.vendorAddOnsTitle,
    this.vendorAddOnsPrice,
    this.vendorAvailableDays,
    this.vendorAvailableTimings,
    this.vendorOptions,
  });

//   factory MasterProductModel.fromJson(Map<String, dynamic> json) {
//     final opt = json['options'];
//     List<MasterProductOption>? opts;
//     if (opt is List) {
//       opts = opt.map((e) => MasterProductOption.fromJson(Map<String, dynamic>.from(e as Map))).toList();
//     }
//
//     final vOpts = json['vendor_options'];
//     List<VendorOptionOverride>? vOptionsList;
//     if (vOpts is List) {
//       vOptionsList = vOpts.map((e) => VendorOptionOverride.fromJson(Map<String, dynamic>.from(e as Map))).toList();
//     }
//
//     final vTimings = json['vendor_available_timings'];
//     List<VendorTimingSlot>? timingsList;
//     if (vTimings is List) {
//       timingsList = vTimings.map((e) => VendorTimingSlot.fromJson(Map<String, dynamic>.from(e as Map))).toList();
//     }
//
//     List<String>? addOnsTitle;
//     if (json['vendor_addOnsTitle'] is List) {
//       addOnsTitle = (json['vendor_addOnsTitle'] as List).map((e) => e.toString()).toList();
//     }
//     List<String>? addOnsPrice;
//     if (json['vendor_addOnsPrice'] is List) {
//       addOnsPrice = (json['vendor_addOnsPrice'] as List).map((e) => e.toString()).toList();
//     }
//     List<String>? days;
//     if (json['vendor_available_days'] is List) {
//       days = (json['vendor_available_days'] as List).map((e) => e.toString()).toList();
//     }
//
//     return MasterProductModel(
//       id: json['id']?.toString(),
//       name: json['name']?.toString(),
//       description: json['description']?.toString(),
//       photo: json['photo']?.toString(),
//       suggestedPrice: _toDouble(json['suggested_price']),
//       nonveg: json['nonveg'] == true || json['nonveg'] == 1,
//       veg: json['veg'] == true || json['veg'] == 1,
//       isExisting: json['is_existing'] == true || json['is_existing'] == 1,
//       options: opts,
//       vendorProductId: json['vendor_product_id']?.toString(),
//       vendorPrice: json['vendor_price']?.toString(),
//       vendorMerchantPrice: (json['vendor_merchantPrice'] ?? json['vendor_merchant_price'])?.toString(),
//       vendorDisPrice: (json['vendor_disPrice'] ?? json['vendor_dis_price'])?.toString(),
//       vendorPublish: json['vendor_publish'] == true || json['vendor_publish'] == 1,
//       vendorIsAvailable: json['vendor_isAvailable'] == true || json['vendor_isAvailable'] == 1,
//       vendorAddOnsTitle: addOnsTitle,
//       vendorAddOnsPrice: addOnsPrice,
//       vendorAvailableDays: days,
//       vendorAvailableTimings: timingsList,
//       vendorOptions: vOptionsList,
//     );
//   }
//

  factory MasterProductModel.fromJson(
      Map<String, dynamic> json) {
    return MasterProductModel(
      id: json['masterProductId']?.toString(),
      name: json['masterProductName']?.toString(),
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),

      photo: json['photo']?.toString(),
      description: '',

      veg: json['veg'] == 1 ||
          json['veg'] == true,

      nonveg: json['nonVeg'] == 1 ||
          json['nonVeg'] == true,

      vendorPublish:
      json['publish'] == 1 ||
          json['publish'] == true,

      isExisting: false,
      suggestedPrice: null,

      options: [],
      vendorOptions: [],
      vendorAvailableTimings: [],
      vendorAvailableDays: [],
      vendorAddOnsTitle: [],
      vendorAddOnsPrice: [],
    );
  }


  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class MasterProductOption {
  String? id;
  String? title;
  String? subtitle;
  num? price;

  MasterProductOption({this.id, this.title, this.subtitle, this.price});

  factory MasterProductOption.fromJson(Map<String, dynamic> json) {
    return MasterProductOption(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      price: json['price'] is num ? json['price'] : num.tryParse(json['price']?.toString() ?? ''),
    );
  }
}

/// Vendor override for an option (when is_existing).
class VendorOptionOverride {
  String? id;
  String? title;
  String? price;
  bool? isAvailable;

  VendorOptionOverride({this.id, this.title, this.price, this.isAvailable});

  factory VendorOptionOverride.fromJson(Map<String, dynamic> json) {
    return VendorOptionOverride(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      price: json['price']?.toString(),
      isAvailable: json['is_available'] == true || json['is_available'] == 1,
    );
  }
}

class VendorTimingSlot {
  String? day;
  List<TimeRange>? timeslot;

  VendorTimingSlot({this.day, this.timeslot});

  factory VendorTimingSlot.fromJson(Map<String, dynamic> json) {
    List<TimeRange>? slots;
    final ts = json['timeslot'];
    if (ts is List) {
      slots = ts.map((e) => TimeRange.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    return VendorTimingSlot(day: json['day']?.toString(), timeslot: slots);
  }
}

class TimeRange {
  String? from;
  String? to;

  TimeRange({this.from, this.to});

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(from: json['from']?.toString(), to: json['to']?.toString());
  }
}
