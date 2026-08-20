import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/models/outlet_model.dart';
import '../utils/preferences.dart';

class EditProfileController extends GetxController {
  // ADDED fields
  RxBool isOutletMode = false.obs;
  Rx<OutletModel> outletModel = OutletModel().obs;
  int _activeOutletId = 0;

  Rx<TextEditingController> outletNameController = TextEditingController().obs;
  Rx<TextEditingController> cuisineTypeController = TextEditingController().obs;
  Rx<TextEditingController> outletPhoneController = TextEditingController().obs;
  Rx<TextEditingController> radiusController = TextEditingController().obs;
  // Address
  Rx<TextEditingController> buildingNumberController = TextEditingController().obs;
  Rx<TextEditingController> roadController = TextEditingController().obs;
  Rx<TextEditingController> landmarkController = TextEditingController().obs;
  Rx<TextEditingController> areaController = TextEditingController().obs;
  RxInt selectedStateId = 0.obs;
  RxInt selectedCityId = 0.obs;
  RxInt selectedAreaId = 0.obs;
  // Dropdown data
  RxList<Map<String, dynamic>> states = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> cities = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> areas = <Map<String, dynamic>>[].obs;
  // Bank
  // Rx<TextEditingController> bankNameController = TextEditingController().obs;
  // Rx<TextEditingController> accountHolderNameController = TextEditingController().obs;
  // Rx<TextEditingController> accountNumberController = TextEditingController().obs;
  // Rx<TextEditingController> ifscCodeController = TextEditingController().obs;
  //end
  RxBool isLoading = true.obs;
  Rx<UserModel> userModel = UserModel().obs;

  Rx<TextEditingController> firstNameController = TextEditingController().obs;
  Rx<TextEditingController> lastNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeController = TextEditingController(text: "+91").obs;
  Rx<TextEditingController> merchantNameController = TextEditingController().obs;
  Rx<TextEditingController> businessTypeController = TextEditingController().obs;
  Rx<TextEditingController> dobController = TextEditingController().obs;
  Rx<TextEditingController> statusController = TextEditingController().obs;
  Rx<TextEditingController> accountNumberController = TextEditingController().obs;
  Rx<TextEditingController> ifscCodeController = TextEditingController().obs;
  Rx<TextEditingController> bankNameController = TextEditingController().obs;
  Rx<TextEditingController> accountHolderNameController = TextEditingController().obs;

