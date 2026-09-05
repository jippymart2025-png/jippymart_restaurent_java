import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jippymart_restaurant/models/admin_commission.dart';

/// Restaurant/vendor entity. [isOpen] and [reststatus] drive dashboard open/closed state.
class VendorModel {
  /// Preference key used to persist this vendor's zone id.
  static const String zoneIdPrefKey = 'zone_id';
  // String? author;
  // bool? dineInActive;
  // String? openDineTime;
  List<dynamic>? categoryID;
  String? id;
  String? categoryPhoto;
  List<dynamic>? restaurantMenuPhotos;
  List<WorkingHours>? workingHours;
  String? location;
  String? fcmToken;
  G? g;
  bool? hidephotos;
  bool? reststatus;
  Filters? filters;
  AdminCommission? adminCommission;
  String? photo;
  String? description;
  num? walletAmount;
  String? closeDineTime;
  String? zoneId;
  Timestamp? createdAt;
  double? longitude;
  bool? enabledDiveInFuture;
  String? restaurantCost;
  DeliveryCharge? deliveryCharge;
  String? authorProfilePic;
  String? authorName;
  String? phonenumber;
  List<SpecialDiscount>? specialDiscount;
  bool? specialDiscountEnable;
  GeoPoint? coordinates;
  num? reviewsSum;
  num? reviewsCount;
  List<dynamic>? photos;
  String? title;
  List<dynamic>? categoryTitle;
  double? latitude;
  String? subscriptionPlanId;
  Timestamp? subscriptionExpiryDate;
  Map<String, dynamic>? subscriptionPlan;
  String? subscriptionTotalOrders;
  bool? isSelfDelivery;
  // Add missing fields
  String? cuisineID;
  String? cuisineTitle;
  bool? isOpen;

  VendorModel(
      {
        // this.author,
        // this.dineInActive,
        // this.openDineTime,
        this.categoryID,
        this.id,
        this.categoryPhoto,
        this.restaurantMenuPhotos,
        this.workingHours,
        this.location,
        this.fcmToken,
        this.g,
        this.hidephotos,
        this.reststatus,
        this.filters,
        this.reviewsCount,
        this.photo,
        this.description,
        this.walletAmount,
        this.closeDineTime,
        this.zoneId,
        this.createdAt,
        this.longitude,
        this.enabledDiveInFuture,
        this.restaurantCost,
        this.deliveryCharge,
        this.adminCommission,
        this.authorProfilePic,
        this.authorName,
        this.phonenumber,
        this.specialDiscount,
        this.specialDiscountEnable,
        this.coordinates,
        this.reviewsSum,
        this.photos,
        this.title,
        this.categoryTitle,
        this.latitude,
        this.subscriptionPlanId,
        this.subscriptionExpiryDate,
        this.subscriptionPlan,
        this.subscriptionTotalOrders,
        this.isSelfDelivery,
        this.cuisineID,
        this.cuisineTitle,
        this.isOpen});

