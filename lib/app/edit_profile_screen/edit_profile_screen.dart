import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/edit_profile_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/responsive.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/themes/text_field_widget.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';

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
                              ),
                              TextFieldWidget(
                                title: 'Phone Number'.tr,
                                controller: controller.outletPhoneController.value,
                                hintText: 'Phone Number'.tr,
                              ),
                              TextFieldWidget(
                                title: 'Cuisine Type'.tr,
                                controller: controller.cuisineTypeController.value,
                                hintText: 'Cuisine Type'.tr,
                              ),
                              TextFieldWidget(
                                title: 'Delivery Radius (km)'.tr,
                                controller: controller.radiusController.value,
                                hintText: 'Radius'.tr,
                                textInputType: TextInputType.number,
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

                                          const SizedBox(height: 8),

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
                                        TextFieldWidget(
                                          title: 'Status'.tr,
                                          controller: controller.statusController.value,
                                          hintText: 'Status'.tr,
                                          enable: false,
                                        ),
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
}
