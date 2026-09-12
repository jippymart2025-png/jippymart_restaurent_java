import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../controller/edit_profile_controller.dart';
import '../../../themes/text_field_widget.dart';
import 'MerchantForm.dart';

class BankInfoSection extends StatelessWidget {
  const BankInfoSection({required this.controller});
  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Bank Information',
      children: [
        TextFieldWidget(
          title: 'Bank Name'.tr,
          controller: controller.bankNameController,
          hintText: 'Bank Name'.tr,
        ),
        TextFieldWidget(
          title: 'Account Holder Name'.tr,
          controller: controller.accountHolderNameController,
          hintText: 'Account Holder Name'.tr,
        ),
        TextFieldWidget(
          title: 'Account Number'.tr,
          controller: controller.accountNumberController,
          hintText: 'Account Number'.tr,
          textInputType: TextInputType.number,
        ),
        TextFieldWidget(
          title: 'IFSC Code'.tr,
          controller: controller.ifscCodeController,
          hintText: 'IFSC Code'.tr,
        ),
      ],
    );
  }
}
