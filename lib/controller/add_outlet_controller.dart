// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../constant/show_toast_dialog.dart';
// import '../models/outlet_model.dart';
// import '../utils/fire_store_utils.dart';
// import '../utils/preferences.dart';
// import '../models/location_model.dart';
// import '../service/location_api_service.dart';
// class AddOutletController extends GetxController {
//
//   final outletNameController = TextEditingController();
//   final phoneController = TextEditingController();
//   final alternatePhoneController = TextEditingController();
//   final emailController = TextEditingController();
//   final usernameController = TextEditingController();
//   final passwordController = TextEditingController();
//   final fssaiNumberController = TextEditingController();
//   final gstNumberController = TextEditingController();
//   final buildingController = TextEditingController();
//   final roadController = TextEditingController();
//   final landmarkController = TextEditingController();
//   final cuisineController = TextEditingController();
//
//   final cityIdController = TextEditingController();
//
//   final stateController = TextEditingController();
//
//   final areaController = TextEditingController();
//
//   final latitudeController = TextEditingController();
//
//   final longitudeController = TextEditingController();
//
//   final openingTimeController = TextEditingController();
//
//   final closingTimeController = TextEditingController();
//
// // Bank Details Controllers
//   final accountHolderController = TextEditingController();
//
//   final accountNumberController = TextEditingController();
//
//   final ifscController = TextEditingController();
//
//   final bankNameController = TextEditingController();
//   RxBool isLoading = false.obs;
//   RxBool useMerchantBankDetails = false.obs;
//   /// ---------- Operating Hours ----------
//
//   RxBool sameTimingForAllDays = true.obs;
//
//   RxList<Map<String, dynamic>> operatingDays =
//       <Map<String, dynamic>>[].obs;
//   /// Location Lists
//   RxList<StateModel> states = <StateModel>[].obs;
//   RxList<CityModel> cities = <CityModel>[].obs;
//   RxList<AreaModel> areas = <AreaModel>[].obs;
//
//   /// Selected Objects
//   Rx<StateModel?> selectedState = Rx<StateModel?>(null);
//   Rx<CityModel?> selectedCity = Rx<CityModel?>(null);
//   Rx<AreaModel?> selectedArea = Rx<AreaModel?>(null);
//   @override
//   void onInit() {
//     super.onInit();
//     loadStates();
//
//     initializeOperatingDays();
//   }
//   void initializeOperatingDays() {
//
//     operatingDays.clear();
//
//     operatingDays.add({
//
//       "dayOfWeekId":1,
//
//       "dayName":"Monday",
//
//       "openingTime":"",
//
//       "closingTime":"",
//
//       "isOpen":true
//
//     });
//
//   }
//   void addOperatingDay() {
//
//     if(operatingDays.length>=7){
//       return;
//     }
//
//     const days=[
//
//       "Monday",
//
//       "Tuesday",
//
//       "Wednesday",
//
//       "Thursday",
//
//       "Friday",
//
//       "Saturday",
//
//       "Sunday"
//
//     ];
//
//     final index=operatingDays.length;
//
//     operatingDays.add({
//
//       "dayOfWeekId":index+1,
//
//       "dayName":days[index],
//
//       "openingTime":"",
//
//       "closingTime":"",
//
//       "isOpen":true
//
//     });
//
//   }void removeOperatingDay(int index){
//
//     operatingDays.removeAt(index);
//
//   }void updateOpeningTime(
//       int index,
//       String value){
//
//     operatingDays[index]["openingTime"]=value;
//
//     operatingDays.refresh();
//
//   }void updateClosingTime(
//       int index,
//       String value){
//
//     operatingDays[index]["closingTime"]=value;
//
//     operatingDays.refresh();
//
//   }Future<String?> pickTime(BuildContext context) async {
//
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//
//     if (picked == null) return null;
//
//     final hour = picked.hour.toString().padLeft(2, '0');
//
//     final minute = picked.minute.toString().padLeft(2, '0');
//
//     return "$hour:$minute";
//
//   }
//   Future<void> loadStates() async {
//     states.value = await LocationApiService.fetchStates();
//   }
//   Future<void> onStateSelected(StateModel? state) async {
//     selectedState.value = state;
//
//     selectedCity.value = null;
//     selectedArea.value = null;
//
//     cities.clear();
//     areas.clear();
//
//     if (state == null) return;
//
//     cities.value =
//     await LocationApiService.fetchCities(state.stateId);
//   }Future<void> onCitySelected(CityModel? city) async {
//
//     selectedCity.value = city;
//
//     selectedArea.value = null;
//
//     areas.clear();
//
//     if (city == null) return;
//
//     areas.value =
//     await LocationApiService.fetchAreas(city.cityId);
//   }void onAreaSelected(AreaModel? area) {
//     selectedArea.value = area;
//   }
//   void fillMerchantBankDetails() {
//     accountHolderController.text =
//         Preferences.getString("merchantAccountHolder");
//
//     accountNumberController.text =
//         Preferences.getString("merchantAccountNumber");
//
//     ifscController.text =
//         Preferences.getString("merchantIfscCode");
//
//     bankNameController.text =
//         Preferences.getString("merchantBankName");
//
//     print("Merchant Bank Details Loaded");
//   }
//   void clearBankDetails() {
//     accountHolderController.clear();
//     accountNumberController.clear();
//     ifscController.clear();
//     bankNameController.clear();
//   }
//   void onMerchantBankChanged(bool value) {
//     useMerchantBankDetails.value = value;
//
//     if (value) {
//       fillMerchantBankDetails();
//     } else {
//       clearBankDetails();
//     }
//   }
//   Future<void> saveOutlet() async {
//
//     ShowToastDialog.showLoader("Please wait");
//
//     try {
//
//       final merchantIdStr = Preferences.getString('merchantId');
//       final merchantId = int.tryParse(merchantIdStr) ?? 0;
//
//       if (merchantId <= 0) {
//         ShowToastDialog.showToast("Merchant ID not found");
//         return;
//       }
//       if (selectedState.value == null) {
//         ShowToastDialog.showToast("Please select a state");
//         return;
//       }
//
//       if (selectedCity.value == null) {
//         ShowToastDialog.showToast("Please select a city");
//         return;
//       }
//
//       if (selectedArea.value == null) {
//         ShowToastDialog.showToast("Please select an area");
//         return;
//       }
//       if (sameTimingForAllDays.value) {
//
//         if (openingTimeController.text.trim().isEmpty ||
//             closingTimeController.text.trim().isEmpty) {
//
//           ShowToastDialog.showToast(
//             "Please select opening and closing time",
//           );
//
//           return;
//         }
//
//       } else {
//
//         for (final day in operatingDays) {
//
//           if ((day["openingTime"] as String).isEmpty ||
//               (day["closingTime"] as String).isEmpty) {
//
//             ShowToastDialog.showToast(
//               "Please enter timings for ${day["dayName"]}",
//             );
//
//             return;
//           }
//         }
//       }
//       Map<String, dynamic> body = {
//         "outletName": outletNameController.text.trim(),
//         "merchantId": merchantId,
//
//         "cuisineType": cuisineController.text.trim(),
//
//         "outletPhone": phoneController.text.trim(),
//
//         "outletEmail": emailController.text.trim(),
//         "alternateOutletPhone": alternatePhoneController.text.trim(),
//
//         "username": usernameController.text.trim(),
//
//         "password": passwordController.text.trim(),
//         "fssaiNumber": fssaiNumberController.text.trim(),
//         "gstNumber": gstNumberController.text.trim(),
//         "buildingNumber": buildingController.text.trim(),
//
//         "road": roadController.text.trim(),
//
//         "landmark": landmarkController.text.trim(),
//
//         "cityId": selectedCity.value?.cityId ?? 0,
//
//         "stateId": selectedState.value?.stateId ?? 0,
//
//         "stateName": selectedState.value?.stateName ?? "",
//
//         "areaId": selectedArea.value?.areaId ?? 0,
//
//         "areaName": selectedArea.value?.areaName ?? "",
//
//         "latitude": latitudeController.text.trim(),
//
//         "longitude": longitudeController.text.trim(),
//         "accountHolderName": accountHolderController.text.trim(),
//         "accountNumber": accountNumberController.text.trim(),
//
//         "ifscCode": ifscController.text.trim(),
//
//         "bankName": bankNameController.text.trim(),
//         "updatedBy": merchantId,
//         "operatingDays":
//         sameTimingForAllDays.value
//             ?
//         List.generate(
//           7,
//               (index){
//             return{
//
//               "dayOfWeekId":index+1,
//
//               "isOpen":true,
//
//               "openingTime":
//
//               openingTimeController.text,
//
//               "closingTime":
//
//               closingTimeController.text,
//
//               "slotType":"FULL_DAY"
//
//             };
//
//           },
//
//         )
//             :
//         operatingDays.map((day){
//
//           return{
//
//             "dayOfWeekId":
//
//             day["dayOfWeekId"],
//
//             "isOpen":true,
//
//             "openingTime":
//
//             day["openingTime"],
//
//             "closingTime":
//
//             day["closingTime"],
//
//             "slotType":"FULL_DAY"
//
//           };
//
//         }).toList(),
//         "uploadedBy": "MERCHANT"
//       };
//       print("========== CREATE OUTLET REQUEST ==========");
//       print(body);
//       print("==========================================");
//
//       OutletModel? outlet =
//       await FireStoreUtils.createOutlet(body);
//
//       if (outlet != null) {
//
//         print(
//           "Outlet Created : ${outlet.outletId}",
//         );
//
//         ShowToastDialog.showToast(
//           "Outlet created successfully",
//         );
//
//         Get.back(result: true);
//
//       } else {
//
//         ShowToastDialog.showToast(
//           "Outlet creation failed",
//         );
//       }
//
//     } catch (e) {
//
//       print(e);
//
//       ShowToastDialog.showToast(
//         e.toString(),
//       );
//
//     } finally {
//
//       ShowToastDialog.closeLoader();
//     }
//   }
//
//   @override
//   void onClose() {
//
//     outletNameController.dispose();
//     phoneController.dispose();
//     alternatePhoneController.dispose();
//     emailController.dispose();
//     usernameController.dispose();
//     passwordController.dispose();
//     fssaiNumberController.dispose();
//     gstNumberController.dispose();
//     buildingController.dispose();
//     roadController.dispose();
//     landmarkController.dispose();
//     accountHolderController.dispose();
//
//     accountNumberController.dispose();
//
//     ifscController.dispose();
//
//     bankNameController.dispose();
//
//     openingTimeController.dispose();
//
//     closingTimeController.dispose();
//
//     cityIdController.dispose();
//
//     stateController.dispose();
//
//     areaController.dispose();
//
//     latitudeController.dispose();
//
//     longitudeController.dispose();
//
//     cuisineController.dispose();
//     super.onClose();
//   }
// }






