import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/document_model.dart';
import 'package:jippymart_restaurant/models/driver_document_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

class DetailsUploadController extends GetxController {
  Rx<DocumentModel> documentModel = DocumentModel().obs;

  Rx<DateTime?> selectedDate = DateTime.now().obs;

  RxString frontImage = "".obs;
  RxString backImage = "".obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      documentModel.value = argumentData['documentModel'];
    }
    getDocument();
    update();
  }

  Rx<Documents> documents = Documents().obs;

  getDocument() async {
    await FireStoreUtils.getDocumentOfDriver().then((value) {
      isLoading.value = false;
      if (value != null) {
        var contain = value.documents!
            .where((element) => element.documentId == documentModel.value.id);
        if (contain.isNotEmpty) {
          documents.value = value.documents!.firstWhere((itemToCheck) =>
              itemToCheck.documentId == documentModel.value.id);
          frontImage.value = documents.value.frontImage!;
          backImage.value = documents.value.backImage!;
        }
      }
    });
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile({required ImageSource source, required String type}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      if (type == "front") {
        frontImage.value = image.path;
      } else {
        backImage.value = image.path;
      }
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"Failed to Pick :".tr} \n $e");
    }
  }
  uploadDocument() async {
    try {
      documents.value.frontImage = frontImage.value;
      documents.value.backImage = backImage.value;
      documents.value.documentId = documentModel.value.id;
      documents.value.status = "uploaded";
      print('------------ Document Upload Debug Log ------------');
      print('User ID      : ${FireStoreUtils.getCurrentUid()}');
      print('documentId   : ${documents.value.documentId}');
      print('status       : ${documents.value.status}');
      print('frontImage   : ${documents.value.frontImage}');
      print('backImage    : ${documents.value.backImage}');
      print('--------------------------------------------------');

      ShowToastDialog.showLoader("Please wait...");

      bool result = await FireStoreUtils.uploadDriverDocument(documents.value);

      ShowToastDialog.closeLoader();

      if (result) {
        ShowToastDialog.showToast("Document uploaded successfully");
        Get.back(result: true);
      } else {
        ShowToastDialog.showToast("Upload failed — check server logs");
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error uploading document: $e");
      print('❌ Error in uploadDocument: $e');
    }
  }

}
