import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/models/subscription_plan_model.dart';
import 'package:jippymart_restaurant/service/subscription_api_service.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import '../../../models/location_model.dart';
import '../../../service/location_api_service.dart';
import '../../../models/vendor_model.dart';
/// GetX controller for subscription plans screen.
/// Resolves zone from restaurant (vendor) details, then preferences.
class SubscriptionPlansController extends GetxController {
  //final RxList<SubscriptionPlanModel> plans = <SubscriptionPlanModel>[].obs;
  //final RxBool isLoading = true.obs;
  //final RxString errorMessage = ''.obs;
  final RxList<StateModel> states = <StateModel>[].obs;
  final RxList<CityModel> cities = <CityModel>[].obs;
  final RxList<AreaModel> areas = <AreaModel>[].obs;

  final Rxn<StateModel> selectedState = Rxn<StateModel>();
  final Rxn<CityModel> selectedCity = Rxn<CityModel>();
  final Rxn<AreaModel> selectedArea = Rxn<AreaModel>();

  final RxList<SubscriptionPlanModel> plans =
      <SubscriptionPlanModel>[].obs;

  /// Dropdown selected value
  final Rxn<SubscriptionPlanModel> selectedPlan =
  Rxn<SubscriptionPlanModel>();

  /// Details returned from
  /// GET /subscription-plans/{id}
  final Rxn<SubscriptionPlanModel> selectedPlanDetails =
  Rxn<SubscriptionPlanModel>();

  /// General loading
  final RxBool isLoading = false.obs;

  /// Loading subscription plans list
  final RxBool isPlansLoading = false.obs;

  /// Loading only while fetching plan details
  final RxBool isPlanDetailsLoading = false.obs;

  final RxString errorMessage = ''.obs;
  @override
  void onReady() {
    loadStates();
    super.onReady();
  }


  Future<void> loadStates() async {
    try {
      isLoading.value = true;

      final result = await LocationApiService.fetchStates();

      states.clear();
      states.assignAll(result);

      // Reset dependent selections
      selectedState.value = null;
      selectedCity.value = null;
      selectedArea.value = null;

      cities.clear();
      areas.clear();
      plans.clear();
      selectedPlan.value = null;
      selectedPlanDetails.value = null;

    } catch (e) {
      debugPrint('loadStates error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCities(int stateId) async {
    try {
      isLoading.value = true;

      // Reset dependent selections
      selectedCity.value = null;
      selectedArea.value = null;

      cities.clear();
      areas.clear();
      plans.clear();
      selectedPlan.value = null;
      selectedPlanDetails.value = null;

      final result = await LocationApiService.fetchCities(stateId);

      cities.assignAll(result);
    } catch (e) {
      debugPrint('loadCities error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> loadAreas(int cityId) async {
    try {
      isLoading.value = true;

      selectedArea.value = null;

      areas.clear();
      plans.clear();
      selectedPlan.value = null;
      selectedPlanDetails.value = null;

      final result = await LocationApiService.fetchAreas(cityId);

      areas.assignAll(result);
    } catch (e) {
      debugPrint('loadAreas error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> loadPlans(int areaId) async {
    if (areaId <= 0) {
      plans.clear();
      selectedPlan.value = null;
      selectedPlanDetails.value = null;
      return;
    }

    isPlansLoading.value = true;
    errorMessage.value = '';
    plans.clear();
    selectedPlan.value = null;
    selectedPlanDetails.value = null;

    try {
      final result =
          await SubscriptionApiService.getSubscriptionPlansByArea(areaId);
      plans.assignAll(result);
      if (result.isEmpty) {
        errorMessage.value = 'No subscription plans found for this area.';
      }
    } catch (e) {
      debugPrint('loadPlans error: $e');
      errorMessage.value = 'Unable to load plans. Please try again.';
    } finally {
      isPlansLoading.value = false;
    }
  }
  Future<void> loadPlanDetails(
      int planId,
      ) async {
    final plan =
    await SubscriptionApiService
        .getPlanDetails(planId);

    if (plan != null) {
      selectedPlan.value = plan;
    }
  }
  Future<void> selectPlan(SubscriptionPlanModel plan) async {
    selectedPlan.value = plan;
    selectedPlanDetails.value = plan;
    isPlanDetailsLoading.value = true;

    try {
      final response = await SubscriptionApiService.getPlanDetails(
        plan.subscriptionPlanId,
      );

      if (response != null) {
        selectedPlanDetails.value = response;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isPlanDetailsLoading.value = false;
    }
  }
  bool get hasError => errorMessage.value.isNotEmpty;
  bool get hasPlans => plans.isNotEmpty;

  /// Clears slot-booking dropdown selections when user leaves or re-enters.
  void resetSlotBookingSelections() {
    selectedState.value = null;
    selectedCity.value = null;
    selectedArea.value = null;
    selectedPlan.value = null;
    selectedPlanDetails.value = null;
    cities.clear();
    areas.clear();
    plans.clear();
    errorMessage.value = '';
    isPlansLoading.value = false;
    isPlanDetailsLoading.value = false;
  }
}
