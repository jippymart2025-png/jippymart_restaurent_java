import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jippymart_restaurant/app/edit_profile_screen/widgets/MerchantForm.dart';
import 'package:jippymart_restaurant/app/edit_profile_screen/widgets/OutletForm.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/app/edit_profile_screen/controller/edit_profile_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/responsive.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder<EditProfileController>(
      init: EditProfileController(),
      builder: (controller) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              titleSpacing: 0,
              iconTheme: const IconThemeData(
                color: AppThemeData.grey50,
                size: 20,
              ),
            ),
            body: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileAvatar(controller: controller),
                    const SizedBox(height: 40),
                    Obx(() => controller.isOutletMode.value
                        ? OutletForm(controller: controller)
                        : MerchantForm(controller: controller)),
                  ],
                ),
              );
            }),
            bottomNavigationBar: Container(
              color: themeChange.getThem()
                  ? AppThemeData.grey900
                  : AppThemeData.grey50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Obx(() => RoundedButtonFill(
                  title: controller.isSaving.value
                      ? 'Saving...'.tr
                      : 'Save Details'.tr,
                  height: 5.5,
                  color: AppThemeData.secondary300,
                  textColor: AppThemeData.grey50,
                  fontSizes: 16,
                  onPress: controller.isSaving.value
                      ? null
                      : controller.saveData,
                )),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// Profile avatar
// ─────────────────────────────────────────────────────────
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.controller});
  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    final size = Responsive.width(24, context);

    return Center(
      child: Stack(
        children: [
          Obx(() {
            final img = controller.profileImage.value;
            Widget child;

            if (img.isEmpty) {
              child = Image.asset(
                Constant.userPlaceHolder,
                height: size,
                width: size,
                fit: BoxFit.cover,
              );
            } else if (!Constant().hasValidUrl(img)) {
              child = Image.file(
                File(img),
                height: size,
                width: size,
                fit: BoxFit.cover,
              );
            } else {
              child = NetworkImageWidget(
                fit: BoxFit.cover,
                imageUrl: img,
                height: size,
                width: size,
                errorWidget: Image.asset(
                  Constant.userPlaceHolder,
                  fit: BoxFit.cover,
                  height: size,
                  width: size,
                ),
              );
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: child,
            );
          }),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: () => _showImagePicker(context, controller),
              child: SvgPicture.asset('assets/icons/ic_edit.svg'),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePicker(
      BuildContext context, EditProfileController controller) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: Responsive.height(22, context),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'please select'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () => controller.pickFile(
                            source: ImageSource.gallery),
                        icon: const Icon(
                          Icons.photo_library_sharp,
                          size: 32,
                        ),
                      ),
                      Text('gallery'.tr),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
