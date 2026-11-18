// import 'dart:convert';
// import 'dart:io' show Platform;
//
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:jippymart_restaurant/utils/http_client.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:jippymart_restaurant/app/dash_board_screens/dash_board_screen.dart';
// import 'package:jippymart_restaurant/app/landing_screen.dart';
// import 'package:jippymart_restaurant/app/verification_screen/verification_screen.dart';
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
// import 'package:jippymart_restaurant/service/audio_player_service.dart';
// import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
//
// import '../../../utils/common.dart';
// import '../../../utils/preferences.dart' show Preferences;
// import '../../../utils/fcm_token_service.dart';
// import '../../../utils/notification/notification_service.dart';
// import '../../../controller/dash_board_controller.dart';
// import '../../../controller/merchant_outlet_controller.dart';
//
// class LoginController extends GetxController {
//   // ---------------------------------------------------------------------------
//   // Session Keys
//   // ---------------------------------------------------------------------------
//
//   static const String _keyIsLoggedIn = 'is_logged_in';
//   static const String _keyFirebaseId = 'firebase_id';
//   static const String _keyUserId = 'user_id';
//   static const String _keyUserIdInt = 'userId';
//   static const String _keyRole = 'role';
//   static const String _keyLoginType = 'loginType';
//   static const String _keyAuthToken = 'authToken';
//   static const String _keyMerchantId = 'merchantId';
//   static const String _keyOutletId = 'outletId';
//   static const String _keySelectedOutletId = 'selectedOutletId';
//   static const String _keySelectedOutletName = 'selectedOutletName';
//
//   // ---------------------------------------------------------------------------
//   // Controllers / State
//   // ---------------------------------------------------------------------------
//
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   final RxBool passwordVisible = true.obs;
//   final RxBool isLoading = false.obs;
//
//   final NotificationService notificationService = NotificationService();
//
//   // ---------------------------------------------------------------------------
//   // Lifecycle
//   // ---------------------------------------------------------------------------
//
//   @override
//   void onClose() {
//     usernameController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
//
//   // ---------------------------------------------------------------------------
//   // Login API
//   // ---------------------------------------------------------------------------
//
//   static Future<Map<String, dynamic>> loginWithUserNameAndPasswordApi({
//     required String username,
//     required String password,
//   }) async {
//     final response = await http.post(
//       Uri.parse('${Constant.baseUrl}fm/auth/login'),
//       headers: await getHeaders(),
//       body: jsonEncode({
//         'username': username,
//         'password': password,
//       }),
//     );
//
//     debugPrint('[LoginApi] status=${response.statusCode}');
//
//     Map<String, dynamic>? responseData;
//
//     try {
//       final decoded = jsonDecode(response.body);
//
//       if (decoded is Map<String, dynamic>) {
//         responseData = decoded;
//       }
//     } catch (_) {
//       // Response was not valid JSON.
//     }
//
//     // Successful login.
//     if (response.statusCode >= 200 &&
//         response.statusCode < 300 &&
//         responseData != null) {
//       return responseData;
//     }
//
//     // Backend returned an error.
//     if (responseData != null) {
//       return {
//         'success': false,
//         'statusCode': response.statusCode,
//         'message': _getApiErrorMessage(
//           response.statusCode,
//           responseData,
//         ),
//       };
//     }
//
//     // Invalid/non-JSON server response.
//     return {
//       'success': false,
//       'statusCode': response.statusCode,
//       'message': _getStatusMessage(response.statusCode),
//     };
//   }
//
//   static String _getApiErrorMessage(int statusCode, Map<String, dynamic> data) {
//     // Try common keys the backend might use
//     final backendMessage = data['message'] ??
//         data['error'] ??
//         data['detail'] ??
//         data['msg'];
//
//     if (backendMessage is String && backendMessage.trim().isNotEmpty) {
//       return backendMessage;
//     }
//
//     // Fallback based on status code
//     return _getStatusMessage(statusCode);
//   }
//
//   static String _getStatusMessage(int statusCode) {
//     switch (statusCode) {
//       case 400:
//         return 'Enter Valid Credentials';
//       case 401:
//         return 'Enter Valid Credentials';
//       case 403:
//         return 'You Are Not Approved. Check your Approval Status';
//       case 404:
//         return 'Account not found';
//       case 500:
//         return 'Server error. Please try again later.';
//       default:
//         return 'Something went wrong. Please try again.';
//     }
//   }
//   // ---------------------------------------------------------------------------
//   // Username + Password Login
//   // ---------------------------------------------------------------------------
//
//   Future<void> loginWithUserNameAndPassword() async {
//     if (isLoading.value) {
//       return;
//     }
//
//     final username = usernameController.text.trim();
//     final password = passwordController.text.trim();
//
//     // ------------------------------------------------------------
//     // Validation
//     // ------------------------------------------------------------
//
//     if (username.isEmpty) {
//       ShowToastDialog.showToast(
//         'Please enter valid username'.tr,
//       );
//       return;
//     }
//
//     if (password.isEmpty) {
//       ShowToastDialog.showToast(
//         'Please enter valid password'.tr,
//       );
//       return;
//     }
//
//     isLoading.value = true;
//
//     ShowToastDialog.showLoader(
//       'Please wait.'.tr,
//     );
//
//     try {
//       // ----------------------------------------------------------
//       // STEP 1: Login API
//       // ----------------------------------------------------------
//
//       final response =
//       await loginWithUserNameAndPasswordApi(
//         username: username,
//         password: password,
//       );
//
//       // ----------------------------------------------------------
//       // STEP 2: Reusable Login Success Flow
//       //
//       // This same method is also used by Mobile OTP Login
//       // ----------------------------------------------------------
//
//       await handleLoginSuccess(response);
//     } catch (e, stackTrace) {
//       debugPrint('[Login] error=$e');
//       debugPrint('[Login] stackTrace=$stackTrace');
//
//       ShowToastDialog.showToast(
//         _getLoginErrorMessage(e),
//       );
//     } finally {
//       isLoading.value = false;
//
//       ShowToastDialog.closeLoader();
//     }
//   }
//
//
//   Future<bool> handleLoginSuccess(
//       Map<String, dynamic> response,
//       ) async {
//     try {
//       debugPrint('========================================');
//       debugPrint('[LoginSuccess] Processing login response');
//       debugPrint('[LoginSuccess] Response: $response');
//       debugPrint('========================================');
//
//       // ----------------------------------------------------------
//       // STEP 1: Check Login Response
//       // ----------------------------------------------------------
//
//       if (response['success'] == false) {
//         ShowToastDialog.showToast(
//           response['message'] ?? 'Login failed'.tr,
//         );
//
//         return false;
//       }
//
//       // ----------------------------------------------------------
//       // STEP 2: Get JWT Token
//       // ----------------------------------------------------------
//
//       final token = response['jwt']?.toString().trim();
//       final refreshToken = response['refreshToken']?.toString().trim();
//
//       if (token == null || token.isEmpty) {
//         ShowToastDialog.showToast(
//           'Login failed. Authentication token missing.'.tr,
//         );
//
//         return false;
//       }
//
//       debugPrint('[LoginSuccess] JWT token received');
//
//       // ----------------------------------------------------------
//       // STEP 3: Get User ID
//       // ----------------------------------------------------------
//
//       final userId =
//           _parseInt(response['userId']) ?? 0;
//
//       if (userId <= 0) {
//         ShowToastDialog.showToast(
//           'Login failed. User ID missing.'.tr,
//         );
//
//         return false;
//       }
//
//       // ----------------------------------------------------------
//       // STEP 4: Get Role
//       // ----------------------------------------------------------
//
//       final role = _getRole(response);
//
//       // ----------------------------------------------------------
//       // STEP 5: Resolve Login Type
//       //
//       // MERCHANT
//       // OUTLET
//       // ----------------------------------------------------------
//
//       final loginType = _resolveLoginType(
//         role: role,
//         response: response,
//       );
//
//       debugPrint(
//         '[LoginSuccess] '
//             'userId=$userId '
//             'role=$role '
//             'loginType=$loginType',
//       );
//
//       // ----------------------------------------------------------
//       // STEP 6: Validate Login Type
//       // ----------------------------------------------------------
//
//       if (loginType.isEmpty) {
//         await clearSession();
//
//         ShowToastDialog.showToast(
//           'Unknown user role'.tr,
//         );
//
//         return false;
//       }
//
//       // ----------------------------------------------------------
//       // STEP 7: Save Login Session
//       //
//       // IMPORTANT:
//       // JWT is saved BEFORE Merchant Profile API
//       // ----------------------------------------------------------
//
//       await _saveLoginSession(
//         userId: userId,
//         token: token,
//         role: role,
//         loginType: loginType,
//       );
//
//       if (refreshToken != null && refreshToken.isNotEmpty) {
//         await saveRefreshToken(refreshToken);
//       }
//
//       debugPrint(
//         '[LoginSuccess] Session/token saved successfully',
//       );
//
//       // ----------------------------------------------------------
//       // STEP 8: Save FCM Token
//       // ----------------------------------------------------------
//       // Retrieve the FCM token from Firebase Messaging
//       String? fcmToken = await _getFCMToken();
//       if (fcmToken != null && fcmToken.isNotEmpty) {
//         final loginType = Preferences.getString(_keyLoginType);
//         await FCMTokenService.saveToken(
//           userId: userId,
//           userType: loginType ?? 'MERCHANT',
//           fcmToken: fcmToken,
//           deviceType: Platform.isIOS ? 'IOS' : 'ANDROID',
//         );
//       }
//
//       // ----------------------------------------------------------
//       // STEP 8: Initialize Merchant / Outlet
//       // ----------------------------------------------------------
//
//       final sessionResult =
//       await _initializeLoginSession(
//         loginType: loginType,
//         response: response,
//         userId: userId,
//         token: token,
//         role: role,
//       );
//
//       // ----------------------------------------------------------
//       // STEP 9: Check Session Initialization
//       // ----------------------------------------------------------
//
//       if (!sessionResult) {
//         await clearSession();
//
//         ShowToastDialog.showToast(
//           'Unable to initialize account. Please try again.'.tr,
//         );
//
//         return false;
//       }
//
//       debugPrint(
//         '[LoginSuccess] Session initialized successfully',
//       );
//
//       // ----------------------------------------------------------
//       // STEP 10: Navigate
//       //
//       // PENDING / NOT APPROVED
//       //        ↓
//       // Verification Screen
//       //
//       // APPROVED
//       //        ↓
//       // Dashboard
//       // ----------------------------------------------------------
//
//       await _navigateToDashboard();
//
//       return true;
//     } catch (e, stackTrace) {
//       debugPrint(
//         '[LoginSuccess] error=$e',
//       );
//
//       debugPrint(
//         '[LoginSuccess] stackTrace=$stackTrace',
//       );
//
//       await clearSession();
//
//       ShowToastDialog.showToast(
//         _getLoginErrorMessage(e),
//       );
//
//       return false;
//     }
//   }
//
//   // ---------------------------------------------------------------------------
//   // Login Type
//   // ---------------------------------------------------------------------------
//
//   String _getRole(
//       Map<String, dynamic> response,
//       ) {
//     final roles = response['roles'];
//
//     if (roles is List && roles.isNotEmpty) {
//       return roles.first.toString();
//     }
//
//     return '';
//   }
//
//   String _resolveLoginType({
//     required String role,
//     required Map<String, dynamic> response,
//   }) {
//     if (role == 'ROLE_ADMIN' ||
//         role == 'ROLE_MERCHANT') {
//       return 'MERCHANT';
//     }
//
//     final outletId = response['outletId'];
//
//     final userType =
//     response['userType']
//         ?.toString()
//         .toUpperCase();
//
//     if (role == 'ROLE_OUTLET' ||
//         outletId != null ||
//         userType == 'OUTLET') {
//       return 'OUTLET';
//     }
//
//     return '';
//   }
//
//   // ---------------------------------------------------------------------------
//   // Session Initialization
//   // ---------------------------------------------------------------------------
//
//   Future<bool> _initializeLoginSession({
//     required String loginType,
//     required Map<String, dynamic> response,
//     required int userId,
//     required String token,
//     required String role,
//   }) async {
//     switch (loginType) {
//       case 'MERCHANT':
//         return _initializeMerchantSession(
//           response: response,
//           userId: userId,
//         );
//
//       case 'OUTLET':
//         return _initializeOutletLoginSession(
//           response: response,
//         );
//
//       default:
//         return false;
//     }
//   }
//
//   // ---------------------------------------------------------------------------
//   // Merchant Login
//   // ---------------------------------------------------------------------------
//
//   Future<bool> _initializeMerchantSession({
//     required Map<String, dynamic> response,
//     required int userId,
//   }) async {
//     final merchantId =
//         _parseInt(response['merchantId']) ??
//             userId;
//
//     if (merchantId <= 0) {
//       debugPrint(
//         '[MerchantSession] Invalid merchantId=$merchantId',
//       );
//
//       return false;
//     }
//
//     await Preferences.setString(
//       _keyMerchantId,
//       merchantId.toString(),
//     );
//
//     await Preferences.setInt(
//       _keyOutletId,
//       0,
//     );
//
//     await Preferences.setInt(
//       _keySelectedOutletId,
//       0,
//     );
//
//     await Preferences.setString(
//       _keyLoginType,
//       'MERCHANT',
//     );
//
//     if (Get.isRegistered<MerchantOutletController>()) {
//       Get.delete<MerchantOutletController>(
//         force: true,
//       );
//     }
//
//     final controller = Get.put(
//       MerchantOutletController(),
//       permanent: true,
//     );
//
//     await controller.initializeMerchantSession();
//
//     debugPrint(
//       '[MerchantSession] initialized '
//           'merchantId=$merchantId '
//           'outletCount=${controller.outletList.length}',
//     );
//
//     return true;
//   }
//
//   // ---------------------------------------------------------------------------
//   // Outlet Login
//   // ---------------------------------------------------------------------------
//
//   Future<bool> _initializeOutletLoginSession({
//     required Map<String, dynamic> response,
//   }) async {
//     final outletId =
//         _parseInt(response['outletId']) ??
//             _parseInt(response['id']) ??
//             _parseInt(response['userId']) ??
//             0;
//
//     if (outletId <= 0) {
//       debugPrint(
//         '[OutletSession] Missing outletId',
//       );
//
//       ShowToastDialog.showToast(
//         'Outlet ID missing from login. Please contact support.'.tr,
//       );
//
//       return false;
//     }
//
//     return _initializeOutletSession(outletId);
//   }
//
//   Future<bool> _initializeOutletSession(
//       int outletId,
//       ) async {
//     debugPrint(
//       '[OutletSession] Loading outletId=$outletId',
//     );
//
//     final result =
//     await FireStoreUtils.fetchOutletById(
//       outletId,
//     );
//
//     if (!result.hasMerchantId) {
//       debugPrint(
//         '[OutletSession] Failed: ${result.message}',
//       );
//
//       return false;
//     }
//
//     final merchantId = result.merchantId!;
//
//     final resolvedOutletId =
//         result.outletId ?? outletId;
//
//     await Preferences.setInt(
//       _keyOutletId,
//       resolvedOutletId,
//     );
//
//     await Preferences.setInt(
//       _keySelectedOutletId,
//       resolvedOutletId,
//     );
//
//     await Preferences.setString(
//       _keySelectedOutletName,
//       result.outlet?.outletName ?? '',
//     );
//
//     await Preferences.setString(
//       _keyLoginType,
//       'OUTLET',
//     );
//
//     await Preferences.setString(
//       _keyMerchantId,
//       merchantId.toString(),
//     );
//
//     await MerchantOutletController.persistApprovalState(
//       result.outlet?.isApproved,
//     );
//
//     debugPrint(
//       '[OutletSession] '
//           'outletId=$resolvedOutletId '
//           'merchantId=$merchantId',
//     );
//
//     // Merchant profile is required by existing dashboard flow.
//
//     try {
//       final profile =
//       await FireStoreUtils.getMerchantProfile(
//         merchantId.toString(),
//       );
//
//       if (profile != null) {
//         Constant.merchantModel = profile;
//       } else {
//         debugPrint(
//           '[OutletSession] Merchant profile not found',
//         );
//       }
//     } catch (e) {
//       debugPrint(
//         '[OutletSession] Profile loading failed: $e',
//       );
//
//       // Existing behavior:
//       // Profile failure is non-fatal.
//     }
//
//     return true;
//   }
//
//   // ---------------------------------------------------------------------------
//   // Persist Session
//   // ---------------------------------------------------------------------------
//
//   Future<void> _saveLoginSession({
//     required int userId,
//     required String token,
//     required String role,
//     required String loginType,
//   }) async {
//     final prefs =
//     await SharedPreferences.getInstance();
//
//     await prefs.setBool(
//       _keyIsLoggedIn,
//       true,
//     );
//
//     await prefs.setBool(
//       Preferences.isFinishOnBoardingKey,
//       true,
//     );
//
//     await prefs.setString(
//       _keyFirebaseId,
//       userId.toString(),
//     );
//
//     await prefs.setString(
//       _keyUserId,
//       userId.toString(),
//     );
//
//     await prefs.setInt(
//       _keyUserIdInt,
//       userId,
//     );
//
//     await prefs.setString(
//       _keyRole,
//       role,
//     );
//
//     await prefs.setString(
//       _keyLoginType,
//       loginType,
//     );
//
//     await prefs.setString(
//       _keyAuthToken,
//       token,
//     );
//   }
//
//   // ---------------------------------------------------------------------------
//   // Restore Session
//   // ---------------------------------------------------------------------------
//
//   Future<void> proceedToMainApp() async {
//     try {
//       final onboardingFinished =
//       Preferences.getBoolean(
//         Preferences.isFinishOnBoardingKey,
//       );
//
//       if (!onboardingFinished) {
//         _goToLanding();
//         return;
//       }
//
//       final firebaseLoggedIn =
//       await FireStoreUtils.isLogin();
//
//       if (!firebaseLoggedIn) {
//         await clearSession();
//         _goToLanding();
//         return;
//       }
//
//       final authToken =
//       Preferences.getString(
//         _keyAuthToken,
//       );
//
//       final loginType =
//       Preferences.getString(
//         _keyLoginType,
//       );
//
//       if (authToken.isEmpty ||
//           loginType.isEmpty) {
//         await clearSession();
//         _goToLanding();
//         return;
//       }
//
//       switch (loginType) {
//         case 'MERCHANT':
//           await _restoreMerchantSession();
//           break;
//
//         case 'OUTLET':
//           await _restoreOutletSession();
//           break;
//
//         default:
//           await clearSession();
//           _goToLanding();
//           return;
//       }
//
//       await _goToDashboardOrVerification();
//     } catch (e, stackTrace) {
//       debugPrint(
//         '[SessionRestore] error=$e',
//       );
//
//       debugPrint(
//         '[SessionRestore] stackTrace=$stackTrace',
//       );
//
//       await clearSession();
//
//       _goToLanding();
//     }
//   }
//
//   Future<void> _restoreMerchantSession() async {
//     if (!Get.isRegistered<MerchantOutletController>()) {
//       Get.put(
//         MerchantOutletController(),
//         permanent: true,
//       );
//     }
//
//     await Get.find<MerchantOutletController>()
//         .initializeMerchantSession();
//   }
//
//   Future<void> _restoreOutletSession() async {
//     final merchantId =
//     Preferences.getString(
//       _keyMerchantId,
//     );
//
//     if (merchantId.isEmpty) {
//       throw Exception(
//         'Merchant ID missing for outlet session',
//       );
//     }
//
//     final profile =
//     await FireStoreUtils.getMerchantProfile(
//       merchantId,
//     );
//
//     if (profile != null) {
//       Constant.merchantModel = profile;
//     }
//   }
//
//   // ---------------------------------------------------------------------------
//   // Dashboard
//   // ---------------------------------------------------------------------------
//
//   Future<void> _navigateToDashboard() async {
//     await _goToDashboardOrVerification();
//   }
//
//   /// True when the current merchant/outlet
//   /// is approved by the backend.
//   ///
//   /// Fails open so a fetch error never
//   /// locks a user out.
//   Future<bool> _isSessionApproved() async {
//     final loginType =
//     Preferences.getString(
//       _keyLoginType,
//     );
//
//     try {
//       // --------------------------------------------------------
//       // OUTLET
//       // --------------------------------------------------------
//
//       if (loginType == 'OUTLET') {
//         final outletId =
//         Preferences.getInt(_keyOutletId) > 0
//             ? Preferences.getInt(_keyOutletId)
//             : Preferences.getInt(
//           _keySelectedOutletId,
//         );
//
//         if (outletId <= 0) {
//           return true;
//         }
//
//         final result =
//         await FireStoreUtils.fetchOutletById(
//           outletId,
//         );
//
//         return result.outlet?.isApproved ?? true;
//       }
//
//       // --------------------------------------------------------
//       // MERCHANT
//       // --------------------------------------------------------
//
//       if (Get.isRegistered<MerchantOutletController>()) {
//         final profile =
//             Get.find<MerchantOutletController>()
//                 .merchantProfile
//                 .value;
//
//         if (profile != null) {
//           return profile.isApproved ?? true;
//         }
//       }
//
//       return true;
//     } catch (e, stackTrace) {
//       debugPrint(
//         '[Session] approval check failed: $e',
//       );
//
//       debugPrint(
//         '$stackTrace',
//       );
//
//       return true;
//     }
//   }
//
//   // ---------------------------------------------------------------------------
//   // Dashboard OR Verification
//   // ---------------------------------------------------------------------------
//
//   Future<void> _goToDashboardOrVerification() async {
//     final approved =
//     await _isSessionApproved();
//
//     await MerchantOutletController.persistApprovalState(
//       approved,
//     );
//
//     // ----------------------------------------------------------
//     // NOT APPROVED
//     // ----------------------------------------------------------
//
//     if (!approved) {
//       debugPrint(
//         '[Session] Not approved — showing verification screen',
//       );
//
//       Get.offAll(
//             () => const VerificationScreen(),
//         transition: Transition.fadeIn,
//         duration: const Duration(
//           milliseconds: 400,
//         ),
//       );
//
//       return;
//     }
//
//     // ----------------------------------------------------------
//     // APPROVED
//     // ----------------------------------------------------------
//
//     if (Get.isRegistered<DashBoardController>()) {
//       Get.delete<DashBoardController>(
//         force: true,
//       );
//     }
//
//     _goToDashboard();
//   }
//
//   void _goToDashboard() {
//     Get.offAll(
//           () => const DashBoardScreen(),
//       transition: Transition.fadeIn,
//       duration: const Duration(
//         milliseconds: 500,
//       ),
//     );
//   }
//
//   void _goToLanding() {
//     Get.offAll(
//           () => const LandingScreen(),
//     );
//   }
//
//   // ---------------------------------------------------------------------------
//   // Logout
//   // ---------------------------------------------------------------------------
//
//   Future<void> logoutFunction() async {
//     try {
//       await AudioPlayerService.playSound(false);
//
//       // Remove FCM token from backend
//       final loginType = Preferences.getString(_keyLoginType);
//       final userId = Preferences.getInt(_keyUserIdInt) ?? 0;
//       if (loginType != null && loginType.isNotEmpty) {
//         await FCMTokenService.removeToken(
//           userId: userId,
//           userType: loginType,
//         );
//       }
//
//       if (Constant.userModel != null) {
//         try {
//           Constant.userModel!.fcmToken = '';
//
//           await FireStoreUtils.updateUser(
//             Constant.userModel!,
//           );
//         } catch (e) {
//           debugPrint(
//             '[Logout] FCM update failed: $e',
//           );
//         }
//       }
//     } finally {
//       Constant.userModel = null;
//
//       _disposeSessionControllers();
//
//       await clearSession();
//
//       _goToLanding();
//     }
//   }
//
//   void _disposeSessionControllers() {
//     if (Get.isRegistered<MerchantOutletController>()) {
//       Get.delete<MerchantOutletController>(
//         force: true,
//       );
//     }
//
//     if (Get.isRegistered<DashBoardController>()) {
//       Get.delete<DashBoardController>(
//         force: true,
//       );
//     }
//   }
//
//   // ---------------------------------------------------------------------------
//   // Clear Session
//   // ---------------------------------------------------------------------------
//
//   Future<void> clearSession() async {
//     final prefs =
//     await SharedPreferences.getInstance();
//
//     await prefs.remove(_keyFirebaseId);
//
//     await prefs.remove(_keyUserId);
//
//     await prefs.remove(_keyUserIdInt);
//
//     await prefs.remove(_keyRole);
//
//     await prefs.remove(_keyAuthToken);
//
//     await prefs.remove(_keyMerchantId);
//
//     await prefs.remove(_keyOutletId);
//
//     await prefs.remove(_keySelectedOutletId);
//
//     await prefs.remove(_keySelectedOutletName);
//
//     await prefs.remove(_keyLoginType);
//
//     await prefs.setBool(
//       _keyIsLoggedIn,
//       false,
//     );
//   }
//
//   /// Get FCM token from Firebase Messaging
//   Future<String?> _getFCMToken() async {
//     try {
//       return await NotificationService.getToken();
//     } catch (e) {
//       debugPrint('[Login] Error getting FCM token: $e');
//       return null;
//     }
//   }
//
//   // ---------------------------------------------------------------------------
//   // Helpers
//   // ---------------------------------------------------------------------------
//
//   int? _parseInt(dynamic value) {
//     if (value == null) {
//       return null;
//     }
//
//     if (value is int) {
//       return value;
//     }
//
//     return int.tryParse(
//       value.toString(),
//     );
//   }
//
//   String _getLoginErrorMessage(
//       Object error,
//       ) {
//     if (error is http.ClientException) {
//       return 'Unable to connect to server. Please check your internet connection.';
//     }
//
//     return 'Login failed. Please try again.';
//   }
// }


