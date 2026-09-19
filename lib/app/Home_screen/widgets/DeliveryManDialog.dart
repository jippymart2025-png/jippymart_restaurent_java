import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../constant/constant.dart';
import '../../../constant/send_notification.dart';
import '../../../constant/show_toast_dialog.dart' show ShowToastDialog;
import '../../../controller/home_controller.dart';
import '../../../models/order_model.dart';
import '../../../models/user_model.dart';
import '../../../service/audio_player_service.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/round_button_fill.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';

class DeliveryManDialog extends StatelessWidget {
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final OrderModel orderModel;

  const DeliveryManDialog({
    required this.controller,
    required this.themeChange,
    required this.orderModel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeChange.getThem();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor:
      isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Select the delivery man'.tr,
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        color: isDark
                            ? AppThemeData.grey100
                            : AppThemeData.grey800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Add Delivery Man'.tr,
                      style: TextStyle(
                        color: AppThemeData.secondary300,
                        fontFamily: AppThemeData.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownSearch<UserModel>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      labelText: 'Search Delivery Man'.tr,
                      labelStyle: const TextStyle(
                          fontFamily: AppThemeData.medium,
                          fontSize: 15),
                      border: const OutlineInputBorder(),
                      prefixIcon:
                      const Icon(Icons.search),
                      contentPadding:
                      const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                  itemBuilder: (_, UserModel driver, bool __) {
                    final occupied =
                        driver.inProgressOrderID?.isNotEmpty ==
                            true;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              '${driver.firstName} ${driver.lastName}',
                              style: const TextStyle(
                                fontFamily: AppThemeData.medium,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (Constant.singleOrderReceive ==
                              true)
                            Expanded(
                              flex: 1,
                              child: Text(
                                occupied
                                    ? 'Occupied'.tr
                                    : 'Assign'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppThemeData.medium,
                                  fontSize: 12,
                                  color: occupied
                                      ? AppThemeData.danger300
                                      : AppThemeData.secondary300,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                items: controller.driverUserList,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  baseStyle: const TextStyle(
                      fontFamily: AppThemeData.medium, fontSize: 16),
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Select Delivery Man'.tr,
                    labelStyle: const TextStyle(
                        fontFamily: AppThemeData.medium,
                        fontSize: 15),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                  ),
                ),
                itemAsString: (u) => u?.id != null
                    ? '${u?.firstName} ${u?.lastName}'
                    : 'Select Delivery Man'.tr,
                onChanged: (value) {
                  if (Constant.singleOrderReceive == true) {
                    if (value?.inProgressOrderID?.isEmpty ==
                        true) {
                      controller.selectDriverUser.value = value!;
                    } else {
                      ShowToastDialog.showToast(
                        'This delivery man is already assigned. Kindly select a different one.'
                            .tr,
                      );
                      controller.selectDriverUser.value =
                          UserModel();
                    }
                  } else {
                    controller.selectDriverUser.value = value!;
                  }
                },
                selectedItem: controller.selectDriverUser.value,
              ),
            )),
            const SizedBox(height: 20),
            Container(
              color: isDark
                  ? AppThemeData.grey700
                  : AppThemeData.grey200,
              height: 3,
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: RoundedButtonFill(
                          title: 'Cancel'.tr,
                          color: isDark
                              ? AppThemeData.grey700
                              : AppThemeData.grey200,
                          textColor: isDark
                              ? AppThemeData.grey100
                              : AppThemeData.grey800,
                          onPress: Get.back,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RoundedButtonFill(
                          title: 'Order Assign'.tr,
                          color: AppThemeData.secondary300,
                          textColor: AppThemeData.grey50,
                          onPress: () =>
                              _assignDriver(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignDriver(BuildContext context) async {
    final driver = controller.selectDriverUser.value;
    if (driver.id == null || driver.id!.isEmpty) {
      ShowToastDialog.showToast('Please select the delivery man'.tr);
      return;
    }

    Get.back();
    ShowToastDialog.showLoader('Please wait...'.tr);
    await AudioPlayerService.playSound(false);

    orderModel
      ..notes = ''
      ..driverID = driver.id
      ..driver = driver
      ..status = Constant.orderInTransit;

    // driver.inProgressOrderID?.add(orderModel.id);

    await FireStoreUtils.updateOrder(orderModel);
    await Future.wait([
      FireStoreUtils.updateDriverUser(driver),
      FireStoreUtils.restaurantVendorWalletSet(orderModel),
    ]);

    if (driver.fcmToken?.isNotEmpty == true) {
      SendNotification.sendFcmMessage(
        Constant.newDeliveryOrder,
        driver.fcmToken!,
        {'orderId': orderModel.id},
      );
    }

    ShowToastDialog.closeLoader();
  }
}
