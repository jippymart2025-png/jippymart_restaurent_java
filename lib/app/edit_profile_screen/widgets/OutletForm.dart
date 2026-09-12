import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../controller/edit_profile_controller.dart';
import '../../../themes/text_field_widget.dart';
import 'BankInfoSection.dart';
import 'MerchantForm.dart';
import 'OperatingHoursSection.dart';

class OutletForm extends StatelessWidget {
  const OutletForm({required this.controller});
  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          title: 'Outlet Information',
          children: [
            TextFieldWidget(
              title: 'Outlet Name'.tr,
              controller: controller.outletNameController,
              hintText: 'Outlet Name'.tr,
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
              controller: controller.outletPhoneController,
              hintText: 'Phone Number'.tr,
              enable: false,
            ),
            TextFieldWidget(
              title: 'Alternate Phone Number'.tr,
              controller: controller.alternatePhoneController,
              hintText: 'Alternate Phone Number'.tr,
              textInputType: TextInputType.phone,
            ),
            TextFieldWidget(
              title: 'FSSAI Number'.tr,
              controller: controller.fssaiNumberController,
              hintText: 'FSSAI Number'.tr,
              textInputType: TextInputType.number,
            ),
            TextFieldWidget(
              title: 'GST Number'.tr,
              controller: controller.gstNumberController,
              hintText: 'GST Number'.tr,
              enable: false,
            ),
            Obx(() {
              final names = controller.selectedCuisineNames;
              return InkWell(
                onTap: () => _showCuisinePicker(context, controller),
                child: IgnorePointer(
                  child: TextFieldWidget(
                    title: 'Cuisine Type'.tr,
                    controller:
                    TextEditingController(text: names),
                    hintText: 'Select Cuisine Types'.tr,
                  ),
                ),
              );
            }),
            TextFieldWidget(
              title: 'Delivery Radius (km)'.tr,
              controller: controller.radiusController,
              hintText: 'Radius'.tr,
              textInputType: TextInputType.number,
            ),
          ],
        ),
        OperatingHoursSection(controller: controller),
        SectionCard(
          title: 'Address Information',
          children: [
            TextFieldWidget(
              title: 'Building Number'.tr,
              controller: controller.buildingNumberController,
              hintText: 'Building Number'.tr,
            ),
            TextFieldWidget(
              title: 'Road'.tr,
              controller: controller.roadController,
              hintText: 'Road'.tr,
            ),
            TextFieldWidget(
              title: 'Landmark'.tr,
              controller: controller.landmarkController,
              hintText: 'Landmark'.tr,
            ),
            TextField(
              controller: controller.locationDisplayController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Outlet Location'.tr,
                hintText: 'Outlet location',
                suffixIcon: const Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
          ],
        ),
        BankInfoSection(controller: controller),
      ],
    );
  }

  void _showCuisinePicker(
      BuildContext context, EditProfileController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Cuisine Types'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                  MediaQuery.of(context).size.height * 0.5,
                ),
                child: Obx(() {
                  if (controller.isCuisineLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: controller.cuisineTypes.map((cuisine) {
                        return Obx(() => CheckboxListTile(
                          value: controller.isCuisineSelected(
                              cuisine.cuisineTypeId),
                          title: Text(cuisine.cuisineTypeName),
                          controlAffinity:
                          ListTileControlAffinity.leading,
                          onChanged: (_) => controller
                              .toggleCuisine(cuisine.cuisineTypeId),
                        ));
                      }).toList(),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Done'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