import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/show_toast_dialog.dart';
import '../models/cuisine_type_model.dart';
import '../models/outlet_model.dart';
import '../utils/fire_store_utils.dart';
import '../utils/preferences.dart';
import '../models/location_model.dart';
import '../service/location_api_service.dart';

class AddOutletController extends GetxController {
  // ============================================================
  // BASIC OUTLET CONTROLLERS
  // ============================================================
  RxBool isPasswordHidden = true.obs;
  RxBool isGstApplied = false.obs;
  RxBool isVegOutlet = false.obs;
  final outletNameController = TextEditingController();

  final phoneController = TextEditingController();

  final alternatePhoneController = TextEditingController();

  final emailController = TextEditingController();

  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  final fssaiNumberController = TextEditingController();

  final gstNumberController = TextEditingController();

  final buildingController = TextEditingController();

  final roadController = TextEditingController();

  final landmarkController = TextEditingController();

  // ============================================================
  // CUISINE
  // ============================================================

  /// Stores cuisine IDs selected by the user.
  ///
  /// Example:
  /// [1, 2, 3]
  final selectedCuisineIds = <int>[].obs;
  /// All available cuisine types fetched from the API.
  final cuisineTypes = <CuisineTypeModel>[].obs;
  /// Toggle cuisine selection.
  void toggleCuisine(int cuisineId) {
    if (selectedCuisineIds.contains(cuisineId)) {
      selectedCuisineIds.remove(cuisineId);
    } else {
      selectedCuisineIds.add(cuisineId);
    }
  }
  final isCuisineLoading = false.obs;
  /// Check whether a cuisine is selected.
  bool isCuisineSelected(int cuisineId) {
    return selectedCuisineIds.contains(cuisineId);
  }
  /// Fetch all cuisine types from the API.
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
  // LOCATION CONTROLLERS
  // ============================================================

