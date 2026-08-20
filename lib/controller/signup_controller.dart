import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jippymart_restaurant/app/auth_screen/login_screen.dart';
import 'package:jippymart_restaurant/app/dash_board_screens/app_not_access_screen.dart';
import 'package:jippymart_restaurant/app/dash_board_screens/dash_board_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/utils/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/models/merchant_response_model.dart';
import 'package:jippymart_restaurant/models/merchant_request_model.dart';

import '../models/outlet_model.dart';
import '../utils/fire_store_utils.dart';
import '../utils/preferences.dart';
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
  //


  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    // Set default country code to India
    countryCodeEditingController.value.text = '+91';
    super.onInit();
  }

  getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      type.value = argumentData['type'];
      userModel.value = argumentData['userModel'];
      if (type.value == "mobileNumber") {
        phoneNUmberEditingController.value.text =
            userModel.value.phoneNumber.toString();
        countryCodeEditingController.value.text =
            userModel.value.countryCode.toString();
      } else if (type.value == "google" || type.value == "apple") {
        emailEditingController.value.text = userModel.value.email ?? "";
        firstNameEditingController.value.text = userModel.value.firstName ?? "";
        lastNameEditingController.value.text = userModel.value.lastName ?? "";
      }
    }
  }
  signUpWithEmailAndPassword() async {
    await signUp();
  }
