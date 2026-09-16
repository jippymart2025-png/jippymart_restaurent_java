import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/add_outlet_controller.dart';
import 'widgets/address_info_section.dart';
import 'widgets/bank_details_section.dart';
import 'widgets/operating_hours_section.dart';
import 'widgets/outlet_info_section.dart';

class AddOutletScreen extends StatelessWidget {
  AddOutletScreen({super.key});

  final AddOutletController controller = Get.put(AddOutletController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Outlet Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            OutletInfoSection(controller: controller),
            AddressInfoSection(controller: controller),
            OperatingHoursSection(controller: controller),
            BankDetailsSection(controller: controller),
            const SizedBox(height: 10),
            _buildSaveButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.red.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () async {
          if (!controller.validateOutletForm()) return;
          await controller.submitOutlet();
        },
        child: const Text(
          "Save Outlet",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}