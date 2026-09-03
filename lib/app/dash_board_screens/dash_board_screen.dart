
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/controller/product_list_controller.dart';
import 'package:jippymart_restaurant/controller/sales_report_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:jippymart_restaurant/utils/const/image_const.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/service/dashboard_api_service.dart';
import '../../models/bottom_nav_item.dart';
import '../../utils/preferences.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Nav item data – plain const records, no runtime allocation
// ─────────────────────────────────────────────────────────────────────────────
//


// ─────────────────────────────────────────────────────────────────────────────
// DashBoardScreen
// ─────────────────────────────────────────────────────────────────────────────
class DashBoardScreen extends StatelessWidget {
  final String outletName;

  const DashBoardScreen({
    super.key,
    this.outletName = '',
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final controller = Get.put(DashBoardController());
    final productCtrl = Get.put(ProductListController(), permanent: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("Dashboard opened");
      debugPrint("selectedIndex = ${controller.selectedIndex.value}");
    });

    return Obx(() {
      final navItems = controller.getNavItems();

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;

          if (controller.onBackPressed()) {
            Navigator.of(context).pop();
          } else {
            _showExitSnack(context, themeChange.getThem());
          }
        },
        child: Scaffold(
          backgroundColor: themeChange.getThem()
              ? AppThemeData.grey900
              : const Color(0xFFF5F6FA),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                if (controller.showStatusBanner)
                  _StatusBanner(controller: controller),

                Expanded(
                  child: IndexedStack(
                    key: ValueKey(
                      'dashboard-${controller.activeOutletId.value}',
                    ),
                    index: controller.selectedIndex.value,
                    children: controller.pageList,
                  ),
                ),
              ],
            ),
          ),

          bottomNavigationBar: _BottomNavBar(
            themeChange: themeChange,
            controller: controller,
            productCtrl: productCtrl,
            items: navItems,
          ),
        ),
      );
    });
  }

  void _showExitSnack(BuildContext context, bool isDark) {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Press back again to exit'.tr,
            style: const TextStyle(
              fontFamily: AppThemeData.medium,
              fontSize: 13,
            ),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor:
          isDark ? AppThemeData.grey700 : AppThemeData.grey800,
        ),
      );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Status Banner