  /// Cached for this screen session to avoid repeated getCurrentUid() calls.
  String? _userId;
  bool _isSaving = false;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  /// Load profile once: use Constant.userModel when already set for current user, else fetch (with cache).
  // Future<void> getData() async {
  //   final userId = await FireStoreUtils.getCurrentUid();
  //   _userId = userId;
  //
  //   UserModel? value;
  //   if (Constant.userModel != null && Constant.userModel!.id == userId) {
  //     value = Constant.userModel;
  //   } else {
  //     value = await FireStoreUtils.getUserProfile(userId, forceRefresh: false);
  //   }
  //
  //   if (value != null) {
  //     userModel.value = value;
  //     firstNameController.value.text = value.firstName ?? '';
  //     lastNameController.value.text = value.lastName ?? '';
  //     emailController.value.text = value.email ?? '';
  //     phoneNumberController.value.text = value.phoneNumber ?? '';
  //     countryCodeController.value.text = value.countryCode ?? '+91';
  //     profileImage.value = value.profilePictureURL ?? '';
  //   }
  //   isLoading.value = false;
  // }
// This is java related getData() method(start)
  Future<void> getData() async {
    // FOR GET OUTLET PROFILE
    final outletId = Preferences.getInt('outletId');
    isOutletMode.value = outletId > 0;

    if (isOutletMode.value) {
      _activeOutletId = outletId;
      final outlet = await FireStoreUtils.getOutletProfile(outletId);
      print("getOutletProfile result: ${outlet?.outletName}");

      if (outlet != null) {
        outletModel.value = outlet;
        outletNameController.value.text = outlet.outletName ?? '';
        emailController.value.text = outlet.outletEmail ?? '';
        outletPhoneController.value.text = outlet.outletPhone ?? '';
        cuisineTypeController.value.text = outlet.cuisineType ?? '';
        radiusController.value.text = outlet.radius?.toString() ?? '';
        profileImage.value = outlet.outletPicUrl ?? '';
        // Address
        buildingNumberController.value.text = outlet.buildingNumber ?? '';
        roadController.value.text = outlet.road ?? '';
        landmarkController.value.text = outlet.landmark ?? '';
        selectedStateId.value = outlet.stateId ?? 0;
        selectedCityId.value = outlet.cityId ?? 0;
        selectedAreaId.value = outlet.areaId ?? 0;
        // Bank
        accountNumberController.value.text = outlet.accountNumber ?? '';
        ifscCodeController.value.text = outlet.ifscCode ?? '';
        bankNameController.value.text = outlet.bankName ?? '';
        accountHolderNameController.value.text = outlet.accountHolderName ?? '';
      }
      isLoading.value = false;
      return;
    }

    final userId = await FireStoreUtils.getCurrentUid();
    _userId = userId;

    // String merchantId = Preferences.getString('merchantId');
    // UserModel? value;
    //
    // if (merchantId.isNotEmpty) {
    //   // Java API
    //   value = await FireStoreUtils.getMerchantProfile(merchantId);
    // } else {
    //   // Fallback
    //   if (Constant.userModel != null && Constant.userModel!.id == userId) {
    //     value = Constant.userModel;
    //   } else {
    //     value = await FireStoreUtils.getUserProfile(userId, forceRefresh: false);
    //   }
    // }
    // String merchantId = Preferences.getString('merchantId');

// REPLACE WITH — check preferences first, then userModel as fallback
//     String merchantId = Preferences.getString('merchantId');
//     if (merchantId.isEmpty) {
//       merchantId = Constant.userModel?.merchantId ?? '';
//     }
//     final value = await FireStoreUtils.getMerchantProfile(merchantId);
    final int merchantId = Preferences.getInt('userId');

    print(
      "merchantId from preferences = $merchantId",
    );

    final value =
    await FireStoreUtils.getMerchantProfile(
      merchantId.toString(),
    );
    print("merchantId from preferences = $merchantId");
//F
    print("merchantId = $merchantId");
    print("merchantName = ${value?.merchantName}");
    print("businessType = ${value?.merchantBusinessType}");
    print("email = ${value?.email}");
    print("phone = ${value?.phoneNumber}");
    print("bankName = ${value?.bankName}");
    print("bankNameController = ${bankNameController.value.text}");
    print("accountNumberController = ${accountNumberController.value.text}");
    print("merchantNameController = ${merchantNameController.value.text}");
    print("businessTypeController = ${businessTypeController.value.text}");

    //
    if (value != null) {
      userModel.value = value;
      // firstNameController.value.text = value.firstName ?? '';
      // lastNameController.value.text = value.lastName ?? '';

      emailController.value.text = value.email ?? '';
      phoneNumberController.value.text = value.phoneNumber ?? '';
      countryCodeController.value.text = value.countryCode ?? '+91';
      profileImage.value = value.profilePictureURL ?? '';

      // New fields
      merchantNameController.value.text = value.merchantName ?? '';
      businessTypeController.value.text = value.merchantBusinessType ?? '';

      // dobController.value.text = value.dob ?? '';
      statusController.value.text = value.status ?? '';
      accountNumberController.value.text = value.accountNumber ?? '';
      ifscCodeController.value.text = value.ifscCode ?? '';
      bankNameController.value.text = value.bankName ?? '';
      accountHolderNameController.value.text = value.accountHolderName ?? '';
      print("===== CONTROLLERS =====");
      print(bankNameController.value.text);
      print(accountNumberController.value.text);
      print(ifscCodeController.value.text);
      print(accountHolderNameController.value.text);
    }
    isLoading.value = false;
  }
//(end)
//   Future<void> saveData() async {
//     if (_isSaving) return;
//     _isSaving = true;
//     ShowToastDialog.showLoader("Please wait...".tr);
//     try {
//       if (Constant().hasValidUrl(profileImage.value) == false &&
//           profileImage.value.isNotEmpty) {
//         final pathId = _userId ?? userModel.value.id ?? await FireStoreUtils.getCurrentUid();
//         profileImage.value = await Constant.uploadUserImageToFireStorage(
//           File(profileImage.value),
//           "profileImage/$pathId",
//           File(profileImage.value).path.split('/').last,
//         );
//       }
//       userModel.value.firstName = firstNameController.value.text;
//       userModel.value.lastName = lastNameController.value.text;
//       userModel.value.profilePictureURL = profileImage.value;
//
//       final success = await FireStoreUtils.updateUser(userModel.value);
//       if (success) {
//         Get.back(result: true);
//       } else {
//         ShowToastDialog.showToast('Failed to update profile. Please try again.'.tr);
//       }
//     } catch (e) {
//       ShowToastDialog.showToast('${"Failed to save".tr}: $e');
//     } finally {
//       _isSaving = false;
//       ShowToastDialog.closeLoader();
//     }
//   }

// this is java related saveData() method (Start)
//   Future<void> saveData() async {
//     if (_isSaving) return;
//     _isSaving = true;
//     ShowToastDialog.showLoader("Please wait...".tr);
//     try {
//       // Upload image if changed
//       if (Constant().hasValidUrl(profileImage.value) == false &&
//           profileImage.value.isNotEmpty) {
//         final pathId = _userId ?? userModel.value.id ??
//             await FireStoreUtils.getCurrentUid();
//         profileImage.value = await Constant.uploadUserImageToFireStorage(
//           File(profileImage.value),
//           "profileImage/$pathId",
//           File(profileImage.value).path.split('/').last,
//         );
//       }
//
//     } catch (e) {
//       ShowToastDialog.showToast('${"Failed to save".tr}: $e');
//     } finally {
//       _isSaving = false;
//       ShowToastDialog.closeLoader();
//     }
//   }


