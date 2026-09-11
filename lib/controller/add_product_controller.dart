// import 'dart:developer';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:jippymart_restaurant/constant/collection_name.dart';
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
// import 'package:jippymart_restaurant/models/AttributesModel.dart';
// import 'package:jippymart_restaurant/models/product_model.dart';
// import 'package:jippymart_restaurant/models/vendor_category_model.dart';
// import 'package:jippymart_restaurant/app/product_screens/controllers/product_list_controller.dart';
// import 'package:jippymart_restaurant/models/vendor_model.dart';
// import 'package:jippymart_restaurant/models/selected_product_model.dart';
// import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
//
// class AddProductController extends GetxController {
//   final ProductModel? productToEdit;
//
//   AddProductController({this.productToEdit});
//
//   RxBool isLoading = true.obs;
//   Rx<TextEditingController> attributesValueController =
//       TextEditingController().obs;
//
//   Rx<TextEditingController> productTitleController =
//       TextEditingController().obs;
//   Rx<TextEditingController> productDescriptionController =
//       TextEditingController().obs;
//   Rx<TextEditingController> regularPriceController =
//       TextEditingController().obs;
//   Rx<TextEditingController> discountedPriceController =
//       TextEditingController().obs;
//   Rx<TextEditingController> productQuantityController =
//       TextEditingController().obs;
//   Rx<TextEditingController> caloriesController = TextEditingController().obs;
//   Rx<TextEditingController> gramsController = TextEditingController().obs;
//   Rx<TextEditingController> proteinController = TextEditingController().obs;
//   Rx<TextEditingController> fatsController = TextEditingController().obs;
//
//   Rx<ItemAttribute?> itemAttributes =
//       ItemAttribute(attributes: [], variants: []).obs;
//
//   RxList<VendorCategoryModel> vendorCategoryList = <VendorCategoryModel>[].obs;
//   Rx<VendorCategoryModel> selectedProductCategory = VendorCategoryModel().obs;
//
//   final myKey1 = GlobalKey<DropdownSearchState<AttributesModel>>();
//
//   Rx<ProductModel> productModel = ProductModel().obs;
//   Rx<VendorModel> vendorModel = VendorModel().obs;
//   RxList<ProductModel> productList = <ProductModel>[].obs;
//   RxList images = <dynamic>[].obs;
//
//   RxList<AttributesModel> attributesList = <AttributesModel>[].obs;
//   RxList<AttributesModel> selectedAttributesList = <AttributesModel>[].obs;
//
//
//   RxList<ProductSpecificationModel> specificationList =
//       <ProductSpecificationModel>[].obs;
//   RxList<ProductSpecificationModel> addonsList =
//       <ProductSpecificationModel>[].obs;
//
//   RxString title = "".obs;
//
//   RxBool isPublish = true.obs;
//   RxBool isPureVeg = true.obs;
//   RxBool isNonVeg = false.obs;
//
//   RxBool takeAway = false.obs;
//   RxBool isDiscountedPriceOk = false.obs;
//
//   /// Per-day availability copied from / compatible with `SelectedProductModel`.
//   /// UI edits these, and at save time they are serialized into
//   /// `productModel.availableTimings` to send to backend.
//   RxList<String> availableDays = <String>[].obs;
//   RxMap<String, List<TimeRangeItem>> availableTimings =
//       <String, List<TimeRangeItem>>{}.obs;
//
//   @override
//   void onInit() {
//     // TODO: implement onInit
//     getArgument();
//     priceAndDiscountPriceListen();
//     super.onInit();
//   }
//
//   addAttribute(String id) {
//     ItemAttribute? itemAttribute = itemAttributes.value;
//     List<Attributes>? attributesList = itemAttribute!.attributes;
//     attributesList!.add(Attributes(attributeId: id, attributeOptions: []));
//     itemAttributes.value = itemAttribute;
//     update();
//   }
//
//   /// Update a variant's title (sku) or price at [index]. Reassigns [itemAttributes] so UI updates.
//   void updateVariantAt(int index, {String? variantSku, String? variantPrice}) {
//     final att = itemAttributes.value;
//     if (att == null || att.variants == null || index < 0 || index >= att.variants!.length) return;
//     final newVariants = List<Variants>.from(att.variants!);
//     final v = newVariants[index];
//     if (variantSku != null) v.variantSku = variantSku;
//     if (variantPrice != null) v.variantPrice = variantPrice;
//     itemAttributes.value = ItemAttribute(attributes: att.attributes, variants: newVariants);
//   }
//
//   RxDouble regularPrice = 0.0.obs;
//   RxDouble discountPrice = 0.0.obs;
//   RxDouble merchant_price = 0.0.obs;
//   priceAndDiscountPriceListen() {
//     regularPriceController.value.addListener(() {
//       regularPrice.value = double.parse(
//           regularPriceController.value.text.trim().isEmpty
//               ? '0.0'
//               : regularPriceController.value.text.trim());
//       if (merchant_price.value != 0.0 &&
//           merchant_price.value < merchant_price.value) {
//         ShowToastDialog.showToast(
//             "Enter a regular price greater than the discount price.".tr);
//       }
//     });
//     discountedPriceController.value.addListener(() {
//       discountPrice.value = double.parse(
//           discountedPriceController.value.text.trim().isEmpty
//               ? '0.0'
//               : discountedPriceController.value.text.trim());
//
//       if (regularPrice.value != 0.0 &&
//           discountPrice.value > regularPrice.value) {
//         isDiscountedPriceOk.value = true;
//         ShowToastDialog.showToast(
//             "Enter a discount price less than the regular price.".tr);
//       } else {
//         isDiscountedPriceOk.value = false;
//       }
//       update();
//     });
//   }
//
//   @override
//   void onClose() {
//     attributesValueController.value.dispose();
//     productTitleController.value.dispose();
//     productDescriptionController.value.dispose();
//     regularPriceController.value.dispose();
//     discountedPriceController.value.dispose();
//     productQuantityController.value.dispose();
//     caloriesController.value.dispose();
//     gramsController.value.dispose();
//     proteinController.value.dispose();
//     fatsController.value.dispose();
//     super.onClose();
//   }
//   getArgument() async {
//     if (Constant.userModel!.vendorID != null &&
//         Constant.userModel!.vendorID!.isNotEmpty) {
//       await FireStoreUtils.getVendorById(Constant.userModel!.vendorID.toString()).then((value) {
//         if (value != null) {
//           vendorModel.value = value;
//         }
//       });
//     }
//
//     await FireStoreUtils.getAllMasterCategories().then((value) {
//       if (value != null) {
//         vendorCategoryList.value = value;
//       }
//     });
//
//     await FireStoreUtils.getAttributes().then((value) {
//       if (value != null) {
//         attributesList.value = value;
//       }
//     });
//
//     await FireStoreUtils.getProduct().then((value) {
//       if (value != null) {
//         productList.value = value;
//         log("ProductList :: ${productList.length}");
//       }
//     });
//
//     ProductModel? editProduct = productToEdit;
//     if (editProduct == null) {
//       final argumentData = Get.arguments;
//       if (argumentData != null && argumentData is Map && argumentData['productModel'] != null) {
//         editProduct = argumentData['productModel'] as ProductModel;
//       }
//     }
//     if (editProduct != null) {
//       productModel.value = editProduct;
//
//       final photosList = editProduct.photos;
//       if (photosList != null && photosList.isNotEmpty) {
//         images.clear();
//         for (var element in photosList) {
//           images.add(element);
//         }
//       }
//
//       isPublish.value = editProduct.publish ?? false;
//       productTitleController.value.text = editProduct.name?.toString() ?? '';
//       productDescriptionController.value.text = editProduct.description?.toString() ?? '';
//       regularPriceController.value.text = editProduct.merchant_price?.toString() ?? editProduct.price?.toString() ?? '0';
//       discountedPriceController.value.text = editProduct.disPrice?.toString() ?? '0';
//       productQuantityController.value.text = editProduct.quantity?.toString() ?? '0';
//
//       caloriesController.value.text = editProduct.calories?.toString() ?? '0';
//       gramsController.value.text = editProduct.grams?.toString() ?? '0';
//       fatsController.value.text = editProduct.fats?.toString() ?? '0';
//       proteinController.value.text = editProduct.proteins?.toString() ?? '0';
//       isPureVeg.value = editProduct.veg ?? true;
//       isNonVeg.value = editProduct.nonveg ?? false;
//       takeAway.value = editProduct.takeawayOption ?? false;
//
//       if (editProduct.productSpecification != null && editProduct.productSpecification!.isNotEmpty) {
//         specificationList.clear();
//         editProduct.productSpecification!.forEach((key, value) {
//           specificationList.add(ProductSpecificationModel(lable: key, value: value.toString()));
//         });
//       }
//
//       itemAttributes.value = editProduct.itemAttribute ?? ItemAttribute(attributes: [], variants: []);
//
//       if (editProduct.itemAttribute?.attributes != null && editProduct.itemAttribute!.attributes!.isNotEmpty) {
//         selectedAttributesList.clear();
//         for (var element in editProduct.itemAttribute!.attributes!) {
//           try {
//             final attributesModel = attributesList.firstWhere((product) => product.id == element.attributeId);
//             selectedAttributesList.add(attributesModel);
//           } catch (_) {}
//         }
//       }
//       if (editProduct.addOnsTitle != null && editProduct.addOnsPrice != null && editProduct.addOnsTitle!.isNotEmpty) {
//         final list = <ProductSpecificationModel>[];
//         for (int i = 0; i < editProduct.addOnsTitle!.length; i++) {
//           if (i < editProduct.addOnsPrice!.length) {
//             list.add(ProductSpecificationModel(
//               lable: editProduct.addOnsTitle![i].toString(),
//               value: editProduct.addOnsPrice![i].toString(),
//             ));
//           }
//         }
//         addonsList.assignAll(list);
//       }
//
//       if (editProduct.categoryID != null) {
//         for (var element in vendorCategoryList) {
//           if (element.id == editProduct!.categoryID) {
//             selectedProductCategory.value = element;
//             break;
//           }
//         }
//       }
//
//       // Initialize availability if backend sent any timings
//       if (editProduct.availableTimings != null &&
//           editProduct.availableTimings!.isNotEmpty) {
//         availableDays.clear();
//         availableTimings.clear();
//         for (final item in editProduct.availableTimings!) {
//           if (item is Map) {
//             final day = item['day']?.toString();
//             if (day == null || day.isEmpty) continue;
//             final slotsRaw = item['timeslot'];
//             final slots = <TimeRangeItem>[];
//             if (slotsRaw is List) {
//               for (final s in slotsRaw) {
//                 if (s is Map) {
//                   final productAvailableTimingId =
//                       int.tryParse(
//                         s['productAvailableTimingId']?.toString() ?? '',
//                       ) ?? 0;
//
//                   final from = s['from']?.toString() ?? '';
//                   final to = s['to']?.toString() ?? '';
//                   if (from.isNotEmpty && to.isNotEmpty) {
//                     slots.add(TimeRangeItem(
//                         productAvailableTimingId: productAvailableTimingId,from: from, to: to));
//                   }
//                 }
//               }
//             }
//             if (slots.isNotEmpty) {
//               availableDays.add(day);
//               availableTimings[day] = slots;
//             }
//           }
//         }
//       }
//     }
//
//     isLoading.value = false;
//   }
//   // getArgument() async {
//   //   if (Constant.userModel!.vendorID != null &&
//   //       Constant.userModel!.vendorID!.isNotEmpty) {
//   //     await FireStoreUtils.getVendorById(
//   //             Constant.userModel!.vendorID.toString())
//   //         .then((value) {
//   //       if (value != null) {
//   //         vendorModel.value = value;
//   //       }
//   //     });
//   //   }
//   //
//   //   await FireStoreUtils.getVendorCategoryById().then((value) {
//   //     if (value != null) {
//   //       vendorCategoryList.value = value;
//   //     }
//   //   });
//   //
//   //   await FireStoreUtils.getAttributes().then((value) {
//   //     if (value != null) {
//   //       attributesList.value = value;
//   //     }
//   //   });
//   //   await FireStoreUtils.fireStore
//   //       .collection(CollectionName.vendorProducts)
//   //       .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
//   //       .where('createdAt',
//   //           isGreaterThan: Constant.userModel?.subscriptionPlan?.createdAt)
//   //       .get()
//   //       .then((value) {
//   //     for (var element in value.docs) {
//   //       ProductModel productModel = ProductModel.fromJson(element.data());
//   //       productList.add(productModel);
//   //       log("ProductList :: ${productList.length}");
//   //     }
//   //   });
//   //
//   //   dynamic argumentData = Get.arguments;
//   //   if (argumentData != null) {
//   //     productModel.value = argumentData['productModel'];
//   //
//   //     for (var element in productModel.value.photos!) {
//   //       images.add(element);
//   //     }
//   //
//   //     isPublish.value = productModel.value.publish ?? false;
//   //     productTitleController.value.text = productModel.value.name.toString();
//   //     productDescriptionController.value.text =
//   //         productModel.value.description.toString();
//   //     regularPriceController.value.text = productModel.value.price.toString();
//   //     discountedPriceController.value.text =
//   //         productModel.value.disPrice.toString();
//   //     productQuantityController.value.text =
//   //         productModel.value.quantity.toString();
//   //
//   //     caloriesController.value.text = productModel.value.calories.toString();
//   //     gramsController.value.text = productModel.value.grams.toString();
//   //     fatsController.value.text = productModel.value.fats.toString();
//   //     proteinController.value.text = productModel.value.proteins.toString();
//   //     isPureVeg.value = productModel.value.veg ?? true;
//   //     isNonVeg.value = productModel.value.nonveg ?? false;
//   //     takeAway.value = productModel.value.takeawayOption ?? false;
//   //     if (productModel.value.productSpecification != null) {
//   //       productModel.value.productSpecification!.forEach((key, value) {
//   //         specificationList
//   //             .add(ProductSpecificationModel(lable: key, value: value));
//   //       });
//   //     }
//   //
//   //     itemAttributes.value =
//   //         productModel.value.itemAttribute ?? ItemAttribute();
//   //
//   //     if (productModel.value.itemAttribute != null) {
//   //       for (var element in productModel.value.itemAttribute!.attributes!) {
//   //         AttributesModel attributesModel = attributesList
//   //             .firstWhere((product) => product.id == element.attributeId);
//   //         selectedAttributesList.add(attributesModel);
//   //       }
//   //     }
//   //
//   //     for (var element in productModel.value.addOnsTitle!) {
//   //       addonsList.add(ProductSpecificationModel(
//   //           lable: element,
//   //           value: productModel.value.addOnsPrice![
//   //               productModel.value.addOnsTitle!.indexOf(element)]));
//   //     }
//   //
//   //     for (var element in vendorCategoryList) {
//   //       if (element.id == productModel.value.categoryID) {
//   //         selectedProductCategory.value = element;
//   //       }
//   //     }
//   //   }
//   //
//   //   isLoading.value = false;
//   // }
//
//   Map<String, dynamic> specification = {};
//
//   /// Helper to serialize availability into backend JSON structure:
//   /// `[{"day":"Monday","timeslot":[{"from":"11:00","to":"22:00"}]}]`
//   List<Map<String, dynamic>> get availabilityJson => availableDays
//       .map((day) => {
//             'day': day,
//             'timeslot':
//                 (availableTimings[day] ?? []).map((t) => t.toJson()).toList(),
//           })
//       .toList();
//
//   saveDetails() async {
//     // if(selectedAttributesList.isNotEmpty){
//     //   if(itemAttributes.value!.attributes!.isNotEmpty){
//     //     if(itemAttributes.value!.variants!.isEmpty){
//     //       isAttributeNotAvailable.value = true;
//     //     }
//     //   }
//     // }else{
//     //   isAttributeNotAvailable.value = false;
//     // }
//     if (selectedProductCategory.value.id == null) {
//       ShowToastDialog.showToast("Please Select category".tr);
//     } else if (productTitleController.value.text.isEmpty) {
//       ShowToastDialog.showToast("Please enter title".tr);
//     } else if (productDescriptionController.value.text.isEmpty) {
//       ShowToastDialog.showToast("Please enter description".tr);
//     } else if (regularPriceController.value.text.isEmpty) {
//       ShowToastDialog.showToast("Please enter valid regular price".tr);
//     } else if (isDiscountedPriceOk.value == true) {
//       ShowToastDialog.showToast("Please enter valid discount price".tr);
//     } else if (productQuantityController.value.text.isEmpty) {
//       ShowToastDialog.showToast("Please enter product quantity");
//     } else if (double.parse(regularPriceController.value.text.toString()) <=
//         0) {
//       ShowToastDialog.showToast("Please enter valid regular price".tr);
//     } else {
//       specification.clear();
//       for (var element in specificationList) {
//         if (element.value!.isNotEmpty && element.lable!.isNotEmpty) {
//           specification
//               .addEntries([MapEntry(element.lable.toString(), element.value)]);
//         }
//       }
//       // if (itemAttributes.value!.attributes!.isEmpty || itemAttributes.value!.variants!.isEmpty) {
//       //   itemAttributes.value = null;
//       // }
//       ShowToastDialog.showLoader("Please wait".tr);
//       for (int i = 0; i < images.length; i++) {
//         if (images[i].runtimeType == XFile) {
//           String url = await Constant.uploadUserImageToFireStorage(
//             File(images[i].path),
//             "profileImage/${FireStoreUtils.getCurrentUid()}",
//             File(images[i].path).path.split('/').last,
//           );
//           images.removeAt(i);
//           images.insert(i, url);
//         }
//       }
//       List listAddTitle = [];
//       List listAddPrice = [];
//       for (var element in addonsList) {
//         if (element.value!.isNotEmpty && element.lable!.isNotEmpty) {
//           listAddTitle.add(element.lable.toString());
//           listAddPrice.add(element.value.toString());
//         }
//       }
//       productModel.value.id = productModel.value.id
//           ?? Constant.getUuid();
//       productModel.value.photo = images.isNotEmpty ? images.first : "";
//       productModel.value.photos = images;
//       productModel.value.price = regularPriceController.value.text.toString();
//       productModel.value.merchant_price = regularPriceController.value.text.toString();
//       productModel.value.disPrice =
//           discountedPriceController.value.text.toString().isEmpty
//               ? "0"
//               : discountedPriceController.value.text.toString();
//       productModel.value.quantity =
//           int.parse(productQuantityController.value.text);
//       productModel.value.description = productDescriptionController.value.text;
//       productModel.value.calories = int.parse(
//           caloriesController.value.text.isEmpty
//               ? "0"
//               : caloriesController.value.text);
//       productModel.value.grams = int.parse(gramsController.value.text.isEmpty
//           ? "0"
//           : gramsController.value.text);
//       productModel.value.proteins = int.parse(
//           proteinController.value.text.isEmpty
//               ? "0"
//               : proteinController.value.text);
//       productModel.value.fats = int.parse(
//           fatsController.value.text.isEmpty ? "0" : fatsController.value.text);
//       productModel.value.name = productTitleController.value.text;
//       productModel.value.veg = isPureVeg.value;
//       productModel.value.nonveg = isNonVeg.value;
//       productModel.value.publish = isPublish.value;
//       productModel.value.vendorID = Constant.userModel!.vendorID;
//       productModel.value.categoryID =
//           selectedProductCategory.value.id.toString();
//       productModel.value.itemAttribute =
//           ((itemAttributes.value!.attributes == null ||
//                       itemAttributes.value!.attributes!.isEmpty) &&
//                   (itemAttributes.value!.variants == null ||
//                       itemAttributes.value!.variants!.isEmpty))
//               ? null
//               : itemAttributes.value;
//       productModel.value.addOnsTitle = listAddTitle;
//       productModel.value.addOnsPrice = listAddPrice;
//       productModel.value.takeawayOption = takeAway.value;
//       productModel.value.productSpecification = specification;
//       productModel.value.createdAt = Timestamp.now();
//       // Attach availability timings, if any selected.
//       if (availableDays.isNotEmpty) {
//         productModel.value.availableTimings = availabilityJson;
//       } else {
//         productModel.value.availableTimings = null;
//       }
//       // await FireStoreUtils.updateProduct(productModel.value);
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast("Product saved successfully".tr);
//       Get.back(result: true);
//       // Product list screen refreshes via .then((value) { if (value == true) controller.getProduct(); })
//     }
//   }
//   final ImagePicker _imagePicker = ImagePicker();
//   Future pickFile({required ImageSource source}) async {
//     try {
//       XFile? image = await _imagePicker.pickImage(source: source);
//       if (image == null) return;
//       images.clear();
//       images.add(image);
//       Get.back();
//     } on PlatformException catch (e) {
//       ShowToastDialog.showToast("${"Failed to Pick :".tr} \n $e");
//     }
//   }
//
//   List<dynamic> getCombination(List<List<dynamic>> listArray) {
//     if (listArray.length == 1) {
//       return listArray[0];
//     } else {
//       List<dynamic> result = [];
//       var allCasesOfRest = getCombination(listArray.sublist(1));
//       for (var i = 0; i < allCasesOfRest.length; i++) {
//         for (var j = 0; j < listArray[0].length; j++) {
//           result.add(listArray[0][j] + "-" + allCasesOfRest[i]);
//         }
//       }
//       return result;
//     }
//   }
// }