// ─────────────────────────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.controller});
  final DashBoardController controller;


  static const _kGreen = Color(0xFF0A9E6E);
  static const _kRed = Color(0xFFDC3545);
  static const _kGreenBg = Color(0xFFE6F9F2);
  static const _kRedBg = Color(0xFFFFECEC);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOpen = controller.vendorModel.value.isOpen ?? false;
      final isLoading = controller.isUpdatingStatus.value;
      final showBack = controller.isMerchantOutletDashboard;
      final fg = isOpen ? _kGreen : _kRed;
      final bg = isOpen ? _kGreenBg : _kRedBg;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.fromLTRB(0, 2, 0, 2),
        decoration: BoxDecoration(
          color: bg,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Row(
              children: [
                if (showBack)
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: fg),
                    tooltip: 'Back to outlets'.tr,
                    onPressed: () => controller.switchToMerchantMode(),
                  ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      splashColor: fg.withOpacity(0.1),
                      onTap: isLoading ? null : () => _onTap(context, isOpen),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            _LiveDot(color: fg, active: isOpen),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isOpen
                                        ? 'Open for Orders'
                                        : 'Currently Closed',
                                    style: TextStyle(
                                      color: fg,
                                      fontSize: 13,
                                      fontFamily: AppThemeData.bold,
                                    ),
                                  ),
                                  Text(
                                    isOpen
                                        ? 'Accepting new orders'
                                        : 'Not accepting orders',
                                    style: TextStyle(
                                      color: fg.withOpacity(0.7),
                                      fontSize: 11,
                                      fontFamily: AppThemeData.medium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isLoading)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: fg,
                                ),
                              )
                            else
                              _TogglePill(isOn: isOpen, color: fg),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Future<void> _onTap(BuildContext context, bool isOpen) async {
  //   if (isOpen) {
  //     final ok = await showDialog<bool>(
  //       context: context,
  //       builder: (_) => const _ConfirmDialog(
  //         iconData: Icons.storefront_rounded,
  //         iconColor: _kRed,
  //         title: 'Close Restaurant?',
  //         message:
  //         'Customers will not be able to place new orders while your restaurant is closed.',
  //         confirmLabel: 'Close',
  //         confirmColor: _kRed,
  //         isDanger: true,
  //       ),
  //     ) ??
  //         false;
  //
  //     if (!ok) return;
  //
  //     // Ask for duration before calling API
  //     if (!context.mounted) return;
  //     final option = await showDialog<RestaurantCloseOption>(
  //       context: context,
  //       builder: (_) => const _CloseOptionsDialog(),
  //     );
  //     if (option == null) return;
  //
  //     final success = await controller.(false);
  //     if (!success && context.mounted) {
  //       ShowToastDialog.showToast('Failed to update status'.tr);
  //       return;
  //     }
  //     if (option != RestaurantCloseOption.today && context.mounted) {
  //       await _maybeSendEmail(context, option);
  //     }
  //   } else {
  //     final ok = await showDialog<bool>(
  //       context: context,
  //       builder: (_) => const _ConfirmDialog(
  //         iconData: Icons.storefront_rounded,
  //         iconColor: _kGreen,
  //         title: 'Open Restaurant?',
  //         message:
  //         'Your restaurant will be visible to customers and start accepting orders.',
  //         confirmLabel: 'Open Now',
  //         confirmColor: _kGreen,
  //       ),
  //     ) ??
  //         false;
  //
  //     if (!ok) return;
  //     final success = await controller.updateRestStatus(true);
  //     if (!success && context.mounted) {
  //       ShowToastDialog.showToast('Failed to update status'.tr);
  //     }
  //   }
  // }

  Future<void> _onTap(BuildContext context, bool isOpen) async {
    if (isOpen) {
      // ================= CLOSE RESTAURANT =================

      final bool ok =
          await showDialog<bool>(
            context: context,
            builder: (_) => const _ConfirmDialog(
              iconData: Icons.storefront_rounded,
              iconColor: _kRed,
              title: 'Close Outlet?',
              message:
              'Customers will not be able to place new orders while your restaurant is closed.',
              confirmLabel: 'Close',
              confirmColor: _kRed,
              isDanger: true,
            ),
          ) ??
              false;

      if (!ok) return;

      if (!context.mounted) return;

      final RestaurantCloseOption? option =
      await showDialog<RestaurantCloseOption>(
        context: context,
        builder: (_) => const _CloseOptionsDialog(),
      );

      if (option == null) return;

      final DateTime now = DateTime.now();

      DateTime? toDate;

      switch (option) {
        case RestaurantCloseOption.today:
          toDate = DateTime(
            now.year,
            now.month,
            now.day,
            23,
            59,
            59,
          );
          break;

        case RestaurantCloseOption.tomorrow:
          toDate = DateTime(
            now.year,
            now.month,
            now.day + 1,
            23,
            59,
            59,
          );
          break;

        case RestaurantCloseOption.threeDays:
          toDate = now.add(const Duration(days: 3));
          break;

        case RestaurantCloseOption.sevenDays:
          toDate = now.add(const Duration(days: 7));
          break;

        case RestaurantCloseOption.untilReopened:
          toDate = DateTime(2099, 12, 31, 23, 59, 59);
          break;

        case RestaurantCloseOption.custom:
        // Use custom selected date here
          return;
      }

      final outletId = DashBoardController.resolveActiveOutletId();
      print('========== OPEN OUTLET ==========');
      print('outletId = $outletId');
      print('loginType = ${Preferences.getString('loginType')}');
      print(
        'Preferences outletId = ${Preferences.getInt('outletId')}',
      );
      print(
        'Preferences selectedOutletId = ${Preferences.getInt('selectedOutletId')}',
      );
      print('=================================');
      if (outletId <= 0) {
        ShowToastDialog.showToast('No outlet selected'.tr);
        return;
      }

      final success = await DashBoardController.updateOutletUnavailability(
        type: "OUTLET",
        unavailabilityId: outletId,
        fromDate: now,
        toDate: toDate,
        reason: "Outlet temporarily unavailable",
      );

      if (!success) {
        ShowToastDialog.showToast(
          "Failed to close outlet",
        );
        return;
      }

// Update UI
      controller.vendorModel.update((vendor) {
        if (vendor != null) {
          vendor.isOpen = false;
          vendor.reststatus = false;
        }
      });

      await Preferences.setBoolean(
        Preferences.vendorIsOpenKey,
        false,
      );

      controller.vendorModel.refresh();

      ShowToastDialog.showToast(
        "Outlet closed successfully",
      );


      // switch (option) {
      //   case RestaurantCloseOption.today:
      //     fromDate = now;
      //     toDate = DateTime(
      //       now.year,
      //       now.month,
      //       now.day,
      //       23,
      //       59,
      //       59,
      //     );
      //     reason = "Restaurant closed for today";
      //     break;
      //
      //   case RestaurantCloseOption.tomorrow:
      //     fromDate = now;
      //     toDate = now.add(const Duration(days: 1));
      //     reason = "Restaurant closed until tomorrow";
      //     break;
      //
      //   case RestaurantCloseOption.custom:
      //     fromDate = now;
      //     toDate = now.add(const Duration(days: 7));
      //     reason = "Restaurant temporarily unavailable";
      //     break;
      // }

      // final bool success =
      // await ApiService.updateOutletUnavailability(
      //   type: "outlet",
      //   unavailabilityId: 7,
      //   fromDate: fromDate,
      //   toDate: toDate,
      //   reason: reason,
      // );

      // if (!success) {
      //   if (context.mounted) {
      //     ShowToastDialog.showToast(
      //       'Failed to update status'.tr,
      //     );
      //   }
      //   return;
      // }



      if (option != RestaurantCloseOption.today &&
          context.mounted) {
        // await _maybeSendEmail(context, option);
      }
    } else {
      // ================= OPEN RESTAURANT =================

      // ================= OPEN RESTAURANT =================

      final bool ok =
          await showDialog<bool>(
            context: context,
            builder: (_) => const _ConfirmDialog(
              iconData: Icons.storefront_rounded,
              iconColor: _kGreen,
              title: 'Open Outlet?',
              message:
              'Your restaurant will be visible to customers and start accepting orders.',
              confirmLabel: 'Open Now',
              confirmColor: _kGreen,
            ),
          ) ??
              false;

      if (!ok) return;

      final outletId = DashBoardController.resolveActiveOutletId();
      if (outletId <= 0) {
        ShowToastDialog.showToast('No outlet selected'.tr);
        return;
      }

      final bool success =
      await DashboardApiService.restoreOutletAvailability(
        type: "OUTLET",
        unavailabilityId: outletId,
        reason: "Outlet reopened",
      );
      if (!success) {
        ShowToastDialog.showToast(
          "Failed to update status",
        );
        return;
      }

// Update UI
      controller.vendorModel.update((vendor) {
        if (vendor != null) {
          vendor.isOpen = true;
          vendor.reststatus = true;
        }
      });

      await Preferences.setBoolean(
        Preferences.vendorIsOpenKey,
        true,
      );

      controller.vendorModel.refresh();

      ShowToastDialog.showToast(
        "Outlet opened successfully",
      );

    }
  }
  //
  // Future<void> _maybeSendEmail(
  //     BuildContext context, RestaurantCloseOption option) async {
  //   final dur = switch (option) {
  //     RestaurantCloseOption.threeDays => '3 days',
  //     RestaurantCloseOption.sevenDays => '7 days',
  //     RestaurantCloseOption.untilReopened => 'until reopened',
  //     RestaurantCloseOption.today => 'today',
  //   };
  //   final name =
  //       controller.vendorModel.value.title ?? 'Unknown Restaurant';
  //   final phone =
  //       controller.vendorModel.value.phonenumber ?? 'Unknown Restaurant';
  //   final subject = '[$name] Temporary closure – $dur';
  //   final body =
  //       'Hello,\nThe restaurant "$name" has been temporarily closed for $dur.\n'
  //       'Please review if any action is needed.\n\n'
  //       'phone number: "$phone"\n'
  //       'Thanks,\nJippyMart';
  //
  //   // iOS is stricter with mailto parsing; use one "to" address and the other as cc.
  //   final uri = Uri(
  //     scheme: 'mailto',
  //     path: 'Sivapm@jippymart.in',
  //     query:
  //         'cc=${Uri.encodeComponent('Sudheer@jippymart.in')}&subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
  //   );
  //
  //   // Try platform default first, then explicit external app handoff.
  //   bool launched = await launchUrl(uri);
  //   if (!launched) {
  //     launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   }
  //   if (!launched && context.mounted) {
  //     await Constant.sendMail(
  //       subject: subject,
  //       body: body,
  //       recipients: <dynamic>[
  //         'Sivapm@jippymart.in',
  //         'Sudheer@jippymart.in',
  //       ],
  //       isAdmin: true,
  //     );
  //   }
  // }
}

