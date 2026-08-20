import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jippymart_restaurant/constant/constant.dart';

class UserModel {
  // Preference key for storing user's zone id.
  static const String zoneIdPrefKey = 'user_zone_id';
  String? id;
  String? firstName;
  String?firebaseId;
  String? lastName;
  String? email;
  String? profilePictureURL;
  String? fcmToken;
  String? countryCode;
  String? phoneNumber;
  num? walletAmount;
  bool? active;
  bool? isActive;
  bool? isDocumentVerify;
  Timestamp? createdAt;
  String? role;
  UserLocation? location;
  UserBankDetails? userBankDetails;
  List<ShippingAddress>? shippingAddress;
  String? carName;
  String? carNumber;
  String? carPictureURL;
  List<dynamic>? inProgressOrderID;
  List<dynamic>? orderRequestData;
  String? vendorID;
  String? zoneId;
  num? rotation;
  String? appIdentifier;
  String? provider;
  String? subscriptionPlanId;
  Timestamp? subscriptionExpiryDate;
  Map<String, dynamic>? subscriptionPlan;
  // these are new fields
  String? merchantName;
  String? merchantBusinessType;
  String? dob;
  String? status;
  String? merchantId;
  String? accountNumber;
  String? ifscCode;
  String? bankName;
  String? accountHolderName;
  String? userType;
  int? bankId;
  int? recipientId;


  UserModel(
      {this.id,
      this.firstName,
        this.firebaseId,
      this.lastName,
      this.active,
      this.isActive,
      this.isDocumentVerify,
      this.email,
      this.profilePictureURL,
      this.fcmToken,
      this.countryCode,
      this.phoneNumber,
      this.walletAmount,
      this.createdAt,
      this.role,
      this.location,
      this.shippingAddress,
      this.carName,
      this.carNumber,
      this.carPictureURL,
      this.inProgressOrderID,
      this.orderRequestData,
      this.vendorID,
      this.zoneId,
      this.rotation,
      this.appIdentifier,
      this.provider,
      this.subscriptionPlanId,
      this.subscriptionExpiryDate,
      this.subscriptionPlan,
      this.merchantName,
        this.merchantBusinessType,
        this.dob,
        this.status,
        this.merchantId,
        this.accountNumber,
        this.ifscCode,
        this.bankName,
        this.accountHolderName,
        this.userType,
        this.bankId,
        this.recipientId
      });


