import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/subscription_payment_controller.dart';
import 'package:jippymart_restaurant/models/subscription_plan_model.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import '../../../controller/dash_board_controller.dart';
import '../../../models/location_model.dart';
import '../controller/subscription_plans_controller.dart';
import 'promotion_action_forms.dart';
import 'promotion_quick_action.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────
class _Tok {
  static const double s2 = 2, s4 = 4, s6 = 6, s8 = 8, s10 = 10, s12 = 12,
      s14 = 14, s16 = 16, s20 = 20, s24 = 24, s28 = 28, s32 = 32, s48 = 48;

  static const double r8 = 8, r12 = 12, r16 = 16, r20 = 20, r24 = 24, r99 = 99;

  static const double f11 = 11, f12 = 12, f13 = 13, f14 = 14, f15 = 15,
      f16 = 16, f18 = 18, f22 = 22, f26 = 26, f28 = 28;

  static const double i18 = 18, i22 = 22, i28 = 28, i32 = 32, i48 = 48, i64 = 64;

  static const LinearGradient heroGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1F3C), Color(0xFF2D3561)],
  );
  static const LinearGradient accentGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
  );
  static const LinearGradient commissionGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
  );
  static const LinearGradient subGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key,this.showBackButton = true,});
  final bool showBackButton;

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  // Holds the current plan fetched fresh from Firestore on screen open.
  final Rx<SubscriptionPlanModel?> _currentPlan = Rx<SubscriptionPlanModel?>(null);
  final RxBool _currentPlanLoading = true.obs;

  late final SubscriptionPaymentController _paymentController;
  late final SubscriptionPlansController _plansController;
  PromotionQuickAction? _selectedAction;
  Worker? _promotionsTabResetWorker;

  @override
  void initState() {
    super.initState();
    _paymentController = Get.put(SubscriptionPaymentController());
    _plansController = Get.put(SubscriptionPlansController());

    if (!widget.showBackButton && Get.isRegistered<DashBoardController>()) {
      final dash = Get.find<DashBoardController>();
      _promotionsTabResetWorker =
          ever(dash.promotionsTabResetToken, (_) {
            if (mounted) {
              _plansController.resetSlotBookingSelections();
              setState(() => _selectedAction = null);
            }
          });
    }

    // Fetch everything fresh when the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });
  }

  @override
  void dispose() {
    _promotionsTabResetWorker?.dispose();
    super.dispose();
  }

  /// Refresh plans list AND current plan simultaneously.
  Future<void> _refreshAll() async {
    _currentPlanLoading.value = true;
    await Future.wait([
      _plansController.loadStates(),
      _loadCurrentPlan(),
    ]);
  }

  /// Loads the vendor's active subscription plan directly from Firestore
  /// so it's always up-to-date even on cold start.
  Future<void> _loadCurrentPlan() async {
    try {
      _currentPlanLoading.value = true;

      // 1. Try dashboard (fastest if already loaded)
      if (Get.isRegistered<DashBoardController>()) {
        final dash = Get.find<DashBoardController>();
        final raw = dash.vendorModel.value.subscriptionPlan;
        if (raw is Map && (raw as Map).isNotEmpty) {
          _currentPlan.value = SubscriptionPlanModel.fromJson(
              Map<String, dynamic>.from(raw as Map<dynamic, dynamic>));
          _currentPlanLoading.value = false;
          return;
        }
      }

      // 2. Force-fetch vendor from Firestore for accurate data on restart
      final vendorId = Constant.userModel?.vendorID?.toString().trim();
      if (vendorId != null && vendorId.isNotEmpty) {
        final vendor = await FireStoreUtils.getVendorById(vendorId, forceRefresh: true);
        if (vendor != null) {
          // Sync dashboard with fresh data
          if (Get.isRegistered<DashBoardController>()) {
            Get.find<DashBoardController>().vendorModel.value = vendor;
          }
          final raw = vendor.subscriptionPlan;
          if (raw is Map && (raw as Map).isNotEmpty) {
            _currentPlan.value = SubscriptionPlanModel.fromJson(
                Map<String, dynamic>.from(raw as Map<dynamic, dynamic>));
          } else {
            _currentPlan.value = null;
          }
        }
      }
    } catch (e) {
      debugPrint('_loadCurrentPlan error: $e');
      _currentPlan.value = null;
    } finally {
      _currentPlanLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionPlansController>(
      init: _plansController,
      builder: (controller) {
        return Scaffold(
          backgroundColor: _bg(context),
          body: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                _PromotionsTopBar(showBackButton: widget.showBackButton),
                PromotionQuickActionsGrid(
                  selected: _selectedAction,
                  onSelected: (action) {
                    if (_selectedAction == PromotionQuickAction.slotBooking ||
                        action == PromotionQuickAction.slotBooking) {
                      _plansController.resetSlotBookingSelections();
                    }
                    setState(() {
                      _selectedAction =
                      _selectedAction == action ? null : action;
                    });
                  },
                ),
                Expanded(
                  child: _selectedAction == null
                      ? const PromotionPlansStatusPanel()
                      : _buildActionContent(controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionContent(SubscriptionPlansController controller) {
    final action = _selectedAction;
    if (action == null) return const SizedBox.shrink();

    switch (action) {
      case PromotionQuickAction.slotBooking:
        return Obx(() {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_currentPlanLoading.value)
                  _CurrentPlanSkeleton()
                else if (_currentPlan.value != null)
                  _CurrentPlanCard(
                    plan: _currentPlan.value!,
                    onRefresh: _loadCurrentPlan,
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: _LocationFilterSection(
                    controller: controller,
                    onBuyNow: (plan) =>
                        _paymentController.startRazorpayPayment(plan),
                  ),
                ),
              ],
            ),
          );
        });
    }
  }

  void _openDetail(BuildContext context, SubscriptionPlanModel plan) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: SubscriptionPlanDetailScreen(plan: plan),
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) {
      // Refresh current plan when returning from detail (user may have bought)
      _loadCurrentPlan();
    });
  }

  static Color _bg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0F1120) : const Color(0xFFF2F4FA);
  }
}

