import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/cuisine_type_model.dart';
import 'package:jippymart_restaurant/models/merchant_response_model.dart';
import 'package:jippymart_restaurant/models/outlet_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

class EditProfileController extends GetxController {
  // ───────────────────────── Mode ─────────────────────────
  final RxBool isOutletMode = false.obs;
  final Rx<OutletModel> outletModel = OutletModel().obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString profileImage = ''.obs;

  int _activeOutletId = 0;
  String? _userId;
  final ImagePicker _imagePicker = ImagePicker();

  // ─────────────────── Outlet controllers ───────────────────
  final outletNameController = TextEditingController();
  final outletPhoneController = TextEditingController();
  final alternatePhoneController = TextEditingController();
  final fssaiNumberController = TextEditingController();
  final gstNumberController = TextEditingController();
  final radiusController = TextEditingController();

  // ─────────────────── Address controllers ───────────────────
  final buildingNumberController = TextEditingController();
  final roadController = TextEditingController();
  final landmarkController = TextEditingController();
  final areaController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final locationDisplayController = TextEditingController();

  final RxInt selectedStateId = 0.obs;
  final RxInt selectedCityId = 0.obs;
  final RxInt selectedAreaId = 0.obs;

  // ─────────────────── Merchant controllers ───────────────────
  final merchantNameController = TextEditingController();
  final businessTypeController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final countryCodeController = TextEditingController(text: '+91');
  final statusController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountHolderNameController = TextEditingController();
  final aadharController = TextEditingController();
  final panController = TextEditingController();

  final Rx<UserModel> userModel = UserModel().obs;
  final Rxn<MerchantModel> merchantModel = Rxn<MerchantModel>();

  // ─────────────────── Cuisine ───────────────────
  final selectedCuisineIds = <int>[].obs;
  final cuisineTypes = <CuisineTypeModel>[].obs;
  final isCuisineLoading = false.obs;

  // ─────────────────── Operating hours ───────────────────
  final RxBool sameTimingForAllDays = true.obs;
  final commonTimeSlots = <Map<String, dynamic>>[].obs;
  final operatingDaysList = <Map<String, dynamic>>[].obs;

