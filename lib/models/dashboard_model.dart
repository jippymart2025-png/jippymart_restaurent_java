/// Response model for GET /api/vendor/dashboard?vendor_id=...&filter=...
class DashboardModel {
  final bool success;
  final String? vendorId;
  final String? lastSettlementDate;
  final int totalOrders;
  final num totalEarnings;
  final List<DailyChartItem> dailyChart;

  DashboardModel({
    required this.success,
    this.vendorId,
    this.lastSettlementDate,
    this.totalOrders = 0,
    this.totalEarnings = 0,
    this.dailyChart = const [],
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final dailyList = json['daily_chart'] as List<dynamic>? ?? [];
    return DashboardModel(
      success: json['success'] == true,
      vendorId: json['vendor_id']?.toString(),
      lastSettlementDate: json['last_settlement_date']?.toString(),
      totalOrders: (json['total_orders'] is int)
          ? json['total_orders'] as int
          : int.tryParse(json['total_orders']?.toString() ?? '0') ?? 0,
      totalEarnings: (json['total_earnings'] is num)
          ? (json['total_earnings'] as num).toDouble()
          : double.tryParse(json['total_earnings']?.toString() ?? '0') ?? 0,
      dailyChart: dailyList
          .map((e) => DailyChartItem.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  /// Java API: GET /api/co/sales-report
  factory DashboardModel.fromJavaSalesReportJson(Map<String, dynamic> json) {
    final dailyList = json['dailyBreakdown'] as List<dynamic>? ?? [];
    return DashboardModel(
      success: true,
      totalOrders: _parseInt(json['totalOrders']),
      totalEarnings: _parseNum(json['totalEarnings']),
      dailyChart: dailyList
          .map(
            (e) => DailyChartItem.fromJavaJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }

  /// Java API: GET /api/div
  /// Response is a LIST of weekly settlement objects.
  ///
  /// We adapt it to the Sales Report UI by:
  /// - totalOrders: sum of ordersCount
  /// - totalEarnings: sum of netSettlementAmount
  /// - dailyChart: one row per week (using weekStartDate as the "date")
  /// - lastSettlementDate: most recent weekEndDate (if present)
  factory DashboardModel.fromJavaSettlementListJson(List<dynamic> list) {
    int totalOrders = 0;
    num totalEarnings = 0;
    String? lastEndDate;

    final items = <DailyChartItem>[];
    for (final raw in list) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw as Map);

      final weekStart = m['weekStartDate']?.toString() ?? '';
      final weekEnd = m['weekEndDate']?.toString() ?? '';
      final orders = _parseInt(m['ordersCount']);
      final net = _parseNum(m['netSettlementAmount']);

      totalOrders += orders;
      totalEarnings += net;
      if (weekEnd.isNotEmpty) {
        if (lastEndDate == null) {
          lastEndDate = weekEnd;
        } else {
          // Keep the latest end date when parseable.
          try {
            final a = DateTime.parse(lastEndDate);
            final b = DateTime.parse(weekEnd);
            if (b.isAfter(a)) lastEndDate = weekEnd;
          } catch (_) {
            // If parsing fails, keep existing.
          }
        }
      }

      items.add(
        DailyChartItem(
          date: weekStart,
          orders: orders,
          earnings: net,
        ),
      );
    }

    return DashboardModel(
      success: true,
      lastSettlementDate: lastEndDate,
      totalOrders: totalOrders,
      totalEarnings: totalEarnings,
      dailyChart: items,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  static num _parseNum(dynamic value) {
    if (value is num) return value;
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }
}

class DailyChartItem {
  final String date;
  final int orders;
  final num earnings;

  DailyChartItem({
    required this.date,
    this.orders = 0,
    this.earnings = 0,
  });

  factory DailyChartItem.fromJson(Map<String, dynamic> json) {
    return DailyChartItem(
      date: json['date']?.toString() ?? '',
      orders: (json['orders'] is int)
          ? json['orders'] as int
          : int.tryParse(json['orders']?.toString() ?? '0') ?? 0,
      earnings: (json['earnings'] is num)
          ? (json['earnings'] as num).toDouble()
          : double.tryParse(json['earnings']?.toString() ?? '0') ?? 0,
    );
  }

  factory DailyChartItem.fromJavaJson(Map<String, dynamic> json) {
    return DailyChartItem(
      date: json['salesDate']?.toString() ?? '',
      orders: DashboardModel._parseInt(json['totalOrders']),
      earnings: DashboardModel._parseNum(json['totalEarnings']),
    );
  }
}
