import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constant/show_toast_dialog.dart' show ShowToastDialog;
import '../../../themes/app_them_data.dart';
import '../../../themes/round_button_fill.dart';
import '../../../utils/dark_theme_provider.dart';

/// Collects the mandatory rejection reason for
/// `POST /api/co/acceptOrRejectOrderByOutlet`. Pops with the trimmed reason, or
/// with `null` when the outlet cancels.
class RejectOrderDialog extends StatefulWidget {
  final DarkThemeProvider themeChange;

  const RejectOrderDialog({
    super.key,
    required this.themeChange,
  });

  @override
  State<RejectOrderDialog> createState() => _RejectOrderDialogState();
}

class _RejectOrderDialogState extends State<RejectOrderDialog> {
  static const List<String> _quickReasons = [
    'Item unavailable',
    'Kitchen closed',
    'Too many orders',
    'Outside delivery area',
  ];

  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _applyQuickReason(String reason) {
    _reasonController.value = TextEditingValue(
      text: reason,
      selection: TextSelection.collapsed(offset: reason.length),
    );
  }

  void _submit() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ShowToastDialog.showToast('Please enter a rejection reason'.tr);
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeChange.getThem();
    final surface = isDark ? AppThemeData.surfaceDark : AppThemeData.surface;
    final titleColor =
        isDark ? AppThemeData.grey100 : AppThemeData.grey800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: surface,
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                'Reject order'.tr,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  color: titleColor,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Reason for rejection'.tr,
                    style: TextStyle(
                      fontFamily: AppThemeData.medium,
                      fontSize: 15,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: TextField(
                        controller: _reasonController,
                        maxLines: 3,
                        minLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontFamily: AppThemeData.medium,
                          fontSize: 15,
                          color: isDark
                              ? AppThemeData.grey100
                              : AppThemeData.grey900,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          hintText: 'Enter rejection reason'.tr,
                          hintStyle: const TextStyle(
                            fontFamily: AppThemeData.medium,
                            fontSize: 15,
                            color: AppThemeData.grey500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _reasonController,
                    builder: (_, value, __) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickReasons
                          .map((reason) {
                            final selected = value.text.trim() == reason;
                            return ActionChip(
                              label: Text(
                                reason.tr,
                                style: const TextStyle(
                                  fontFamily: AppThemeData.medium,
                                  fontSize: 13,
                                ),
                              ),
                              backgroundColor: selected
                                  ? AppThemeData.secondary300
                                      .withValues(alpha: 0.15)
                                  : Colors.transparent,
                              side: BorderSide(
                                color: selected
                                    ? AppThemeData.secondary300
                                    : Colors.grey.shade300,
                              ),
                              onPressed: () => _applyQuickReason(reason),
                            );
                          })
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: RoundedButtonFill(
                          title: 'Cancel'.tr,
                          color: isDark
                              ? AppThemeData.grey700
                              : AppThemeData.grey200,
                          textColor: isDark
                              ? AppThemeData.grey100
                              : AppThemeData.grey800,
                          onPress: Get.back,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RoundedButtonFill(
                          title: 'Reject order'.tr,
                          color: AppThemeData.new_primary,
                          textColor: AppThemeData.grey50,
                          onPress: _submit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
