import 'dart:async';
import 'package:jippymart_restaurant/app/auth_screen/login_screen.dart';
import 'package:jippymart_restaurant/app/dash_board_screens/dash_board_screen.dart';
import 'package:jippymart_restaurant/app/landing_screen.dart';
import 'package:jippymart_restaurant/app/on_boarding_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/notification/notification_service.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/app_update_controller.dart';

import 'login_controller.dart' show LoginController;

class SplashController extends GetxController {
  bool isRedirecting = false;

  @override
  void onInit() {
    print('🚀 SplashController onInit started');
    
    // Initialize app update controller
    try {
      print('🔧 Initializing AppUpdateController...');
      Get.put(AppUpdateController());
      print('✅ AppUpdateController initialized successfully');
    } catch (e) {
      print('❌ Error initializing AppUpdateController: $e');
    }
    
    // Comment out old timer implementation
    // Timer(const Duration(seconds: 3), () => redirectScreen());
    
    // New implementation with error handling
    Future.delayed(const Duration(seconds: 3), () {
      if (!isRedirecting) {
        print('⏰ Timer triggered, calling redirectScreen');
        redirectScreen();
      }
    });
    super.onInit();
  }
  final loginController = Get.find<LoginController>(); // Finds existing instance

  redirectScreen() async {
    print('🔄 redirectScreen started');
    try {
      if (isRedirecting) {
        print('⚠️ Already redirecting, skipping');
        return;
      }
      isRedirecting = true;
      print('✅ Set isRedirecting to true');

      // Check for app updates first
      print('🔍 Looking for AppUpdateController...');
      final appUpdateController = Get.find<AppUpdateController>();
      print('✅ Found AppUpdateController, calling checkForUpdates...');
      await appUpdateController.checkForUpdates();
      print('✅ checkForUpdates completed');
      
      // Wait a bit for the update dialog to show if needed
      await Future.delayed(const Duration(milliseconds: 500));
      
      // If force update is required, don't proceed
      if (appUpdateController.isForceUpdate.value) {
        print('🔄 Force update required, blocking app flow');
        return; // Don't proceed to next screen
      }
      if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
        Get.offAll(() => const LandingScreen());
        return;
      }
      bool isLogin = await FireStoreUtils.isLogin();
      if (!isLogin) {
        loginController.clearUserData();
        Get.offAll(() => const LandingScreen());
        return;
      }
      String userId = await FireStoreUtils.getCurrentUid();
      // Use cached profile when valid (same userId, not expired) to avoid refetch on post-login redirect
      final userProfile = await FireStoreUtils.getUserProfile(userId, forceRefresh: false);
      if (userProfile == null) {
        loginController.clearUserData();
        Get.offAll(() => const LandingScreen());
        return;
      }

      Constant.userModel = userProfile;
      print( "getUserProfilegetUserProfile  ${Constant.userModel?.toJson()} ");
      if (Constant.userModel?.role != Constant.userRoleVendor) {
        loginController.clearUserData();
        Get.offAll(() => const LandingScreen());
        return;
      }
      if (Constant.userModel?.active != true) {
        loginController.clearUserData();
        Get.offAll(() => const LandingScreen());
        return;
      }
      // On startup (after login): get FCM token and call profile update API with fcmToken
      try {
        Constant.userModel?.fcmToken = await NotificationService.getToken();
        await FireStoreUtils.updateUser(Constant.userModel!);
      } catch (e) {
        print('Error updating FCM token: $e');
      }

      Get.offAll(() => const DashBoardScreen());
    } catch (e) {
      print('Error in redirectScreen: $e');
      ShowToastDialog.showToast('An error occurred. Please try again.');
      loginController.clearUserData();
      Get.offAll(() => const LandingScreen());
    } finally {
      isRedirecting = false;
    }
  }
}
