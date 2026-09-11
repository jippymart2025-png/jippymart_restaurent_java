


import 'dart:convert';

import 'package:bottom_picker/resources/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:jippymart_restaurant/app/add_restaurant_screen/add_restaurant_screen.dart';
import 'package:jippymart_restaurant/app/product_rating_view_screen/product_rating_view_screen.dart';
import 'package:jippymart_restaurant/app/verification_screen/verification_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/send_notification.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/home_controller.dart';
import 'package:jippymart_restaurant/models/cart_product_model.dart';
import 'package:jippymart_restaurant/models/order_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/wallet_transaction_model.dart';
import 'package:jippymart_restaurant/service/audio_player_service.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:jippymart_restaurant/widget/my_separator.dart';

import '../../controller/merchant_outlet_controller.dart';
import '../../utils/preferences.dart';



// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late HomeController controller;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    if (Get.isRegistered<HomeController>()) {
      controller = Get.find<HomeController>();
      controller.resumeOrderPolling();
    } else {
      controller = Get.put(HomeController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSelectedOutlet();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      controller
        ..resumeOrderPolling()
        ..getOrder(silent: false);
    }
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────
  static const List<String> _tabLabels = [
    'New', 'Accepted', 'Completed', 'Rejected', 'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<HomeController>(
      init: controller,
      builder: (ctrl) {
        if (ctrl.isLoading.value) return Constant.loader();

        return DefaultTabController(
          length: _tabLabels.length,
          child: Scaffold(
            appBar: _buildAppBar(themeChange, ctrl),
            body: _buildBody(themeChange, ctrl, context),
          ),
        );
      },
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      DarkThemeProvider themeChange, HomeController ctrl) {
    debugPrint(
      'OUTLET PIC URL: ${controller.outletModel.value.outletPicUrl}',
    );
    return AppBar(

      backgroundColor: ColorConst.orange,
      centerTitle: false,
      title: Row(
        children: [

          Obx(() {
            final picUrl = controller.outletModel.value.outletPicUrl ?? '';
            return ClipOval(
              child: picUrl.isNotEmpty
                  ? NetworkImageWidget(
                      imageUrl: picUrl,
                      height: 42,
                      width: 42,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      Constant.userPlaceHolder,
                      height: 42,
                      width: 42,
                      fit: BoxFit.cover,
                    ),
            );
          }),

          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 270,
                child: RichText(
                  maxLines: 1,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome to '.tr,
                        style: const TextStyle(
                          color: AppThemeData.grey50,
                          fontSize: 18,
                          fontFamily: AppThemeData.bold,
                        ),
                      ),
                      TextSpan(
                        text: Preferences.getString('selectedOutletName').isNotEmpty
                            ? Preferences.getString('selectedOutletName')
                            : (ctrl.vendermodel.value.title ?? 'Restaurant'),
                        style: const TextStyle(
                          color: AppThemeData.grey50,
                          fontSize: 18,
                          fontFamily: AppThemeData.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                ctrl.userModel.value.fullName(),
                style: const TextStyle(
                  color: AppThemeData.grey50,
                  fontSize: 16,
                  fontFamily: AppThemeData.semiBold,
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: TabBar(
        onTap: (i) => ctrl.selectedTabIndex.value = i,
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        labelPadding: const EdgeInsets.symmetric(horizontal: 20),
        labelStyle:
        const TextStyle(fontFamily: AppThemeData.semiBold),
        labelColor: AppThemeData.grey50,
        unselectedLabelStyle:
        const TextStyle(fontFamily: AppThemeData.medium),
        unselectedLabelColor: const Color(0xFFD5DBDB),
        indicatorColor: AppThemeData.secondary300,
        dividerColor: Colors.transparent,
        tabs: _tabLabels
            .map((t) => Tab(text: t.tr))
            .toList(),
      ),
      actions: const [
        // Chat icon hidden (visible: false) – kept for future use
        SizedBox.shrink(),
      ],
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────
  Widget _buildBody(DarkThemeProvider themeChange, HomeController ctrl,
      BuildContext context) {
    // Not verified — backend merchant/outlet approval takes priority
    if (!MerchantOutletController.isCurrentSessionApproved ||
        (Constant.isRestaurantVerification == true &&
            ctrl.userModel.value.isDocumentVerify == false)) {
      return _EmptyStateView(
        icon: 'assets/icons/ic_document.svg',
        title: 'Document Verification in Pending'.tr,
        subtitle:
        'Your documents are being reviewed. We will notify you once the verification is complete.'
            .tr,
        buttonLabel: 'View Status'.tr,
        onTap: () => Get.to(const VerificationScreen()),
        themeChange: themeChange,
      );
    }

    // No restaurant linked
    // if (ctrl.userModel.value.vendorID == null ||
    //     ctrl.userModel.value.vendorID!.isEmpty) {
    //   return _EmptyStateView(
    //     icon: 'assets/icons/ic_building_two.svg',
    //     title: 'Add Your First Outlet'.tr,
    //     subtitle:
    //     'Get started by adding your outlet details to manage your menu, orders, and reservations.'
    //         .tr,
    //     buttonLabel: 'Add Outlet'.tr,
    //     onTap: () async {
    //       final result = await Get.to(const AddRestaurantScreen());
    //       if (result == true) ctrl.getUserProfile();
    //     },
    //     themeChange: themeChange,
    //   );
    // }
    final outletId = Preferences.getInt('outletId');
    if (ctrl.outletList.isEmpty && outletId <= 0) {
      return _EmptyStateView(
        icon: 'assets/icons/ic_building_two.svg',
        title: 'Add Your First Outlet'.tr,
        subtitle:
        'Get started by adding your outlet details to manage your menu, orders, and reservations.'
            .tr,
        buttonLabel: 'Add Outlet'.tr,
        onTap: () async {
          final result = await Get.to(
            const AddRestaurantScreen(),
          );

          if (result == true) {
            if (Get.isRegistered<MerchantOutletController>()) {
              await Get.find<MerchantOutletController>().refreshOutletsOnly();
            }
          }
        },
        themeChange: themeChange,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TabBarView(
        children: [
          _OrderTab(
            orders: ctrl.newOrderList,
            emptyMessage: ' Waiting For New Orders'.tr,
            onRefresh: () => ctrl.refreshApp(),
            itemBuilder: (order) => _NewOrderCard(
              orderModel: order,
              controller: ctrl,
              themeChange: themeChange,
              context: context,
              onEstimatedTimePicked: _showDurationPicker,
            ),
          ),
          _OrderTab(
            orders: ctrl.acceptedOrderList,
            emptyMessage: 'Accepted Orders Not found'.tr,
            onRefresh: () => ctrl.refreshApp(),
            itemBuilder: (order) => _AcceptedOrderCard(
              orderModel: order,
              controller: ctrl,
              themeChange: themeChange,
              context: context,
            ),
          ),
          _OrderTab(
            orders: ctrl.completedOrderList,
            emptyMessage: 'Completed Orders Not found'.tr,
            onRefresh: () => ctrl.refreshApp(),
            itemBuilder: (order) => _ClosedOrderCard(
              orderModel: order,
              themeChange: themeChange,
              context: context,
              controller: ctrl,
            ),
          ),
          _OrderTab(
            orders: ctrl.rejectedOrderList,
            emptyMessage: 'Rejected Orders Not found'.tr,
            onRefresh: () => ctrl.refreshApp(),
            itemBuilder: (order) => _ClosedOrderCard(
              orderModel: order,
              themeChange: themeChange,
              context: context,
              controller: ctrl,
            ),
          ),
          _OrderTab(
            orders: ctrl.cancelledOrderList,
            emptyMessage: 'Cancelled Orders Not found'.tr,
            onRefresh: () => ctrl.refreshApp(),
            itemBuilder: (order) => _ClosedOrderCard(
              orderModel: order,
              themeChange: themeChange,
              context: context,
              controller: ctrl,
            ),
          ),
        ],
      ),
    );
  }

  // ── Duration picker helpers ───────────────────────────────────────────────
  Future<void> _showDurationPicker(
      BuildContext context, HomeController ctrl) async {
    Duration initial = const Duration(minutes: 10);
    final text = ctrl.estimatedTimeController.value.text.trim();
    if (text.isNotEmpty) {
      final minuteMatch =
      RegExp(r'(\d+)\s*(?:minutes?|min)', caseSensitive: false)
          .firstMatch(text);
      if (minuteMatch != null) {
        initial = Duration(
            minutes:
            (int.tryParse(minuteMatch.group(1) ?? '') ?? 10).clamp(1, 2400));
      } else {
        final parts = text.split(':');
        if (parts.length == 2) {
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          initial = Duration(minutes: (h * 60 + m).clamp(1, 2400));
        } else {
          initial = Duration(minutes: (int.tryParse(text) ?? 10).clamp(1, 2400));
        }
      }
    }

    final picked = await showModalBottomSheet<Duration>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DurationPickerBottomSheet(initialDuration: initial),
    );
    if (picked != null) _applyDuration(picked, ctrl);
  }

  void _applyDuration(Duration d, HomeController ctrl) {
    String pad(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    ctrl.estimatedTimeController.value.text =
    h == 0 ? '${d.inMinutes} minutes' : '$h:${pad(m)}';
    ctrl.estimatedTimeController.refresh();
  }
  Future<void> loadSelectedOutlet() async {
    if (Preferences.getInt('outletId') <= 0) return;

    final selectedOutletId = Preferences.getInt('selectedOutletId');
    if (selectedOutletId > 0) {
      await controller.loadOutletData(selectedOutletId);
    }
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Generic tab wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _OrderTab extends StatelessWidget {
  final RxList<OrderModel> orders;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final Widget Function(OrderModel) itemBuilder;

  const _OrderTab({
    required this.orders,
    required this.emptyMessage,
    required this.onRefresh,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => RefreshIndicator(
      onRefresh: onRefresh,
      child: orders.isEmpty
          ? SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Constant.showEmptyView(message: emptyMessage),
        ),
      )
          : ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: orders.length,
        itemBuilder: (_, i) => itemBuilder(orders[i]),
      ),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state widget
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyStateView extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;
  final DarkThemeProvider themeChange;

  const _EmptyStateView({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
    required this.themeChange,
  });

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
                  borderRadius: BorderRadius.circular(120)),
            ),
            padding: const EdgeInsets.all(20),
            child: SvgPicture.asset(icon),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
              fontSize: 22,
              fontFamily: AppThemeData.semiBold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppThemeData.grey50 : AppThemeData.grey500,
              fontSize: 16,
              fontFamily: AppThemeData.bold,
            ),
          ),
          const SizedBox(height: 20),
          RoundedButtonFill(
            title: buttonLabel,
            width: 55,
            height: 5.5,
            color: AppThemeData.secondary300,
            textColor: AppThemeData.grey50,
            onPress: onTap,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared order card shell
// ─────────────────────────────────────────────────────────────────────────────
class _OrderCardShell extends StatelessWidget {
  final DarkThemeProvider themeChange;
  final List<Widget> children;

  const _OrderCardShell({
    required this.themeChange,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: ShapeDecoration(
          color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Customer row (avatar + name + address)
// ─────────────────────────────────────────────────────────────────────────────
class _CustomerRow extends StatelessWidget {
  final OrderModel orderModel;
  final DarkThemeProvider themeChange;

  const _CustomerRow({required this.orderModel, required this.themeChange});

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Row(
      children: [
        ClipOval(
          child: NetworkImageWidget(
            imageUrl: orderModel.author?.profilePictureURL ?? '',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderModel.author?.fullName() ?? '',
                style: TextStyle(
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                  fontSize: 14,
                  fontFamily: AppThemeData.semiBold,
                ),
              ),
              Text(
                orderModel.takeAway == true
                    ? 'Take Away'.tr
                    : orderModel.id ?? '',
                style: TextStyle(
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                  fontSize: 14,
                  fontFamily: AppThemeData.medium,
                ),
              ),
            ],
          ),
        ),
        // const Icon(Icons.chevron_right),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product list (items + variants + addons)
// ─────────────────────────────────────────────────────────────────────────────
class _ProductList extends StatelessWidget {
  final OrderModel orderModel;
  final DarkThemeProvider themeChange;
  final bool showViewRatings;

  const _ProductList({
    required this.orderModel,
    required this.themeChange,
    this.showViewRatings = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    final products = orderModel.products ?? const <CartProductModel>[];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: MySeparator(
          color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
        ),
      ),
      itemBuilder: (_, i) =>
          _ProductItem(
            product: products[i],
            orderModel: orderModel,
            themeChange: themeChange,
            showViewRatings: showViewRatings,
          ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final CartProductModel product;
  final OrderModel orderModel;
  final DarkThemeProvider themeChange;
  final bool showViewRatings;

  const _ProductItem({
    required this.product,
    required this.orderModel,
    required this.themeChange,
    this.showViewRatings = false,
  });

  String get _priceText {
    final price = double.tryParse(product.merchant_price ?? '0') ?? 0;
    final qty = double.tryParse(product.quantity?.toString() ?? '1') ?? 1;
    return Constant.amountShow(amount: (price * qty).toString());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${product.quantity}x ${product.name}'.tr,
                style: TextStyle(
                  color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppThemeData.semiBold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _priceText,
                  style: TextStyle(
                    color:
                    isDark ? AppThemeData.grey100 : AppThemeData.grey800,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppThemeData.semiBold,
                  ),
                ),
                if (showViewRatings)
                  GestureDetector(
                    onTap: () => Get.to(
                      const ProductRatingViewScreen(),
                      arguments: {
                        'orderModel': orderModel,
                        'productId': product.id,
                      },
                    ),
                    child: Text(
                      'View Ratings'.tr,
                      style:  TextStyle(
                        color: AppThemeData.secondary300,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        fontFamily: AppThemeData.semiBold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (product.variantInfo?.variantOptions?.isNotEmpty == true)
          _VariantChips(product: product, themeChange: themeChange),
        if (product.extras?.isNotEmpty == true)
          _AddonChips(product: product, themeChange: themeChange),
      ],
    );
  }
}

class _VariantChips extends StatelessWidget {
  final CartProductModel product;
  final DarkThemeProvider themeChange;

  const _VariantChips(
      {required this.product, required this.themeChange});

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    final options = product.variantInfo!.variantOptions!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variants'.tr,
            style: TextStyle(
              fontFamily: AppThemeData.semiBold,
              color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: options.keys
                .where((key) => key != 'merchant_price')
                .map((key) {
              return _Chip(
                label: '$key : ${options[key]}',
                themeChange: themeChange,
              );
            }).toList(),
          ),        ],
      ),
    );
  }
}

class _AddonChips extends StatelessWidget {
  final CartProductModel product;
  final DarkThemeProvider themeChange;

  const _AddonChips(
      {required this.product, required this.themeChange});

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    final qty = double.tryParse(product.quantity?.toString() ?? '1') ?? 1;
    final extrasTotal =
        double.tryParse(product.extrasPrice?.toString() ?? '0') ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Addons'.tr,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              Constant.amountShow(amount: (extrasTotal * qty).toString()),
              style:  TextStyle(
                fontFamily: AppThemeData.semiBold,
                color: AppThemeData.secondary300,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: product.extras!
              .map((e) =>
              _Chip(label: e.toString(), themeChange: themeChange))
              .toList(),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final DarkThemeProvider themeChange;

  const _Chip({required this.label, required this.themeChange});

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Container(
      decoration: ShapeDecoration(
        color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppThemeData.medium,
          color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared footer rows (order date, admin commission, remarks)
// ─────────────────────────────────────────────────────────────────────────────
class _OrderMetaRows extends StatelessWidget {
  final OrderModel orderModel;
  final DarkThemeProvider themeChange;
  final double adminCommission;
  final HomeController controller;
  final BuildContext parentContext;

  const _OrderMetaRows({
    required this.orderModel,
    required this.themeChange,
    required this.adminCommission,
    required this.controller,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _LabelValue(
          label: 'Order Date'.tr,
          value: Constant.timestampToDateTime(orderModel.createdAt ?? ''),
          themeChange: themeChange,
        ),
        if (Constant.adminCommission?.isEnabled == true) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Admin Commissions'.tr,
                  style: TextStyle(
                    color:
                    isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                    fontSize: 16,
                    fontFamily: AppThemeData.regular,
                  ),
                ),
              ),
              Text(
                '-${Constant.amountShow(amount: adminCommission.toString())}',
                style: const TextStyle(
                  color: AppThemeData.danger300,
                  fontSize: 16,
                  fontFamily: AppThemeData.semiBold,
                ),
              ),
            ],
          ),
        ],
        if (orderModel.notes?.isNotEmpty == true)
          GestureDetector(
            onTap: () => showDialog(
              context: parentContext,
              builder: (_) => _RemarkDialog(
                controller: controller,
                themeChange: themeChange,
                orderModel: orderModel,
              ),
            ),
            child: Text(
              'View Remarks'.tr,
              style: TextStyle(
                fontFamily: AppThemeData.regular,
                decoration: TextDecoration.underline,
                color: isDark
                    ? AppThemeData.secondary300
                    : AppThemeData.secondary300,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final DarkThemeProvider themeChange;

  const _LabelValue(
      {required this.label,
        required this.value,
        required this.themeChange});

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
              fontSize: 16,
              fontFamily: AppThemeData.regular,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
            fontSize: 14,
            fontFamily: AppThemeData.semiBold,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calculation helper (pure function extracted from widgets)
// ─────────────────────────────────────────────────────────────────────────────
class _OrderTotals {
  final double subTotal;
  final double taxAmount;
  final double specialDiscount;
  final double adminCommission;
  final double totalAmount;

  _OrderTotals({
    required this.subTotal,
    required this.taxAmount,
    required this.specialDiscount,
    required this.adminCommission,
    required this.totalAmount,
  });

  factory _OrderTotals.from(OrderModel order) {
    double sub = 0, tax = 0, special = 0, admin = 0;
    final disc = double.tryParse(order.discount?.toString() ?? '0') ?? 0;

    for (final p in order.products ?? const []) {
      final price = double.tryParse(p.merchant_price?.toString() ?? '0') ?? 0;
      final qty = double.tryParse(p.quantity?.toString() ?? '1') ?? 1;
      final extras =
          double.tryParse(p.extrasPrice?.toString() ?? '0') ?? 0;
      sub += price * qty + extras * qty;
    }

    if (order.specialDiscount?['special_discount'] != null) {
      special = double.tryParse(
          order.specialDiscount!['special_discount'].toString()) ??
          0;
    }

    if (order.taxSetting != null) {
      for (final t in order.taxSetting!) {
        tax += Constant.calculateTax(
          amount:
          (sub - disc - special)
              .toString(),
          taxModel: t,
        );
      }
    }

    final total = sub - disc - special + tax;

    if (order.adminCommissionType == 'Percent' &&
        order.adminCommission != null) {
      final rate = double.tryParse(order.adminCommission!) ?? 0;
      admin = sub - sub / (1 + rate / 100);
    } else {
      admin = double.tryParse(order.adminCommission ?? '0') ?? 0;
    }

    return _OrderTotals(
      subTotal: sub,
      taxAmount: tax,
      specialDiscount: special,
      adminCommission: admin,
      totalAmount: total,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// New Order Card
// ─────────────────────────────────────────────────────────────────────────────
class _NewOrderCard extends StatelessWidget {
  final OrderModel orderModel;
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final BuildContext context;
  final Future<void> Function(BuildContext, HomeController)
  onEstimatedTimePicked;

  const _NewOrderCard({
    required this.orderModel,
    required this.controller,
    required this.themeChange,
    required this.context,
    required this.onEstimatedTimePicked,
  });

  @override
  Widget build(BuildContext ctx) {
    final totals = _OrderTotals.from(orderModel);

    return _OrderCardShell(
      themeChange: themeChange,
      children: [
        _CustomerRow(orderModel: orderModel, themeChange: themeChange),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: MySeparator(
            color: themeChange.getThem()
                ? AppThemeData.grey700
                : AppThemeData.grey200,
          ),
        ),
        _ProductList(
          orderModel: orderModel,
          themeChange: themeChange,
          showViewRatings: true,
        ),
        _OrderMetaRows(
          orderModel: orderModel,
          themeChange: themeChange,
          adminCommission: totals.adminCommission,
          controller: controller,
          parentContext: context,
        ),
        const SizedBox(height: 10),
        _NewOrderActions(
          orderModel: orderModel,
          totals: totals,
          controller: controller,
          themeChange: themeChange,
          context: context,
          onEstimatedTimePicked: onEstimatedTimePicked,
        ),
      ],
    );
  }
}

class _NewOrderActions extends StatelessWidget {
  final OrderModel orderModel;
  final _OrderTotals totals;
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final BuildContext context;
  final Future<void> Function(BuildContext, HomeController)
  onEstimatedTimePicked;

  const _NewOrderActions({
    required this.orderModel,
    required this.totals,
    required this.controller,
    required this.themeChange,
    required this.context,
    required this.onEstimatedTimePicked,
  });

  Future<void> _reject() async {
    ShowToastDialog.showLoader('Please wait...'.tr);
    await AudioPlayerService.playSound(false);
    orderModel.status = Constant.orderRejected;
    await FireStoreUtils.updateOrder(orderModel);

    if (orderModel.author?.fcmToken?.isNotEmpty == true) {
      SendNotification.sendFcmMessage(
        Constant.restaurantRejected,
        orderModel.author!.fcmToken!,
        {'orderId': orderModel.id ?? '', 'status': Constant.orderRejected},
      );
    }

    if (orderModel.paymentMethod?.toLowerCase() != 'cod') {
      final amount = totals.subTotal +
          (double.tryParse(orderModel.discount.toString()) ?? 0) +
          totals.specialDiscount +
          totals.taxAmount +
          (double.tryParse(orderModel.deliveryCharge.toString()) ?? 0) +
          (double.tryParse(orderModel.tipAmount.toString()) ?? 0);

      final tx = WalletTransactionModel(
        amount: amount,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: orderModel.author!.id,
        date: Timestamp.now(),
        isTopup: true,
        paymentMethod: 'Wallet',
        paymentStatus: 'success',
        note: 'Order Refund success',
        transactionUser: 'user',
      );
      await FireStoreUtils.setWalletTransaction(tx);
      await FireStoreUtils.updateUserWallet(
        amount: amount.toString(),
        userId: orderModel.author?.firebaseId ?? '',
      );
    }

    await controller.getOrder(silent: false);
    ShowToastDialog.closeLoader();
    Get.back();
  }

  void _openEstimatedDialog() {
    if (orderModel.scheduleTime != null) {
      final scheduled = Constant.checkScheduleTime(
          scheduleDate: orderModel.scheduleTime!.toDate());
      if (DateTime.now().isAtSameMomentOrAfter(scheduled)) {
        _showEstimatedDialog();
      } else {
        ShowToastDialog.showToast(
          '${'You can accept order on'.tr} ${Constant.timestampToDateTime(Timestamp.fromDate(scheduled))}.',
        );
      }
    } else {
      controller.driverUserList.clear();
      controller.selectDriverUser.value = UserModel();
      _showEstimatedDialog();
    }
  }

  void _showEstimatedDialog() {
    showDialog(
      context: context,
      builder: (_) => _EstimatedTimeDialog(
        controller: controller,
        themeChange: themeChange,
        orderModel: orderModel,
        context: context,
        onPickDuration: onEstimatedTimePicked,
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    final isSelfDelivery = Constant.isSelfDeliveryFeature == true &&
        controller.vendermodel.value.isSelfDelivery == true &&
        orderModel.takeAway == false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: RoundedButtonFill(
              title: 'Reject'.tr,
              color: AppThemeData.new_primary,
              textColor: AppThemeData.grey50,
              height: 5,
              onPress: _reject,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RoundedButtonFill(
              title: isSelfDelivery ? 'Self Delivery'.tr : 'Accept'.tr,
              height: 5,
              color: isSelfDelivery
                  ? AppThemeData.success400
                  : AppThemeData.new_green_tog,
              textColor: AppThemeData.grey50,
              onPress: isSelfDelivery
                  ? _openEstimatedDialog
                  : () => showDialog(
                context: context,
                builder: (_) => _EstimatedTimeDialog(
                  controller: controller,
                  themeChange: themeChange,
                  orderModel: orderModel,
                  context: context,
                  onPickDuration: onEstimatedTimePicked,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Accepted Order Card
// ─────────────────────────────────────────────────────────────────────────────
class _AcceptedOrderCard extends StatelessWidget {
  final OrderModel orderModel;
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final BuildContext context;

  const _AcceptedOrderCard({
    required this.orderModel,
    required this.controller,
    required this.themeChange,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final totals = _OrderTotals.from(orderModel);

    return _OrderCardShell(
      themeChange: themeChange,
      children: [
        _CustomerRow(orderModel: orderModel, themeChange: themeChange),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: MySeparator(
            color: themeChange.getThem()
                ? AppThemeData.grey700
                : AppThemeData.grey200,
          ),
        ),
        _ProductList(orderModel: orderModel, themeChange: themeChange),
        _OrderMetaRows(
          orderModel: orderModel,
          themeChange: themeChange,
          adminCommission: totals.adminCommission,
          controller: controller,
          parentContext: context,
        ),
        const SizedBox(height: 10),
        _AcceptedOrderActions(
          orderModel: orderModel,
          totals: totals,
          controller: controller,
          themeChange: themeChange,
          context: context,
        ),
      ],
    );
  }
}

class _AcceptedOrderActions extends StatelessWidget {
  final OrderModel orderModel;
  final _OrderTotals totals;
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final BuildContext context;

  const _AcceptedOrderActions({
    required this.orderModel,
    required this.totals,
    required this.controller,
    required this.themeChange,
    required this.context,
  });

  Future<void> _cancelOrder() async {
    final userId = await FireStoreUtils.getCurrentUid();
    ShowToastDialog.showLoader('Please wait...'.tr);
    await AudioPlayerService.playSound(false);

    orderModel.status = Constant.orderCancelled;

    if (orderModel.driverID != null) {
      final driver =
      await FireStoreUtils.getUserById(orderModel.driverID ?? '');
      if (driver != null) {
        // driver.orderRequestData?.remove(orderModel.id);
        // driver.inProgressOrderID?.remove(orderModel.id);
        await FireStoreUtils.updateDriverUser(driver);
        if (driver.fcmToken?.isNotEmpty == true) {
          SendNotification.sendFcmMessage(
            Constant.driverCancelled,
            driver.fcmToken!,
            {'title': 'Cancelled Order'},
          );
        }
      }
    }

    await FireStoreUtils.updateOrder(orderModel);

    if (orderModel.author?.fcmToken?.isNotEmpty == true) {
      SendNotification.sendFcmMessage(
        Constant.restaurantCancelled,
        orderModel.author!.fcmToken!,
        {'orderId': orderModel.id ?? '', 'status': Constant.orderCancelled},
      );
    }

    if (orderModel.paymentMethod?.toLowerCase() != 'cod') {
      final refund = totals.subTotal +
          (double.tryParse(orderModel.discount.toString()) ?? 0) +
          totals.specialDiscount +
          totals.taxAmount +
          (double.tryParse(orderModel.deliveryCharge.toString()) ?? 0) +
          (double.tryParse(orderModel.tipAmount.toString()) ?? 0);

      await FireStoreUtils.setWalletTransaction(WalletTransactionModel(
        amount: refund,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: orderModel.author!.id,
        date: Timestamp.now(),
        isTopup: true,
        paymentMethod: 'Wallet',
        paymentStatus: 'success',
        note: 'Order Refund success',
        transactionUser: 'user',
      ));
      await FireStoreUtils.updateUserWallet(
        amount: refund.toString(),
        userId: orderModel.author?.id ?? '',
      );
    }

    // Vendor wallet debit
    final disc = double.tryParse(orderModel.discount.toString()) ?? 0;
    final adminCommission = orderModel.adminCommission;
    double vendorAmount;
    if (adminCommission != null &&
        adminCommission != '0' &&
        adminCommission.isNotEmpty) {
      vendorAmount = (totals.subTotal /
          (1 + double.tryParse(adminCommission)! / 100)) -
          disc -
          totals.specialDiscount;
    } else {
      vendorAmount = totals.subTotal - disc - totals.specialDiscount;
    }

    await Future.wait([
      FireStoreUtils.setWalletTransaction(WalletTransactionModel(
        amount: totals.taxAmount,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: userId,
        date: Timestamp.now(),
        isTopup: false,
        paymentMethod: 'tax',
        paymentStatus: 'success',
        note: 'Tax Amount Refund',
        transactionUser: 'vendor',
      )),
      FireStoreUtils.setWalletTransaction(WalletTransactionModel(
        amount: vendorAmount,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: userId,
        date: Timestamp.now(),
        isTopup: false,
        paymentMethod: 'Wallet',
        paymentStatus: 'success',
        note: 'Order Amount Refund',
        transactionUser: 'vendor',
      )),
    ]);

    await FireStoreUtils.updateUserWallet(
      amount: (-(vendorAmount + totals.taxAmount)).toString(),
      userId: FireStoreUtils.getCurrentUid().toString(),
    );

    await controller.getOrder(silent: false);
    ShowToastDialog.closeLoader();
    Get.back();
  }

  Future<void> _markDelivered() async {
    ShowToastDialog.showLoader('Please wait...'.tr);
    await AudioPlayerService.playSound(false);
    orderModel.status = Constant.orderCompleted;
    await Future.wait([
      FireStoreUtils.updateOrder(orderModel),
      FireStoreUtils.restaurantVendorWalletSet(orderModel),
    ]);
    if (orderModel.author?.fcmToken?.isNotEmpty == true) {
      SendNotification.sendFcmMessage(
        Constant.takeawayCompleted,
        orderModel.author!.fcmToken!,
        {},
      );
    }
    await controller.getOrder(silent: false);
    ShowToastDialog.closeLoader();
  }

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: RoundedButtonFill(
              title: 'Cancel Order'.tr,
              color: AppThemeData.new_primary,
              textColor: AppThemeData.grey50,
              height: 5,
              onPress: _cancelOrder,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: orderModel.takeAway == true
                ? RoundedButtonFill(
              title: 'Delivered'.tr,
              color: AppThemeData.primary300,
              textColor: AppThemeData.grey50,
              height: 5,
              onPress: _markDelivered,
            )
                : RoundedButtonFill(
              title: orderModel.status ?? '',
              color: AppThemeData.new_green_tog,
              textColor: AppThemeData.grey50,
              height: 5,
              onPress: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Closed (Completed / Rejected / Cancelled) Order Card
// ─────────────────────────────────────────────────────────────────────────────
class _ClosedOrderCard extends StatelessWidget {
  final OrderModel orderModel;
  final DarkThemeProvider themeChange;
  final BuildContext context;
  final HomeController controller;

  const _ClosedOrderCard({
    required this.orderModel,
    required this.themeChange,
    required this.context,
    required this.controller,
  });

  @override
  Widget build(BuildContext ctx) {
    final totals = _OrderTotals.from(orderModel);

    return _OrderCardShell(
      themeChange: themeChange,
      children: [
        _CustomerRow(orderModel: orderModel, themeChange: themeChange),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: MySeparator(
            color: themeChange.getThem()
                ? AppThemeData.grey700
                : AppThemeData.grey200,
          ),
        ),
        _ProductList(orderModel: orderModel, themeChange: themeChange),
        _OrderMetaRows(
          orderModel: orderModel,
          themeChange: themeChange,
          adminCommission: totals.adminCommission,
          controller: controller,
          parentContext: context,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: RoundedButtonFill(
            title: orderModel.status ?? '',
            color: orderModel.status == Constant.orderRejected
                ? AppThemeData.danger300
                : AppThemeData.secondary300,
            textColor: AppThemeData.grey50,
            height: 5,
            onPress: () {},
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estimated Time Dialog
// ─────────────────────────────────────────────────────────────────────────────
class _EstimatedTimeDialog extends StatelessWidget {
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final OrderModel orderModel;
  final BuildContext context;
  final Future<void> Function(BuildContext, HomeController) onPickDuration;

  const _EstimatedTimeDialog({
    required this.controller,
    required this.themeChange,
    required this.orderModel,
    required this.context,
    required this.onPickDuration,
  });

  @override
  Widget build(BuildContext ctx) {
    final isDark = themeChange.getThem();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor:
      isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Text(
                'Estimate time to prepare'.tr,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  color: isDark
                      ? AppThemeData.grey100
                      : AppThemeData.grey800,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              color: isDark
                  ? AppThemeData.grey700
                  : AppThemeData.grey200,
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Duration picker tap target
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onPickDuration(context, controller),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estimated Time',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(() => Text(
                                      controller
                                          .estimatedTimeController
                                          .value
                                          .text
                                          .isEmpty
                                          ? 'Select duration'
                                          : controller
                                          .estimatedTimeController
                                          .value
                                          .text,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                        color: controller
                                            .estimatedTimeController
                                            .value
                                            .text
                                            .isEmpty
                                            ? Colors.grey.shade500
                                            : Colors.black,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              Obx(() => controller
                                  .estimatedTimeController
                                  .value
                                  .text
                                  .isNotEmpty
                                  ? IconButton(
                                icon: Icon(Icons.clear,
                                    color:
                                    Colors.grey.shade500,
                                    size: 20),
                                onPressed: () {
                                  controller
                                      .estimatedTimeController
                                      .value
                                      .text = '';
                                  controller
                                      .estimatedTimeController
                                      .refresh();
                                },
                                padding: EdgeInsets.zero,
                                constraints:
                                const BoxConstraints(
                                    minWidth: 40),
                              )
                                  : Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Colors.grey.shade500,
                                size: 24,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: RoundedButtonFill(
                          title: 'Cancel'.tr,
                          color: isDark
                              ? AppThemeData.grey700
                              : AppThemeData.grey200,
                          textColor: isDark
                              ? AppThemeData.grey100
                              : AppThemeData.grey800,
                          onPress: Get.back,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RoundedButtonFill(
                          title: 'Shipped order'.tr,
                          color: AppThemeData.secondary300,
                          textColor: AppThemeData.grey50,
                          onPress: () =>
                              _onShipPressed(ctx),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onShipPressed(BuildContext ctx) async {
    if (controller.estimatedTimeController.value.text.isEmpty) {
      ShowToastDialog.showToast('Please enter estimated time'.tr);
      return;
    }

    final isSelfDelivery = Constant.isSelfDeliveryFeature == true &&
        controller.vendermodel.value.isSelfDelivery == true &&
        orderModel.takeAway == false;

    if (isSelfDelivery) {
      ShowToastDialog.showLoader('Please wait...'.tr);
      await controller.getAllDriverList();
      ShowToastDialog.closeLoader();
      orderModel.estimatedTimeToPrepare =
          controller.estimatedTimeController.value.text;
      Get.back();
      showDialog(
        context: context,
        builder: (_) => _DeliveryManDialog(
          controller: controller,
          themeChange: themeChange,
          orderModel: orderModel,
        ),
      );
      return;
    }

    ShowToastDialog.showLoader('Please wait...'.tr);
    try {
      orderModel
        ..estimatedTimeToPrepare =
            controller.estimatedTimeController.value.text
        ..status = Constant.orderAccepted;

      await AudioPlayerService.playSound(false);

      // Radius fetch (cached)
      double radius = Constant.driverSearchRadius ?? 5.0;
      if (Constant.driverSearchRadius == null) {
        try {
          final res = await http.get(
            Uri.parse('${Constant.baseUrl}restaurant/GetDriverNearBy'),
            headers: {'Content-Type': 'application/json'},
          );
          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            if (data['success'] == true) {
              radius = double.tryParse(
                  data['data']['driverRadios'].toString()) ??
                  5.0;
              Constant.driverSearchRadius = radius;
            }
          }
        } catch (_) {
          radius = 5.0;
          Constant.driverSearchRadius = radius;
        }
      }

      orderModel.ensureMerchantPriceFromProducts();
      await Future.wait([
        FireStoreUtils.updateOrder(orderModel),
        FireStoreUtils.restaurantVendorWalletSet(orderModel),
      ]);

      // Notify nearby drivers
      await _notifyNearbyDrivers(radius);

      // Notify customer
      if (orderModel.author?.fcmToken?.isNotEmpty == true) {
        SendNotification.sendFcmMessage(
          Constant.restaurantAccepted,
          orderModel.author!.fcmToken!,
          {'orderId': orderModel.id ?? '', 'status': Constant.orderAccepted},
        ).catchError((_) {});
      }

      await controller.getOrder(silent: false);
    } catch (e) {
      debugPrint('Error accepting order: $e');
      ShowToastDialog.showToast(
          'Error processing order. Please try again.'.tr);
    } finally {
      ShowToastDialog.closeLoader();
      Get.back();
    }
  }

  Future<void> _notifyNearbyDrivers(double radius) async {
    final orderId = orderModel.id;
    if (orderId == null || orderId.isEmpty) return;

    final restaurantLat =
        controller.vendermodel.value.latitude ?? 0.0;
    final restaurantLng =
        controller.vendermodel.value.longitude ?? 0.0;
    final zoneId = controller.vendermodel.value.zoneId;

    final allDrivers =
    await FireStoreUtils.getAvalibleDrivers(zoneId: zoneId);

    final eligible = <UserModel>[];
    for (final d in allDrivers) {
      final lat = d.location?.latitude;
      final lng = d.location?.longitude;
      if (lat == null || lng == null) continue;
      try {
        final dist = Geolocator.distanceBetween(
            restaurantLat, restaurantLng, lat, lng) /
            1000;
        if (dist <= radius) eligible.add(d);
      } catch (_) {}
    }

    eligible.sort((a, b) {
      try {
        final da = Geolocator.distanceBetween(restaurantLat, restaurantLng,
            a.location!.latitude!, a.location!.longitude!);
        final db = Geolocator.distanceBetween(restaurantLat, restaurantLng,
            b.location!.latitude!, b.location!.longitude!);
        return da.compareTo(db);
      } catch (_) {
        return 0;
      }
    });

    const batchSize = 5;
    for (var i = 0; i < eligible.length; i += batchSize) {
      final batch = eligible.skip(i).take(batchSize).toList();
      await Future.wait(batch.map((driver) async {
        try {
          driver.role = Constant.userRoleDriver;
          final existing = <String>[];
          for (final item in driver.orderRequestData ?? []) {
            if (item is String) {
              existing.add(item);
            } else if (item is Map && item['id'] != null) {
              existing.add(item['id'].toString());
            }
          }
          if (existing.contains(orderId)) return;
          // driver.orderRequestData = [...existing, orderId];

          final updated = await FireStoreUtils.updateDriverUser(driver);
          if (!updated) return;

          if (driver.fcmToken?.isNotEmpty == true) {
            await SendNotification.sendFcmMessage(
              Constant.newDeliveryOrder,
              driver.fcmToken!,
              {'orderId': orderId},
            );
          }
        } catch (e) {
          debugPrint('Driver update error [${driver.firebaseId}]: $e');
        }
      }));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Delivery Man Selector Dialog
// ─────────────────────────────────────────────────────────────────────────────
class _DeliveryManDialog extends StatelessWidget {
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final OrderModel orderModel;

  const _DeliveryManDialog({
    required this.controller,
    required this.themeChange,
    required this.orderModel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor:
      isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Select the delivery man'.tr,
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        color: isDark
                            ? AppThemeData.grey100
                            : AppThemeData.grey800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Add Delivery Man'.tr,
                      style: TextStyle(
                        color: AppThemeData.secondary300,
                        fontFamily: AppThemeData.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownSearch<UserModel>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      labelText: 'Search Delivery Man'.tr,
                      labelStyle: const TextStyle(
                          fontFamily: AppThemeData.medium,
                          fontSize: 15),
                      border: const OutlineInputBorder(),
                      prefixIcon:
                      const Icon(Icons.search),
                      contentPadding:
                      const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                  itemBuilder: (_, UserModel driver, bool __) {
                    final occupied =
                        driver.inProgressOrderID?.isNotEmpty ==
                            true;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              '${driver.firstName} ${driver.lastName}',
                              style: const TextStyle(
                                fontFamily: AppThemeData.medium,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (Constant.singleOrderReceive ==
                              true)
                            Expanded(
                              flex: 1,
                              child: Text(
                                occupied
                                    ? 'Occupied'.tr
                                    : 'Assign'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppThemeData.medium,
                                  fontSize: 12,
                                  color: occupied
                                      ? AppThemeData.danger300
                                      : AppThemeData.secondary300,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                items: controller.driverUserList,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  baseStyle: const TextStyle(
                      fontFamily: AppThemeData.medium, fontSize: 16),
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Select Delivery Man'.tr,
                    labelStyle: const TextStyle(
                        fontFamily: AppThemeData.medium,
                        fontSize: 15),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                  ),
                ),
                itemAsString: (u) => u?.id != null
                    ? '${u?.firstName} ${u?.lastName}'
                    : 'Select Delivery Man'.tr,
                onChanged: (value) {
                  if (Constant.singleOrderReceive == true) {
                    if (value?.inProgressOrderID?.isEmpty ==
                        true) {
                      controller.selectDriverUser.value = value!;
                    } else {
                      ShowToastDialog.showToast(
                        'This delivery man is already assigned. Kindly select a different one.'
                            .tr,
                      );
                      controller.selectDriverUser.value =
                          UserModel();
                    }
                  } else {
                    controller.selectDriverUser.value = value!;
                  }
                },
                selectedItem: controller.selectDriverUser.value,
              ),
            )),
            const SizedBox(height: 20),
            Container(
              color: isDark
                  ? AppThemeData.grey700
                  : AppThemeData.grey200,
              height: 3,
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: RoundedButtonFill(
                          title: 'Cancel'.tr,
                          color: isDark
                              ? AppThemeData.grey700
                              : AppThemeData.grey200,
                          textColor: isDark
                              ? AppThemeData.grey100
                              : AppThemeData.grey800,
                          onPress: Get.back,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RoundedButtonFill(
                          title: 'Order Assign'.tr,
                          color: AppThemeData.secondary300,
                          textColor: AppThemeData.grey50,
                          onPress: () =>
                              _assignDriver(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignDriver(BuildContext context) async {
    final driver = controller.selectDriverUser.value;
    if (driver.id == null || driver.id!.isEmpty) {
      ShowToastDialog.showToast('Please select the delivery man'.tr);
      return;
    }

    Get.back();
    ShowToastDialog.showLoader('Please wait...'.tr);
    await AudioPlayerService.playSound(false);

    orderModel
      ..notes = ''
      ..driverID = driver.id
      ..driver = driver
      ..status = Constant.orderInTransit;

    // driver.inProgressOrderID?.add(orderModel.id);

    await FireStoreUtils.updateOrder(orderModel);
    await Future.wait([
      FireStoreUtils.updateDriverUser(driver),
      FireStoreUtils.restaurantVendorWalletSet(orderModel),
    ]);

    if (driver.fcmToken?.isNotEmpty == true) {
      SendNotification.sendFcmMessage(
        Constant.newDeliveryOrder,
        driver.fcmToken!,
        {'orderId': orderModel.id},
      );
    }

    ShowToastDialog.closeLoader();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Remark Dialog
// ─────────────────────────────────────────────────────────────────────────────
class _RemarkDialog extends StatelessWidget {
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final OrderModel orderModel;

  const _RemarkDialog({
    required this.controller,
    required this.themeChange,
    required this.orderModel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor:
      isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Text(
                  orderModel.notes ?? '',
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    color: isDark
                        ? AppThemeData.grey100
                        : AppThemeData.grey800,
                    fontSize: 18,
                  ),
                ),
              ),
              RoundedButtonFill(
                title: 'Cancel'.tr,
                color: isDark
                    ? AppThemeData.grey700
                    : AppThemeData.grey200,
                textColor: isDark
                    ? AppThemeData.grey100
                    : AppThemeData.grey800,
                onPress: Get.back,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Duration Picker Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class DurationPickerBottomSheet extends StatefulWidget {
  final Duration initialDuration;

  const DurationPickerBottomSheet({super.key, required this.initialDuration});

  @override
  State<DurationPickerBottomSheet> createState() =>
      _DurationPickerBottomSheetState();
}

class _DurationPickerBottomSheetState
    extends State<DurationPickerBottomSheet> {
  late Duration _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.2))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'Select Duration',
                      textAlign: TextAlign.center,
                      style:
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Selected display
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time,
                      color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    '${_selected.inMinutes} minutes',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            // Quick select chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [5, 10, 15, 20, 25, 30, 35, 40]
                    .map((m) => FilterChip(
                  label: Text('$m min'),
                  selected: _selected.inMinutes == m,
                  onSelected: (_) =>
                      setState(() =>
                      _selected = Duration(minutes: m)),
                ))
                    .toList(),
              ),
            ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.pop(context, _selected),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Confirm'),
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
}