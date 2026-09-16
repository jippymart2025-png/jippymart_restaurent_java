import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/add_outlet_controller.dart';
import '../../edit_profile_screen/widgets/MerchantForm.dart';
import 'time_field.dart';

class OperatingHoursSection extends StatelessWidget {
  const OperatingHoursSection({super.key, required this.controller});

  final AddOutletController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Operating Hours",
      icon: Icons.schedule,
      children: [
        _buildSameTimingToggle(),
        const SizedBox(height: 16),
        Obx(() => controller.sameTimingForAllDays.value
            ? _buildCommonSlots(context)
            : _buildPerDaySlots(context)),
      ],
    );
  }

  Widget _buildSameTimingToggle() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            value: controller.sameTimingForAllDays.value,
            onChanged: (v) =>
                controller.sameTimingForAllDays.value = v ?? false,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: const Text(
              "Same timings for all days",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Colors.red,
          ),
        ));
  }

  // ---------------- SAME TIMING SLOTS ----------------
  Widget _buildCommonSlots(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.commonTimeSlots.length,
          itemBuilder: (context, index) {
            final slot = controller.commonTimeSlots[index];

            return _SlotCard(
              title: "Slot ${index + 1}",
              onDelete: () => controller.removeCommonTimeSlot(index),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TimeField(
                        label: "Opening Time",
                        value: slot["openingTime"].toString(),
                        icon: Icons.wb_sunny_outlined,
                        onTap: () =>
                            controller.pickCommonOpeningTime(context, index),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TimeField(
                        label: "Closing Time",
                        value: slot["closingTime"].toString(),
                        icon: Icons.nights_stay_outlined,
                        onTap: () =>
                            controller.pickCommonClosingTime(context, index),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        _buildAddButton(
          label: "Add Another Time Slot",
          onPressed: controller.addCommonTimeSlot,
        ),
      ],
    );
  }

  // ---------------- PER-DAY SLOTS ----------------
  Widget _buildPerDaySlots(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.operatingDays.length,
          itemBuilder: (context, dayIndex) =>
              _buildDayCard(context, dayIndex),
        ),
        const SizedBox(height: 8),
        _buildAddButton(
          label: controller.operatingDays.length >= 7
              ? "All 7 Days Added"
              : "Add Day (${controller.weekDays[controller.operatingDays.length]})",
          onPressed: controller.operatingDays.length >= 7
              ? null
              : controller.addOperatingDay,
        ),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, int dayIndex) {
    final day = controller.operatingDays[dayIndex];
    final slots = day["slots"] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day["dayName"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
              IconButton(
                onPressed: () => controller.removeOperatingDay(dayIndex),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...List.generate(slots.length, (slotIndex) =>
              _buildSlotRow(context, dayIndex, slotIndex, slots)),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => controller.addTimeSlot(dayIndex),
              icon: const Icon(Icons.add, color: Colors.red),
              label: const Text(
                "Add Slot",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotRow(
    BuildContext context,
    int dayIndex,
    int slotIndex,
    List<dynamic> slots,
  ) {
    final slot = slots[slotIndex];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TimeField(
                  label: "Opening Time",
                  value: slot["openingTime"].toString(),
                  icon: Icons.wb_sunny_outlined,
                  onTap: () => controller.pickOpeningTime(
                    context,
                    dayIndex,
                    slotIndex,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TimeField(
                  label: "Closing Time",
                  value: slot["closingTime"].toString(),
                  icon: Icons.nights_stay_outlined,
                  onTap: () => controller.pickClosingTime(
                    context,
                    dayIndex,
                    slotIndex,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () =>
                  controller.removeTimeSlot(dayIndex, slotIndex),
              icon: const Icon(Icons.delete, size: 16, color: Colors.red),
              label: const Text(
                "Remove Slot",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ),
          if (slotIndex < slots.length - 1) const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Small internal card used for common time slots.
class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.title,
    required this.onDelete,
    required this.children,
  });

  final String title;
  final VoidCallback onDelete;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}