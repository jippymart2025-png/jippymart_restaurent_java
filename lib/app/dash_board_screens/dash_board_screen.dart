// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
// import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
// import 'package:jippymart_restaurant/controller/product_list_controller.dart';
// import 'package:jippymart_restaurant/controller/sales_report_controller.dart';
// import 'package:jippymart_restaurant/themes/app_them_data.dart';
// import 'package:jippymart_restaurant/utils/const/color_const.dart';
// import 'package:jippymart_restaurant/utils/const/image_const.dart';
// import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// enum RestaurantCloseOption {
//   today,
//   threeDays,
//   sevenDays,
//   untilReopened,
// }
//
// class DashBoardScreen extends StatelessWidget {
//   const DashBoardScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final themeChange = Provider.of<DarkThemeProvider>(context);
//     final controller = Get.put(DashBoardController());
//     final productListController = Get.put(ProductListController());
//
//     return Obx(() {
//       return PopScope(
//         canPop: false,
//         onPopInvokedWithResult: (didPop, result) {
//           if (didPop) return;
//           if (controller.onBackPressed()) {
//             Navigator.of(context).pop();
//           } else {
//             ShowToastDialog.showToast('Double press to exit'.tr);
//           }
//         },
//         child: Scaffold(
//           body: SafeArea(
//             child: Column(
//               children: [
//                 RestaurantStatusToggle(controller: controller),
//                 Expanded(
//                   child: IndexedStack(
//                     index: controller.selectedIndex.value,
//                     children: controller.pageList,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           bottomNavigationBar: _buildBottomNav(
//             context,
//             themeChange: themeChange,
//             controller: controller,
//             productListController: productListController,
//           ),
//         ),
//       );
//     });
//   }
//
//   BottomNavigationBar _buildBottomNav(
//     BuildContext context, {
//     required DarkThemeProvider themeChange,
//     required DashBoardController controller,
//     required ProductListController productListController,
//   }) {
//     final items = Constant.isDineInEnable ? _dineInNavItems : _standardNavItems;
//     final isDark = themeChange.getThem();
//
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       showUnselectedLabels: true,
//       showSelectedLabels: true,
//       selectedFontSize: 12,
//       selectedLabelStyle: const TextStyle(fontFamily: AppThemeData.bold),
//       unselectedLabelStyle: const TextStyle(fontFamily: AppThemeData.bold),
//       currentIndex: controller.selectedIndex.value,
//       backgroundColor: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
//       selectedItemColor: ColorConst.orange,
//       unselectedItemColor: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
//       onTap: (int index) => _onNavTap(
//         context,
//         index: index,
//         controller: controller,
//         productListController: productListController,
//       ),
//       items: items
//           .map((e) => _navItem(
//                 themeChange: themeChange,
//                 index: e.index,
//                 label: e.label,
//                 assetIcon: e.assetIcon,
//                 controller: controller,
//               ))
//           .toList(),
//     );
//   }
//
//   void _onNavTap(
//     BuildContext context, {
//     required int index,
//     required DashBoardController controller,
//     required ProductListController productListController,
//   }) {
//     controller.selectedIndex.value = index;
//     if (index == 1 && productListController.productList.isEmpty) {
//       productListController.getUserProfile();
//       productListController.getProduct();
//     }
//     if (index == 2 && Get.isRegistered<SalesReportController>()) {
//       Get.find<SalesReportController>().fetchReport();
//     }
//   }
//
//   static final List<_NavItem> _standardNavItems = [
//     _NavItem(index: 0, assetIcon: ImageConst.homeIcon, label: 'Home'),
//     _NavItem(index: 1, assetIcon: ImageConst.products, label: 'Items'),
//     _NavItem(index: 2, assetIcon: ImageConst.report, label: 'Sales Report'),
//     _NavItem(index: 3, assetIcon: ImageConst.profile, label: 'Profile'),
//   ];
//
//   static final List<_NavItem> _dineInNavItems = [
//     _NavItem(index: 0, assetIcon: ImageConst.homeIcon, label: 'Home'),
//     const _NavItem(index: 1, assetIcon: 'assets/icons/ic_dinein.svg', label: 'Dine in'),
//     _NavItem(index: 2, assetIcon: ImageConst.products, label: 'Manage Inventory'),
//     _NavItem(index: 3, assetIcon: ImageConst.report, label: 'Report'),
//     _NavItem(index: 4, assetIcon: ImageConst.profile, label: 'Profile'),
//   ];
//
//   BottomNavigationBarItem _navItem({
//     required DarkThemeProvider themeChange,
//     required int index,
//     required String label,
//     required String assetIcon,
//     required DashBoardController controller,
//   }) {
//     final selected = controller.selectedIndex.value == index;
//     final isDark = themeChange.getThem();
//     final color = selected ? ColorConst.orange : (isDark ? AppThemeData.grey300 : AppThemeData.grey600);
//
//     return BottomNavigationBarItem(
//       icon: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 5),
//         child: SvgPicture.asset(assetIcon, height: 22, width: 22, color: color),
//       ),
//       label: label.tr,
//     );
//   }
// }
//
// class _NavItem {
//   const _NavItem({
//     required this.index,
//     required this.assetIcon,
//     required this.label,
//   });
//   final int index;
//   final String assetIcon;
//   final String label;
// }
//
// /// Restaurant open/closed toggle with confirm dialogs and optional closure email.
// class RestaurantStatusToggle extends StatelessWidget {
//   const RestaurantStatusToggle({super.key, required this.controller});
//
//   final DashBoardController controller;
//
//   static const Color _openColor = Color(0xFF138D75);
//   static const Color _closedColor = Color(0xFFC0392B);
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final isOpen = controller.vendorModel.value.isOpen ?? false;
//       return SwitchListTile(
//         title: Text(isOpen ? 'Restaurant Open' : 'Restaurant Closed'),
//         value: isOpen,
//         onChanged: (value) => _onChanged(context, value),
//         thumbColor: const MaterialStatePropertyAll(Colors.white),
//         trackColor: MaterialStateProperty.resolveWith<Color>((states) {
//           return states.contains(MaterialState.selected) ? _openColor : _closedColor;
//         }),
//       );
//     });
//   }
//
//   Future<void> _onChanged(BuildContext context, bool value) async {
//     if (value) {
//       final confirm = await _showOpenDialog(context);
//       if (confirm == true) {
//         final ok = await controller.updateRestStatus(true);
//         if (!ok && context.mounted) {
//           ShowToastDialog.showToast('Failed to update status'.tr);
//         }
//       }
//     } else {
//       final option = await _showCloseDialog(context);
//       if (option == null) return;
//
//       final ok = await controller.updateRestStatus(false);
//       if (!ok && context.mounted) {
//         ShowToastDialog.showToast('Failed to update status'.tr);
//         return;
//       }
//
//       if (option == RestaurantCloseOption.threeDays ||
//           option == RestaurantCloseOption.sevenDays ||
//           option == RestaurantCloseOption.untilReopened) {
//         await _sendClosureEmailIfNeeded(context, option);
//       }
//     }
//   }
//
//   Future<bool?> _showOpenDialog(BuildContext context) {
//     return showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Open Restaurant?'),
//         content: const Text(
//           'Are you sure you want to open the restaurant and start accepting orders?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Yes', style: TextStyle(color: AppThemeData.new_primary)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<RestaurantCloseOption?> _showCloseDialog(BuildContext context) {
//     return showDialog<RestaurantCloseOption>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Close Restaurant'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               title: const Text('Close for today'),
//               onTap: () => Navigator.of(context).pop(RestaurantCloseOption.today),
//             ),
//             ListTile(
//               title: const Text('Close for 3 days'),
//               onTap: () => Navigator.of(context).pop(RestaurantCloseOption.threeDays),
//             ),
//             ListTile(
//               title: const Text('Close for 7 days'),
//               onTap: () => Navigator.of(context).pop(RestaurantCloseOption.sevenDays),
//             ),
//             ListTile(
//               title: const Text('Close until I open'),
//               onTap: () => Navigator.of(context).pop(RestaurantCloseOption.untilReopened),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _sendClosureEmailIfNeeded(
//     BuildContext context,
//     RestaurantCloseOption option,
//   ) async {
//     final durationText = switch (option) {
//       RestaurantCloseOption.threeDays => '3 days',
//       RestaurantCloseOption.sevenDays => '7 days',
//       RestaurantCloseOption.untilReopened => 'until reopened',
//       RestaurantCloseOption.today => 'today',
//     };
//
//     final restaurantName = controller.vendorModel.value.title ?? 'Unknown Restaurant';
//     final subject = '[$restaurantName] Temporary closure – $durationText';
//     final body = 'Hello,\n'
//         'The restaurant "$restaurantName" has been temporarily closed '
//         'for $durationText from the dashboard toggle.\n'
//         'Selected option: Close for $durationText.\n'
//         'Please review if any operational or support action is needed.\n'
//         'Thanks,\n'
//         'JippyMart Restaurant App';
//
//     final uri = Uri(
//       scheme: 'mailto',
//       path: 'devjippy@gmail.com',
//       query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
//     );
//
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else if (context.mounted) {
//       await Constant.sendMail(
//         subject: subject,
//         body: body,
//         recipients: <dynamic>['devjippy@gmail.com'],
//         isAdmin: true,
//       );
//     }
//   }
// }
//
//




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

// ─────────────────────────────────────────────────────────────────────────────
// Nav item data – plain const records, no runtime allocation
// ─────────────────────────────────────────────────────────────────────────────
class _NavItemData {
  const _NavItemData({required this.icon, required this.label});
  final String icon;
  final String label;
}

final List<_NavItemData> _kStandardNav = [
  _NavItemData(icon: ImageConst.homeIcon, label: 'Home'),
  _NavItemData(icon: ImageConst.products, label: 'Items'),
  _NavItemData(icon: ImageConst.report, label: 'Sales'),
  _NavItemData(icon: ImageConst.profile, label: 'Profile'),
];

 List<_NavItemData> _kDineInNav = [
  _NavItemData(icon: ImageConst.homeIcon, label: 'Home'),
  _NavItemData(icon: 'assets/icons/ic_dinein.svg', label: 'Dine In'),
  _NavItemData(icon: ImageConst.products, label: 'Inventory'),
  _NavItemData(icon: ImageConst.report, label: 'Report'),
  _NavItemData(icon: ImageConst.profile, label: 'Profile'),
];

// ─────────────────────────────────────────────────────────────────────────────
// DashBoardScreen
// ─────────────────────────────────────────────────────────────────────────────
class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final controller = Get.put(DashBoardController());
    final productCtrl = Get.put(ProductListController());

    return Obx(() => PopScope(
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
              // ── Restaurant status banner ───────────────────────────
              _StatusBanner(controller: controller),
              // ── Page content ──────────────────────────────────────
              Expanded(
                child: IndexedStack(
                  index: controller.selectedIndex.value,
                  children: controller.pageList,
                ),
              ),
            ],
          ),
        ),
        // ── Custom bottom nav ─────────────────────────────────────
        bottomNavigationBar: _BottomNavBar(
          themeChange: themeChange,
          controller: controller,
          productCtrl: productCtrl,
          items: Constant.isDineInEnable ? _kDineInNav : _kStandardNav,
        ),
      ),
    ));
  }

  void _showExitSnack(BuildContext context, bool isDark) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(
          'Press back again to exit'.tr,
          style: const TextStyle(
              fontFamily: AppThemeData.medium, fontSize: 13),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor:
        isDark ? AppThemeData.grey700 : AppThemeData.grey800,
      ));
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
      final fg = isOpen ? _kGreen : _kRed;
      final bg = isOpen ? _kGreenBg : _kRedBg;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.fromLTRB(0, 2, 0, 2),
        decoration: BoxDecoration(
          color: bg,
          // borderRadius: BorderRadius.circular(14),
          // border: Border.all(color: fg.withOpacity(0.25)),
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            splashColor: fg.withOpacity(0.1),
            onTap: isLoading ? null : () => _onTap(context, isOpen),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  _LiveDot(color: fg, active: isOpen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOpen ? 'Open for Orders' : 'Currently Closed',
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
                          strokeWidth: 2, color: fg),
                    )
                  else
                    _TogglePill(isOn: isOpen, color: fg),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _onTap(BuildContext context, bool isOpen) async {
    if (isOpen) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => const _ConfirmDialog(
          iconData: Icons.storefront_rounded,
          iconColor: _kRed,
          title: 'Close Restaurant?',
          message:
          'Customers will not be able to place new orders while your restaurant is closed.',
          confirmLabel: 'Close',
          confirmColor: _kRed,
          isDanger: true,
        ),
      ) ??
          false;

      if (!ok) return;

      // Ask for duration before calling API
      if (!context.mounted) return;
      final option = await showDialog<RestaurantCloseOption>(
        context: context,
        builder: (_) => const _CloseOptionsDialog(),
      );
      if (option == null) return;

      final success = await controller.updateRestStatus(false);
      if (!success && context.mounted) {
        ShowToastDialog.showToast('Failed to update status'.tr);
        return;
      }
      if (option != RestaurantCloseOption.today && context.mounted) {
        await _maybeSendEmail(context, option);
      }
    } else {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => const _ConfirmDialog(
          iconData: Icons.storefront_rounded,
          iconColor: _kGreen,
          title: 'Open Restaurant?',
          message:
          'Your restaurant will be visible to customers and start accepting orders.',
          confirmLabel: 'Open Now',
          confirmColor: _kGreen,
        ),
      ) ??
          false;

      if (!ok) return;
      final success = await controller.updateRestStatus(true);
      if (!success && context.mounted) {
        ShowToastDialog.showToast('Failed to update status'.tr);
      }
    }
  }

  Future<void> _maybeSendEmail(
      BuildContext context, RestaurantCloseOption option) async {
    final dur = switch (option) {
      RestaurantCloseOption.threeDays => '3 days',
      RestaurantCloseOption.sevenDays => '7 days',
      RestaurantCloseOption.untilReopened => 'until reopened',
      RestaurantCloseOption.today => 'today',
    };
    final name =
        controller.vendorModel.value.title ?? 'Unknown Restaurant';
    final phone =
        controller.vendorModel.value.phonenumber ?? 'Unknown Restaurant';
    final subject = '[$name] Temporary closure – $dur';
    final body =
        'Hello,\nThe restaurant "$name" has been temporarily closed for $dur.\n'
        'Please review if any action is needed.\n\n'
        'phone number: "$phone"\n'
        'Thanks,\nJippyMart';

    // iOS is stricter with mailto parsing; use one "to" address and the other as cc.
    final uri = Uri(
      scheme: 'mailto',
      path: 'Sivapm@jippymart.in',
      query:
          'cc=${Uri.encodeComponent('Sudheer@jippymart.in')}&subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    // Try platform default first, then explicit external app handoff.
    bool launched = await launchUrl(uri);
    if (!launched) {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (!launched && context.mounted) {
      await Constant.sendMail(
        subject: subject,
        body: body,
        recipients: <dynamic>[
          'Sivapm@jippymart.in',
          'Sudheer@jippymart.in',
        ],
        isAdmin: true,
      );
    }
  }
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
  final List<_NavItemData> items;

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
    controller.selectedIndex.value = index;

    if (index == 1 && productCtrl.productList.isEmpty) {
      productCtrl
        ..getUserProfile()
        ..getProduct();
    }
    if (index == 2 && Get.isRegistered<SalesReportController>()) {
      Get.find<SalesReportController>().fetchReport();
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

  final _NavItemData data;
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