


import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/models/order_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';
import 'package:jippymart_restaurant/service/audio_player_service.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

import '../models/outlet_model.dart';
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
      final userId = await FireStoreUtils.getCurrentUid();
      if (userId.isEmpty) {
        debugPrint('⚠️ getUserProfile: empty user ID');
        return;
      }

      final value = await FireStoreUtils.getUserProfile(userId);
      if (value == null) {
        debugPrint('⚠️ getUserProfile: profile not found');
        return;
      }

      userModel.value = value;
      Constant.userModel = value;

      final vendorId = value.vendorID;
      if (vendorId == null || vendorId.isEmpty) return;

      // Fetch vendor (non-blocking)
      FireStoreUtils.getVendorById(vendorId).then((vender) {
        if (vender?.id != null) vendermodel.value = vender!;
      }).catchError((e) => debugPrint('⚠️ Vendor fetch error: $e'));

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
  // ── Orders ────────────────────────────────────────────────────────────────
  Future<void> getOrder({bool silent = false}) async {
    if (isFetchingOrders.value && silent) return;

    final vendorId = Constant.userModel?.vendorID;
    if (vendorId == null || vendorId.isEmpty) {
      debugPrint('⚠️ No vendor ID – skipping order fetch');
      return;
    }

    final url = '${Constant.baseUrl}orders/vendor/$vendorId';
    if (!silent) debugPrint('🔄 Fetching orders: $url');

    isFetchingOrders.value = true;
    try {
      final response = await http
          .get(Uri.parse(url),
          headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15),
          onTimeout: () =>
          throw TimeoutException('Order fetch timed out'));

      if (response.statusCode != 200) {
        if (!silent) debugPrint('❌ HTTP ${response.statusCode}');
        return;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] != true) {
        if (!silent) {
          debugPrint('⚠️ API error: ${json['message']}');
        }
        return;
      }

      final rawList = json['data'] as List<dynamic>;
      final parsed = <OrderModel>[];
      var errors = 0;

      for (final el in rawList) {
        try {
          final order = OrderModel.fromJson(el as Map<String, dynamic>);
          order.id = el['id'] as String?;
          parsed.add(order);
        } catch (e) {
          errors++;
          if (!silent) debugPrint('❌ Parse error [${el['id']}]: $e');
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