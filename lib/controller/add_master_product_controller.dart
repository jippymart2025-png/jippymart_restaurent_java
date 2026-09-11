import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/create_master_product_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

import '../themes/app_them_data.dart';

class AddMasterProductController extends GetxController {
  AddMasterProductController({
    required this.categoryId,
    this.categoryName,
  });

  final int categoryId;
  final String? categoryName;

  // --------------------------------------------------
  // Text Controllers
  // --------------------------------------------------

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final shortDescriptionController = TextEditingController();
  final photoController = TextEditingController();
  final photosController = TextEditingController();
  final thumbnailController = TextEditingController();
  final foodTypeController = TextEditingController();
  final cuisineTypeController = TextEditingController();

  // --------------------------------------------------
  // Observable Values
  // --------------------------------------------------

  /// Default food type is VEG
  final isVeg = true.obs;

  final isSubmitting = false.obs;

  final pickedImagePath = RxnString();

  // --------------------------------------------------
  // Image Picker
  // --------------------------------------------------

  final ImagePicker _imagePicker = ImagePicker();

  // --------------------------------------------------
  // Init
  // --------------------------------------------------

  @override
  void onInit() {
    super.onInit();

    // Default value
    isVeg.value = true;
    foodTypeController.text = 'VEG';
  }

  // --------------------------------------------------
  // Update Food Type
  // --------------------------------------------------

  void updateFoodType(bool value) {
    isVeg.value = value;

    foodTypeController.text = value ? 'VEG' : 'NON_VEG';
  }

  // --------------------------------------------------
  // Dispose
  // --------------------------------------------------

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    shortDescriptionController.dispose();
    photoController.dispose();
    photosController.dispose();
    thumbnailController.dispose();
    foodTypeController.dispose();
    cuisineTypeController.dispose();

    super.onClose();
  }

  // --------------------------------------------------
  // Pick Image
  // --------------------------------------------------

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
      );

      if (image == null) return;

      pickedImagePath.value = image.path;

      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }
    } on PlatformException catch (e) {
      ShowToastDialog.showToast(
        'Failed to pick image: ${e.message ?? ''}'.tr,
      );
    } catch (_) {
      ShowToastDialog.showToast(
        'Failed to pick image'.tr,
      );
    }
  }

  // --------------------------------------------------
  // Resolve Photo URL
  // --------------------------------------------------

  Future<String?> _resolvePhotoUrl() async {
    final manualUrl = photoController.text.trim();

    // If user entered a URL manually
    if (manualUrl.isNotEmpty) {
      return manualUrl;
    }

    // Otherwise use picked image
    final localPath = pickedImagePath.value;

    if (localPath == null || localPath.isEmpty) {
      return '';
    }

    ShowToastDialog.showLoader(
      'Uploading image...'.tr,
    );

    try {
      final url =
      await Constant.uploadUserImageToFireStorage(
        File(localPath),
        'master-products/$categoryId',
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      return url;
    } catch (e) {
      ShowToastDialog.showToast(
        'Image upload failed'.tr,
      );

      return null;
    } finally {
      ShowToastDialog.closeLoader();
    }
  }

  // --------------------------------------------------
  // Create Product
  // --------------------------------------------------

  Future<bool> createProduct() async {
    final name = nameController.text.trim();

    // Validate product name
    if (name.isEmpty) {
      ShowToastDialog.showToast(
        'Please enter product name'.tr,
      );

      return false;
    }

    // Validate category
    if (categoryId <= 0) {
      ShowToastDialog.showToast(
        'Invalid category'.tr,
      );

      return false;
    }

    isSubmitting.value = true;

    ShowToastDialog.showLoader(
      'Creating product...'.tr,
    );

    try {
      // --------------------------------------------------
      // Photo
      // --------------------------------------------------

      final photoUrl = await _resolvePhotoUrl();

      if (photoUrl == null) {
        return false;
      }

      final photosUrl =
      photosController.text.trim().isNotEmpty
          ? photosController.text.trim()
          : photoUrl;

      final thumbnailUrl =
      thumbnailController.text.trim().isNotEmpty
          ? thumbnailController.text.trim()
          : photoUrl;

      // --------------------------------------------------
      // Food Type
      // --------------------------------------------------

      // Make absolutely sure that food type is set.
      // If user didn't touch the toggle, it will be VEG.
      final foodType = isVeg.value ? 'VEG' : 'NON_VEG';

      // Keep controller synchronized as well.
      foodTypeController.text = foodType;

      // --------------------------------------------------
      // Request
      // --------------------------------------------------

      final request = CreateMasterProductRequest(
        categoryId: categoryId,
        masterProductName: name,
        description: descriptionController.text.trim(),
        shortDescription:
        shortDescriptionController.text.trim(),
        photo: photoUrl,
        photos: photosUrl,
        thumbnail: thumbnailUrl,

        // true = VEG
        // false = NON_VEG
        isVeg: isVeg.value,

        // VEG or NON_VEG
        foodType: foodType,

        cuisineType:
        cuisineTypeController.text.trim(),
      );

      // --------------------------------------------------
      // API Call
      // --------------------------------------------------

      final response =
      await FireStoreUtils.createMasterProduct(
        request,
      );

      ShowToastDialog.closeLoader();

      // --------------------------------------------------
      // Response null
      // --------------------------------------------------

      if (response == null) {
        ShowToastDialog.showToast(
          'Something went wrong'.tr,
        );

        return false;
      }

      // --------------------------------------------------
      // API Error
      // --------------------------------------------------

      if (!response.success) {
        final error = response.errors.isNotEmpty
            ? response.errors.first
            : (response.message ??
            'Failed to create product');

        ShowToastDialog.showToast(error);

        return false;
      }

      // --------------------------------------------------
      // Success
      // --------------------------------------------------

      ShowToastDialog.showToast(
        response.message ??
            'Product created successfully'.tr,
      );

      return true;
    } catch (e) {
      ShowToastDialog.closeLoader();

      ShowToastDialog.showToast(
        'Failed to create product'.tr,
      );

      return false;
    } finally {
      isSubmitting.value = false;
    }
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