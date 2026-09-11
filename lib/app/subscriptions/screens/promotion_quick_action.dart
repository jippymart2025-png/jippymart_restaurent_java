import 'package:flutter/material.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';

enum PromotionQuickAction { slotBooking }

extension PromotionQuickActionX on PromotionQuickAction {
  String get label {
    switch (this) {
      case PromotionQuickAction.slotBooking:
        return 'Slot Booking';
    }
  }

  IconData get icon {
    switch (this) {
      case PromotionQuickAction.slotBooking:
        return Icons.calendar_month_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case PromotionQuickAction.slotBooking:
        return const Color(0xFF3B82F6);
    }
  }
}

/// Compact quick-actions panel shown at the top of Promotions.
const double kQuickActionsPanelHeight = 68;

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
    const action = PromotionQuickAction.slotBooking;

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
          child: _QuickActionTile(
            action: action,
            isSelected: selected == action,
            onTap: () => onSelected(action),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isSelected ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  action.icon,
                  size: 17,
                  color: accent,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily:
                  isSelected ? AppThemeData.semiBold : AppThemeData.medium,
                  fontSize: 13,
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