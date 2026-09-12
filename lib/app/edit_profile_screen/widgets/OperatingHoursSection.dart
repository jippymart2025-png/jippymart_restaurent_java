import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/edit_profile_controller.dart';
import '../../../themes/app_them_data.dart';

class OperatingHoursSection extends StatelessWidget {
  const OperatingHoursSection({super.key, required this.controller});
  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppThemeData.secondary300, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operating Hours'.tr,
            style: TextStyle(
              color: AppThemeData.secondary300,
              fontFamily: AppThemeData.semiBold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Obx(
                () => CheckboxListTile(
              value: controller.sameTimingForAllDays.value,
              onChanged: (v) =>
              controller.sameTimingForAllDays.value = v ?? false,
              contentPadding: EdgeInsets.zero,
              title: Text('Same timings for all days'.tr),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          const SizedBox(height: 10),
          Obx(
                () => controller.sameTimingForAllDays.value
                ? _CommonSlots(controller: controller)
                : _PerDaySlots(controller: controller),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Common slots (same timing for all days)
// ─────────────────────────────────────────────────────────
class _CommonSlots extends StatelessWidget {
  const _CommonSlots({required this.controller});
  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
              () => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.commonTimeSlots.length,
            itemBuilder: (context, i) {
              final slot = controller.commonTimeSlots[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _TimePickerField(
                        key: ValueKey('common_open_$i'),
                        label: 'Opening Time'.tr,
                        initialTime: slot['openingTime'] as String?,
                        onTimePicked: (v) =>
                            controller.updateCommonOpeningTime(i, v),
                      ),
                      const SizedBox(height: 12),
                      _TimePickerField(
                        key: ValueKey('common_close_$i'),
                        label: 'Closing Time'.tr,
                        initialTime: slot['closingTime'] as String?,
                        onTimePicked: (v) =>
                            controller.updateCommonClosingTime(i, v),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () =>
                              controller.removeCommonTimeSlot(i),
                          icon: const Icon(Icons.delete),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.addCommonTimeSlot,
            icon: const Icon(Icons.add),
            label: Text('Add Another Time Slot'.tr),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Per-day slots
// ─────────────────────────────────────────────────────────
class _PerDaySlots extends StatelessWidget {
  const _PerDaySlots({required this.controller});
  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.operatingDaysList.length,
            itemBuilder: (context, dayIndex) {
              final day = controller.operatingDaysList[dayIndex];
              final slots = day['slots'] as List<dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day['dayName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ...List.generate(slots.length, (slotIndex) {
                        final slot = slots[slotIndex];
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Slot ${slotIndex + 1}'.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints:
                                  const BoxConstraints(),
                                  onPressed: () => controller.removeTimeSlot(
                                      dayIndex, slotIndex),
                                  icon: const Icon(Icons.delete, size: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _TimePickerField(
                              key: ValueKey(
                                  'day_${day['dayOfWeekId']}_open_$slotIndex'),
                              label: 'Opening Time'.tr,
                              initialTime: slot['openingTime'] as String?,
                              onTimePicked: (v) => controller
                                  .updateOpeningTime(
                                  dayIndex, slotIndex, v),
                            ),
                            const SizedBox(height: 12),
                            _TimePickerField(
                              key: ValueKey(
                                  'day_${day['dayOfWeekId']}_close_$slotIndex'),
                              label: 'Closing Time'.tr,
                              initialTime: slot['closingTime'] as String?,
                              onTimePicked: (v) => controller
                                  .updateClosingTime(
                                  dayIndex, slotIndex, v),
                            ),
                          ],
                        );
                      }),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => controller.addTimeSlot(dayIndex),
                          icon: const Icon(Icons.add),
                          label: Text('Add Slot'.tr),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.operatingDaysList.length >= 7
                  ? null
                  : controller.addOperatingDay,
              icon: const Icon(Icons.add),
              label: Text(
                controller.operatingDaysList.length >= 7
                    ? 'All 7 Days Added'.tr
                    : '${'Add Day'.tr} (${EditProfileController.weekDays[controller.operatingDaysList.length]})',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Time Picker Field
// ─────────────────────────────────────────────────────────
class _TimePickerField extends StatefulWidget {
  const _TimePickerField({
    super.key,
    required this.label,
    required this.initialTime,
    required this.onTimePicked,
  });

  final String label;

  /// Expected format: "HH:mm" (24-hour), may be null or empty.
  final String? initialTime;

  /// Emits "HH:mm" (24-hour) — same contract as before.
  final ValueChanged<String> onTimePicked;

  @override
  State<_TimePickerField> createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<_TimePickerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Display as 12-hour AM/PM even though the value is stored as HH:mm.
    _controller = TextEditingController(
      text: _toDisplay(widget.initialTime),
    );
  }

  @override
  void didUpdateWidget(covariant _TimePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTime != oldWidget.initialTime) {
      final newDisplay = _toDisplay(widget.initialTime);
      if (_controller.text != newDisplay) {
        _controller.text = newDisplay;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final initial = _parse24h(widget.initialTime) ??
        _parse24h(_controller.text) ??
        const TimeOfDay(hour: 9, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        // Force 12-hour AM/PM display in the picker.
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    final stored24h = _format24h(picked); // e.g. "14:30"
    _controller.text = _format12h(picked); // e.g. "02:30 PM"
    widget.onTimePicked(stored24h);        // keep backend contract
  }

  // ─────────────────────────────────────────────────────────
  // Format helpers
  // ─────────────────────────────────────────────────────────

  /// "14:30" → "02:30 PM". Empty/null → "".
  String _toDisplay(String? hhmm) {
    if (hhmm == null || hhmm.isEmpty) return '';
    final t = _parse24h(hhmm);
    if (t == null) return hhmm; // fallback: show raw
    return _format12h(t);
  }

  /// "14:30" → TimeOfDay(14, 30). Also accepts "2:30 PM".
  TimeOfDay? _parse24h(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final v = value.trim().toUpperCase();

    // Try HH:mm first
    final parts = v.split(':');
    if (parts.length == 2) {
      final h = int.tryParse(parts[0]);
      final mPart = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
      final m = int.tryParse(mPart);
      if (h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60) {
        return TimeOfDay(hour: h, minute: m);
      }
    }

    // Fallback: "2:30 PM" style
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$').firstMatch(v);
    if (match != null) {
      var h = int.parse(match.group(1)!);
      final m = int.parse(match.group(2)!);
      final isPm = match.group(3) == 'PM';
      if (isPm && h != 12) h += 12;
      if (!isPm && h == 12) h = 0;
      return TimeOfDay(hour: h, minute: m);
    }

    return null;
  }

  String _format24h(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _format12h(TimeOfDay t) {
    final h24 = t.hour;
    final period = h24 >= 12 ? 'PM' : 'AM';
    var h12 = h24 % 12;
    if (h12 == 0) h12 = 12;
    final h = h12.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pickTime,
      borderRadius: BorderRadius.circular(8),
      child: IgnorePointer(
        child: TextFormField(
          controller: _controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: 'hh:mm AM/PM',
            suffixIcon: const Icon(Icons.access_time, size: 20),
          ),
        ),
      ),
    );
  }
}