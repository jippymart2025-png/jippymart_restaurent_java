import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';
import '../../../controller/subscription_payment_controller.dart';
import '../../../models/subscription_plan_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';
import '../widgets/pillbotton.dart';
import '../widgets/tok.dart';

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
    final planGrad = Tok.subGrad;
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
              padding: const EdgeInsets.only(left: Tok.s8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(Tok.s8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(Tok.r12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: Tok.i22),
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
                    left: Tok.s20,
                    right: Tok.s20,
                    bottom: Tok.s20,
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
                        const SizedBox(height: Tok.s8),
                        Text(
                          plan.planName,
                          style: const TextStyle(
                            fontFamily: AppThemeData.semiBold,
                            fontSize: Tok.f26,
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
                  Tok.s16, Tok.s4, Tok.s16, Tok.s48),
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
                  const SizedBox(height: Tok.s16),
                  _SectionLabel(
                      label: "Plan details".tr, textColor: textPrimary),
                  const SizedBox(height: Tok.s8),
                  _DetailCard(
                    cardBg: cardBg,
                    divider: divider,
                    rows: _buildRows(plan, textPrimary, textSub),
                  ),
                  const SizedBox(height: Tok.s28),
                  PillButton(
                    label: "Buy Now".tr,
                    gradient: planGrad,
                    fullWidth: true,
                    onPressed: () {
                      final ctrl = Get.find<SubscriptionPaymentController>();
                      ctrl.startRazorpayPayment(plan);
                    },
                  ),
                  const SizedBox(height: Tok.s12),
                  Center(
                    child: Text(
                      "Secure payment · Cancel anytime",
                      style: TextStyle(
                        fontFamily: AppThemeData.regular,
                        fontSize: Tok.f12,
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
      padding: const EdgeInsets.all(Tok.s20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(Tok.r20),
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
                    fontSize: Tok.f12,
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
                      fontSize: Tok.f28,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 48, color: divider),
          const SizedBox(width: Tok.s20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Validity",
                style: TextStyle(
                  fontFamily: AppThemeData.regular,
                  fontSize: Tok.f12,
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
                      fontSize: Tok.f18,
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
        fontSize: Tok.f16,
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
        borderRadius: BorderRadius.circular(Tok.r16),
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
                horizontal: Tok.s16, vertical: Tok.s14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                    AppThemeData.secondary300.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Tok.r8),
                  ),
                  child: Icon(row.icon,
                      size: 16, color: AppThemeData.secondary300),
                ),
                const SizedBox(width: Tok.s12),
                Expanded(
                  child: Text(
                    row.label,
                    style: const TextStyle(
                      fontFamily: AppThemeData.regular,
                      fontSize: Tok.f14,
                      color: AppThemeData.grey500,
                    ),
                  ),
                ),
                Text(
                  row.value,
                  style: const TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: Tok.f14,
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
          const SizedBox(height: Tok.s16),
          Text(
            "Loading plans…",
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              fontSize: Tok.f14,
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
        padding: const EdgeInsets.symmetric(horizontal: Tok.s32),
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
                  size: Tok.i48, color: Color(0xFFFF4757)),
            ),
            const SizedBox(height: Tok.s20),
            const Text(
              "Something went wrong",
              style: TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: Tok.f18,
                color: AppThemeData.grey900,
              ),
            ),
            const SizedBox(height: Tok.s8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppThemeData.regular,
                fontSize: Tok.f14,
                color: AppThemeData.grey500,
              ),
            ),
            const SizedBox(height: Tok.s24),
            PillButton(
              label: "Retry".tr,
              gradient: Tok.accentGrad,
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
        padding: const EdgeInsets.symmetric(horizontal: Tok.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: Tok.heroGrad,
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
                  size: Tok.i48, color: Colors.white),
            ),
            const SizedBox(height: Tok.s24),
            const Text(
              "No plans yet",
              style: TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: Tok.f22,
                color: AppThemeData.grey900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: Tok.s8),
            Text(
              "No subscription plans available for your zone right now.".tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppThemeData.regular,
                fontSize: Tok.f14,
                color: AppThemeData.grey500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: Tok.s24),
            PillButton(
              label: "Refresh".tr,
              gradient: Tok.heroGrad,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}