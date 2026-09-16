import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/add_outlet_controller.dart';
import '../../../../utils/input_decorations.dart';
import '../../edit_profile_screen/widgets/MerchantForm.dart';

class BankDetailsSection extends StatelessWidget {
  const BankDetailsSection({super.key, required this.controller});

  final AddOutletController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Bank Details",
      icon: Icons.account_balance,
      children: [
        _buildMerchantToggle(),
        const SizedBox(height: 16),
        _buildAccountHolder(),
        const SizedBox(height: 16),
        _buildAccountNumber(),
        const SizedBox(height: 16),
        _buildIfsc(),
        const SizedBox(height: 16),
        _buildBankName(),
      ],
    );
  }

  Widget _buildMerchantToggle() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        value: controller.useMerchantBankDetails.value,
        onChanged: (v) =>
            controller.onMerchantBankChanged(v ?? false),
        title: const Text(
          "Same as Merchant Bank Details",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.red,
      ),
    ));
  }

  Widget _buildAccountHolder() {
    return Obx(() => TextField(
      controller: controller.accountHolderController,
      readOnly: controller.useMerchantBankDetails.value,
      decoration: AppInputDecoration.box(
        labelText: "Account Holder",
        prefixIcon: const Icon(Icons.person_outline, size: 20),
        readOnly: controller.useMerchantBankDetails.value,
      ),
    ));
  }

  Widget _buildAccountNumber() {
    return Obx(() => TextField(
      controller: controller.accountNumberController,
      readOnly: controller.useMerchantBankDetails.value,
      keyboardType: TextInputType.number,
      decoration: AppInputDecoration.box(
        labelText: "Account Number",
        prefixIcon: const Icon(Icons.numbers, size: 20),
        readOnly: controller.useMerchantBankDetails.value,
      ),
    ));
  }

  Widget _buildIfsc() {
    return Obx(() => TextField(
      controller: controller.ifscController,
      readOnly: controller.useMerchantBankDetails.value,
      decoration: AppInputDecoration.box(
        labelText: "IFSC Code",
        prefixIcon: const Icon(Icons.code, size: 20),
        readOnly: controller.useMerchantBankDetails.value,
      ),
    ));
  }

  Widget _buildBankName() {
    return Obx(() => TextField(
      controller: controller.bankNameController,
      readOnly: controller.useMerchantBankDetails.value,
      decoration: AppInputDecoration.box(
        labelText: "Bank Name",
        prefixIcon: const Icon(Icons.account_balance, size: 20),
        readOnly: controller.useMerchantBankDetails.value,
      ),
    ));
  }
}