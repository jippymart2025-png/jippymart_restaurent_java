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
import '../models/cuisine_type_model.dart';
import '../utils/preferences.dart';

class EditProfileController extends GetxController {
  // ADDED fields
  RxBool isOutletMode = false.obs;
  Rx<OutletModel> outletModel = OutletModel().obs;
  int _activeOutletId = 0;

  Rx<TextEditingController> outletNameController = TextEditingController().obs;
 // Rx<TextEditingController> cuisineTypeController = TextEditingController().obs;
  Rx<TextEditingController> outletPhoneController = TextEditingController().obs;
  Rx<TextEditingController> alternatePhoneController = TextEditingController().obs;
  Rx<TextEditingController> fssaiNumberController = TextEditingController().obs;
  Rx<TextEditingController> gstNumberController = TextEditingController().obs;
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
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final locationDisplayController = TextEditingController();
  /// Cached for this screen session to avoid repeated getCurrentUid() calls.
  String? _userId;
  bool _isSaving = false;

  @override
  void onInit() {
    getData();
    super.onInit();
  }
  final selectedCuisineIds = <int>[].obs;
  final cuisineTypes = <CuisineTypeModel>[].obs;
  final isCuisineLoading = false.obs;

  void toggleCuisine(int cuisineId) {
    if (selectedCuisineIds.contains(cuisineId)) {
      selectedCuisineIds.remove(cuisineId);
    } else {
      selectedCuisineIds.add(cuisineId);
    }
  }

  bool isCuisineSelected(int cuisineId) {
    return selectedCuisineIds.contains(cuisineId);
  }

  Future<void> loadCuisineTypes() async {
    try {
      isCuisineLoading.value = true;
      final result = await FireStoreUtils.getCuisineTypes();
      cuisineTypes.assignAll(result);
    } finally {
      isCuisineLoading.value = false;
    }
  }
// ============================================================
// OPERATING HOURS (outlet mode)
// ============================================================

  RxBool sameTimingForAllDays = true.obs;

  final commonTimeSlots = <Map<String, dynamic>>[].obs;

  final operatingDaysList = <Map<String, dynamic>>[].obs;



  final List<String> weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday",];
// ============================================================
// OPERATING HOURS METHODS
// ============================================================

  /// Groups the flat operatingDays response (from GET) into per-day slots
  /// for editing, and detects if all days share identical slot patterns
  /// (same timings for all days) vs differing per day.
  void _populateOperatingHours(List<Map<String, dynamic>>? flatDays) {
    operatingDaysList.clear();
    commonTimeSlots.clear();

    if (flatDays == null || flatDays.isEmpty) {
      sameTimingForAllDays.value = true;
      commonTimeSlots.add({
        "openingTime": "",
        "closingTime": "",

      });
      return;
    }

    // Group flat slots by dayOfWeekId
    final Map<int, List<Map<String, dynamic>>> grouped = {};
    for (final slot in flatDays) {
      final dayId = OutletModel.parseIntSafe(slot['dayOfWeekId']) ?? 1;
      grouped.putIfAbsent(dayId, () => []);
      final rawOpen = slot['openingTime']?.toString() ?? '';
      final rawClose = slot['closingTime']?.toString() ?? '';
      grouped[dayId]!.add({
        "openingTime": rawOpen.length >= 5 ? rawOpen.substring(0, 5) : rawOpen,
        "closingTime": rawClose.length >= 5 ? rawClose.substring(0, 5) : rawClose,
        //"slotType": slot['slotType']?.toString() ?? "FULL_DAY",
      });
    }

    final sortedDayIds = grouped.keys.toList()..sort();

    for (final dayId in sortedDayIds) {
      operatingDaysList.add({
        "dayOfWeekId": dayId,
        "dayName": weekDays[(dayId - 1).clamp(0, 6)],
        "isOpen": true,
        "slots": grouped[dayId],
      });
    }

    // Decide "same for all days" by comparing actual slot CONTENT
    // across every present day — not just counting days.
    final bool coversAllDays = sortedDayIds.length == 7;
    final bool allDaysIdentical = coversAllDays && _allGroupsMatch(grouped, sortedDayIds);

    sameTimingForAllDays.value = allDaysIdentical;

    if (sameTimingForAllDays.value) {
      commonTimeSlots.addAll(
          List<Map<String, dynamic>>.from(grouped[sortedDayIds.first]!));
    } else if (commonTimeSlots.isEmpty && operatingDaysList.isEmpty) {
      commonTimeSlots.add({
        "openingTime": "",
        "closingTime": "",
        "slotType": "FULL_DAY",
      });
    }
  }

