import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/create_master_product_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

class AddMasterProductController extends GetxController {
  AddMasterProductController({
    required this.categoryId,
    this.categoryName,
  });

  final int categoryId;
  final String? categoryName;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final shortDescriptionController = TextEditingController();
  final photoController = TextEditingController();
  final photosController = TextEditingController();
  final thumbnailController = TextEditingController();
  final foodTypeController = TextEditingController();
  final cuisineTypeController = TextEditingController();

  final isVeg = true.obs;
  final isSubmitting = false.obs;
  final pickedImagePath = RxnString();

  final ImagePicker _imagePicker = ImagePicker();

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

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
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
      ShowToastDialog.showToast('Failed to pick image'.tr);
    }
  }

  Future<String?> _resolvePhotoUrl() async {
    final manualUrl = photoController.text.trim();
    if (manualUrl.isNotEmpty) return manualUrl;

    final localPath = pickedImagePath.value;
    if (localPath == null || localPath.isEmpty) return '';

    ShowToastDialog.showLoader('Uploading image...'.tr);
    try {
      final url = await Constant.uploadUserImageToFireStorage(
        File(localPath),
        'master-products/$categoryId',
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      return url;
    } catch (e) {
      ShowToastDialog.showToast('Image upload failed'.tr);
      return null;
    } finally {
      ShowToastDialog.closeLoader();
    }
  }

  Future<bool> createProduct() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ShowToastDialog.showToast('Please enter product name'.tr);
      return false;
    }

    if (categoryId <= 0) {
      ShowToastDialog.showToast('Invalid category'.tr);
      return false;
    }

    isSubmitting.value = true;
    ShowToastDialog.showLoader('Creating product...'.tr);

    try {
      final photoUrl = await _resolvePhotoUrl();
      if (photoUrl == null) {
        return false;
      }

      final photosUrl = photosController.text.trim().isNotEmpty
          ? photosController.text.trim()
          : photoUrl;
      final thumbnailUrl = thumbnailController.text.trim().isNotEmpty
          ? thumbnailController.text.trim()
          : photoUrl;

      final request = CreateMasterProductRequest(
        categoryId: categoryId,
        masterProductName: name,
        description: descriptionController.text.trim(),
        shortDescription: shortDescriptionController.text.trim(),
        photo: photoUrl,
        photos: photosUrl,
        thumbnail: thumbnailUrl,
        isVeg: isVeg.value,
        foodType: foodTypeController.text.trim(),
        cuisineType: cuisineTypeController.text.trim(),
      );

      final response = await FireStoreUtils.createMasterProduct(request);
      ShowToastDialog.closeLoader();

      if (response == null) {
        ShowToastDialog.showToast('Something went wrong'.tr);
        return false;
      }

      if (!response.success) {
        final error = response.errors.isNotEmpty
            ? response.errors.first
            : (response.message ?? 'Failed to create product');
        ShowToastDialog.showToast(error);
        return false;
      }

      ShowToastDialog.showToast(
        response.message ?? 'Product created successfully'.tr,
      );
      return true;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Failed to create product'.tr);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