  static const List<String> weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  // ─────────────────────────────────────────────────────────
  // Bootstrap
  // ─────────────────────────────────────────────────────────
  Future<void> _loadInitialData() async {
    try {
      await Future.wait([loadCuisineTypes(), getData()]);
    } catch (e) {
      debugPrint('EditProfileController._loadInitialData error: $e');
      ShowToastDialog.showToast('Failed to load profile'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCuisineTypes() async {
    try {
      isCuisineLoading.value = true;
      final result = await FireStoreUtils.getCuisineTypes();
      cuisineTypes.assignAll(result);
    } catch (e) {
      debugPrint('loadCuisineTypes error: $e');
    } finally {
      isCuisineLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Data fetch
  // ─────────────────────────────────────────────────────────
  Future<void> getData() async {
    final outletId = Preferences.getInt('outletId');
    isOutletMode.value = outletId > 0;

    if (isOutletMode.value) {
      _activeOutletId = outletId;
      await _loadOutletProfile(outletId);
      return;
    }

    await _loadMerchantProfile();
  }

  Future<void> _loadOutletProfile(int outletId) async {
    final outlet = await FireStoreUtils.getOutletProfile(outletId);
    if (outlet == null) return;

    outletModel.value = outlet;
    outletNameController.text = outlet.outletName ?? '';
    emailController.text = outlet.outletEmail ?? '';
    outletPhoneController.text = outlet.outletPhone ?? '';
    fssaiNumberController.text = outlet.fssaiNumber ?? '';
    gstNumberController.text = outlet.gstNumber ?? '';
    alternatePhoneController.text = outlet.alternateOutletPhone ?? '';
    radiusController.text = outlet.radius?.toString() ?? '';
    profileImage.value = outlet.outletPicUrl ?? '';

    selectedCuisineIds.assignAll(outlet.cuisineTypeIds ?? []);
    _populateOperatingHours(outlet.operatingDays);

    // Address
    buildingNumberController.text = outlet.buildingNumber ?? '';
    roadController.text = outlet.road ?? '';
    landmarkController.text = outlet.landmark ?? '';
    latitudeController.text = outlet.latitude?.toString() ?? '';
    longitudeController.text = outlet.longitude?.toString() ?? '';
    locationDisplayController.text = [
      outlet.buildingNumber,
      outlet.road,
      outlet.landmark,
    ].where((e) => e != null && e.trim().isNotEmpty).join(', ');

    selectedStateId.value = outlet.stateId ?? 0;
    selectedCityId.value = outlet.cityId ?? 0;
    selectedAreaId.value = outlet.areaId ?? 0;

    // Bank
    accountNumberController.text = outlet.accountNumber ?? '';
    ifscCodeController.text = outlet.ifscCode ?? '';
    bankNameController.text = outlet.bankName ?? '';
    accountHolderNameController.text = outlet.accountHolderName ?? '';
  }

  Future<void> _loadMerchantProfile() async {
    final userId = await FireStoreUtils.getCurrentUid();
    _userId = userId;

    final merchantId = Preferences.getInt('userId');
    final value = await FireStoreUtils.getMerchantProfile(merchantId.toString());
    if (value == null) return;

    merchantModel.value = value;
    emailController.text = value.merchantEmail ?? '';
    phoneNumberController.text = value.merchantPhone ?? '';
    merchantNameController.text = value.merchantName ?? '';
    businessTypeController.text = value.merchantBusinessType ?? '';
    statusController.text = value.status ?? '';
    accountNumberController.text = value.accountNumber ?? '';
    ifscCodeController.text = value.ifscCode ?? '';
    bankNameController.text = value.bankName ?? '';
    accountHolderNameController.text = value.accountHolderName ?? '';
    panController.text = value.panNumber ?? '';
    aadharController.text = value.addharNumber ?? '';
  }

  // ─────────────────────────────────────────────────────────
  // Cuisine
  // ─────────────────────────────────────────────────────────
  void toggleCuisine(int cuisineId) {
    selectedCuisineIds.contains(cuisineId)
        ? selectedCuisineIds.remove(cuisineId)
        : selectedCuisineIds.add(cuisineId);
  }

  bool isCuisineSelected(int cuisineId) =>
      selectedCuisineIds.contains(cuisineId);

  String get selectedCuisineNames => cuisineTypes
      .where((c) => selectedCuisineIds.contains(c.cuisineTypeId))
      .map((c) => c.cuisineTypeName)
      .join(', ');

  // ─────────────────────────────────────────────────────────
  // Operating hours
  // ─────────────────────────────────────────────────────────
  void _populateOperatingHours(List<Map<String, dynamic>>? flatDays) {
    operatingDaysList.clear();
    commonTimeSlots.clear();

    if (flatDays == null || flatDays.isEmpty) {
      sameTimingForAllDays.value = true;
      commonTimeSlots.add({'openingTime': '', 'closingTime': ''});
      return;
    }

    final Map<int, List<Map<String, dynamic>>> grouped = {};
    for (final slot in flatDays) {
      final dayId = OutletModel.parseIntSafe(slot['dayOfWeekId']) ?? 1;
      final rawOpen = slot['openingTime']?.toString() ?? '';
      final rawClose = slot['closingTime']?.toString() ?? '';
      grouped.putIfAbsent(dayId, () => []).add({
        'openingTime': _normalizeTime(rawOpen),
        'closingTime': _normalizeTime(rawClose),
      });
    }

    final sortedDayIds = grouped.keys.toList()..sort();
    for (final dayId in sortedDayIds) {
      operatingDaysList.add({
        'dayOfWeekId': dayId,
        'dayName': weekDays[(dayId - 1).clamp(0, 6)],
        'isOpen': true,
        'slots': grouped[dayId],
      });
    }

    final coversAllDays = sortedDayIds.length == 7;
    sameTimingForAllDays.value =
        coversAllDays && _allGroupsMatch(grouped, sortedDayIds);

    if (sameTimingForAllDays.value) {
      commonTimeSlots.addAll(
        List<Map<String, dynamic>>.from(grouped[sortedDayIds.first]!),
      );
    }
  }

  String _normalizeTime(String raw) =>
      raw.length >= 5 ? raw.substring(0, 5) : raw;

  bool _allGroupsMatch(
      Map<int, List<Map<String, dynamic>>> grouped,
      List<int> dayIds,
      ) {
    final reference = grouped[dayIds.first]!;
    for (final dayId in dayIds.skip(1)) {
      final current = grouped[dayId]!;
      if (current.length != reference.length) return false;
      for (int i = 0; i < reference.length; i++) {
        if (current[i]['openingTime'] != reference[i]['openingTime'] ||
            current[i]['closingTime'] != reference[i]['closingTime']) {
          return false;
        }
      }
    }
    return true;
  }

  void addCommonTimeSlot() =>
      commonTimeSlots.add({'openingTime': '', 'closingTime': ''});

  void removeCommonTimeSlot(int slotIndex) =>
      commonTimeSlots.removeAt(slotIndex);

  void updateCommonOpeningTime(int slotIndex, String value) {
    commonTimeSlots[slotIndex]['openingTime'] = value;
    commonTimeSlots.refresh();
  }

  void updateCommonClosingTime(int slotIndex, String value) {
    commonTimeSlots[slotIndex]['closingTime'] = value;
    commonTimeSlots.refresh();
  }

  void addOperatingDay() {
    if (operatingDaysList.length >= 7) {
      ShowToastDialog.showToast('All 7 days are already added');
      return;
    }
    final index = operatingDaysList.length;
    operatingDaysList.add({
      'dayOfWeekId': index + 1,
      'dayName': weekDays[index],
      'isOpen': true,
      'slots': [
        {'openingTime': '', 'closingTime': ''},
      ],
    });
  }

  void addTimeSlot(int dayIndex) {
    (operatingDaysList[dayIndex]['slots'] as List<dynamic>)
        .add({'openingTime': '', 'closingTime': ''});
    operatingDaysList.refresh();
  }

  void removeTimeSlot(int dayIndex, int slotIndex) {
    final slots = operatingDaysList[dayIndex]['slots'] as List<dynamic>;
    if (slots.length <= 1) {
      operatingDaysList.removeAt(dayIndex);
    } else {
      slots.removeAt(slotIndex);
      operatingDaysList.refresh();
    }
  }

  void updateOpeningTime(int dayIndex, int slotIndex, String value) {
    final slots = operatingDaysList[dayIndex]['slots'] as List<dynamic>;
    slots[slotIndex]['openingTime'] = value;
    operatingDaysList.refresh();
  }

  void updateClosingTime(int dayIndex, int slotIndex, String value) {
    final slots = operatingDaysList[dayIndex]['slots'] as List<dynamic>;
    slots[slotIndex]['closingTime'] = value;
    operatingDaysList.refresh();
  }

  List<Map<String, dynamic>> buildOperatingDaysRequest() {
    final result = <Map<String, dynamic>>[];

    if (sameTimingForAllDays.value) {
      for (int dayId = 1; dayId <= 7; dayId++) {
        for (final slot in commonTimeSlots) {
          result.add({
            'dayOfWeekId': dayId,
            'isOpen': true,
            'openingTime': slot['openingTime'],
            'closingTime': slot['closingTime'],
          });
        }
      }
      return result;
    }

    for (final day in operatingDaysList) {
      for (final slot in day['slots'] as List<dynamic>) {
        result.add({
          'dayOfWeekId': day['dayOfWeekId'],
          'isOpen': day['isOpen'],
          'openingTime': slot['openingTime'],
          'closingTime': slot['closingTime'],
        });
      }
    }
    return result;
  }

  bool validateOperatingHours() {
    final slotsToCheck = sameTimingForAllDays.value
        ? commonTimeSlots
        : operatingDaysList
        .expand((d) => d['slots'] as List<dynamic>)
        .toList();

    for (final slot in slotsToCheck) {
      final opening = (slot['openingTime'] ?? '').toString().trim();
      final closing = (slot['closingTime'] ?? '').toString().trim();
      if (opening.isEmpty || closing.isEmpty) {
        ShowToastDialog.showToast('Please fill all opening and closing times');
        return false;
      }
    }
    return true;
  }

  // ─────────────────────────────────────────────────────────
  // Save
  // ─────────────────────────────────────────────────────────
  Future<void> saveData() async {
    if (isSaving.value) return;

    if (isOutletMode.value && !validateOperatingHours()) return;

    isSaving.value = true;
    ShowToastDialog.showLoader('Please wait...'.tr);

    try {
      if (isOutletMode.value) {
        await _saveOutletData();
      } else {
        await _saveMerchantData();
      }
    } catch (e) {
      debugPrint('saveData error: $e');
      ShowToastDialog.showToast('${'Failed to save'.tr}: $e');
    } finally {
      isSaving.value = false;
      ShowToastDialog.closeLoader();
    }
  }

  Future<void> _saveMerchantData() async {
    if (profileImage.value.isNotEmpty &&
        !Constant().hasValidUrl(profileImage.value)) {
      final pathId =
          _userId ?? userModel.value.id ?? await FireStoreUtils.getCurrentUid();
      profileImage.value = await Constant.uploadUserImageToFireStorage(
        File(profileImage.value),
        'profileImage/$pathId',
        File(profileImage.value).path.split('/').last,
      );
    }

    merchantModel.value ??= MerchantModel();
    final m = merchantModel.value!;
    m
      ..merchantName = merchantNameController.text
      ..merchantBusinessType = businessTypeController.text
      ..accountNumber = accountNumberController.text
      ..ifscCode = ifscCodeController.text
      ..bankName = bankNameController.text
      ..accountHolderName = accountHolderNameController.text
      ..status = statusController.text
      ..addharNumber = aadharController.text
      ..panNumber = panController.text;

    final merchantId =
        m.merchantId?.toString() ?? Preferences.getString('merchantId');

    final success =
    await FireStoreUtils.updateMerchantProfile(merchantId, m);

    success
        ? Get.back(result: true)
        : ShowToastDialog.showToast('Failed to update profile.'.tr);
  }

  Future<void> _saveOutletData() async {
    if (profileImage.value.isNotEmpty &&
        !Constant().hasValidUrl(profileImage.value)) {
      final pathId = _activeOutletId.toString();
      profileImage.value = await Constant.uploadUserImageToFireStorage(
        File(profileImage.value),
        'outletImage/$pathId',
        File(profileImage.value).path.split('/').last,
      );
    }

    final body = <String, dynamic>{
      'outletName': outletNameController.text,
      'merchantId': outletModel.value.merchantId,
      'cuisineType': selectedCuisineIds.toList(),
      'outletEmail': emailController.text,
      'outletPhone': outletPhoneController.text,
      'fssaiNumber': fssaiNumberController.text.trim(),
      'gstNumber': gstNumberController.text.trim(),
      'alternateOutletPhone': alternatePhoneController.text.trim(),
      'accountNumber': accountNumberController.text,
      'ifscCode': ifscCodeController.text,
      'bankName': bankNameController.text,
      'accountHolderName': accountHolderNameController.text,
      if (outletModel.value.stateId != null)
        'stateId': outletModel.value.stateId,
      if (outletModel.value.cityId != null)
        'cityId': outletModel.value.cityId,
      if (outletModel.value.areaId != null)
        'areaId': outletModel.value.areaId,
      'buildingNumber': buildingNumberController.text,
      'road': roadController.text,
      'landmark': landmarkController.text,
      'latitude': latitudeController.text.trim(),
      'longitude': longitudeController.text.trim(),
      'operatingDays': buildOperatingDaysRequest(),
      'updatedBy': Preferences.getInt('userId'),
    };

    final success =
    await FireStoreUtils.updateOutletProfile(_activeOutletId, body);

    success
        ? Get.back(result: true)
        : ShowToastDialog.showToast('Failed to update outlet.'.tr);
  }

  // ─────────────────────────────────────────────────────────
  // Image picker
  // ─────────────────────────────────────────────────────────
  Future<void> pickFile({required ImageSource source}) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      Get.back();
      profileImage.value = image.path;

      if (isOutletMode.value) {
        await _uploadProfileImage(File(image.path));
      }
    } on PlatformException catch (e) {
      ShowToastDialog.showToast('${'failed_to_pick'.tr} : \n $e');
    }
  }

  Future<void> _uploadProfileImage(File image) async {
    ShowToastDialog.showLoader('Uploading image...'.tr);
    try {
      final url = await FireStoreUtils.uploadOutletImage(
        outletId: _activeOutletId,
        image: image,
      );
      if (url != null && url.isNotEmpty) {
        profileImage.value = url;
        ShowToastDialog.showToast('Image uploaded successfully'.tr);
      } else {
        ShowToastDialog.showToast('Failed to upload image'.tr);
      }
    } finally {
      ShowToastDialog.closeLoader();
    }
  }

  // ─────────────────────────────────────────────────────────
  // Cleanup
  // ─────────────────────────────────────────────────────────
  @override
  void onClose() {
    for (final c in [
      outletNameController,
      outletPhoneController,
      alternatePhoneController,
      fssaiNumberController,
      gstNumberController,
      radiusController,
      buildingNumberController,
      roadController,
      landmarkController,
      areaController,
      latitudeController,
      longitudeController,
      locationDisplayController,
      merchantNameController,
      businessTypeController,
      emailController,
      phoneNumberController,
      countryCodeController,
      statusController,
      accountNumberController,
      ifscCodeController,
      bankNameController,
      accountHolderNameController,
      aadharController,
      panController,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}