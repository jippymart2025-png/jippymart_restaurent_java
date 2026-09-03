import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  int? fats;
  String? vendorID;
  bool? veg;
  bool? publish;
  List<dynamic>? addOnsTitle;
  int? calories;
  int? proteins;
  List<dynamic>? addOnsPrice;
  num? reviewsSum;
  bool? takeawayOption;
  String? name;
  Map<String, dynamic>? reviewAttributes;
  Map<String, dynamic>? productSpecification;
  ItemAttribute? itemAttribute;
  String? id;
  int? quantity;
  int? grams;
  num? reviewsCount;
  String? disPrice;
  List<dynamic>? photos;
  bool? nonveg;
  String? photo;
  String? price;
  String? merchant_price;
  String? categoryID;
  String? description;
  Timestamp? createdAt;
  bool? isAvailable;
  /// Optional per-day time slots when the product is available.
  /// Matches the JSON that `SelectedProductModel` sends to the backend, e.g.:
  /// `[{"day":"Monday","timeslot":[{"from":"11:00","to":"22:00"}]}]`
  List<dynamic>? availableTimings;

  ProductModel({
    this.fats,
    this.vendorID,
    this.veg,
    this.publish,
    this.addOnsTitle,
    this.calories,
    this.proteins,
    this.addOnsPrice,
    this.reviewsSum,
    this.takeawayOption,
    this.name,
    this.reviewAttributes,
    this.productSpecification,
    this.itemAttribute,
    this.id,
    this.quantity,
    this.grams,
    this.reviewsCount,
    this.disPrice,
    this.photos,
    this.nonveg,
    this.photo,
    this.price,
    this.merchant_price,
    this.categoryID,
    this.description,
    this.createdAt,
    this.isAvailable,
    this.availableTimings,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    fats = json['fats'];
    vendorID = json['vendorID'];

    // Handle boolean fields that might come as int (0/1), bool, or String from API
    veg = _convertToBool(json['veg']);
    publish = _convertToBool(json['publish']);
    nonveg = _convertToBool(json['nonveg']);
    takeawayOption = _convertToBool(json['takeawayOption'] ?? json['takeaway_option']);
    isAvailable = _convertToBool(json['isAvailable'] ?? json['is_available']);

    // FIX: Handle Firestore arrayValue format for addOnsTitle (accept API keys: addOnsTitle, add_ons_title)
    addOnsTitle = _extractArrayFromFirestore(json['addOnsTitle'] ?? json['add_ons_title']) ?? [];

    calories = json['calories'];
    proteins = json['proteins'];

    // FIX: Handle Firestore arrayValue format for addOnsPrice (accept API keys: addOnsPrice, add_ons_price)
    addOnsPrice = _extractArrayFromFirestore(json['addOnsPrice'] ?? json['add_ons_price']) ?? [];

    reviewsSum = json['reviewsSum'] ?? 0.0;
    name = json['name'];

    // FIX: Handle reviewAttributes that might be a String (JSON) instead of Map
    reviewAttributes = _parseJsonField(json['reviewAttributes']);

    // FIX: Handle product_specification that can be either List or Map or String
    productSpecification = _parseJsonField(json['product_specification']) ?? {};

    // FIX: Handle item_attribute / itemAttribute (object). Top-level "options" array is handled below.
    itemAttribute = _parseItemAttribute(json['item_attribute'] ?? json['itemAttribute']);

    // API may send top-level "options" as array: [{ id, title, subtitle, original_price, price, is_available }, ...]
    final optionsList = json['options'];
    if (optionsList is List && optionsList.isNotEmpty) {
      final variants = <Variants>[];
      for (var o in optionsList) {
        if (o is Map) {
          final m = Map<String, dynamic>.from(o);
          final title = m['title']?.toString() ?? '';
          final subtitle = m['subtitle']?.toString();
          final price = m['price']?.toString() ?? m['original_price']?.toString() ?? '0';
          final sku = subtitle != null && subtitle.isNotEmpty ? '$title - $subtitle' : title;
          variants.add(Variants(
            variantSku: sku,
            variantPrice: price,
            variantId: m['id']?.toString(),
            variantQuantity: '0',
            variantImage: null,
          ));
        }
      }
      if (variants.isNotEmpty) {
        itemAttribute ??= ItemAttribute(attributes: [], variants: []);
        itemAttribute!.variants = variants;
      }
    }

    id = json['id'];
    quantity = json['quantity'];
    grams = json['grams'];
    reviewsCount = json['reviewsCount'] ?? 0.0;

    // Fix: Convert disPrice to string
    disPrice = _convertToString(json['disPrice']) ?? "0";

    // FIX: Handle photos as array or JSON string (e.g. "[\"url1\", \"url2\"]")
    photos = _extractArrayFromFirestore(json['photos']) ?? [];

    photo = json['photo'];

    // Fix: Convert price to string
    price = _convertToString(json['price']);

    merchant_price = _convertToString(json['merchant_price']);

    final rawCategoryId = json['categoryID'] ?? json['category_id'];
    categoryID = rawCategoryId?.toString();
    description = json['description'];

    // Handle createdAt field - support multiple formats
    if (json['createdAt'] != null) {
      if (json['createdAt'] is int) {
        // If it's milliseconds since epoch
        createdAt = Timestamp.fromMillisecondsSinceEpoch(json['createdAt']);
      } else if (json['createdAt'] is Map) {
        // If it's Firestore Timestamp format
        final timestampData = json['createdAt'];
        createdAt = Timestamp(
          timestampData['seconds'] ?? 0,
          timestampData['nanoseconds'] ?? 0,
        );
      } else if (json['createdAt'] is String) {
        try {
          final date = DateTime.parse(json['createdAt']);
          createdAt = Timestamp.fromDate(date);
        } catch (e) {
          createdAt = null;
        }
      } else {
        createdAt = json['createdAt'];
      }
    }

    // Optional availability timings (may come as List, Firestore arrayValue, or JSON string)
    try {
      final rawAvailability = json['available_timings'];
      if (rawAvailability != null) {
        final parsed = _extractArrayFromFirestore(rawAvailability);
        if (parsed != null) {
          availableTimings = parsed;
        }
      }
    } catch (_) {
      availableTimings = null;
    }
  }

  // Helper method to parse JSON fields that might be strings
  Map<String, dynamic>? _parseJsonField(dynamic value) {
    if (value == null) return null;

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    } else if (value is String) {
      // Try to parse the JSON string
      try {
        final parsedJson = jsonDecode(value);
        if (parsedJson is Map) {
          return Map<String, dynamic>.from(parsedJson);
        } else {
          return {};
        }
      } catch (e) {
        // If parsing fails, use empty map
        return {};
      }
    } else if (value is List) {
      // If it's a list, return empty map
      return {};
    } else {
      return {};
    }
  }

  ItemAttribute? _parseItemAttribute(dynamic value) {
    if (value == null) return null;

    try {
      final extractedValue = _extractValueFromFirestoreFormat(value);

      if (extractedValue == null) {
        return ItemAttribute(attributes: [], variants: []);
      }

      // Now handle the extracted value
      if (extractedValue is Map) {
        if (extractedValue.isEmpty) {
          return ItemAttribute(attributes: [], variants: []);
        }
        return ItemAttribute.fromJson(Map<String, dynamic>.from(extractedValue));
      } else if (extractedValue is String) {
        // Try to parse the JSON string
        final parsedJson = jsonDecode(extractedValue);
        if (parsedJson is Map) {
          return ItemAttribute.fromJson(Map<String, dynamic>.from(parsedJson));
        }
      }
    } catch (e) {
      // If anything goes wrong, return empty ItemAttribute
    }

    return ItemAttribute(attributes: [], variants: []);
  }

