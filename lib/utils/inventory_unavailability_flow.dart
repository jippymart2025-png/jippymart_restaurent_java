import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';

enum InventoryUnavailabilityKind { product, outletCategory }

class InventoryCloseDates {
  const InventoryCloseDates({required this.from, required this.to});

  final DateTime from;
  final DateTime to;
}

/// Resolves the unavailability end date for a close-duration option.
/// "Close for today" = from now until end of tomorrow.
class InventoryUnavailabilityFlow {
  static const _kRed = Color(0xFFDC3545);

  static DateTime? resolveCloseToDate(
    RestaurantCloseOption option,
    DateTime now,
  ) {
    switch (option) {
      case RestaurantCloseOption.today:
        final tomorrow = now.add(const Duration(days: 1));
        return DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          23,
          59,
          59,
        );
      case RestaurantCloseOption.tomorrow:
        final dayAfter = now.add(const Duration(days: 2));
        return DateTime(
          dayAfter.year,
          dayAfter.month,
          dayAfter.day,
          23,
          59,
          59,
        );
      case RestaurantCloseOption.threeDays:
        return now.add(const Duration(days: 3));
      case RestaurantCloseOption.sevenDays:
        return now.add(const Duration(days: 7));
      case RestaurantCloseOption.untilReopened:
        return DateTime(2029, 12, 31, 23, 59, 59);
      case RestaurantCloseOption.custom:
        return null;
    }
  }

  static String _confirmTitle(InventoryUnavailabilityKind kind) {
    switch (kind) {
      case InventoryUnavailabilityKind.product:
        return 'Close Product?';
      case InventoryUnavailabilityKind.outletCategory:
        return 'Close Outlet Category?';
    }
  }

  static String _confirmMessage(InventoryUnavailabilityKind kind) {
    switch (kind) {
      case InventoryUnavailabilityKind.product:
        return 'Customers will not be able to order this product while it is unavailable.';
      case InventoryUnavailabilityKind.outletCategory:
        return 'Customers will not be able to order items in this category while it is unavailable.';
    }
  }

  static String _optionsTitle(InventoryUnavailabilityKind kind) {
    switch (kind) {
      case InventoryUnavailabilityKind.product:
        return 'Close Product';
      case InventoryUnavailabilityKind.outletCategory:
        return 'Close Outlet Category';
    }
  }

  static IconData _icon(InventoryUnavailabilityKind kind) {
    switch (kind) {
      case InventoryUnavailabilityKind.product:
        return Icons.fastfood_outlined;
      case InventoryUnavailabilityKind.outletCategory:
        return Icons.category_outlined;
    }
  }

  /// Confirm → duration picker → returns from/to dates, or null if cancelled.
  static Future<InventoryCloseDates?> runCloseFlow(
    BuildContext context,
    InventoryUnavailabilityKind kind,
  ) async {
    final bool ok = await showDialog<bool>(
          context: context,
          builder: (_) => _InventoryConfirmDialog(
            iconData: _icon(kind),
            title: _confirmTitle(kind),
            message: _confirmMessage(kind),
          ),
        ) ??
        false;

    if (!ok || !context.mounted) return null;

    final RestaurantCloseOption? option =
        await showDialog<RestaurantCloseOption>(
      context: context,
      builder: (_) => _InventoryCloseOptionsDialog(
        title: _optionsTitle(kind),
        iconData: _icon(kind),
      ),
    );

    if (option == null) return null;

    final now = DateTime.now();
    final toDate = resolveCloseToDate(option, now);
    if (toDate == null) return null;

    return InventoryCloseDates(from: now, to: toDate);
  }
}

class _InventoryConfirmDialog extends StatelessWidget {
  const _InventoryConfirmDialog({
    required this.iconData,
    required this.title,
    required this.message,
  });

  final IconData iconData;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: InventoryUnavailabilityFlow._kRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData,
                  color: InventoryUnavailabilityFlow._kRed, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title.tr,
              style: const TextStyle(
                fontSize: 17,
                fontFamily: AppThemeData.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontFamily: AppThemeData.regular,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Cancel'.tr,
                      style: TextStyle(
                        fontFamily: AppThemeData.medium,
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: InventoryUnavailabilityFlow._kRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close'.tr,
                      style: const TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryCloseOptionsDialog extends StatelessWidget {
  const _InventoryCloseOptionsDialog({
    required this.title,
    required this.iconData,
  });

  final String title;
  final IconData iconData;

  static const List<_CloseOption> _options = [
    _CloseOption(
      value: RestaurantCloseOption.today,
      icon: Icons.wb_sunny_outlined,
      label: 'Close for today',
      sub: 'Reopens automatically tomorrow',
    ),
    _CloseOption(
      value: RestaurantCloseOption.threeDays,
      icon: Icons.event_outlined,
      label: 'Close for 3 days',
      sub: 'Team will be notified by email',
    ),
    _CloseOption(
      value: RestaurantCloseOption.sevenDays,
      icon: Icons.date_range_outlined,
      label: 'Close for 7 days',
      sub: 'Team will be notified by email',
    ),
    _CloseOption(
      value: RestaurantCloseOption.untilReopened,
      icon: Icons.lock_outline_rounded,
      label: 'Close Until I Open',
      sub: 'Reopen manually from the dashboard',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: InventoryUnavailabilityFlow._kRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(iconData,
                      color: InventoryUnavailabilityFlow._kRed, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: AppThemeData.bold,
                      ),
                    ),
                    Text(
                      'How long should we pause orders?'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontFamily: AppThemeData.regular,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ..._options.map(
              (o) => _CloseOptionRow(
                option: o,
                onTap: () => Navigator.of(context).pop(o.value),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel'.tr,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontFamily: AppThemeData.medium,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseOption {
  const _CloseOption({
    required this.value,
    required this.icon,
    required this.label,
    required this.sub,
  });

  final RestaurantCloseOption value;
  final IconData icon;
  final String label;
  final String sub;
}

class _CloseOptionRow extends StatelessWidget {
  const _CloseOptionRow({required this.option, required this.onTap});

  final _CloseOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(option.icon,
                      size: 17, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: AppThemeData.semiBold,
                        ),
                      ),
                      Text(
                        option.sub.tr,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontFamily: AppThemeData.regular,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