// THIS IS PHP SIGNUP() METHOD
//   signUp() async {
//     ShowToastDialog.showLoader("Please wait");
//     try {
//       userModel.value.firstName = firstNameEditingController.value.text.toString();
//       userModel.value.lastName = lastNameEditingController.value.text.toString();
//       userModel.value.email = emailEditingController.value.text.toString().toLowerCase();
//       userModel.value.phoneNumber = phoneNUmberEditingController.value.text.toString();
//       userModel.value.role = Constant.userRoleVendor;
//       userModel.value.fcmToken = await NotificationService.getToken();
//       userModel.value.active = Constant.autoApproveRestaurant == true ? true : false;
//       userModel.value.countryCode = countryCodeEditingController.value.text;
//       userModel.value.isDocumentVerify = Constant.isRestaurantVerification == true ? false : true;
//       userModel.value.createdAt = Timestamp.now();
//       userModel.value.appIdentifier = Platform.isAndroid ? 'android' : 'ios';
//       if (type.value == "email") {
//         userModel.value.provider = 'email';
//       }
//       final bodyJson = {
//         "type": "email",
//         "first_name": userModel.value.firstName,
//         "last_name": userModel.value.lastName,
//         "email": userModel.value.email,
//         "password": passwordEditingController.value.text.trim() ,
//         "phone_number": userModel.value.phoneNumber,
//         "country_code": userModel.value.countryCode,
//         "zone_id": "1", // You might want to make this dynamic
//         "fcm_token": userModel.value.fcmToken,
//         "app_identifier": userModel.value.appIdentifier,
//       };
//       print("signUp ${bodyJson} ");
//       http.Response response = await http.post(
//         Uri.parse( '${Constant.baseUrl}restaurant/signup',),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode(bodyJson,),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = jsonDecode(response.body);
//         userModel.value.id = responseData['data']?['id']?.toString() ?? '';
//         Constant.userModel = userModel.value;
//         if (Constant.autoApproveRestaurant == true) {
//           await handlePostSignupNavigation();
//         } else {
//           ShowToastDialog.showToast(
//               "Thank you for sign up, your application is under approval so please wait till that approve.".tr
//           );
//           Get.offAll(const LoginScreen());
//         }
//       } else {
//         final errorData = jsonDecode(response.body);
//         ShowToastDialog.showToast(
//             errorData['message']?.toString() ?? 'Signup failed. Please try again.'.tr
//         );
//       }
//     } catch (e) {
//       // Handle network or other errors
//       ShowToastDialog.showToast(e.toString());
//     } finally {
//       ShowToastDialog.closeLoader();
//     }
//   }

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
        nameInBankAccount:
        accountHolderController.value.text.trim(),
      );
      //
      // final success =
      // await FireStoreUtils.createMerchant(request);
      //
      // if (success != null) {
      //   ShowToastDialog.showToast(
      //     "Merchant registered successfully",
      //   );
      //
      //   Get.offAll(const LoginScreen());
      // } else {
      //   ShowToastDialog.showToast(
      //     "Merchant registration failed",
      //   );
      // }
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
  // signUpWithEmailAndPassword() async {
  //   signUp();
  // }

  // signUp() async {
  //   ShowToastDialog.showLoader("Please wait");
  //   if (type.value == "google" ||
  //       type.value == "apple" ||
  //       type.value == "mobileNumber") {
  //     userModel.value.firstName =
  //         firstNameEditingController.value.text.toString();
  //     userModel.value.lastName =
  //         lastNameEditingController.value.text.toString();
  //     userModel.value.email =
  //         emailEditingController.value.text.toString().toLowerCase();
  //     userModel.value.phoneNumber =
  //         phoneNUmberEditingController.value.text.toString();
  //     userModel.value.role = Constant.userRoleVendor;
  //     userModel.value.fcmToken = await NotificationService.getToken();
  //     userModel.value.active =
  //         Constant.autoApproveRestaurant == true ? true : false;
  //     userModel.value.countryCode = countryCodeEditingController.value.text;
  //     userModel.value.isDocumentVerify =
  //         Constant.isRestaurantVerification == true ? false : true;
  //     userModel.value.createdAt = Timestamp.now();
  //     userModel.value.appIdentifier = Platform.isAndroid ? 'android' : 'ios';
  //
  //     await FireStoreUtils.updateUser(userModel.value).then(
  //       (value) async {
  //         if (Constant.autoApproveRestaurant == true) {
  //           bool isPlanExpire = false;
  //           if (userModel.value.subscriptionPlan?.id != null) {
  //             if (userModel.value.subscriptionExpiryDate == null) {
  //               if (userModel.value.subscriptionPlan?.expiryDay == '-1') {
  //                 isPlanExpire = false;
  //               } else {
  //                 isPlanExpire = true;
  //               }
  //             } else {
  //               DateTime expiryDate =
  //                   userModel.value.subscriptionExpiryDate!.toDate();
  //               isPlanExpire = expiryDate.isBefore(DateTime.now());
  //             }
  //           } else {
  //             isPlanExpire = true;
  //           }
  //           if (userModel.value.subscriptionPlanId == null ||
  //               isPlanExpire == true) {
  //             if (Constant.adminCommission?.isEnabled == false &&
  //                 Constant.isSubscriptionModelApplied == false) {
  //               Get.offAll(const DashBoardScreen());
  //             } else {
  //               Get.offAll(const SubscriptionPlanScreen());
  //             }
  //           } else if (userModel.value.subscriptionPlan?.features
  //                       ?.restaurantMobileApp !=
  //                   false ||
  //               userModel.value.subscriptionPlan?.type == 'free') {
  //             Get.offAll(const DashBoardScreen());
  //           } else {
  //             Get.offAll(const AppNotAccessScreen());
  //           }
  //         } else {
  //           ShowToastDialog.showToast(
  //               "Thank you for sign up, your application is under approval so please wait till that approve."
  //                   .tr);
  //           Get.offAll(const LoginScreen());
  //         }
  //       },
  //     );
  //   } else {
  //     try {
  //       final credential =
  //           await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //         email: emailEditingController.value.text.trim(),
  //         password: passwordEditingController.value.text.trim(),
  //       );
  //       if (credential.user != null) {
  //         userModel.value.id = credential.user!.uid;
  //         userModel.value.firstName =
  //             firstNameEditingController.value.text.toString();
  //         userModel.value.lastName =
  //             lastNameEditingController.value.text.toString();
  //         userModel.value.email =
  //             emailEditingController.value.text.toString().toLowerCase();
  //         userModel.value.phoneNumber =
  //             phoneNUmberEditingController.value.text.toString();
  //         userModel.value.role = Constant.userRoleVendor;
  //         userModel.value.fcmToken = await NotificationService.getToken();
  //         userModel.value.active =
  //             Constant.autoApproveRestaurant == true ? true : false;
  //         userModel.value.isDocumentVerify =
  //             Constant.isRestaurantVerification == true ? false : true;
  //         userModel.value.countryCode = countryCodeEditingController.value.text;
  //         userModel.value.appIdentifier =
  //             Platform.isAndroid ? 'android' : 'ios';
  //         userModel.value.createdAt = Timestamp.now();
  //         userModel.value.provider = 'email';
  //
  //         await FireStoreUtils.updateUser(userModel.value).then(
  //           (value) async {
  //             if (Constant.autoApproveRestaurant == true) {
  //               bool isPlanExpire = false;
  //               if (userModel.value.subscriptionPlan?.id != null) {
  //                 if (userModel.value.subscriptionExpiryDate == null) {
  //                   if (userModel.value.subscriptionPlan?.expiryDay == '-1') {
  //                     isPlanExpire = false;
  //                   } else {
  //                     isPlanExpire = true;
  //                   }
  //                 } else {
  //                   DateTime expiryDate =
  //                       userModel.value.subscriptionExpiryDate!.toDate();
  //                   isPlanExpire = expiryDate.isBefore(DateTime.now());
  //                 }
  //               } else {
  //                 isPlanExpire = true;
  //               }
  //               if (userModel.value.subscriptionPlanId == null ||
  //                   isPlanExpire == true) {
  //                 if (Constant.adminCommission?.isEnabled == false &&
  //                     Constant.isSubscriptionModelApplied == false) {
  //                   Get.offAll(const DashBoardScreen());
  //                 } else {
  //                   Get.offAll(const SubscriptionPlanScreen());
  //                 }
  //               } else if (userModel.value.subscriptionPlan?.features
  //                           ?.restaurantMobileApp !=
  //                       false ||
  //                   userModel.value.subscriptionPlan?.type == 'free') {
  //                 Get.offAll(const DashBoardScreen());
  //               } else {
  //                 Get.offAll(const AppNotAccessScreen());
  //               }
  //             } else {
  //               ShowToastDialog.showToast(
  //                   "Thank you for sign up, your application is under approval so please wait till that approve."
  //                       .tr);
  //               Get.offAll(const LoginScreen());
  //             }
  //           },
  //         );
  //       }
  //     } on FirebaseAuthException catch (e) {
  //       if (e.code == 'weak-password') {
  //         ShowToastDialog.showToast("The password provided is too weak.".tr);
  //       } else if (e.code == 'email-already-in-use') {
  //         ShowToastDialog.showToast(
  //             "The account already exists for that email.".tr);
  //       } else if (e.code == 'invalid-email') {
  //         ShowToastDialog.showToast("Enter email is Invalid".tr);
  //       }
  //     } catch (e) {
  //       ShowToastDialog.showToast(e.toString());
  //     }
  //   }
  //
  //   ShowToastDialog.closeLoader();
  // }
}
