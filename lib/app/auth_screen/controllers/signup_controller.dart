import 'package:jippymart_restaurant/app/auth_screen/screens/login_screen.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/models/merchant_request_model.dart';
import '../../../models/location_model.dart';
import '../../../models/outlet_model.dart';
import '../../../service/location_api_service.dart';
import '../../../utils/fire_store_utils.dart';
import '../../../utils/preferences.dart';


class SignupController extends GetxController {
  Rx<TextEditingController> firstNameEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> lastNameEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> emailEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> phoneNUmberEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> usernameController =
      TextEditingController().obs;
  Rx<TextEditingController> passwordEditingController =
      TextEditingController().obs;
  // Rx<TextEditingController> conformPasswordEditingController =
  //     TextEditingController().obs;
  //  this is the new java fields
  Rx<TextEditingController> dobController =
      TextEditingController().obs;

  Rx<TextEditingController> outletTypeController =
      TextEditingController().obs;

  Rx<TextEditingController> panController =
      TextEditingController().obs;

  Rx<TextEditingController> aadhaarController =
      TextEditingController().obs;

  Rx<TextEditingController> fssaiController =
      TextEditingController().obs;

  Rx<TextEditingController> gstController =
      TextEditingController().obs;

  Rx<TextEditingController> accountNumberController =
      TextEditingController().obs;

  Rx<TextEditingController> ifscController =
      TextEditingController().obs;

  Rx<TextEditingController> bankLocationController =
      TextEditingController().obs;

  Rx<TextEditingController> accountHolderController =
      TextEditingController().obs;
//
  RxBool passwordVisible = true.obs;
  RxBool conformPasswordVisible = true.obs;

  RxString type = "".obs;
  RxString accountType = "Merchant".obs;
  //
  Rx<TextEditingController> outletNameController =
      TextEditingController().obs;
  Rx<TextEditingController> merchantIdController =
      TextEditingController().obs;
  Rx<TextEditingController> cuisineTypeController =
      TextEditingController().obs;

  Rx<TextEditingController> outletPhoneController =
      TextEditingController().obs;

  Rx<TextEditingController> buildingNumberController =
      TextEditingController().obs;

  Rx<TextEditingController> roadController =
      TextEditingController().obs;

  Rx<TextEditingController> landmarkController =
      TextEditingController().obs;

  Rx<TextEditingController> stateNameController =
      TextEditingController().obs;

  Rx<TextEditingController> cityController =
      TextEditingController().obs;

  Rx<TextEditingController> areaNameController =
      TextEditingController().obs;
  Rx<TextEditingController> latitudeController =
      TextEditingController().obs;

  Rx<TextEditingController> longitudeController =
      TextEditingController().obs;
  RxList<StateModel> states = <StateModel>[].obs;
  RxList<CityModel> cities = <CityModel>[].obs;
  RxList<AreaModel> areas = <AreaModel>[].obs;

  Rx<StateModel?> selectedState = Rx<StateModel?>(null);
  Rx<CityModel?> selectedCity = Rx<CityModel?>(null);
  Rx<AreaModel?> selectedArea = Rx<AreaModel?>(null);
  final locationDisplayController = TextEditingController();

  //


  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    // Set default country code to India
    countryCodeEditingController.value.text = '+91';
    loadStates(); // NEW
    super.onInit();
  }
  Future<void> loadStates() async {
    try {
      print("Loading states...");
      states.value = await LocationApiService.fetchStates();
      print("States loaded: ${states.length}");
    } catch (e) {
      print("Error loading states: $e");
    }
  }
  Future<void> onStateSelected(StateModel? state) async {
    selectedState.value = state;
    selectedCity.value = null;
    selectedArea.value = null;
    cities.clear();
    areas.clear();
    if (state == null) return;
    cities.value = await LocationApiService.fetchCities(state.stateId);
  }

  Future<void> onCitySelected(CityModel? city) async {
    selectedCity.value = city;
    selectedArea.value = null;
    areas.clear();
    if (city == null) return;
    areas.value = await LocationApiService.fetchAreas(city.cityId);
  }

  void onAreaSelected(AreaModel? area) {
    selectedArea.value = area;
  }
  getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      type.value = argumentData['type'];
      // Only overwrite userModel if one was actually passed
      if (argumentData['userModel'] != null) {
        userModel.value = argumentData['userModel'];
      }
      if (type.value == "mobileNumber") {
        phoneNUmberEditingController.value.text =
            userModel.value.phoneNumber.toString();
        countryCodeEditingController.value.text =
            userModel.value.countryCode.toString();
      } else if (type.value == "google" || type.value == "apple") {
        emailEditingController.value.text = userModel.value.email ?? "";
        firstNameEditingController.value.text = userModel.value.firstName ?? "";
        lastNameEditingController.value.text = userModel.value.lastName ?? "";
      }else if (type.value == "emailVerified") {
        emailEditingController.value.text = argumentData['email'] ?? "";
        phoneNUmberEditingController.value.text = argumentData['mobile'] ?? "";
      }
    }
  }
  signUpWithEmailAndPassword() async {
    await signUp();
  }

  // this is java API signup
  Future<void> signUp() async {
    ShowToastDialog.showLoader("Please wait");

    try {
      final request = MerchantRequestModel(
        firstName: firstNameEditingController.value.text.trim(),
        lastName: lastNameEditingController.value.text.trim(),
        dob: dobController.value.text.trim(),
        email: emailEditingController.value.text.trim(),
        phone: phoneNUmberEditingController.value.text.trim(),
        username: usernameController.value.text.trim(),
        password: passwordEditingController.value.text.trim(),
        outletType: outletTypeController.value.text.trim(),
        uploadedBy: "MERCHANT",
        pan: panController.value.text.trim(),
        adhar: aadhaarController.value.text.trim(),
        fssai: fssaiController.value.text.trim(),
        gstNumber: gstController.value.text.trim(),
        accountNumber: accountNumberController.value.text.trim(),
        ifscCode: ifscController.value.text.trim(),
        bankLocation: bankLocationController.value.text.trim(),
        nameInBankAccount: accountHolderController.value.text.trim(),
        // NEW — address fields
        buildingNumber: buildingNumberController.value.text.trim(),
        road: roadController.value.text.trim(),
        landmark: landmarkController.value.text.trim(),
        stateId: selectedState.value?.stateId,
        cityId: selectedCity.value?.cityId,
        areaId: selectedArea.value?.areaId,
        latitude: latitudeController.value.text.trim(),
        longitude: longitudeController.value.text.trim(),
      );

      final merchant =
      await FireStoreUtils.createMerchant(request);

      if (merchant != null) {
        print("========== MERCHANT ID = ${merchant.merchantId} ==========");
        ShowToastDialog.showToast(
          "Merchant registered successfully",
        );

        Get.offAll(const LoginScreen());

      } else {

        ShowToastDialog.showToast(
          "Merchant registration failed",
        );

      }
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    } finally {
      ShowToastDialog.closeLoader();
    }
  }