// Helper method to extract value from Firestore format
  dynamic _extractValueFromFirestoreFormat(dynamic value) {
    if (value == null) return null;

    if (value is Map) {
      // Check for Firestore value formats
      if (value.containsKey('stringValue')) {
        return value['stringValue'];
      } else if (value.containsKey('mapValue')) {
        return value['mapValue'];
      } else if (value.containsKey('arrayValue')) {
        return value['arrayValue'];
      } else if (value.containsKey('intValue')) {
        return value['intValue'];
      } else if (value.containsKey('doubleValue')) {
        return value['doubleValue'];
      } else if (value.containsKey('boolValue')) {
        return value['boolValue'];
      } else {
        // It's a regular Map, return as-is
        return value;
      }
    }

    // Not a Map, return as-is
    return value;
  }

  // Helper method to extract array from Firestore arrayValue format
  List<dynamic>? _extractArrayFromFirestore(dynamic value) {
    if (value == null) return null;

    // If it's already a List, return it
    if (value is List) {
      return value;
    }

    // If it's a Map and contains arrayValue (Firestore format)
    if (value is Map<String, dynamic>) {
      if (value.containsKey('arrayValue')) {
        final arrayValue = value['arrayValue'];
        if (arrayValue is Map && arrayValue.containsKey('values')) {
          final values = arrayValue['values'];
          if (values is List) {
            // Extract the actual values from Firestore array format
            return values.map((item) {
              if (item is Map) {
                // Extract stringValue, intValue, etc.
                if (item.containsKey('stringValue')) {
                  return item['stringValue'];
                } else if (item.containsKey('intValue')) {
                  return int.tryParse(item['intValue'].toString()) ?? item['intValue'];
                } else if (item.containsKey('doubleValue')) {
                  return double.tryParse(item['doubleValue'].toString()) ?? item['doubleValue'];
                } else if (item.containsKey('boolValue')) {
                  return item['boolValue'] == true;
                }
              }
              return item;
            }).toList();
          }
        }
        // If arrayValue is empty (like {arrayValue: {}} or {arrayValue: []})
        return [];
      }

      // If it's a regular map but we expect a list, convert if possible
      if (value.containsKey('values') && value['values'] is List) {
        return value['values'];
      }
    }

    // If it's a string that looks like JSON, try to parse it
    if (value is String) {
      try {
        final parsed = json.decode(value);
        if (parsed is List) return parsed;
      } catch (e) {
        // If parsing fails, return as a single-item list
        return [value];
      }
    }

    // For other types, wrap in a list
    return [value];
  }

  // Helper method to convert various types to boolean
  bool _convertToBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }

  // Helper method to convert various types to string
  String? _convertToString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();

    // Handle Firestore numeric value format
    if (value is Map) {
      if (value.containsKey('stringValue')) {
        return value['stringValue'].toString();
      } else if (value.containsKey('intValue')) {
        return value['intValue'].toString();
      } else if (value.containsKey('doubleValue')) {
        return value['doubleValue'].toString();
      }
    }

    return value.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fats'] = fats;
    data['vendorID'] = vendorID;
    data['veg'] = veg;
    data['publish'] = publish;
    data['addOnsTitle'] = addOnsTitle;
    data['addOnsPrice'] = addOnsPrice;
    data['calories'] = calories;
    data['proteins'] = proteins;
    data['reviewsSum'] = reviewsSum;
    data['takeawayOption'] = takeawayOption;
    data['name'] = name;
    data['reviewAttributes'] = reviewAttributes;
    data['product_specification'] = productSpecification;
    if (itemAttribute != null) {
      data['item_attribute'] = itemAttribute!.toJson();
    }
    data['id'] = id;
    data['quantity'] = quantity;
    data['grams'] = grams;
    data['reviewsCount'] = reviewsCount;
    data['disPrice'] = disPrice;
    data['photos'] = photos;
    data['nonveg'] = nonveg;
    data['photo'] = photo;
    data['price'] = price;
    data['merchant_price'] = merchant_price;
    data['categoryID'] = categoryID;
    data['description'] = description;

    // Convert Timestamp to milliseconds since epoch for JSON serialization
    data['createdAt'] = createdAt?.millisecondsSinceEpoch;

    data['isAvailable'] = isAvailable;
    if (availableTimings != null && availableTimings!.isNotEmpty) {
      data['available_timings'] = availableTimings;
    }
    return data;
  }

  // Helper method to convert to Firestore-friendly map (if needed for Firestore operations)
  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fats'] = fats;
    data['vendorID'] = vendorID;
    data['veg'] = veg;
    data['publish'] = publish;
    data['addOnsTitle'] = addOnsTitle;
    data['addOnsPrice'] = addOnsPrice;
    data['calories'] = calories;
    data['proteins'] = proteins;
    data['reviewsSum'] = reviewsSum;
    data['takeawayOption'] = takeawayOption;
    data['name'] = name;
    data['reviewAttributes'] = reviewAttributes;
    data['product_specification'] = productSpecification;
    if (itemAttribute != null) {
      data['item_attribute'] = itemAttribute!.toJson();
    }
    data['id'] = id;
    data['quantity'] = quantity;
    data['grams'] = grams;
    data['reviewsCount'] = reviewsCount;
    data['disPrice'] = disPrice;
    data['photos'] = photos;
    data['nonveg'] = nonveg;
    data['photo'] = photo;
    data['price'] = price;
    data['merchant_price'] = merchant_price;
    data['categoryID'] = categoryID;
    data['description'] = description;
    data['createdAt'] = createdAt; // Keep as Timestamp for Firestore
    data['isAvailable'] = isAvailable;
    if (availableTimings != null && availableTimings!.isNotEmpty) {
      data['available_timings'] = availableTimings;
    }
    return data;
  }
  Map<String, dynamic> toMasterProductJson() {
    return {
      "productName": name ?? "",
      "description": description ?? "",

      "merchantPrice":
      double.tryParse(merchant_price ?? price ?? "0") ?? 0,

      "isVeg": veg ?? false,

      "hasProductVariants":
      itemAttribute?.variants?.isNotEmpty ?? false,

      "variants": itemAttribute?.variants?.map((v) {
        return {
          "variantId": int.tryParse(v.variantId ?? "0") ?? 0,
          "variantSku": v.variantSku ?? "",
          "variantPrice":
          double.tryParse(v.variantPrice ?? "0") ?? 0,
          "variantQuantity":
          int.tryParse(v.variantQuantity ?? "0") ?? 0,
        };
      }).toList() ??
          [],

      "masterProductId": int.tryParse(id ?? "0") ?? 0,

      "categoryId": int.tryParse(categoryID ?? "0") ?? 0,

      "csvDayOfWeek": "MONDAY",
      "csvTiming": "09:00-22:00",

      "timings": [
        {
          "dayOfWeekId": 1,
          "startTime": "09:00",
          "endTime": "22:00"
        }
      ]
    };
  }

}

