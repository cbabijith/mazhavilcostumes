// Domain types for dashboard analytics metrics.
// Mirrors the admin web dashboard's analytics section data.

/// Represents a pacing metric (sales or revenue) with comparison to previous period
class PacingMetric {
  final double current;
  final double previous;
  final double percentageChange;
  final bool isPositive;

  const PacingMetric({
    required this.current,
    required this.previous,
    required this.percentageChange,
    required this.isPositive,
  });

  factory PacingMetric.fromJson(Map<String, dynamic> json) {
    return PacingMetric(
      current: (json['current'] as num?)?.toDouble() ?? 0,
      previous: (json['previous'] as num?)?.toDouble() ?? 0,
      percentageChange: (json['percentageChange'] as num?)?.toDouble() ?? 0,
      isPositive: json['isPositive'] as bool? ?? true,
    );
  }
}

/// Revenue breakdown by order status
class RevenueByStatus {
  final double completedRevenue;
  final double activeBalance;
  final double scheduledRevenue;
  final double pendingAmount;

  const RevenueByStatus({
    required this.completedRevenue,
    required this.activeBalance,
    required this.scheduledRevenue,
    required this.pendingAmount,
  });

  factory RevenueByStatus.fromJson(Map<String, dynamic> json) {
    return RevenueByStatus(
      completedRevenue: (json['completedRevenue'] as num?)?.toDouble() ?? 0,
      activeBalance: (json['activeBalance'] as num?)?.toDouble() ?? 0,
      scheduledRevenue: (json['scheduledRevenue'] as num?)?.toDouble() ?? 0,
      pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Cancellation statistics with period comparison
class CancellationStats {
  final int currentCount;
  final double percentageChange;
  final bool isPositive;

  const CancellationStats({
    required this.currentCount,
    required this.percentageChange,
    required this.isPositive,
  });

  factory CancellationStats.fromJson(Map<String, dynamic> json) {
    return CancellationStats(
      currentCount: (json['currentCount'] as num?)?.toInt() ?? 0,
      percentageChange: (json['percentageChange'] as num?)?.toDouble() ?? 0,
      isPositive: json['isPositive'] as bool? ?? true,
    );
  }
}

/// Action required summary (overdue, etc.)
class ActionRequired {
  final int overdueCount;

  const ActionRequired({required this.overdueCount});

  factory ActionRequired.fromJson(Map<String, dynamic> json) {
    return ActionRequired(
      overdueCount: (json['overdueCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A single day's revenue in the daily trends chart
class DailyRevenue {
  final String date;
  final double amount;

  const DailyRevenue({required this.date, required this.amount});

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      date: json['date'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// A single day in the booking velocity chart
class BookingVelocity {
  final String date;
  final int count;

  const BookingVelocity({required this.date, required this.count});

  factory BookingVelocity.fromJson(Map<String, dynamic> json) {
    return BookingVelocity(
      date: json['date'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Category revenue distribution
class CategoryRevenue {
  final String name;
  final double revenue;
  final int percentage;

  const CategoryRevenue({
    required this.name,
    required this.revenue,
    required this.percentage,
  });

  factory CategoryRevenue.fromJson(Map<String, dynamic> json) {
    return CategoryRevenue(
      name: json['name'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Top performing product by rental revenue
class TopPerformer {
  final String name;
  final int rentals;
  final double revenue;

  const TopPerformer({
    required this.name,
    required this.rentals,
    required this.revenue,
  });

  factory TopPerformer.fromJson(Map<String, dynamic> json) {
    return TopPerformer(
      name: json['name'] as String? ?? '',
      rentals: (json['rentals'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Product that hasn't been rented in 90+ days
class DeadStockItem {
  final String name;
  final int daysIdle;

  const DeadStockItem({required this.name, required this.daysIdle});

  factory DeadStockItem.fromJson(Map<String, dynamic> json) {
    return DeadStockItem(
      name: json['name'] as String? ?? '',
      daysIdle: (json['daysIdle'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Operational bottleneck (stuck order)
class Bottleneck {
  final String id;
  final String type;
  final String message;
  final String severity;

  const Bottleneck({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
  });

  factory Bottleneck.fromJson(Map<String, dynamic> json) {
    return Bottleneck(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      message: json['message'] as String? ?? '',
      severity: json['severity'] as String? ?? 'medium',
    );
  }
}

/// Full analytics metrics container returned by the mobile-analytics API
class AnalyticsMetrics {
  final PacingMetric salesPacing;
  final PacingMetric revenuePacing;
  final RevenueByStatus revenueByStatus;
  final CancellationStats cancellationStats;
  final ActionRequired actionRequired;
  final List<DailyRevenue> dailyRevenue;
  final double totalCash;
  final double totalUpi;
  final double totalGpay;
  final double totalBankTransfer;
  final double totalAmountCollection;
  final List<BookingVelocity> bookingVelocity;
  final List<CategoryRevenue> categoryRevenue;
  final List<TopPerformer> topPerformers;
  final List<DeadStockItem> deadStock;
  final List<Bottleneck> bottlenecks;

  const AnalyticsMetrics({
    required this.salesPacing,
    required this.revenuePacing,
    required this.revenueByStatus,
    required this.cancellationStats,
    required this.actionRequired,
    required this.dailyRevenue,
    required this.totalCash,
    required this.totalUpi,
    required this.totalGpay,
    required this.totalBankTransfer,
    required this.totalAmountCollection,
    required this.bookingVelocity,
    required this.categoryRevenue,
    required this.topPerformers,
    required this.deadStock,
    required this.bottlenecks,
  });

  factory AnalyticsMetrics.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return AnalyticsMetrics(
      salesPacing: PacingMetric.fromJson(
          data['salesPacing'] as Map<String, dynamic>? ?? {}),
      revenuePacing: PacingMetric.fromJson(
          data['revenuePacing'] as Map<String, dynamic>? ?? {}),
      revenueByStatus: RevenueByStatus.fromJson(
          data['revenueByStatus'] as Map<String, dynamic>? ?? {}),
      cancellationStats: CancellationStats.fromJson(
          data['cancellationStats'] as Map<String, dynamic>? ?? {}),
      actionRequired: ActionRequired.fromJson(
          data['actionRequired'] as Map<String, dynamic>? ?? {}),
      dailyRevenue: (data['dailyRevenue'] as List<dynamic>? ?? [])
          .map((e) => DailyRevenue.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCash: (data['total_cash'] as num?)?.toDouble() ?? 0,
      totalUpi: (data['total_upi'] as num?)?.toDouble() ?? 0,
      totalGpay: (data['total_gpay'] as num?)?.toDouble() ?? 0,
      totalBankTransfer:
          (data['total_bank_transfer'] as num?)?.toDouble() ?? 0,
      totalAmountCollection:
          (data['total_amount_collection'] as num?)?.toDouble() ?? 0,
      bookingVelocity: (data['bookingVelocity'] as List<dynamic>? ?? [])
          .map((e) => BookingVelocity.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryRevenue: (data['categoryRevenue'] as List<dynamic>? ?? [])
          .map((e) => CategoryRevenue.fromJson(e as Map<String, dynamic>))
          .toList(),
      topPerformers: (data['topPerformers'] as List<dynamic>? ?? [])
          .map((e) => TopPerformer.fromJson(e as Map<String, dynamic>))
          .toList(),
      deadStock: (data['deadStock'] as List<dynamic>? ?? [])
          .map((e) => DeadStockItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      bottlenecks: (data['bottlenecks'] as List<dynamic>? ?? [])
          .map((e) => Bottleneck.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
