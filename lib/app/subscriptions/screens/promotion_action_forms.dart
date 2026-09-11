import 'package:flutter/material.dart';
import 'package:jippymart_restaurant/app/subscriptions/widgets/PlanStatusItem.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';

class PromotionActionForms {
  static void showComingSoon() {
    ShowToastDialog.showToast('This feature will be available soon');
  }
}

/// Default promotions panel: Active / Scheduled / Ended plan lists.
class PromotionPlansStatusPanel extends StatefulWidget {
  const PromotionPlansStatusPanel({super.key});

  @override
  State<PromotionPlansStatusPanel> createState() =>
      _PromotionPlansStatusPanelState();
}

class _PromotionPlansStatusPanelState extends State<PromotionPlansStatusPanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;
    final borderColor =
    isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: AppThemeData.secondary300,
              unselectedLabelColor:
              isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B),
              indicatorColor: AppThemeData.secondary300,
              labelStyle: const TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: 11,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: AppThemeData.medium,
                fontSize: 11,
              ),
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Scheduled'),
                Tab(text: 'Ended'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  PlansList(
                    plans: const [
                      PlanStatusItem(
                        title: 'Lunch & Dinner Special',
                        subtitle: '11:00 AM – 02:00 PM • 15% off',
                        status: 'Active',
                        isActive: true,
                      ),
                    ],
                  ),
                  PlansList(
                    plans: const [
                      PlanStatusItem(
                        title: 'Weekend % Off',
                        subtitle: 'Sat – Sun • 20% off',
                        status: 'Scheduled',
                        isActive: true,
                      ),
                    ],
                  ),
                  PlansList(
                    plans: const [
                      PlanStatusItem(
                        title: 'New Year Flat Offer',
                        subtitle: '₹50 off • Min ₹300',
                        status: 'Ended',
                        isActive: false,
                      ),
                    ],
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
