import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../../../models/selected_product_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/round_button_fill.dart';
import '../../../utils/const/color_const.dart';
import '../../../utils/dark_theme_provider.dart';

class AvailabilitySheetContent extends StatefulWidget {
  const AvailabilitySheetContent({
    required this.sel,
    required this.theme,
    required this.onDone,
  });
  final SelectedProductModel sel;
  final DarkThemeProvider theme;
  final void Function(
      List<String> days,
      Map<String, List<TimeRangeItem>> timings) onDone;

  @override
  State<AvailabilitySheetContent> createState() =>
      _AvailabilitySheetContentState();
}

class _AvailabilitySheetContentState
    extends State<AvailabilitySheetContent> {
  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late List<String> _selectedDays;
  late Map<String, List<TimeRangeItem>> _timings;

  @override
  void initState() {
    super.initState();
    _selectedDays = List<String>.from(widget.sel.availableDays);
    _timings = {
      for (final e in widget.sel.availableTimings.entries)
        e.key: List.from(e.value),
    };
  }

  void _toggleDay(String day, bool selected) {
    setState(() {
      if (selected) {
        _selectedDays.add(day);
        if (!_timings.containsKey(day)) {
          _timings[day] = [TimeRangeItem(from: '09:00', to: '22:00')];
        }
      } else {
        _selectedDays.remove(day);
        _timings.remove(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.getThem();
    final bg = isDark ? AppThemeData.grey800 : Colors.white;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetHandle(),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorConst.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.schedule_rounded,
                        size: 18, color: ColorConst.orange),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Available Days & Times'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: AppThemeData.bold,
                      color: isDark
                          ? AppThemeData.grey100
                          : AppThemeData.grey900,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                color: isDark
                    ? AppThemeData.grey700
                    : Colors.grey.shade200),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Days'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: AppThemeData.semiBold,
                      color: isDark
                          ? AppThemeData.grey400
                          : AppThemeData.grey600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _days.map((d) {
                      final on = _selectedDays.contains(d);
                      return _DayChip(
                        day: d,
                        selected: on,
                        isDark: isDark,
                        onToggle: (v) => _toggleDay(d, v),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: isDark
                    ? AppThemeData.grey700
                    : Colors.grey.shade200),
            Expanded(
              child: _selectedDays.isEmpty
                  ? Center(
                child: Text(
                  'Select days above to set hours'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppThemeData.grey500
                        : AppThemeData.grey400,
                    fontFamily: AppThemeData.regular,
                  ),
                ),
              )
                  : ListView.separated(
                controller: scrollController,
                padding:
                const EdgeInsets.fromLTRB(16, 12, 16, 8),
                itemCount: _selectedDays.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final day = _selectedDays[i];
                  final slots = _timings[day] ??
                      [
                        TimeRangeItem(from: '09:00', to: '22:00')
                      ];
                  return _DayTimeSection(
                    day: day,
                    slots: slots,
                    isDark: isDark,
                    onSlotsChanged: (updated) {
                      setState(() => _timings[day] = updated);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SafeArea(
                bottom: false,
                child: RoundedButtonFill(
                  title: 'Done'.tr,
                  color: ColorConst.orange,
                  width: 50,
                  height: 5,
                  textColor: AppThemeData.grey50,
                  onPress: () =>
                      widget.onDone(_selectedDays, _timings),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.isDark,
    required this.onToggle,
  });
  final String day;
  final bool selected;
  final bool isDark;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? ColorConst.orange
              : (isDark ? AppThemeData.grey700 : AppThemeData.grey100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? ColorConst.orange
                : (isDark ? AppThemeData.grey600 : Colors.grey.shade300),
          ),
        ),
        child: Text(
          day.substring(0, 3),
          style: TextStyle(
            fontSize: 12,
            fontFamily: AppThemeData.semiBold,
            color: selected
                ? Colors.white
                : (isDark ? AppThemeData.grey300 : AppThemeData.grey600),
          ),
        ),
      ),
    );
  }
}

class _DayTimeSection extends StatelessWidget {
  const _DayTimeSection({
    required this.day,
    required this.slots,
    required this.isDark,
    required this.onSlotsChanged,
  });
  final String day;
  final List<TimeRangeItem> slots;
  final bool isDark;
  final ValueChanged<List<TimeRangeItem>> onSlotsChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey700 : AppThemeData.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemeData.grey600 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConst.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppThemeData.semiBold,
                    color: ColorConst.orange,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  final updated = List<TimeRangeItem>.from(slots)
                    ..add(TimeRangeItem(from: '09:00', to: '22:00'));
                  onSlotsChanged(updated);
                },
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        size: 16, color: ColorConst.orange),
                    const SizedBox(width: 4),
                    Text(
                      'Add slot'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorConst.orange,
                        fontFamily: AppThemeData.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...slots.asMap().entries.map((e) {
            final idx = e.key;
            final slot = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _TimeField(
                      label: 'From'.tr,
                      initial: slot.from,
                      isDark: isDark,
                      onChanged: (v) {
                        final updated =
                        List<TimeRangeItem>.from(slots);
                        updated[idx] =
                            TimeRangeItem(from: v, to: slot.to);
                        onSlotsChanged(updated);
                      },
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_forward,
                        size: 14,
                        color: isDark
                            ? AppThemeData.grey500
                            : AppThemeData.grey400),
                  ),
                  Expanded(
                    child: _TimeField(
                      label: 'To'.tr,
                      initial: slot.to,
                      isDark: isDark,
                      onChanged: (v) {
                        final updated =
                        List<TimeRangeItem>.from(slots);
                        updated[idx] =
                            TimeRangeItem(from: slot.from, to: v);
                        onSlotsChanged(updated);
                      },
                    ),
                  ),
                  if (slots.length > 1) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        final updated =
                        List<TimeRangeItem>.from(slots)
                          ..removeAt(idx);
                        onSlotsChanged(updated);
                      },
                      child: Icon(Icons.remove_circle_outline,
                          size: 18,
                          color: isDark
                              ? AppThemeData.grey500
                              : Colors.grey.shade400),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.initial,
    required this.isDark,
    required this.onChanged,
  });
  final String label;
  final String initial;
  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial,
      keyboardType: TextInputType.datetime,
      style: TextStyle(
        fontSize: 13,
        fontFamily: AppThemeData.medium,
        color: isDark ? AppThemeData.grey100 : AppThemeData.grey900,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 11,
          color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
        ),
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        filled: true,
        fillColor: isDark ? AppThemeData.grey800 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color:
              isDark ? AppThemeData.grey600 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color:
              isDark ? AppThemeData.grey600 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
          BorderSide(color: ColorConst.orange, width: 1.5),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}