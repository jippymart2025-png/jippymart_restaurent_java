class MerchantRequestModel {
  String? firstName;
  String? lastName;
  String? dob;
  String? email;
  String? phone;
  String?username;
  String?password;
  String? outletType;
  String? uploadedBy;
  String? pan;
  String? adhar;
  String? fssai;
  String? gstNumber;
  String? accountNumber;
  String? ifscCode;
  String? bankLocation;
  String? nameInBankAccount;

  // NEW — address fields
  String? buildingNumber;
  String? road;
  String? landmark;
  int? stateId;
  int? cityId;
  int? areaId;
  String? latitude;
  String? longitude;

  MerchantRequestModel({
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
    // NEW
    this.buildingNumber,
    this.road,
    this.landmark,
    this.stateId,
    this.cityId,
    this.areaId,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "dob": dob,
      "email": email,
      "phone": phone,
      "username":username,
      "password":password,
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
      // NEW
      "buildingNumber": buildingNumber,
      "road": road,
      "landmark": landmark,
      "stateId": stateId,
      "cityId": cityId,
      "areaId": areaId,
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}