import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../branches/viewmodels/providers/branch_provider.dart';
import '../../repositories/dashboard_repository.dart';
import '../../domain/operational_card.dart';
import '../../domain/analytics_metrics.dart';

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

/// Analytics metrics provider — watches branchId and range
final analyticsMetricsProvider = FutureProvider<AnalyticsMetrics>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final branchId = ref.watch(effectiveBranchIdProvider);
  final range = ref.watch(analyticsRangeProvider);
  debugPrint('[DashboardProvider] Fetching analytics metrics: range=${range.apiValue}, branch=$branchId');
  try {
    return await repo.getAnalyticsMetrics(
      branchId: branchId,
      range: range.apiValue,
    );
  } catch (e) {
    debugPrint('[DashboardProvider] Analytics error: $e');
    rethrow;
  }
});
