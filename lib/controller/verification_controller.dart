import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/merchant_response_model.dart';
import 'package:jippymart_restaurant/models/outlet_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

enum VerificationEntityType { merchant, outlet }

class VerificationController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool isUploading = false.obs;

  VerificationEntityType entityType = VerificationEntityType.merchant;
  int entityId = 0;
  String entityName = '';
  String errorMessage = '';
  bool isApproved = false;

  MerchantModel? merchant;
  OutletModel? outlet;

  final RxString aadhaarImage = ''.obs;
  final RxString panImage = ''.obs;
  final RxString fssaiImage = ''.obs;
  final RxString gstImage = ''.obs;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    loadVerificationStatus();
    super.onInit();
  }

  String get entityTypeLabel =>
      entityType == VerificationEntityType.merchant ? 'MERCHANT' : 'OUTLET';

  bool get isMerchant => entityType == VerificationEntityType.merchant;

  List<String> get requiredDocuments =>
      isMerchant ? ['aadhaar', 'pan'] : ['fssai', 'gst'];

  String documentTitle(String docKey) {
    switch (docKey) {
      case 'aadhaar':
        return 'Aadhaar Card';
      case 'pan':
        return 'PAN Card';
      case 'fssai':
        return 'FSSAI License';
      case 'gst':
        return 'GST Certificate';
      default:
        return docKey;
    }
  }

  Future<void> loadVerificationStatus() async {
    isLoading.value = true;
    errorMessage = '';
    try {
      final loginType = Preferences.getString('loginType');
      final activeOutletId = Preferences.getInt('outletId') > 0
          ? Preferences.getInt('outletId')
          : Preferences.getInt('selectedOutletId');

      if (loginType == 'OUTLET' || activeOutletId > 0) {
        entityType = VerificationEntityType.outlet;
        entityId = activeOutletId;
        if (entityId > 0) {
          final result = await FireStoreUtils.fetchOutletById(entityId);
          if (result.isSuccess && result.outlet != null) {
            outlet = result.outlet;
            entityName = outlet!.outletName ?? '';
            isApproved = outlet!.isApproved ?? false;
            aadhaarImage.value = outlet!.aadhaarNumberUrl ?? '';
            panImage.value = outlet!.panNumberUrl ?? '';
            fssaiImage.value = outlet!.fssaiNumberUrl ?? '';
            gstImage.value = outlet!.gstNumberUrl ?? '';
          } else {
            errorMessage = result.message ?? 'Failed to load outlet';
          }
        } else {
          errorMessage = 'Outlet not found';
        }
      } else {
        entityType = VerificationEntityType.merchant;
        final merchantIdStr = Preferences.getString('merchantId').trim();
        entityId = int.tryParse(merchantIdStr) ?? 0;
        if (entityId <= 0) entityId = Preferences.getInt('userId');
        if (entityId > 0) {
          merchant =
              await FireStoreUtils.getMerchantProfile(entityId.toString());
          if (merchant != null) {
            entityName = merchant!.merchantName ?? '';
            isApproved = merchant!.isApproved ?? false;
            aadhaarImage.value = merchant!.aadhaarNumberUrl ?? '';
            panImage.value = merchant!.panNumberUrl ?? '';
          } else {
            errorMessage = 'Failed to load merchant';
          }
        } else {
          errorMessage = 'Merchant not found';
        }
      }
    } catch (e, stackTrace) {
      errorMessage = e.toString();
      debugPrint('VerificationController.loadVerificationStatus error: $e');
      debugPrint('$stackTrace');
    }
    isLoading.value = false;
    update();
  }

  String documentValue(String docKey) {
    switch (docKey) {
      case 'aadhaar':
        return aadhaarImage.value;
      case 'pan':
        return panImage.value;
      case 'fssai':
        return fssaiImage.value;
      case 'gst':
        return gstImage.value;
      default:
        return '';
    }
  }

  bool hasDocument(String docKey) => documentValue(docKey).isNotEmpty;

  void clearDocument(String docKey) {
    switch (docKey) {
      case 'aadhaar':
        aadhaarImage.value = '';
        break;
      case 'pan':
        panImage.value = '';
        break;
      case 'fssai':
        fssaiImage.value = '';
        break;
      case 'gst':
        gstImage.value = '';
        break;
    }
    update();
  }

  bool get areAllDocumentsUploaded => requiredDocuments.every(hasDocument);

  /// True when all required docs have been submitted to the backend and are
  /// awaiting admin review (URLs returned by the server, not local picks).
  bool get hasSubmittedDocuments {
    if (isMerchant) {
      return (merchant?.aadhaarNumberUrl?.isNotEmpty ?? false) &&
          (merchant?.panNumberUrl?.isNotEmpty ?? false);
    }
    return (outlet?.fssaiNumberUrl?.isNotEmpty ?? false) &&
        (outlet?.gstNumberUrl?.isNotEmpty ?? false);
  }

  Future pickDocument({
    required String docKey,
    required ImageSource source,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
      );
      if (image == null) return;
      switch (docKey) {
        case 'aadhaar':
          aadhaarImage.value = image.path;
          break;
        case 'pan':
          panImage.value = image.path;
          break;
        case 'fssai':
          fssaiImage.value = image.path;
          break;
        case 'gst':
          gstImage.value = image.path;
          break;
      }
      Get.back();
      update();
    } catch (e) {
      debugPrint('pickDocument error: $e');
      ShowToastDialog.showToast('Failed to pick image');
    }
  }

  File? _localFile(String docKey) {
    final value = documentValue(docKey);
    if (value.isEmpty || value.startsWith('http')) return null;
    return File(value);
  }

  Future<bool> submitDocuments() async {
    final missing =
        requiredDocuments.where((doc) => !hasDocument(doc)).toList();
    if (missing.isNotEmpty) {
      ShowToastDialog.showToast('Upload all required documents');
      return false;
    }

    isUploading.value = true;
    update();
    try {
      final success = await FireStoreUtils.saveOrUpdateDocuments(
        entityId: entityId,
        entityType: entityTypeLabel,
        aadharFile: _localFile('aadhaar'),
        panFile: _localFile('pan'),
        fssaiFile: _localFile('fssai'),
        gstFile: _localFile('gst'),
      );
      isUploading.value = false;
      update();
      if (success) {
        ShowToastDialog.showToast('Documents submitted successfully');
        await loadVerificationStatus();
        return true;
      }
      ShowToastDialog.showToast('Upload failed. Please try again');
      return false;
    } catch (e) {
      isUploading.value = false;
      update();
      debugPrint('submitDocuments error: $e');
      ShowToastDialog.showToast('Error uploading documents');
      return false;
    }
  }
}