import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/utils/http_client.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jippymart_restaurant/app/dash_board_screens/dash_board_screen.dart';
import 'package:jippymart_restaurant/app/landing_screen.dart';
import 'package:jippymart_restaurant/app/verification_screen/verification_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/service/audio_player_service.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

import '../../../utils/common.dart';
import '../../../utils/preferences.dart' show Preferences;
import '../../../utils/fcm_token_service.dart';
import '../../../utils/notification/notification_service.dart';
import '../../../controller/dash_board_controller.dart';
import '../../../controller/merchant_outlet_controller.dart';

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

  final NotificationService notificationService = NotificationService();

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

  /// Always returns a map with:
  ///   - success:    bool
  ///   - statusCode: int
  ///   - message:    String (only on failure)
  ///   - plus the raw backend fields on success.
  static Future<Map<String, dynamic>> loginWithUserNameAndPasswordApi({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${Constant.baseUrl}fm/auth/login'),
      headers: await getHeaders(),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    // ✅ FIX 5: also log the body so you can inspect the real backend error shape.
    debugPrint('[LoginApi] status=${response.statusCode}');
    debugPrint('[LoginApi] body=${response.body}');

    Map<String, dynamic>? responseData;

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        responseData = decoded;
      }
    } catch (_) {
      // Response was not valid JSON.
    }

    // Successful login (2xx with a JSON body).
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        responseData != null) {
      // ✅ FIX 2 + FIX 3: always include a 'success' key.
      // If the backend sends an errorCode inside a 200 response,
      // treat it as a failure so the UI can surface the message.
      final rawCode = responseData['errorCode'] ??
          responseData['code'] ??
          responseData['error_code'];
      final hasErrorCode =
          rawCode != null && rawCode.toString().trim().isNotEmpty;
      final explicitSuccess = responseData['success'];

      final isSuccess = !hasErrorCode &&
          (explicitSuccess == null || explicitSuccess == true);

      if (isSuccess) {
        return {
          ...responseData,
          'success': true,
          'statusCode': response.statusCode,
        };
      }

      return {
        ...responseData,
        'success': false,
        'statusCode': response.statusCode,
        'message': _getApiErrorMessage(response.statusCode, responseData),
      };
    }

    // Backend returned an error (valid JSON).
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

  // ✅ FIX: must be static — it is called from a static method.
  static String _getApiErrorMessage(
      int statusCode,
      Map<String, dynamic> data,
      ) {
    // 1) Explicit error codes.
    final rawCode = (data['errorCode'] ??
        data['code'] ??
        data['error_code'] ??
        '')
        .toString()
        .toUpperCase();

    if (rawCode.isNotEmpty) {
      switch (rawCode) {
        case 'INVALID_CREDENTIALS':
        case 'INVALID_PASSWORD':
        case 'INVALID_USERNAME':
        case 'USER_NOT_FOUND':
        case 'BAD_CREDENTIALS':
        case 'UNAUTHORIZED':
          return 'Enter Valid Credentials';

        case 'NOT_APPROVED':
        case 'PENDING_APPROVAL':
        case 'ACCOUNT_PENDING':
        case 'APPROVAL_PENDING':
        case 'USER_NOT_APPROVED':
        case 'ACCOUNT_NOT_APPROVED':
          return 'You Are Not Approved. Check your Approval Status';
      }
    }

    // 2) Human-readable message from backend.
    final backendMessage = data['message'] ??
        data['error'] ??
        data['detail'] ??
        data['msg'];

    if (backendMessage is String && backendMessage.trim().isNotEmpty) {
      return _mapBackendMessage(backendMessage, statusCode);
    }

    // 3) Status-code fallback.
    return _getStatusMessage(statusCode);
  }

  static String _mapBackendMessage(String message, int statusCode) {
    final lower = message.toLowerCase();

    if (lower.contains('not approved') ||
        lower.contains('pending') ||
        lower.contains('approval')) {
      return 'You Are Not Approved. Check your Approval Status';
    }

    if (lower.contains('invalid credentials') ||
        lower.contains('invalid password') ||
        lower.contains('invalid username') ||
        lower.contains('bad credentials') ||
        lower.contains('user not found') ||
        lower.contains('unauthorized')) {
      return 'Enter Valid Credentials';
    }

    if (message.trim().isNotEmpty) {
      return message;
    }

    return _getStatusMessage(statusCode);
  }

  // ✅ FIX: must be static too.
  static String _getStatusMessage(int statusCode) {
    switch (statusCode) {
      case 400:
      case 401:
        return 'Enter Valid Credentials';
      case 403:
        return 'You Are Not Approved. Check your Approval Status';
      case 404:
        return 'Account not found';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // ---------------------------------------------------------------------------
  // Username + Password Login
  // ---------------------------------------------------------------------------

  Future<void> loginWithUserNameAndPassword() async {
    if (isLoading.value) return;

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) {
      ShowToastDialog.showToast('Please enter valid username'.tr);
      return;
    }

    if (password.isEmpty) {
      ShowToastDialog.showToast('Please enter valid password'.tr);
      return;
    }

    isLoading.value = true;
    ShowToastDialog.showLoader('Please wait.'.tr);

    Map<String, dynamic>? response;
    Object? caughtError;
    StackTrace? caughtStack;

    try {
      response = await loginWithUserNameAndPasswordApi(
        username: username,
        password: password,
      );
    } catch (e, st) {
      caughtError = e;
      caughtStack = st;
    }

    // ✅ FIX 1: close the loader BEFORE showing any toast / dialog,
    // otherwise the loader overlay dismisses the toast.
    ShowToastDialog.closeLoader();
    isLoading.value = false;

    if (caughtError != null) {
      debugPrint('[Login] error=$caughtError');
      debugPrint('[Login] stackTrace=$caughtStack');
      ShowToastDialog.showToast(_getLoginErrorMessage(caughtError));
      return;
    }

    await handleLoginSuccess(response!);
  }

  Future<bool> handleLoginSuccess(
      Map<String, dynamic> response,
      ) async {
    try {
      debugPrint('========================================');
      debugPrint('[LoginSuccess] Processing login response');
      debugPrint('[LoginSuccess] Response: $response');
      debugPrint('========================================');

      // ----------------------------------------------------------
      // STEP 1: Check Login Response FIRST (before token check)
      // ✅ FIX 4: use success flag / errorCode, not just success==false.
      // ----------------------------------------------------------

      final isFailure = response['success'] == false;

      if (isFailure) {
        final message =
        (response['message'] ?? 'Login failed').toString();
        _showLoginError(message);
        return false;
      }

      // ----------------------------------------------------------
      // STEP 2: Get JWT Token
      // ----------------------------------------------------------

      final token = response['jwt']?.toString().trim() ??
          response['token']?.toString().trim();
      final refreshToken = response['refreshToken']?.toString().trim();

      if (token == null || token.isEmpty) {
        _showLoginError('Login failed. Authentication token missing.');
        return false;
      }

      debugPrint('[LoginSuccess] JWT token received');

      // ----------------------------------------------------------
      // STEP 3: Get User ID
      // ----------------------------------------------------------

      final userId = _parseInt(response['userId']) ?? 0;

      if (userId <= 0) {
        _showLoginError('Login failed. User ID missing.');
        return false;
      }

      // ----------------------------------------------------------
      // STEP 4: Get Role
      // ----------------------------------------------------------

      final role = _getRole(response);

      // ----------------------------------------------------------
      // STEP 5: Resolve Login Type
      // ----------------------------------------------------------

      final loginType = _resolveLoginType(
        role: role,
        response: response,
      );

      debugPrint(
        '[LoginSuccess] '
            'userId=$userId '
            'role=$role '
            'loginType=$loginType',
      );

      // ----------------------------------------------------------
      // STEP 6: Validate Login Type
      // ----------------------------------------------------------

      if (loginType.isEmpty) {
        await clearSession();
        _showLoginError('Unknown user role');
        return false;
      }

      // ----------------------------------------------------------
      // STEP 7: Save Login Session
      // ----------------------------------------------------------

      await _saveLoginSession(
        userId: userId,
        token: token,
        role: role,
        loginType: loginType,
      );

      if (refreshToken != null && refreshToken.isNotEmpty) {
        await saveRefreshToken(refreshToken);
      }

      debugPrint('[LoginSuccess] Session/token saved successfully');

      // ----------------------------------------------------------
      // STEP 8: Save FCM Token
      // ----------------------------------------------------------

      String? fcmToken = await _getFCMToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        final savedLoginType = Preferences.getString(_keyLoginType);
        await FCMTokenService.saveToken(
          userId: userId,
          userType: savedLoginType ?? 'MERCHANT',
          fcmToken: fcmToken,
          deviceType: Platform.isIOS ? 'IOS' : 'ANDROID',
        );
      }

      // ----------------------------------------------------------
      // STEP 9: Initialize Merchant / Outlet
      // ----------------------------------------------------------

      final sessionResult = await _initializeLoginSession(
        loginType: loginType,
        response: response,
        userId: userId,
        token: token,
        role: role,
      );

      if (!sessionResult) {
        await clearSession();
        _showLoginError('Unable to initialize account. Please try again.');
        return false;
      }

      debugPrint('[LoginSuccess] Session initialized successfully');

      // ----------------------------------------------------------
      // STEP 10: Navigate
      // ----------------------------------------------------------

      await _navigateToDashboard();
      return true;
    } catch (e, stackTrace) {
      debugPrint('[LoginSuccess] error=$e');
      debugPrint('[LoginSuccess] stackTrace=$stackTrace');

      await clearSession();
      ShowToastDialog.showToast(_getLoginErrorMessage(e));
      return false;
    }
  }

  /// ✅ FIX 6: show a dialog for critical errors so the user has time to read.
  void _showLoginError(String message) {
    if (message.trim().isEmpty) {
      message = 'Login failed. Please try again.';
    }
    debugPrint('[LoginError] $message');

    // Uncomment the dialog below if you prefer a blocking modal:
    // Get.defaultDialog(
    //   title: 'Login Failed',
    //   middleText: message,
    //   textConfirm: 'OK',
    //   onConfirm: Get.back,
    // );
    ShowToastDialog.showToast(message);
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
        return _initializeMerchantSession(
          response: response,
          userId: userId,
        );

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

    final controller = Get.put(
      MerchantOutletController(),
      permanent: true,
    );

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
    final outletId = _parseInt(response['outletId']) ??
        _parseInt(response['id']) ??
        _parseInt(response['userId']) ??
        0;

    if (outletId <= 0) {
      debugPrint('[OutletSession] Missing outletId');
      _showLoginError('Outlet ID missing from login. Please contact support.');
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

    await MerchantOutletController.persistApprovalState(
      result.outlet?.isApproved,
    );

    debugPrint(
      '[OutletSession] '
          'outletId=$resolvedOutletId '
          'merchantId=$merchantId',
    );

    try {
      final profile =
      await FireStoreUtils.getMerchantProfile(merchantId.toString());

      if (profile != null) {
        Constant.merchantModel = profile;
      } else {
        debugPrint('[OutletSession] Merchant profile not found');
      }
    } catch (e) {
      debugPrint('[OutletSession] Profile loading failed: $e');
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
      final onboardingFinished =
      Preferences.getBoolean(Preferences.isFinishOnBoardingKey);

      if (!onboardingFinished) {
        _goToLanding();
        return;
      }

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

      await _goToDashboardOrVerification();
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
    await _goToDashboardOrVerification();
  }

  Future<bool> _isSessionApproved() async {
    final loginType = Preferences.getString(_keyLoginType);

    try {
      if (loginType == 'OUTLET') {
        final outletId = Preferences.getInt(_keyOutletId) > 0
            ? Preferences.getInt(_keyOutletId)
            : Preferences.getInt(_keySelectedOutletId);

        if (outletId <= 0) return true;

        final result = await FireStoreUtils.fetchOutletById(outletId);
        return result.outlet?.isApproved ?? true;
      }

      if (Get.isRegistered<MerchantOutletController>()) {
        final profile =
            Get.find<MerchantOutletController>().merchantProfile.value;
        if (profile != null) {
          return profile.isApproved ?? true;
        }
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('[Session] approval check failed: $e');
      debugPrint('$stackTrace');
      return true;
    }
  }

  Future<void> _goToDashboardOrVerification() async {
    final approved = await _isSessionApproved();

    await MerchantOutletController.persistApprovalState(approved);

    if (!approved) {
      debugPrint('[Session] Not approved — showing verification screen');
      Get.offAll(
            () => const VerificationScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 400),
      );
      return;
    }

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

      final loginType = Preferences.getString(_keyLoginType);
      final userId = Preferences.getInt(_keyUserIdInt) ?? 0;

      // 1. Revoke refresh token on the backend (best-effort).
      //    Must happen BEFORE local tokens are deleted, because the
      //    request needs the Authorization header.
      try {
        final refreshToken = await getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await http.post(
            Uri.parse('${Constant.baseUrl}fm/auth/logout'),
            headers: await getHeaders(),
            body: jsonEncode({
              'refreshToken': refreshToken,
            }),
          );
        }
      } catch (e) {
        debugPrint('[Logout] Server revoke failed: $e');
      }

      // 2. Remove FCM token from backend (best-effort).
      if (loginType != null && loginType.isNotEmpty) {
        try {
          await FCMTokenService.removeToken(
            userId: userId,
            userType: loginType,
          );
        } catch (e) {
          debugPrint('[Logout] FCM token removal failed: $e');
        }
      }

      // 3. Clear FCM token on the user document (best-effort).
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

      // 4. ✅ Wipe JWT + refresh token from BOTH storage mechanisms.
      await clearAuthToken();       // secure storage + prefs
      await clearRefreshToken();    // secure storage + prefs

      // 5. Wipe the rest of the session keys.
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

  Future<String?> _getFCMToken() async {
    try {
      return await NotificationService.getToken();
    } catch (e) {
      debugPrint('[Login] Error getting FCM token: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  String _getLoginErrorMessage(Object error) {
    if (error is http.ClientException) {
      return 'Unable to connect to server. Please check your internet connection.';
    }
    return 'Login failed. Please try again.';
  }
}