  fullName() {
    return "${firstName ?? ''} ${lastName ?? ''}";
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    // Handle id field: convert int to String if needed
    if (json['id'] != null) {
      if (json['id'] is int) {
        id = json['id'].toString();
      } else if (json['id'] is String) {
        id = json['id'];
      } else {
        id = json['id']?.toString();
      }
    } else {
      id = null;
    }

    zoneId = json['zoneId'] ?? '';
    email = json['email'];
    firstName = json['firstName'];
    firebaseId = json['firebase_id'];
    lastName = json['lastName'];
    profilePictureURL = json['profilePictureURL'] ?? json['profile_pic'];
    fcmToken = json['fcmToken'];
    countryCode = json['countryCode'];
    phoneNumber = json['phone'] ?? json['phoneNumber'];

    // Handle wallet_amount for both int and double values
    if (json['wallet_amount'] != null) {
      if (json['wallet_amount'] is int) {
        walletAmount = json['wallet_amount'].toDouble();
      } else if (json['wallet_amount'] is double) {
        walletAmount = json['wallet_amount'];
      } else if (json['wallet_amount'] is String) {
        walletAmount = double.tryParse(json['wallet_amount']) ?? 0;
      } else {
        walletAmount = 0;
      }
    } else {
      walletAmount = 0;
    }

    // Handle createdAt safely
    createdAt = _parseTimestamp(json['createdAt'] ?? json['_created_at']);

    // Handle boolean conversions safely
    active = _parseBool(json['active']);
    isActive = _parseBool(json['isActive']);
    isDocumentVerify = _parseBool(json['isDocumentVerify']);

    role = json['role'] ?? 'user';
    location = json['location'] != null
        ? UserLocation.fromJson(json['location'])
        : null;
    try {
      if (json['userBankDetails'] != null && json['userBankDetails'] is Map) {
        userBankDetails = UserBankDetails.fromJson(json['userBankDetails'] as Map<String, dynamic>);
      } else {
        userBankDetails = null;
      }
    } catch (e) {
      print('Error parsing userBankDetails: $e');
      userBankDetails = null;
    }
    // FIX: Handle shippingAddress with better error handling
    shippingAddress = _parseShippingAddress(json['shippingAddress']);

    carName = json['carName'];
    carNumber = json['carNumber'];
    carPictureURL = json['carPictureURL'];
    inProgressOrderID = json['inProgressOrderID'];
    orderRequestData = json['orderRequestData'];
    vendorID = json['vendorID'] ?? '';

    // Handle rotation field: convert String to num if needed
    if (json['rotation'] != null) {
      if (json['rotation'] is num) {
        rotation = json['rotation'];
      } else if (json['rotation'] is String) {
        rotation = num.tryParse(json['rotation']) ?? 0;
      }
    }
    appIdentifier = json['appIdentifier'];
    provider = json['provider'];
    // Add lines for ui in java fields(start)
    merchantId = json['merchantId']?.toString();
    merchantName = json['merchantName'];
    // merchantBusinessType = json['merchantBusinessType'];
    merchantBusinessType =
        json['merchantBusinessType'] ?? json['businessType'];
    dob = json['dob'];
    status = json['status'];
    email = json['merchantEmail'] ?? json['email'];
    phoneNumber = json['merchantPhone'] ?? json['phoneNumber'] ?? json['phone'];
    accountNumber = json['accountNumber'];
    ifscCode = json['ifscCode'];
    bankName = json['bankName'];
    accountHolderName = json['accountHolderName'];
    userType = json['userType'];
    bankId = json['bankId'];
    recipientId = json['recipientId'];
    //(end)
    subscriptionPlanId = json['subscriptionPlanId'];
    subscriptionExpiryDate = _parseTimestamp(json['subscriptionExpiryDate']);
    if (json['subscription_plan'] != null && json['subscription_plan'] is Map) {
      subscriptionPlan = Map<String, dynamic>.from(json['subscription_plan']);
    } else {
      subscriptionPlan = null;
    }
  }
// Helper method to parse shippingAddress with better error handling
  List<ShippingAddress>? _parseShippingAddress(dynamic shippingAddressData) {
    if (shippingAddressData == null) return null;

    final List<ShippingAddress> addresses = [];

    try {
      if (shippingAddressData is String) {
        // Clean the string - remove any extra quotes or escape characters
        String cleanedString = shippingAddressData;

        // Remove outer quotes if they exist
        if (cleanedString.startsWith('"') && cleanedString.endsWith('"')) {
          cleanedString = cleanedString.substring(1, cleanedString.length - 1);
        }

        // Unescape the string
        cleanedString = cleanedString.replaceAll(r'\"', '"');

        // Try to parse as JSON
        final decoded = jsonDecode(cleanedString);

        if (decoded is List) {
          for (var item in decoded) {
            if (item is Map<String, dynamic>) {
              addresses.add(ShippingAddress.fromJson(item));
            } else if (item is Map) {
              // Try to cast it
              addresses.add(ShippingAddress.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
      } else if (shippingAddressData is List) {
        // It's already a list
        for (var item in shippingAddressData) {
          if (item is Map<String, dynamic>) {
            addresses.add(ShippingAddress.fromJson(item));
          } else if (item is Map) {
            addresses.add(ShippingAddress.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
    } catch (e) {
      print('Error parsing shippingAddress: $e - Data: $shippingAddressData');
    }

    return addresses.isNotEmpty ? addresses : null;
  }
// Add this helper method to parse Timestamp from various types
  Timestamp? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) return value;

    if (value is String) {
      // Handle the case where the string might be wrapped in extra quotes
      String dateString = value.replaceAll('"', '');
      try {
        DateTime dateTime = DateTime.parse(dateString);
        return Timestamp.fromDate(dateTime);
      } catch (e) {
        print('Error parsing date: $value - $e');
        return null;
      }
    }

    if (value is int) {
      return Timestamp.fromMillisecondsSinceEpoch(value);
    }

    return null;
  }

// Your existing _parseBool method (keep this)
  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) {
      return value == 1;
    }
    return false;
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['zoneId'] = zoneId;
    data['firstName'] = firstName;
    data['firebase_id'] = firebaseId;
    data['lastName'] = lastName;
    data['profilePictureURL'] = profilePictureURL;
    data['fcmToken'] = fcmToken;
    data['countryCode'] = countryCode;
    data['phoneNumber'] = phoneNumber;
    data['wallet_amount'] = walletAmount ?? 0;
    data['createdAt'] = createdAt;
    data['active'] = active;
    data['role'] = role;
    data['isDocumentVerify'] = isDocumentVerify;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (userBankDetails != null) {
      data['userBankDetails'] = userBankDetails!.toJson();
    }
    if (shippingAddress != null) {
      data['shippingAddress'] =
          shippingAddress!.map((v) => v.toJson()).toList();
    }
    if (role == Constant.userRoleDriver) {
      data['vendorID'] = vendorID;
      data['isActive'] = isActive;
      data['carName'] = carName;
      data['carNumber'] = carNumber;
      data['carPictureURL'] = carPictureURL;
      data['inProgressOrderID'] = inProgressOrderID;
      data['orderRequestData'] = orderRequestData;
      data['rotation'] = rotation;
    }
    if (role == Constant.userRoleVendor) {
      data['vendorID'] = vendorID;
      data['subscriptionPlanId'] = subscriptionPlanId;
      data['subscriptionExpiryDate'] = subscriptionExpiryDate;
      data['subscription_plan'] = subscriptionPlan;
    }
    data['appIdentifier'] = appIdentifier;
    data['provider'] = provider;
    // adding lines for java useage(start)json
    data['merchantId'] = merchantId;
    data['merchantName'] = merchantName;
    data['merchantBusinessType'] = merchantBusinessType;
    data['dob'] = dob;
    data['status'] = status;
    data['merchantEmail'] = email;
    data['merchantPhone'] = phoneNumber;
    data['accountNumber'] = accountNumber;
    data['ifscCode'] = ifscCode;
    data['bankName'] = bankName;
    data['accountHolderName'] = accountHolderName;
    data['userType'] = userType;
    data['bankId'] = bankId;
    data['recipientId'] = recipientId;

    //end
    return data;
  }
}

class UserLocation {
  double? latitude;
  double? longitude;

  UserLocation({this.latitude, this.longitude});

  UserLocation.fromJson(Map<String, dynamic> json) {
    // Handle int, double, and string types from API
    if (json['latitude'] != null) {
      if (json['latitude'] is String) {
        latitude = double.tryParse(json['latitude'] as String);
      } else if (json['latitude'] is int) {
        latitude = (json['latitude'] as int).toDouble();
      } else {
        latitude = (json['latitude'] as num?)?.toDouble();
      }
    }
    if (json['longitude'] != null) {
      if (json['longitude'] is String) {
        longitude = double.tryParse(json['longitude'] as String);
      } else if (json['longitude'] is int) {
        longitude = (json['longitude'] as int).toDouble();
      } else {
        longitude = (json['longitude'] as num?)?.toDouble();
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class ShippingAddress {
  String? id;
  String? address;
  String? addressAs;
  String? landmark;
  String? locality;
  UserLocation? location;
  bool? isDefault;

  ShippingAddress(
      {this.address,
      this.landmark,
      this.locality,
      this.location,
      this.isDefault,
      this.addressAs,
      this.id});

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    landmark = json['landmark'];
    locality = json['locality'];
    isDefault = _parseBoolNullable(json['isDefault']);
    addressAs = json['addressAs'];
    location = json['location'] == null
        ? null
        : UserLocation.fromJson(json['location']);
  }

  // Helper method to parse bool from int, bool, or String
  static bool? _parseBoolNullable(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true' || value == '1') return true;
      if (value.toLowerCase() == 'false' || value == '0') return false;
      return null;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address'] = address;
    data['landmark'] = landmark;
    data['locality'] = locality;
    data['isDefault'] = isDefault;
    data['addressAs'] = addressAs;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    return data;
  }

  String getFullAddress() {
    return '${address == null || address!.isEmpty ? "" : address} $locality ${landmark == null || landmark!.isEmpty ? "" : landmark.toString()}';
  }
}

class UserBankDetails {
  String bankName;
  String branchName;
  String holderName;
  String accountNumber;
  String otherDetails;

  UserBankDetails({
    this.bankName = '',
    this.otherDetails = '',
    this.branchName = '',
    this.accountNumber = '',
    this.holderName = '',
  });

  factory UserBankDetails.fromJson(Map<String, dynamic> parsedJson) {
    return UserBankDetails(
      bankName: parsedJson['bankName'] ?? '',
      branchName: parsedJson['branchName'] ?? '',
      holderName: parsedJson['holderName'] ?? '',
      accountNumber: parsedJson['accountNumber'] ?? '',
      otherDetails: parsedJson['otherDetails'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'branchName': branchName,
      'holderName': holderName,
      'accountNumber': accountNumber,
      'otherDetails': otherDetails,
    };
  }
}
