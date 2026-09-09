// import 'dart:async';
//
// import 'package:get/get.dart';
// import 'package:jippymart_restaurant/app/auth_screen/login_screen.dart';
// import 'package:jippymart_restaurant/app/dash_board_screens/dash_board_screen.dart';
// import 'package:jippymart_restaurant/app/landing_screen.dart';
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
// import 'package:jippymart_restaurant/controller/app_update_controller.dart';
// import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
// import 'package:jippymart_restaurant/utils/notification/notification_service.dart';
// import 'package:jippymart_restaurant/utils/preferences.dart';
//
// import 'login_controller.dart';
//
// class SplashController extends GetxController {
//   bool _isRedirecting = false;
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     _initializeAppUpdateController();
//     _startSplashTimer();
//   }
//
//   void _initializeAppUpdateController() {
//     try {
//       if (!Get.isRegistered<AppUpdateController>()) {
//         Get.put(AppUpdateController());
//       }
//     } catch (e) {
//       print('Error initializing AppUpdateController: $e');
//     }
//   }
//
//   void _startSplashTimer() {
//     Future.delayed(const Duration(seconds: 3), () {
//       if (!_isRedirecting) {
//         redirectScreen();
//       }
//     });
//   }
//
//   Future<void> redirectScreen() async {
//     if (_isRedirecting) {
//       return;
//     }
//
//     _isRedirecting = true;
//
//     try {
//       // ----------------------------------------------------------
//       // 1. Check app update
//       // ----------------------------------------------------------
//       final appUpdateController = Get.find<AppUpdateController>();
//
//       await appUpdateController.checkForUpdates();
//
//       // Give the update dialog time to appear.
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       // Stop here if a force update is required.
//       if (appUpdateController.isForceUpdate.value) {
//         return;
//       }
//
//       // ----------------------------------------------------------
//       // 2. Check onboarding
//       // ----------------------------------------------------------
//       final isOnboardingFinished =
//       Preferences.getBoolean(Preferences.isFinishOnBoardingKey);
//
//       if (!isOnboardingFinished) {
//         _goToLanding();
//         return;
//       }
//
//       // ----------------------------------------------------------
//       // 3. Check login session
//       // ----------------------------------------------------------
//       final isLoggedIn = await FireStoreUtils.isLogin();
//
//       if (!isLoggedIn) {
//         _clearSession();
//         _goToLanding();
//         return;
//       }
//
//       // ----------------------------------------------------------
//       // 4. Get current user
//       // ----------------------------------------------------------
//       final userId = await FireStoreUtils.getCurrentUid();
//
//       if (userId.isEmpty) {
//         _clearSession();
//         _goToLanding();
//         return;
//       }
//
//       // ----------------------------------------------------------
//       // 5. Load user profile
//       // ----------------------------------------------------------
//       final userProfile = await FireStoreUtils.getUserProfile(
//         userId,
//         forceRefresh: false,
//       );
//
//       if (userProfile == null) {
//         _clearSession();
//         _goToLanding();
//         return;
//       }
//
//       Constant.userModel = userProfile;
//
//       // ----------------------------------------------------------
//       // 6. Validate user role
//       // ----------------------------------------------------------
//       if (Constant.userModel?.role != Constant.userRoleMerchant) {
//         _clearSession();
//         _goToLanding();
//         return;
//       }
//
//       // ----------------------------------------------------------
//       // 7. Validate user status
//       // ----------------------------------------------------------
//       if (Constant.userModel?.active != true) {
//         _clearSession();
//         _goToLanding();
//         return;
//       }
//
//       // ----------------------------------------------------------
//       // 8. Update FCM token
//       // ----------------------------------------------------------
//       await _updateFcmToken();
//
//       // ----------------------------------------------------------
//       // 9. Go to dashboard
//       // ----------------------------------------------------------
//       _goToDashboard();
//     } catch (e, stackTrace) {
//       print('Error in redirectScreen: $e');
//       print(stackTrace);
//
//       ShowToastDialog.showToast(
//         'An error occurred. Please try again.',
//       );
//
//       _clearSession();
//       _goToLanding();
//     } finally {
//       _isRedirecting = false;
//     }
//   }
//
//   Future<void> _updateFcmToken() async {
//     try {
//       final user = Constant.userModel;
//
//       if (user == null) {
//         return;
//       }
//
//       final fcmToken = await NotificationService.getToken();
//
//       if (fcmToken == null || fcmToken.isEmpty) {
//         return;
//       }
//
//       user.fcmToken = fcmToken;
//
//       await FireStoreUtils.updateUser(user);
//     } catch (e) {
//       // FCM failure should not block the user from entering the app.
//       print('Error updating FCM token: $e');
//     }
//   }
//
//   void _clearSession() {
//     if (Get.isRegistered<LoginController>()) {
//       Get.find<LoginController>().clearSession();
//     }
//   }
//
//   void _goToLanding() {
//     Get.offAll(() => const LandingScreen());
//   }
//
//   void _goToDashboard() {
//     Get.offAll(() => const DashBoardScreen());
//   }
// }