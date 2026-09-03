class CreateMasterProductRequest {
  final int categoryId;
  final String masterProductName;
  final String description;
  final String shortDescription;
  final String photo;
  final String photos;
  final String thumbnail;
  final bool isVeg;
  final String foodType;
  final String cuisineType;

  CreateMasterProductRequest({
    required this.categoryId,
    required this.masterProductName,
    required this.description,
    required this.shortDescription,
    this.photo = "",
    this.photos = "",
    this.thumbnail = "",
    required this.isVeg,
    this.foodType = "",
    this.cuisineType = "",
  });

  Map<String, dynamic> toJson() {
    return {
      "categoryId": categoryId,
      "masterProductName": masterProductName,
      "description": description,
      "shortDescription": shortDescription,
      "photo": photo,
      "photos": photos,
      "thumbnail": thumbnail,
      "isVeg": isVeg,
      "foodType": foodType,
      "cuisineType": cuisineType,
    };
  }
}

class CreateMasterProductResponse {
  final bool success;
  final String? message;
  final CreateMasterProductData? data;
  final List<String> errors;
  final String? timestamp;

  CreateMasterProductResponse({
    required this.success,
    this.message,
    this.data,
    required this.errors,
    this.timestamp,
  });

  factory CreateMasterProductResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return CreateMasterProductResponse(
      success: json["success"] ?? false,
      message: json["message"],
      data: json["data"] != null
          ? CreateMasterProductData.fromJson(
        json["data"],
      )
          : null,
      errors: json["errors"] != null
          ? List<String>.from(json["errors"])
          : [],
      timestamp: json["timestamp"],
    );
  }
}

class CreateMasterProductData {
  final int? masterProductId;
  final int? categoryId;
  final String? categoryName;
  final String? masterProductName;
  final String? photo;
  final String? thumbnail;
  final int? veg;
  final int? nonVeg;
  final int? publish;

  CreateMasterProductData({
    this.masterProductId,
    this.categoryId,
    this.categoryName,
    this.masterProductName,
    this.photo,
    this.thumbnail,
    this.veg,
    this.nonVeg,
    this.publish,
  });

  factory CreateMasterProductData.fromJson(
      Map<String, dynamic> json,
      ) {
    return CreateMasterProductData(
      masterProductId: json["masterProductId"],
      categoryId: json["categoryId"],
      categoryName: json["categoryName"],
      masterProductName: json["masterProductName"],
      photo: json["photo"],
      thumbnail: json["thumbnail"],
      veg: json["veg"],
      nonVeg: json["nonVeg"],
      publish: json["publish"],
    );
  }
}