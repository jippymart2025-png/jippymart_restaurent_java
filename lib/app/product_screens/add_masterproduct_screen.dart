import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jippymart_restaurant/controller/add_master_product_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/themes/text_field_widget.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class AddMasterProductScreen extends StatelessWidget {
  final int categoryId;
  final String? categoryName;

  const AddMasterProductScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });



  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DarkThemeProvider>(context);
    final isDark = theme.getThem();
    final controller = Get.put(
      AddMasterProductController(
        categoryId: categoryId,
        categoryName: categoryName,
      ),
      tag: 'add_master_$categoryId',
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppThemeData.grey900 : const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: ColorConst.orange,
        elevation: 0,
        title: Text(
          'Add Product'.tr,
          style: const TextStyle(
            color: AppThemeData.grey50,
            fontSize: 18,
            fontFamily: AppThemeData.semiBold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppThemeData.grey50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if ((categoryName ?? '').isNotEmpty) ...[
              Text(
                categoryName!,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  fontSize: 15,
                  color: isDark
                      ? AppThemeData.grey100
                      : AppThemeData.grey900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'New master product for this category'.tr,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppThemeData.grey400
                      : AppThemeData.grey600,
                ),
              ),
              const SizedBox(height: 16),
            ],
            _FormCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFieldWidget(
                    title: 'Product Name'.tr,
                    hintText: 'e.g. Chicken Biryani'.tr,
                    controller: controller.nameController,
                    textInputAction: TextInputAction.next,
                  ),
                  TextFieldWidget(
                    title: 'Short Description'.tr,
                    hintText: 'Brief summary for the menu'.tr,
                    controller: controller.shortDescriptionController,
                    textInputAction: TextInputAction.next,
                  ),
                  TextFieldWidget(
                    title: 'Description'.tr,
                    hintText: 'Full product description'.tr,
                    controller: controller.descriptionController,
                    maxLine: 4,
                    textInputType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  // TextFieldWidget(
                  //   title: 'Food Type'.tr,
                  //   hintText: 'e.g. VEG OR NON-VEG'.tr,
                  //   controller: controller.foodTypeController,
                  //   textInputAction: TextInputAction.next,
                  // ),
                  TextFieldWidget(
                    title: 'Cuisine Type'.tr,
                    hintText: 'e.g. Indian'.tr,
                    controller: controller.cuisineTypeController,
                    textInputAction: TextInputAction.next,
                  ),
                  _VegToggle(controller: controller, isDark: isDark),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _FormCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Product Image'.tr,
                    style: TextStyle(
                      fontFamily: AppThemeData.medium,
                      fontSize: 14,
                      color: isDark
                          ? AppThemeData.grey50
                          : AppThemeData.grey900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final path = controller.pickedImagePath.value;
                    final hasPhoto = path != null && path.isNotEmpty;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: () => _showImagePickerSheet(controller),
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasPhoto
                                    ? ColorConst.orange.withOpacity(0.5)
                                    : (isDark
                                        ? AppThemeData.grey700
                                        : Colors.grey.shade300),
                              ),
                            ),
                            child: hasPhoto
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Image.file(
                                          File(path),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 36,
                                        color: ColorConst.orange,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to add photo'.tr,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? AppThemeData.grey400
                                              : AppThemeData.grey600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasPhoto
                              ? 'Photo selected. It uploads when you tap Create.'.tr
                              : 'Choose Camera or Gallery, or paste a URL below.'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppThemeData.grey400
                                : AppThemeData.grey600,
                          ),
                        ),
                        if (hasPhoto) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                controller.pickedImagePath.value = null;
                              },
                              child: Text(
                                'Remove photo'.tr,
                                style: TextStyle(color: ColorConst.orange),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                  const SizedBox(height: 12),
                  TextFieldWidget(
                    title: 'Photo URL (optional)'.tr,
                    hintText: 'Or paste image URL'.tr,
                    controller: controller.photoController,
                  ),
                  TextFieldWidget(
                    title: 'Thumbnail URL (optional)'.tr,
                    hintText: 'Defaults to photo if empty'.tr,
                    controller: controller.thumbnailController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => RoundedButtonFill(
                title: controller.isSubmitting.value
                    ? 'Creating...'.tr
                    : 'Create'.tr,
                color: ColorConst.orange,
                textColor: Colors.white,
                height: 6,
                radius: 12,
                onPress: () async {
                  if (controller.isSubmitting.value) return;
                  final success = await controller.createProduct();
                  if (success) {
                    Get.back(result: true);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerSheet(AddMasterProductController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Photo'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: AppThemeData.semiBold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera'.tr,
                  onTap: () =>
                      controller.pickImage(ImageSource.camera),
                ),
                _PickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery'.tr,
                  onTap: () =>
                      controller.pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: ColorConst.orange),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _VegToggle extends StatelessWidget {
  const _VegToggle({
    required this.controller,
    required this.isDark,
  });

  final AddMasterProductController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppThemeData.grey900
              : AppThemeData.grey50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              controller.isVeg.value
                  ? Icons.eco
                  : Icons.restaurant,
              color: controller.isVeg.value
                  ? Colors.green
                  : Colors.red,
              size: 20,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                controller.isVeg.value
                    ? 'Vegetarian'.tr
                    : 'Non-Vegetarian'.tr,
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 14,
                  color: isDark
                      ? AppThemeData.grey100
                      : AppThemeData.grey900,
                ),
              ),
            ),

            Switch(
              value: controller.isVeg.value,
              activeColor: Colors.green,
              onChanged: (value) {
                controller.updateFoodType(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}