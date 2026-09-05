import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/edit_profile_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/responsive.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/themes/text_field_widget.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';
import '../add_restaurant_screen/locationselection.dart';
import '../../constant/show_toast_dialog.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SafeArea(
      child: GetX(
          init: EditProfileController(),
          builder: (controller) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppThemeData.secondary300,
                centerTitle: false,
                titleSpacing: 0,
                iconTheme:
                    const IconThemeData(color: AppThemeData.grey50, size: 20),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            controller.profileImage.isEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.asset(
                                      Constant.userPlaceHolder,
                                      height: Responsive.width(24, context),
                                      width: Responsive.width(24, context),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Constant().hasValidUrl(
                                            controller.profileImage.value) ==
                                        false
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: Image.file(
                                          File(controller.profileImage.value),
                                          height: Responsive.width(24, context),
                                          width: Responsive.width(24, context),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: NetworkImageWidget(
                                          fit: BoxFit.cover,
                                          imageUrl: controller.profileImage.value,
                                          height: Responsive.width(24, context),
                                          width: Responsive.width(24, context),
                                          errorWidget: Image.asset(
                                            Constant.userPlaceHolder,
                                            fit: BoxFit.cover,
                                            height: Responsive.width(24, context),
                                            width: Responsive.width(24, context),
                                          ),
                                        ),
                                      ),
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                    onTap: () {
                                      buildBottomSheet(context, controller);
                                    },
                                    child: SvgPicture.asset(
                                        "assets/icons/ic_edit.svg")))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Obx(() {
                        if (controller.isOutletMode.value) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TextFieldWidget(
                              //   title: 'Outlet Name'.tr,
                              //   controller: controller.outletNameController.value,
                              //   hintText: 'Outlet Name'.tr,
                              // ),
                              // TextFieldWidget(
                              //   title: 'Email'.tr,
                              //   textInputType: TextInputType.emailAddress,
                              //   controller: controller.emailController.value,
                              //   hintText: 'Email'.tr,
                              // ),
                              // TextFieldWidget(
                              //   title: 'Phone Number'.tr,
                              //   controller: controller.outletPhoneController.value,
                              //   hintText: 'Phone Number'.tr,
                              // ),
                              // TextFieldWidget(
                              //   title: 'Alternate Phone Number'.tr,
                              //   controller: controller.alternatePhoneController.value,
                              //   hintText: 'Alternate Phone Number'.tr,
                              //   textInputType: TextInputType.phone,
                              // ),
                              // Obx(() {
                              //   final selectedNames = controller.cuisineTypes
                              //       .where((c) => controller.isCuisineSelected(c.cuisineTypeId))
                              //       .map((c) => c.cuisineTypeName)
                              //       .join(", ");
                              //
                              //   return InkWell(
                              //     onTap: () => _showCuisinePicker(context, controller),
                              //     child: TextFieldWidget(
                              //       title: 'Cuisine Type'.tr,
                              //       controller: TextEditingController(text: selectedNames),
                              //       hintText: 'Select Cuisine Types'.tr,
                              //       enable: false,
                              //     ),
                              //   );
                              // }),
                              // TextFieldWidget(
                              //   title: 'FSSAI Number'.tr,
                              //   controller: controller.fssaiNumberController.value,
                              //   hintText: 'FSSAI Number'.tr,
                              //   textInputType: TextInputType.number,
                              // ),
                              // TextFieldWidget(
                              //   title: 'GST Number'.tr,
                              //   controller: controller.gstNumberController.value,
                              //   hintText: 'GST Number'.tr,
                              // ),
                              // TextFieldWidget(
                              //   title: 'Delivery Radius (km)'.tr,
                              //   controller: controller.radiusController.value,
                              //   hintText: 'Radius'.tr,
                              //   textInputType: TextInputType.number,
                              // ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppThemeData.secondary300,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        top: 10,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        'Outlet Information'.tr,
                                        style: TextStyle(
                                          color: AppThemeData.secondary300,
                                          fontFamily: AppThemeData.semiBold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Column(
                                        children: [
                                          TextFieldWidget(
                                            title: 'Outlet Name'.tr,
                                            controller: controller.outletNameController.value,
                                            hintText: 'Outlet Name'.tr,
                                          ),
                                          TextFieldWidget(
                                            title: 'Email'.tr,
                                            textInputType: TextInputType.emailAddress,
                                            controller: controller.emailController.value,
                                            hintText: 'Email'.tr,
                                            enable: false,
                                          ),
                                          TextFieldWidget(
                                            title: 'Phone Number'.tr,
                                            controller: controller.outletPhoneController.value,
                                            hintText: 'Phone Number'.tr,
                                            enable: false,
                                          ),
                                          TextFieldWidget(
                                            title: 'Alternate Phone Number'.tr,
                                            controller: controller.alternatePhoneController.value,
                                            hintText: 'Alternate Phone Number'.tr,
                                            textInputType: TextInputType.phone,
                                          ),
                                          TextFieldWidget(
                                            title: 'FSSAI Number'.tr,
                                            controller: controller.fssaiNumberController.value,
                                            hintText: 'FSSAI Number'.tr,
                                            textInputType: TextInputType.number,
                                            enable: false,
                                          ),
                                          TextFieldWidget(
                                            title: 'GST Number'.tr,
                                            controller: controller.gstNumberController.value,
                                            hintText: 'GST Number'.tr,
                                            enable: false,
                                          ),
                                          Obx(() {
                                            final selectedNames = controller.cuisineTypes
                                                .where((c) => controller.isCuisineSelected(c.cuisineTypeId))
                                                .map((c) => c.cuisineTypeName)
                                                .join(", ");

                                            return InkWell(
                                              onTap: () => _showCuisinePicker(context, controller),
                                              child: TextFieldWidget(
                                                title: 'Cuisine Type'.tr,
                                                controller: TextEditingController(text: selectedNames),
                                                hintText: 'Select Cuisine Types'.tr,
                                                //enable: false,
                                              ),
                                            );
                                          }),
                                          TextFieldWidget(
                                            title: 'Delivery Radius (km)'.tr,
                                            controller: controller.radiusController.value,
                                            hintText: 'Radius'.tr,
                                            textInputType: TextInputType.number,
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppThemeData.secondary300,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
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

                                      Obx(() => CheckboxListTile(
                                        value: controller.sameTimingForAllDays.value,
                                        onChanged: (value) {
                                          controller.sameTimingForAllDays.value = value!;
                                        },
                                        contentPadding: EdgeInsets.zero,
                                        title: Text('Same timings for all days'.tr),
                                        controlAffinity: ListTileControlAffinity.leading,
                                      )),

                                      const SizedBox(height: 10),

                                      Obx(() {
                                        if (controller.sameTimingForAllDays.value) {
                                          return Column(
                                            children: [
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: controller.commonTimeSlots.length,
                                                itemBuilder: (context, slotIndex) {
                                                  final slot = controller.commonTimeSlots[slotIndex];

                                                  return Card(
                                                    margin: const EdgeInsets.only(bottom: 12),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(12),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const SizedBox(height: 12),
                                                          TextFormField(
                                                            initialValue: slot["openingTime"],
                                                            decoration: InputDecoration(
                                                              labelText: 'Opening Time'.tr,
                                                              hintText: "09:00",
                                                            ),
                                                            onChanged: (value) {
                                                              controller.updateCommonOpeningTime(
                                                                  slotIndex, value);
                                                            },
                                                          ),
                                                          const SizedBox(height: 12),
                                                          TextFormField(
                                                            initialValue: slot["closingTime"],
                                                            decoration: InputDecoration(
                                                              labelText: 'Closing Time'.tr,
                                                              hintText: "22:00",
                                                            ),
                                                            onChanged: (value) {
                                                              controller.updateCommonClosingTime(
                                                                  slotIndex, value);
                                                            },
                                                          ),
                                                          Align(
                                                            alignment: Alignment.centerRight,
                                                            child: IconButton(
                                                              onPressed: () {
                                                                controller
                                                                    .removeCommonTimeSlot(slotIndex);
                                                              },
                                                              icon: const Icon(Icons.delete),
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
                                                  onPressed: controller.addCommonTimeSlot,
                                                  icon: const Icon(Icons.add),
                                                  label: Text('Add Another Time Slot'.tr),
                                                ),
                                              ),
                                            ],
                                          );
                                        }

                                        return Column(
                                          children: [
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: controller.operatingDaysList.length,
                                              itemBuilder: (context, dayIndex) {
                                                final day = controller.operatingDaysList[dayIndex];
                                                final slots = day["slots"] as List<dynamic>;

                                                return Card(
                                                  margin: const EdgeInsets.only(bottom: 12),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(12),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          day["dayName"],
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
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                                    constraints: const BoxConstraints(),
                                                                    onPressed: () {
                                                                      controller.removeTimeSlot(dayIndex, slotIndex);
                                                                    },
                                                                    icon: const Icon(Icons.delete, size: 20),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(height: 8),
                                                              TextFormField(
                                                                initialValue: slot["openingTime"],
                                                                decoration: InputDecoration(
                                                                  labelText: 'Opening Time'.tr,
                                                                  hintText: "09:00",
                                                                ),
                                                                onChanged: (value) {
                                                                  controller.updateOpeningTime(dayIndex, slotIndex, value);
                                                                },
                                                              ),
                                                              const SizedBox(height: 12),
                                                              TextFormField(
                                                                initialValue: slot["closingTime"],
                                                                decoration: InputDecoration(
                                                                  labelText: 'Closing Time'.tr,
                                                                  hintText: "22:00",
                                                                ),
                                                                onChanged: (value) {
                                                                  controller.updateClosingTime(dayIndex, slotIndex, value);
                                                                },
                                                              ),

                                                            ],
                                                          );
                                                        }),
                                                        SizedBox(
                                                          width: double.infinity,
                                                          child: TextButton.icon(
                                                            onPressed: () {
                                                              controller.addTimeSlot(dayIndex);
                                                            },
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
                                                      : '${'Add Day'.tr} (${controller.weekDays[controller.operatingDaysList.length]})',
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppThemeData.secondary300,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        top: 10,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        'Address Information'.tr,
                                        style: TextStyle(
                                          color: AppThemeData.secondary300,
                                          fontFamily: AppThemeData.semiBold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Column(
                                        children: [

                                          TextFieldWidget(
                                            title: 'Building Number'.tr,
                                            controller:
                                            controller.buildingNumberController.value,
                                            hintText: 'Building Number'.tr,
                                          ),

                                          TextFieldWidget(
                                            title: 'Road'.tr,
                                            controller:
                                            controller.roadController.value,
                                            hintText: 'Road'.tr,
                                          ),

                                          TextFieldWidget(
                                            title: 'Landmark'.tr,
                                            controller:
                                            controller.landmarkController.value,
                                            hintText: 'Landmark'.tr,
                                          ),
                                          InkWell(
                                            onTap: () => _openLocationPickerForEdit(context, controller),
                                            child: IgnorePointer(
                                              child: TextField(
                                                controller: controller.locationDisplayController,
                                                decoration: InputDecoration(
                                                  labelText: 'Outlet Location'.tr,
                                                  hintText: 'Tap to select on map',
                                                  suffixIcon: const Icon(Icons.location_on),
                                                ),
                                                maxLines: 2,
                                              ),
                                            ),
                                          ),


                                          // STATE DROPDOWN WILL COME HERE

                                          // CITY DROPDOWN WILL COME HERE

                                          // AREA DROPDOWN WILL COME HERE

                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppThemeData.secondary300,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        top: 10,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        'Bank Information'.tr,
                                        style: TextStyle(
                                          color: AppThemeData.secondary300,
                                          fontFamily: AppThemeData.semiBold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Column(
                                        children: [
                                          TextFieldWidget(
                                            title: 'Bank Name'.tr,
                                            controller:
                                            controller.bankNameController.value,
                                            hintText: 'Bank Name'.tr,
                                          ),

                                          TextFieldWidget(
                                            title: 'Account Holder Name'.tr,
                                            controller:
                                            controller.accountHolderNameController.value,
                                            hintText: 'Account Holder Name'.tr,
                                          ),

                                          TextFieldWidget(
                                            title: 'Account Number'.tr,
                                            controller:
                                            controller.accountNumberController.value,
                                            hintText: 'Account Number'.tr,
                                            textInputType: TextInputType.number,
                                          ),

                                          TextFieldWidget(
                                            title: 'IFSC Code'.tr,
                                            controller:
                                            controller.ifscCodeController.value,
                                            hintText: 'IFSC Code'.tr,
                                          ),

                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFieldWidget(
                              title: 'Merchant Name'.tr,
                              controller: controller.merchantNameController.value,
                              hintText: 'Merchant Name'.tr,
                            ),
                            TextFieldWidget(
                              title: 'Email'.tr,
                              textInputType: TextInputType.emailAddress,
                              controller: controller.emailController.value,
                              hintText: 'Email'.tr,
                              enable: false,
                            ),
                            TextFieldWidget(
                              title: 'Phone Number'.tr,
                              controller: controller.phoneNumberController.value,
                              hintText: 'Phone Number'.tr,
                              enable: false,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppThemeData.secondary300, width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12, top: 10, bottom: 4),
                                    child: Text(
                                      'Business Information'.tr,
                                      style: TextStyle(
                                        color: AppThemeData.secondary300,
                                        fontFamily: AppThemeData.semiBold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Column(
                                      children: [
                                        TextFieldWidget(
                                          title: 'Business Type'.tr,
                                          controller: controller.businessTypeController.value,
                                          hintText: 'Business Type'.tr,
                                        ),
                                        // TextFieldWidget(
                                        //   title: 'Status'.tr,
                                        //   controller: controller.statusController.value,
                                        //   hintText: 'Status'.tr,
                                        //   enable: false,
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppThemeData.secondary300, width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12, top: 10, bottom: 4),
                                    child: Text(
                                      'Bank Information'.tr,
                                      style: TextStyle(
                                        color: AppThemeData.secondary300,
                                        fontFamily: AppThemeData.semiBold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Column(
                                      children: [
                                        TextFieldWidget(
                                          title: 'Bank Name'.tr,
                                          controller: controller.bankNameController.value,
                                          hintText: 'Bank Name'.tr,
                                        ),
                                        TextFieldWidget(
                                          title: 'Account Holder Name'.tr,
                                          controller: controller.accountHolderNameController.value,
                                          hintText: 'Account Holder Name'.tr,
                                        ),
                                        TextFieldWidget(
                                          title: 'Account Number'.tr,
                                          controller: controller.accountNumberController.value,
                                          hintText: 'Account Number'.tr,
                                          textInputType: TextInputType.number,
                                        ),
                                        TextFieldWidget(
                                          title: 'IFSC Code'.tr,
                                          controller: controller.ifscCodeController.value,
                                          hintText: 'IFSC Code'.tr,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
// ADD FROM HERE ↓

                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Container(
                color: themeChange.getThem()
                    ? AppThemeData.grey900
                    : AppThemeData.grey50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: RoundedButtonFill(
                      title: "Save Details".tr,
                      height: 5.5,
                      color: AppThemeData.secondary300,
                      textColor: AppThemeData.grey50,
                      fontSizes: 16,
                      onPress: () async {
                        controller.saveData();
                      },
                    )),
              ),
            );
          }),
    );
  }

  buildBottomSheet(BuildContext context, EditProfileController controller) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text("please select".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => controller.pickFile(
                                  source: ImageSource.gallery),
                              icon: const Icon(
                                Icons.photo_library_sharp,
                                size: 32,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                "gallery".tr,
                                style: const TextStyle(),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  void _showCuisinePicker(
      BuildContext context, EditProfileController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
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
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
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
                          return Obx(() {
                            final selected = controller
                                .isCuisineSelected(cuisine.cuisineTypeId);

                            return CheckboxListTile(
                              value: selected,
                              title: Text(cuisine.cuisineTypeName),
                              controlAffinity:
                              ListTileControlAffinity.leading,
                              onChanged: (_) {
                                controller
                                    .toggleCuisine(cuisine.cuisineTypeId);
                              },
                            );
                          });
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
        );
      },
    );
  }
  void _openLocationPickerForEdit(
      BuildContext context, EditProfileController controller) {
    Constant.checkPermission(
      context: context,
      onTap: () async {
        ShowToastDialog.showLoader("Getting location...".tr);
        try {
          await Geolocator.requestPermission();
          final position = await Geolocator.getCurrentPosition();
          ShowToastDialog.closeLoader();

          final initialPos = Constant.selectedMapType == 'osm'
              ? const LatLng(20.5937, 78.9629)
              : LatLng(position.latitude, position.longitude);

          final result = await Get.to(
                () => MapPickerPage(initialPosition: initialPos),
            fullscreenDialog: Constant.selectedMapType != 'osm',
          );

          if (result != null) {
            final data = result as Map<String, dynamic>;
            final LatLng selectedLatLng = data['location'] as LatLng;
            final String selectedAddress = data['address'] as String? ?? '';

            controller.latitudeController.text =
                selectedLatLng.latitude.toString();
            controller.longitudeController.text =
                selectedLatLng.longitude.toString();
            controller.locationDisplayController.text = selectedAddress;
          }
        } catch (e) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast(
              "Failed to get location: ${e.toString()}".tr);
        }
      },
    );
  }
}
