import 'package:flutter_svg/svg.dart';
import 'package:jippymart_restaurant/app/landing_screen.dart';
import 'package:jippymart_restaurant/controller/login_controller.dart';
import 'package:jippymart_restaurant/utils/const/image_const.dart';
import 'package:jippymart_restaurant/utils/const/text_style_const.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/service/app_update_service.dart';

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }
  final loginController = Get.put(LoginController());

  void _initializeVideo() async {
    // Navigate after a short splash - don't block first-time install
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _navigateToMainApp();
      }
    });
  }

  void _navigateToMainApp() async {
    if (!mounted) return;
    try {
      // First install: skip update check - go straight to OnBoarding/Landing
      final bool onboardingDone = Preferences.getBoolean(Preferences.isFinishOnBoardingKey);
      if (!onboardingDone) {
        Get.offAll(
          () => const LandingScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
        return;
      }

      // Returning user: check for updates with timeout (don't block if API is slow)
      bool updateRequired = false;
      try {
        updateRequired = await AppUpdateService.checkForUpdate()
            .timeout(const Duration(seconds: 5), onTimeout: () => false);
      } catch (e) {
        // Network error or timeout - proceed to app
      }
      if (updateRequired) return;

      loginController.proceedToMainApp();
    } catch (e) {
      if (!mounted) return;
      Get.offAll(
        () => const LandingScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SvgPicture.asset(ImageConst.splashImage, fit: BoxFit.fill),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome to Jippy Mart",
                style: TextStyleConst.whiteMedium24,
              ),
              Text("Merchant", style: TextStyleConst.whiteMedium24),
              SizedBox(height: 10),
              Center(
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/ic_logo.png",
                          width: 150,
                          height: 150,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Text("0% ", style: TextStyleConst.whiteMedium48),
              Text("Commission ", style: TextStyleConst.whiteMedium24),
              Text(
                "Let’s Build Local Together",
                style: TextStyleConst.whiteMedium24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

typedef SplashScreen = VideoSplashScreen;
