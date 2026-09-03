import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/outlet_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

enum MerchantSessionState {
  initial,
  loading,
  hasOutlets,
  empty,
  error,
}

class MerchantOutletController extends GetxController {
  /// Single source of truth for outlet data.
  final RxList<OutletModel> outletList = <OutletModel>[].obs;

  final Rx<MerchantSessionState> sessionState =
      MerchantSessionState.initial.obs;

  final RxString errorMessage = ''.obs;
  final Rxn<UserModel> merchantProfile = Rxn<UserModel>();

  Future<void>? _sessionFuture;
  int? _resolvedMerchantId;

  bool get isSessionLoaded =>
      sessionState.value == MerchantSessionState.hasOutlets ||
      sessionState.value == MerchantSessionState.empty;

  bool get isLoading =>
      sessionState.value == MerchantSessionState.loading ||
      sessionState.value == MerchantSessionState.initial;

  /// Login → Profile → Outlets → UI decision (single flight, no duplicates).
  Future<void> initializeMerchantSession({bool force = false}) {
    if (Preferences.getString('loginType') == 'OUTLET') {
      debugPrint('[MerchantSession] Skipped — outlet login does not load outlet list');
      return Future.value();
    }

    if (!force && isSessionLoaded) {
      debugPrint('[MerchantSession] Skipped — session already loaded');
      return Future.value();
    }

    if (!force && _sessionFuture != null) {
      debugPrint('[MerchantSession] Reusing in-flight session future');
      return _sessionFuture!;
    }

    _sessionFuture = _runSession(force: force);
    return _sessionFuture!;
  }

  Future<void> _runSession({required bool force}) async {
    sessionState.value = MerchantSessionState.loading;
    errorMessage.value = '';
    if (force) {
      outletList.clear();
    }

    debugPrint('[MerchantSession] START — Login → Profile → Outlets');

    try {
      final merchantId = await _fetchMerchantProfileOnce();
      if (merchantId <= 0) {
        errorMessage.value = 'Merchant ID not found';
        sessionState.value = MerchantSessionState.error;
        debugPrint('[MerchantSession] Profile failed — merchantId missing');
        debugPrint('[MerchantSession] SCREEN → Error');
        return;
      }

      _resolvedMerchantId = merchantId;
      debugPrint('[MerchantSession] Profile success — merchantId=$merchantId');

      await _fetchMerchantOutlets(merchantId);
      _applyScreenDecision();
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to load merchant data';
      sessionState.value = MerchantSessionState.error;
      debugPrint('[MerchantSession] ERROR — $e\n$stackTrace');
      debugPrint('[MerchantSession] SCREEN → Error');
    }
  }

  Future<int> _fetchMerchantProfileOnce() async {
    final merchantIdStr = _resolveMerchantIdString();
    debugPrint('[MerchantSession] getMerchantProfile REQUEST — merchantId=$merchantIdStr');

    if (merchantIdStr.isEmpty) return 0;

    final profile =
        await FireStoreUtils.getMerchantProfile(merchantIdStr);

    debugPrint('[MerchantSession] getMerchantProfile RESPONSE — profile=${profile?.toJson()}');

    if (profile == null) return 0;
    // Save merchant bank details for Add Outlet screen
    await Preferences.setString(
      "merchantAccountHolder",
      profile.accountHolderName ?? "",
    );

    await Preferences.setString(
      "merchantAccountNumber",
      profile.accountNumber ?? "",
    );

    await Preferences.setString(
      "merchantIfscCode",
      profile.ifscCode ?? "",
    );

    await Preferences.setString(
      "merchantBankName",
      profile.bankName ?? "",
    );

    debugPrint("========= MERCHANT BANK DETAILS =========");
    debugPrint(
        "Holder : ${Preferences.getString("merchantAccountHolder")}");
    debugPrint(
        "Account : ${Preferences.getString("merchantAccountNumber")}");
    debugPrint(
        "IFSC : ${Preferences.getString("merchantIfscCode")}");
    debugPrint(
        "Bank : ${Preferences.getString("merchantBankName")}");
    debugPrint("=========================================");

    merchantProfile.value = profile;
    Constant.userModel = profile;

    final resolvedId = profile.merchantId?.trim().isNotEmpty == true
        ? profile.merchantId!
        : merchantIdStr;

    if (resolvedId.isNotEmpty) {
      await Preferences.setString('merchantId', resolvedId);
    }

    return int.tryParse(resolvedId) ?? 0;
  }

  Future<void> _fetchMerchantOutlets(int merchantId) async {
    debugPrint('[MerchantSession] getMerchantOutlets REQUEST — merchantId=$merchantId');

    final outlets = await FireStoreUtils.getMerchantOutlets(merchantId);

    debugPrint('[MerchantSession] getMerchantOutlets RESPONSE — count=${outlets.length}');

    outletList
      ..clear()
      ..addAll(outlets);
  }

