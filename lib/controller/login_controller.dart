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

//
// class LoginController extends GetxController {
//
//
//   void proceedToMainApp() async {
//     try {
//       if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
//         Get.offAll(
//               () => const LandingScreen(),
//           transition: Transition.fadeIn,
//           duration: const Duration(milliseconds: 1200),
//         );
//         return;
//       }
//
//       // FireStoreUtils.getAvalibleDrivers();
//
//       bool isLogin = await FireStoreUtils.isLogin();
//       if (!isLogin) {
//         Get.offAll(() => const LandingScreen());
//         return;
//       }
//
//       final loginType = Preferences.getString('loginType');
//       final authToken = Preferences.getString('authToken');
//
//       // Restore Java merchant/outlet session saved at login.
//       if (authToken.isNotEmpty &&
//           (loginType == 'MERCHANT' || loginType == 'OUTLET')) {
//         if (loginType == 'MERCHANT') {
//           if (!Get.isRegistered<MerchantOutletController>()) {
//             Get.put(MerchantOutletController(), permanent: true);
//           }
//           await Get.find<MerchantOutletController>()
//               .initializeMerchantSession();
//         } else {
//           final merchantId = Preferences.getString('merchantId');
//           if (merchantId.isNotEmpty) {
//             try {
//               final profile =
//                   await FireStoreUtils.getMerchantProfile(merchantId);
//               if (profile != null) {
//                 Constant.userModel = profile;
//               }
//             } catch (e) {
//               print('proceedToMainApp outlet profile restore: $e');
//             }
//           }
//         }
//
//         Get.offAll(
//           () => const DashBoardScreen(),
//           transition: Transition.fadeIn,
//           duration: const Duration(milliseconds: 500),
//         );
//         return;
//       }
//
//       final userId = await FireStoreUtils.getCurrentUid();
//       if (userId.isEmpty) {
//         Get.offAll(() => const LandingScreen());
//         return;
//       }
//
//       final userModel = await FireStoreUtils.getUserProfile(userId);
//       if (userModel == null) {
//         Get.offAll(() => const LandingScreen());
//         return;
//       }
//
//       if (userModel.merchantId != null && userModel.merchantId!.isNotEmpty) {
//         Preferences.setString('merchantId', userModel.merchantId!);
//       }
//
//       if (userModel.role != Constant.userRoleMerchant || userModel.active != true) {
//         Get.offAll(() => const LandingScreen());
//         return;
//       }
//
//       Get.offAll(
//             () => const DashBoardScreen(),
//         transition: Transition.fadeIn,
//         duration: const Duration(milliseconds: 500),
//       );
//
//       final fcmToken = await NotificationService.getToken();
//       if (fcmToken != null && fcmToken.isNotEmpty) {
//         userModel.fcmToken = fcmToken;
//         await FireStoreUtils.updateUser(userModel);
//       }
//
//     } catch (e) {
//       print("proceedToMainApp error: $e");
//       Get.offAll(() => const LandingScreen());
//     }
//   }
//
//
//   Rx<TextEditingController> emailEditingController =
//       TextEditingController().obs;
//   Rx<TextEditingController> passwordEditingController =
//       TextEditingController().obs;
//
//   RxBool passwordVisible = true.obs;
//
//   @override
//   void onClose() {
//     emailEditingController.value.dispose();
//     passwordEditingController.value.dispose();
//     super.onClose();
//   }
//
//
//
//
//   // THIS IS JAVA CODE OF LOGINAPI
//   // static Future<Map<String, dynamic>> loginWithUserNameAndPasswordApi(
//   //     String username,
//   //     String password,
//   //     ) async {
//   //   final response = await http.post(
//   //     Uri.parse(
//   //       '${Constant.baseUrl}fm/auth/login',
//   //     ),
//   //     headers: await getHeaders(),
//   //     body: jsonEncode({
//   //       "username": username,
//   //       "password": password,
//   //     }),
//   //   );
//   //   print("LOGIN STATUS CODE =====> ${response.statusCode}");
//   //   print("LOGIN RESPONSE =====>");
//   //   print(response.body);
//   //
//   //   if (response.statusCode == 200) {
//   //     return jsonDecode(response.body);
//   //   }
//   //
//   //
//   //   throw Exception("Login failed");
//   // }
//   static Future<Map<String, dynamic>> loginWithUserNameAndPasswordApi(
//       String username,
//       String password,
//       ) async {
//     final response = await http.post(
//       Uri.parse(
//         '${Constant.baseUrl}fm/auth/login',
//       ),
//       headers: await getHeaders(),
//       body: jsonEncode({
//         "username": username,
//         "password": password,
//       }),
//     );
//
//     print("LOGIN STATUS CODE =====> ${response.statusCode}");
//     print("LOGIN RESPONSE =====> ${response.body}");
//
//     try {
//       final responseData = jsonDecode(response.body);
//
//       // Login success
//       if (response.statusCode == 200) {
//         return responseData;
//       }
//
//       // Login failed - return backend message
//       return {
//         "success": false,
//         "statusCode": response.statusCode,
//         "message": responseData["message"] ??
//             responseData["error"] ??
//             "Login failed",
//       };
//     } catch (e) {
//       return {
//         "success": false,
//         "statusCode": response.statusCode,
//         "message": "invalid credentials.",
//       };
//     }
//   }
//
//
// // THIS IS THE JAVA CODE OF LOGIN METHOD START
//   loginWithUserNameAndPassword() async {
//     ShowToastDialog.showLoader("Please wait.".tr);
//
//     try {
//       final response =
//       await loginWithUserNameAndPasswordApi(
//         emailEditingController.value.text.trim(),
//         passwordEditingController.value.text.trim(),
//       );
//
//       print("=== LOGIN RESPONSE ===");
//       print(response);
//       print("=== LOGIN RESPONSE ===");
//       print(response);
//
// // Check API login failure
//       if (response['success'] == false) {
//         ShowToastDialog.showToast(
//           response['message'] ?? "Login failed".tr,
//         );
//         return;
//       }
//
//       final String? token = response['jwt'];
//       final int userId = response['userId'] ?? 0;
//       print("===== LOGIN DEBUG =====");
//       print("userId = $userId");
//       print("userType = ${response['userType']}");
//       print("outletId = ${response['outletId']}");
//       print("merchantId = ${response['merchantId']}");
//       print("=======================");
//
//       final String role =
//           (response['roles'] as List).isNotEmpty
//               ? response['roles'][0]
//               : '';
//
//       Preferences.setInt('userId', userId);
//       Preferences.setString('role', role);
//
//       String loginType = '';
//       if (role == "ROLE_ADMIN" || role == "ROLE_MERCHANT") {
//         loginType = 'MERCHANT';
//       } else if (role == "ROLE_OUTLET" ||
//           response['outletId'] != null ||
//           response['userType']?.toString().toUpperCase() == 'OUTLET') {
//         loginType = 'OUTLET';
//       }
//       Preferences.setString('loginType', loginType);
//
//       int merchantId = 0;
//       int outletId = 0;
//
//       if (loginType == 'MERCHANT') {
//         merchantId = _parseLoginInt(response['merchantId']) ?? userId;
//         await Preferences.setString('merchantId', merchantId.toString());
//         await Preferences.setInt('outletId', 0);
//         await Preferences.setInt('selectedOutletId', 0);
//       } else if (loginType == 'OUTLET') {
//         outletId = _parseLoginInt(response['outletId']) ??
//             _parseLoginInt(response['id']) ??
//             _parseLoginInt(response['userId']) ??
//             0;
//
//         print("OUTLET ID CALCULATED = $outletId");
//
//         if (outletId <= 0) {
//           ShowToastDialog.closeLoader();
//           ShowToastDialog.showToast(
//             'Outlet ID missing from login. Please contact support.'.tr,
//           );
//           return;
//         }
//         await Preferences.setInt('outletId', outletId);
//         await Preferences.setInt('selectedOutletId', outletId);
//         await Preferences.clearKeyData('merchantId');
//       }
//
//       print("=== LOGIN PARSED ===");
//       print("loginType=$loginType userId=$userId merchantId=$merchantId outletId=$outletId role=$role");
//
//       if (token == null || token.isEmpty) {
//         ShowToastDialog.showToast("Login failed".tr);
//         return;
//       }
//
//       Preferences.setString('authToken', token);
//
//       print("JWT Saved Successfully");
//
//       ShowToastDialog.showToast("Login Successful".tr);
//
//       print("=== LOGIN SUCCESS ===");
//
//       if (loginType == 'MERCHANT') {
//         if (Get.isRegistered<MerchantOutletController>()) {
//           Get.delete<MerchantOutletController>(force: true);
//         }
//         final outletController =
//             Get.put(MerchantOutletController(), permanent: true);
//         await outletController.initializeMerchantSession();
//         print("=== MERCHANT SESSION COMPLETE ===");
//         print(
//           "sessionState=${outletController.sessionState.value} "
//           "outletCount=${outletController.outletList.length}",
//         );
//       } else if (loginType == 'OUTLET') {
//         if (Get.isRegistered<MerchantOutletController>()) {
//           Get.delete<MerchantOutletController>(force: true);
//         }
//         final ok = await _initializeOutletSession(outletId);
//         if (!ok) {
//           await clearUserData();
//           ShowToastDialog.showToast(
//             "Unable to load outlet. Please try again.".tr,
//           );
//           return;
//         }
//         print("=== OUTLET SESSION COMPLETE ===");
//       } else {
//         await clearUserData();
//         ShowToastDialog.showToast("Unknown user role".tr);
//         return;
//       }
//
//       await _persistLoginSession(userId: userId, token: token);
//       await _navigateToDashboardAfterLogin();
//
//     } catch (e) {
//       print("LOGIN ERROR = $e");
//       ShowToastDialog.showToast(
//         "Login Failed".tr,
//       );
//     } finally {
//       ShowToastDialog.closeLoader();
//     }
//   }
//
//
//   int? _parseLoginInt(dynamic value) {
//     if (value == null) return null;
//     if (value is int) return value;
//     return int.tryParse(value.toString());
//   }
//
//   Future<void> _persistLoginSession({
//     required int userId,
//     required String token,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('is_logged_in', true);
//     await prefs.setBool(Preferences.isFinishOnBoardingKey, true);
//     await prefs.setString('firebase_id', userId.toString());
//     await prefs.setString('user_id', userId.toString());
//     await Preferences.setString('authToken', token);
//   }
//
//   // Future<void> _markLoggedIn() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   await prefs.setBool('is_logged_in', true);
//   // }
//
//   Future<void> _navigateToDashboardAfterLogin() async {
//     if (Get.isRegistered<DashBoardController>()) {
//       Get.delete<DashBoardController>(force: true);
//     }
//     Get.offAll(
//       () => const DashBoardScreen(),
//       transition: Transition.fadeIn,
//       duration: const Duration(milliseconds: 500),
//     );
//   }
//
//   /// Outlet login: outletId → getOutletById → merchantId → profile (best-effort)
//   Future<bool> _initializeOutletSession(int outletId) async {
//     debugPrint('[OutletSession] START — loginType=OUTLET outletId=$outletId');
//
//     if (outletId <= 0) {
//       debugPrint('[OutletSession] ERROR — invalid outletId');
//       return false;
//     }
//
//     debugPrint('[OutletSession] getOutletById REQUEST — outletId=$outletId');
//     final result = await FireStoreUtils.fetchOutletById(outletId);
//     print("===== OUTLET DEBUG =====");
//     print("result.outlet = ${result.outlet}");
//     print("result.outlet?.outletName = ${result.outlet?.outletName}");
//
//     debugPrint(
//       '[OutletSession] getOutletById RESULT — '
//       'status=${result.status} merchantId=${result.merchantId} '
//       'parseWarning=${result.hadParseWarning}',
//     );
//
//     if (result.hasMerchantId) {
//       final merchantId = result.merchantId!;
//       final resolvedOutletId = result.outletId ?? outletId;
//
//       await Preferences.setInt('outletId', resolvedOutletId);
//       await Preferences.setInt('selectedOutletId', resolvedOutletId);
//       await Preferences.setString('selectedOutletName', result.outlet?.outletName ?? '',);
//       print("selectedOutletName after save = ${Preferences.getString('selectedOutletName')}");
//       await Preferences.setString('loginType', 'OUTLET');
//       await Preferences.setString('merchantId', merchantId.toString());
//
//       debugPrint(
//         '[OutletSession] Session context — '
//         'outletId=$resolvedOutletId merchantId=$merchantId (NOT mixed)',
//       );
//
//       if (result.hadParseWarning) {
//         debugPrint(
//           '[OutletSession] Parse warning ignored — session continues with merchantId',
//         );
//       }
//
//       try {
//         debugPrint(
//           '[OutletSession] getMerchantProfile REQUEST — merchantId=$merchantId',
//         );
//         final profile =
//             await FireStoreUtils.getMerchantProfile(merchantId.toString());
//         debugPrint(
//           '[OutletSession] getMerchantProfile RESPONSE — '
//           'success=${profile != null}',
//         );
//         if (profile != null) {
//           Constant.userModel = profile;
//         }
//       } catch (profileError) {
//         debugPrint(
//           '[OutletSession] Profile warning (non-fatal) — $profileError',
//         );
//       }
//
//       debugPrint('[OutletSession] SUCCESS → Outlet Dashboard (products tab)');
//       return true;
//     }
//
//     debugPrint('[OutletSession] FAILURE — ${result.message}');
//     return false;
//   }
//
// // Helper method to parse bool from various types
// //   bool _parseBoolValue(dynamic value) {
// //     if (value == null) return false;
// //     if (value is bool) return value;
// //     if (value is String) {
// //       return value.toLowerCase() == 'true' || value == '1';
// //     }
// //     if (value is int) {
// //       return value == 1;
// //     }
// //     return false;
// //   }
//
// // // Helper method to save user data to SharedPreferences
// //   Future<void> _saveUserDataToSharedPreferences(Map<String, dynamic> userData) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setString('firebase_id', userData['firebase_id'] ?? '');
// //     await prefs.setString('email', userData['email'] ?? '');
// //     await prefs.setString('fcm_token', userData['fcmToken'] ?? '');
// //     await prefs.setString('first_name', userData['firstName'] ?? '');
// //     await prefs.setString('last_name', userData['lastName'] ?? '');
// //     await prefs.setString('phone_number', userData['phoneNumber'] ?? '');
// //     await prefs.setString('country_code', userData['countryCode'] ?? '');
// //     await prefs.setString('role', userData['role'] ?? '');
// //     await prefs.setString('vendorID', userData['vendorID'] ?? '');
// //     await prefs.setBool('is_active', _parseBoolValue(userData['active'] ?? userData['active']));
// //     await prefs.setString('user_id', userData['id'].toString());
// //     await prefs.setString('profile_picture', userData['profilePictureURL'] ?? '');
// //     await prefs.setString('merchantId', userData['merchantId']?.toString() ?? '');
// //
// //     // Do NOT persist zone here – vendor data is not available yet.
// //     await prefs.setBool('is_document_verify', _parseBoolValue(userData['isDocumentVerify']));
// //     await prefs.setBool('is_logged_in', true);
// //     await prefs.setBool('is_logged_in', true);
// //     await prefs.setString('authToken',
// //         userData['token'] ??
// //             userData['accessToken'] ??
// //             userData['jwtToken'] ?? '');
// //   }
// //
// // // Helper method to convert API response to UserModel
// //   Future<UserModel?> _convertApiResponseToUserModel(Map<String, dynamic> userData) async {
// //     try {
// //       Timestamp? _parseTimestamp(dynamic value) {
// //         if (value == null) return null;
// //         if (value is Timestamp) return value;
// //         if (value is String) {// Handle the case where the string might be wrapped in extra quotes
// //           String dateString = value.replaceAll('"', '');
// //           try {
// //             DateTime dateTime = DateTime.parse(dateString);
// //             return Timestamp.fromDate(dateTime);
// //           } catch (e) {
// //             print('Error parsing date: $value - $e');
// //             return null;
// //           }
// //         }
// //         if (value is int) {
// //           return Timestamp.fromMillisecondsSinceEpoch(value);
// //         }
// //         return null;
// //       }
// //       // Convert the API response to your UserModel
// //       // You'll need to adjust this based on your actual UserModel structure
// //       return UserModel(
// //         id: userData['id']?.toString() ?? userData['firebase_id'],
// //         firebaseId: userData['firebase_id'],
// //         firstName: userData['firstName'],
// //         lastName: userData['lastName'],
// //         email: userData['email'],
// //         phoneNumber: userData['phoneNumber'],
// //         countryCode: userData['countryCode'],
// //         role: userData['role'],
// //         active: _parseBoolValue(userData['active'] ?? userData['active']),
// //         profilePictureURL: userData['profilePictureURL'],
// //         fcmToken: userData['fcmToken'],
// //         zoneId: userData['zoneId'],
// //         vendorID: userData['vendorID']?.toString() ?? userData['vendorID'],
// //         isDocumentVerify: _parseBoolValue(userData['isDocumentVerify']),
// //         subscriptionPlanId: userData['subscriptionPlanId'],
// //         subscriptionExpiryDate:_parseTimestamp(userData['subscriptionExpiryDate'],),
// //         // ADD THIS LINE ↓
// //         merchantId: userData['merchantId']?.toString() ?? '',
// //         // userData['subscriptionExpiryDate'] != null
// //         //     ? Timestamp.fromDate(DateTime.parse(userData['subscriptionExpiryDate']))
// //         //     : null,
// //         // Add other fields as needed
// //       );
// //
// //     } catch (e) {
// //       print("Error converting to UserModel: $e");
// //       return null;
// //     }
// //   }
//   // void logoutFunction()async{
//   //   await AudioPlayerService
//   //       .playSound(false);
//   //   Constant.userModel!.fcmToken = "";
//   //   await FireStoreUtils.updateUser(
//   //       Constant.userModel!);
//   //   Constant.userModel = null;
//   //   // ADD THIS
//   //   if (Get.isRegistered<MerchantOutletController>()) {
//   //     Get.delete<MerchantOutletController>(
//   //       force: true,
//   //     );
//   //   }
//   //
//   //   if (Get.isRegistered<DashBoardController>()) {
//   //     Get.delete<DashBoardController>(
//   //       force: true,
//   //     );
//   //   }
//   //
//   //   Get.offAll(
//   //         () => const LandingScreen(),
//   //   );
//   //
//   //     await  clearUserData();
//   //   Get.offAll(() => const LandingScreen());
//   // }
//   void logoutFunction() async {
//     await AudioPlayerService.playSound(false);
//
//     if (Constant.userModel != null) {
//       Constant.userModel!.fcmToken = "";
//       await FireStoreUtils.updateUser(Constant.userModel!);
//     }
//
//     Constant.userModel = null;
//
//     if (Get.isRegistered<MerchantOutletController>()) {
//       Get.delete<MerchantOutletController>(force: true);
//     }
//
//     if (Get.isRegistered<DashBoardController>()) {
//       Get.delete<DashBoardController>(force: true);
//     }
//
//     await clearUserData();
//
//     Get.offAll(() => const LandingScreen());
//   }
// // Helper method to clear user data on logout/error
//   Future<void> clearUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     //await prefs.remove('firebase_id');
//     await prefs.remove('email');
//     //await prefs.remove('fcm_token');
//     await prefs.remove('first_name');
//     await prefs.remove('last_name');
//     await prefs.remove('phone_number');
//     await prefs.remove('country_code');
//     await prefs.remove('role');
//     //await prefs.remove('vendorID');
//     await prefs.remove('is_active');
//     await prefs.remove('user_id');
//     await prefs.remove('profile_picture');
//    // await prefs.remove('zone_id');
//     //await prefs.remove('is_document_verify');
//     await prefs.setBool('is_logged_in', false);
//     await prefs.remove('merchantId');
//     await prefs.remove('userId');
//     await prefs.remove('outletId');
//     await prefs.remove('loginType');
//     await prefs.remove('authToken');
//     await prefs.remove('selectedOutletId');
//   }
// // loginWithEmailAndPassword() async {
// //   ShowToastDialog.showLoader("Please wait.".tr);
// //   try {
// //     final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
// //       email: emailEditingController.value.text.toLowerCase().trim(),
// //       password: passwordEditingController.value.text.trim(),
// //     );
// //     UserModel? userModel =
// //         await FireStoreUtils.getUserProfile(credential.user!.uid);
// //     if (userModel != null) {
// //       if (userModel.role == Constant.userRoleVendor) {
// //         if (userModel.active == true) {
// //           userModel.fcmToken = await NotificationService.getToken();
// //           await FireStoreUtils.updateUser(userModel);
// //           bool isPlanExpire = false;
// //           if (userModel.subscriptionPlan?.id != null) {
// //             if (userModel.subscriptionExpiryDate == null) {
// //               if (userModel.subscriptionPlan?.expiryDay == '-1') {
// //                 isPlanExpire = false;
// //               } else {
// //                 isPlanExpire = true;
// //               }
// //             } else {
// //               DateTime expiryDate =
// //                   userModel.subscriptionExpiryDate!.toDate();
// //               isPlanExpire = expiryDate.isBefore(DateTime.now());
// //             }
// //           } else {
// //             isPlanExpire = true;
// //           }
// //           if (userModel.subscriptionPlanId == null || isPlanExpire == true) {
// //             if (Constant.adminCommission?.isEnabled == false &&
// //                 Constant.isSubscriptionModelApplied == false) {
// //               Get.offAll(const DashBoardScreen());
// //             } else {
// //               Get.offAll(const SubscriptionPlanScreen());
// //             }
// //           } else if (userModel
// //                   .subscriptionPlan?.features?.restaurantMobileApp ==
// //               true) {
// //             Get.offAll(const DashBoardScreen());
// //           } else {
// //             Get.offAll(const AppNotAccessScreen());
// //           }
// //         } else {
// //           await FirebaseAuth.instance.signOut();
// //           ShowToastDialog.showToast(
// //               "This user is disable please contact to administrator".tr);
// //         }
// //       } else {
// //         await FirebaseAuth.instance.signOut();
// //         // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
// //       }
// //     }
// //   } on FirebaseAuthException catch (e) {
// //     print(e.code);
// //     if (e.code == 'user-not-found') {
// //       ShowToastDialog.showToast("No user found for that email.".tr);
// //     } else if (e.code == 'wrong-password') {
// //       ShowToastDialog.showToast("Wrong password provided for that user.".tr);
// //     } else if (e.code == 'invalid-email') {
// //       ShowToastDialog.showToast("Invalid Email.".tr);
// //     } else {
// //       ShowToastDialog.showToast("${e.message}");
// //     }
// //   }
// //   ShowToastDialog.closeLoader();
// // }
//
// }
//
// Future<Map<String, dynamic>> getUserData() async {
//   final prefs = await SharedPreferences.getInstance();
//   return {
//     //'firebase_id': prefs.getString('firebase_id') ?? '',
//     'email': prefs.getString('email') ?? '',
//     //'fcm_token': prefs.getString('fcm_token') ?? '',
//     'first_name': prefs.getString('first_name') ?? '',
//     'last_name': prefs.getString('last_name') ?? '',
//     'phone_number': prefs.getString('phone_number') ?? '',
//     'country_code': prefs.getString('country_code') ?? '',
//     'role': prefs.getString('role') ?? '',
//     'is_active': prefs.getBool('is_active') ?? false,
//     'user_id': prefs.getString('user_id') ?? '',
//     'profile_picture': prefs.getString('profile_picture') ?? '',
//     //'zone_id': prefs.getString('zone_id') ?? '',
//     //'vendorID': prefs.getString('vendorID') ?? '',
//     //'is_document_verify': prefs.getBool('is_document_verify') ?? false,
//     'is_logged_in': prefs.getBool('is_logged_in') ?? false,
//   };
// }
// Future<String>? getFirebaseId() async {
//   final prefs = await SharedPreferences.getInstance();
//   return  prefs.getString('firebase_id')??'' ;
// }
//
// Future<bool> isLoggedIn() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getBool('is_logged_in') ?? false;
// }
//
// Future<void> clearUserData() async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.clear();
// }

