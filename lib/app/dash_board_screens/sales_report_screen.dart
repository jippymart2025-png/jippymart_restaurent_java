import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/sales_report_controller.dart';
import 'package:jippymart_restaurant/models/dashboard_model.dart';
import 'package:jippymart_restaurant/service/dashboard_api_service.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.getThem();
    final controller = Get.isRegistered<SalesReportController>()
        ? Get.find<SalesReportController>()
        : Get.put(SalesReportController());

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey900 : AppThemeData.grey100,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchReport(),
          child: Obx(() {
            if (controller.loading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.errorMessage.value.isNotEmpty) {
              return _ErrorView(
                message: controller.errorMessage.value,
                onRetry: () => controller.fetchReport(),
              );
            }
            final data = controller.dashboard.value;
            if (data == null) {
              return _ErrorView(
                message: 'No data available',
                onRetry: () => controller.fetchReport(),
              );
            }
            return _ReportContent(
              data: data,
              isDark: isDark,
              controller: controller,
            );
          }),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppThemeData.grey500),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppThemeData.regular,
                fontSize: 16,
                color: AppThemeData.grey600,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: ColorConst.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTypeButtons extends StatelessWidget {
  final SalesReportController controller;
  final bool isDark;

  const _ReportTypeButtons({
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.reportType.value;
      return Row(
        children: [
          Expanded(
            child: _ReportTypeButton(
              label: 'Coming earnings',
              subtitle: 'Pending / in progress',
              selected: selected == ReportType.comingEarnings,
              isDark: isDark,
              onTap: () => controller.setReportType(ReportType.comingEarnings),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ReportTypeButton(
              label: 'Settled earnings',
              subtitle: 'Already settled',
              selected: selected == ReportType.settledEarnings,
              isDark: isDark,
              onTap: () => controller.setReportType(ReportType.settledEarnings),
            ),
          ),
        ],
      );
    });
  }
}

