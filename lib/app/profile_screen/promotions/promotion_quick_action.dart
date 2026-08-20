import 'package:flutter/material.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';

enum PromotionQuickAction {
  slotBooking,
  percentOffPlan,
  onePlusOneOffer,
  flatOffer,
  createPlan,
  twoPlusOneOffer,
}

extension PromotionQuickActionX on PromotionQuickAction {
  String get label {
    switch (this) {
      case PromotionQuickAction.slotBooking:
        return 'Slot Booking';
      case PromotionQuickAction.percentOffPlan:
        return '% Off Plan';
      case PromotionQuickAction.onePlusOneOffer:
        return '1+1 Offer';
      case PromotionQuickAction.flatOffer:
        return 'Flat Offer';
      case PromotionQuickAction.createPlan:
        return 'Create Plan';
      case PromotionQuickAction.twoPlusOneOffer:
        return '2+1 Offer';
    }
  }

  IconData get icon {
    switch (this) {
      case PromotionQuickAction.slotBooking:
        return Icons.calendar_month_rounded;
      case PromotionQuickAction.percentOffPlan:
        return Icons.percent_rounded;
      case PromotionQuickAction.onePlusOneOffer:
        return Icons.card_giftcard_rounded;
      case PromotionQuickAction.flatOffer:
        return Icons.currency_rupee_rounded;
      case PromotionQuickAction.createPlan:
        return Icons.add_circle_rounded;
      case PromotionQuickAction.twoPlusOneOffer:
        return Icons.redeem_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case PromotionQuickAction.slotBooking:
        return const Color(0xFF3B82F6);
      case PromotionQuickAction.percentOffPlan:
        return const Color(0xFFEF4444);
      case PromotionQuickAction.onePlusOneOffer:
        return const Color(0xFF8B5CF6);
      case PromotionQuickAction.flatOffer:
        return const Color(0xFF10B981);
      case PromotionQuickAction.createPlan:
        return const Color(0xFF6366F1);
      case PromotionQuickAction.twoPlusOneOffer:
        return const Color(0xFFF59E0B);
    }
  }
}

/// Compact quick-actions panel shown at the top of Promotions.
const double kQuickActionsPanelHeight = 132;

class PromotionQuickActionsGrid extends StatelessWidget {
  const PromotionQuickActionsGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PromotionQuickAction? selected;
  final ValueChanged<PromotionQuickAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5);
    final actions = PromotionQuickAction.values;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: SizedBox(
        height: kQuickActionsPanelHeight,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1E38) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(3, (index) {
                    final action = actions[index];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index < 2 ? 6 : 0),
                        child: _QuickActionTile(
                          action: action,
                          isSelected: selected == action,
                          onTap: () => onSelected(action),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Row(
                  children: List.generate(3, (index) {
                    final action = actions[index + 3];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index < 2 ? 6 : 0),
                        child: _QuickActionTile(
                          action: action,
                          isSelected: selected == action,
                          onTap: () => onSelected(action),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PromotionQuickActionsHint extends StatelessWidget {
  const PromotionQuickActionsHint({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 40,
              color: isDark
                  ? const Color(0xFF4B5563)
                  : const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a promotion type to continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppThemeData.medium,
                fontSize: 14,
                color: isDark
                    ? const Color(0xFF8892B0)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.action,
    required this.isSelected,
    required this.onTap,
  });

  final PromotionQuickAction action;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = action.accentColor;
    final selectedBg = accent.withValues(alpha: isDark ? 0.18 : 0.1);
    final normalBg = isDark ? const Color(0xFF111827) : const Color(0xFFFAFBFD);
    final borderColor = isSelected
        ? accent
        : (isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : normalBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isSelected ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  action.icon,
                  size: 15,
                  color: accent,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily:
                      isSelected ? AppThemeData.semiBold : AppThemeData.medium,
                  fontSize: 9,
                  height: 1.1,
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF1A1F3C))
                      : (isDark ? Colors.white70 : const Color(0xFF334155)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
