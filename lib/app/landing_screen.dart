import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/app/auth_screen/login_screen.dart';
import 'package:jippymart_restaurant/app/guest_browse_screen.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';

import 'auth_screen/email_verification_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.primary300,
              themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.primary200,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    "assets/images/ic_logo.png",
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 5),

                  // App Title
                  Text(
                    "Jippymart Restaurant",
                    style: TextStyle(
                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50,
                      fontSize: 25,
                      fontFamily: AppThemeData.bold,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 0),

                  // Tagline
                  // Text(
                  //   "Manage Your Restaurant Effortlessly",
                  //   style: TextStyle(
                  //     color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey200,
                  //     fontSize: 18,
                  //     fontFamily: AppThemeData.regular,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  // const SizedBox(height: 40),
                  //
                  // // App Explanation
                  // Text(
                  //   "Welcome to Jippymart Restaurant - Your Complete Restaurant Management Solution",
                  //   style: TextStyle(
                  //     color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50,
                  //     fontSize: 20,
                  //     fontFamily: AppThemeData.semiBold,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  // const SizedBox(height: 20),
                  //
                  // Text(
                  //   "Take control of your restaurant operations with our powerful app. Manage orders, track deliveries, handle payments, and grow your business all from your mobile device.",
                  //   style: TextStyle(
                  //     color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey200,
                  //     fontSize: 16,
                  //     fontFamily: AppThemeData.regular,
                  //     height: 1.5,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),

                  // Screenshots/Demo Images
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     _buildDemoImage("assets/images/image_1.png"),
                  //     const SizedBox(width: 10),
                  //     _buildDemoImage("assets/images/image_2.png"),
                  //     const SizedBox(width: 10),
                  //     _buildDemoImage("assets/images/image_3.png"),
                  //   ],
                  // ),
                  const SizedBox(height: 40),

                  // How It Works
                  Text(
                    "How It Works",
                    style: TextStyle(
                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50,
                      fontSize: 24,
                      fontFamily: AppThemeData.bold,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  _buildHowItWorksStep(
                    icon: Icons.restaurant_menu,
                    title: "Set Up Your Restaurant",
                    description: "Add your restaurant details, menu items, and settings.",
                    themeChange: themeChange,
                  ),
                  const SizedBox(height: 20),

                  _buildHowItWorksStep(
                    icon: Icons.shopping_cart,
                    title: "Receive Orders",
                    description: "Get real-time order notifications and manage them efficiently.",
                    themeChange: themeChange,
                  ),
                  const SizedBox(height: 20),

                  _buildHowItWorksStep(
                    icon: Icons.delivery_dining,
                    title: "Track Deliveries",
                    description: "Monitor delivery status and coordinate with drivers.",
                    themeChange: themeChange,
                  ),
                  const SizedBox(height: 20),

                  _buildHowItWorksStep(
                    icon: Icons.analytics,
                    title: "Grow Your Business",
                    description: "Access analytics and insights to improve performance.",
                    themeChange: themeChange,
                  ),
                  const SizedBox(height: 50),

                  // Browse without login - App Store 5.1.1 compliance
                  RoundedButtonFill(
                    title: "Browse Sample Menu",
                    color: AppThemeData.secondary300,
                    textColor: AppThemeData.grey50,
                    onPress: () {
                      Get.to(() => const GuestBrowseScreen());
                    },
                  ),
                  const SizedBox(height: 16),

                  // Login/Register Buttons
                  RoundedButtonFill(
                    title: "Login",
                    color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                    textColor: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                    onPress: () {
                      Get.to(() => const LoginScreen());
                    },
                  ),
                  const SizedBox(height: 16),
                  RoundedButtonFill(
                    title: "Register",
                    color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey300,
                    textColor: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                    onPress: () {
                      Get.to(() => const EmailVerificationScreen());
                    },
                  ),

                  const SizedBox(height: 30),

                  // Footer text
                  Text(
                    "Join thousands of restaurant owners using Jippymart",
                    style: TextStyle(
                      color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey300,
                      fontSize: 14,
                      fontFamily: AppThemeData.regular,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildDemoImage(String imagePath) {
  //   return Container(
  //     width: 80,
  //     height: 140,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12),
  //       image: DecorationImage(
  //         image: AssetImage(imagePath),
  //         fit: BoxFit.cover,
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.2),
  //           blurRadius: 8,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildHowItWorksStep({
    required IconData icon,
    required String title,
    required String description,
    required DarkThemeProvider themeChange,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppThemeData.secondary300,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            icon,
            color: AppThemeData.grey50,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50,
                  fontSize: 18,
                  fontFamily: AppThemeData.semiBold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey200,
                  fontSize: 14,
                  fontFamily: AppThemeData.regular,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}