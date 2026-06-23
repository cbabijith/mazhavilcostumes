import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../branches/viewmodels/providers/branch_provider.dart';
import '../../repositories/dashboard_repository.dart';
import '../../domain/operational_card.dart';
import '../../domain/analytics_metrics.dart';
import '../../domain/transaction_detail.dart';

// Repository provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

// Dashboard metrics provider
final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final branchId = ref.watch(effectiveBranchIdProvider);
  return repo.getMetrics(branchId: branchId);
});

// Operational metrics provider
final operationalMetricsProvider = FutureProvider<OperationalMetrics>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final branchId = ref.watch(effectiveBranchIdProvider);
  debugPrint('[DashboardProvider] Fetching operational metrics with branchId: $branchId');
  try {
    return await repo.getOperationalMetrics(branchId: branchId);
  } catch (e) {
    debugPrint('[DashboardProvider] Error: $e');
    rethrow;
  }
});

/// Date range options for the analytics section
enum AnalyticsRange {
  today('today', 'Today'),
  thisWeek('this_week', 'This Week'),
  lastWeek('last_week', 'Last Week'),
  thisMonth('this_month', 'This Month'),
  lastMonth('last_month', 'Last Month');

  final String apiValue;
  final String label;
  const AnalyticsRange(this.apiValue, this.label);
}

/// Notifier for the selected analytics date range
class AnalyticsRangeNotifier extends Notifier<AnalyticsRange> {
  @override
  AnalyticsRange build() => AnalyticsRange.thisWeek;

  void select(AnalyticsRange range) {
    state = range;
  }
}

/// State provider for the selected analytics date range
final analyticsRangeProvider = NotifierProvider<AnalyticsRangeNotifier, AnalyticsRange>(
  AnalyticsRangeNotifier.new,
);

/// Previous period label based on selected range
final analyticsPrevLabelProvider = Provider<String>((ref) {
  final range = ref.watch(analyticsRangeProvider);
  return switch (range) {
    AnalyticsRange.today => 'Yesterday',
    AnalyticsRange.thisWeek => 'Last Week',
    AnalyticsRange.lastWeek => 'Previous Week',
    AnalyticsRange.thisMonth => 'Last Month',
    AnalyticsRange.lastMonth => 'Previous Month',
  };
});

/// Category period options for the category revenue section
enum CategoryPeriod {
  month('month', 'This Period'),
  year('year', 'Last 12m'),
  all('all', 'All Time');

  final String apiValue;
  final String label;
  const CategoryPeriod(this.apiValue, this.label);
}

/// Notifier for the selected category period
class CategoryPeriodNotifier extends Notifier<CategoryPeriod> {
  @override
  CategoryPeriod build() => CategoryPeriod.month;

  void select(CategoryPeriod period) {
    state = period;
  }
}

/// State provider for the selected category period
final categoryPeriodProvider = NotifierProvider<CategoryPeriodNotifier, CategoryPeriod>(
  CategoryPeriodNotifier.new,
);

/// ROI limit options for the inventory ROI section
enum RoiLimit {
  three(3, 'Top 3'),
  five(5, 'Top 5'),
  ten(10, 'Top 10');

  final int value;
  final String label;
  const RoiLimit(this.value, this.label);
}

/// Notifier for the selected ROI limit
class RoiLimitNotifier extends Notifier<RoiLimit> {
  @override
  RoiLimit build() => RoiLimit.three;

  void select(RoiLimit limit) {
    state = limit;
  }
}

/// State provider for the selected ROI limit
final roiLimitProvider = NotifierProvider<RoiLimitNotifier, RoiLimit>(
  RoiLimitNotifier.new,
);

/// Analytics metrics provider — watches branchId and range (default parameters)
final analyticsMetricsProvider = FutureProvider<AnalyticsMetrics>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final branchId = ref.watch(effectiveBranchIdProvider);
  final range = ref.watch(analyticsRangeProvider);
  debugPrint('[DashboardProvider] Fetching base analytics metrics: range=${range.apiValue}, branch=$branchId, roiLimit=${RoiLimit.three.value}');
  try {
    final metrics = await repo.getAnalyticsMetrics(
      branchId: branchId,
      range: range.apiValue,
      categoryPeriod: CategoryPeriod.month.apiValue,
      roiLimit: RoiLimit.three.value,
    );
    debugPrint('[DashboardProvider] Base analytics metrics loaded. Top performers count: ${metrics.topPerformers.length}');
    return metrics;
  } catch (e) {
    debugPrint('[DashboardProvider] Analytics error: $e');
    rethrow;
  }
});

