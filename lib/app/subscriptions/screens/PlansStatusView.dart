import 'package:flutter/material.dart';

import '../../../themes/app_them_data.dart';
import '../widgets/PlanStatusItem.dart';

class PlansStatusView extends StatefulWidget {
  const PlansStatusView({super.key});

  @override
  State<PlansStatusView> createState() => _PlansStatusViewState();
}
class _PlansStatusViewState extends State<PlansStatusView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
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
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Active / Scheduled'),
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