class ItemAttribute {
  List<Attributes>? attributes;
  List<Variants>? variants;

  ItemAttribute({this.attributes, this.variants});

  ItemAttribute.fromJson(Map<String, dynamic> json) {
    if (json['attributes'] != null) {
      attributes = <Attributes>[];
      // Handle both List format and Firestore arrayValue format
      final attributesList = _extractArrayFromFirestore(json['attributes']);
      if (attributesList != null) {
        for (var v in attributesList) {
          if (v is Map) {
            attributes!.add(Attributes.fromJson(Map<String, dynamic>.from(v)));
          }
        }
      }
    }
    if (json['variants'] != null) {
      variants = <Variants>[];
      // Handle both List format and Firestore arrayValue format
      final variantsList = _extractArrayFromFirestore(json['variants']);
      if (variantsList != null) {
        for (var v in variantsList) {
          if (v is Map) {
            variants!.add(Variants.fromJson(Map<String, dynamic>.from(v)));
          }
        }
      }
    }
  }

  // Helper method to extract array from Firestore arrayValue format
  List<dynamic>? _extractArrayFromFirestore(dynamic value) {
    if (value == null) return null;

    // If it's already a List, return it
    if (value is List) {
      return value;
    }

    // If it's a Map and contains arrayValue (Firestore format)
    if (value is Map<String, dynamic>) {
      if (value.containsKey('arrayValue')) {
        final arrayValue = value['arrayValue'];
        if (arrayValue is Map && arrayValue.containsKey('values')) {
          final values = arrayValue['values'];
          if (values is List) {
            return values.map((item) {
              if (item is Map) {
                if (item.containsKey('mapValue')) {
                  return item['mapValue'];
                }
                return item;
              }
              return item;
            }).toList();
          }
        }
        return [];
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attributes != null) {
      data['attributes'] = attributes!.map((v) => v.toJson()).toList();
    }
    if (variants != null) {
      data['variants'] = variants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attributes {
  String? attributeId;
  List<String>? attributeOptions;

  Attributes({this.attributeId, this.attributeOptions});

  Attributes.fromJson(Map<String, dynamic> json) {
    attributeId = json['attribute_id'];
    // Handle attribute_options that might be in Firestore arrayValue format
    if (json['attribute_options'] != null) {
      if (json['attribute_options'] is List) {
        attributeOptions = List<String>.from(json['attribute_options'].map((x) => x.toString()));
      } else if (json['attribute_options'] is Map) {
        // Handle Firestore arrayValue format
        if (json['attribute_options'].containsKey('arrayValue')) {
          final arrayValue = json['attribute_options']['arrayValue'];
          if (arrayValue is Map && arrayValue.containsKey('values')) {
            attributeOptions = List<String>.from(
                arrayValue['values'].map((x) => x['stringValue'].toString())
            );
          }
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attribute_id'] = attributeId;
    data['attribute_options'] = attributeOptions;
    return data;
  }
}

class Variants {
  String? variantId;
  String? variantImage;
  String? variantPrice;
  String? variantMerchantPrice;
  String? variantQuantity;
  String? variantSku;

  Variants({
    this.variantId,
    this.variantImage,
    this.variantPrice,
    this.variantMerchantPrice,
    this.variantQuantity,
    this.variantSku,
  });

  Variants.fromJson(Map<String, dynamic> json) {
    variantId = _convertToString(json['variant_id'] ?? json['variantId']);
    variantImage = _convertToString(json['variant_image'] ?? json['variantImage']);
    variantPrice = _convertToString(json['variant_price'] ?? json['variantPrice']) ?? '0';
    variantQuantity = _convertToString(json['variant_quantity'] ?? json['variantQuantity']) ?? '0';
    variantSku = _convertToString(json['variant_sku'] ?? json['variantSku']);
  }

  // Helper method to convert various types to string
  String? _convertToString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();

    // Handle Firestore value format
    if (value is Map) {
      if (value.containsKey('stringValue')) {
        return value['stringValue'].toString();
      } else if (value.containsKey('intValue')) {
        return value['intValue'].toString();
      } else if (value.containsKey('doubleValue')) {
        return value['doubleValue'].toString();
      }
    }

    return value.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variant_id'] = variantId;
    data['variant_image'] = variantImage;
    data['variant_price'] = variantPrice;
    data['variant_quantity'] = variantQuantity;
    data['variant_sku'] = variantSku;
    return data;
  }
}

class ProductSpecificationModel {
  String? lable;
  String? value;

  ProductSpecificationModel({this.lable, this.value});

  ProductSpecificationModel.fromJson(Map<String, dynamic> json) {
    lable = json['lable'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lable'] = lable;
    data['value'] = value;
    return data;
  }
}