  void _applyScreenDecision() {
    if (outletList.isNotEmpty) {
      sessionState.value = MerchantSessionState.hasOutlets;
      debugPrint('[MerchantSession] SCREEN → Outlet List (${outletList.length} outlets)');
    } else {
      sessionState.value = MerchantSessionState.empty;
      debugPrint('[MerchantSession] SCREEN → Add Your First Outlet');
    }
  }

  /// Refetch outlets only (after add outlet). Does not call getMerchantProfile again.
  Future<void> refreshOutletsOnly() async {
    final merchantId = _resolvedMerchantId ??
        int.tryParse(_resolveMerchantIdString()) ??
        0;

    if (merchantId <= 0) {
      debugPrint('[MerchantSession] refreshOutletsOnly skipped — no merchantId');
      return;
    }

    sessionState.value = MerchantSessionState.loading;
    errorMessage.value = '';

    try {
      await _fetchMerchantOutlets(merchantId);
      _applyScreenDecision();
    } catch (e) {
      errorMessage.value = 'Failed to refresh outlets';
      sessionState.value = MerchantSessionState.error;
      debugPrint('[MerchantSession] refreshOutletsOnly ERROR — $e');
    }
  }

  Future<void> retrySession() async {
    _sessionFuture = null;
    await initializeMerchantSession(force: true);
  }

  String _resolveMerchantIdString() {
    if (Preferences.getString('loginType') == 'OUTLET') {
      return Preferences.getString('merchantId').trim();
    }

    final fromPrefs = Preferences.getString('merchantId').trim();
    if (fromPrefs.isNotEmpty) return fromPrefs;

    if (Preferences.getString('loginType') == 'MERCHANT') {
      final userId = Preferences.getInt('userId');
      if (userId > 0) return userId.toString();
    }

    return merchantProfile.value?.merchantId?.trim() ??
        Constant.userModel?.merchantId?.trim() ??
        '';
  }
  Future<void> selectOutlet(OutletModel outlet) async {
    await Preferences.setInt(
      'selectedOutletId',
      outlet.outletId ?? 0,
    );

    await Preferences.setString(
      'selectedOutletName',
      outlet.outletName ?? '',
    );

    debugPrint(
      '[MerchantSession] Selected outlet '
          'id=${outlet.outletId} '
          'name=${outlet.outletName}',
    );
  }

  /// Merchant picks an outlet → activate outlet dashboard (keeps loginType MERCHANT).
  Future<bool> enterOutletDashboard(OutletModel outlet) async {
    final listOutletId = outlet.outletId ?? 0;
    if (listOutletId <= 0) {
      debugPrint('[MerchantSession] enterOutletDashboard — invalid outletId from list');
      return false;
    }

    // Persist list outlet immediately — source of truth for menu APIs
    await Preferences.setInt('outletId', listOutletId);
    await Preferences.setInt('selectedOutletId', listOutletId);
    await Preferences.setString(
      'selectedOutletName',
      outlet.outletName ?? '',
    );

    debugPrint(
      '[MerchantSession] enterOutletDashboard REQUEST — list outletId=$listOutletId',
    );
    final result = await FireStoreUtils.fetchOutletById(listOutletId);

    if (!result.isSuccess) {
      debugPrint(
        '[MerchantSession] enterOutletDashboard — fetch failed: '
        '${result.message ?? result.status}',
      );
      return false;
    }

    final resolvedOutletId = result.outletId ??
        result.outlet?.outletId ??
        listOutletId;
    if (resolvedOutletId <= 0) {
      debugPrint('[MerchantSession] enterOutletDashboard — could not resolve outletId');
      return false;
    }

    if (result.hasMerchantId) {
      await Preferences.setString('merchantId', result.merchantId.toString());
    } else if (_resolveMerchantIdString().isEmpty) {
      debugPrint('[MerchantSession] enterOutletDashboard — merchantId missing');
      return false;
    }

    await Preferences.setInt('outletId', resolvedOutletId);
   // // await Preferences.setInt('outletCategoryId'
   //    //result.outlet?.outletCategoryId ?? 0,
   //  );
    await Preferences.setInt('selectedOutletId', resolvedOutletId);
    await Preferences.setString('selectedOutletName', outlet.outletName ?? '');

    debugPrint(
      '[MerchantSession] enterOutletDashboard SUCCESS — '
      'outletId=$resolvedOutletId name=${outlet.outletName}',
    );
    return true;
  }

  /// Return merchant to outlet list (clears active outlet session only).
  Future<void> exitOutletDashboard() async {
    await Preferences.setInt('outletId', 0);
    debugPrint('[MerchantSession] exitOutletDashboard — outletId cleared');
  }

  /// Keeps outlet list UI when returning from an outlet dashboard.
  void restoreListStateIfNeeded() {
    if (outletList.isNotEmpty) {
      sessionState.value = MerchantSessionState.hasOutlets;
      debugPrint(
        '[MerchantSession] Restored outlet list state '
        '(${outletList.length} outlets)',
      );
    }
  }

}
