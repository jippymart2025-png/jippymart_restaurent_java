import 'dart:convert';

import 'package:bottom_picker/resources/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../constant/constant.dart';
import '../../../constant/send_notification.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/home_controller.dart';
import '../../../models/order_model.dart';
import '../../../models/user_model.dart';
import '../../../models/wallet_transaction_model.dart';
import '../../../service/audio_player_service.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/round_button_fill.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';
import '../../../widget/my_separator.dart';
import 'CustomerRow.dart';
import 'DeliveryManDialog.dart';
import 'OrderCardShell.dart';
import 'OrderMetaRows.dart';
import 'ProductList.dart';

class NewOrderCard extends StatelessWidget {
  final OrderModel orderModel;
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final BuildContext context;
  final Future<void> Function(BuildContext, HomeController)
  onEstimatedTimePicked;

  const NewOrderCard({
    required this.orderModel,
    required this.controller,
    required this.themeChange,
    required this.context,
    required this.onEstimatedTimePicked,
  });

  @override
  Widget build(BuildContext ctx) {
    final totals = OrderTotals.from(orderModel);

    return OrderCardShell(
      themeChange: themeChange,
      children: [
        CustomerRow(orderModel: orderModel, themeChange: themeChange),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: MySeparator(
            color: themeChange.getThem()
                ? AppThemeData.grey700
                : AppThemeData.grey200,
          ),
        ),
        ProductList(
          orderModel: orderModel,
          themeChange: themeChange,
          showViewRatings: true,
        ),
        OrderMetaRows(
          orderModel: orderModel,
          themeChange: themeChange,
          adminCommission: totals.adminCommission,
          controller: controller,
          parentContext: context,
        ),
        const SizedBox(height: 10),
        _NewOrderActions(
          orderModel: orderModel,
          totals: totals,
          controller: controller,
          themeChange: themeChange,
          context: context,
          onEstimatedTimePicked: onEstimatedTimePicked,
        ),
      ],
    );
  }
}


class _NewOrderActions extends StatelessWidget {
  final OrderModel orderModel;
  final OrderTotals totals;
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final BuildContext context;
  final Future<void> Function(BuildContext, HomeController)
  onEstimatedTimePicked;

  const _NewOrderActions({
    required this.orderModel,
    required this.totals,
    required this.controller,
    required this.themeChange,
    required this.context,
    required this.onEstimatedTimePicked,
  });

  Future<void> _reject() async {
    ShowToastDialog.showLoader('Please wait...'.tr);
    await AudioPlayerService.playSound(false);
    orderModel.status = Constant.orderRejected;
    await FireStoreUtils.updateOrder(orderModel);

    if (orderModel.author?.fcmToken?.isNotEmpty == true) {
      SendNotification.sendFcmMessage(
        Constant.restaurantRejected,
        orderModel.author!.fcmToken!,
        {'orderId': orderModel.id ?? '', 'status': Constant.orderRejected},
      );
    }

    if (orderModel.paymentMethod?.toLowerCase() != 'cod') {
      final amount = totals.subTotal +
          (double.tryParse(orderModel.discount.toString()) ?? 0) +
          totals.specialDiscount +
          totals.taxAmount +
          (double.tryParse(orderModel.deliveryCharge.toString()) ?? 0) +
          (double.tryParse(orderModel.tipAmount.toString()) ?? 0);

      final tx = WalletTransactionModel(
        amount: amount,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: orderModel.author!.id,
        date: Timestamp.now(),
        isTopup: true,
        paymentMethod: 'Wallet',
        paymentStatus: 'success',
        note: 'Order Refund success',
        transactionUser: 'user',
      );
      await FireStoreUtils.setWalletTransaction(tx);
      await FireStoreUtils.updateUserWallet(
        amount: amount.toString(),
        userId: orderModel.author?.firebaseId ?? '',
      );
    }

    await controller.getOrder(silent: false);
    ShowToastDialog.closeLoader();
    Get.back();
  }

  void _openEstimatedDialog() {
    if (orderModel.scheduleTime != null) {
      final scheduled = Constant.checkScheduleTime(
          scheduleDate: orderModel.scheduleTime!.toDate());
      if (DateTime.now().isAtSameMomentOrAfter(scheduled)) {
        _showEstimatedDialog();
      } else {
        ShowToastDialog.showToast(
          '${'You can accept order on'.tr} ${Constant.timestampToDateTime(Timestamp.fromDate(scheduled))}.',
        );
      }
    } else {
      controller.driverUserList.clear();
      controller.selectDriverUser.value = UserModel();
      _showEstimatedDialog();
    }
  }