// Helper method for post-signup navigation
  handlePostSignupNavigation() async {
    // App is now 100% free - no subscription checks needed
    Get.offAll(const LoginScreen());
  }
  //THIS IS CREATE OUTLET METGHOD FOR SIGNUP OF OUTLET
  Future<void> createOutlet() async {
    ShowToastDialog.showLoader("Please wait");

    try {
      final merchantId =
          int.tryParse(
            Preferences.getString('merchantId'),
          ) ??
              0;

      if (merchantId <= 0) {
        ShowToastDialog.showToast(
          "Merchant ID not found",
        );
        return;
      }

      if (outletNameController.value.text.trim().isEmpty) {
        ShowToastDialog.showToast(
          "Please enter outlet name",
        );
        return;
      }

      if (outletPhoneController.value.text.trim().isEmpty) {
        ShowToastDialog.showToast(
          "Please enter outlet phone",
        );
        return;
      }

      Map<String, dynamic> body = {
        "outletName":
        outletNameController.value.text.trim(),

        "merchantId": merchantId,

        "cuisineType":
        cuisineTypeController.value.text.trim(),

        "outletPhone":
        outletPhoneController.value.text.trim(),

        "buildingNumber":
        buildingNumberController.value.text.trim(),

        "road":
        roadController.value.text.trim(),

        "landmark":
        landmarkController.value.text.trim(),

        "cityId":
        int.tryParse(
          cityController.value.text.trim(),
        ) ??
            0,

        "stateName":
        stateNameController.value.text.trim(),

        "areaName":
        areaNameController.value.text.trim(),

        "latitude":
        latitudeController.value.text.trim(),

        "longitude":
        longitudeController.value.text.trim(),

        "operatingDays": [
          {
            "dayOfWeekId": 1,
            "isOpen": true,
            "openingTime": "09:00",
            "closingTime": "22:00",
            "slotType": "FULL_DAY"
          }
        ],

        "uploadedBy": "MERCHANT"
      };

      print("=== CREATE OUTLET REQUEST ===");
      print(body);

      OutletModel? outlet =
      await FireStoreUtils.createOutlet(body);

      if (outlet != null) {
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
      print("CREATE OUTLET ERROR: $e");

      ShowToastDialog.showToast(
        e.toString(),
      );
    } finally {
      ShowToastDialog.closeLoader();
    }
  }
  @override
  void onClose() {
    firstNameEditingController.value.dispose();
    lastNameEditingController.value.dispose();
    emailEditingController.value.dispose();
    phoneNUmberEditingController.value.dispose();
    countryCodeEditingController.value.dispose();
    usernameController.value.dispose();
    passwordEditingController.value.dispose();
    dobController.value.dispose();
    outletTypeController.value.dispose();
    panController.value.dispose();
    aadhaarController.value.dispose();
    fssaiController.value.dispose();
    gstController.value.dispose();
    accountNumberController.value.dispose();
    ifscController.value.dispose();
    bankLocationController.value.dispose();
    accountHolderController.value.dispose();
    outletNameController.value.dispose();
    merchantIdController.value.dispose();
    cuisineTypeController.value.dispose();
    outletPhoneController.value.dispose();
    buildingNumberController.value.dispose();
    roadController.value.dispose();
    landmarkController.value.dispose();
    stateNameController.value.dispose();
    cityController.value.dispose();
    areaNameController.value.dispose();
    latitudeController.value.dispose();
    longitudeController.value.dispose();
    locationDisplayController.dispose();
    super.onClose();
  }


}
