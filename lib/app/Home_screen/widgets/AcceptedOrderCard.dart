import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:uuid/uuid.dart';
import '../../../constant/constant.dart';
import '../../../constant/send_notification.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/home_controller.dart';
import '../../../models/order_model.dart';
import '../../../models/wallet_transaction_model.dart';
import '../../../service/audio_player_service.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/round_button_fill.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';
import '../../../widget/my_separator.dart';
import 'CustomerRow.dart';
import 'NewOrderCard.dart';
import 'OrderCardShell.dart' show OrderCardShell;
import 'OrderMetaRows.dart';
import 'ProductList.dart';

class AcceptedOrderCard extends StatelessWidget {
  final OrderModel orderModel;
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final BuildContext context;

  const AcceptedOrderCard({
    required this.orderModel,
    required this.controller,
    required this.themeChange,
    required this.context,
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
        ProductList(orderModel: orderModel, themeChange: themeChange),
        OrderMetaRows(
          orderModel: orderModel,
          themeChange: themeChange,
          adminCommission: totals.adminCommission,
          controller: controller,
          parentContext: context,
        ),
        const SizedBox(height: 10),
        _AcceptedOrderActions(
          orderModel: orderModel,
          totals: totals,
          controller: controller,
          themeChange: themeChange,
          context: context,
        ),
      ],
    );
  }
}


class _AcceptedOrderActions extends StatelessWidget {
  final OrderModel orderModel;
  final OrderTotals totals;
  final HomeController controller;
  final DarkThemeProvider themeChange;
  final BuildContext context;

  const _AcceptedOrderActions({
    required this.orderModel,
    required this.totals,
    required this.controller,
    required this.themeChange,
    required this.context,
  });

  Future<void> _cancelOrder() async {
    final userId = await FireStoreUtils.getCurrentUid();
    ShowToastDialog.showLoader('Please wait...'.tr);
    await AudioPlayerService.playSound(false);

    orderModel.status = Constant.orderCancelled;

    if (orderModel.driverID != null) {
      final driver =
      await FireStoreUtils.getUserById(orderModel.driverID ?? '');
      if (driver != null) {
        // driver.orderRequestData?.remove(orderModel.id);
        // driver.inProgressOrderID?.remove(orderModel.id);
        await FireStoreUtils.updateDriverUser(driver);
        if (driver.fcmToken?.isNotEmpty == true) {
          SendNotification.sendFcmMessage(
            Constant.driverCancelled,
            driver.fcmToken!,
            {'title': 'Cancelled Order'},
          );
        }
      }
    }

    await FireStoreUtils.updateOrder(orderModel);

    if (orderModel.author?.fcmToken?.isNotEmpty == true) {
      SendNotification.sendFcmMessage(
        Constant.restaurantCancelled,
        orderModel.author!.fcmToken!,
        {'orderId': orderModel.id ?? '', 'status': Constant.orderCancelled},
      );
    }

    if (orderModel.paymentMethod?.toLowerCase() != 'cod') {
      final refund = totals.subTotal +
          (double.tryParse(orderModel.discount.toString()) ?? 0) +
          totals.specialDiscount +
          totals.taxAmount +
          (double.tryParse(orderModel.deliveryCharge.toString()) ?? 0) +
          (double.tryParse(orderModel.tipAmount.toString()) ?? 0);

      await FireStoreUtils.setWalletTransaction(WalletTransactionModel(
        amount: refund,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: orderModel.author!.id,
        date: Timestamp.now(),
        isTopup: true,
        paymentMethod: 'Wallet',
        paymentStatus: 'success',
        note: 'Order Refund success',
        transactionUser: 'user',
      ));
      await FireStoreUtils.updateUserWallet(
        amount: refund.toString(),
        userId: orderModel.author?.id ?? '',
      );
    }

    // Vendor wallet debit
    final disc = double.tryParse(orderModel.discount.toString()) ?? 0;
    final adminCommission = orderModel.adminCommission;
    double vendorAmount;
    if (adminCommission != null &&
        adminCommission != '0' &&
        adminCommission.isNotEmpty) {
      vendorAmount = (totals.subTotal /
          (1 + double.tryParse(adminCommission)! / 100)) -
          disc -
          totals.specialDiscount;
    } else {
      vendorAmount = totals.subTotal - disc - totals.specialDiscount;
    }

    await Future.wait([
      FireStoreUtils.setWalletTransaction(WalletTransactionModel(
        amount: totals.taxAmount,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: userId,
        date: Timestamp.now(),
        isTopup: false,
        paymentMethod: 'tax',
        paymentStatus: 'success',
        note: 'Tax Amount Refund',
        transactionUser: 'vendor',
      )),
      FireStoreUtils.setWalletTransaction(WalletTransactionModel(
        amount: vendorAmount,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: userId,
        date: Timestamp.now(),
        isTopup: false,
        paymentMethod: 'Wallet',
        paymentStatus: 'success',
        note: 'Order Amount Refund',
        transactionUser: 'vendor',
      )),
    ]);

    await FireStoreUtils.updateUserWallet(
      amount: (-(vendorAmount + totals.taxAmount)).toString(),
      userId: FireStoreUtils.getCurrentUid().toString(),
    );

    await controller.getOrder(silent: false);
    ShowToastDialog.closeLoader();
    Get.back();
  }

  Future<void> _markDelivered() async {
    ShowToastDialog.showLoader('Please wait...'.tr);
    await AudioPlayerService.playSound(false);
    orderModel.status = Constant.orderCompleted;
    await Future.wait([
      FireStoreUtils.updateOrder(orderModel),
      FireStoreUtils.restaurantVendorWalletSet(orderModel),
    ]);
    if (orderModel.author?.fcmToken?.isNotEmpty == true) {
      SendNotification.sendFcmMessage(
        Constant.takeawayCompleted,
        orderModel.author!.fcmToken!,
        {},
      );
    }
    await controller.getOrder(silent: false);
    ShowToastDialog.closeLoader();
  }

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: RoundedButtonFill(
              title: 'Cancel Order'.tr,
              color: AppThemeData.new_primary,
              textColor: AppThemeData.grey50,
              height: 5,
              onPress: _cancelOrder,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: orderModel.takeAway == true
                ? RoundedButtonFill(
              title: 'Delivered'.tr,
              color: AppThemeData.primary300,
              textColor: AppThemeData.grey50,
              height: 5,
              onPress: _markDelivered,
            )
                : RoundedButtonFill(
              title: orderModel.status ?? '',
              color: AppThemeData.new_green_tog,
              textColor: AppThemeData.grey50,
              height: 5,
              onPress: () {},
            ),
          ),
        ],
      ),
    );
  }
}
