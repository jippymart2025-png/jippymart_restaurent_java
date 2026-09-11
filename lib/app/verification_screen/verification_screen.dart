import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/verification_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<VerificationController>(
        init: VerificationController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem()
                ? AppThemeData.surfaceDark
                : AppThemeData.surface,
            appBar: AppBar(
              backgroundColor: themeChange.getThem()
                  ? AppThemeData.grey900
                  : AppThemeData.grey50,
              centerTitle: false,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.chevron_left_outlined,
                  color: themeChange.getThem()
                      ? AppThemeData.grey50
                      : AppThemeData.grey900,
                ),
              ),
              elevation: 0,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : controller.entityId <= 0 && controller.errorMessage.isNotEmpty
                    ? _buildErrorView(controller, themeChange)
: controller.isApproved
                        ? _buildVerifiedView(controller, themeChange)
                        : controller.hasSubmittedDocuments
                            ? _buildPendingView(controller, themeChange)
                            : _buildUploadView(
                                context, controller, themeChange),
          );
        });
  }

  Widget _buildErrorView(
      VerificationController controller, DarkThemeProvider themeChange) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: themeChange.getThem()
                  ? AppThemeData.grey200
                  : AppThemeData.grey500,
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeChange.getThem()
                    ? AppThemeData.grey100
                    : AppThemeData.grey800,
                fontFamily: AppThemeData.medium,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            RoundedButtonFill(
              title: 'Retry'.tr,
              color: AppThemeData.secondary300,
              textColor: AppThemeData.grey50,
              width: 60,
              onPress: () => controller.loadVerificationStatus(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedView(
      VerificationController controller, DarkThemeProvider themeChange) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFD9F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_outlined,
                color: Color(0xFF10B271),
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Verified'.tr,
              style: TextStyle(
                color: themeChange.getThem()
                    ? AppThemeData.grey100
                    : AppThemeData.grey800,
                fontFamily: AppThemeData.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.entityName.isNotEmpty
                  ? controller.entityName
                  : controller.isMerchant
                      ? 'Merchant'.tr
                      : 'Outlet'.tr,
              style: TextStyle(
                color: themeChange.getThem()
                    ? AppThemeData.grey200
                    : AppThemeData.grey500,
                fontFamily: AppThemeData.medium,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your documents have been approved. You are all set to go.'
                  .tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeChange.getThem()
                    ? AppThemeData.grey300
                    : AppThemeData.grey600,
                fontFamily: AppThemeData.regular,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingView(
      VerificationController controller, DarkThemeProvider themeChange) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF2DC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                color: Color(0xFFE28C12),
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Verification in Pending'.tr,
              style: TextStyle(
                color: themeChange.getThem()
                    ? AppThemeData.grey100
                    : AppThemeData.grey800,
                fontFamily: AppThemeData.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.entityName.isNotEmpty
                  ? controller.entityName
                  : controller.isMerchant
                      ? 'Merchant'.tr
                      : 'Outlet'.tr,
              style: TextStyle(
                color: themeChange.getThem()
                    ? AppThemeData.grey200
                    : AppThemeData.grey500,
                fontFamily: AppThemeData.medium,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your documents have been submitted and are under review. You will be notified once the verification is complete.'
                  .tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeChange.getThem()
                    ? AppThemeData.grey300
                    : AppThemeData.grey600,
                fontFamily: AppThemeData.regular,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadView(
      BuildContext context,
      VerificationController controller,
      DarkThemeProvider themeChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document Verification'.tr,
                  style: TextStyle(
                    color: themeChange.getThem()
                        ? AppThemeData.grey100
                        : AppThemeData.grey800,
                    fontFamily: AppThemeData.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  controller.isMerchant
                      ? 'Upload your Aadhaar and PAN card to complete the verification process and ensure compliance.'
                          .tr
                      : 'Upload your FSSAI and GST documents to complete the verification process and ensure compliance.'
                          .tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: themeChange.getThem()
                        ? AppThemeData.grey200
                        : AppThemeData.grey700,
                    fontFamily: AppThemeData.regular,
                  ),
                ),
                const SizedBox(height: 24),
                ...controller.requiredDocuments.map((docKey) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _buildDocumentCard(
                        context, controller, themeChange, docKey),
                  );
                }),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: RoundedButtonFill(
            title: controller.isUploading.value
                ? 'Uploading...'.tr
                : 'Submit for Verification'.tr,
            color: AppThemeData.secondary300,
            textColor: AppThemeData.grey50,
            onPress: () {
              if (controller.isUploading.value) return;
              controller.submitDocuments();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    VerificationController controller,
    DarkThemeProvider themeChange,
    String docKey,
  ) {
    final value = controller.documentValue(docKey);
    final isNetwork = value.startsWith('http');
    final hasImage = value.isNotEmpty;

    return Container(
      decoration: ShapeDecoration(
        color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: themeChange.getThem()
                ? AppThemeData.grey800
                : AppThemeData.grey200,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    controller.documentTitle(docKey),
                    style: TextStyle(
                      color: themeChange.getThem()
                          ? AppThemeData.grey100
                          : AppThemeData.grey800,
                      fontFamily: AppThemeData.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: hasImage
                        ? const Color(0xFFD9F5E9)
                        : themeChange.getThem()
                            ? AppThemeData.grey800
                            : AppThemeData.grey100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    hasImage
                        ? 'Uploaded'.tr
                        : 'Required'.tr,
                    style: TextStyle(
                      color: hasImage
                          ? const Color(0xFF10B271)
                          : themeChange.getThem()
                              ? AppThemeData.grey200
                              : AppThemeData.grey600,
                      fontFamily: AppThemeData.medium,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () =>
                  buildBottomSheet(context, controller, docKey, themeChange),
              child: Container(
                height: 140,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: themeChange.getThem()
                      ? AppThemeData.surfaceDark
                      : AppThemeData.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeChange.getThem()
                        ? AppThemeData.grey800
                        : AppThemeData.grey200,
                    style: BorderStyle.solid,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasImage
                    ? Image(
                        image: isNetwork
                            ? NetworkImage(value)
                            : FileImage(File(value)),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(themeChange),
                      )
                    : _buildPlaceholder(themeChange),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: RoundedButtonFill(
                    title: hasImage ? 'Change'.tr : 'Browse Image'.tr,
                    color: AppThemeData.secondary50,
                    height: 5,
                    textColor: AppThemeData.secondary300,
                    onPress: () =>
                        buildBottomSheet(context, controller, docKey, themeChange),
                  ),
                ),
                if (hasImage && !isNetwork) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: RoundedButtonFill(
                      title: 'Remove'.tr,
                      color: themeChange.getThem()
                          ? AppThemeData.grey800
                          : AppThemeData.grey100,
                      height: 5,
                      textColor: themeChange.getThem()
                          ? AppThemeData.grey100
                          : AppThemeData.grey800,
                      onPress: () => controller.clearDocument(docKey),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(DarkThemeProvider themeChange) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 40,
            color: themeChange.getThem()
                ? AppThemeData.grey600
                : AppThemeData.grey300,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose an image and upload here'.tr,
            style: TextStyle(
              color: themeChange.getThem()
                  ? AppThemeData.grey300
                  : AppThemeData.grey600,
              fontFamily: AppThemeData.regular,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> buildBottomSheet(
      BuildContext context,
      VerificationController controller,
      String docKey,
      DarkThemeProvider themeChange) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Please Select'.tr,
                    style: TextStyle(
                      color: themeChange.getThem()
                          ? AppThemeData.grey50
                          : AppThemeData.grey900,
                      fontFamily: AppThemeData.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => controller.pickDocument(
                            docKey: docKey, source: ImageSource.gallery),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              const Icon(Icons.photo_library_sharp,
                                  size: 32),
                              const SizedBox(height: 4),
                              Text('Gallery'.tr),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => controller.pickDocument(
                            docKey: docKey, source: ImageSource.camera),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              const Icon(Icons.photo_camera_outlined,
                                  size: 32),
                              const SizedBox(height: 4),
                              Text('Camera'.tr),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}