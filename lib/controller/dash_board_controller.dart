// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jippymart_restaurant/app/Home_screen/home_screen.dart';
// import 'package:jippymart_restaurant/app/dash_board_screens/sales_report_screen.dart';
// import 'package:jippymart_restaurant/app/product_screens/product_list_screen.dart';
// import 'package:jippymart_restaurant/app/profile_screen/profile_screen.dart';
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/controller/app_update_controller.dart';
// import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
// import 'package:jippymart_restaurant/utils/preferences.dart';
// import 'package:jippymart_restaurant/config/app_config.dart';
// import 'package:jippymart_restaurant/models/vendor_model.dart';
//
// /// Controller for the main dashboard: vendor state, page list, and app lifecycle.
// class DashBoardController extends GetxController with WidgetsBindingObserver {
//   // ─────────────────────────────────────────────────────────────────────────
//   // State
//   // ─────────────────────────────────────────────────────────────────────────
//
//   static const Duration doublePressExitInterval = Duration(seconds: 2);
//
//   final RxInt selectedIndex = 0.obs;
//   final RxList<Widget> pageList = <Widget>[].obs;
//   final Rx<VendorModel> vendorModel = VendorModel().obs;
//   final RxBool canPopNow = false.obs;
//
//   DateTime? _lastBackPressTime;
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Lifecycle
//   // ─────────────────────────────────────────────────────────────────────────
//
//   @override
//   void onInit() {
//     super.onInit();
//     WidgetsBinding.instance.addObserver(this);
//     _restoreVendorOpenState();
//     _loadVendor();
//     _buildPageList();
//     _checkMandatoryUpdate();
//   }
//
//   @override
//   void onClose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.onClose();
//   }

//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _checkMandatoryUpdate();
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Vendor
//   // ─────────────────────────────────────────────────────────────────────────
//
//   /// Restores last known open/closed state so the toggle does not flash closed on restart.
//   void _restoreVendorOpenState() {
//     try {
//       final saved = Preferences.getBoolean(Preferences.vendorIsOpenKey);
//       final current = vendorModel.value;
//       vendorModel.value = current.copyWith(isOpen: saved, reststatus: saved);
//       vendorModel.refresh();
//     } catch (_) {}
//   }
//
//   /// Loads vendor from API and updates local state; merges persisted isOpen when API omits it.
//   Future<void> loadVendor() async {
//     final vendorId = Constant.userModel?.vendorID?.toString();
//     if (vendorId == null || vendorId.isEmpty) return;
//
//     if (AppConfig.enableDebugLogs) {
//       // ignore: avoid_print
//       debugPrint('DashBoardController.loadVendor: vendorId=$vendorId');
//     }
//
//     try {
//       final value = await FireStoreUtils.getVendorById(vendorId, forceRefresh: true);
//       if (value == null) return;
//
//       Constant.vendorAdminCommission = value.adminCommission;
//       value.id ??= vendorId;
//
//       final isOpen = value.isOpen ??
//           Preferences.getBoolean(Preferences.vendorIsOpenKey);
//       value.isOpen = isOpen;
//       value.reststatus = isOpen;
//       Preferences.setBoolean(Preferences.vendorIsOpenKey, isOpen);
//
//       vendorModel.value = value;
//       vendorModel.refresh();
//     } catch (e) {
//       if (AppConfig.enableDebugLogs) {
//         // ignore: avoid_print
//         debugPrint('DashBoardController.loadVendor error: $e');
//       }
//     }
//   }
//
//   /// Updates restaurant open/closed status on the server and in local state.
//   Future<bool> updateRestStatus(bool status) async {
//     final vendorId = Constant.userModel?.vendorID?.toString();
//     if (vendorId == null || vendorId.isEmpty) {
//       if (AppConfig.enableDebugLogs) {
//         debugPrint('DashBoardController.updateRestStatus: missing vendorId');
//       }
//       return false;
//     }
//
//     try {
//       final latest = await FireStoreUtils.getVendorById(vendorId, forceRefresh: true);
//       if (latest == null) {
//         if (AppConfig.enableDebugLogs) {
//           debugPrint('DashBoardController.updateRestStatus: failed to load vendor');
//         }
//         return false;
//       }
//
//       latest.id ??= vendorId;
//       latest.isOpen = status;
//       latest.reststatus = status;
//
//       final updated = await FireStoreUtils.updateVendor(latest);
//       if (updated == null) return false;
//
//       await Preferences.setBoolean(Preferences.vendorIsOpenKey, status);
//       vendorModel.value = updated;
//       vendorModel.refresh();
//       return true;
//     } catch (e) {
//       if (AppConfig.enableDebugLogs) {
//         debugPrint('DashBoardController.updateRestStatus error: $e');
//       }
//       return false;
//     }
//   }
//
//   /// Whether the user should exit the app (double-back).
//   bool get shouldPopNow {
//     if (selectedIndex.value != 0) return false;
//     final now = DateTime.now();
//     if (_lastBackPressTime == null ||
//         now.difference(_lastBackPressTime!) > doublePressExitInterval) {
//       _lastBackPressTime = now;
//       return false;
//     }
//     return true;
//   }
//
//   /// Call when back is pressed; returns true if the app should pop/exit.
//   bool onBackPressed() => shouldPopNow;
//
//   /// Loads vendor from API and updates state. Alias for [loadVendor] for existing callers (e.g. refresh).
//   Future<void> getVendor() => loadVendor();
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Private
//   // ─────────────────────────────────────────────────────────────────────────
//
//   void _loadVendor() {
//     loadVendor();
//   }
//
//   void _buildPageList() {
//     pageList.value = [
//       const HomeScreen(),
//       const ProductListScreen(),
//       const SalesReportScreen(),
//       const ProfileScreen(),
//     ];
//   }
//
//   void _checkMandatoryUpdate() {
//     try {
//       Get.find<AppUpdateController>().checkMandatoryUpdateForLoggedInUser();
//     } catch (_) {}
//   }
// }