  final cityIdController = TextEditingController();

  final stateController = TextEditingController();

  final areaController = TextEditingController();

  final latitudeController = TextEditingController();

  final longitudeController = TextEditingController();

  // ============================================================
  // BANK DETAILS
  // ============================================================

  final accountHolderController = TextEditingController();

  final accountNumberController = TextEditingController();

  final ifscController = TextEditingController();

  final bankNameController = TextEditingController();
  final locationDisplayController = TextEditingController();
  // ============================================================
  // COMMON STATE
  // ============================================================

  RxBool isLoading = false.obs;

  RxBool useMerchantBankDetails = false.obs;

  // ============================================================
  // OPERATING HOURS
  // ============================================================

  /// Checkbox:
  ///
  /// true  = same timings for all days
  /// false = different timings for each day
  RxBool sameTimingForAllDays = true.obs;

  /// Common slots used when:
  ///
  /// sameTimingForAllDays = true
  ///
  /// Example:
  ///
  /// [
  ///   {
  ///     "openingTime": "06:00",
  ///     "closingTime": "10:00",
  ///     "slotType": "BREAKFAST"
  ///   },
  ///   {
  ///     "openingTime": "12:00",
  ///     "closingTime": "15:00",
  ///     "slotType": "LUNCH"
  ///   }
  /// ]
  final commonTimeSlots = <Map<String, dynamic>>[].obs;

