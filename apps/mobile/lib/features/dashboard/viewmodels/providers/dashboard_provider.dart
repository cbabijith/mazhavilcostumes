import 'dart:async';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/providers/startup_cache_provider.dart';
import '../../../auth/viewmodels/providers/auth_provider.dart';
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

// Wait for branch resolution before issuing dashboard requests.
final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final token = CancelToken();
  ref.onDispose(token.cancel);
  final branchId = await ref.watch(resolvedBranchIdProvider.future);
  if (token.isCancelled) throw token.cancelError!;
  return repo.getMetrics(branchId: branchId, cancelToken: token);
});

final operationalMetricsProvider = StreamProvider<OperationalMetrics>((
  ref,
) async* {
  final scope = ref.watch(startupCacheScopeProvider);
  if (scope == null) return;
  final cache = ref.watch(startupCacheProvider);
  final repo = ref.watch(dashboardRepositoryProvider);
  final token = CancelToken();
  ref.onDispose(token.cancel);
  final branchId = await ref.watch(resolvedBranchIdProvider.future);
  if (token.isCancelled) throw token.cancelError!;
  yield* repo.watchOperationalMetrics(
    cache: cache, scope: scope, branchId: branchId, cancelToken: token,
  );
});

/// Date range options for the analytics section
enum AnalyticsRange {
  today('today', 'Today'),
  yesterday('yesterday', 'Yesterday'),
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
final analyticsRangeProvider =
    NotifierProvider<AnalyticsRangeNotifier, AnalyticsRange>(
      AnalyticsRangeNotifier.new,
    );

/// Previous period label based on selected range
final analyticsPrevLabelProvider = Provider<String>((ref) {
  final range = ref.watch(analyticsRangeProvider);
  return switch (range) {
    AnalyticsRange.today => 'Yesterday',
    AnalyticsRange.yesterday => 'Previous Day',
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
final categoryPeriodProvider =
    NotifierProvider<CategoryPeriodNotifier, CategoryPeriod>(
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

/// Value keys share both completed and in-flight analytics across sections.
typedef AnalyticsQuery = ({
  String? branchId,
  AnalyticsRange range,
  CategoryPeriod categoryPeriod,
  RoiLimit roiLimit,
});

final analyticsRequestProvider = FutureProvider.autoDispose
    .family<AnalyticsMetrics, AnalyticsQuery>((ref, query) async {
      ref.watch(
        authUserProvider,
      ); // Never reuse a previous account's cached report.
      final repo = ref.watch(dashboardRepositoryProvider);
      final token = CancelToken();
      ref.onDispose(token.cancel);
      final branchFuture = ref.read(resolvedBranchIdProvider.future);
      await Future<void>.delayed(AppDurations.searchDebounce);
      if (token.isCancelled) throw token.cancelError!;
      final branchId = await branchFuture;
      if (branchId != query.branchId) token.cancel('Branch selection changed');
      if (token.isCancelled) throw token.cancelError!;
      final result = await repo.getAnalyticsMetrics(
        branchId: branchId,
        range: query.range.apiValue,
        categoryPeriod: query.categoryPeriod.apiValue,
        roiLimit: query.roiLimit.value,
        cancelToken: token,
      );
      if (token.isCancelled) throw token.cancelError!;
      final cache = ref.keepAlive();
      final timer = Timer(AppDurations.analyticsCache, cache.close);
      ref.onDispose(timer.cancel);
      return result;
    });

Future<AnalyticsMetrics> _analytics(
  Ref ref,
  CategoryPeriod period,
  RoiLimit limit,
) {
  final range = ref.watch(analyticsRangeProvider);
  final branchId = ref.watch(effectiveBranchIdProvider);
  return ref.watch(
    analyticsRequestProvider((
      branchId: branchId,
      range: range,
      categoryPeriod: period,
      roiLimit: limit,
    )).future,
  );
}

final analyticsMetricsProvider = FutureProvider<AnalyticsMetrics>((ref) {
  return _analytics(ref, CategoryPeriod.month, RoiLimit.three);
});

final categoryRevenueProvider = FutureProvider<List<CategoryRevenue>>((
  ref,
) async {
  final period = ref.watch(categoryPeriodProvider);
  final metrics = await _analytics(ref, period, RoiLimit.three);
  return metrics.categoryRevenue;
});

final inventoryRoiProvider = FutureProvider<List<TopPerformer>>((ref) async {
  final limit = ref.watch(roiLimitProvider);
  final metrics = await _analytics(ref, CategoryPeriod.month, limit);
  return metrics.topPerformers;
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
final transactionReportProvider =
    FutureProvider.family<List<TransactionDetail>, TransactionReportParam>((
      ref,
      param,
    ) async {
      final repo = ref.read(dashboardRepositoryProvider);
      return repo.getTransactionReport(
        fromDate: param.fromDate,
        toDate: param.toDate,
        branchId: param.branchId,
      );
    });