  /// Compares every day's slot list against the first day's slot list.
  /// Returns true only if all days have the same number of slots with
  /// identical openingTime/closingTime/slotType, in the same order.
  bool _allGroupsMatch(
      Map<int, List<Map<String, dynamic>>> grouped, List<int> dayIds) {
    final reference = grouped[dayIds.first]!;

    for (final dayId in dayIds.skip(1)) {
      final current = grouped[dayId]!;
      if (current.length != reference.length) return false;

      for (int i = 0; i < reference.length; i++) {
        if (current[i]["openingTime"] != reference[i]["openingTime"] ||
            current[i]["closingTime"] != reference[i]["closingTime"] ) {
          return false;
        }
      }
    }
    return true;
  }
  void addCommonTimeSlot() {
    commonTimeSlots.add({
      "openingTime": "",
      "closingTime": "",

    });
  }
  void removeCommonTimeSlot(int slotIndex) {
    commonTimeSlots.removeAt(slotIndex);
  }
  void updateCommonOpeningTime(int slotIndex, String value) {
    commonTimeSlots[slotIndex]["openingTime"] = value;
    commonTimeSlots.refresh();
  }

  void updateCommonClosingTime(int slotIndex, String value) {
    commonTimeSlots[slotIndex]["closingTime"] = value;
    commonTimeSlots.refresh();
  }

  void removeOperatingDay(int dayIndex) {
    operatingDaysList.removeAt(dayIndex);
  }

  void addOperatingDay() {
    if (operatingDaysList.length >= 7) {
      ShowToastDialog.showToast("All 7 days are already added");
      return;
    }
    final index = operatingDaysList.length;
    operatingDaysList.add({
      "dayOfWeekId": index + 1,
      "dayName": weekDays[index],
      "isOpen": true,
      "slots": [
        {"openingTime": "", "closingTime": "",}
      ],
    });
  }

  void addTimeSlot(int dayIndex) {
    final slots = operatingDaysList[dayIndex]["slots"] as List<dynamic>;
    slots.add({"openingTime": "", "closingTime": "",});
    operatingDaysList.refresh();
  }

  // void removeTimeSlot(int dayIndex, int slotIndex) {
  //   final slots = operatingDaysList[dayIndex]["slots"] as List<dynamic>;
  //   if (slots.length <= 1) {
  //     ShowToastDialog.showToast("At least one time slot is required");
  //     return;
  //   }
  //   slots.removeAt(slotIndex);
  //   operatingDaysList.refresh();
  // }
  void removeTimeSlot(int dayIndex, int slotIndex) {
    final slots = operatingDaysList[dayIndex]["slots"] as List<dynamic>;

    if (slots.length <= 1) {
      // Last slot in this day — remove the entire day instead.
      operatingDaysList.removeAt(dayIndex);
    } else {
      slots.removeAt(slotIndex);
      operatingDaysList.refresh();
    }
  }

  void updateOpeningTime(int dayIndex, int slotIndex, String value) {
    final slots = operatingDaysList[dayIndex]["slots"] as List<dynamic>;
    slots[slotIndex]["openingTime"] = value;
    operatingDaysList.refresh();
  }

  void updateClosingTime(int dayIndex, int slotIndex, String value) {
    final slots = operatingDaysList[dayIndex]["slots"] as List<dynamic>;
    slots[slotIndex]["closingTime"] = value;
    operatingDaysList.refresh();
  }



  /// Flattens the current UI state (common or per-day) into the
  /// backend's expected flat operatingDays request format.
  List<Map<String, dynamic>> buildOperatingDaysRequest() {
    final List<Map<String, dynamic>> result = [];

    if (sameTimingForAllDays.value) {
      for (int dayId = 1; dayId <= 7; dayId++) {
        for (final slot in commonTimeSlots) {
          result.add({
            "dayOfWeekId": dayId,
            "isOpen": true,
            "openingTime": slot["openingTime"],
            "closingTime": slot["closingTime"],

          });
        }
      }
    } else {
      for (final day in operatingDaysList) {
        final slots = day["slots"] as List<dynamic>;
        for (final slot in slots) {
          result.add({
            "dayOfWeekId": day["dayOfWeekId"],
            "isOpen": day["isOpen"],
            "openingTime": slot["openingTime"],
            "closingTime": slot["closingTime"],

          });
        }
      }
    }

    return result;
  }

