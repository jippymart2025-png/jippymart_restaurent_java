import 'dart:convert' show json;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/constant/collection_name.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/payment_model/flutter_wave_model.dart';
import 'package:jippymart_restaurant/models/payment_model/paypal_model.dart';
import 'package:jippymart_restaurant/models/payment_model/razorpay_model.dart';
import 'package:jippymart_restaurant/models/payment_model/stripe_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/wallet_transaction_model.dart';
import 'package:jippymart_restaurant/models/withdraw_method_model.dart';
import 'package:jippymart_restaurant/models/withdrawal_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class WalletController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<TextEditingController> amountTextFieldController =
      TextEditingController().obs;
  Rx<TextEditingController> noteTextFieldController =
      TextEditingController().obs;

  Rx<UserModel> userModel = UserModel().obs;
  RxList<WalletTransactionModel> walletTransactionList =
      <WalletTransactionModel>[].obs;
  RxList<WithdrawalModel> withdrawalList = <WithdrawalModel>[].obs;

  RxInt selectedTabIndex = 0.obs;
  RxInt selectedValue = 0.obs;

  Rx<WithdrawMethodModel> withdrawMethodModel = WithdrawMethodModel().obs;

  Rx<RazorPayModel> razorPayModel = RazorPayModel().obs;
  Rx<PayPalModel> paypalDataModel = PayPalModel().obs;
  Rx<StripeModel> stripeSettingData = StripeModel().obs;
  Rx<FlutterWaveModel> flutterWaveSettingData = FlutterWaveModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getWalletTransaction(false);

    super.onInit();
  }

  @override
  void onClose() {
    amountTextFieldController.value.dispose();
    noteTextFieldController.value.dispose();
    super.onClose();
  }

  Future<void> createAndSavePdf() async {
    // Create a new PDF document
    final PdfDocument document = PdfDocument();

    // Add a page to the document
    final PdfPage page = document.pages.add();

    // Create a PDF grid (table)
    final PdfGrid grid = PdfGrid();

    // Add columns to the grid
    grid.columns.add(count: 4);

    // Add headers to the grid
    grid.headers.add(1);
    final PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Description';
    header.cells[1].value = 'Order Id';
    header.cells[2].value = 'Amount';
    header.cells[3].value = 'Date';

    // Add rows to the grid
    PdfGridRow row = grid.rows.add();
    for (var element in walletTransactionList) {
      row.cells[0].value = element.note.toString();
      row.cells[1].value =
          Constant.orderId(orderId: element.orderId.toString());
      row.cells[2].value =
          Constant.amountShow(amount: element.amount.toString());
      row.cells[3].value = Constant.timestampToDateTime(element.date!);
      row = grid.rows.add();
    }

    // Draw the grid on the page
    grid.draw(
      page: page,
      bounds: const Rect.fromLTWH(0, 0, 0, 0),
    );

    // Save the document
    final List<int> bytes = document.saveSync();

    // Dispose of the document
    document.dispose();

    // Get the application directory
    final Directory? downloadsDirectory =
        Directory('/storage/emulated/0/Download');
    if (downloadsDirectory != null) {
      final String path = '${downloadsDirectory.path}/statement.pdf';
      final File file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      ShowToastDialog.showToast("Statement downloaded in download folder".tr);
      print('PDF saved at: $path');
    }
  }

  RxDouble orderAmount = 0.0.obs;
  RxDouble taxAmount = 0.0.obs;

  Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 1)).obs;
  Rx<DateTime> endDate = DateTime.now().obs;

  getWalletTransaction(bool isFilter) async {
    final Future<List<WalletTransactionModel>?> source = isFilter
        ? FireStoreUtils.getFilterWalletTransaction(
            Timestamp.fromDate(DateTime(startDate.value.year,
                startDate.value.month, startDate.value.day, 00, 00)),
            Timestamp.fromDate(DateTime(endDate.value.year,
                endDate.value.month, endDate.value.day, 23, 59)))
        : FireStoreUtils.getWalletTransaction();

    await source.then(
      (value) {
        if (value != null) {
          walletTransactionList.value = value;

          double tax = 0.0;
          double orders = 0.0;
          for (final element in value) {
            if (element.paymentMethod == "tax") {
              if (element.isTopup == false) {
                tax -= double.parse(element.amount.toString());
              } else {
                tax += double.parse(element.amount.toString());
              }
            } else {
              if (element.isTopup == false) {
                orders -= double.parse(element.amount.toString());
              } else {
                orders += double.parse(element.amount.toString());
              }
            }
          }
          taxAmount.value = tax;
          orderAmount.value = orders;
        }
      },
    );

    await FireStoreUtils.getWithdrawHistory().then(
      (value) {
        if (value != null) {
          withdrawalList.value = value;
        }
      },
    );
    String userId = await FireStoreUtils.getCurrentUid();
    await FireStoreUtils.getUserProfile(userId).then(
      (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );
    await getPaymentMethod();
    isLoading.value = false;
  }

  getPaymentMethod() async {
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}settings/payment'),
        headers: {
          'Content-Type': 'application/json',
          // Add any required headers like authorization if needed
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> paymentData = data['data'];

        // Parse RazorPay settings
        if (paymentData.containsKey('razorpaySettings')) {
          try {
            razorPayModel.value = RazorPayModel.fromJson(paymentData['razorpaySettings']);
          } catch (e) {
            debugPrint('Failed to parse razorpaySettings: $e');
          }
        }

        // Parse PayPal settings
        if (paymentData.containsKey('paypalSettings')) {
          try {
            paypalDataModel.value = PayPalModel.fromJson(paymentData['paypalSettings']);
          } catch (e) {
            debugPrint('Failed to parse paypalSettings: $e');
          }
        }

        // Parse Stripe settings
        if (paymentData.containsKey('stripeSettings')) {
          try {
            stripeSettingData.value = StripeModel.fromJson(paymentData['stripeSettings']);
          } catch (e) {
            debugPrint('Failed to parse stripeSettings: $e');
          }
        }

        // Parse FlutterWave settings
        if (paymentData.containsKey('flutterWave')) {
          try {
            flutterWaveSettingData.value = FlutterWaveModel.fromJson(paymentData['flutterWave']);
          } catch (e) {
            debugPrint('Failed to parse flutterWave: $e');
          }
        }

        // Handle withdraw method - you might need to adjust this based on your API
        // If you have a separate endpoint for withdraw methods, call it here
        // Otherwise, if it's included in the payment response, parse it accordingly
        await _handleWithdrawMethod();

      } else {
        debugPrint('Failed to load payment methods: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getPaymentMethod: $e');
    }
  }