import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jippymart_restaurant/app/Home_screen/home_screen.dart';
import 'package:jippymart_restaurant/app/dash_board_screens/sales_report_screen.dart';
import 'package:jippymart_restaurant/app/product_screens/product_list_screen.dart';
import 'package:jippymart_restaurant/app/profile_screen/profile_screen.dart';
import 'package:jippymart_restaurant/config/app_config.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/app_update_controller.dart';
import 'package:jippymart_restaurant/controller/product_list_controller.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

import '../app/merchant_outlet_list_screen.dart';
import '../app/profile_screen/subscription_plans_screen.dart';
import '../utils/const/image_const.dart';
import 'merchant_outlet_controller.dart';
import 'sales_report_controller.dart';
import 'package:jippymart_restaurant/controller/profile_controller.dart';
import 'package:jippymart_restaurant/models/bottom_nav_item.dart';
/// Closure duration the restaurant owner selects when closing.
enum RestaurantCloseOption { today, threeDays, sevenDays, untilReopened, tomorrow, custom }

/// Controller for the main dashboard.
///
/// Responsibilities:
///  - Vendor open/closed state (persisted across restarts)
///  - Bottom-nav tab selection
///  - Double-back-to-exit logic
///  - Mandatory update checks on resume
class DashBoardController extends GetxController with WidgetsBindingObserver {
  // ── Constants ──────────────────────────────────────────────────────────────
  static const Duration _exitWindow = Duration(seconds: 2);

  // ── Observables ────────────────────────────────────────────────────────────
  final RxInt selectedIndex = 0.obs;
  final RxList<Widget> pageList = <Widget>[].obs;
  final Rx<VendorModel> vendorModel = VendorModel().obs;

  /// Reactive mirror of [Preferences] outletId — drives list vs outlet dashboard UI.
  final RxInt activeOutletId = 0.obs;