  // Future<void> saveData() async {
  //   if (_isSaving) return;
  //   _isSaving = true;
  //   ShowToastDialog.showLoader("Please wait...".tr);
  //   try {
  //     // Upload image if changed
  //     if (Constant().hasValidUrl(profileImage.value) == false &&
  //         profileImage.value.isNotEmpty) {
  //       final pathId = _userId ?? userModel.value.id ??
  //           await FireStoreUtils.getCurrentUid();
  //       profileImage.value = await Constant.uploadUserImageToFireStorage(
  //         File(profileImage.value),
  //         "profileImage/$pathId",
  //         File(profileImage.value).path.split('/').last,
  //       );
  //     }
  //
  //     // ADD FROM HERE ↓
  //     // Update model with all fields
  //     userModel.value.firstName = firstNameController.value.text;
  //     userModel.value.lastName = lastNameController.value.text;
  //     userModel.value.merchantName = merchantNameController.value.text;
  //     userModel.value.merchantBusinessType = businessTypeController.value.text;
  //     userModel.value.dob = dobController.value.text;
  //     userModel.value.profilePictureURL = profileImage.value;
  //
  //     // Get merchantId
  //     String merchantId = userModel.value.merchantId ??
  //         Preferences.getString('merchantId');
  //     if (merchantId.isEmpty) merchantId = '36'; // ← temporary for testing
  //
  //     if (merchantId.isNotEmpty) {
  //       // Java API
  //       final success = await FireStoreUtils.updateMerchantProfile(
  //         merchantId,
  //         userModel.value,
  //       );
  //       if (success) {
  //         await FireStoreUtils.updateUser(userModel.value); // Firebase backward compat
  //         Get.back(result: true);
  //       } else {
  //         ShowToastDialog.showToast('Failed to update profile.'.tr);
  //       }
  //     } else {
  //       // Fallback Firebase only
  //       final success = await FireStoreUtils.updateUser(userModel.value);
  //       if (success) {
  //         Get.back(result: true);
  //       } else {
  //         ShowToastDialog.showToast('Failed to update profile.'.tr);
  //       }
  //     }
  //     // ADD UNTIL HERE ↑
  //
  //   } catch (e) {
  //     ShowToastDialog.showToast('${"Failed to save".tr}: $e');
  //   } finally {
  //     _isSaving = false;
  //     ShowToastDialog.closeLoader();
  //   }
  // }
  //STARTED SAVE OUTLET DETAILS WITHOUT OUTLET PROFILE
  // Future<void> saveData() async {
  //   if (_isSaving) return;
  //   _isSaving = true;
  //   ShowToastDialog.showLoader("Please wait...".tr);
  //   try {
  //     print("=== saveData started ===");
  //     print("firstName: ${firstNameController.value.text}");
  //     print("merchantName: ${merchantNameController.value.text}");
  //     print("businessType: ${businessTypeController.value.text}");
  //
  //
  //     // Upload image if changed
  //     if (Constant().hasValidUrl(profileImage.value) == false &&
  //         profileImage.value.isNotEmpty) {
  //       print("=== uploading image ===");
  //       final pathId = _userId ?? userModel.value.id ??
  //           await FireStoreUtils.getCurrentUid();
  //       profileImage.value = await Constant.uploadUserImageToFireStorage(
  //         File(profileImage.value),
  //         "profileImage/$pathId",
  //         File(profileImage.value).path.split('/').last,
  //       );
  //       print("=== image uploaded: ${profileImage.value} ===");
  //     }
  //
  //     // Update model with all fields
  //     // userModel.value.firstName = firstNameController.value.text;
  //     // userModel.value.lastName = lastNameController.value.text;
  //     userModel.value.merchantName = merchantNameController.value.text;
  //     userModel.value.merchantBusinessType = businessTypeController.value.text;
  //     // userModel.value.dob = dobController.value.text;
  //     userModel.value.profilePictureURL = profileImage.value;
  //     userModel.value.accountNumber = accountNumberController.value.text;
  //     userModel.value.ifscCode = ifscCodeController.value.text;
  //     userModel.value.bankName = bankNameController.value.text;
  //     userModel.value.accountHolderName = accountHolderNameController.value.text;
  //
  //     print("=== userModel updated ===");
  //     print("userModel id: ${userModel.value.id}");
  //     print("userModel firstName: ${userModel.value.firstName}");
  //     print("userModel merchantName: ${userModel.value.merchantName}");
  //     print("bankNameController = ${bankNameController.value.text}");
  //     print("accountHolderController = ${accountHolderNameController.value.text}");
  //     print("accountNumberController = ${accountNumberController.value.text}");
  //     print("ifscController = ${ifscCodeController.value.text}");
  //     //
  //
  //     //
  //     // Firebase only for now
  //     print("=== calling updateUser ===");
  //     // Java API now ready
  //     String merchantId = userModel.value.merchantId ??
  //         Preferences.getString('merchantId');
  //
  //     final success = await FireStoreUtils.updateMerchantProfile(
  //       merchantId,
  //       userModel.value,
  //     );
  //     if (success) {
  //       Get.back(result: true);
  //     } else {
  //       ShowToastDialog.showToast('Failed to update profile.'.tr);
  //     }
  //   } catch (e) {
  //     print("=== ERROR in saveData: $e ===");
  //     ShowToastDialog.showToast('${"Failed to save".tr}: $e');
  //   } finally {
  //     _isSaving = false;
  //     ShowToastDialog.closeLoader();
  //   }
  // }
//ENDED SAVE OUTLET DETAILS WITHOUT PROFILE
  Future<void> saveData() async {
    if (_isSaving) return;
    _isSaving = true;
    ShowToastDialog.showLoader("Please wait...".tr);
    try {
      if (isOutletMode.value) {
        await _saveOutletData();
        return;
      }

      // ── existing merchant saveData() logic below, unchanged ──
      print("=== saveData started ===");
      if (Constant().hasValidUrl(profileImage.value) == false &&
          profileImage.value.isNotEmpty) {
        final pathId = _userId ?? userModel.value.id ??
            await FireStoreUtils.getCurrentUid();
        profileImage.value = await Constant.uploadUserImageToFireStorage(
          File(profileImage.value),
          "profileImage/$pathId",
          File(profileImage.value).path.split('/').last,
        );
      }

      userModel.value.merchantName = merchantNameController.value.text;
      userModel.value.merchantBusinessType = businessTypeController.value.text;
      userModel.value.profilePictureURL = profileImage.value;
      userModel.value.accountNumber = accountNumberController.value.text;
      userModel.value.ifscCode = ifscCodeController.value.text;
      userModel.value.bankName = bankNameController.value.text;
      userModel.value.accountHolderName = accountHolderNameController.value.text;

      String merchantId = userModel.value.merchantId ??
          Preferences.getString('merchantId');

      final success = await FireStoreUtils.updateMerchantProfile(
        merchantId,
        userModel.value,
      );
      if (success) {
        Get.back(result: true);
      } else {
        ShowToastDialog.showToast('Failed to update profile.'.tr);
      }
    } catch (e) {
      print("=== ERROR in saveData: $e ===");
      ShowToastDialog.showToast('${"Failed to save".tr}: $e');
    } finally {
      _isSaving = false;
      ShowToastDialog.closeLoader();
    }
  }

// ADDED — outlet save path, isolated from merchant path
  Future<void> _saveOutletData() async {
    try {
      if (Constant().hasValidUrl(profileImage.value) == false &&
          profileImage.value.isNotEmpty) {
        final pathId = _activeOutletId.toString();
        profileImage.value = await Constant.uploadUserImageToFireStorage(
          File(profileImage.value),
          "outletImage/$pathId",
          File(profileImage.value).path.split('/').last,
        );
      }

      final body = {
        "outletName": outletNameController.value.text,
        "merchantId": outletModel.value.merchantId,
        "cuisineType": cuisineTypeController.value.text,
        "outletEmail": emailController.value.text,
        "outletPhone": outletPhoneController.value.text,
        // ⚠️ NOT returned by getOutletById — see note below.
        "alternateOutletPhone": "",
        "accountNumber": accountNumberController.value.text,
        "ifscCode": ifscCodeController.value.text,
        "bankName": bankNameController.value.text,
        "accountHolderName": accountHolderNameController.value.text,

        // ADDRESS
        "buildingNumber": buildingNumberController.value.text,
        "road": roadController.value.text,
        "landmark": landmarkController.value.text,
        "stateId": selectedStateId.value,
        "cityId": selectedCityId.value,
        "areaId": selectedAreaId.value,

        "latitude": outletModel.value.latitude?.toString() ?? "0",
        "longitude": outletModel.value.longitude?.toString() ?? "0",
        "operatingDays": [],
        "updatedBy": Preferences.getInt('userId'),
      };

      final success =
      await FireStoreUtils.updateOutletProfile(_activeOutletId, body);
      if (success) {
        Get.back(result: true);
      } else {
        ShowToastDialog.showToast('Failed to update outlet.'.tr);
      }
    } catch (e) {
      print("=== ERROR in _saveOutletData: $e ===");
      ShowToastDialog.showToast('${"Failed to save".tr}: $e');
    }
  }
  final ImagePicker _imagePicker = ImagePicker();
  RxString profileImage = "".obs;

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }
}
