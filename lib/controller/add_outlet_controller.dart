import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/show_toast_dialog.dart';
import '../models/outlet_model.dart';
import '../utils/fire_store_utils.dart';
import '../utils/preferences.dart';
import '../models/location_model.dart';
import '../service/location_api_service.dart';
class AddOutletController extends GetxController {

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
  final cuisineController = TextEditingController();

  final cityIdController = TextEditingController();

  final stateController = TextEditingController();

  final areaController = TextEditingController();

  final latitudeController = TextEditingController();

  final longitudeController = TextEditingController();

  final openingTimeController = TextEditingController();

  final closingTimeController = TextEditingController();

// Bank Details Controllers
  final accountHolderController = TextEditingController();

  final accountNumberController = TextEditingController();

  final ifscController = TextEditingController();

  final bankNameController = TextEditingController();
  RxBool isLoading = false.obs;
  RxBool useMerchantBankDetails = false.obs;
  /// ---------- Operating Hours ----------

  RxBool sameTimingForAllDays = true.obs;

  RxList<Map<String, dynamic>> operatingDays =
      <Map<String, dynamic>>[].obs;
  /// Location Lists
  RxList<StateModel> states = <StateModel>[].obs;
  RxList<CityModel> cities = <CityModel>[].obs;
  RxList<AreaModel> areas = <AreaModel>[].obs;

  /// Selected Objects
  Rx<StateModel?> selectedState = Rx<StateModel?>(null);
  Rx<CityModel?> selectedCity = Rx<CityModel?>(null);
  Rx<AreaModel?> selectedArea = Rx<AreaModel?>(null);
  @override
  void onInit() {
    super.onInit();
    loadStates();

    initializeOperatingDays();
  }
  void initializeOperatingDays() {

    operatingDays.clear();

    operatingDays.add({

      "dayOfWeekId":1,

      "dayName":"Monday",

      "openingTime":"",

      "closingTime":"",

      "isOpen":true

    });

  }
  void addOperatingDay() {

    if(operatingDays.length>=7){
      return;
    }

    const days=[

      "Monday",

      "Tuesday",

      "Wednesday",

      "Thursday",

      "Friday",

      "Saturday",

      "Sunday"

    ];

    final index=operatingDays.length;

    operatingDays.add({

      "dayOfWeekId":index+1,

      "dayName":days[index],

      "openingTime":"",

      "closingTime":"",

      "isOpen":true

    });

  }void removeOperatingDay(int index){

    operatingDays.removeAt(index);

  }void updateOpeningTime(
      int index,
      String value){

    operatingDays[index]["openingTime"]=value;

    operatingDays.refresh();

  }void updateClosingTime(
      int index,
      String value){

    operatingDays[index]["closingTime"]=value;

    operatingDays.refresh();

  }Future<String?> pickTime(BuildContext context) async {

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) return null;

    final hour = picked.hour.toString().padLeft(2, '0');

    final minute = picked.minute.toString().padLeft(2, '0');