class _ReportTypeButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _ReportTypeButton({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? ColorConst.orange.withOpacity(0.15)
                : (isDark ? AppThemeData.grey800 : AppThemeData.grey200),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? ColorConst.orange
                  : (isDark ? AppThemeData.grey700 : AppThemeData.grey300),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    selected ? Icons.trending_up : Icons.schedule,
                    size: 18,
                    color: selected ? ColorConst.orange : (isDark ? AppThemeData.grey400 : AppThemeData.grey600),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        fontSize: 13,
                        color: selected
                            ? ColorConst.orange
                            : (isDark ? AppThemeData.grey200 : AppThemeData.grey800),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: AppThemeData.regular,
                  fontSize: 11,
                  color: isDark ? AppThemeData.grey500 : AppThemeData.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  final DashboardModel data;
  final bool isDark;
  final SalesReportController controller;

  const _ReportContent({
    required this.data,
    required this.isDark,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 28,
                      color: isDark ? ColorConst.orange : ColorConst.orange,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sales Report',
                      style: TextStyle(
                        fontFamily: AppThemeData.bold,
                        fontSize: 24,
                        color:
                            isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Obx(
                  () => Text(
                    controller.scopeLabel.value,
                    style: TextStyle(
                      fontFamily: AppThemeData.medium,
                      fontSize: 13,
                      color: isDark ? AppThemeData.grey400 : AppThemeData.grey600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _ReportTypeButtons(controller: controller, isDark: isDark),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _FilterChips(controller: controller, isDark: isDark),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SummaryCards(
              totalOrders: data.totalOrders,
              totalEarnings: data.totalEarnings,
              lastSettlementDate: data.lastSettlementDate,
              isDark: isDark,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_view_day_rounded,
                  size: 20,
                  color: isDark ? AppThemeData.grey400 : AppThemeData.grey600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Daily breakdown',
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: 16,
                    color: isDark ? AppThemeData.grey200 : AppThemeData.grey700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        if (data.dailyChart.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: AppThemeData.grey400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No daily data for this period',
                      style: TextStyle(
                        fontFamily: AppThemeData.regular,
                        fontSize: 14,
                        color: AppThemeData.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = data.dailyChart[index];
                  return _DailyChartRow(
                    item: item,
                    maxEarnings: _maxEarnings(data.dailyChart),
                    isDark: isDark,
                  );
                },
                childCount: data.dailyChart.length,
              ),
            ),
          ),
      ],
    );
  }

  double _maxEarnings(List<DailyChartItem> list) {
    if (list.isEmpty) return 1;
    var max = 0.0;
    for (final e in list) {
      final v = (e.earnings is int)
          ? (e.earnings as int).toDouble()
          : e.earnings as double;
      if (v > max) max = v;
    }
    return max > 0 ? max : 1;
  }
}

class _FilterChips extends StatelessWidget {
  final SalesReportController controller;
  final bool isDark;

  const _FilterChips({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedFilter.value;
      return Row(
        children: [
          _Chip(
            label: 'All',
            selected: selected == DashboardFilter.none,
            isDark: isDark,
            onTap: () => controller.setFilter(DashboardFilter.none),
          ),
          const SizedBox(width: 10),
          _Chip(
            label: 'Last week',
            selected: selected == DashboardFilter.lastWeek,
            isDark: isDark,
            onTap: () => controller.setFilter(DashboardFilter.lastWeek),
          ),
          const SizedBox(width: 10),
          _Chip(
            label: 'Last month',
            selected: selected == DashboardFilter.lastMonth,
            isDark: isDark,
            onTap: () => controller.setFilter(DashboardFilter.lastMonth),
          ),
        ],
      );
    });
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? ColorConst.orange
                : (isDark ? AppThemeData.grey800 : AppThemeData.grey200),
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: ColorConst.orange.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppThemeData.semiBold,
              fontSize: 13,
              color: selected
                  ? Colors.white
                  : (isDark ? AppThemeData.grey300 : AppThemeData.grey700),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final int totalOrders;
  final num totalEarnings;
  final String? lastSettlementDate;
  final bool isDark;

  const _SummaryCards({
    required this.totalOrders,
    required this.totalEarnings,
    this.lastSettlementDate,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final earningsDouble = (totalEarnings is int)
        ? (totalEarnings as int).toDouble()
        : totalEarnings as double;
    String settlementLabel = 'Last settlement';
    if (lastSettlementDate != null && lastSettlementDate!.isNotEmpty) {
      try {
        final d = DateTime.parse(lastSettlementDate!);
        settlementLabel = 'Settled on ${DateFormat('MMM d, yyyy').format(d)}';
      } catch (_) {}
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Orders',
                value: '$totalOrders',
                subtitle: 'in this period',
                isDark: isDark,
                accent: AppThemeData.new_green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.payments_outlined,
                title: 'Earnings',
                value: Constant.amountShow(amount: earningsDouble.toString()),
                subtitle: 'total',
                isDark: isDark,
                accent: ColorConst.orange,
              ),
            ),
          ],
        ),
        if (lastSettlementDate != null && lastSettlementDate!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SettlementBanner(
            label: settlementLabel,
            isDark: isDark,
          ),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool isDark;
  final Color accent;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: accent),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontFamily: AppThemeData.medium,
              fontSize: 12,
              color: isDark ? AppThemeData.grey400 : AppThemeData.grey600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppThemeData.bold,
              fontSize: 20,
              color: accent,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              fontSize: 11,
              color: isDark ? AppThemeData.grey500 : AppThemeData.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementBanner extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SettlementBanner({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.grey800
            : AppThemeData.info50.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemeData.grey700 : AppThemeData.info200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: AppThemeData.info500,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppThemeData.medium,
                fontSize: 13,
                color: isDark ? AppThemeData.grey300 : AppThemeData.info600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyChartRow extends StatelessWidget {
  final DailyChartItem item;
  final double maxEarnings;
  final bool isDark;

  const _DailyChartRow({
    required this.item,
    required this.maxEarnings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final earnings = (item.earnings is int)
        ? (item.earnings as int).toDouble()
        : item.earnings as double;
    final barWidth =
        maxEarnings > 0 ? (earnings / maxEarnings).clamp(0.0, 1.0) : 0.0;
    String dateLabel = item.date;
    try {
      final d = DateTime.parse(item.date);
      dateLabel = DateFormat('EEE, MMM d').format(d);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                dateLabel,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  fontSize: 14,
                  color: isDark ? AppThemeData.grey200 : AppThemeData.grey800,
                ),
              ),
              Text(
                '${item.orders} orders · ${Constant.amountShow(amount: earnings.toString())}',
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 13,
                  color: isDark ? AppThemeData.grey400 : AppThemeData.grey600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barWidth,
              minHeight: 6,
              backgroundColor:
                  isDark ? AppThemeData.grey700 : AppThemeData.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(ColorConst.orange),
            ),
          ),
        ],
      ),
    );
  }
}