  void _showEstimatedDialog() {
    showDialog(
      context: context,
      builder: (_) => _EstimatedTimeDialog(
        controller: controller,
        themeChange: themeChange,
        orderModel: orderModel,
        context: context,
        onPickDuration: onEstimatedTimePicked,
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    final isSelfDelivery = Constant.isSelfDeliveryFeature == true &&
        controller.vendermodel.value.isSelfDelivery == true &&
        orderModel.takeAway == false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: RoundedButtonFill(
              title: 'Reject'.tr,
              color: AppThemeData.new_primary,
              textColor: AppThemeData.grey50,
              height: 5,
              onPress: _reject,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RoundedButtonFill(
              title: isSelfDelivery ? 'Self Delivery'.tr : 'Accept'.tr,
              height: 5,
              color: isSelfDelivery
                  ? AppThemeData.success400
                  : AppThemeData.new_green_tog,
              textColor: AppThemeData.grey50,
              onPress: isSelfDelivery
                  ? _openEstimatedDialog
                  : () => showDialog(
                context: context,
                builder: (_) => _EstimatedTimeDialog(
                  controller: controller,
                  themeChange: themeChange,
                  orderModel: orderModel,
                  context: context,
                  onPickDuration: onEstimatedTimePicked,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderTotals {
  final double subTotal;
  final double taxAmount;
  final double specialDiscount;
  final double adminCommission;
  final double totalAmount;

  OrderTotals({
    required this.subTotal,
    required this.taxAmount,
    required this.specialDiscount,
    required this.adminCommission,
    required this.totalAmount,
  });

  factory OrderTotals.from(OrderModel order) {
    double sub = 0, tax = 0, special = 0, admin = 0;
    final disc = double.tryParse(order.discount?.toString() ?? '0') ?? 0;

    for (final p in order.products ?? const []) {
      final price = double.tryParse(p.merchant_price?.toString() ?? '0') ?? 0;
      final qty = double.tryParse(p.quantity?.toString() ?? '1') ?? 1;
      final extras =
          double.tryParse(p.extrasPrice?.toString() ?? '0') ?? 0;
      sub += price * qty + extras * qty;
    }

    if (order.specialDiscount?['special_discount'] != null) {
      special = double.tryParse(
          order.specialDiscount!['special_discount'].toString()) ??
          0;
    }

    if (order.taxSetting != null) {
      for (final t in order.taxSetting!) {
        tax += Constant.calculateTax(
          amount:
          (sub - disc - special)
              .toString(),
          taxModel: t,
        );
      }
    }

    final total = sub - disc - special + tax;

    if (order.adminCommissionType == 'Percent' &&
        order.adminCommission != null) {
      final rate = double.tryParse(order.adminCommission!) ?? 0;
      admin = sub - sub / (1 + rate / 100);
    } else {
      admin = double.tryParse(order.adminCommission ?? '0') ?? 0;
    }

    return OrderTotals(
      subTotal: sub,
      taxAmount: tax,
      specialDiscount: special,
      adminCommission: admin,
      totalAmount: total,
    );
  }
}



class _EstimatedTimeDialog extends StatelessWidget {
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final OrderModel orderModel;
  final BuildContext context;
  final Future<void> Function(BuildContext, HomeController) onPickDuration;

  const _EstimatedTimeDialog({
    required this.controller,
    required this.themeChange,
    required this.orderModel,
    required this.context,
    required this.onPickDuration,
  });

  @override
  Widget build(BuildContext ctx) {
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Text(
                'Estimate time to prepare'.tr,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  color: isDark
                      ? AppThemeData.grey100
                      : AppThemeData.grey800,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              color: isDark
                  ? AppThemeData.grey700
                  : AppThemeData.grey200,
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Duration picker tap target
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onPickDuration(context, controller),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estimated Time',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(() => Text(
                                      controller
                                          .estimatedTimeController
                                          .value
                                          .text
                                          .isEmpty
                                          ? 'Select duration'
                                          : controller
                                          .estimatedTimeController
                                          .value
                                          .text,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                        color: controller
                                            .estimatedTimeController
                                            .value
                                            .text
                                            .isEmpty
                                            ? Colors.grey.shade500
                                            : Colors.black,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              Obx(() => controller
                                  .estimatedTimeController
                                  .value
                                  .text
                                  .isNotEmpty
                                  ? IconButton(
                                icon: Icon(Icons.clear,
                                    color:
                                    Colors.grey.shade500,
                                    size: 20),
                                onPressed: () {
                                  controller
                                      .estimatedTimeController
                                      .value
                                      .text = '';
                                  controller
                                      .estimatedTimeController
                                      .refresh();
                                },
                                padding: EdgeInsets.zero,
                                constraints:
                                const BoxConstraints(
                                    minWidth: 40),
                              )
                                  : Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Colors.grey.shade500,
                                size: 24,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                          title: 'Shipped order'.tr,
                          color: AppThemeData.secondary300,
                          textColor: AppThemeData.grey50,
                          onPress: () =>
                              _onShipPressed(ctx),
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

  Future<void> _onShipPressed(BuildContext ctx) async {
    if (controller.estimatedTimeController.value.text.isEmpty) {
      ShowToastDialog.showToast('Please enter estimated time'.tr);
      return;
    }

    final isSelfDelivery = Constant.isSelfDeliveryFeature == true &&
        controller.vendermodel.value.isSelfDelivery == true &&
        orderModel.takeAway == false;

    if (isSelfDelivery) {
      ShowToastDialog.showLoader('Please wait...'.tr);
      await controller.getAllDriverList();
      ShowToastDialog.closeLoader();
      orderModel.estimatedTimeToPrepare =
          controller.estimatedTimeController.value.text;
      Get.back();
      showDialog(
        context: context,
        builder: (_) => DeliveryManDialog(
          controller: controller,
          themeChange: themeChange,
          orderModel: orderModel,
        ),
      );
      return;
    }

    ShowToastDialog.showLoader('Please wait...'.tr);
    try {
      orderModel
        ..estimatedTimeToPrepare =
            controller.estimatedTimeController.value.text
        ..status = Constant.orderAccepted;

      await AudioPlayerService.playSound(false);

      // Radius fetch (cached)
      double radius = Constant.driverSearchRadius ?? 5.0;
      if (Constant.driverSearchRadius == null) {
        try {
          final res = await http.get(
            Uri.parse('${Constant.baseUrl}restaurant/GetDriverNearBy'),
            headers: {'Content-Type': 'application/json'},
          );
          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            if (data['success'] == true) {
              radius = double.tryParse(
                  data['data']['driverRadios'].toString()) ??
                  5.0;
              Constant.driverSearchRadius = radius;
            }
          }
        } catch (_) {
          radius = 5.0;
          Constant.driverSearchRadius = radius;
        }
      }

      orderModel.ensureMerchantPriceFromProducts();
      await Future.wait([
        FireStoreUtils.updateOrder(orderModel),
        FireStoreUtils.restaurantVendorWalletSet(orderModel),
      ]);

      // Notify nearby drivers
      await _notifyNearbyDrivers(radius);

      // Notify customer
      if (orderModel.author?.fcmToken?.isNotEmpty == true) {
        SendNotification.sendFcmMessage(
          Constant.restaurantAccepted,
          orderModel.author!.fcmToken!,
          {'orderId': orderModel.id ?? '', 'status': Constant.orderAccepted},
        ).catchError((_) {});
      }

      await controller.getOrder(silent: false);
    } catch (e) {
      debugPrint('Error accepting order: $e');
      ShowToastDialog.showToast(
          'Error processing order. Please try again.'.tr);
    } finally {
      ShowToastDialog.closeLoader();
      Get.back();
    }
  }

  Future<void> _notifyNearbyDrivers(double radius) async {
    final orderId = orderModel.id;
    if (orderId == null || orderId.isEmpty) return;

    final restaurantLat =
        controller.vendermodel.value.latitude ?? 0.0;
    final restaurantLng =
        controller.vendermodel.value.longitude ?? 0.0;
    final zoneId = controller.vendermodel.value.zoneId;

    final allDrivers =
    await FireStoreUtils.getAvalibleDrivers(zoneId: zoneId);

    final eligible = <UserModel>[];
    for (final d in allDrivers) {
      final lat = d.location?.latitude;
      final lng = d.location?.longitude;
      if (lat == null || lng == null) continue;
      try {
        final dist = Geolocator.distanceBetween(
            restaurantLat, restaurantLng, lat, lng) /
            1000;
        if (dist <= radius) eligible.add(d);
      } catch (_) {}
    }

    eligible.sort((a, b) {
      try {
        final da = Geolocator.distanceBetween(restaurantLat, restaurantLng,
            a.location!.latitude!, a.location!.longitude!);
        final db = Geolocator.distanceBetween(restaurantLat, restaurantLng,
            b.location!.latitude!, b.location!.longitude!);
        return da.compareTo(db);
      } catch (_) {
        return 0;
      }
    });

    const batchSize = 5;
    for (var i = 0; i < eligible.length; i += batchSize) {
      final batch = eligible.skip(i).take(batchSize).toList();
      await Future.wait(batch.map((driver) async {
        try {
          driver.role = Constant.userRoleDriver;
          final existing = <String>[];
          for (final item in driver.orderRequestData ?? []) {
            if (item is String) {
              existing.add(item);
            } else if (item is Map && item['id'] != null) {
              existing.add(item['id'].toString());
            }
          }
          if (existing.contains(orderId)) return;
          // driver.orderRequestData = [...existing, orderId];

          final updated = await FireStoreUtils.updateDriverUser(driver);
          if (!updated) return;

          if (driver.fcmToken?.isNotEmpty == true) {
            await SendNotification.sendFcmMessage(
              Constant.newDeliveryOrder,
              driver.fcmToken!,
              {'orderId': orderId},
            );
          }
        } catch (e) {
          debugPrint('Driver update error [${driver.firebaseId}]: $e');
        }
      }));
    }
  }
}