  VendorModel.fromJson(Map<String, dynamic> json) {
    // author = json['author'];
    // dineInActive = _parseToBool(json['dine_in_active']);
    // openDineTime = json['openDineTime'];

    // Handle categoryID - it might be a string or array
    categoryID = _parseJsonFieldToList(json['categoryID']) ?? [];

    id = json['id'];
    categoryPhoto = json['categoryPhoto'];

    // Handle restaurantMenuPhotos - it might be a string or array
    restaurantMenuPhotos = _parseJsonFieldToList(json['restaurantMenuPhotos']) ?? [];

    // Handle workingHours - it might be a string or array
    if (json['workingHours'] is String) {
      try {
        List<dynamic> workingHoursData = jsonDecode(json['workingHours']);
        workingHours = <WorkingHours>[];
        for (var v in workingHoursData) {
          workingHours!.add(WorkingHours.fromJson(v));
        }
      } catch (e) {
        workingHours = [];
      }
    } else if (json['workingHours'] != null) {
      workingHours = <WorkingHours>[];
      for (var v in json['workingHours']) {
        workingHours!.add(WorkingHours.fromJson(v));
      }
    }

    location = json['location'];
    fcmToken = json['fcmToken'];

    // Handle g field - it might be a string or object
    if (json['g'] is String) {
      try {
        g = G.fromJson(jsonDecode(json['g']));
      } catch (e) {
        g = null;
      }
    } else {
      g = json['g'] != null ? G.fromJson(json['g']) : null;
    }

    hidephotos = _parseToBool(json['hidephotos']);

    // Handle reststatus - it might be int (1/0) or bool; API may use reststatus or rest_status
    reststatus = _parseToBool(json['reststatus']) ?? _parseToBool(json['rest_status']);

    // Handle filters - it might be a string or object
    if (json['filters'] is String) {
      try {
        filters = Filters.fromJson(jsonDecode(json['filters']));
      } catch (e) {
        filters = null;
      }
    } else {
      filters = json['filters'] != null ? Filters.fromJson(json['filters']) : null;
    }

    reviewsCount = json['reviewsCount'] ?? 0.0;
    photo = json['photo'];
    description = json['description'];
    walletAmount = json['walletAmount'];
    closeDineTime = json['closeDineTime'];
    zoneId = json['zoneId'];

    // Handle createdAt - it might be a string or Timestamp
    if (json['createdAt'] is String) {
      try {
        DateTime dateTime = DateTime.parse(json['createdAt']);
        createdAt = Timestamp.fromDate(dateTime);
      } catch (e) {
        createdAt = null;
      }
    } else {
      createdAt = json['createdAt'];
    }

    longitude = _parseToDouble(json['longitude']);
    enabledDiveInFuture = _parseToBool(json['enabledDiveInFuture']);
    restaurantCost = json['restaurantCost']?.toString();

    // Handle deliveryCharge - it might be a string or object
    if (json['DeliveryCharge'] is String) {
      try {
        deliveryCharge = DeliveryCharge.fromJson(jsonDecode(json['DeliveryCharge']));
      } catch (e) {
        deliveryCharge = null;
      }
    } else {
      // Handle deliveryCharge - it might be a string, object, or now an integer
      if (json['DeliveryCharge'] is Map) {
        // It's a JSON object (old format)
        deliveryCharge = DeliveryCharge.fromJson(json['DeliveryCharge']);
      } else if (json['DeliveryCharge'] is String) {
        // It's a stringified JSON (alternative format)
        try {
          deliveryCharge = DeliveryCharge.fromJson(jsonDecode(json['DeliveryCharge']));
        } catch (e) {
          deliveryCharge = null;
        }
      } else if (json['DeliveryCharge'] is num) {
        // It's now a numeric value from the database
        // Create a DeliveryCharge object with the numeric value as minimum delivery charges
        deliveryCharge = DeliveryCharge(
          minimumDeliveryCharges: json['DeliveryCharge'],
          minimumDeliveryChargesWithinKm: 0,
          deliveryChargesPerKm: 0,
          vendorCanModify: true,
        );
      } else {
        deliveryCharge = null;
      }
    }
    // Handle adminCommission - it might be a string or object
    if (json['adminCommission'] is String) {
      try {
        adminCommission = AdminCommission.fromJson(jsonDecode(json['adminCommission']));
      } catch (e) {
        adminCommission = null;
      }
    } else {
      adminCommission = json['adminCommission'] != null
          ? AdminCommission.fromJson(json['adminCommission'])
          : null;
    }

    authorProfilePic = json['authorProfilePic'];
    authorName = json['authorName'];
    phonenumber = json['phonenumber'];

    if (json['specialDiscount'] != null) {
      specialDiscount = <SpecialDiscount>[];
      for (var v in json['specialDiscount']) {
        specialDiscount!.add(SpecialDiscount.fromJson(v));
      }
    }

    specialDiscountEnable = _parseToBool(json['specialDiscountEnable']);
    coordinates = json['coordinates'];
    reviewsSum = json['reviewsSum'] ?? 0.0;

    // Handle photos - it might be a string or array
    photos = _parseJsonFieldToList(json['photos']) ?? [];

    title = json['title'];

    // Handle categoryTitle - it might be a string or array
    categoryTitle = _parseJsonFieldToList(json['categoryTitle']) ?? [];

    latitude = _parseToDouble(json['latitude']);

    subscriptionPlanId = json['subscriptionPlanId'];

    // Handle subscriptionExpiryDate - it might be a string or Timestamp
    if (json['subscriptionExpiryDate'] is String) {
      try {
        DateTime dateTime = DateTime.parse(json['subscriptionExpiryDate']);
        subscriptionExpiryDate = Timestamp.fromDate(dateTime);
      } catch (e) {
        subscriptionExpiryDate = null;
      }
    } else {
      subscriptionExpiryDate = json['subscriptionExpiryDate'];
    }

    if (json['subscription_plan'] != null && json['subscription_plan'] is Map) {
      subscriptionPlan = Map<String, dynamic>.from(json['subscription_plan']);
    } else {
      subscriptionPlan = null;
    }

    subscriptionTotalOrders = json['subscriptionTotalOrders'];
    isSelfDelivery = _parseToBool(json['isSelfDelivery']) ?? false;
    cuisineID = json['cuisineID'];
    cuisineTitle = json['cuisineTitle'];

    // Handle isOpen only - int (1/0), bool, or string; API may use isOpen, is_open, or open
    isOpen = _parseToBool(json['isOpen']) ??
        _parseToBool(json['is_open']) ??
        _parseToBool(json['open']);
  }

// Add this helper method to VendorModel class for boolean parsing
  static bool? _parseToBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true' || value == '1') return true;
      if (value.toLowerCase() == 'false' || value == '0') return false;
    }
    return null;
  }

  /// Returns a copy with [isOpen] and/or [reststatus] updated; other fields shared.
  VendorModel copyWith({bool? isOpen, bool? reststatus}) {
    return VendorModel(
      // author: author,
      // dineInActive: dineInActive,
      // openDineTime: openDineTime,
      categoryID: categoryID,
      id: id,
      categoryPhoto: categoryPhoto,
      restaurantMenuPhotos: restaurantMenuPhotos,
      workingHours: workingHours,
      location: location,
      fcmToken: fcmToken,
      g: g,
      hidephotos: hidephotos,
      reststatus: reststatus ?? this.reststatus,
      filters: filters,
      reviewsCount: reviewsCount,
      photo: photo,
      description: description,
      walletAmount: walletAmount,
      closeDineTime: closeDineTime,
      zoneId: zoneId,
      createdAt: createdAt,
      longitude: longitude,
      enabledDiveInFuture: enabledDiveInFuture,
      restaurantCost: restaurantCost,
      deliveryCharge: deliveryCharge,
      adminCommission: adminCommission,
      authorProfilePic: authorProfilePic,
      authorName: authorName,
      phonenumber: phonenumber,
      specialDiscount: specialDiscount,
      specialDiscountEnable: specialDiscountEnable,
      coordinates: coordinates,
      reviewsSum: reviewsSum,
      photos: photos,
      title: title,
      categoryTitle: categoryTitle,
      latitude: latitude,
      subscriptionPlanId: subscriptionPlanId,
      subscriptionExpiryDate: subscriptionExpiryDate,
      subscriptionPlan: subscriptionPlan,
      subscriptionTotalOrders: subscriptionTotalOrders,
      isSelfDelivery: isSelfDelivery,
      cuisineID: cuisineID,
      cuisineTitle: cuisineTitle,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['author'] = author;
    // data['dine_in_active'] = dineInActive;
    // data['openDineTime'] = openDineTime;
    data['categoryID'] = categoryID;
    data['id'] = id;
    data['categoryPhoto'] = categoryPhoto;
    data['restaurantMenuPhotos'] = restaurantMenuPhotos;
    data['subscriptionPlanId'] = subscriptionPlanId;

    // Fix: Convert subscriptionExpiryDate Timestamp to ISO string
    if (subscriptionExpiryDate != null) {
      data['subscriptionExpiryDate'] = subscriptionExpiryDate!.toDate().toIso8601String();
    } else {
      data['subscriptionExpiryDate'] = null;
    }

    data['subscription_plan'] = subscriptionPlan;
    data['subscriptionTotalOrders'] = subscriptionTotalOrders;

    if (workingHours != null) {
      data['workingHours'] = workingHours!.map((v) => v.toJson()).toList();
    }

    data['location'] = location;
    data['fcmToken'] = fcmToken;

    if (g != null) {
      data['g'] = g!.toJson();
    }

    data['hidephotos'] = hidephotos;
    data['reststatus'] = reststatus;

    if (filters != null) {
      data['filters'] = filters!.toJson();
    }

    data['reviewsCount'] = reviewsCount;
    data['photo'] = photo;
    data['description'] = description;
    data['walletAmount'] = walletAmount;
    data['closeDineTime'] = closeDineTime;
    data['zoneId'] = zoneId;

    // Handle createdAt - convert Timestamp to ISO string
    if (createdAt != null) {
      data['createdAt'] = createdAt!.toDate().toIso8601String();
    } else {
      data['createdAt'] = null;
    }

    data['longitude'] = longitude;
    data['enabledDiveInFuture'] = enabledDiveInFuture;
    data['restaurantCost'] = restaurantCost;

    if (deliveryCharge != null) {
      data['DeliveryCharge'] = deliveryCharge!.minimumDeliveryCharges ?? 0;
    }

    if (adminCommission != null) {
      data['adminCommission'] = adminCommission!.toJson();
    }

    data['authorProfilePic'] = authorProfilePic;
    data['authorName'] = authorName;
    data['phonenumber'] = phonenumber;

    if (specialDiscount != null) {
      data['specialDiscount'] = specialDiscount!.map((v) => v.toJson()).toList();
    }

    data['specialDiscountEnable'] = specialDiscountEnable;
    data['coordinates'] = coordinates;
    data['reviewsSum'] = reviewsSum;
    data['photos'] = photos;
    data['title'] = title;
    data['categoryTitle'] = categoryTitle;
    data['latitude'] = latitude;
    data['isSelfDelivery'] = isSelfDelivery ?? false;
    data['cuisineID'] = cuisineID;
    data['cuisineTitle'] = cuisineTitle;
    data['isOpen'] = isOpen;

    return data;
  }


  // Helper method to parse JSON fields to List
  static List<dynamic>? _parseJsonFieldToList(dynamic field) {
    if (field is String) {
      try {
        return jsonDecode(field);
      } catch (e) {
        return [];
      }
    } else if (field is List) {
      return field;
    }
    return null;
  }

  // Helper method to safely parse to double
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }
}

