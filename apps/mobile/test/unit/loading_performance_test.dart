/// Regression coverage for duplicate loads, cancellation, and request ordering.
library;

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/branches/viewmodels/providers/branch_provider.dart';
import 'package:mobile/features/branches/models/branch.dart';
import 'package:mobile/features/auth/viewmodels/providers/auth_provider.dart';
import 'package:mobile/features/products/repositories/product_repository.dart';
import 'package:mobile/features/products/viewmodels/providers/product_provider.dart';
import 'package:mobile/features/orders/repositories/order_repository.dart';
import 'package:mobile/features/orders/viewmodels/providers/order_provider.dart';
import 'package:mobile/features/categories/repositories/category_repository.dart';
import 'package:mobile/features/categories/viewmodels/providers/category_provider.dart';
import 'package:mobile/features/dashboard/domain/analytics_metrics.dart';
import 'package:mobile/features/dashboard/repositories/dashboard_repository.dart';
import 'package:mobile/features/dashboard/viewmodels/providers/dashboard_provider.dart';

class ProductRequest {
  final String? search;
  final CancelToken? token;
  final completer = Completer<PaginatedProducts>();
  ProductRequest(this.search, this.token);
  void complete(int total) => completer.complete(
    PaginatedProducts(products: [], total: total, page: 1, totalPages: 1),
  );
}

class ProductsFake extends ProductRepository {
  final requests = <ProductRequest>[];
  @override
  Future<PaginatedProducts> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? branchId,
    String? status,
    String? category,
    CancelToken? cancelToken,
  }) {
    final request = ProductRequest(search, cancelToken);
    requests.add(request);
    return request.completer.future;
  }
}

class OrdersFake extends OrderRepository {
  final branches = <String?>[];
  @override
  Future<PaginatedOrders> getOrders({
    int page = 1,
    int limit = 25,
    String? query,
    dynamic status,
    String? customerId,
    String? branchId,
    String? dateFilter,
    String? dateField,
    String? dateFrom,
    String? dateTo,
    dynamic excludeStatus,
    dynamic paymentStatus,
    bool? hasStockConflict,
    CancelToken? cancelToken,
  }) async {
    branches.add(branchId);
    return PaginatedOrders(
      orders: [],
      total: 0,
      page: page,
      limit: limit,
      totalPages: 1,
      hasNext: false,
      hasPrev: false,
    );
  }
}

class CountsFake extends CategoryRepository {
  int requests = 0;
  @override
  Future<Map<String, int>> getCategoryProductCounts({
    String? branchId,
    CancelToken? cancelToken,
  }) async {
    requests++;
    return {'category': 4, 'All': 5};
  }
}