// ─────────────────────────────────────────────────────────────────────────────
// Live pulsing dot
// ─────────────────────────────────────────────────────────────────────────────
class _LiveDot extends StatefulWidget {
  const _LiveDot({required this.color, required this.active});
  final Color color;
  final bool active;

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..repeat(reverse: true);

  late final Animation<double> _scale =
  Tween<double>(begin: 0.8, end: 1.2).animate(
    CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
      );
    }
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.45),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated toggle pill
// ─────────────────────────────────────────────────────────────────────────────
class _TogglePill extends StatelessWidget {
  const _TogglePill({required this.isOn, required this.color});
  final bool isOn;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: 42,
      height: 24,
      decoration: BoxDecoration(
        color: isOn ? color : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Bottom Nav Bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.themeChange,
    required this.controller,
    required this.productCtrl,
    required this.items,
  });

  final DarkThemeProvider themeChange;
  final DashBoardController controller;
  final ProductListController productCtrl;
  final List<BottomNavItem>items;

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey900 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: List.generate(
                items.length,
                    (i) => Expanded(
                  child: _NavTile(
                    data: items[i],
                    index: i,
                    isDark: isDark,
                    controller: controller,
                    onTap: () => _handleTap(i),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),    );
  }
  void _handleTap(int index) {
    HapticFeedback.selectionClick();

    final item = items[index];

    if (controller.isMerchantListMode &&
        item.id != BottomNavId.home &&
        item.id != BottomNavId.profile &&
        item.id != BottomNavId.sales) {
      ShowToastDialog.showToast(
        'Select an outlet first'.tr,
      );
      return;
    }

    final prevIndex = controller.selectedIndex.value;

    controller.selectedIndex.value = index;

    switch (item.id) {
      case BottomNavId.home:
        break;

      case BottomNavId.dineIn:
        break;

      case BottomNavId.inventory:
        productCtrl.refreshInventory(
          forceRefresh: true,
          outletId: DashBoardController.resolveActiveOutletId(),
        );
        break;

      case BottomNavId.subscription:
        if (prevIndex != index) {
          controller.resetPromotionsQuickAction();
        }
        break;

      case BottomNavId.sales:
        if (Get.isRegistered<SalesReportController>()) {
          Get.find<SalesReportController>().fetchReport();
        }
        break;

      case BottomNavId.profile:
        break;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual nav tile with animated selection pill
// ─────────────────────────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.data,
    required this.index,
    required this.isDark,
    required this.controller,
    required this.onTap,
  });

  final BottomNavItem data;
  final int index;
  final bool isDark;
  final DashBoardController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedIndex.value == index;
      final activeColor = ColorConst.orange;
      final inactiveColor =
      isDark ? AppThemeData.grey400 : AppThemeData.grey500;
      final color = selected ? activeColor : inactiveColor;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with pill background
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? activeColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SvgPicture.asset(
                data.icon,
                height: 22,
                width: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 1),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10.5,
                fontFamily: selected
                    ? AppThemeData.semiBold
                    : AppThemeData.medium,
                color: color,
              ),
              child: Text(data.label.tr),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable confirm dialog
