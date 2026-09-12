import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/app/auth_screen/screens/login_screen.dart';
import 'package:jippymart_restaurant/app/auth_screen/screens/signup_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';

/// GuestBrowseScreen - App Store 5.1.1 compliance: Allows browsing products/features
/// without login. Users can explore sample menu items before creating an account.
class GuestBrowseScreen extends StatefulWidget {
  const GuestBrowseScreen({super.key});

  @override
  State<GuestBrowseScreen> createState() => _GuestBrowseScreenState();
}

class _GuestBrowseScreenState extends State<GuestBrowseScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollHint = true;

  /// Format price in Indian Rupees (₹)
  static String _formatPrice(String amount) {
    if (Constant.currencyModel != null) {
      return Constant.amountShow(amount: amount);
    }
    final value = double.tryParse(amount) ?? 0.0;
    return '₹ ${value.toStringAsFixed(0)}';
  }

  static const List<Map<String, String>> _demoProducts = [
    {
      'name': 'Butter Chicken',
      'description': 'Tender chicken in rich tomato and butter gravy with aromatic spices',
      'price': '₹ 249.00 (example)',
      'image': 'assets/images/demo_food/butterchicken.jpeg',
    },
    {
      'name': 'Paneer Tikka',
      'description': 'Marinated cottage cheese grilled with spices and lemon',
      'price': '₹ 199.00 (example)',
      'image': 'assets/images/demo_food/paneertikka.jpeg',
    },
    {
      'name': 'Biryani',
      'description': 'Fragrant basmati rice with spiced meat or vegetables',
      'price': '₹ 299.00 (example)',
      'image': 'assets/images/demo_food/biryani.jpeg',
    },
    {
      'name': 'Masala Dosa',
      'description': 'Crispy rice crepe filled with spiced potato filling',
      'price': '₹ 99.00 (example)',
      'image': 'assets/images/demo_food/dosa.jpeg',
    },
    {
      'name': 'Dal Makhani',
      'description': 'Creamy black lentils slow-cooked with butter and cream',
      'price': '₹ 178.00 (example)',
      'image': 'assets/images/demo_food/dal.jpeg',
    },
    {
      'name': 'Gulab Jamun',
      'description': 'Soft milk dumplings in rose-scented sugar syrup',
      'price': '₹ 79.00 (example)',
      'image': 'assets/images/demo_food/jamun.jpeg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && _showScrollHint) {
        setState(() => _showScrollHint = false);
      } else if (_scrollController.offset <= 50 && !_showScrollHint) {
        setState(() => _showScrollHint = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.primary300,
        elevation: 0,
        title: Text(
          "Demo Menu Preview".tr,
          style: TextStyle(
            color: AppThemeData.grey50,
            fontSize: 18,
            fontFamily: AppThemeData.semiBold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppThemeData.grey50),
          onPressed: () => Get.back(),
        ),
      ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "This is a sample, non-interactive menu shown for demonstration purposes only Items and prices are illustrative and cannot be ordered."
                      .tr,
                  style: TextStyle(
                    color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey200,
                    fontSize: 14,
                    fontFamily: AppThemeData.regular,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Scroll hint - visible when at top
              AnimatedOpacity(
                opacity: _showScrollHint ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                        size: 24,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Scroll down for more".tr,
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                          fontSize: 13,
                          fontFamily: AppThemeData.medium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 40,
                      ),
                      itemCount: _demoProducts.length,
                  itemBuilder: (context, index) {
                    final product = _demoProducts[index];
                    return _buildDemoProductCard(
                      name: product['name']!,
                      description: product['description']!,
                      price: (product['price']!),
                      imagePath: product['image']!,
                      themeChange: themeChange,
                    );
                  },
                    ),
                    // Fade gradient at bottom to hint more content
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 48,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                (themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.primary200).withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.transparent,
                child: Column(
                  children: [
                    Text(
                      "Ready to manage your restaurant?".tr,
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50,
                        fontSize: 16,
                        fontFamily: AppThemeData.semiBold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RoundedButtonFill(
                      title: "Create Account".tr,
                      color: AppThemeData.secondary300,
                      textColor: AppThemeData.grey50,
                      onPress: () => Get.off(() => const SignupScreen()),
                    ),
                    const SizedBox(height: 12),
                    RoundedButtonFill(
                      title: "Login".tr,
                      color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey300,
                      textColor: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                      onPress: () => Get.off(() => const LoginScreen()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoProductCard({
    required String name,
    required String description,
    required String price,
    required String imagePath,
    required DarkThemeProvider themeChange,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeChange.getThem()
            ? AppThemeData.grey800.withOpacity(0.5)
            : AppThemeData.grey50.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFoodPlaceholder(themeChange),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                      fontSize: 16,
                      fontFamily: AppThemeData.semiBold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                      fontSize: 12,
                      fontFamily: AppThemeData.regular,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      color: AppThemeData.secondary300,
                      fontSize: 14,
                      fontFamily: AppThemeData.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodPlaceholder(DarkThemeProvider themeChange) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemeData.secondary300.withOpacity(0.3),
            AppThemeData.secondary300.withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.restaurant_menu,
        size: 40,
        color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
      ),
    );
  }
}