class WorkingHours {
  String? day;
  List<Timeslot>? timeslot;

  WorkingHours({this.day, this.timeslot});

  WorkingHours.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    if (json['timeslot'] != null) {
      timeslot = <Timeslot>[];
      // Handle timeslot - it might be a string or array
      if (json['timeslot'] is String) {
        try {
          List<dynamic> timeslotData = jsonDecode(json['timeslot']);
          for (var v in timeslotData) {
            timeslot!.add(Timeslot.fromJson(v));
          }
        } catch (e) {
          timeslot = [];
        }
      } else {
        for (var v in json['timeslot']) {
          timeslot!.add(Timeslot.fromJson(v));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    if (timeslot != null) {
      data['timeslot'] = timeslot!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Timeslot {
  int? productAvailableTimingId;
  String? to;
  String? from;

  Timeslot({
    this.productAvailableTimingId,
    this.to,
    this.from,
  });

  Timeslot.fromJson(Map<String, dynamic> json) {
    productAvailableTimingId =
    json['productAvailableTimingId'] is int
        ? json['productAvailableTimingId']
        : int.tryParse(
      json['productAvailableTimingId']?.toString() ?? '',
    );

    to = json['to'];
    from = json['from'];
  }

  Map<String, dynamic> toJson() {
    return {
      'productAvailableTimingId': productAvailableTimingId,
      'to': to,
      'from': from,
    };
  }
}
class G {
  String? geohash;
  GeoPoint? geopoint;

  G({this.geohash, this.geopoint});

  G.fromJson(Map<String, dynamic> json) {
    geohash = json['geohash'];
    // Handle geopoint - it might be a map with latitude/longitude
    if (json['geopoint'] != null) {
      if (json['geopoint'] is Map) {
        Map<String, dynamic> geoMap = json['geopoint'];
        double? lat = _parseDouble(geoMap['latitude'] ?? geoMap['_latitude']);
        double? lng = _parseDouble(geoMap['longitude'] ?? geoMap['_longitude']);
        if (lat != null && lng != null) {
          geopoint = GeoPoint(lat, lng);
        } else {
          geopoint = null;
        }
      } else {
        geopoint = null;
      }
    } else {
      geopoint = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['geohash'] = geohash;
    if (geopoint != null) {
      data['geopoint'] = {
        'latitude': geopoint!.latitude,
        'longitude': geopoint!.longitude,
        '_latitude': geopoint!.latitude,
        '_longitude': geopoint!.longitude,
      };
    }
    return data;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

class Filters {
  String? goodForLunch;
  String? outdoorSeating;
  String? liveMusic;
  String? vegetarianFriendly;
  String? goodForDinner;
  String? goodForBreakfast;
  String? freeWiFi;
  String? takesReservations;

  Filters(
      {this.goodForLunch,
        this.outdoorSeating,
        this.liveMusic,
        this.vegetarianFriendly,
        this.goodForDinner,
        this.goodForBreakfast,
        this.freeWiFi,
        this.takesReservations});

  Filters.fromJson(Map<String, dynamic> json) {
    goodForLunch = json['Good for Lunch']?.toString();
    outdoorSeating = json['Outdoor Seating']?.toString();
    liveMusic = json['Live Music']?.toString();
    vegetarianFriendly = json['Vegetarian Friendly']?.toString();
    goodForDinner = json['Good for Dinner']?.toString();
    goodForBreakfast = json['Good for Breakfast']?.toString();
    freeWiFi = json['Free Wi-Fi']?.toString();
    takesReservations = json['Takes Reservations']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Good for Lunch'] = goodForLunch;
    data['Outdoor Seating'] = outdoorSeating;
    data['Live Music'] = liveMusic;
    data['Vegetarian Friendly'] = vegetarianFriendly;
    data['Good for Dinner'] = goodForDinner;
    data['Good for Breakfast'] = goodForBreakfast;
    data['Free Wi-Fi'] = freeWiFi;
    data['Takes Reservations'] = takesReservations;
    return data;
  }
}

class DeliveryCharge {
  num? minimumDeliveryChargesWithinKm;
  num? minimumDeliveryCharges;
  num? deliveryChargesPerKm;
  bool? vendorCanModify;

  DeliveryCharge(
      {this.minimumDeliveryChargesWithinKm,
        this.minimumDeliveryCharges,
        this.deliveryChargesPerKm,
        this.vendorCanModify});

  DeliveryCharge.fromJson(Map<String, dynamic> json) {
    minimumDeliveryChargesWithinKm = _parseNum(json['minimum_delivery_charges_within_km']);
    minimumDeliveryCharges = _parseNum(json['minimum_delivery_charges']);
    deliveryChargesPerKm = _parseNum(json['delivery_charges_per_km']);
    vendorCanModify = _parseBool(json['vendor_can_modify']);
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final n = value.toLowerCase();
      if (n == 'true' || n == '1') return true;
      if (n == 'false' || n == '0') return false;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['minimum_delivery_charges_within_km'] = minimumDeliveryChargesWithinKm;
    data['minimum_delivery_charges'] = minimumDeliveryCharges;
    data['delivery_charges_per_km'] = deliveryChargesPerKm;
    data['vendor_can_modify'] = vendorCanModify;
    return data;
  }

  static num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) {
      try {
        return num.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

class SpecialDiscount {
  String? day;
  List<SpecialDiscountTimeslot>? timeslot;

  SpecialDiscount({this.day, this.timeslot});

  SpecialDiscount.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    if (json['timeslot'] != null) {
      timeslot = <SpecialDiscountTimeslot>[];
      // Handle timeslot - it might be a string or array
      if (json['timeslot'] is String) {
        try {
          List<dynamic> timeslotData = jsonDecode(json['timeslot']);
          for (var v in timeslotData) {
            timeslot!.add(SpecialDiscountTimeslot.fromJson(v));
          }
        } catch (e) {
          timeslot = [];
        }
      } else {
        for (var v in json['timeslot']) {
          timeslot!.add(SpecialDiscountTimeslot.fromJson(v));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    if (timeslot != null) {
      data['timeslot'] = timeslot!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SpecialDiscountTimeslot {
  String? discount;
  String? discountType;
  String? to;
  String? type;
  String? from;

  SpecialDiscountTimeslot(
      {this.discount, this.discountType, this.to, this.type, this.from});

  SpecialDiscountTimeslot.fromJson(Map<String, dynamic> json) {
    discount = json['discount'];
    discountType = json['discount_type'];
    to = json['to'];
    type = json['type'];
    from = json['from'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['to'] = to;
    data['type'] = type;
    data['from'] = from;
    return data;
  }
}