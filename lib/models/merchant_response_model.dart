class MerchantModel {
  int? merchantId;
  String? merchantName;
  String? merchantEmail;
  String? merchantPhone;
  String? merchantBusinessType;
  String? status;
  String? isActive;
  bool? isApproved;
  String? createdAt;

  // Personal info (for profile)
  String? firstName;
  String? lastName;
  String? dob;

  // Address info (for update)
  int? stateId;
  int? cityId;
  int? areaId;
  String? buildingNumber;
  String? road;
  String? landmark;
  String? stateName;
  String? cityName;
  String? areaName;

  // Bank info (for update)
  int? bankId;
  String? recipientId;
  String? bankName;
  String? accountHolderName;
  String? accountNumber;
  String? ifscCode;
  String? addharNumber;
  String? panNumber;

  // User type
  String? userType;

  // Document URLs (verification)
  String? aadhaarNumberUrl;
  String? panNumberUrl;

  MerchantModel({
    this.merchantId,
    this.merchantName,
    this.merchantEmail,
    this.merchantPhone,
    this.merchantBusinessType,
    this.status,
    this.isActive,
    this.isApproved,
    this.createdAt,
    this.firstName,
    this.lastName,
    this.dob,
    this.stateId,
    this.cityId,
    this.areaId,
    this.buildingNumber,
    this.road,
    this.landmark,
    this.stateName,
    this.cityName,
    this.areaName,
    this.bankId,
    this.recipientId,
    this.bankName,
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
    this.addharNumber,
    this.panNumber,
    this.userType,
    this.aadhaarNumberUrl,
    this.panNumberUrl,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    final address = _extractAddress(json);

    return MerchantModel(
      merchantId: json['merchantId'],
      merchantName: json['merchantName'],
      merchantEmail: json['merchantEmail'] ?? json['email'],
      merchantPhone: json['merchantPhone'] ?? json['phone'],
      merchantBusinessType: json['merchantBusinessType'] ?? json['businessType'],
      status: json['status'],
      isActive: json['isActive']?.toString(),
      isApproved: json['isApproved'],
      createdAt: json['createdAt'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dob: json['dob'],
      stateId: _parseInt(json['stateId'] ?? address['stateId']),
      cityId: _parseInt(json['cityId'] ?? address['cityId']),
      areaId: _parseInt(json['areaId'] ?? address['areaId']),
      buildingNumber:
          (json['buildingNumber'] ?? address['buildingNumber'])?.toString(),
      road: (json['road'] ?? address['road'])?.toString(),
      landmark: (json['landmark'] ?? address['landmark'])?.toString(),
      stateName: (json['stateName'] ?? address['stateName'])?.toString(),
      cityName: (json['cityName'] ?? address['cityName'])?.toString(),
      areaName: (json['areaName'] ?? address['areaName'])?.toString(),
      bankId: json['bankId'],
      recipientId: json['recipientId']?.toString(),
      bankName: json['bankName'],
      accountHolderName: json['accountHolderName'],
      accountNumber: json['accountNumber'],
      ifscCode: json['ifscCode'],
      addharNumber:json['aadharNumber'],
      panNumber: json['panNumber'],
      userType: json['userType'],
      aadhaarNumberUrl:
          json['aadhaarNumberUrl'] ?? json['aadharNumberUrl'],
      panNumberUrl: json['panNumberUrl'],
    );
  }

  /// The merchant profile API may return address fields either flattened on
  /// the merchant object or inside a nested address object.
  static Map<String, dynamic> _extractAddress(Map<String, dynamic> json) {
    for (final key in const ['address', 'merchantAddress']) {
      final value = json[key];
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      "merchantId": merchantId,
      "merchantName": merchantName,
      "merchantEmail": merchantEmail,
      "merchantPhone": merchantPhone,
      "merchantBusinessType": merchantBusinessType,
      "status": status,
      "isActive": isActive,
      "isApproved": isApproved,
      "createdAt": createdAt,
      "firstName": firstName,
      "lastName": lastName,
      "dob": dob,
      "stateId": stateId,
      "cityId": cityId,
      "areaId": areaId,
      "buildingNumber": buildingNumber,
      "road": road,
      "landmark": landmark,
      "stateName": stateName,
      "cityName": cityName,
      "areaName": areaName,
      "bankId": bankId,
      "recipientId": recipientId,
      "bankName": bankName,
      "accountHolderName": accountHolderName,
      "accountNumber": accountNumber,
      "ifscCode": ifscCode,
      "userType": userType,
      "aadhaarNumberUrl": aadhaarNumberUrl,
      "panNumberUrl": panNumberUrl,
      "addharNumber" : addharNumber,
      "panNumber" : panNumber
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      "merchantId": merchantId,
      "merchantName": merchantName,
      "businessType": merchantBusinessType,
      "status": status,
      "merchantEmail": merchantEmail,
      "merchantPhone": merchantPhone,
      "stateId": stateId,
      "cityId": cityId,
      "areaId": areaId,
      "buildingNumber": buildingNumber,
      "road": road,
      "landmark": landmark,
      "stateName": stateName,
      "cityName": cityName,
      "areaName": areaName,
      "bankId": bankId,
      "recipientId": recipientId,
      "accountNumber": accountNumber,
      "ifscCode": ifscCode,
      "bankName": bankName,
      "accountHolderName": accountHolderName,
      "userType": userType ?? "MERCHANT",
      "addharNumber" : addharNumber,
      "panNumber" : panNumber
    };
  }
}
