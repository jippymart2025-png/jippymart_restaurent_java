import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/app/Home_screen/widgets/AcceptedOrderCard.dart';
import 'package:jippymart_restaurant/app/Home_screen/widgets/CustomerRow.dart';
import 'package:jippymart_restaurant/app/Home_screen/widgets/NewOrderCard.dart';
import 'package:jippymart_restaurant/app/Home_screen/widgets/OrderCardShell.dart';
import 'package:jippymart_restaurant/app/Home_screen/widgets/OrderMetaRows.dart';
import 'package:jippymart_restaurant/app/Home_screen/widgets/ProductList.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/app/verification_screen/verification_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/home_controller.dart';
import 'package:jippymart_restaurant/models/order_model.dart';
import 'package:jippymart_restaurant/service/order_api_service.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
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


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TabBarView(
        children: [
          _OrderTab(
            orders: ctrl.newOrderList,
            emptyMessage: ' Waiting For New Orders'.tr,
            onRefresh: () => ctrl.refreshApp(),
            itemBuilder: (order) => NewOrderCard(
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
            itemBuilder: (order) => AcceptedOrderCard(
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
      final minutes = OrderApiService.parsePreparationTimeInMins(text);
      if (minutes != null) {
        initial = Duration(
            minutes:
                minutes.clamp(kMinPreparationTimeInMins, kMaxPreparationTimeInMins));
      }
    }

    final picked = await showModalBottomSheet<Duration>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DurationPickerBottomSheet(
        initialDuration: initial,
        minMinutes: kMinPreparationTimeInMins,
        maxMinutes: kMaxPreparationTimeInMins,
      ),
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
    final totals = OrderTotals.from(orderModel);

    return OrderCardShell(
      themeChange: themeChange,
      children: [
        CustomerRow(orderModel: orderModel, themeChange: themeChange),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: MySeparator(
            color: themeChange.getThem()
                ? AppThemeData.grey700
                : AppThemeData.grey200,
          ),
        ),
        ProductList(orderModel: orderModel, themeChange: themeChange),
        OrderMetaRows(
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
// Duration Picker Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class DurationPickerBottomSheet extends StatefulWidget {
  final Duration initialDuration;
  final int minMinutes;
  final int maxMinutes;

  const DurationPickerBottomSheet({
    super.key,
    required this.initialDuration,
    this.minMinutes = 1,
    this.maxMinutes = 15,
  });

  @override
  State<DurationPickerBottomSheet> createState() =>
      _DurationPickerBottomSheetState();
}

class _DurationPickerBottomSheetState
    extends State<DurationPickerBottomSheet> {
  static const List<int> _chipOptions = [1, 2, 5, 8, 10, 12, 15];

  late Duration _selected;

  @override
  void initState() {
    super.initState();
    _selected = Duration(
        minutes: widget.initialDuration.inMinutes
            .clamp(widget.minMinutes, widget.maxMinutes));
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
                children: _chipOptions
                        .where((m) => m >= widget.minMinutes && m <= widget.maxMinutes)
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