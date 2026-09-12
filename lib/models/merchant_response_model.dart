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
