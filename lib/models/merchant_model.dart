class MerchantModel {
  // =========================
  // Merchant basic information
  // =========================
  int? merchantId;

  String? merchantName;
  String? merchantEmail;
  String? merchantPhone;
  String? merchantBusinessType;

  String? firstName;
  String? lastName;
  String? dob;

  String? email;
  String? phone;

  // =========================
  // Login information
  // =========================
  String? username;
  String? password;

  // =========================
  // Merchant registration
  // =========================
  String? outletType;
  String? uploadedBy;

  String? pan;
  String? adhar;
  String? fssai;
  String? gstNumber;

  // =========================
  // Bank information
  // =========================
  String? accountNumber;
  String? ifscCode;

  String? bankLocation;
  String? nameInBankAccount;

  // Fields used by Update Merchant API
  int? bankId;
  String? recipientId;
  String? bankName;
  String? accountHolderName;

  // =========================
  // Status information
  // =========================
  String? status;
  String? isActive;
  bool? isApproved;
  String? createdAt;

  // =========================
  // User type
  // =========================
  String? userType;

  MerchantModel({
    this.merchantId,
    this.merchantName,
    this.merchantEmail,
    this.merchantPhone,
    this.merchantBusinessType,
    this.firstName,
    this.lastName,
    this.dob,
    this.email,
    this.phone,
    this.username,
    this.password,
    this.outletType,
    this.uploadedBy,
    this.pan,
    this.adhar,
    this.fssai,
    this.gstNumber,
    this.accountNumber,
    this.ifscCode,
    this.bankLocation,
    this.nameInBankAccount,
    this.bankId,
    this.recipientId,
    this.bankName,
    this.accountHolderName,
    this.status,
    this.isActive,
    this.isApproved,
    this.createdAt,
    this.userType,
  });

  // =========================================================
  // FROM JSON
  // =========================================================

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      merchantId: json['merchantId'],

      merchantName: json['merchantName'],

      merchantEmail:
      json['merchantEmail'] ?? json['email'],

      merchantPhone:
      json['merchantPhone'] ?? json['phone'],

      merchantBusinessType:
      json['merchantBusinessType'] ??
          json['businessType'],

      firstName: json['firstName'],
      lastName: json['lastName'],
      dob: json['dob'],

      email: json['email'],

      phone: json['phone'],

      username: json['username'],
      password: json['password'],

      outletType: json['outletType'],
      uploadedBy: json['uploadedBy'],

      pan: json['pan'],
      adhar: json['adhar'],
      fssai: json['fssai'],
      gstNumber: json['gstNumber'],

      accountNumber: json['accountNumber'],
      ifscCode: json['ifscCode'],

      bankLocation: json['bankLocation'],
      nameInBankAccount: json['nameInBankAccount'],

      bankId: json['bankId'],
      recipientId: json['recipientId']?.toString(),
      bankName: json['bankName'],
      accountHolderName: json['accountHolderName'],

      status: json['status'],

      isActive: json['isActive']?.toString(),

      isApproved: json['isApproved'],

      createdAt: json['createdAt'],

      userType: json['userType'],
    );
  }

  // =========================================================
  // CREATE MERCHANT JSON
  // =========================================================

  Map<String, dynamic> toCreateJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "dob": dob,
      "email": email,
      "phone": phone,
      "username": username,
      "password": password,
      "outletType": outletType,
      "uploadedBy": uploadedBy,
      "pan": pan,
      "adhar": adhar,
      "fssai": fssai,
      "gstNumber": gstNumber,
      "accountNumber": accountNumber,
      "ifscCode": ifscCode,
      "bankLocation": bankLocation,
      "nameInBankAccount": nameInBankAccount,
    };
  }

  // =========================================================
  // UPDATE MERCHANT JSON
  // =========================================================

  Map<String, dynamic> toUpdateJson() {
    return {
      "merchantId": merchantId,
      "merchantName": merchantName,
      "businessType": merchantBusinessType,
      "status": status,
      "merchantEmail": merchantEmail ?? email,
      "merchantPhone": merchantPhone ?? phone,
      "bankId": bankId,
      "recipientId": recipientId,
      "accountNumber": accountNumber,
      "ifscCode": ifscCode,
      "bankName": bankName,
      "accountHolderName": accountHolderName,
      "userType": userType ?? "MERCHANT",
    };
  }
}