class _LocationFilterSection extends StatelessWidget {
  const _LocationFilterSection({
    required this.controller,
    required this.onBuyNow,
  });

  final SubscriptionPlansController controller;
  final void Function(SubscriptionPlanModel plan) onBuyNow;

  SubscriptionPlanModel? _selectedPlanInList() {
    final selected = controller.selectedPlan.value;
    if (selected == null) return null;
    for (final plan in controller.plans) {
      if (plan.subscriptionPlanId == selected.subscriptionPlanId) {
        return plan;
      }
    }
    return null;
  }

  SubscriptionPlanModel? _visiblePlanDetails() {
    final details = controller.selectedPlanDetails.value;
    if (details != null) return details;

    return _selectedPlanInList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;
    final borderColor =
    isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5);
    final textPrimary =
    isDark ? Colors.white : const Color(0xFF1A1F3C);
    final textSecondary =
    isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B);

    return Obx(() {
      final planDetails = _visiblePlanDetails();
      final plansLoading = controller.isPlansLoading.value;

      return Container(
          padding: const EdgeInsets.all(_Tok.s12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(_Tok.r12),
            border: Border.all(color: borderColor),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Subscription Plans",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _Tok.f14,
                  fontFamily: AppThemeData.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: _Tok.s8),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: _Tok.s10),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SubscriptionDropdown<StateModel>(
                        label: 'State',
                        value: controller.states.contains(controller.selectedState.value)
                            ? controller.selectedState.value
                            : null,
                        hint: 'Select state',
                        items: controller.states
                            .map(
                              (state) => DropdownMenuItem<StateModel>(
                            value: state,
                            child: Text(state.stateName),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          controller.selectedState.value = value;
                          controller.selectedPlan.value = null;
                          controller.selectedPlanDetails.value = null;
                          controller.loadCities(value.stateId);
                        },
                      ),
                      const SizedBox(height: _Tok.s8),
                      _SubscriptionDropdown<CityModel>(
                        label: 'City',
                        value: controller.cities.contains(controller.selectedCity.value)
                            ? controller.selectedCity.value
                            : null,
                        hint: 'Select city',
                        items: controller.cities
                            .map(
                              (city) => DropdownMenuItem<CityModel>(
                            value: city,
                            child: Text(city.cityName),
                          ),
                        )
                            .toList(),
                        onChanged: controller.selectedState.value == null
                            ? null
                            : (value) {
                          if (value == null) return;
                          controller.selectedCity.value = value;
                          controller.selectedPlan.value = null;
                          controller.selectedPlanDetails.value = null;
                          controller.loadAreas(value.cityId);
                        },
                      ),
                      const SizedBox(height: _Tok.s8),
                      _SubscriptionDropdown<AreaModel>(
                        label: 'Area',
                        value: controller.areas.contains(controller.selectedArea.value)
                            ? controller.selectedArea.value
                            : null,
                        hint: 'Select area',
                        items: controller.areas
                            .map(
                              (area) => DropdownMenuItem<AreaModel>(
                            value: area,
                            child: Text(area.areaName),
                          ),
                        )
                            .toList(),
                        onChanged: controller.selectedCity.value == null
                            ? null
                            : (value) async {
                          if (value == null) return;
                          controller.selectedArea.value = value;
                          controller.selectedPlan.value = null;
                          controller.selectedPlanDetails.value = null;
                          await controller.loadPlans(value.areaId);
                        },
                      ),
                      const SizedBox(height: _Tok.s8),
                      _SubscriptionDropdown<SubscriptionPlanModel>(
                        label: 'Available Plans',
                        value: _selectedPlanInList(),
                        hint: controller.selectedArea.value == null
                            ? 'Select area first'
                            : plansLoading
                            ? 'Loading plans...'
                            : 'Select plan',
                        items: controller.plans
                            .map(
                              (plan) => DropdownMenuItem<SubscriptionPlanModel>(
                            value: plan,
                            child: Text(plan.planName),
                          ),
                        )
                            .toList(),
                        onChanged: controller.selectedArea.value == null ||
                            plansLoading ||
                            controller.plans.isEmpty
                            ? null
                            : (value) {
                          if (value == null) return;
                          controller.selectPlan(value);
                        },
                      ),
                      if (plansLoading) ...[
                        const SizedBox(height: _Tok.s10),
                        const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ] else if (!controller.hasPlans && controller.hasError) ...[
                        const SizedBox(height: _Tok.s10),
                        _InlineMessage(
                          message: controller.errorMessage.value,
                          isError: true,
                        ),
                      ],
                      if (planDetails != null) ...[
                        const SizedBox(height: _Tok.s10),
                        Container(
                          padding: const EdgeInsets.all(_Tok.s12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF111827)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(_Tok.r12),
                            border: Border.all(color: borderColor),
                          ),
                          child: controller.isPlanDetailsLoading.value
                              ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      planDetails.planName,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.bold,
                                        fontSize: _Tok.f14,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: _Tok.s8),
                                  Text(
                                    Constant.amountShow(
                                      amount: planDetails.price.toString(),
                                    ),
                                    style: TextStyle(
                                      fontFamily: AppThemeData.bold,
                                      fontSize: _Tok.f15,
                                      color: AppThemeData.secondary300,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: _Tok.s6),
                              _PlanAttributesGrid(
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                items: [
                                  _PlanAttributeItem(
                                    label: 'Duration',
                                    value: '${planDetails.durationInDays} Days',
                                  ),
                                  _PlanAttributeItem(
                                    label: 'Banner Duration',
                                    value:
                                    '${planDetails.bannerDurationInDays} Days',
                                  ),
                                  _PlanAttributeItem(
                                    label: 'Radius',
                                    value: '${planDetails.radiusInKms} KM',
                                  ),
                                  _PlanAttributeItem(
                                    label: 'Banner Slot',
                                    value: '${planDetails.bannerSlot}',
                                  ),
                                  _PlanAttributeItem(
                                    label: 'Best Restaurant',
                                    value: '${planDetails.bestRestaurantSlot}',
                                  ),
                                  _PlanAttributeItem(
                                    label: 'Deals Slot',
                                    value: '${planDetails.dealsSlot}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: _Tok.s8),
                              _PillButton(
                                label: 'Buy Now'.tr,
                                gradient: _Tok.subGrad,
                                fullWidth: true,
                                compact: true,
                                onPressed: () => onBuyNow(planDetails),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          )
      );
    });
  }
}

class _SubscriptionDropdown<T> extends StatelessWidget {
  const _SubscriptionDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? const Color(0xFF1A1E38) : Colors.white;
    final border =
    isDark ? const Color(0xFF2A3050) : const Color(0xFFE2E8F0);

    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label.tr,
        hintText: hint.tr,
        filled: true,
        fillColor: fill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _Tok.s12,
          vertical: _Tok.s10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Tok.r12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Tok.r12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Tok.r12),
          borderSide: BorderSide(
            color: AppThemeData.secondary300,
            width: 1.5,
          ),
        ),
      ),
      hint: Text(hint.tr),
      isExpanded: true,
      items: items,
      onChanged: onChanged,
    );
  }
}

