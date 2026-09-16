import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/add_outlet_controller.dart';

/// Bottom sheet that lets the user pick multiple cuisine types.
class CuisinePickerSheet extends StatelessWidget {
  const CuisinePickerSheet({super.key, required this.controller});

  final AddOutletController controller;

  static Future<void> show(
      BuildContext context,
      AddOutletController controller,
      ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CuisinePickerSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDragHandle(),
            const SizedBox(height: 16),
            const Text(
              "Select Cuisine Types",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _buildList(context),
            const SizedBox(height: 10),
            _buildDoneButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: controller.cuisineTypes.map((cuisine) {
            return Obx(() {
              final selected =
              controller.isCuisineSelected(cuisine.cuisineTypeId);
              return CheckboxListTile(
                value: selected,
                title: Text(cuisine.cuisineTypeName),
                controlAffinity: ListTileControlAffinity.leading,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onChanged: (_) =>
                    controller.toggleCuisine(cuisine.cuisineTypeId),
              );
            });
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text("Done"),
      ),
    );
  }
}