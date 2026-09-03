import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/app/add_outlet_screen.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/controller/merchant_outlet_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

import '../utils/preferences.dart';
import 'auth_screen/outlet_otp_verification_screen.dart';
import 'dash_board_screens/dash_board_screen.dart';

/// Merchant-only outlet list. Never used for outlet login sessions.
class MerchantOutletListScreen extends StatelessWidget {
  MerchantOutletListScreen({super.key});

  MerchantOutletController get _controller {
    if (!Get.isRegistered<MerchantOutletController>()) {
      Get.put(MerchantOutletController(), permanent: true);
    }
    return Get.find<MerchantOutletController>();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final controller = _controller;

    return Obx(() {
      final state = controller.sessionState.value;
      final showAppBar = state != MerchantSessionState.empty;

      return Scaffold(
        appBar: showAppBar
            ? AppBar(
                title: Text('My Outlets'.tr),
              )
            : null,
        floatingActionButton: state == MerchantSessionState.hasOutlets ||
            state == MerchantSessionState.empty
            ? FloatingActionButton(
                onPressed: () => _openAddOutlet(controller),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add),
              SizedBox(width: 15),
              Text(
                'ADD Outlet',
                maxLines: 2,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
            : null,
        body: _buildBody(themeChange, controller, state),
      );
    });
  }

  Widget _buildBody(
    DarkThemeProvider themeChange,
    MerchantOutletController controller,
    MerchantSessionState state,
  ) {
    switch (state) {
      case MerchantSessionState.initial:
      case MerchantSessionState.loading:
        return const Center(child: CircularProgressIndicator());

      case MerchantSessionState.error:
        return _ErrorView(
          message: controller.errorMessage.value.isNotEmpty
              ? controller.errorMessage.value
              : 'Something went wrong'.tr,
          onRetry: controller.retrySession,
        );

      case MerchantSessionState.empty:
        return _AddFirstOutletView(
          themeChange: themeChange,
          onAddOutlet: () => _openAddOutlet(controller),
        );

      case MerchantSessionState.hasOutlets:
        return RefreshIndicator(
          onRefresh: controller.refreshOutletsOnly,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.outletList.length,
            itemBuilder: (context, index) {
              final outlet = controller.outletList[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(outlet.outletName ?? ''),
                  //subtitle: Text(outlet.cuisineType ?? ''),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () async {
                    final ok =
                        await controller.enterOutletDashboard(outlet);

                    if (!ok) {
                      ShowToastDialog.showToast(
                        'Unable to open outlet'.tr,
                      );
                      return;
                    }

                    if (Get.isRegistered<DashBoardController>()) {
                      Get.find<DashBoardController>().switchToOutletMode();
                      return;
                    }

                    await Preferences.setString(
                      'selectedOutletName',
                      outlet.outletName ?? '',
                    );
                    Get.offAll(() => DashBoardScreen(
                          outletName: outlet.outletName ?? '',
                        ));
                  },
                ),
              );
            },
          ),
        );
    }
  }
  }
Future<void> _openAddOutlet(MerchantOutletController controller) async {
  final verified = await Get.to(() => const OutletOtpVerificationScreen());
  if (verified != true) return;

  final created = await Get.to(() => AddOutletScreen());
  if (created == true) {
    await controller.refreshOutletsOnly();
  }
}




/// Shown on Items/Sales/Profile tabs until merchant selects an outlet.
class MerchantSelectOutletPromptScreen extends StatelessWidget {
  const MerchantSelectOutletPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 56,
              color: AppThemeData.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              'Select an outlet first'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontFamily: AppThemeData.semiBold,
                color: AppThemeData.grey800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an outlet from the Home tab to manage orders, inventory, and sales.'
                  .tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppThemeData.regular,
                color: AppThemeData.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFirstOutletView extends StatelessWidget {
  const _AddFirstOutletView({
    required this.themeChange,
    required this.onAddOutlet,
  });

  final DarkThemeProvider themeChange;
  final VoidCallback onAddOutlet;

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: ShapeDecoration(
              color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(120),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: SvgPicture.asset('assets/icons/ic_building_two.svg'),
          ),
          const SizedBox(height: 12),
          Text(
            'Add Your First Outlet'.tr,
            style: TextStyle(
              color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
              fontSize: 22,
              fontFamily: AppThemeData.semiBold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Get started by adding your outlet details to manage your menu, orders, and reservations.'
                .tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppThemeData.grey50 : AppThemeData.grey500,
              fontSize: 16,
              fontFamily: AppThemeData.bold,
            ),
          ),
          const SizedBox(height: 20),
          RoundedButtonFill(
            title: 'Add Outlet'.tr,
            width: 55,
            height: 5.5,
            color: AppThemeData.secondary300,
            textColor: AppThemeData.grey50,
            onPress: onAddOutlet,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
