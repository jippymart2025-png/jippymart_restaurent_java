import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jippymart_restaurant/app/subscriptions/widgets/tok.dart';

import '../../../constant/constant.dart';
import '../../../models/subscription_plan_model.dart';
import '../../../themes/app_them_data.dart';

class CurrentPlanCard extends StatelessWidget {
  const CurrentPlanCard({required this.plan, this.onRefresh});
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
      padding: const EdgeInsets.all(Tok.s14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Tok.r16),
        border: Border.all(color: border.withOpacity(0.6), width: 1.1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Tok.s8),
            decoration: BoxDecoration(
              color: border.withOpacity(0.15),
              borderRadius: BorderRadius.circular(Tok.r12),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: Tok.i22,
              color: Color(0xFFEA580C),
            ),
          ),
          const SizedBox(width: Tok.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current plan'.tr,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: Tok.f12,
                    color: text.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: Tok.s2),
                Text(
                  plan.planName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: Tok.f15,
                    color: text,
                  ),
                ),
                const SizedBox(height: Tok.s2),
                Row(
                  children: [
                    Text(
                      Constant.amountShow(amount: '${plan.price}'),
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        fontSize: Tok.f13,
                        color: text.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: Tok.s6),
                    Text(
                      '• $validityText',
                      style: TextStyle(
                        fontFamily: AppThemeData.regular,
                        fontSize: Tok.f12,
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
              borderRadius: BorderRadius.circular(Tok.r99),
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
