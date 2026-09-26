


import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/models/cart_product_model.dart';
import 'package:jippymart_restaurant/models/order_model.dart';
import 'package:jippymart_restaurant/models/merchant_response_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';
import 'package:jippymart_restaurant/service/audio_player_service.dart';
import 'package:jippymart_restaurant/service/order_api_service.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

import '../models/outlet_model.dart';
import '../utils/common.dart';
import '../utils/preferences.dart';

class HomeController extends GetxController {
  // ── Observables ──────────────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isFetchingOrders = false.obs;
  final RxBool isFloating = false.obs;
  final RxInt selectedTabIndex = 0.obs;

  final Rx<TextEditingController> estimatedTimeController =
      TextEditingController().obs;

  final Rx<UserModel> userModel = UserModel().obs;
  final Rx<VendorModel> vendermodel = VendorModel().obs;
  Rx<OutletModel> outletModel = OutletModel().obs;


  final RxList<OrderModel> allOrderList = <OrderModel>[].obs;
  final RxList<OrderModel> newOrderList = <OrderModel>[].obs;
  final RxList<OrderModel> acceptedOrderList = <OrderModel>[].obs;
  final RxList<OrderModel> completedOrderList = <OrderModel>[].obs;
  final RxList<OrderModel> rejectedOrderList = <OrderModel>[].obs;
  final RxList<OrderModel> cancelledOrderList = <OrderModel>[].obs;

  final RxList<UserModel> driverUserList = <UserModel>[].obs;
  final Rx<UserModel> selectDriverUser = UserModel().obs;

  RxList<OutletModel> outletList = <OutletModel>[].obs;
  RxInt selectedOutletId = 0.obs;

