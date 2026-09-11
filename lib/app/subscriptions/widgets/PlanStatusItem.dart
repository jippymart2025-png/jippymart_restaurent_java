import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../themes/app_them_data.dart';
import '../screens/promotion_action_forms.dart';

class PlansList extends StatelessWidget {
  const PlansList({required this.plans});

  final List<PlanStatusItem> plans;

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return Center(
        child: Text(
          'No plans found',
          style: TextStyle(
            fontFamily: AppThemeData.regular,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF8892B0)
                : const Color(0xFF64748B),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => PlanStatusCard(plan: plans[index]),
    );
  }
}

class PlanStatusItem {
  const PlanStatusItem({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isActive,
  });

  final String title;
  final String subtitle;
  final String status;
  final bool isActive;
}
class PlanStatusCard extends StatelessWidget {
  const PlanStatusCard({required this.plan});

  final PlanStatusItem plan;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);
    final statusColor = plan.isActive
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC3545);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: PromotionActionForms.showComingSoon,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2A3050)
                  : const Color(0xFFE8ECF5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppThemeData.secondary300.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_offer_outlined,
                  color: AppThemeData.secondary300,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        fontSize: 12,
                        color: isDark ? Colors.white : const Color(0xFF1A1F3C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plan.subtitle,
                      style: TextStyle(
                        fontFamily: AppThemeData.regular,
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF8892B0)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  plan.status,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: 10,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}