class AnalyticsFake extends DashboardRepository {
  final ranges = <String>[];
  @override
  Future<AnalyticsMetrics> getAnalyticsMetrics({
    String? branchId,
    String range = 'this_week',
    String categoryPeriod = 'month',
    int roiLimit = 3,
    CancelToken? cancelToken,
  }) async {
    ranges.add(range);
    return AnalyticsMetrics.fromJson({'data': <String, dynamic>{}});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'startup waits for branch selection and explicit All remains available',
    () async {
      final repo = OrdersFake();
      final branches = Completer<List<Branch>>();
      final container = ProviderContainer(
        overrides: [
          authUserProvider.overrideWithValue(
            const AuthUser(
              id: 'user',
              email: 'user@example.test',
              name: 'User',
              role: UserRole.admin,
            ),
          ),
          branchesProvider.overrideWith((ref) => branches.future),
          orderRepositoryProvider.overrideWithValue(repo),
        ],
        retry: (count, error) => null,
      );
      addTearDown(container.dispose);
      container.listen(ordersProvider, (_, _) {});
      await container.pump();
      expect(repo.branches, isEmpty);
      branches.complete([
        Branch.fromJson({'id': 'branch', 'name': 'Branch', 'address': ''}),
      ]);
      await container.read(ordersProvider.future);
      expect(repo.branches, ['branch']);
      container.read(selectedBranchIdProvider.notifier).select(null);
      await container.read(ordersProvider.future);
      expect(repo.branches, ['branch', null]);
    },
  );
  test(
    'opening Orders reuses its request and clearing filters retains branch',
    () async {
      final repo = OrdersFake();
      final container = ProviderContainer(
        overrides: [
          resolvedBranchIdProvider.overrideWith(
            (ref) async => 'selected-branch',
          ),
          orderRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(ordersProvider.notifier);
      await notifier.clearFilters();
      await container.read(ordersProvider.future);
      await notifier.clearFilters();
      expect(repo.branches, ['selected-branch']);
      await notifier.filterByStatus('pending');
      await notifier.clearFilters();
      expect(repo.branches, everyElement('selected-branch'));
      expect(repo.branches.length, 3);
    },
  );

  test(
    'new search cancels old request and late responses cannot replace results',
    () async {
      final repo = ProductsFake();
      final container = ProviderContainer(
        overrides: [
          resolvedBranchIdProvider.overrideWith((ref) async => 'branch'),
          productRepositoryProvider.overrideWithValue(repo),
        ],
        retry: (count, error) => null,
      );
      addTearDown(container.dispose);
      final subscription = container.listen(productsProvider, (_, _) {});
      addTearDown(subscription.close);
      await Future<void>.delayed(Duration.zero);
      repo.requests.single.complete(1);
      await container.read(productsProvider.future);
      final notifier = container.read(productsProvider.notifier);
      final oldSearch = notifier.search('old');
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final old = repo.requests.last;
      final newSearch = notifier.search('new');
      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(old.token!.isCancelled, isTrue);
      repo.requests.last.complete(3);
      await newSearch;
      old.complete(2);
      await oldSearch;
      expect(container.read(productsProvider).value!.total, 3);
    },
  );

  test('rapid typing only sends the final search', () async {
    final repo = ProductsFake();
    final container = ProviderContainer(
      overrides: [
        resolvedBranchIdProvider.overrideWith((ref) async => 'branch'),
        productRepositoryProvider.overrideWithValue(repo),
      ],
      retry: (count, error) => null,
    );
    addTearDown(container.dispose);
    container.listen(productsProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    repo.requests.single.complete(1);
    await container.read(productsProvider.future);
    final notifier = container.read(productsProvider.notifier);
    final first = notifier.search('a');
    final second = notifier.search('ab');
    final third = notifier.search('abc');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    expect(repo.requests.map((r) => r.search), ['', 'abc']);
    repo.requests.last.complete(1);
    await Future.wait([first, second, third]);
  });

  test(
    'total count reuses category counts without fetching products',
    () async {
      final counts = CountsFake();
      final products = ProductsFake();
      final container = ProviderContainer(
        overrides: [
          resolvedBranchIdProvider.overrideWith((ref) async => 'branch'),
          categoryRepositoryProvider.overrideWithValue(counts),
          productRepositoryProvider.overrideWithValue(products),
        ],
      );
      addTearDown(container.dispose);
      container.listen(totalProductCountProvider, (_, _) {});
      await container.read(categoryProductCountsProvider.future);
      expect(container.read(totalProductCountProvider).value, 5);
      expect(counts.requests, 1);
      expect(products.requests, isEmpty);
    },
  );

  test(
    'analytics shares default sections and reuses a recently viewed range',
    () async {
      final repo = AnalyticsFake();
      final container = ProviderContainer(
        overrides: [
          resolvedBranchIdProvider.overrideWith((ref) async => 'branch'),
          dashboardRepositoryProvider.overrideWithValue(repo),
          effectiveBranchIdProvider.overrideWithValue('branch'),
        ],
      );
      addTearDown(container.dispose);
      container.listen(analyticsMetricsProvider, (_, _) {});
      container.listen(categoryRevenueProvider, (_, _) {});
      container.listen(inventoryRoiProvider, (_, _) {});
      await Future.wait([
        container.read(analyticsMetricsProvider.future),
        container.read(categoryRevenueProvider.future),
        container.read(inventoryRoiProvider.future),
      ]);
      expect(repo.ranges, ['this_week']);
      container
          .read(analyticsRangeProvider.notifier)
          .select(AnalyticsRange.lastMonth);
      await container.read(analyticsMetricsProvider.future);
      container
          .read(analyticsRangeProvider.notifier)
          .select(AnalyticsRange.thisWeek);
      await container.read(analyticsMetricsProvider.future);
      expect(repo.ranges, ['this_week', 'last_month']);
      await container.pump();
      container.invalidate(analyticsRequestProvider);
      container.invalidate(analyticsMetricsProvider);
      await container.pump();
      await container.read(analyticsMetricsProvider.future);
      expect(repo.ranges, ['this_week', 'last_month', 'this_week']);
    },
  );
}