  // ── Private state ─────────────────────────────────────────────────────────
  Timer? _orderPollingTimer;
  bool _isPollingActive = false;
  int _previousNewOrderCount = 0;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    getUserProfile();
    super.onInit();
  }

  @override
  void onClose() {
    _stopPolling();
    AudioPlayerService.playSound(false);
    estimatedTimeController.value.dispose();
    super.onClose();
  }

  // ── Public helpers ────────────────────────────────────────────────────────
  void toggleFloating() => isFloating.toggle();

  // ── Profile ───────────────────────────────────────────────────────────────
  Future<void> getUserProfile({bool withOrders = true}) async {
    try {
      final merchantId = Preferences.getString('merchantId').trim();

      MerchantModel? profile = Constant.merchantModel;
      if (profile == null) {
        final id = merchantId.isNotEmpty ? merchantId : await FireStoreUtils.getCurrentUid();
        if (id.isEmpty) {
          debugPrint('⚠️ getUserProfile: empty merchant ID');
          return;
        }
        profile = await FireStoreUtils.getMerchantProfile(id);
      }

      if (profile == null) {
        debugPrint('⚠️ getUserProfile: profile not found');
        return;
      }

      _applyMerchantToUser(profile);

      if (withOrders) {
        await getOrder();
        _startOrderPolling();
      }
    } catch (e) {
      debugPrint('⚠️ getUserProfile exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Maps the backend merchant profile into the legacy UI-facing [UserModel].
  void _applyMerchantToUser(MerchantModel profile) {
    Constant.merchantModel = profile;
    userModel.value = UserModel(
      id: profile.merchantId?.toString(),
      firstName: profile.firstName ?? profile.merchantName,
      lastName: profile.lastName,
      email: profile.merchantEmail,
      phoneNumber: profile.merchantPhone,
      isDocumentVerify: profile.isApproved,
    );
    Constant.userModel = userModel.value;
  }



  // ── Polling ───────────────────────────────────────────────────────────────
  void _startOrderPolling() {
    if (_isPollingActive) return;
    _isPollingActive = true;
    _orderPollingTimer =
        Timer.periodic(const Duration(seconds: 10), (_) {
          if (!_isPollingActive ||
              Constant.userModel?.vendorID == null) {
            _stopPolling();
            return;
          }
          if (!isFetchingOrders.value) getOrder(silent: true);
        });
  }

  void _stopPolling() {
    _isPollingActive = false;
    _orderPollingTimer?.cancel();
    _orderPollingTimer = null;
  }

  /// Cheap identity signature of an order covering every field the cards
  /// render. Used to avoid rebuilding identical order tabs on each poll.
  String _orderSnapshotKey(OrderModel o) => [
    o.id,
    o.status,
    o.driverID,
    o.estimatedTimeToPrepare,
    o.merchant_price?.toString(),
    o.deliveryCharge,
    o.tipAmount,
    o.discount?.toString(),
    (o.rejectedByDrivers?.length ?? 0).toString(),
  ].join('|');

  bool _sameOrderSnapshot(List<OrderModel> a, List<OrderModel> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (_orderSnapshotKey(a[i]) != _orderSnapshotKey(b[i])) return false;
    }
    return true;
  }

  void stopOrderPolling() {
    _stopPolling();
    AudioPlayerService.playSound(false);
    debugPrint('⏹️ Order polling stopped');
  }

  void resumeOrderPolling() {
    if (Constant.userModel?.vendorID != null && !_isPollingActive) {
      _startOrderPolling();
    }
  }
  Future<void> loadOutletData(
      int outletId,
      ) async {

    print(
      "Loading outlet data => $outletId",
    );

    selectedOutletId.value =
        outletId;

    await refreshOutletProfile(outletId);

    await getOrder();

  }

  /// Reloads the active outlet's profile (incl. outletPicUrl) into [outletModel].
  Future<void> refreshOutletProfile([int? outletId]) async {
    final id = outletId ?? _activeOutletId;
    if (id <= 0) return;
    try {
      final outlet = await FireStoreUtils.getOutletProfile(id);
      if (outlet != null) {
        outletModel.value = outlet;
      }
    } catch (e) {
      debugPrint('refreshOutletProfile error: $e');
    }
  }

  int get _activeOutletId {
    final outletId = Preferences.getInt('outletId');
    if (outletId > 0) return outletId;
    return Preferences.getInt('selectedOutletId');
  }

  /// Outlet the order list currently belongs to. Needed by APIs that take the
  /// outlet id in the request body (e.g. accept/reject order).
  int get activeOutletId =>
      selectedOutletId.value > 0 ? selectedOutletId.value : _activeOutletId;

  /// Accepts or rejects an order through
  /// `POST /api/co/acceptOrRejectOrderByOutlet`. The backend owns the rejection
  /// record, the refund and the driver dispatch, so nothing else is triggered
  /// here. Returns `true` when the status was updated.
  Future<bool> updateOrderStatus({
    required OrderModel order,
    required OutletOrderAction action,
    int? preparationTimeInMins,
    String? rejectionReason,
  }) async {
    final orderId = order.id;
    if (orderId == null || orderId.isEmpty) {
      ShowToastDialog.showToast('Order id is missing'.tr);
      return false;
    }

    final outletId = activeOutletId;
    if (outletId <= 0) {
      ShowToastDialog.showToast('Please select an outlet'.tr);
      return false;
    }

    ShowToastDialog.showLoader('Please wait...'.tr);
    try {
      final result = await OrderApiService.acceptOrRejectOrderByOutlet(
        orderId: orderId,
        outletId: outletId,
        action: action,
        preparationTimeInMins: preparationTimeInMins,
        rejectionReason: rejectionReason,
      );

      if (!result.success) {
        ShowToastDialog.showToast(result.message);
        return false;
      }

      if (action == OutletOrderAction.accept) {
        order
          ..status = Constant.orderAccepted
          ..estimatedTimeToPrepare = estimatedTimeController.value.text;
      } else {
        order.status = Constant.orderRejected;
      }

      await AudioPlayerService.playSound(false);
      await getOrder(silent: false);

      ShowToastDialog.showToast(
        action == OutletOrderAction.accept
            ? 'Order accepted successfully'.tr
            : 'Order rejected successfully'.tr,
      );
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      ShowToastDialog.showToast(
          'Error processing order. Please try again.'.tr);
      return false;
    } finally {
      ShowToastDialog.closeLoader();
    }
  }
  // ── Orders ────────────────────────────────────────────────────────────────
  Future<void> getOrder({bool silent = false}) async {
    if (isFetchingOrders.value && silent) return;

    final outletId = _activeOutletId;
    if (outletId <= 0) {
      debugPrint('⚠️ No outlet ID – skipping order fetch');
      return;
    }

    final url = '${Constant.baseUrl}fm/outlets/orderSummaryForOutlet'
        '?outletId=$outletId&page=0&size=20';
    if (!silent) debugPrint('🔄 Fetching orders: $url');

    isFetchingOrders.value = true;
    try {
      final headers = await getHeaders();
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15),
          onTimeout: () =>
          throw TimeoutException('Order fetch timed out'));

      if (response.statusCode != 200) {
        if (!silent) debugPrint('❌ HTTP ${response.statusCode}');
        return;
      }

      final decoded = jsonDecode(response.body);
      final rawList = decoded is List ? decoded : <dynamic>[];
      final parsed = <OrderModel>[];
      var errors = 0;

      for (final el in rawList) {
        if (el is! Map<String, dynamic>) {
          errors++;
          continue;
        }
        try {
          parsed.add(_outletSummaryToOrderModel(el));
        } catch (e) {
          errors++;
          if (!silent) debugPrint('❌ Parse error [${el['orderId']}]: $e');
        }
      }

      if (!silent) {
        debugPrint(
            '📊 Parsed ${parsed.length} ok / $errors failed');
      }

      // ── Filter ───────────────────────────────────────────────────────────
      final prevCount = _previousNewOrderCount;

      final newList = parsed
          .where((o) =>
      o.status == Constant.orderPlaced ||
          o.status?.toLowerCase() == 'pending')
          .toList();

      final acceptedList = parsed
          .where((o) =>
      o.status == Constant.orderAccepted ||
          o.status == Constant.driverAccepted ||
          o.status == Constant.driverPending ||
          o.status == Constant.driverRejected ||
          o.status == Constant.orderShipped ||
          o.status == Constant.orderInTransit)
          .toList();

      final completedList =
          parsed.where((o) => o.status == Constant.orderCompleted).toList();

      final rejectedList =
          parsed.where((o) => o.status == Constant.orderRejected).toList();

      final cancelledList =
          parsed.where((o) => o.status == Constant.orderCancelled).toList();

      allOrderList
        ..clear()
        ..addAll(parsed);

      // Only reassign the filtered lists (and thus notify the UI) when the
      // order snapshot actually changed. Every 10s poll otherwise tears down
      // and rebuilds every visible order card even when nothing changed.
      final changed =
          !_sameOrderSnapshot(newList, newOrderList) ||
          !_sameOrderSnapshot(acceptedList, acceptedOrderList) ||
          !_sameOrderSnapshot(completedList, completedOrderList) ||
          !_sameOrderSnapshot(rejectedList, rejectedOrderList) ||
          !_sameOrderSnapshot(cancelledList, cancelledOrderList);

      if (changed) {
        newOrderList.value = newList;
        acceptedOrderList.value = acceptedList;
        completedOrderList.value = completedList;
        rejectedOrderList.value = rejectedList;
        cancelledOrderList.value = cancelledList;
        update();
      }

      if (!silent) {
        debugPrint(
            '✅ New:${newOrderList.length} Accepted:${acceptedOrderList.length} '
                'Done:${completedOrderList.length} Rejected:${rejectedOrderList.length} '
                'Cancelled:${cancelledOrderList.length}');
      }

      await _updateSoundState(prevCount, newOrderList.length, silent);
      _previousNewOrderCount = newOrderList.length;
    } on TimeoutException catch (e) {
      if (!silent) debugPrint('⏱️ Timeout: $e');
    } catch (e, st) {
      if (!silent) {
        debugPrint('❌ getOrder error: $e\n$st');
      }
    } finally {
      isFetchingOrders.value = false;
    }
  }

  /// Maps the FM `orderSummaryForOutlet` payload onto the existing
  /// [OrderModel] so the order tabs/cards can render it unchanged.
  OrderModel _outletSummaryToOrderModel(Map<String, dynamic> json) {
    final products = <CartProductModel>[];
    final rawProducts = json['merchantOrderProductDtoList'];
    if (rawProducts is List) {
      for (final raw in rawProducts) {
        if (raw is! Map<String, dynamic>) continue;
        final unitPrice = raw['merchantUnitPrice'];
        final rawName = raw['productName']?.toString() ?? '';
        final variantName = _variantOptionName(raw);
        products.add(CartProductModel(
          id: raw['productId']?.toString(),
          name: rawName.isNotEmpty
              ? rawName
              : (variantName ?? 'Item #${raw['productId'] ?? ''}'),
          photo: raw['productPicUrl']?.toString(),
          quantity: _toInt(raw['quantity']),
          price: unitPrice?.toString(),
          merchant_price: unitPrice?.toString(),
          variantInfo: _variantOptionName(raw) != null
              ? VariantInfo(
                  variantId: raw['variantOptionsId']?.toString(),
                  variantOptions: {'Variant': _variantOptionName(raw)!},
                )
              : null,
        ));
      }
    }

    return OrderModel(
      id: json['orderId']?.toString(),
      status: _mapOutletOrderStatus(json['orderStatus']?.toString()),
      merchant_price: _toNum(json['totalPrice']),
      notes: json['cookingInstructions']?.toString(),
      createdAt: _parseOutletTimestamp(json['orderCreatedAt']?.toString()),
      products: products,
    );
  }

  String? _variantOptionName(Map<String, dynamic> raw) {
    final name = raw['variantOptionName']?.toString();
    return (name == null || name.isEmpty) ? null : name;
  }

  String? _mapOutletOrderStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
      case 'NEW':
        return Constant.orderPlaced;
      case 'ORDER_ACCEPTED':
      case 'ACCEPTED':
        return Constant.orderAccepted;
      case 'ORDER_COMPLETED':
      case 'COMPLETED':
      case 'ORDER_DELIVERED':
      case 'DELIVERED':
        return Constant.orderCompleted;
      case 'ORDER_REJECTED':
      case 'REJECTED':
        return Constant.orderRejected;
      case 'ORDER_CANCELLED':
      case 'CANCELLED':
        return Constant.orderCancelled;
      default:
        return status;
    }
  }

  int _toInt(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 1;
  }

  num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }

  Timestamp? _parseOutletTimestamp(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return Timestamp.fromDate(DateTime.parse(value));
    } catch (_) {
      return null;
    }
  }

  // ── Sound management ──────────────────────────────────────────────────────
  Future<void> _updateSoundState(
      int prev, int current, bool silent) async {
    try {
      await AudioPlayerService.initAudio();
      if (current == 0) {
        await AudioPlayerService.playSound(false);
      } else if (prev > 0 && current < prev) {
        await AudioPlayerService.playSound(false);
      } else if (current > prev) {
        await AudioPlayerService.playSound(true);
      } else if (current > 0 && prev == 0 && !silent) {
        await AudioPlayerService.playSound(true);
      }
    } catch (e) {
      debugPrint('⚠️ Sound error: $e');
    }
  }

  // ── Drivers ───────────────────────────────────────────────────────────────
  Future<void> getAllDriverList() async {
    final drivers = await FireStoreUtils.getAvalibleDrivers();
    if (drivers.isNotEmpty) driverUserList.value = drivers;
    isLoading.value = false;
  }

  // ── Refresh ───────────────────────────────────────────────────────────────
  Future<void> refreshApp() async {
    isLoading.value = true;
    try {
      await Future.wait([
        if (Constant.userModel?.vendorID != null) getOrder(silent: false),
        getUserProfile(withOrders: false),
      ]);

      try {
        await Get.find<DashBoardController>().getVendor();
      } catch (_) {
        // DashBoardController not mounted – ignore
      }
    } finally {
      isLoading.value = false;
    }
  }
}