  /// Used when:
  ///
  /// sameTimingForAllDays = false
  ///
  /// Each day can contain multiple slots.
  ///
  /// Example:
  ///
  /// {
  ///   "dayOfWeekId": 1,
  ///   "dayName": "Monday",
  ///   "isOpen": true,
  ///   "slots": [
  ///     {
  ///       "openingTime": "06:00",
  ///       "closingTime": "10:00",
  ///       "slotType": "BREAKFAST"
  ///     }
  ///   ]
  /// }
  final operatingDays = <Map<String, dynamic>>[].obs;

  /// Slot type values.
  ///
  /// We will adjust these later if your backend has a fixed enum.


  // ============================================================
  // LOCATION LISTS
  // ============================================================

  RxList<StateModel> states = <StateModel>[].obs;

  RxList<CityModel> cities = <CityModel>[].obs;

  RxList<AreaModel> areas = <AreaModel>[].obs;

  // ============================================================
  // SELECTED LOCATION OBJECTS
  // ============================================================

  Rx<StateModel?> selectedState = Rx<StateModel?>(null);

  Rx<CityModel?> selectedCity = Rx<CityModel?>(null);

  Rx<AreaModel?> selectedArea = Rx<AreaModel?>(null);

  // ============================================================
  // DAYS
  // ============================================================

  final List<String> weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    loadStates();
    loadCuisineTypes();
    initializeOperatingDays();