  bool validateOperatingHours() {
    final slotsToCheck = sameTimingForAllDays.value
        ? commonTimeSlots
        : operatingDaysList.expand((d) => d["slots"] as List<dynamic>).toList();

    for (final slot in slotsToCheck) {
      final opening = (slot["openingTime"] ?? '').toString().trim();
      final closing = (slot["closingTime"] ?? '').toString().trim();
      if (opening.isEmpty || closing.isEmpty) {
        ShowToastDialog.showToast("Please fill all opening and closing times");
        return false;
      }
    }
    return true;
  }
// This is java related getData() method(start)
  Future<void> getData() async {
    loadCuisineTypes(); // ← ADDED, fire-and-forget alongside outlet/merchant fetch

    // FOR GET OUTLET PROFILE
    final outletId = Preferences.getInt('outletId');
    isOutletMode.value = outletId > 0;

    if (isOutletMode.value) {
      _activeOutletId = outletId;
      final outlet = await FireStoreUtils.getOutletProfile(outletId);
      print("getOutletProfile result: ${outlet?.outletName}");
      print("DEBUG raw stateId=${outlet?.stateId}, cityId=${outlet?.cityId}, areaId=${outlet?.areaId}");
      if (outlet != null) {
        outletModel.value = outlet;
        outletNameController.value.text = outlet.outletName ?? '';
        emailController.value.text = outlet.outletEmail ?? '';
        outletPhoneController.value.text = outlet.outletPhone ?? '';
        fssaiNumberController.value.text = outlet.fssaiNumber ?? '';
        gstNumberController.value.text = outlet.gstNumber ?? '';
        alternatePhoneController.value.text = outlet.alternateOutletPhone ?? '';
        selectedCuisineIds.assignAll(outlet.cuisineTypeIds ?? []);
        _populateOperatingHours(outlet.operatingDays);
        radiusController.value.text = outlet.radius?.toString() ?? '';
        profileImage.value = outlet.outletPicUrl ?? '';
        // Address
        buildingNumberController.value.text = outlet.buildingNumber ?? '';
        roadController.value.text = outlet.road ?? '';
        landmarkController.value.text = outlet.landmark ?? '';
        latitudeController.text = outlet.latitude?.toString() ?? '';
        longitudeController.text = outlet.longitude?.toString() ?? '';

        locationDisplayController.text = [
          outlet.buildingNumber,
          outlet.road,
          outlet.landmark,
        ]
            .where((e) => e != null && e.trim().isNotEmpty)
            .join(', ');
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
      print("DEBUG stateId=${outletModel.value.stateId}, cityId=${outletModel.value.cityId}, areaId=${outletModel.value.areaId}");
      final body = {
        "outletName": outletNameController.value.text,
        "merchantId": outletModel.value.merchantId,
        "cuisineType": selectedCuisineIds.toList(),
        "outletEmail": emailController.value.text,
        "outletPhone": outletPhoneController.value.text,
        "fssaiNumber": fssaiNumberController.value.text.trim(),
        "gstNumber": gstNumberController.value.text.trim(),
        // ⚠️ NOT returned by getOutletById — see note below.
        "alternateOutletPhone": alternatePhoneController.value.text.trim(),
        "accountNumber": accountNumberController.value.text,
        "ifscCode": ifscCodeController.value.text,
        "bankName": bankNameController.value.text,
        "accountHolderName": accountHolderNameController.value.text,
        if (outletModel.value.stateId != null) "stateId": outletModel.value.stateId,
        if (outletModel.value.cityId != null) "cityId": outletModel.value.cityId,
        if (outletModel.value.areaId != null) "areaId": outletModel.value.areaId,
        // ADDRESS
        "buildingNumber": buildingNumberController.value.text,
        "road": roadController.value.text,
        "landmark": landmarkController.value.text,

        "latitude": latitudeController.text.trim(),
        "longitude": longitudeController.text.trim(),
        "operatingDays": buildOperatingDaysRequest(),
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
  @override
  void onClose() {
    outletNameController.value.dispose();
    outletPhoneController.value.dispose();
    alternatePhoneController.value.dispose();
    fssaiNumberController.value.dispose();
    gstNumberController.value.dispose();
    radiusController.value.dispose();
    buildingNumberController.value.dispose();
    roadController.value.dispose();
    landmarkController.value.dispose();
    areaController.value.dispose();
    firstNameController.value.dispose();
    lastNameController.value.dispose();
    emailController.value.dispose();
    phoneNumberController.value.dispose();
    countryCodeController.value.dispose();
    merchantNameController.value.dispose();
    businessTypeController.value.dispose();
    dobController.value.dispose();
    statusController.value.dispose();
    accountNumberController.value.dispose();
    ifscCodeController.value.dispose();
    bankNameController.value.dispose();
    accountHolderNameController.value.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    locationDisplayController.dispose();
    super.onClose();
  }

  final ImagePicker _imagePicker = ImagePicker();
  RxString profileImage = "".obs;

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;

      if (isOutletMode.value) {
        await _uploadProfileImage(File(image.path));
      }
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }

  Future<void> _uploadProfileImage(File image) async {
    ShowToastDialog.showLoader("Uploading image...".tr);
    try {
      final url = await FireStoreUtils.uploadOutletImage(
        outletId: _activeOutletId,
        image: image,
      );
      if (url != null && url.isNotEmpty) {
        profileImage.value = url;
        ShowToastDialog.showToast("Image uploaded successfully".tr);
      } else {
        ShowToastDialog.showToast("Failed to upload image".tr);
      }
    } finally {
      ShowToastDialog.closeLoader();
    }
  }
}