    return "$hour:$minute";

  }
  Future<void> loadStates() async {
    states.value = await LocationApiService.fetchStates();
  }
  Future<void> onStateSelected(StateModel? state) async {
    selectedState.value = state;

    selectedCity.value = null;
    selectedArea.value = null;

    cities.clear();
    areas.clear();

    if (state == null) return;

    cities.value =
    await LocationApiService.fetchCities(state.stateId);
  }Future<void> onCitySelected(CityModel? city) async {

    selectedCity.value = city;

    selectedArea.value = null;

    areas.clear();

    if (city == null) return;

    areas.value =
    await LocationApiService.fetchAreas(city.cityId);
  }void onAreaSelected(AreaModel? area) {
    selectedArea.value = area;
  }
  void fillMerchantBankDetails() {
    accountHolderController.text =
        Preferences.getString("merchantAccountHolder");

    accountNumberController.text =
        Preferences.getString("merchantAccountNumber");

    ifscController.text =
        Preferences.getString("merchantIfscCode");

    bankNameController.text =
        Preferences.getString("merchantBankName");

    print("Merchant Bank Details Loaded");
  }
  void clearBankDetails() {
    accountHolderController.clear();
    accountNumberController.clear();
    ifscController.clear();
    bankNameController.clear();
  }
  void onMerchantBankChanged(bool value) {
    useMerchantBankDetails.value = value;

    if (value) {
      fillMerchantBankDetails();
    } else {
      clearBankDetails();
    }
  }
  Future<void> saveOutlet() async {

    ShowToastDialog.showLoader("Please wait");

    try {

      final merchantIdStr = Preferences.getString('merchantId');
      final merchantId = int.tryParse(merchantIdStr) ?? 0;

      if (merchantId <= 0) {
        ShowToastDialog.showToast("Merchant ID not found");
        return;
      }
      if (selectedState.value == null) {
        ShowToastDialog.showToast("Please select a state");
        return;
      }

      if (selectedCity.value == null) {
        ShowToastDialog.showToast("Please select a city");
        return;
      }

      if (selectedArea.value == null) {
        ShowToastDialog.showToast("Please select an area");
        return;
      }
      if (sameTimingForAllDays.value) {

        if (openingTimeController.text.trim().isEmpty ||
            closingTimeController.text.trim().isEmpty) {

          ShowToastDialog.showToast(
            "Please select opening and closing time",
          );

          return;
        }

      } else {

        for (final day in operatingDays) {

          if ((day["openingTime"] as String).isEmpty ||
              (day["closingTime"] as String).isEmpty) {

            ShowToastDialog.showToast(
              "Please enter timings for ${day["dayName"]}",
            );

            return;
          }
        }
      }
      Map<String, dynamic> body = {
        "outletName": outletNameController.text.trim(),
        "merchantId": merchantId,

        "cuisineType": cuisineController.text.trim(),

        "outletPhone": phoneController.text.trim(),

        "outletEmail": emailController.text.trim(),
        "alternateOutletPhone": alternatePhoneController.text.trim(),

        "username": usernameController.text.trim(),

        "password": passwordController.text.trim(),
        "fssaiNumber": fssaiNumberController.text.trim(),
        "gstNumber": gstNumberController.text.trim(),
        "buildingNumber": buildingController.text.trim(),

        "road": roadController.text.trim(),

        "landmark": landmarkController.text.trim(),

        "cityId": selectedCity.value?.cityId ?? 0,

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
        "operatingDays":
        sameTimingForAllDays.value
            ?
        List.generate(
          7,
              (index){
            return{

              "dayOfWeekId":index+1,

              "isOpen":true,

              "openingTime":

              openingTimeController.text,

              "closingTime":

              closingTimeController.text,

              "slotType":"FULL_DAY"

            };

          },

        )
            :
        operatingDays.map((day){

          return{

            "dayOfWeekId":

            day["dayOfWeekId"],

            "isOpen":true,

            "openingTime":

            day["openingTime"],

            "closingTime":

            day["closingTime"],

            "slotType":"FULL_DAY"

          };

        }).toList(),
        "uploadedBy": "MERCHANT"
      };
      print("========== CREATE OUTLET REQUEST ==========");
      print(body);
      print("==========================================");

      OutletModel? outlet =
      await FireStoreUtils.createOutlet(body);

      if (outlet != null) {

        print(
          "Outlet Created : ${outlet.outletId}",
        );

        ShowToastDialog.showToast(
          "Outlet created successfully",
        );

        Get.back(result: true);

      } else {

        ShowToastDialog.showToast(
          "Outlet creation failed",
        );
      }

    } catch (e) {

      print(e);

      ShowToastDialog.showToast(
        e.toString(),
      );

    } finally {

      ShowToastDialog.closeLoader();
    }
  }

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

    openingTimeController.dispose();

    closingTimeController.dispose();

    cityIdController.dispose();

    stateController.dispose();

    areaController.dispose();

    latitudeController.dispose();

    longitudeController.dispose();

    cuisineController.dispose();
    super.onClose();
  }
}