  /// True while a status-update API call is in flight – prevents double-taps.
  final RxBool isUpdatingStatus = false.obs;

  /// Bumped when user re-enters the Plans tab so promotions UI resets.
  final RxInt promotionsTabResetToken = 0.obs;

  static const int plansTabIndex = 2;

  // ── Private state ──────────────────────────────────────────────────────────
  DateTime? _lastBackPress;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    activeOutletId.value = Preferences.getInt('outletId');
    _ensureMerchantSession();
    _buildPageList();
    _restoreOpenState();
    loadVendor();
    _checkUpdate();
    _applyInitialTab();
  }

  void _applyInitialTab() {
    if (!_isOutletSession()) return;

    if (Preferences.getString('loginType') == 'OUTLET') {
      selectedIndex.value = 0;
      debugPrint('[Dashboard] Outlet login — opening Home tab for outlet session');
      return;
    }

    // selectedIndex.value = 0;
    // debugPrint('[Dashboard] Merchant outlet selected — opening home tab');
  }

  /// Ensures merchant session starts once on cold start (not after login).
  void _ensureMerchantSession() {
    if (Preferences.getString('loginType') != 'MERCHANT') return;

    if (!Get.isRegistered<MerchantOutletController>()) {
      Get.put(MerchantOutletController(), permanent: true);
    }

    final outletCtrl = Get.find<MerchantOutletController>();
    if (outletCtrl.sessionState.value == MerchantSessionState.initial) {
      outletCtrl.initializeMerchantSession();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkUpdate();
  }

  // ── Pages ──────────────────────────────────────────────────────────────────
  // void _buildPageList() {
  //   pageList.value = const [
  //     HomeScreen(),
  //     ProductListScreen(),
  //     SalesReportScreen(),
  //     ProfileScreen(),
  //   ];
  // }
  void _buildPageList({int? outletIdOverride}) {
    final loginType = Preferences.getString('loginType');
    final outletId = outletIdOverride ?? activeOutletId.value;
    final isOutletSession = loginType == 'OUTLET' || outletId > 0;

    print("=================================");
    print("BUILD PAGE LIST CALLED");
    print("LOGIN TYPE = $loginType outletId = $outletId");
    print("isOutletSession = $isOutletSession");
    print("=================================");

    if (isOutletSession) {
      // Keep merchant outlet cache when a merchant opens an outlet dashboard.
      if (loginType != 'MERCHANT' &&
          Get.isRegistered<MerchantOutletController>()) {
        Get.delete<MerchantOutletController>(force: true);
      }
      pageList.value = [
        HomeScreen(),
        const ProductListScreen(),
        const SubscriptionPlansScreen(showBackButton: false),
        const SalesReportScreen(),
        const ProfileScreen(),
      ];
      pageList.refresh();
      return;
    }

    if (loginType == 'MERCHANT') {
      if (!Get.isRegistered<MerchantOutletController>()) {
        Get.put(MerchantOutletController(), permanent: true);
      }
      pageList.value = [
        MerchantOutletListScreen(),
        const MerchantSelectOutletPromptScreen(),
        const SubscriptionPlansScreen(showBackButton: false),
        const SalesReportScreen(),
        const ProfileScreen(),
      ];
      pageList.refresh();
      return;
    }

    pageList.value = [
      HomeScreen(),
      const ProductListScreen(),
      const SubscriptionPlansScreen(showBackButton: false),
      const SalesReportScreen(),
      const ProfileScreen(),
    ];
    pageList.refresh();
  }

  bool _isOutletSession() {
    return Preferences.getString('loginType') == 'OUTLET' ||
        activeOutletId.value > 0;
  }

  /// Merchant logged in but has not opened an outlet dashboard yet.
  bool get isMerchantListMode =>
      Preferences.getString('loginType') == 'MERCHANT' &&
      activeOutletId.value <= 0;

  /// Merchant viewing a selected outlet's dashboard.
  bool get isMerchantOutletDashboard =>
      Preferences.getString('loginType') == 'MERCHANT' &&
      activeOutletId.value > 0;

  /// Call when bottom-nav switches to Plans from another tab.
  void resetPromotionsQuickAction() {
    promotionsTabResetToken.value++;
  }

  bool get isMerchantWithoutOutlets {
    if (Preferences.getString('loginType') != 'MERCHANT') {
      return false;
    }

    if (!Get.isRegistered<MerchantOutletController>()) {
      return false;
    }

    final controller = Get.find<MerchantOutletController>();

    return controller.outletList.isEmpty;
  }

  /// Open/closed toggle: outlet dashboard, outlet login, or merchant with no outlets.
  /// Hidden only on the merchant outlet list when outlets exist.
  bool get showStatusBanner {
    if (!isMerchantListMode) return true;

    if (!Get.isRegistered<MerchantOutletController>()) return true;

    final outletCtrl = Get.find<MerchantOutletController>();
    if (outletCtrl.sessionState.value == MerchantSessionState.hasOutlets) {
      return false;
    }
    if (outletCtrl.sessionState.value == MerchantSessionState.empty) {
      return true;
    }
    // loading / initial — show toggle only when no outlets are cached yet
    return outletCtrl.outletList.isEmpty;
  }
  void switchToOutletMode() {
    final outletId = Preferences.getInt('outletId');
    _buildPageList(outletIdOverride: outletId);
    selectedIndex.value = 0;
    activeOutletId.value = outletId;
    _refreshSalesReport();
    _refreshProductInventory(outletId);
    _refreshProfile();
    debugPrint(
      '[Dashboard] Switched to outlet dashboard — outletId=$outletId',
    );
  }

  /// Reload Items tab from Java getOutletDetails after outlet is selected.
  void _refreshProductInventory(int outletId) {
    FireStoreUtils.invalidateOutletProductCache(outletId);
    if (!Get.isRegistered<ProductListController>()) {
      Get.put(ProductListController(), permanent: true);
    }
    final productCtrl = Get.find<ProductListController>();
    productCtrl.prepareForOutletSwitch(outletId);
    productCtrl.refreshInventory(forceRefresh: true, outletId: outletId);
  }

  Future<void> switchToMerchantMode() async {
    await Preferences.setInt('outletId', 0);
    await Preferences.setInt('selectedOutletId', 0);
    if (Get.isRegistered<ProductListController>()) {
      Get.find<ProductListController>().clearOutletInventoryState();
    }
    if (Get.isRegistered<MerchantOutletController>()) {
      final outletCtrl = Get.find<MerchantOutletController>();
      await outletCtrl.exitOutletDashboard();
      outletCtrl.restoreListStateIfNeeded();
    }
    selectedIndex.value = 0;
    // Build merchant list pages before activeOutletId changes so IndexedStack
    // never briefly shows HomeScreen "Add your first outlet" during transition.
    _buildPageList(outletIdOverride: 0);
    activeOutletId.value = 0;
    _refreshSalesReport();
    _refreshProfile();
    debugPrint('[Dashboard] Switched to merchant outlet list mode');
  }

  void _refreshSalesReport() {
    if (Get.isRegistered<SalesReportController>()) {
      Get.find<SalesReportController>().fetchReport(forceRefresh: true);
    }
  }
  void _refreshProfile() {
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().getUserProfile();
    }
  }
  /// Bottom navigation items.
  List<BottomNavItem> getNavItems() {
    if (Constant.isDineInEnable) {
      return  [
        BottomNavItem(
          id: BottomNavId.home,
          icon: ImageConst.homeIcon,
          label: 'Home',
        ),
        BottomNavItem(
          id: BottomNavId.dineIn,
          icon: 'assets/icons/ic_dinein.svg',
          label: 'Dine In',
        ),
        BottomNavItem(
          id: BottomNavId.inventory,
          icon: ImageConst.products,
          label: 'Inventory',
        ),
        BottomNavItem(
          id: BottomNavId.subscription,
          icon: ImageConst.subscription,
          label: 'Promotions',
        ),
        BottomNavItem(
          id: BottomNavId.sales,
          icon: ImageConst.report,
          label: 'Report',
        ),
        BottomNavItem(
          id: BottomNavId.profile,
          icon: ImageConst.profile,
          label: 'Profile',
        ),
      ];
    }

    return  [
      BottomNavItem(
        id: BottomNavId.home,
        icon: ImageConst.homeIcon,
        label: 'Home',
      ),
      BottomNavItem(
        id: BottomNavId.inventory,
        icon: ImageConst.products,
        label: 'Items',
      ),
      BottomNavItem(
        id: BottomNavId.subscription,
        icon: ImageConst.subscription,
        label: 'Promotions',
      ),
      BottomNavItem(
        id: BottomNavId.sales,
        icon: ImageConst.report,
        label: 'Sales',
      ),
      BottomNavItem(
        id: BottomNavId.profile,
        icon: ImageConst.profile,
        label: 'Profile',
      ),
    ];
  }
  // ── Vendor ─────────────────────────────────────────────────────────────────

  /// Immediately applies the last-persisted open/closed value so the UI
  /// never flashes "Closed" while the network request is in flight.
  void _restoreOpenState() {
    try {
      final saved = Preferences.getBoolean(Preferences.vendorIsOpenKey);
      vendorModel.value =
          vendorModel.value.copyWith(isOpen: saved, reststatus: saved);
    } catch (_) {}
  }

  /// Fetches fresh vendor data from Firestore and merges it with local state.
  Future<void> loadVendor() async {
    final vendorId = Constant.userModel?.vendorID;
    if (vendorId == null || vendorId.isEmpty) return;

    _log('loadVendor id=$vendorId');
    try {
      final fresh =
          await FireStoreUtils.getVendorById(vendorId, forceRefresh: true);
      if (fresh == null) return;

      Constant.vendorAdminCommission = fresh.adminCommission;
      fresh.id ??= vendorId;

      // Prefer server value; fall back to persisted pref if server omits it.
      final isOpen =
          fresh.isOpen ?? Preferences.getBoolean(Preferences.vendorIsOpenKey);
      fresh
        ..isOpen = isOpen
        ..reststatus = isOpen;

      await Preferences.setBoolean(Preferences.vendorIsOpenKey, isOpen);

      // Persist vendor's zone id so other features (e.g. subscriptions)
      // can resolve it without reloading the vendor every time.
      final zoneId = fresh.zoneId?.toString().trim();
      if (zoneId != null && zoneId.isNotEmpty) {
        await Preferences.setString(VendorModel.zoneIdPrefKey, zoneId);
      }

      vendorModel
        ..value = fresh
        ..refresh();
    } catch (e) {
      _log('loadVendor error: $e');
    }
  }

  /// Public alias kept for callers such as [HomeController.refreshApp].
  Future<void> getVendor() => loadVendor();

  /// Pushes an open/closed status change to Firestore.
  /// Returns `true` on success, `false` on any failure.
  // Future<bool> updateRestStatus(bool open) async {
  //   if (isUpdatingStatus.value) return false;
  //
  //   final vendorId = Constant.userModel?.vendorID;
  //   if (vendorId == null || vendorId.isEmpty) {
  //     _log('updateRestStatus: no vendorId');
  //     return false;
  //   }
  //
  //   isUpdatingStatus.value = true;
  //   try {
  //     // Always fetch latest before writing to avoid overwriting concurrent changes.
  //     final latest =
  //     await FireStoreUtils.getVendorById(vendorId, forceRefresh: true);
  //     if (latest == null) return false;
  //
  //     latest
  //       ..id ??= vendorId
  //       ..isOpen = open
  //       ..reststatus = open;
  //
  //     final saved = await FireStoreUtils.updateVendor(latest);
  //     if (saved == null) return false;
  //
  //     await Preferences.setBoolean(Preferences.vendorIsOpenKey, open);
  //     vendorModel
  //       ..value = saved
  //       ..refresh();
  //     return true;
  //   } catch (e) {
  //     _log('updateRestStatus error: $e');
  //     return false;
  //   } finally {
  //     isUpdatingStatus.value = false;
  //   }
  // }
  // Future<bool> updateRestStatus(bool open) async {
  //   if (isUpdatingStatus.value) return false;
  //
  //   final vendorId = Constant.userModel?.vendorID;
  //   if (vendorId == null || vendorId.isEmpty) {
  //     print("No vendorId");
  //     return false;
  //   }
  //
  //   isUpdatingStatus.value = true;
  //
  //   try {
  //     final latest = await FireStoreUtils.getVendorById(
  //       vendorId,
  //       forceRefresh: true,
  //     );
  //
  //     print("Latest Vendor = $latest");
  //
  //     if (latest == null) {
  //       print("Latest vendor is null");
  //       return false;
  //     }
  //
  //     latest.isOpen = open;
  //     latest.reststatus = open;
  //
  //     print("Before updateVendor");
  //
  //     final saved = await FireStoreUtils.updateVendor(latest);
  //
  //     print("Saved Vendor = $saved");
  //
  //     if (saved == null) {
  //       print("updateVendor returned null");
  //       return false;
  //     }
  //
  //     await Preferences.setBoolean(
  //       Preferences.vendorIsOpenKey,
  //       open,
  //     );
  //
  //     vendorModel.value = saved;
  //     vendorModel.refresh();
  //
  //     return true;
  //   } catch (e) {
  //     print("updateRestStatus Error = $e");
  //     return false;
  //   } finally {
  //     isUpdatingStatus.value = false;
  //   }
  // }
  /// Active outlet id for open/close APIs — from dashboard session or preferences.
  static int resolveActiveOutletId() {
    if (Get.isRegistered<DashBoardController>()) {
      final sessionId = Get.find<DashBoardController>().activeOutletId.value;
      if (sessionId > 0) return sessionId;
    }

    final outletId = Preferences.getInt('outletId');
    if (outletId > 0) return outletId;

    return Preferences.getInt('selectedOutletId');
  }

  static Future<bool> updateOutletUnavailability({
    required String type,
    required int unavailabilityId,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    // OUTLET close — POST /api/fm/outlet-unavailability (type=OUTLET, id=outletId)
    return FireStoreUtils.postOutletItemUnavailability(
      type: type,
      unavailabilityId: unavailabilityId,
      reason: reason,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
  // ── Navigation ─────────────────────────────────────────────────────────────

  /// Call from [PopScope.onPopInvokedWithResult].
  /// - Merchant outlet dashboard on Home → back to outlet list.
  /// - On a non-root tab → jumps back to tab 0, returns `false`.
  /// - On tab 0, first press → records timestamp, returns `false` (show hint).
  /// - On tab 0, second press within [_exitWindow] → returns `true` (exit).
  bool onBackPressed() {
    if (isMerchantOutletDashboard) {
      if (selectedIndex.value != 0) {
        selectedIndex.value = 0;
        return false;
      }
      switchToMerchantMode();
      return false;
    }

    if (selectedIndex.value != 0) {
      selectedIndex.value = 0;
      return false;
    }
    final now = DateTime.now();
    final isSecondPress = _lastBackPress != null &&
        now.difference(_lastBackPress!) <= _exitWindow;
    _lastBackPress = now;
    return isSecondPress;
  }

  // ── Private helpers ────────────────────────────────────────────────────────
  void _checkUpdate() {
    try {
      Get.find<AppUpdateController>().checkMandatoryUpdateForLoggedInUser();
    } catch (_) {}
  }

  void _log(String msg) {
    if (AppConfig.enableDebugLogs) debugPrint('DashBoardController.$msg');
  }
}