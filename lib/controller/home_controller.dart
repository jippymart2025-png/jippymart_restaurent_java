// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
// import 'package:jippymart_restaurant/models/order_model.dart';
// import 'package:jippymart_restaurant/models/user_model.dart';
// import 'package:jippymart_restaurant/models/vendor_model.dart';
// import 'package:jippymart_restaurant/service/audio_player_service.dart';
// import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
//
// class HomeController extends GetxController {
//
//   RxBool isFloating= false.obs;
//
//   void isFloatingFunction(){
//     if(isFloating.value){
//       isFloating.value = false;
//     }else{
//       isFloating.value=true;
//     }
//   }
//   RxBool isLoading = true.obs;
//   RxBool isFetchingOrders = false.obs;
//
//   Rx<TextEditingController> estimatedTimeController =
//       TextEditingController().obs;
//
//   RxInt selectedTabIndex = 0.obs;
//
//   Timer? _orderPollingTimer;
//   bool _isPollingActive = false;
//   int _previousNewOrderCount = 0;
//
//   @override
//   void onInit() {
//     super.onInit();
//     getUserProfile();
//   }
//
//   @override
//   void onClose() {
//     _orderPollingTimer?.cancel();
//     _orderPollingTimer = null;
//     _isPollingActive = false;
//     // Ensure any ringing sound is stopped when leaving the screen/app.
//     AudioPlayerService.playSound(false);
//     estimatedTimeController.value.dispose();
//     super.onClose();
//   }
//
//   RxList<OrderModel> allOrderList = <OrderModel>[].obs;
//   RxList<OrderModel> newOrderList = <OrderModel>[].obs;
//   RxList<OrderModel> acceptedOrderList = <OrderModel>[].obs;
//   RxList<OrderModel> completedOrderList = <OrderModel>[].obs;
//   RxList<OrderModel> rejectedOrderList = <OrderModel>[].obs;
//   RxList<OrderModel> cancelledOrderList = <OrderModel>[].obs;
//
//   Rx<UserModel> userModel = UserModel().obs;
//   Rx<VendorModel> vendermodel = VendorModel().obs;
//
//   Future<void> getUserProfile({bool withOrders = true}) async {
//     try {
//       String userId = await FireStoreUtils.getCurrentUid();
//       if (userId.isEmpty) {
//         print("⚠️ getUserProfile: User ID is empty, cannot fetch profile");
//         isLoading.value = false;
//         return;
//       }
//       await FireStoreUtils.getUserProfile(userId).then(
//         (value) {
//           if (value != null) {
//             userModel.value = value;
//             Constant.userModel = userModel.value;
//             // Only proceed if we have a valid user model with vendor ID
//             if (userModel.value.vendorID != null && userModel.value.vendorID!.isNotEmpty) {
//               FireStoreUtils.getVendorById(userModel.value.vendorID!).then(
//                 (vender) {
//                   if (vender?.id != null) {
//                     vendermodel.value = vender!;
//                   }
//                 },
//               ).catchError((error) {
//                 print("⚠️ Error fetching vendor: $error");
//               });
//               // Start fetching orders and polling once vendor ID is available,
//               // but allow callers to skip this when they only need fresh profile data
//               if (withOrders) {
//                 getOrder().catchError((error) {
//                   print("⚠️ Error fetching orders: $error");
//                 });
//                 _startOrderPolling();
//               }
//             }
//           } else {
//             print("⚠️ getUserProfile: User profile not found (404 or null response)");
//           }
//         },
//       ).catchError((error) {
//         print("⚠️ Error in getUserProfile: $error");
//       });
//     } catch (e) {
//       print("⚠️ Exception in getUserProfile: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Start periodic polling for orders
//   void _startOrderPolling() {
//     if (_isPollingActive) return;
//
//     _isPollingActive = true;
//     // Poll every 10 seconds for new orders
//     _orderPollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
//       if (!_isPollingActive || Constant.userModel?.vendorID == null) {
//         timer.cancel();
//         return;
//       }
//       // Only poll if not currently fetching to avoid overlapping requests
//       if (!isFetchingOrders.value) {
//         getOrder(silent: true);
//       }
//     });
//   }
//
//   // Stop polling (useful when app goes to background)
//   void stopOrderPolling() {
//     _isPollingActive = false;
//     _orderPollingTimer?.cancel();
//     _orderPollingTimer = null;
//     // If app goes background, ensure ringtone doesn't keep playing.
//     AudioPlayerService.playSound(false);
//     print('⏹️ Stopped order polling');
//   }
//
//   // Resume polling
//   void resumeOrderPolling() {
//     if (Constant.userModel?.vendorID != null && !_isPollingActive) {
//       _startOrderPolling();
//     }
//   }
//
//   RxList<UserModel> driverUserList = <UserModel>[].obs;
//   Rx<UserModel> selectDriverUser = UserModel().obs;
//   getAllDriverList() async {
//     await FireStoreUtils.getAvalibleDrivers().then(
//       (value) {
//         if (value.isNotEmpty == true) {
//           driverUserList.value = value;
//         }
//       },
//     );
//     isLoading.value = false;
//   }
//   // getOrder() async {
//   //   print('🔄 Setting up order listener for vendor: ${Constant.userModel?.vendorID}');
//   //
//   //   FireStoreUtils.fireStore
//   //       .collection(CollectionName.restaurantOrders)
//   //       .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
//   //       .orderBy('createdAt', descending: true)
//   //       .snapshots()
//   //       .listen(
//   //         (event) async {
//   //       // Clear cache by checking metadata
//   //       if (event.metadata.hasPendingWrites) {
//   //         print('📝 Local changes detected, skipping...');
//   //         return;
//   //       }
//   //
//   //       print('📦 Received ${event.docs.length} orders from Firebase');
//   //       allOrderList.clear();
//   //
//   //       for (var element in event.docs) {
//   //         OrderModel orderModel = OrderModel.fromJson(element.data());
//   //         orderModel.id = element.id;
//   //
//   //         // Skip if this is from cache and we want fresh data only
//   //         if (element.metadata.isFromCache) {
//   //           print('⚡ Skipping cached data');
//   //           continue;
//   //         }
//   //
//   //         allOrderList.add(orderModel);
//   //         print('📋 Order ${orderModel.id}: Status = "${orderModel.status}"');
//   //       }
//   //
//   //       // Your existing filtering logic...
//   //       newOrderList.value = allOrderList
//   //           .where((p0) => p0.status == Constant.orderPlaced || p0.status == "pending")
//   //           .toList();
//   //             acceptedOrderList.value = allOrderList
//   //                 .where((p0) =>
//   //                     p0.status == Constant.orderAccepted ||
//   //                     p0.status == Constant.driverAccepted ||
//   //                     p0.status == Constant.driverPending ||
//   //                     p0.status == Constant.driverRejected ||
//   //                     p0.status == Constant.orderShipped ||
//   //                     p0.status == Constant.orderInTransit)
//   //                 .toList();
//   //             completedOrderList.value = allOrderList
//   //                 .where((p0) => p0.status == Constant.orderCompleted)
//   //                 .toList();
//   //             rejectedOrderList.value = allOrderList
//   //                 .where((p0) => p0.status == Constant.orderRejected)
//   //                 .toList();
//   //             cancelledOrderList.value = allOrderList
//   //                 .where((p0) => p0.status == Constant.orderCancelled)
//   //                 .toList();
//   //       update();
//   //       if (newOrderList.isNotEmpty == true) {
//   //         print('🔔 Playing notification sound for new orders');
//   //         await AudioPlayerService.playSound(true);
//   //       }
//   //     },
//   //   );
//   // }
//
//
//   Future<void> getOrder({bool silent = false}) async {
//     // Prevent multiple simultaneous requests
//     if (isFetchingOrders.value && silent) {
//       return;
//     }
//     if (Constant.userModel?.vendorID == null || Constant.userModel!.vendorID!.isEmpty) {
//       print('⚠️ Vendor ID not available, skipping order fetch');
//       return;
//     }
//     String? url = '${Constant.baseUrl}orders/vendor/${Constant.userModel?.vendorID}';
//     print("getOrdergetOrder ${url}");
//     if (!silent) {
//       print('🔄 Fetching orders for vendor: ${Constant.userModel?.vendorID}');
//     }
//     isFetchingOrders.value = true;
//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       ).timeout(
//         const Duration(seconds: 15),
//         onTimeout: () {
//           throw TimeoutException('Order fetch request timed out');
//         },
//       );
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);
//         if (jsonResponse['success'] == true) {
//           List<OrderModel> allOrderTemp = [];
//           int successCount = 0;
//           int errorCount = 0;
//           for (var element in jsonResponse['data']) {
//             try {
//               OrderModel orderModel = OrderModel.fromJson(element);
//               orderModel.id = element['id']; // Ensure ID is set
//               allOrderTemp.add(orderModel);
//               successCount++;
//             } catch (e) {
//               errorCount++;
//               if (!silent) {
//                 print('❌ Error parsing order ${element['id']}: $e');
//               }
//             }
//           }
//           if (!silent) {
//             print('📊 Order processing summary: $successCount successful, $errorCount failed');
//           }
//           // Store previous count before updating to detect new orders
//           int previousNewOrderCount = _previousNewOrderCount;
//           // Update reactive lists
//           allOrderList.clear();
//           allOrderList.addAll(allOrderTemp);
//           newOrderList.value = allOrderList
//               .where((p0) => p0.status == Constant.orderPlaced ||
//                       p0.status?.toLowerCase() == "pending")
//               .toList();
//
//           acceptedOrderList.value = allOrderList
//               .where((p0) =>
//                   p0.status == Constant.orderAccepted ||
//                   p0.status == Constant.driverAccepted ||
//                   p0.status == Constant.driverPending ||
//                   p0.status == Constant.driverRejected ||
//                   p0.status == Constant.orderShipped ||
//                   p0.status == Constant.orderInTransit)
//               .toList();
//
//           completedOrderList.value = allOrderList
//               .where((p0) => p0.status == Constant.orderCompleted)
//               .toList();
//
//           rejectedOrderList.value = allOrderList
//               .where((p0) => p0.status == Constant.orderRejected)
//               .toList();
//
//           cancelledOrderList.value = allOrderList
//               .where((p0) => p0.status == Constant.orderCancelled)
//               .toList();
//
//           if (!silent) {
//             print('✅ Filtered orders - New: ${newOrderList.length}, Accepted: ${acceptedOrderList.length}, Completed: ${completedOrderList.length}, Rejected: ${rejectedOrderList.length}, Cancelled: ${cancelledOrderList.length}');
//           }
//
//           update();
//
//           // Always enforce correct sound state based on current new order count
//           int currentNewOrderCount = newOrderList.length;
//
//           try {
//             await AudioPlayerService.initAudio();
//
//             // CRITICAL: ALWAYS stop sound if NO new orders exist (regardless of previous state)
//             if (currentNewOrderCount == 0) {
//               await AudioPlayerService.playSound(false);
//             }
//             // Stop sound if order count decreased (orders moved to Accepted/Rejected/etc)
//             // This handles cases where admin accepts orders from admin panel
//             else if (previousNewOrderCount > 0 && currentNewOrderCount < previousNewOrderCount) {
//               await AudioPlayerService.playSound(false);
//             }
//             // Play sound when new orders are detected (count increased)
//             else if (currentNewOrderCount > previousNewOrderCount) {
//               await AudioPlayerService.playSound(true);
//             }
//             // Play sound on initial load if there are new orders
//             else if (currentNewOrderCount > 0 && previousNewOrderCount == 0 && !silent) {
//               await AudioPlayerService.playSound(true);
//             }
//           } catch (e) {
//             print('⚠️ Error managing sound: $e');
//           }
//
//           // Update previous count for next comparison
//           _previousNewOrderCount = currentNewOrderCount;
//         } else {
//           if (!silent) {
//             print('⚠️ API returned success=false: ${jsonResponse['message'] ?? 'Unknown error'}');
//           }
//         }
//       } else {
//         if (!silent) {
//           print('❌ Failed to fetch orders: ${response.statusCode}');
//         }
//       }
//     } on TimeoutException catch (e) {
//       if (!silent) {
//         print('⏱️ Order fetch timeout: $e');
//       }
//     } catch (e, stackTrace) {
//       if (!silent) {
//         print('❌ Error fetching orders: $e');
//         print('Stack trace: $stackTrace');
//       }
//     } finally {
//       isFetchingOrders.value = false;
//     }
//   }
//
//
//   // Refresh method for pull-to-refresh functionality
//   Future<void> refreshApp() async {
//     isLoading.value = true;
//
//     // Fetch orders immediately without waiting for full profile reload
//     if (Constant.userModel?.vendorID != null) {
//       await getOrder(silent: false);
//     }
//
//     await getUserProfile(withOrders: false);
//
//     // Also refresh the dashboard controller's vendor data to update restaurant status
//     try {
//       DashBoardController dashBoardController = Get.find<DashBoardController>();
//       await dashBoardController.getVendor();
//     } catch (e) {
//       // If dashboard controller is not found, ignore the error
//       print('Dashboard controller not found: $e');
//     }
//
//     isLoading.value = false;
//   }
// }



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

    await getOrder();

  }
  // ── Orders ────────────────────────────────────────────────────────────────
  // Future<void> getOrder({bool silent = false}) async {
  //   if (isFetchingOrders.value && silent) return;
  //
  //   // final vendorId = Constant.userModel?.vendorID;
  //   // if (vendorId == null || vendorId.isEmpty) {
  //   //   debugPrint('⚠️ No vendor ID – skipping order fetch');
  //   //   return;
  //   // }
  //   //
  //   // final url = '${Constant.baseUrl}orders/vendor/$vendorId';
  //   // if (!silent) debugPrint('🔄 Fetching orders: $url');
  //   //
  //   // isFetchingOrders.value = true;
  //   // try {
  //   //   final response = await http
  //   //       .get(Uri.parse(url),
  //   //       headers: {'Content-Type': 'application/json'})
  //   //       .timeout(const Duration(seconds: 15),
  //   //       onTimeout: () =>
  //   //       throw TimeoutException('Order fetch timed out'));
  //   final merchantId =
  //   Preferences.getString('merchantId');
  //
  //   if (merchantId.isEmpty) {
  //     debugPrint('⚠️ No merchantId – skipping order fetch',);
  //     return;
  //   }
  //   final url = '${Constant.baseUrl}orders/merchant/$merchantId';
  //   if (!silent) {
  //     debugPrint('🔄 Fetching orders: $url', );
  //   }
  //   isFetchingOrders.value = true;
  //   try {
  //     final response = await http
  //         .get(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type':
  //         'application/json',
  //       },
  //     )
  //         .timeout(
  //       const Duration(seconds: 15),
  //       onTimeout: () => throw TimeoutException(
  //         'Order fetch timed out',),);
  //
  //
  //     if (response.statusCode != 200) {
  //       if (!silent) debugPrint('❌ HTTP ${response.statusCode}');
  //       return;
  //     }
  //
  //     final json = jsonDecode(response.body) as Map<String, dynamic>;
  //     if (json['success'] != true) {
  //       if (!silent) {
  //         debugPrint('⚠️ API error: ${json['message']}');
  //       }
  //       return;
  //     }
  //
  //     final rawList = json['data'] as List<dynamic>;
  //     final parsed = <OrderModel>[];
  //     var errors = 0;
  //
  //     for (final el in rawList) {
  //       try {
  //         final order = OrderModel.fromJson(el as Map<String, dynamic>);
  //         order.id = el['id'] as String?;
  //         parsed.add(order);
  //       } catch (e) {
  //         errors++;
  //         if (!silent) debugPrint('❌ Parse error [${el['id']}]: $e');
  //       }
  //     }
  //
  //     if (!silent) {
  //       debugPrint(
  //           '📊 Parsed ${parsed.length} ok / $errors failed');
  //     }

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

      allOrderList
        ..clear()
        ..addAll(parsed);

      newOrderList.value = parsed
          .where((o) =>
      o.status == Constant.orderPlaced ||
          o.status?.toLowerCase() == 'pending')
          .toList();

      acceptedOrderList.value = parsed
          .where((o) =>
      o.status == Constant.orderAccepted ||
          o.status == Constant.driverAccepted ||
          o.status == Constant.driverPending ||
          o.status == Constant.driverRejected ||
          o.status == Constant.orderShipped ||
          o.status == Constant.orderInTransit)
          .toList();

      completedOrderList.value =
          parsed.where((o) => o.status == Constant.orderCompleted).toList();

      rejectedOrderList.value =
          parsed.where((o) => o.status == Constant.orderRejected).toList();

      cancelledOrderList.value =
          parsed.where((o) => o.status == Constant.orderCancelled).toList();

      if (!silent) {
        debugPrint(
            '✅ New:${newOrderList.length} Accepted:${acceptedOrderList.length} '
                'Done:${completedOrderList.length} Rejected:${rejectedOrderList.length} '
                'Cancelled:${cancelledOrderList.length}');
      }

      update();
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