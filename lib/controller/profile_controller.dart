import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/merchant_outlet_controller.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jippymart_restaurant/models/outlet_model.dart';

class ProfileController extends GetxController {
  RxBool isOutletContext = false.obs;
  Rx<OutletModel> outletModel = OutletModel().obs;

  RxBool isLoading = true.obs;

  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getUserProfile();
    getThem();
    super.onInit();
  }

  // getUserProfile() async {
  //   String userId = await FireStoreUtils.getCurrentUid();
  //   await FireStoreUtils.getUserProfile(userId).then(
  //         (value) {
  //       if (value != null) {
  //         userModel.value = value;
  //         Constant.userModel = userModel.value;
  //       }
  //     },
  //   );
  //   isLoading.value = false;
  // }
// This is java related working method(start)
//   getUserProfile() async {
//     try {
//       String merchantId = Preferences.getString('merchantId');
//
//       if (merchantId.isNotEmpty) {
//         // Java API
//         final value = await FireStoreUtils.getMerchantProfile(merchantId);
//         if (value != null) {
//           userModel.value = value;
//           Constant.userModel = value;
//         }
//       } else {
//         // Fallback: existing PHP/Firebase API
//         String userId = await FireStoreUtils.getCurrentUid();
//         final value = await FireStoreUtils.getUserProfile(userId);
//         if (value != null) {
//           userModel.value = value;
//           Constant.userModel = value;
//         }
//       }
//     } catch (e) {
//       debugPrint('getUserProfile error: $e');
//     }
//     isLoading.value = false;
//   }
  getUserProfile() async {
    try {
      final outletId = Preferences.getInt('outletId');
      isOutletContext.value = outletId > 0;

      if (isOutletContext.value) {
        final outlet = await FireStoreUtils.getOutletProfile(outletId);
        if (outlet != null) outletModel.value = outlet;
        isLoading.value = false;
        return;
      }

      if (Preferences.getString('loginType') == 'MERCHANT' &&
          Get.isRegistered<MerchantOutletController>()) {
        final cached =
            Get.find<MerchantOutletController>().merchantProfile.value;
        if (cached != null) {
          userModel.value = cached;
          Constant.userModel = cached;
          debugPrint('[Profile] Using cached merchant profile (no API call)');
          isLoading.value = false;
          return;
        }
      }

      String merchantId = Preferences.getString('merchantId');
      final value = await FireStoreUtils.getMerchantProfile(merchantId);
      if (value != null) {
        userModel.value = value;
        Constant.userModel = value;
      }
    } catch (e) {
      debugPrint('getUserProfile error: $e');
    }
    isLoading.value = false;
  }
//(end)
  RxString isDarkMode = "Light".obs;
  RxBool isDarkModeSwitch = false.obs;

  getThem() {
    isDarkMode.value = Preferences.getString(Preferences.themKey);
    if (isDarkMode.value == "Dark") {
      isDarkModeSwitch.value = true;
    } else if (isDarkMode.value == "Light") {
      isDarkModeSwitch.value = false;
    } else {
      isDarkModeSwitch.value = false;
    }
    isLoading.value = false;
  }

  Future<bool> deleteUserFromServer() async {
    var url = '${Constant.storeUrl}/api/delete-user';
    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'uuid': FireStoreUtils.getCurrentUid(),
        },
      );
      log("deleteUserFromServer :: ${response.body}");
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