class LoginController extends GetxController {
  // ---------------------------------------------------------------------------
  // Session Keys
  // ---------------------------------------------------------------------------

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyFirebaseId = 'firebase_id';
  static const String _keyUserId = 'user_id';
  static const String _keyUserIdInt = 'userId';
  static const String _keyRole = 'role';
  static const String _keyLoginType = 'loginType';
  static const String _keyAuthToken = 'authToken';
  static const String _keyMerchantId = 'merchantId';
  static const String _keyOutletId = 'outletId';
  static const String _keySelectedOutletId = 'selectedOutletId';
  static const String _keySelectedOutletName = 'selectedOutletName';

  // ---------------------------------------------------------------------------
  // Controllers / State
  // ---------------------------------------------------------------------------

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool passwordVisible = true.obs;
  final RxBool isLoading = false.obs;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // Login API
  // ---------------------------------------------------------------------------

  static Future<Map<String, dynamic>> loginWithUserNameAndPasswordApi({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${Constant.baseUrl}fm/auth/login'),
      headers: await getHeaders(),
      body: jsonEncode({'username': username, 'password': password}),
    );

    debugPrint('[LoginApi] status=${response.statusCode}');

    Map<String, dynamic>? responseData;

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        responseData = decoded;
      }
    } catch (_) {
      // Response was not valid JSON.
    }

    // Successful login.
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        responseData != null) {
      return responseData;
    }

    // Backend returned an error.
    if (responseData != null) {
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': _getApiErrorMessage(response.statusCode, responseData),
      };
    }

    // Invalid/non-JSON server response.
    return {
      'success': false,
      'statusCode': response.statusCode,
      'message': _getStatusMessage(response.statusCode),
    };
  }

  static String _getApiErrorMessage(int statusCode,
      Map<String, dynamic> response,) {
    final backendMessage =
        response['message'] ?? response['error'] ?? response['detail'];

    if (backendMessage != null && backendMessage
        .toString()
        .trim()
        .isNotEmpty) {
      return backendMessage.toString();
    }

    return _getStatusMessage(statusCode);
  }

  static String _getStatusMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid login request.';
      case 401:
        return 'Invalid username or password.';
      case 403:
        return 'You do not have permission to access this account.';
      case 404:
        return 'Login service not found.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  Future<void> loginWithUserNameAndPassword() async {
    if (isLoading.value) {
      return;
    }

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // ------------------------------------------------------------
    // Validation
    // ------------------------------------------------------------

    if (username.isEmpty) {
      ShowToastDialog.showToast(
        'Please enter valid username'.tr,
      );
      return;
    }

    if (password.isEmpty) {
      ShowToastDialog.showToast(
        'Please enter valid password'.tr,
      );
      return;
    }

    isLoading.value = true;
    ShowToastDialog.showLoader('Please wait.'.tr);

    try {
      // ----------------------------------------------------------
      // STEP 1: Login API
      // ----------------------------------------------------------

      final response = await loginWithUserNameAndPasswordApi(
        username: username,
        password: password,
      );

      // ----------------------------------------------------------
      // STEP 2: Check login response
      // ----------------------------------------------------------

      if (response['success'] == false) {
        ShowToastDialog.showToast(
          response['message'] ?? 'Login failed'.tr,
        );
        return;
      }

      // ----------------------------------------------------------
      // STEP 3: Get JWT token
      // ----------------------------------------------------------

      final token = response['jwt']?.toString().trim();

      if (token == null || token.isEmpty) {
        ShowToastDialog.showToast(
          'Login failed. Authentication token missing.'.tr,
        );
        return;
      }

      debugPrint('[Login] JWT token received');

      // ----------------------------------------------------------
      // STEP 4: Get user information
      // ----------------------------------------------------------

      final userId = _parseInt(response['userId']) ?? 0;

      final role = _getRole(response);

      final loginType = _resolveLoginType(
        role: role,
        response: response,
      );

      debugPrint(
        '[Login] '
            'userId=$userId '
            'role=$role '
            'loginType=$loginType',
      );

      // ----------------------------------------------------------
      // STEP 5: Validate login type
      // ----------------------------------------------------------

      if (loginType.isEmpty) {
        await clearSession();

        ShowToastDialog.showToast(
          'Unknown user role'.tr,
        );
        return;
      }

      // ----------------------------------------------------------
      // STEP 6: SAVE TOKEN FIRST
      //
      // This MUST happen before getMerchantProfile()
      // ----------------------------------------------------------

      await _saveLoginSession(
        userId: userId,
        token: token,
        role: role,
        loginType: loginType,
      );

      debugPrint(
        '[Login] Session/token saved successfully',
      );

      // ----------------------------------------------------------
      // STEP 7: Now initialize Merchant / Outlet session
      //
      // getMerchantProfile() will now have access to authToken
      // ----------------------------------------------------------

      final sessionResult = await _initializeLoginSession(
        loginType: loginType,
        response: response,
        userId: userId,
        token: token,
        role: role,
      );

      // ----------------------------------------------------------
      // STEP 8: Check session initialization
      // ----------------------------------------------------------

      if (!sessionResult) {
        await clearSession();

        ShowToastDialog.showToast(
          'Unable to initialize account. Please try again.'.tr,
        );
        return;
      }

      // ----------------------------------------------------------
      // STEP 9: Login successful
      // ----------------------------------------------------------

      ShowToastDialog.showToast(
        'Login Successful'.tr,
      );

      // ----------------------------------------------------------
      // STEP 10: Navigate to dashboard
      // ----------------------------------------------------------

      await _navigateToDashboard();
    } catch (e, stackTrace) {
      debugPrint('[Login] error=$e');
      debugPrint('[Login] stackTrace=$stackTrace');

      ShowToastDialog.showToast(
        _getLoginErrorMessage(e),
      );
    } finally {
      isLoading.value = false;
      ShowToastDialog.closeLoader();
    }
  }

  // ---------------------------------------------------------------------------
  // Login Type
  // ---------------------------------------------------------------------------

  String _getRole(Map<String, dynamic> response) {
    final roles = response['roles'];

    if (roles is List && roles.isNotEmpty) {
      return roles.first.toString();
    }

    return '';
  }

  String _resolveLoginType({
    required String role,
    required Map<String, dynamic> response,
  }) {
    if (role == 'ROLE_ADMIN' || role == 'ROLE_MERCHANT') {
      return 'MERCHANT';
    }

    final outletId = response['outletId'];
    final userType = response['userType']?.toString().toUpperCase();

    if (role == 'ROLE_OUTLET' || outletId != null || userType == 'OUTLET') {
      return 'OUTLET';
    }

    return '';
  }

  // ---------------------------------------------------------------------------
  // Session Initialization
  // ---------------------------------------------------------------------------

  Future<bool> _initializeLoginSession({
    required String loginType,
    required Map<String, dynamic> response,
    required int userId,
    required String token,
    required String role,
  }) async {
    switch (loginType) {
      case 'MERCHANT':
        return _initializeMerchantSession(response: response, userId: userId);

      case 'OUTLET':
        return _initializeOutletLoginSession(response: response);

      default:
        return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Merchant Login
  // ---------------------------------------------------------------------------

  Future<bool> _initializeMerchantSession({
    required Map<String, dynamic> response,
    required int userId,
  }) async {
    final merchantId = _parseInt(response['merchantId']) ?? userId;

    if (merchantId <= 0) {
      debugPrint('[MerchantSession] Invalid merchantId=$merchantId');
      return false;
    }

    await Preferences.setString(_keyMerchantId, merchantId.toString());

    await Preferences.setInt(_keyOutletId, 0);

    await Preferences.setInt(_keySelectedOutletId, 0);

    await Preferences.setString(_keyLoginType, 'MERCHANT');

    if (Get.isRegistered<MerchantOutletController>()) {
      Get.delete<MerchantOutletController>(force: true);
    }

    final controller = Get.put(MerchantOutletController(), permanent: true);

    await controller.initializeMerchantSession();

    debugPrint(
      '[MerchantSession] initialized '
          'merchantId=$merchantId '
          'outletCount=${controller.outletList.length}',
    );

    return true;
  }

  // ---------------------------------------------------------------------------
  // Outlet Login
  // ---------------------------------------------------------------------------

  Future<bool> _initializeOutletLoginSession({
    required Map<String, dynamic> response,
  }) async {
    final outletId =
        _parseInt(response['outletId']) ??
            _parseInt(response['id']) ??
            _parseInt(response['userId']) ??
            0;

    if (outletId <= 0) {
      debugPrint('[OutletSession] Missing outletId');

      ShowToastDialog.showToast(
        'Outlet ID missing from login. Please contact support.'.tr,
      );

      return false;
    }

    return _initializeOutletSession(outletId);
  }

  Future<bool> _initializeOutletSession(int outletId) async {
    debugPrint('[OutletSession] Loading outletId=$outletId');

    final result = await FireStoreUtils.fetchOutletById(outletId);

    if (!result.hasMerchantId) {
      debugPrint('[OutletSession] Failed: ${result.message}');

      return false;
    }

    final merchantId = result.merchantId!;
    final resolvedOutletId = result.outletId ?? outletId;

    await Preferences.setInt(_keyOutletId, resolvedOutletId);

    await Preferences.setInt(_keySelectedOutletId, resolvedOutletId);

    await Preferences.setString(
      _keySelectedOutletName,
      result.outlet?.outletName ?? '',
    );

    await Preferences.setString(_keyLoginType, 'OUTLET');

    await Preferences.setString(_keyMerchantId, merchantId.toString());

    debugPrint(
      '[OutletSession] '
          'outletId=$resolvedOutletId '
          'merchantId=$merchantId',
    );

    // Merchant profile is required by the existing dashboard flow.
    try {
      final profile = await FireStoreUtils.getMerchantProfile(
        merchantId.toString(),
      );

      if (profile != null) {
        Constant.merchantModel = profile;
      } else {
        debugPrint('[OutletSession] Merchant profile not found');
      }
    } catch (e) {
      debugPrint('[OutletSession] Profile loading failed: $e');

      // Keep existing behavior: profile failure is non-fatal.
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // Persist Session
  // ---------------------------------------------------------------------------

  Future<void> _saveLoginSession({
    required int userId,
    required String token,
    required String role,
    required String loginType,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyIsLoggedIn, true);

    await prefs.setBool(Preferences.isFinishOnBoardingKey, true);

    await prefs.setString(_keyFirebaseId, userId.toString());

    await prefs.setString(_keyUserId, userId.toString());

    await prefs.setInt(_keyUserIdInt, userId);

    await prefs.setString(_keyRole, role);

    await prefs.setString(_keyLoginType, loginType);

    await prefs.setString(_keyAuthToken, token);
  }

  // ---------------------------------------------------------------------------
  // Restore Session
  // ---------------------------------------------------------------------------

  Future<void> proceedToMainApp() async {
    try {
      final onboardingFinished = Preferences.getBoolean(
        Preferences.isFinishOnBoardingKey,
      );

      if (!onboardingFinished) {
        _goToLanding();
        return;
      }

      /*
       * Keep this check because the existing application still uses
       * FireStoreUtils.isLogin() as part of its authentication state.
       */
      final firebaseLoggedIn = await FireStoreUtils.isLogin();

      if (!firebaseLoggedIn) {
        await clearSession();
        _goToLanding();
        return;
      }

      final authToken = Preferences.getString(_keyAuthToken);

      final loginType = Preferences.getString(_keyLoginType);

      if (authToken.isEmpty || loginType.isEmpty) {
        await clearSession();
        _goToLanding();
        return;
      }

      switch (loginType) {
        case 'MERCHANT':
          await _restoreMerchantSession();
          break;

        case 'OUTLET':
          await _restoreOutletSession();
          break;

        default:
          await clearSession();
          _goToLanding();
          return;
      }

      _goToDashboard();
    } catch (e, stackTrace) {
      debugPrint('[SessionRestore] error=$e');
      debugPrint('[SessionRestore] stackTrace=$stackTrace');

      await clearSession();
      _goToLanding();
    }
  }

  Future<void> _restoreMerchantSession() async {
    if (!Get.isRegistered<MerchantOutletController>()) {
      Get.put(MerchantOutletController(), permanent: true);
    }

    await Get.find<MerchantOutletController>().initializeMerchantSession();
  }

  Future<void> _restoreOutletSession() async {
    final merchantId = Preferences.getString(_keyMerchantId);

    if (merchantId.isEmpty) {
      throw Exception('Merchant ID missing for outlet session');
    }

    final profile = await FireStoreUtils.getMerchantProfile(merchantId);

    if (profile != null) {
      Constant.merchantModel = profile;
    }
  }

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------

  Future<void> _navigateToDashboard() async {
    if (Get.isRegistered<DashBoardController>()) {
      Get.delete<DashBoardController>(force: true);
    }

    _goToDashboard();
  }

  void _goToDashboard() {
    Get.offAll(
          () => const DashBoardScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _goToLanding() {
    Get.offAll(() => const LandingScreen());
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> logoutFunction() async {
    try {
      await AudioPlayerService.playSound(false);

      if (Constant.userModel != null) {
        try {
          Constant.userModel!.fcmToken = '';

          await FireStoreUtils.updateUser(Constant.userModel!);
        } catch (e) {
          debugPrint('[Logout] FCM update failed: $e');
        }
      }
    } finally {
      Constant.userModel = null;

      _disposeSessionControllers();

      await clearSession();

      _goToLanding();
    }
  }

  void _disposeSessionControllers() {
    if (Get.isRegistered<MerchantOutletController>()) {
      Get.delete<MerchantOutletController>(force: true);
    }

    if (Get.isRegistered<DashBoardController>()) {
      Get.delete<DashBoardController>(force: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Clear Session
  // ---------------------------------------------------------------------------

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyFirebaseId);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserIdInt);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyMerchantId);
    await prefs.remove(_keyOutletId);
    await prefs.remove(_keySelectedOutletId);
    await prefs.remove(_keySelectedOutletName);
    await prefs.remove(_keyLoginType);

    await prefs.setBool(_keyIsLoggedIn, false);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  String _getLoginErrorMessage(Object error) {
    if (error is http.ClientException) {
      return 'Unable to connect to server. Please check your internet connection.';
    }

    return 'Login failed. Please try again.';
  }

}