// ─────────────────────────────────────────────────────────────────────────────
class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.iconData,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    this.isDanger = false,
  });

  final IconData iconData;
  final Color iconColor;
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title.tr,
              style: const TextStyle(
                  fontSize: 17, fontFamily: AppThemeData.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontFamily: AppThemeData.regular,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Cancel'.tr,
                      style: TextStyle(
                        fontFamily: AppThemeData.medium,
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      confirmLabel.tr,
                      style: const TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Close options dialog
// ─────────────────────────────────────────────────────────────────────────────
class _CloseOptionsDialog extends StatelessWidget {
  const _CloseOptionsDialog();

  static const _kRed = Color(0xFFDC3545);

  static const List<_CloseOption> _options = [
    _CloseOption(
      value: RestaurantCloseOption.today,
      icon: Icons.wb_sunny_outlined,
      label: 'Close for today',
      sub: 'Reopens automatically tomorrow',
    ),
    _CloseOption(
      value: RestaurantCloseOption.threeDays,
      icon: Icons.event_outlined,
      label: 'Close for 3 days',
      sub: 'Team will be notified by email',
    ),
    _CloseOption(
      value: RestaurantCloseOption.sevenDays,
      icon: Icons.date_range_outlined,
      label: 'Close for 7 days',
      sub: 'Team will be notified by email',
    ),
    _CloseOption(
      value: RestaurantCloseOption.untilReopened,
      icon: Icons.lock_outline_rounded,
      label: 'Close Until I Open',
      sub: 'Reopen manually from the dashboard',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _kRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store_mall_directory_rounded,
                      color: _kRed, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Close Restaurant'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: AppThemeData.bold,
                      ),
                    ),
                    Text(
                      'How long should we pause orders?'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontFamily: AppThemeData.regular,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Options list
            ..._options.map(
                  (o) => _CloseOptionRow(
                option: o,
                onTap: () => Navigator.of(context).pop(o.value),
              ),
            ),

            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel'.tr,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontFamily: AppThemeData.medium,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Single close option row
class _CloseOption {
  const _CloseOption({
    required this.value,
    required this.icon,
    required this.label,
    required this.sub,
  });
  final RestaurantCloseOption value;
  final IconData icon;
  final String label;
  final String sub;
}

class _CloseOptionRow extends StatelessWidget {
  const _CloseOptionRow({required this.option, required this.onTap});
  final _CloseOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(option.icon,
                      size: 17, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: AppThemeData.semiBold,
                        ),
                      ),
                      Text(
                        option.sub.tr,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontFamily: AppThemeData.regular,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}