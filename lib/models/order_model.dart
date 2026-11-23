import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jippymart_restaurant/models/cart_product_model.dart';
import 'package:jippymart_restaurant/models/tax_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';

class OrderModel {
  ShippingAddress? address;
  String? status;
  String? couponId;
  String? vendorID;
  String? driverID;
  num? discount;
  num? merchant_price;
  String? authorID;
  String? estimatedTimeToPrepare;
  Timestamp? createdAt;
  Timestamp? triggerDelivery;
  List<TaxModel>? taxSetting;
  String? paymentMethod;
  List<CartProductModel>? products;
  String? adminCommissionType;
  VendorModel? vendor;
  String? id;
  String? adminCommission;
  String? couponCode;
  Map<String, dynamic>? specialDiscount;
  String? deliveryCharge;
  Timestamp? scheduleTime;
  String? tipAmount;
  String? notes;
  UserModel? author;
  UserModel? driver;
  bool? takeAway;
  bool? isCutleryRequired;
  num? totalPrice;
  List<dynamic>? rejectedByDrivers;

  OrderModel({
    this.address,
    this.status,
    this.couponId,
    this.vendorID,
    this.driverID,
    this.discount,
    this.merchant_price,
    this.authorID,
    this.estimatedTimeToPrepare,
    this.createdAt,
    this.triggerDelivery,
    this.taxSetting,
    this.paymentMethod,
    this.products,
    this.adminCommissionType,
    this.vendor,
    this.id,
    this.adminCommission,
    this.couponCode,
    this.specialDiscount,
    this.deliveryCharge,
    this.scheduleTime,
    this.tipAmount,
    this.notes,
    this.author,
    this.driver,
    this.takeAway,
    this.isCutleryRequired,
    this.totalPrice,
    this.rejectedByDrivers,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      return OrderModel(
        address: _parseAddress(json['address']),
        status: json['status']?.toString(),
        couponId: json['couponId']?.toString(),
        vendorID: json['vendorID']?.toString(),
        driverID: json['driverID']?.toString(),
        discount: _parseNumber(json['discount']),
        merchant_price: _parseNumber(json['merchant_price']),
        authorID: json['authorID']?.toString(),
        estimatedTimeToPrepare: json['estimatedTimeToPrepare']?.toString(),
        createdAt: _parseTimestamp(json['createdAt']),
        triggerDelivery: _parseTimestamp(json['triggerDelivery']),
        taxSetting: _parseTaxSetting(json['taxSetting']),
        paymentMethod: json['payment_method']?.toString(),
        products: _parseProducts(json['products']),
        adminCommissionType: json['adminCommissionType']?.toString(),
        vendor: _parseVendor(json['vendor']),
        id: json['id']?.toString(),
        adminCommission: json['adminCommission']?.toString(),
        couponCode: json['couponCode']?.toString(),
        specialDiscount: _parseSpecialDiscount(json['specialDiscount']),
        deliveryCharge: _parseDeliveryCharge(json['deliveryCharge']),
        scheduleTime: _parseTimestamp(json['scheduleTime']),
        tipAmount: _parseTipAmount(json['tip_amount']),
        notes: json['notes']?.toString(),
        author: _parseUser(json['author']),
        driver: _parseUser(json['driver']),
        takeAway: json['takeAway'] is bool ? json['takeAway'] : false,
        isCutleryRequired: json['isCutleryRequired'] is bool
            ? json['isCutleryRequired']
            : null,
        totalPrice: json['totalPrice'] == null
            ? null
            : _parseNumber(json['totalPrice']),
        rejectedByDrivers: json['rejectedByDrivers'] is List ? json['rejectedByDrivers'] : [],
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing OrderModel: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  // Helper methods for parsing
  static ShippingAddress? _parseAddress(dynamic addressData) {
    if (addressData == null) return null;

    try {
      if (addressData is Map<String, dynamic>) {
        return ShippingAddress.fromJson(addressData);
      } else if (addressData is List) {
        if (addressData.isNotEmpty && addressData[0] is Map<String, dynamic>) {
          return ShippingAddress.fromJson(addressData[0]);
        }
      }
      print('⚠️ Unexpected address type: ${addressData.runtimeType}');
      return null;
    } catch (e) {
      print('❌ Error parsing address: $e');
      return null;
    }
  }

  static Timestamp? _parseTimestamp(dynamic timestampData) {
    if (timestampData == null) return null;

    try {
      if (timestampData is Timestamp) {
        return timestampData;
      } else if (timestampData is String) {
        // Try to parse as ISO string first
        try {
          return Timestamp.fromDate(DateTime.parse(timestampData));
        } catch (e) {
          // If ISO parsing fails, try to parse numeric string (milliseconds)
          try {
            final millis = int.tryParse(timestampData);
            if (millis != null) {
              return Timestamp.fromMillisecondsSinceEpoch(millis);
            }
          } catch (e) {
            print('❌ Error parsing numeric timestamp: $e');
          }

          // If numeric parsing fails, try custom format
          return _parseCustomDateTime(timestampData);
        }
      } else if (timestampData is int) {
        // Handle integer timestamp (could be seconds or milliseconds)
        if (timestampData > 10000000000) {
          // Likely milliseconds
          return Timestamp.fromMillisecondsSinceEpoch(timestampData);
        } else {
          // Likely seconds
          return Timestamp.fromMillisecondsSinceEpoch(timestampData * 1000);
        }
      } else if (timestampData is Map<String, dynamic>) {
        // Handle Firestore timestamp format
        if (timestampData['_seconds'] != null) {
          final seconds = timestampData['_seconds'] is int
              ? timestampData['_seconds']
              : int.tryParse(timestampData['_seconds'].toString());
          final nanoseconds = timestampData['_nanoseconds'] is int
              ? timestampData['_nanoseconds'] ?? 0
              : int.tryParse(timestampData['_nanoseconds']?.toString() ?? '0') ?? 0;

          if (seconds != null) {
            return Timestamp(seconds, nanoseconds);
          }
        }
      }

      print('⚠️ Unexpected timestamp type: ${timestampData.runtimeType}');
      return null;
    } catch (e) {
      print('❌ Error parsing timestamp: $e');
      print('Timestamp data: $timestampData (type: ${timestampData.runtimeType})');
      return null;
    }
  }

  static Timestamp? _parseCustomDateTime(String dateString) {
    try {
      // Only try to parse if it looks like a date string
      if (!dateString.contains(RegExp(r'[a-zA-Z]'))) {
        return null; // Not a custom date format
      }

      // Parse format like "Nov 28, 2025 12:33 PM"
      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
      };

      final parts = dateString.split(' ');
      if (parts.length >= 4) {
        final monthStr = parts[0];
        final day = parts[1].replaceAll(',', '');
        final year = parts[2];
        final timeStr = parts[3];
        final period = parts.length > 4 ? parts[4] : 'AM'; // AM/PM

        final timeParts = timeStr.split(':');
        var hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        // Convert to 24-hour format
        if (period.toUpperCase() == 'PM' && hour < 12) {
          hour += 12;
        } else if (period.toUpperCase() == 'AM' && hour == 12) {
          hour = 0;
        }
        final month = months[monthStr] ?? 1;
        final dateTime = DateTime(
          int.parse(year),
          month,
          int.parse(day),
          hour,
          minute,
        );
        return Timestamp.fromDate(dateTime);
      }

      print('⚠️ Unable to parse custom date format: $dateString');
      return null;
    } catch (e) {
      print('❌ Error parsing custom date format: $e');
      return null;
    }
  }

  static List<TaxModel>? _parseTaxSetting(dynamic taxData) {
    if (taxData == null || taxData is! List) return null;

    try {
      List<TaxModel> taxSettings = [];
      for (var item in taxData) {
        if (item is Map<String, dynamic>) {
          taxSettings.add(TaxModel.fromJson(item));
        }
      }
      return taxSettings;
    } catch (e) {
      print('❌ Error parsing tax setting: $e');
      return null;
    }
  }

  static List<CartProductModel>? _parseProducts(dynamic productsData) {
    if (productsData == null || productsData is! List) return null;

    try {
      List<CartProductModel> products = [];
      for (var item in productsData) {
        if (item is Map<String, dynamic>) {
          products.add(CartProductModel.fromJson(item));
        }
      }
      return products;
    } catch (e) {
      print('❌ Error parsing products: $e');
      return null;
    }
  }

  static VendorModel? _parseVendor(dynamic vendorData) {
    if (vendorData == null || vendorData is! Map<String, dynamic>) return null;

    try {
      return VendorModel.fromJson(vendorData);
    } catch (e) {
      print('❌ Error parsing vendor: $e');
      return null;
    }
  }

  static UserModel? _parseUser(dynamic userData) {
    if (userData == null || userData is! Map<String, dynamic>) return null;

    try {
      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ Error parsing user: $e');
      return null;
    }
  }

  static Map<String, dynamic>? _parseSpecialDiscount(dynamic discountData) {
    if (discountData == null) return null;

    try {
      if (discountData is Map<String, dynamic>) {
        return discountData;
      } else if (discountData is List) {
        return {}; // Return empty map if it's a list
      }
      return null;
    } catch (e) {
      print('❌ Error parsing special discount: $e');
      return null;
    }
  }

  static String _parseDeliveryCharge(dynamic chargeData) {
    try {
      if (chargeData == null) return "0.0";
      final String charge = chargeData.toString();
      return charge.isEmpty ? "0.0" : charge;
    } catch (e) {
      return "0.0";
    }
  }

  static String _parseTipAmount(dynamic tipData) {
    try {
      if (tipData == null) return "0.0";
      final String tip = tipData.toString();
      return tip.isEmpty ? "0.0" : tip;
    } catch (e) {
      return "0.0";
    }
  }

  static num _parseNumber(dynamic numberData) {
    try {
      if (numberData == null) return 0;
      if (numberData is num) return numberData;
      if (numberData is String) return num.tryParse(numberData) ?? 0;
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Recomputes order-level merchant_price from products subtotal when missing or zero.
  void ensureMerchantPriceFromProducts() {
    if (products == null || products!.isEmpty) return;
    final current = merchant_price == null
        ? 0.0
        : (merchant_price is num ? (merchant_price as num).toDouble() : 0.0);
    if (current > 0) return;
    double subtotal = 0.0;
    for (var p in products!) {
      final qty = p.quantity ?? 1;
      final mp = (p.merchant_price != null ? double.tryParse(p.merchant_price!) : null) ?? 0.0;
      final ext = (p.extrasPrice != null ? double.tryParse(p.extrasPrice!) : null) ?? 0.0;
      subtotal += mp * qty + ext * qty;
    }
    merchant_price = subtotal;
  }

  Map<String, dynamic> toJson() {
    ensureMerchantPriceFromProducts();
    print("Before update merchant_price: $merchant_price");
    final Map<String, dynamic> data = <String, dynamic>{};
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['status'] = status;
    data['couponId'] = couponId;
    data['vendorID'] = vendorID;
    data['driverID'] = driverID;
    data['discount'] = discount;
    data['merchant_price'] = merchant_price;
    data['authorID'] = authorID;
    data['estimatedTimeToPrepare'] = estimatedTimeToPrepare;

    // Handle Timestamps - convert to ISO strings or milliseconds
    if (createdAt != null) {
      data['createdAt'] = createdAt!.millisecondsSinceEpoch;
    }
    if (triggerDelivery != null) {
      data['triggerDelivery'] = triggerDelivery!.millisecondsSinceEpoch;
    }
    if (scheduleTime != null) {
      data['scheduleTime'] = scheduleTime!.millisecondsSinceEpoch;
    }

    if (taxSetting != null) {
      data['taxSetting'] = taxSetting!.map((v) => v.toJson()).toList();
    }
    data['payment_method'] = paymentMethod;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    data['adminCommissionType'] = adminCommissionType;
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    data['id'] = id;
    data['adminCommission'] = adminCommission;
    data['couponCode'] = couponCode;
    data['specialDiscount'] = specialDiscount;
    data['deliveryCharge'] = deliveryCharge;
    data['tip_amount'] = tipAmount;
    data['notes'] = notes;
    if (author != null) {
      data['author'] = author!.toJson();
    }
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    data['takeAway'] = takeAway;
    data['isCutleryRequired'] = isCutleryRequired;
    data['totalPrice'] = totalPrice;
    data['rejectedByDrivers'] = rejectedByDrivers;
    return data;
  }
}