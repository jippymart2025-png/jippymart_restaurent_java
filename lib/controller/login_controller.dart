import 'dart:convert';

import 'package:jippymart_restaurant/app/dash_board_screens/dash_board_screen.dart';
import 'package:jippymart_restaurant/app/landing_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/service/audio_player_service.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/notification/notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;


import '../utils/common.dart';
import '../utils/preferences.dart' show Preferences;

import 'dash_board_controller.dart';
import 'merchant_outlet_controller.dart';


class LoginController extends GetxController {


  void proceedToMainApp() async {
    try {
      if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
        Get.offAll(
              () => const LandingScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 1200),
        );
        return;
      }

      // FireStoreUtils.getAvalibleDrivers();

      bool isLogin = await FireStoreUtils.isLogin();
      if (!isLogin) {
        Get.offAll(() => const LandingScreen());
        return;
      }

      final loginType = Preferences.getString('loginType');
      final authToken = Preferences.getString('authToken');

      // Restore Java merchant/outlet session saved at login.
      if (authToken.isNotEmpty &&
          (loginType == 'MERCHANT' || loginType == 'OUTLET')) {
        if (loginType == 'MERCHANT') {
          if (!Get.isRegistered<MerchantOutletController>()) {
            Get.put(MerchantOutletController(), permanent: true);
          }
          await Get.find<MerchantOutletController>()
              .initializeMerchantSession();
        } else {
          final merchantId = Preferences.getString('merchantId');
          if (merchantId.isNotEmpty) {
            try {
              final profile =
                  await FireStoreUtils.getMerchantProfile(merchantId);
              if (profile != null) {
                Constant.userModel = profile;
              }
            } catch (e) {
              print('proceedToMainApp outlet profile restore: $e');
            }
          }
        }

        Get.offAll(
          () => const DashBoardScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
        return;
      }

      final userId = await FireStoreUtils.getCurrentUid();
      if (userId.isEmpty) {
        Get.offAll(() => const LandingScreen());
        return;
      }

      final userModel = await FireStoreUtils.getUserProfile(userId);
      if (userModel == null) {
        Get.offAll(() => const LandingScreen());
        return;
      }

      if (userModel.merchantId != null && userModel.merchantId!.isNotEmpty) {
        Preferences.setString('merchantId', userModel.merchantId!);
      }

      if (userModel.role != Constant.userRoleMerchant || userModel.active != true) {
        Get.offAll(() => const LandingScreen());
        return;
      }

      Get.offAll(
            () => const DashBoardScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );

      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        userModel.fcmToken = fcmToken;
        await FireStoreUtils.updateUser(userModel);
      }

    } catch (e) {
      print("proceedToMainApp error: $e");
      Get.offAll(() => const LandingScreen());
    }
  }


  Rx<TextEditingController> emailEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> passwordEditingController =
      TextEditingController().obs;

  RxBool passwordVisible = true.obs;

  @override
  void onClose() {
    emailEditingController.value.dispose();
    passwordEditingController.value.dispose();
    super.onClose();
  }




  // THIS IS JAVA CODE OF LOGINAPI
  // static Future<Map<String, dynamic>> loginWithUserNameAndPasswordApi(
  //     String username,
  //     String password,
  //     ) async {
  //   final response = await http.post(
  //     Uri.parse(
  //       '${Constant.baseUrl}fm/auth/login',
  //     ),
  //     headers: await getHeaders(),
  //     body: jsonEncode({
  //       "username": username,
  //       "password": password,
  //     }),
  //   );
  //   print("LOGIN STATUS CODE =====> ${response.statusCode}");
  //   print("LOGIN RESPONSE =====>");
  //   print(response.body);
  //
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   }
  //
  //
  //   throw Exception("Login failed");
  // }
  static Future<Map<String, dynamic>> loginWithUserNameAndPasswordApi(
      String username,
      String password,
      ) async {
    final response = await http.post(
      Uri.parse(
        '${Constant.baseUrl}fm/auth/login',
      ),
      headers: await getHeaders(),
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    print("LOGIN STATUS CODE =====> ${response.statusCode}");
    print("LOGIN RESPONSE =====> ${response.body}");

    try {
      final responseData = jsonDecode(response.body);

      // Login success
      if (response.statusCode == 200) {
        return responseData;
      }

      // Login failed - return backend message
      return {
        "success": false,
        "statusCode": response.statusCode,
        "message": responseData["message"] ??
            responseData["error"] ??
            "Login failed",
      };
    } catch (e) {
      return {
        "success": false,
        "statusCode": response.statusCode,
        "message": "invalid credentials.",
      };
    }
  }


// THIS IS THE JAVA CODE OF LOGIN METHOD START
  loginWithUserNameAndPassword() async {
    ShowToastDialog.showLoader("Please wait.".tr);

    try {
      final response =
      await loginWithUserNameAndPasswordApi(
        emailEditingController.value.text.trim(),
        passwordEditingController.value.text.trim(),
      );

      print("=== LOGIN RESPONSE ===");
      print(response);
      print("=== LOGIN RESPONSE ===");
      print(response);

// Check API login failure
      if (response['success'] == false) {
        ShowToastDialog.showToast(
          response['message'] ?? "Login failed".tr,
        );
        return;
      }

      final String? token = response['jwt'];
      final int userId = response['userId'] ?? 0;
      print("===== LOGIN DEBUG =====");
      print("userId = $userId");
      print("userType = ${response['userType']}");
      print("outletId = ${response['outletId']}");
      print("merchantId = ${response['merchantId']}");
      print("=======================");

      final String role =
          (response['roles'] as List).isNotEmpty
              ? response['roles'][0]
              : '';

      Preferences.setInt('userId', userId);
      Preferences.setString('role', role);

      String loginType = '';
      if (role == "ROLE_ADMIN" || role == "ROLE_MERCHANT") {
        loginType = 'MERCHANT';
      } else if (role == "ROLE_OUTLET" ||
          response['outletId'] != null ||
          response['userType']?.toString().toUpperCase() == 'OUTLET') {
        loginType = 'OUTLET';
      }
      Preferences.setString('loginType', loginType);

      int merchantId = 0;
      int outletId = 0;

      if (loginType == 'MERCHANT') {
        merchantId = _parseLoginInt(response['merchantId']) ?? userId;
        await Preferences.setString('merchantId', merchantId.toString());
        await Preferences.setInt('outletId', 0);
        await Preferences.setInt('selectedOutletId', 0);
      } else if (loginType == 'OUTLET') {
        outletId = _parseLoginInt(response['outletId']) ??
            _parseLoginInt(response['id']) ??
            _parseLoginInt(response['userId']) ??
            0;

        print("OUTLET ID CALCULATED = $outletId");

        if (outletId <= 0) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast(
            'Outlet ID missing from login. Please contact support.'.tr,
          );
          return;
        }
        await Preferences.setInt('outletId', outletId);
        await Preferences.setInt('selectedOutletId', outletId);
        await Preferences.clearKeyData('merchantId');
      }

      print("=== LOGIN PARSED ===");
      print("loginType=$loginType userId=$userId merchantId=$merchantId outletId=$outletId role=$role");

      if (token == null || token.isEmpty) {
        ShowToastDialog.showToast("Login failed".tr);
        return;
      }

      Preferences.setString('authToken', token);

      print("JWT Saved Successfully");

      ShowToastDialog.showToast("Login Successful".tr);

      print("=== LOGIN SUCCESS ===");

      if (loginType == 'MERCHANT') {
        if (Get.isRegistered<MerchantOutletController>()) {
          Get.delete<MerchantOutletController>(force: true);
        }
        final outletController =
            Get.put(MerchantOutletController(), permanent: true);
        await outletController.initializeMerchantSession();
        print("=== MERCHANT SESSION COMPLETE ===");
        print(
          "sessionState=${outletController.sessionState.value} "
          "outletCount=${outletController.outletList.length}",
        );
      } else if (loginType == 'OUTLET') {
        if (Get.isRegistered<MerchantOutletController>()) {
          Get.delete<MerchantOutletController>(force: true);
        }
        final ok = await _initializeOutletSession(outletId);
        if (!ok) {
          await clearUserData();
          ShowToastDialog.showToast(
            "Unable to load outlet. Please try again.".tr,
          );
          return;
        }
        print("=== OUTLET SESSION COMPLETE ===");
      } else {
        await clearUserData();
        ShowToastDialog.showToast("Unknown user role".tr);
        return;
      }

      await _persistLoginSession(userId: userId, token: token);
      await _navigateToDashboardAfterLogin();

    } catch (e) {
      print("LOGIN ERROR = $e");
      ShowToastDialog.showToast(
        "Login Failed".tr,
      );
    } finally {
      ShowToastDialog.closeLoader();
    }
  }


  int? _parseLoginInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Future<void> _persistLoginSession({
    required int userId,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool(Preferences.isFinishOnBoardingKey, true);
    await prefs.setString('firebase_id', userId.toString());
    await prefs.setString('user_id', userId.toString());
    await Preferences.setString('authToken', token);
  }

  // Future<void> _markLoggedIn() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('is_logged_in', true);
  // }

  Future<void> _navigateToDashboardAfterLogin() async {
    if (Get.isRegistered<DashBoardController>()) {
      Get.delete<DashBoardController>(force: true);
    }
    Get.offAll(
      () => const DashBoardScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  /// Outlet login: outletId → getOutletById → merchantId → profile (best-effort)
  Future<bool> _initializeOutletSession(int outletId) async {
    debugPrint('[OutletSession] START — loginType=OUTLET outletId=$outletId');

    if (outletId <= 0) {
      debugPrint('[OutletSession] ERROR — invalid outletId');
      return false;
    }

    debugPrint('[OutletSession] getOutletById REQUEST — outletId=$outletId');
    final result = await FireStoreUtils.fetchOutletById(outletId);
    print("===== OUTLET DEBUG =====");
    print("result.outlet = ${result.outlet}");
    print("result.outlet?.outletName = ${result.outlet?.outletName}");

    debugPrint(
      '[OutletSession] getOutletById RESULT — '
      'status=${result.status} merchantId=${result.merchantId} '
      'parseWarning=${result.hadParseWarning}',
    );

    if (result.hasMerchantId) {
      final merchantId = result.merchantId!;
      final resolvedOutletId = result.outletId ?? outletId;

      await Preferences.setInt('outletId', resolvedOutletId);
      await Preferences.setInt('selectedOutletId', resolvedOutletId);
      await Preferences.setString('selectedOutletName', result.outlet?.outletName ?? '',);
      print("selectedOutletName after save = ${Preferences.getString('selectedOutletName')}");
      await Preferences.setString('loginType', 'OUTLET');
      await Preferences.setString('merchantId', merchantId.toString());

      debugPrint(
        '[OutletSession] Session context — '
        'outletId=$resolvedOutletId merchantId=$merchantId (NOT mixed)',
      );

      if (result.hadParseWarning) {
        debugPrint(
          '[OutletSession] Parse warning ignored — session continues with merchantId',
        );
      }

      try {
        debugPrint(
          '[OutletSession] getMerchantProfile REQUEST — merchantId=$merchantId',
        );
        final profile =
            await FireStoreUtils.getMerchantProfile(merchantId.toString());
        debugPrint(
          '[OutletSession] getMerchantProfile RESPONSE — '
          'success=${profile != null}',
        );
        if (profile != null) {
          Constant.userModel = profile;
        }
      } catch (profileError) {
        debugPrint(
          '[OutletSession] Profile warning (non-fatal) — $profileError',
        );
      }

      debugPrint('[OutletSession] SUCCESS → Outlet Dashboard (products tab)');
      return true;
    }

    debugPrint('[OutletSession] FAILURE — ${result.message}');
    return false;
  }

// Helper method to parse bool from various types
//   bool _parseBoolValue(dynamic value) {
//     if (value == null) return false;
//     if (value is bool) return value;
//     if (value is String) {
//       return value.toLowerCase() == 'true' || value == '1';
//     }
//     if (value is int) {
//       return value == 1;
//     }
//     return false;
//   }

// // Helper method to save user data to SharedPreferences
//   Future<void> _saveUserDataToSharedPreferences(Map<String, dynamic> userData) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('firebase_id', userData['firebase_id'] ?? '');
//     await prefs.setString('email', userData['email'] ?? '');
//     await prefs.setString('fcm_token', userData['fcmToken'] ?? '');
//     await prefs.setString('first_name', userData['firstName'] ?? '');
//     await prefs.setString('last_name', userData['lastName'] ?? '');
//     await prefs.setString('phone_number', userData['phoneNumber'] ?? '');
//     await prefs.setString('country_code', userData['countryCode'] ?? '');
//     await prefs.setString('role', userData['role'] ?? '');
//     await prefs.setString('vendorID', userData['vendorID'] ?? '');
//     await prefs.setBool('is_active', _parseBoolValue(userData['active'] ?? userData['active']));
//     await prefs.setString('user_id', userData['id'].toString());
//     await prefs.setString('profile_picture', userData['profilePictureURL'] ?? '');
//     await prefs.setString('merchantId', userData['merchantId']?.toString() ?? '');
//
//     // Do NOT persist zone here – vendor data is not available yet.
//     await prefs.setBool('is_document_verify', _parseBoolValue(userData['isDocumentVerify']));
//     await prefs.setBool('is_logged_in', true);
//     await prefs.setBool('is_logged_in', true);
//     await prefs.setString('authToken',
//         userData['token'] ??
//             userData['accessToken'] ??
//             userData['jwtToken'] ?? '');
//   }
//
// // Helper method to convert API response to UserModel
//   Future<UserModel?> _convertApiResponseToUserModel(Map<String, dynamic> userData) async {
//     try {
//       Timestamp? _parseTimestamp(dynamic value) {
//         if (value == null) return null;
//         if (value is Timestamp) return value;
//         if (value is String) {// Handle the case where the string might be wrapped in extra quotes
//           String dateString = value.replaceAll('"', '');
//           try {
//             DateTime dateTime = DateTime.parse(dateString);
//             return Timestamp.fromDate(dateTime);
//           } catch (e) {
//             print('Error parsing date: $value - $e');
//             return null;
//           }
//         }
//         if (value is int) {
//           return Timestamp.fromMillisecondsSinceEpoch(value);
//         }
//         return null;
//       }
//       // Convert the API response to your UserModel
//       // You'll need to adjust this based on your actual UserModel structure
//       return UserModel(
//         id: userData['id']?.toString() ?? userData['firebase_id'],
//         firebaseId: userData['firebase_id'],
//         firstName: userData['firstName'],
//         lastName: userData['lastName'],
//         email: userData['email'],
//         phoneNumber: userData['phoneNumber'],
//         countryCode: userData['countryCode'],
//         role: userData['role'],
//         active: _parseBoolValue(userData['active'] ?? userData['active']),
//         profilePictureURL: userData['profilePictureURL'],
//         fcmToken: userData['fcmToken'],
//         zoneId: userData['zoneId'],
//         vendorID: userData['vendorID']?.toString() ?? userData['vendorID'],
//         isDocumentVerify: _parseBoolValue(userData['isDocumentVerify']),
//         subscriptionPlanId: userData['subscriptionPlanId'],
//         subscriptionExpiryDate:_parseTimestamp(userData['subscriptionExpiryDate'],),
//         // ADD THIS LINE ↓
//         merchantId: userData['merchantId']?.toString() ?? '',
//         // userData['subscriptionExpiryDate'] != null
//         //     ? Timestamp.fromDate(DateTime.parse(userData['subscriptionExpiryDate']))
//         //     : null,
//         // Add other fields as needed
//       );
//
//     } catch (e) {
//       print("Error converting to UserModel: $e");
//       return null;
//     }
//   }
  // void logoutFunction()async{
  //   await AudioPlayerService
  //       .playSound(false);
  //   Constant.userModel!.fcmToken = "";
  //   await FireStoreUtils.updateUser(
  //       Constant.userModel!);
  //   Constant.userModel = null;
  //   // ADD THIS
  //   if (Get.isRegistered<MerchantOutletController>()) {
  //     Get.delete<MerchantOutletController>(
  //       force: true,
  //     );
  //   }
  //
  //   if (Get.isRegistered<DashBoardController>()) {
  //     Get.delete<DashBoardController>(
  //       force: true,
  //     );
  //   }
  //
  //   Get.offAll(
  //         () => const LandingScreen(),
  //   );
  //
  //     await  clearUserData();
  //   Get.offAll(() => const LandingScreen());
  // }
  void logoutFunction() async {
    await AudioPlayerService.playSound(false);

    if (Constant.userModel != null) {
      Constant.userModel!.fcmToken = "";
      await FireStoreUtils.updateUser(Constant.userModel!);
    }

    Constant.userModel = null;

    if (Get.isRegistered<MerchantOutletController>()) {
      Get.delete<MerchantOutletController>(force: true);
    }

    if (Get.isRegistered<DashBoardController>()) {
      Get.delete<DashBoardController>(force: true);
    }

    await clearUserData();

    Get.offAll(() => const LandingScreen());
  }
// Helper method to clear user data on logout/error
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    //await prefs.remove('firebase_id');
    await prefs.remove('email');
    //await prefs.remove('fcm_token');
    await prefs.remove('first_name');
    await prefs.remove('last_name');
    await prefs.remove('phone_number');
    await prefs.remove('country_code');
    await prefs.remove('role');
    //await prefs.remove('vendorID');
    await prefs.remove('is_active');
    await prefs.remove('user_id');
    await prefs.remove('profile_picture');
   // await prefs.remove('zone_id');
    //await prefs.remove('is_document_verify');
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('merchantId');
    await prefs.remove('userId');
    await prefs.remove('outletId');
    await prefs.remove('loginType');
    await prefs.remove('authToken');
    await prefs.remove('selectedOutletId');
  }
// loginWithEmailAndPassword() async {
//   ShowToastDialog.showLoader("Please wait.".tr);
//   try {
//     final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: emailEditingController.value.text.toLowerCase().trim(),
//       password: passwordEditingController.value.text.trim(),
//     );
//     UserModel? userModel =
//         await FireStoreUtils.getUserProfile(credential.user!.uid);
//     if (userModel != null) {
//       if (userModel.role == Constant.userRoleVendor) {
//         if (userModel.active == true) {
//           userModel.fcmToken = await NotificationService.getToken();
//           await FireStoreUtils.updateUser(userModel);
//           bool isPlanExpire = false;
//           if (userModel.subscriptionPlan?.id != null) {
//             if (userModel.subscriptionExpiryDate == null) {
//               if (userModel.subscriptionPlan?.expiryDay == '-1') {
//                 isPlanExpire = false;
//               } else {
//                 isPlanExpire = true;
//               }
//             } else {
//               DateTime expiryDate =
//                   userModel.subscriptionExpiryDate!.toDate();
//               isPlanExpire = expiryDate.isBefore(DateTime.now());
//             }
//           } else {
//             isPlanExpire = true;
//           }
//           if (userModel.subscriptionPlanId == null || isPlanExpire == true) {
//             if (Constant.adminCommission?.isEnabled == false &&
//                 Constant.isSubscriptionModelApplied == false) {
//               Get.offAll(const DashBoardScreen());
//             } else {
//               Get.offAll(const SubscriptionPlanScreen());
//             }
//           } else if (userModel
//                   .subscriptionPlan?.features?.restaurantMobileApp ==
//               true) {
//             Get.offAll(const DashBoardScreen());
//           } else {
//             Get.offAll(const AppNotAccessScreen());
//           }
//         } else {
//           await FirebaseAuth.instance.signOut();
//           ShowToastDialog.showToast(
//               "This user is disable please contact to administrator".tr);
//         }
//       } else {
//         await FirebaseAuth.instance.signOut();
//         // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
//       }
//     }
//   } on FirebaseAuthException catch (e) {
//     print(e.code);
//     if (e.code == 'user-not-found') {
//       ShowToastDialog.showToast("No user found for that email.".tr);
//     } else if (e.code == 'wrong-password') {
//       ShowToastDialog.showToast("Wrong password provided for that user.".tr);
//     } else if (e.code == 'invalid-email') {
//       ShowToastDialog.showToast("Invalid Email.".tr);
//     } else {
//       ShowToastDialog.showToast("${e.message}");
//     }
//   }
//   ShowToastDialog.closeLoader();
// }

}

Future<Map<String, dynamic>> getUserData() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    //'firebase_id': prefs.getString('firebase_id') ?? '',
    'email': prefs.getString('email') ?? '',
    //'fcm_token': prefs.getString('fcm_token') ?? '',
    'first_name': prefs.getString('first_name') ?? '',
    'last_name': prefs.getString('last_name') ?? '',
    'phone_number': prefs.getString('phone_number') ?? '',
    'country_code': prefs.getString('country_code') ?? '',
    'role': prefs.getString('role') ?? '',
    'is_active': prefs.getBool('is_active') ?? false,
    'user_id': prefs.getString('user_id') ?? '',
    'profile_picture': prefs.getString('profile_picture') ?? '',
    //'zone_id': prefs.getString('zone_id') ?? '',
    //'vendorID': prefs.getString('vendorID') ?? '',
    //'is_document_verify': prefs.getBool('is_document_verify') ?? false,
    'is_logged_in': prefs.getBool('is_logged_in') ?? false,
  };
}
Future<String>? getFirebaseId() async {
  final prefs = await SharedPreferences.getInstance();
  return  prefs.getString('firebase_id')??'' ;
}

Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('is_logged_in') ?? false;
}

Future<void> clearUserData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}