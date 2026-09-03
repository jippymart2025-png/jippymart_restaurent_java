import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import '../models/promotion_models.dart';
import '../utils/fire_store_utils.dart';
import 'dash_board_controller.dart';

class PromotionPlansController extends GetxController {
  final RxList<PromotionPlanModel> plansList = <PromotionPlanModel>[].obs;
  final RxList<PromotionPlanTypeModel> planTypes = <PromotionPlanTypeModel>[].obs;
  final Rx<PromotionCountsModel> counts = PromotionCountsModel().obs;

  final RxBool isLoading = false.obs;
  final RxString selectedTab = 'ACTIVE'.obs;
  int? _lastFetchedOutletId;

  // Reactive variables for filtering
  final RxnInt selectedPlanTypeId = RxnInt();
  final RxString selectedStatusTab = 'ACTIVE'.obs; // Default selected tab set to ACTIVE
  final RxList<PromotionPlanModel> filteredPlansList = <PromotionPlanModel>[].obs;

  /// Dynamic outlet ID getter resolved across sessions
  int get outletId {
    if (Get.isRegistered<DashBoardController>()) {
      final dash = Get.find<DashBoardController>();
      if (dash.activeOutletId.value > 0) {
        return dash.activeOutletId.value;
      }
    }

    final directOutletId = Preferences.getInt('outletId');
    if (directOutletId > 0) return directOutletId;

    final selectedOutletId = Preferences.getInt('selectedOutletId');
    if (selectedOutletId > 0) return selectedOutletId;

    return 263; // Fallback default if not yet initialized
  }

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    final id = outletId;
    if (id <= 0) return;

    _lastFetchedOutletId = id;
    isLoading.value = true;

    // Clear old outlet's data immediately so a stale list never shows
    // while the new outlet's data is loading.
    plansList.clear();
    filteredPlansList.clear();
    counts.value = PromotionCountsModel();

    try {
      await Future.wait([
        _fetchCountsInternal(),
        _fetchPlanTypesInternal(),
        _fetchPlansByStatusInternal(selectedStatusTab.value.isNotEmpty ? selectedStatusTab.value : 'ACTIVE'),
      ]);
    } catch (e) {
      debugPrint('fetchInitialData error: $e');
    } finally {
      // Guaranteed to run even if any of the above throws — this is what
      // stops the spinner from getting stuck forever on an empty/erroring outlet.
      isLoading.value = false;
    }
  }

  Future<void> fetchPlansByStatus(String status) async {
    selectedTab.value = status;
    selectedStatusTab.value = status;
    selectedPlanTypeId.value = null; // Reset type filter when status changes

    isLoading.value = true;
    try {
      // Always refresh counts alongside the plan list so the two can
      // never drift out of sync with each other or with the active outlet.
      await Future.wait([
        _fetchPlansByStatusInternal(status),
        _fetchCountsInternal(),
      ]);
    } catch (e) {
      debugPrint('fetchPlansByStatus error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Internal fetch used by both fetchInitialData (via Future.wait) and
  // fetchPlansByStatus (standalone) — does not touch isLoading itself,
  // so the caller controls loading state and Future.wait can't race it.
  Future<void> _fetchPlansByStatusInternal(String status) async {
    final result = await FireStoreUtils.getPromotionPlansByOutlet(
      outletId: outletId,
      status: status,
    );

    plansList.assignAll(result);
    filteredPlansList.assignAll(result);
  }

  Future<void> fetchCounts() async {
    try {
      await _fetchCountsInternal();
    } catch (e) {
      debugPrint('fetchCounts error: $e');
    }
  }

  Future<void> _fetchCountsInternal() async {
    final result = await FireStoreUtils.getPromotionCounts(outletId);
    counts.value = result;
  }

  Future<void> fetchPlanTypes() async {
    try {
      await _fetchPlanTypesInternal();
    } catch (e) {
      debugPrint('fetchPlanTypes error: $e');
    }
  }

  Future<void> _fetchPlanTypesInternal() async {
    final result = await FireStoreUtils.getPromotionPlanTypes();
    planTypes.assignAll(result);
  }

  /// Call this every time the promotion plans screen is opened.
  /// If the active outlet has changed since the last fetch, refetches
  /// fresh data for the new outlet instead of showing cached data.
  Future<void> refreshIfOutletChanged() async {
    final currentOutletId = outletId;
    if (currentOutletId != _lastFetchedOutletId) {
      await fetchInitialData();
    }
  }

  void filterPlansByType(int? typeId) {
    selectedPlanTypeId.value = typeId;
    selectedStatusTab.value = ''; // Reset status filter
    if (typeId == null) {
      filteredPlansList.assignAll(plansList);
    } else {
      filteredPlansList.assignAll(
        plansList.where((p) => p.promotionPlanTypeId == typeId).toList(),
      );
    }
  }

  void clearStatusFilter() {
    selectedStatusTab.value = '';

    if (selectedPlanTypeId.value != null) {
      filteredPlansList.assignAll(
        plansList.where((p) => p.promotionPlanTypeId == selectedPlanTypeId.value).toList(),
      );
    } else {
      filteredPlansList.assignAll(plansList);
    }
  }

  // FIXED: Now calls API fetch instead of filtering locally from cached data
  Future<void> filterPlansByStatus(String statusKey) async {
    selectedStatusTab.value = statusKey;
    selectedPlanTypeId.value = null; // Reset type filter
    await fetchPlansByStatus(statusKey);
  }

  int getTabCount(String tab) {
    switch (tab) {
      case 'ALL':
        return counts.value.total;
      case 'ACTIVE':
        return counts.value.active;
      case 'SCHEDULED':
        return counts.value.scheduled;
      case 'ENDED':
        return counts.value.ended;
      default:
        return 0;
    }
  }
  Future<PromotionApiResult> createPromotionPlan(PromotionPlanModel newPlan) async {
    ShowToastDialog.showLoader('Creating plan...');
    final result = await FireStoreUtils.createPromotionPlan(newPlan);
    ShowToastDialog.closeLoader();

    if (result.success) {
      await fetchInitialData();
    }
    return result;
  }

  Future<PromotionPlanModel?> fetchPlanDetails(int promotionPlanId) async {
    return await FireStoreUtils.getPromotionPlanDetails(promotionPlanId);
  }
  Future<PromotionApiResult> updatePromotionPlan(int promotionPlanId, PromotionPlanModel updatedPlan) async {
    ShowToastDialog.showLoader('Updating plan...');
    final result = await FireStoreUtils.updatePromotionPlan(promotionPlanId, updatedPlan);
    ShowToastDialog.closeLoader();

    if (result.success) {
      await fetchInitialData();
    }
    return result;
  }


  Future<void> deletePromotionPlan(int id) async {
    ShowToastDialog.showLoader('Deleting plan...');
    final success = await FireStoreUtils.deletePromotionPlan(id);
    ShowToastDialog.closeLoader();

    if (success) {
      plansList.removeWhere((p) => p.promotionPlanId == id);
      await fetchCounts();
      ShowToastDialog.showToast('Plan deleted successfully');
    } else {
      ShowToastDialog.showToast('Failed to delete promotion plan');
    }
  }
}