    initializeCommonTimeSlots();
  }

  // ============================================================
  // COMMON TIME SLOTS
  // ============================================================

  void initializeCommonTimeSlots() {
    commonTimeSlots.clear();

    commonTimeSlots.add({
      "openingTime": "",
      "closingTime": "",
      "slotType": "FULL_DAY",
    });
  }

  /// Add another common slot.
  ///
  /// Example:
  /// Breakfast
  /// Lunch
  /// Dinner
  void addCommonTimeSlot() {
    commonTimeSlots.add({
      "openingTime": "",
      "closingTime": "",
      "slotType": "FULL_DAY",
    });
  }

  // void removeCommonTimeSlot(int slotIndex) {
  //   if (commonTimeSlots.length <= 1) {
  //     ShowToastDialog.showToast(
  //       "At least one time slot is required",
  //     );
  //     return;
  //   }
  //
  //   commonTimeSlots.removeAt(slotIndex);
  // }
  void removeCommonTimeSlot(int slotIndex) {
    commonTimeSlots.removeAt(slotIndex);
  }
  void updateCommonOpeningTime(
      int slotIndex,
      String value,
      ) {
    commonTimeSlots[slotIndex]["openingTime"] = value;

    commonTimeSlots.refresh();
  }

  void updateCommonClosingTime(
      int slotIndex,
      String value,
      ) {
    commonTimeSlots[slotIndex]["closingTime"] = value;

    commonTimeSlots.refresh();
  }



  // ============================================================
  // OPERATING DAYS
  // ============================================================

  void initializeOperatingDays() {
    operatingDays.clear();

    operatingDays.add(
      _createDay(
        dayOfWeekId: 1,
        dayName: "Monday",
      ),
    );
  }

  Map<String, dynamic> _createDay({
    required int dayOfWeekId,
    required String dayName,
  }) {
    return {
      "dayOfWeekId": dayOfWeekId,
      "dayName": dayName,
      "isOpen": true,
      "slots": [
        {
          "openingTime": "",
          "closingTime": "",
          "slotType": "FULL_DAY",
        }
      ],
    };
  }

  /// Add another day.
  ///
  /// Monday
  /// Tuesday
  /// Wednesday...
  void addOperatingDay() {
    if (operatingDays.length >= 7) {
      ShowToastDialog.showToast(
        "All 7 days are already added",
      );
      return;
    }

    final index = operatingDays.length;

    operatingDays.add(
      _createDay(
        dayOfWeekId: index + 1,
        dayName: weekDays[index],
      ),
    );
  }

  // void removeOperatingDay(int dayIndex) {
  //   if (operatingDays.length <= 1) {
  //     ShowToastDialog.showToast(
  //       "At least one day is required",
  //     );
  //     return;
  //   }
  //
  //   operatingDays.removeAt(dayIndex);
  // }
  void removeOperatingDay(int dayIndex) {
    operatingDays.removeAt(dayIndex);
  }
  // ============================================================
  // MULTIPLE SLOTS PER DAY
  // ============================================================

  void addTimeSlot(int dayIndex) {
    final slots =
    operatingDays[dayIndex]["slots"] as List<dynamic>;

    slots.add({
      "openingTime": "",
      "closingTime": "",
      "slotType": "FULL_DAY",
    });

    operatingDays.refresh();
  }
  void removeTimeSlot(int dayIndex, int slotIndex) {
    final slots = operatingDays[dayIndex]["slots"] as List<dynamic>;

    if (slots.length <= 1) {
      operatingDays.removeAt(dayIndex);
    } else {
      slots.removeAt(slotIndex);
      operatingDays.refresh();
    }
  }


  void updateOpeningTime(
      int dayIndex,
      int slotIndex,
      String value,
      ) {
    final slots =
    operatingDays[dayIndex]["slots"] as List<dynamic>;

    slots[slotIndex]["openingTime"] = value;

    operatingDays.refresh();
  }

  void updateClosingTime(
      int dayIndex,
      int slotIndex,
      String value,
      ) {
    final slots =
    operatingDays[dayIndex]["slots"] as List<dynamic>;

    slots[slotIndex]["closingTime"] = value;

    operatingDays.refresh();
  }



  // ============================================================
  // TIME PICKER
  // ============================================================

  Future<String?> pickTime(
      BuildContext context,
      ) async {
    final TimeOfDay? picked =
    await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) {
      return null;
    }

    final hour =
    picked.hour.toString().padLeft(2, '0');

    final minute =
    picked.minute.toString().padLeft(2, '0');

    return "$hour:$minute";
  }

  // ============================================================
  // LOCATION API
  // ============================================================

  Future<void> loadStates() async {
    states.value =
    await LocationApiService.fetchStates();
  }

  Future<void> onStateSelected(
      StateModel? state,
      ) async {
    selectedState.value = state;

    selectedCity.value = null;
    selectedArea.value = null;

    cities.clear();
    areas.clear();

    if (state == null) {
      return;
    }

    cities.value =
    await LocationApiService.fetchCities(
      state.stateId,
    );
  }

  Future<void> onCitySelected(
      CityModel? city,
      ) async {
    selectedCity.value = city;

    selectedArea.value = null;

    areas.clear();

    if (city == null) {
      return;
    }

    areas.value =
    await LocationApiService.fetchAreas(
      city.cityId,
    );
  }

  void onAreaSelected(
      AreaModel? area,
      ) {
    selectedArea.value = area;
  }

  // ============================================================
  // BANK DETAILS
  // ============================================================

  void fillMerchantBankDetails() {
    accountHolderController.text =
        Preferences.getString(
          "merchantAccountHolder",
        );

    accountNumberController.text =
        Preferences.getString(
          "merchantAccountNumber",
        );

    ifscController.text =
        Preferences.getString(
          "merchantIfscCode",
        );

    bankNameController.text =
        Preferences.getString(
          "merchantBankName",
        );
  }

  void clearBankDetails() {
    accountHolderController.clear();

    accountNumberController.clear();

    ifscController.clear();

    bankNameController.clear();
  }

  void onMerchantBankChanged(
      bool value,
      ) {
    useMerchantBankDetails.value = value;

    if (value) {
      fillMerchantBankDetails();
    } else {
      clearBankDetails();
    }
  }

  // ============================================================
  // VALIDATE OPERATING HOURS
  // ============================================================

  bool validateOperatingHours() {
    // SAME TIMINGS FOR ALL DAYS
    if (sameTimingForAllDays.value) {
      for (final slot in commonTimeSlots) {
        if ((slot["openingTime"] ?? "")
            .toString()
            .trim()
            .isEmpty ||
            (slot["closingTime"] ?? "")
                .toString()
                .trim()
                .isEmpty) {
          ShowToastDialog.showToast(
            "Please select opening and closing time",
          );

          return false;
        }
      }

      return true;
    }

    // DIFFERENT TIMINGS
    for (final day in operatingDays) {
      final slots = day["slots"] as List<dynamic>;

      if (slots.isEmpty) {
        ShowToastDialog.showToast(
          "Please add a time slot for ${day["dayName"]}",
        );

        return false;
      }

      for (final slot in slots) {
        if ((slot["openingTime"] ?? "")
            .toString()
            .trim()
            .isEmpty ||
            (slot["closingTime"] ?? "")
                .toString()
                .trim()
                .isEmpty) {
          ShowToastDialog.showToast(
            "Please enter timings for ${day["dayName"]}",
          );

          return false;
        }
      }
    }

    return true;
  }

  // ============================================================
  // BUILD OPERATING DAYS API REQUEST
  // ============================================================

  List<Map<String, dynamic>> buildOperatingDaysRequest() {
    final List<Map<String, dynamic>> result = [];

    // SAME TIMINGS FOR ALL 7 DAYS
    if (sameTimingForAllDays.value) {
      for (int dayId = 1; dayId <= 7; dayId++) {
        for (final slot in commonTimeSlots) {
          result.add({
            "dayOfWeekId": dayId,
            "isOpen": true,
            "openingTime":
            slot["openingTime"],
            "closingTime":
            slot["closingTime"],
          });
        }
      }

      return result;
    }

    // DIFFERENT TIMINGS FOR EACH DAY
    for (final day in operatingDays) {
      final slots =
      day["slots"] as List<dynamic>;

      for (final slot in slots) {
        result.add({
          "dayOfWeekId":
          day["dayOfWeekId"],
          "isOpen":
          day["isOpen"] ?? true,
          "openingTime":
          slot["openingTime"],
          "closingTime":
          slot["closingTime"],
        });
      }
    }

    return result;
  }
  // ============================================================
  // VALIDATE OUTLET FORM (no API call)
  // ============================================================

  bool validateOutletForm() {
    final merchantIdStr = Preferences.getString('merchantId');
    final merchantId = int.tryParse(merchantIdStr) ?? 0;

    if (merchantId <= 0) {
      ShowToastDialog.showToast("Merchant ID not found");
      return false;
    }

    if (selectedCuisineIds.isEmpty) {
      ShowToastDialog.showToast("Please select at least one cuisine type");
      return false;
    }

    if (selectedState.value == null) {
      ShowToastDialog.showToast("Please select a state");
      return false;
    }

    if (selectedCity.value == null) {
      ShowToastDialog.showToast("Please select a city");
      return false;
    }

    if (selectedArea.value == null) {
      ShowToastDialog.showToast("Please select an area");
      return false;
    }

    if (latitudeController.text.trim().isEmpty ||
        longitudeController.text.trim().isEmpty) {
      ShowToastDialog.showToast("Please select outlet location");
      return false;
    }

    if (!validateOperatingHours()) {
      return false;
    }

    return true;
  }

  // ============================================================
  // SUBMIT OUTLET (assumes validateOutletForm() already passed)
  // ============================================================

  Future<void> submitOutlet() async {
    ShowToastDialog.showLoader("Please wait");

    try {
      final merchantIdStr = Preferences.getString('merchantId');
      final merchantId = int.tryParse(merchantIdStr) ?? 0;

      final Map<String, dynamic> body = {
        "outletName": outletNameController.text.trim(),
        "merchantId": merchantId,
        "cuisineType": selectedCuisineIds.toList(),
        "outletPhone": phoneController.text.trim(),
        "outletEmail": emailController.text.trim(),
        "alternateOutletPhone": alternatePhoneController.text.trim(),
        "username": usernameController.text.trim(),
        "password": passwordController.text.trim(),
        "fssaiNumber": fssaiNumberController.text.trim(),
        "gstNumber": gstNumberController.text.trim(),
        "isGstApplied": isGstApplied.value,
        "isVegOutlet": isVegOutlet.value,
        "buildingNumber": buildingController.text.trim(),
        "road": roadController.text.trim(),
        "landmark": landmarkController.text.trim(),
        "cityId": selectedCity.value?.cityId ?? 0,
        "cityName": selectedCity.value?.cityName ?? "",
        "stateId": selectedState.value?.stateId ?? 0,
        "stateName": selectedState.value?.stateName ?? "",
        "areaId": selectedArea.value?.areaId ?? 0,
        "areaName": selectedArea.value?.areaName ?? "",
        "latitude": latitudeController.text.trim(),
        "longitude": longitudeController.text.trim(),
        "accountHolderName": accountHolderController.text.trim(),
        "accountNumber": accountNumberController.text.trim(),
        "ifscCode": ifscController.text.trim(),
        "bankName": bankNameController.text.trim(),
        "updatedBy": merchantId,
        "operatingDays": buildOperatingDaysRequest(),
        "uploadedBy": "MERCHANT",
      };

      print("========== CREATE OUTLET REQUEST ==========");
      print(body);
      print("==========================================");

      final OutletModel? outlet = await FireStoreUtils.createOutlet(body);

      if (outlet != null) {
        print("Outlet Created : ${outlet.outletId}");
        ShowToastDialog.showToast("Outlet created successfully");
        Get.back(result: true);
      } else {
        ShowToastDialog.showToast("Outlet creation failed");
      }
    } catch (e) {
      print(e);
      ShowToastDialog.showToast(e.toString());
    } finally {
      ShowToastDialog.closeLoader();
    }
  }


  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    outletNameController.dispose();

    phoneController.dispose();

    alternatePhoneController.dispose();

    emailController.dispose();

    usernameController.dispose();

    passwordController.dispose();

    fssaiNumberController.dispose();

    gstNumberController.dispose();

    buildingController.dispose();

    roadController.dispose();

    landmarkController.dispose();

    accountHolderController.dispose();

    accountNumberController.dispose();

    ifscController.dispose();

    bankNameController.dispose();

    cityIdController.dispose();

    stateController.dispose();

    areaController.dispose();

    latitudeController.dispose();

    longitudeController.dispose();

    super.onClose();
  }
}