// Helper method for withdraw method (adjust based on your API)
  _handleWithdrawMethod() async {

    await FireStoreUtils.getWithdrawMethod().then(
          (value) {
        if (value != null) {
          withdrawMethodModel.value = value;
        }
      },
    );
    // Or if withdraw method is included in the payment response, parse it here
    // For now, I'll leave this as a placeholder since I don't see withdraw method in your response
  }
  // getPaymentMethod() async {
  //   await FireStoreUtils.fireStore
  //       .collection(CollectionName.settings)
  //       .doc("razorpaySettings")
  //       .get()
  //       .then((user) {
  //     try {
  //       razorPayModel.value = RazorPayModel.fromJson(user.data() ?? {});
  //     } catch (e) {
  //       debugPrint(
  //           'FireStoreUtils.getUserByID failed to parse user object ${user.id}');
  //     }
  //   });
  //
  //   await FireStoreUtils.fireStore
  //       .collection(CollectionName.settings)
  //       .doc("paypalSettings")
  //       .get()
  //       .then((paypalData) {
  //     try {
  //       paypalDataModel.value = PayPalModel.fromJson(paypalData.data() ?? {});
  //     } catch (error) {
  //       debugPrint(error.toString());
  //     }
  //   });
  //
  //   await FireStoreUtils.fireStore
  //       .collection(CollectionName.settings)
  //       .doc("stripeSettings")
  //       .get()
  //       .then((paypalData) {
  //     try {
  //       stripeSettingData.value = StripeModel.fromJson(paypalData.data() ?? {});
  //     } catch (error) {
  //       debugPrint(error.toString());
  //     }
  //   });
  //
  //   await FireStoreUtils.fireStore
  //       .collection(CollectionName.settings)
  //       .doc("flutterWave")
  //       .get()
  //       .then((paypalData) {
  //     try {
  //       flutterWaveSettingData.value =
  //           FlutterWaveModel.fromJson(paypalData.data() ?? {});
  //     } catch (error) {
  //       debugPrint(error.toString());
  //     }
  //   });
  //
  //   await FireStoreUtils.getWithdrawMethod().then(
  //     (value) {
  //       if (value != null) {
  //         withdrawMethodModel.value = value;
  //       }
  //     },
  //   );
  // }
}