class _PlanAttributeItem {
  const _PlanAttributeItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _PlanAttributesGrid extends StatelessWidget {
  const _PlanAttributesGrid({
    required this.items,
    required this.textPrimary,
    required this.textSecondary,
  });

  final List<_PlanAttributeItem> items;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg =
    isDark ? const Color(0xFF1A1E38) : Colors.white;
    final tileBorder =
    isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5);

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 6.0;
        final tileWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (item) => SizedBox(
              width: tileWidth,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tileBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tileBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppThemeData.medium,
                        fontSize: 10,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        fontSize: 11,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .toList(),
        );
      },
    );
  }
}

class _PlanAttributeRow extends StatelessWidget {
  const _PlanAttributeRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _Tok.s4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.tr,
              style: TextStyle(
                fontFamily: AppThemeData.medium,
                fontSize: _Tok.f12,
                color: textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppThemeData.semiBold,
              fontSize: _Tok.f12,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isError
        ? (isDark ? const Color(0xFF3B1F1F) : const Color(0xFFFFF1F2))
        : (isDark ? const Color(0xFF1A1E38) : const Color(0xFFF8FAFC));
    final color = isError ? const Color(0xFFDC2626) : const Color(0xFF64748B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_Tok.s14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_Tok.r12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppThemeData.medium,
          fontSize: _Tok.f13,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────

class _PromotionsTopBar extends StatelessWidget {
  const _PromotionsTopBar({required this.showBackButton});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeData.new_primary,
      padding: const EdgeInsets.fromLTRB(4, 2, 8, 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: showBackButton
                ? IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppThemeData.grey50,
                size: 20,
              ),
            )
                : null,
          ),
          Expanded(
            child: Text(
              'Subscription Plans'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: 15,
                color: AppThemeData.grey50,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CURRENT PLAN SKELETON (loading placeholder)
// ─────────────────────────────────────────────
class _CurrentPlanSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmer = isDark ? const Color(0xFF1E2235) : const Color(0xFFE8ECF5);
    return Container(
      height: 76,
      padding: const EdgeInsets.all(_Tok.s14),
      decoration: BoxDecoration(
        color: shimmer,
        borderRadius: BorderRadius.circular(_Tok.r16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: shimmer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(_Tok.r12),
            ),
          ),
          const SizedBox(width: _Tok.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 10,
                    width: 80,
                    decoration: BoxDecoration(
                        color: shimmer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(
                    height: 13,
                    width: 140,
                    decoration: BoxDecoration(
                        color: shimmer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CURRENT PLAN CARD
// ─────────────────────────────────────────────
class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({required this.plan, this.onRefresh});
  final SubscriptionPlanModel plan;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111827) : const Color(0xFFFFFBEB);
    final border = isDark ? const Color(0xFF92400E) : const Color(0xFFF59E0B);
    final text = isDark ? Colors.white : const Color(0xFF78350F);

    final validityText = '${plan.durationInDays} Days';
    return Container(
      padding: const EdgeInsets.all(_Tok.s14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_Tok.r16),
        border: Border.all(color: border.withOpacity(0.6), width: 1.1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(_Tok.s8),
            decoration: BoxDecoration(
              color: border.withOpacity(0.15),
              borderRadius: BorderRadius.circular(_Tok.r12),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: _Tok.i22,
              color: Color(0xFFEA580C),
            ),
          ),
          const SizedBox(width: _Tok.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current plan'.tr,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: _Tok.f12,
                    color: text.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: _Tok.s2),
                Text(
                  plan.planName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: _Tok.f15,
                    color: text,
                  ),
                ),
                const SizedBox(height: _Tok.s2),
                Row(
                  children: [
                    Text(
                      Constant.amountShow(amount: '${plan.price}'),
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        fontSize: _Tok.f13,
                        color: text.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: _Tok.s6),
                    Text(
                      '• $validityText',
                      style: TextStyle(
                        fontFamily: AppThemeData.regular,
                        fontSize: _Tok.f12,
                        color: text.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Active badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withOpacity(0.12),
              borderRadius: BorderRadius.circular(_Tok.r99),
              border: Border.all(
                  color: const Color(0xFF16A34A).withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Active',
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: 10,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PLAN CARD
// ─────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    this.index,
    required this.onTap,
    this.onBuyNow,
  });

  final SubscriptionPlanModel plan;
  final int? index;
  final VoidCallback onTap;
  final VoidCallback? onBuyNow;

  @override
  Widget build(BuildContext context) {
    final themeChange =
    Provider.of<DarkThemeProvider>(context, listen: false);

    final isDark = themeChange.getThem();

    final cardBg =
    isDark ? const Color(0xFF1A1E38) : Colors.white;

    final textPrimary =
    isDark ? Colors.white : const Color(0xFF1A1F3C);

    final textSub =
    isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B);

    final planGrad = _Tok.subGrad;

    const double cardH = 88.0;
    const double imgSize = 58.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: _Tok.s10),
      child: SizedBox(
        height: cardH,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(_Tok.r16),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(_Tok.r16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: _Tok.s12,
                vertical: _Tok.s12,
              ),
              child: Row(
                children: [
                  /// Plan Icon
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(_Tok.r12),
                    child: SizedBox(
                      width: imgSize,
                      height: imgSize,
                      child: _SmallPlaceholder(
                        grad: planGrad,
                        size: imgSize,
                      ),
                    ),
                  ),

                  const SizedBox(width: _Tok.s12),

                  /// Plan Details
                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.planName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily:
                            AppThemeData.semiBold,
                            fontSize: _Tok.f15,
                            color: textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),

                        const SizedBox(height: _Tok.s4),

                        Text(
                          '₹${plan.price}',
                          style:  TextStyle(
                            fontFamily:
                            AppThemeData.semiBold,
                            fontSize: _Tok.f14,
                            color:
                            AppThemeData.secondary300,
                          ),
                        ),

                        const SizedBox(height: _Tok.s2),

                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color: textSub,
                            ),

                            const SizedBox(width: 3),

                            Text(
                              '${plan.durationInDays} Days',
                              style: TextStyle(
                                fontFamily:
                                AppThemeData.regular,
                                fontSize: _Tok.f11,
                                color: textSub,
                              ),
                            ),

                            const SizedBox(width: _Tok.s8),

                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppThemeData
                                    .secondary300
                                    .withValues(
                                    alpha: 0.15),
                                borderRadius:
                                BorderRadius.circular(
                                    20),
                              ),
                              child: const Text(
                                'Subscription',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: _Tok.s10),

                  /// Buy Button
                  _PillButton(
                    label: "Buy Now".tr,
                    gradient: planGrad,
                    onPressed: onBuyNow ?? onTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────
// PILL BUTTON
// ─────────────────────────────────────────────
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.gradient,
    required this.onPressed,
    this.fullWidth = false,
    this.compact = false,
  });
  final String label;
  final Gradient gradient;
  final VoidCallback onPressed;
  final bool fullWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final inner = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(_Tok.r99),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: fullWidth ? 0 : _Tok.s20,
            vertical: fullWidth
                ? (compact ? _Tok.s10 : _Tok.s16)
                : _Tok.s10,
          ),
          alignment: fullWidth ? Alignment.center : null,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(_Tok.r99),
            boxShadow: [
              BoxShadow(
                color: _gradFirstColor(gradient).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppThemeData.semiBold,
              fontSize: fullWidth ? (compact ? _Tok.f13 : _Tok.f16) : _Tok.f13,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
    if (fullWidth) {
      return SizedBox(width: double.infinity, child: inner);
    }
    return inner;
  }

  Color _gradFirstColor(Gradient g) {
    if (g is LinearGradient && g.colors.isNotEmpty) return g.colors.first;
    return AppThemeData.secondary300;
  }
}

// ─────────────────────────────────────────────
// TYPE BADGE (used in detail hero)
// ─────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isCommission});
  final bool isCommission;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: _Tok.s10, vertical: _Tok.s4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(_Tok.r99),
        border:
        Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCommission ? Icons.percent_rounded : Icons.star_rounded,
            size: 11,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isCommission ? 'Commission'.tr : 'Subscription'.tr,
            style: const TextStyle(
              fontFamily: AppThemeData.semiBold,
              fontSize: _Tok.f11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SMALL PLACEHOLDER
// ─────────────────────────────────────────────
class _SmallPlaceholder extends StatelessWidget {
  const _SmallPlaceholder({required this.grad, required this.size});
  final LinearGradient grad;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(gradient: grad),
      child: const Center(
        child: Icon(Icons.card_membership_rounded,
            size: 24, color: Colors.white60),
      ),
    );
  }
}

/// Tiny inline badge used inside the horizontal card row
class _TypeBadgeInline extends StatelessWidget {
  const _TypeBadgeInline({required this.isCommission});
  final bool isCommission;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCommission
            ? const Color(0xFF4776E6).withValues(alpha: 0.12)
            : const Color(0xFF11998E).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(_Tok.r99),
      ),
      child: Text(
        isCommission ? 'Commission'.tr : 'Subscription'.tr,
        style: TextStyle(
          fontFamily: AppThemeData.semiBold,
          fontSize: 9,
          color: isCommission
              ? const Color(0xFF4776E6)
              : const Color(0xFF11998E),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DOT PATTERN PAINTER
// ─────────────────────────────────────────────
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const spacing = 14.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter old) => false;
}

// ─────────────────────────────────────────────
// DETAIL SCREEN
// ─────────────────────────────────────────────
class SubscriptionPlanDetailScreen extends StatelessWidget {
  const SubscriptionPlanDetailScreen({super.key, required this.plan});
  final SubscriptionPlanModel plan;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    final isDark = themeChange.getThem();
    final bgColor =
    isDark ? const Color(0xFF0F1120) : const Color(0xFFF2F4FA);
    final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F3C);
    final textSub =
    isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B);
    final divider =
    isDark ? const Color(0xFF2A2F50) : const Color(0xFFE8EDF5);
    final planGrad = _Tok.subGrad;
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: _Tok.s8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(_Tok.s8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(_Tok.r12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: _Tok.i22),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(decoration: BoxDecoration(gradient: planGrad)),
                  Opacity(
                    opacity: 0.06,
                    child: CustomPaint(painter: _DotPatternPainter()),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.4, 1.0],
                        colors: [Colors.transparent, bgColor],
                      ),
                    ),
                  ),
                  Positioned(
                    left: _Tok.s20,
                    right: _Tok.s20,
                    bottom: _Tok.s20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Subscription Plan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: _Tok.s8),
                        Text(
                          plan.planName,
                          style: const TextStyle(
                            fontFamily: AppThemeData.semiBold,
                            fontSize: _Tok.f26,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(blurRadius: 12, color: Colors.black38),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  _Tok.s16, _Tok.s4, _Tok.s16, _Tok.s48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PriceCard(
                    plan: plan,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSub: textSub,
                    planGrad: planGrad,
                    divider: divider,
                  ),
                  const SizedBox(height: _Tok.s16),
                  _SectionLabel(
                      label: "Plan details".tr, textColor: textPrimary),
                  const SizedBox(height: _Tok.s8),
                  _DetailCard(
                    cardBg: cardBg,
                    divider: divider,
                    rows: _buildRows(plan, textPrimary, textSub),
                  ),
                  const SizedBox(height: _Tok.s28),
                  _PillButton(
                    label: "Buy Now".tr,
                    gradient: planGrad,
                    fullWidth: true,
                    onPressed: () {
                      final ctrl = Get.find<SubscriptionPaymentController>();
                      ctrl.startRazorpayPayment(plan);
                    },
                  ),
                  const SizedBox(height: _Tok.s12),
                  Center(
                    child: Text(
                      "Secure payment · Cancel anytime",
                      style: TextStyle(
                        fontFamily: AppThemeData.regular,
                        fontSize: _Tok.f12,
                        color: textSub,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_RowData> _buildRows(
      SubscriptionPlanModel p,
      Color primary,
      Color sub,
      ) {
    return [
      _RowData(
        icon: Icons.currency_rupee,
        label: "Price".tr,
        value: "₹${p.price}",
      ),
      _RowData(
        icon: Icons.calendar_today_rounded,
        label: "Duration".tr,
        value: "${p.durationInDays} Days",
      ),
      _RowData(
        icon: Icons.image_rounded,
        label: "Banner Duration".tr,
        value: "${p.bannerDurationInDays} Days",
      ),
      _RowData(
        icon: Icons.location_on_outlined,
        label: "Radius".tr,
        value: "${p.radiusInKms} Km",
      ),
      _RowData(
        icon: Icons.view_carousel_outlined,
        label: "Banner Slot".tr,
        value: "${p.bannerSlot}",
      ),
      _RowData(
        icon: Icons.star_outline,
        label: "Best Restaurant Slot".tr,
        value: "${p.bestRestaurantSlot}",
      ),
      _RowData(
        icon: Icons.local_offer_outlined,
        label: "Deals Slot".tr,
        value: "${p.dealsSlot}",
      ),
      _RowData(
        icon: Icons.chat_outlined,
        label: "WhatsApp Broadcast".tr,
        value: p.whatsappBroadcast ?? "-",
      ),
      _RowData(
        icon: Icons.video_collection_outlined,
        label: "Video Credits".tr,
        value: p.videoCredits ?? "-",
      ),
    ];
  }
}

class _RowData {
  const _RowData(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
}

// ─────────────────────────────────────────────
// PRICE CARD
// ─────────────────────────────────────────────
class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.plan,
    required this.cardBg,
    required this.textPrimary,
    required this.textSub,
    required this.planGrad,
    required this.divider,
  });
  final SubscriptionPlanModel plan;
  final Color cardBg, textPrimary, textSub, divider;
  final LinearGradient planGrad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_Tok.s20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(_Tok.r20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Price",
                  style: TextStyle(
                    fontFamily: AppThemeData.regular,
                    fontSize: _Tok.f12,
                    color: textSub,
                  ),
                ),
                const SizedBox(height: 2),
                ShaderMask(
                  shaderCallback: (bounds) => planGrad.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    '₹${plan.price}',
                    style: const TextStyle(
                      fontFamily: AppThemeData.semiBold,
                      fontSize: _Tok.f28,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 48, color: divider),
          const SizedBox(width: _Tok.s20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Validity",
                style: TextStyle(
                  fontFamily: AppThemeData.regular,
                  fontSize: _Tok.f12,
                  color: textSub,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 16, color: textPrimary),
                  const SizedBox(width: 4),
                  Text(
                    "${plan.durationInDays} Days",
                    style: TextStyle(
                      fontFamily: AppThemeData.semiBold,
                      fontSize: _Tok.f18,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.textColor});
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: AppThemeData.semiBold,
        fontSize: _Tok.f16,
        color: textColor,
        letterSpacing: -0.2,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DETAIL CARD
// ─────────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.cardBg,
    required this.divider,
    required this.rows,
  });
  final Color cardBg, divider;
  final List<_RowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(_Tok.r16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: divider, indent: 48, endIndent: 16),
        itemBuilder: (_, i) {
          final row = rows[i];
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: _Tok.s16, vertical: _Tok.s14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                    AppThemeData.secondary300.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(_Tok.r8),
                  ),
                  child: Icon(row.icon,
                      size: 16, color: AppThemeData.secondary300),
                ),
                const SizedBox(width: _Tok.s12),
                Expanded(
                  child: Text(
                    row.label,
                    style: const TextStyle(
                      fontFamily: AppThemeData.regular,
                      fontSize: _Tok.f14,
                      color: AppThemeData.grey500,
                    ),
                  ),
                ),
                Text(
                  row.value,
                  style: const TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: _Tok.f14,
                    color: AppThemeData.grey900,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOADING VIEW
// ─────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppThemeData.secondary300,
              ),
            ),
          ),
          const SizedBox(height: _Tok.s16),
          Text(
            "Loading plans…",
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              fontSize: _Tok.f14,
              color: AppThemeData.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _Tok.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color:
                const Color(0xFFFF4757).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: _Tok.i48, color: Color(0xFFFF4757)),
            ),
            const SizedBox(height: _Tok.s20),
            const Text(
              "Something went wrong",
              style: TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: _Tok.f18,
                color: AppThemeData.grey900,
              ),
            ),
            const SizedBox(height: _Tok.s8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppThemeData.regular,
                fontSize: _Tok.f14,
                color: AppThemeData.grey500,
              ),
            ),
            const SizedBox(height: _Tok.s24),
            _PillButton(
              label: "Retry".tr,
              gradient: _Tok.accentGrad,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY VIEW
// ─────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _Tok.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: _Tok.heroGrad,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D3561).withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.card_membership_rounded,
                  size: _Tok.i48, color: Colors.white),
            ),
            const SizedBox(height: _Tok.s24),
            const Text(
              "No plans yet",
              style: TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: _Tok.f22,
                color: AppThemeData.grey900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: _Tok.s8),
            Text(
              "No subscription plans available for your zone right now.".tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppThemeData.regular,
                fontSize: _Tok.f14,
                color: AppThemeData.grey500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: _Tok.s24),
            _PillButton(
              label: "Refresh".tr,
              gradient: _Tok.heroGrad,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}