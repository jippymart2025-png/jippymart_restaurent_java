import 'package:get/get.dart';

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/models/dashboard_model.dart';
import 'package:jippymart_restaurant/service/dashboard_api_service.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

enum ReportType { comingEarnings, settledEarnings }

enum SalesReportScope { merchant, outlet }

class SalesReportController extends GetxController {
  final Rx<DashboardModel?> dashboard = Rx<DashboardModel?>(null);
  final RxBool loading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DashboardFilter> selectedFilter = DashboardFilter.none.obs;
  final Rx<ReportType> reportType = ReportType.comingEarnings.obs;
  final Rx<SalesReportScope> reportScope = SalesReportScope.merchant.obs;
  final RxString scopeLabel = 'Merchant sales'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReport();
  }

  void setReportType(ReportType type) {
    if (reportType.value == type) return;
    reportType.value = type;
    fetchReport();
  }

  void setFilter(DashboardFilter filter) {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
    fetchReport();
  }

  bool get usesJavaSalesApi {
    final loginType = Preferences.getString('loginType');
    return loginType == 'MERCHANT' || loginType == 'OUTLET';
  }

  /// Refreshes data for current report type and filter (merchant vs outlet aware).
  Future<void> fetchReport({bool forceRefresh = false}) async {
    _resolveScope();

    loading.value = true;
    errorMessage.value = '';
    dashboard.value = null;

    final DashboardModel? result;
      result = await _fetchReport(forceRefresh: forceRefresh);


    loading.value = false;

    if (result != null && result.success) {
      dashboard.value = result;
    } else {
      errorMessage.value = result == null
          ? 'Failed to load report. Check your connection.'
          : 'Could not load sales data.';
    }
  }

  Future<DashboardModel?> _fetchReport({required bool forceRefresh}) async {
    final merchantId = _resolveMerchantId();
    if (merchantId <= 0) {
      errorMessage.value = 'Merchant not found. Please log in again.';
      return null;
    }

    final outletId = reportScope.value == SalesReportScope.outlet
        ? _resolveActiveOutletId()
        : null;

    if (reportScope.value == SalesReportScope.outlet && (outletId ?? 0) <= 0) {
      errorMessage.value = 'No outlet selected.';
      return null;
    }

    return reportType.value == ReportType.settledEarnings
        ? DashboardApiService.getSettledEarningsReport(
            merchantId: merchantId,
            outletId: outletId,
            filter: selectedFilter.value,
            forceRefresh: forceRefresh,
          )
        : DashboardApiService.getComingEarningsReport(
            merchantId: merchantId,
            outletId: outletId,
            filter: selectedFilter.value,
            forceRefresh: forceRefresh,
          );
  }


  void _resolveScope() {
    final loginType = Preferences.getString('loginType');
    final outletId = _resolveActiveOutletId();

    if (loginType == 'OUTLET' || outletId > 0) {
      reportScope.value = SalesReportScope.outlet;
      final outletName = Preferences.getString('selectedOutletName').trim();
      scopeLabel.value = outletName.isNotEmpty
          ? 'Outlet: $outletName'
          : 'Outlet sales';
      return;
    }

    reportScope.value = SalesReportScope.merchant;
    scopeLabel.value = 'Merchant sales (all outlets)';
  }

  int _resolveMerchantId() {
    final fromPrefs = int.tryParse(Preferences.getString('merchantId').trim());
    if (fromPrefs != null && fromPrefs > 0) return fromPrefs;

    final userId = Preferences.getInt('userId');
    if (userId > 0) return userId;

    return int.tryParse(Constant.userModel?.merchantId?.trim() ?? '') ?? 0;
  }

  int _resolveActiveOutletId() {
    if (Get.isRegistered<DashBoardController>()) {
      final sessionId = Get.find<DashBoardController>().activeOutletId.value;
      if (sessionId > 0) return sessionId;
    }

    final outletId = Preferences.getInt('outletId');
    if (outletId > 0) return outletId;

    return Preferences.getInt('selectedOutletId');
  }
}
