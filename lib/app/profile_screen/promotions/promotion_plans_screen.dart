import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import '../../../../controller/promotion_plans_controller.dart';
import '../../../../models/promotion_models.dart';
import '../../../constant/show_toast_dialog.dart';
import 'create_promotion_plan_screen.dart';

class PromotionPlansScreen extends StatefulWidget {
  const PromotionPlansScreen({super.key, this.showBackButton = false});
  final bool showBackButton;

  @override
  State<PromotionPlansScreen> createState() => _PromotionPlansScreenState();
}

class _PromotionPlansScreenState extends State<PromotionPlansScreen> {
  final controller = Get.isRegistered<PromotionPlansController>()
      ? Get.find<PromotionPlansController>()
      : Get.put(PromotionPlansController());

  @override
  void initState() {
    super.initState();
    // Every time this screen is opened, check if the active outlet
    // changed since the last fetch — if so, refetch instead of
    // showing the previous outlet's cached plans.
    controller.refreshIfOutletChanged();
  }

  Future<void> _openEditPlan(PromotionPlanModel plan) async {
    if (plan.promotionPlanId == null) return;

    ShowToastDialog.showLoader('Loading plan...');
    final fullPlan = await controller.fetchPlanDetails(plan.promotionPlanId!);
    ShowToastDialog.closeLoader();

    if (fullPlan == null) {
      Get.snackbar('Error', 'Could not load plan details');
      return;
    }

    Get.to(() => CreatePromotionPlanScreen(existingPlan: fullPlan));
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryOrange = Color(0xFFF95B12);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        )
            : null,
        title: Text(
          'Outlet Promotion Plans',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontFamily: AppThemeData.semiBold,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          backgroundColor: primaryOrange,
          elevation: 0,
          onPressed: () => Get.to(() => const CreatePromotionPlanScreen()),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      body: Column(
        children: [
          // Colorful Status Filter Row (Including ALL)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusButton('ALL', 'All', controller.counts.value.total, primaryOrange, controller, isDark),
                  const SizedBox(width: 6),
                  _buildStatusButton('ACTIVE', 'Active', controller.counts.value.active, const Color(0xFF10B981), controller, isDark),
                  const SizedBox(width: 6),
                  _buildStatusButton('SCHEDULED', 'Scheduled', controller.counts.value.scheduled, const Color(0xFF3B82F6), controller, isDark),
                  const SizedBox(width: 6),
                  _buildStatusButton('ENDED', 'Ended', controller.counts.value.ended, const Color(0xFF64748B), controller, isDark),
                ],
              );
            }),
          ),

          // Filtered Outlet Plans List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: primaryOrange));
              }

              if (controller.filteredPlansList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryOrange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_offer_rounded, size: 40, color: primaryOrange),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No promotion plans found',
                        style: TextStyle(
                          fontFamily: AppThemeData.semiBold,
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Try switching filters or create a new plan',
                        style: TextStyle(
                          fontFamily: AppThemeData.medium,
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: primaryOrange,
                onRefresh: controller.fetchInitialData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredPlansList.length,
                  itemBuilder: (context, index) {
                    final plan = controller.filteredPlansList[index];
                    return _buildPlanCard(plan, isDark, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String statusKey, String label, int count, Color activeColor, PromotionPlansController controller, bool isDark) {
    final isSelected = controller.selectedStatusTab.value == statusKey;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.filterPlansByStatus(statusKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            '$label ($count)',
            style: TextStyle(
              fontSize: 10.5,
              fontFamily: isSelected ? AppThemeData.bold : AppThemeData.medium,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
  Widget _buildPlanCard(PromotionPlanModel plan, bool isDark, PromotionPlansController controller) {
    Color statusColor;
    switch (plan.status?.toUpperCase()) {
      case 'ACTIVE':
        statusColor = const Color(0xFF10B981);
        break;
      case 'SCHEDULED':
        statusColor = const Color(0xFF3B82F6);
        break;
      default:
        statusColor = const Color(0xFF64748B);
    }

    return GestureDetector(
      onTap: () => _openEditPlan(plan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: statusColor, width: 4),
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        plan.offerName,
                        style: TextStyle(
                          fontFamily: AppThemeData.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        plan.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: AppThemeData.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (plan.promotionPlanType != null && plan.promotionPlanType!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF95B12).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      plan.promotionPlanType!,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: AppThemeData.semiBold,
                        color: const Color(0xFFF95B12),
                      ),
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 15, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      '${plan.planStartDate} - ${plan.planEndDate}',
                      style: TextStyle(fontSize: 13, fontFamily: AppThemeData.semiBold, color: isDark ? Colors.white : Colors.black87),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time_rounded, size: 15, color: isDark ? Colors.white70 : Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      '${plan.planStartTime} - ${plan.planEndTime}',
                      style: TextStyle(fontSize: 13, fontFamily: AppThemeData.semiBold, color: isDark ? Colors.white : Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        plan.offerType.toUpperCase() == '% OFF'
                            ? '${plan.offerAmount.toInt()}% OFF'
                            : 'Off: ₹${plan.offerAmount.toInt()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: AppThemeData.semiBold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}