import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../controller/edit_profile_controller.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/text_field_widget.dart';
import 'BankInfoSection.dart';

class MerchantForm extends StatelessWidget {
  const MerchantForm({required this.controller});
  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldWidget(
          title: 'Merchant Name'.tr,
          controller: controller.merchantNameController,
          hintText: 'Merchant Name'.tr,
        ),
        TextFieldWidget(
          title: 'Email'.tr,
          textInputType: TextInputType.emailAddress,
          controller: controller.emailController,
          hintText: 'Email'.tr,
          enable: false,
        ),
        TextFieldWidget(
          title: 'Phone Number'.tr,
          controller: controller.phoneNumberController,
          hintText: 'Phone Number'.tr,
          enable: false,
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Business Information',
          children: [
            TextFieldWidget(
              title: 'Business Type'.tr,
              controller: controller.businessTypeController,
              hintText: 'Business Type'.tr,
            ),
          ],
        ),
        SectionCard(
          title: 'documents',
          children: [
            TextFieldWidget(
              title: 'aadhar number'.tr,
              controller: controller.aadharController,
              hintText: 'aadhar number'.tr,
            ),
            TextFieldWidget(
              title: 'pan Number'.tr,
              controller: controller.panController,
              hintText: 'pan Number'.tr,
            ),
          ],
        ),
        BankInfoSection(controller: controller),
      ],
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppThemeData.secondary300, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
            const EdgeInsets.only(left: 12, top: 10, bottom: 4),
            child: Text(
              title.tr,
              style: TextStyle(
                color: AppThemeData.secondary300,
                fontFamily: AppThemeData.semiBold,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(children: children),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