/// Category Revenue provider — watches branchId, range, and categoryPeriod
final categoryRevenueProvider = FutureProvider<List<CategoryRevenue>>((ref) async {
  final catPeriod = ref.watch(categoryPeriodProvider);

  // If using default 'month', reuse the already loaded base metrics to avoid duplicate requests
  if (catPeriod == CategoryPeriod.month) {
    final baseMetrics = await ref.watch(analyticsMetricsProvider.future);
    return baseMetrics.categoryRevenue;
  }

  final repo = ref.read(dashboardRepositoryProvider);
  final branchId = ref.watch(effectiveBranchIdProvider);
  final range = ref.watch(analyticsRangeProvider);

  debugPrint('[DashboardProvider] Fetching category revenue: range=${range.apiValue}, branch=$branchId, period=${catPeriod.apiValue}');
  try {
    final metrics = await repo.getAnalyticsMetrics(
      branchId: branchId,
      range: range.apiValue,
      categoryPeriod: catPeriod.apiValue,
      roiLimit: RoiLimit.three.value,
    );
    return metrics.categoryRevenue;
  } catch (e) {
    debugPrint('[DashboardProvider] Category revenue error: $e');
    rethrow;
  }
});

/// Inventory ROI provider — watches branchId, range, and roiLimit
final inventoryRoiProvider = FutureProvider<List<TopPerformer>>((ref) async {
  final roiLimit = ref.watch(roiLimitProvider);
  debugPrint('[DashboardProvider] inventoryRoiProvider invoked. Selected roiLimit: ${roiLimit.name} (${roiLimit.value})');

  // If using default 'three', reuse the already loaded base metrics to avoid duplicate requests
  if (roiLimit == RoiLimit.three) {
    debugPrint('[DashboardProvider] roiLimit is Top 3. Reusing base metrics topPerformers.');
    final baseMetrics = await ref.watch(analyticsMetricsProvider.future);
    debugPrint('[DashboardProvider] Reused base metrics. topPerformers count: ${baseMetrics.topPerformers.length}');
    return baseMetrics.topPerformers;
  }

  final repo = ref.read(dashboardRepositoryProvider);
  final branchId = ref.watch(effectiveBranchIdProvider);
  final range = ref.watch(analyticsRangeProvider);

  debugPrint('[DashboardProvider] Fetching inventory ROI: range=${range.apiValue}, branch=$branchId, limit=${roiLimit.value}');
  try {
    final metrics = await repo.getAnalyticsMetrics(
      branchId: branchId,
      range: range.apiValue,
      categoryPeriod: CategoryPeriod.month.apiValue,
      roiLimit: roiLimit.value,
    );
    debugPrint('[DashboardProvider] inventoryRoiProvider loaded from API. topPerformers count: ${metrics.topPerformers.length}');
    return metrics.topPerformers;
  } catch (e) {
    debugPrint('[DashboardProvider] Inventory ROI error: $e');
    rethrow;
  }
});

/// Unique parameters for transaction details report provider
class TransactionReportParam {
  final String fromDate;
  final String toDate;
  final String? branchId;

  const TransactionReportParam({
    required this.fromDate,
    required this.toDate,
    this.branchId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionReportParam &&
          runtimeType == other.runtimeType &&
          fromDate == other.fromDate &&
          toDate == other.toDate &&
          branchId == other.branchId;

  @override
  int get hashCode => fromDate.hashCode ^ toDate.hashCode ^ branchId.hashCode;
}

/// Fetches transaction detail records from the repository
final transactionReportProvider = FutureProvider.family<List<TransactionDetail>, TransactionReportParam>((ref, param) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getTransactionReport(
    fromDate: param.fromDate,
    toDate: param.toDate,
    branchId: param.branchId,
  );
});
