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
  });

  MerchantModel.fromJson(Map<String, dynamic> json) {
    merchantId = json['merchantId'];
    merchantName = json['merchantName'];
    merchantEmail = json['merchantEmail'];
    merchantPhone = json['merchantPhone'];
    merchantBusinessType = json['merchantBusinessType'];
    status = json['status'];

    isActive = json['isActive'];
    isApproved = json['isApproved'];
    createdAt = json['createdAt'];
  }
}