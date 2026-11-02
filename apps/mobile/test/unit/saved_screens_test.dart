/// Offline regressions for first-frame data, scoping, refresh and pagination.
library;

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/cache/startup_snapshot_cache.dart';
import 'package:mobile/core/providers/startup_cache_provider.dart';
import 'package:mobile/features/branches/viewmodels/providers/branch_provider.dart';
import 'package:mobile/features/calendar/models/calendar_orders.dart';
import 'package:mobile/features/calendar/providers/calendar_provider.dart';
import 'package:mobile/features/calendar/repositories/calendar_repository.dart';
import 'package:mobile/features/orders/models/order.dart';
import 'package:mobile/features/orders/repositories/order_repository.dart';
import 'package:mobile/features/orders/viewmodels/providers/order_provider.dart';
import 'package:mobile/features/products/models/product.dart';
import 'package:mobile/features/products/repositories/product_repository.dart';
import 'package:mobile/features/products/viewmodels/providers/product_provider.dart';
import 'loading_performance_test.dart' as fixtures;

class DeferredOrders extends OrderRepository {
  final requests =
      <
        ({
          int page,
          String? query,
          CancelToken? token,
          Completer<PaginatedOrders> result,
        })
      >[];
  @override
  Future<PaginatedOrders> getOrders({
    int page = 1,
    int limit = 25,
    String? customerId,
    String? branchId,
    dynamic status,
    String? query,
    String? dateFilter,
    String? dateField,
    String? dateFrom,
    String? dateTo,
    dynamic excludeStatus,
    dynamic paymentStatus,
    bool? hasStockConflict,
    CancelToken? cancelToken,
  }) {
    final result = Completer<PaginatedOrders>();
    requests.add((
      page: page,
      query: query,
      token: cancelToken,
      result: result,
    ));
    return result.future;
  }
}

class DeferredCalendar extends CalendarRepository {
  final result = Completer<List<Order>>();
  @override
  Future<List<Order>> getCalendarOrders({
    required String branchId,
    required String startDate,
    required String endDate,
    CancelToken? cancelToken,
  }) => result.future;
}

Order order(String id) => Order.fromJson({
  'id': id,
  'status': 'scheduled',
  'start_date': '2026-11-02',
  'end_date': '2026-11-04',
  'item_count': 4,
  'customer': {'id': 'customer', 'name': 'Saved customer', 'phone': '000'},
  'total_amount': 250,
  'amount_paid': 100,
});

PaginatedOrders page(String id, {int number = 1}) => PaginatedOrders(
  orders: [order(id)],
  total: 30,
  page: number,
  limit: 15,
  totalPages: 2,
  hasNext: number == 1,
  hasPrev: number > 1,
  actionNeededCount: 7,
  conflictCount: 2,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StartupSnapshotCache cache;
  const scope = 'api/account/store/admin';
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    cache = StartupSnapshotCache();
  });

  test(
    'reopened Orders shows saved rows before HTTP, then paginates only fresh data',
    () async {
      await cache.save(
        resource: StartupResource.orders,
        scope: '$scope/branch/15',
        data: page('saved').toJson(),
      );
      final repo = DeferredOrders();
      final container = ProviderContainer(
        overrides: [
          startupCacheProvider.overrideWithValue(StartupSnapshotCache()),
          startupCacheScopeProvider.overrideWithValue(scope),
          resolvedBranchIdProvider.overrideWith((ref) async => 'branch'),
          orderRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      container.listen(ordersProvider, (_, _) {});
      final saved = await container.read(ordersProvider.future);
      expect(saved.savedAt, isNotNull);
      expect(saved.orders.single.itemCount, 4);
      expect(saved.orders.single.customer?.name, 'Saved customer');
      expect(saved.actionNeededCount, 7);
      await container.read(ordersProvider.notifier).loadMore();
      expect(repo.requests.length, 1);
      repo.requests.first.result.complete(page('fresh'));
      await container.pump();
      expect(container.read(ordersProvider).value!.savedAt, isNull);
      expect(container.read(ordersProvider).value!.orders.single.id, 'fresh');
      final more = container.read(ordersProvider.notifier).loadMore();
      repo.requests.last.result.complete(page('page-two', number: 2));
      await more;
      final result = container.read(ordersProvider).value!;
      expect(result.orders.map((value) => value.id), ['fresh', 'page-two']);
      expect(result.conflictCount, 2);
    },
  );

  test(
    'filtered Orders never reuses or overwrites the unfiltered snapshot',
    () async {
      await cache.save(
        resource: StartupResource.orders,
        scope: '$scope/branch/15',
        data: page('saved').toJson(),
      );
      final repo = DeferredOrders();
      final container = ProviderContainer(
        overrides: [
          startupCacheProvider.overrideWithValue(cache),
          startupCacheScopeProvider.overrideWithValue(scope),
          resolvedBranchIdProvider.overrideWith((ref) async => 'branch'),
          orderRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      container.listen(ordersProvider, (_, _) {});
      await container.read(ordersProvider.future);
      final filter = container
          .read(ordersProvider.notifier)
          .filterByStatus('scheduled');
      await container.pump();
      expect(container.read(ordersProvider).isLoading, true);
      expect(repo.requests.first.token!.isCancelled, true);
      repo.requests.first.result.complete(page('obsolete'));
      repo.requests.last.result.complete(page('filtered'));
      await filter;
      final saved = await cache.read(
        resource: StartupResource.orders,
        scope: '$scope/branch/15',
        decode: PaginatedOrders.fromJson,
      );
      expect(saved!.data.orders.single.id, 'saved');
      expect(
        container.read(ordersProvider).value!.orders.single.id,
        'filtered',
      );
    },
  );

  test(
    'Orders snapshot stays visible with an explicit refresh failure',
    () async {
      await cache.save(
        resource: StartupResource.orders,
        scope: '$scope/branch/15',
        data: page('saved').toJson(),
      );
      final repo = DeferredOrders();
      final stream = repo.watchSavedOrders(
        cache: cache,
        scope: scope,
        branchId: 'branch',
        limit: 15,
        cancelToken: CancelToken(),
      );
      final events = StreamIterator(stream);
      expect(await events.moveNext(), true);
      repo.requests.first.result.completeError(
        DioException(
          requestOptions: RequestOptions(path: '/orders'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(await events.moveNext(), true);
      expect(events.current.refreshFailed, true);
      expect(events.current.orders.single.id, 'saved');
      expect(await events.moveNext(), false);
    },
  );

  test(
    'Products snapshot preserves images and category, then replaces stock from HTTP',
    () async {
      final product = Product.fromJson({
        'id': 'product',
        'name': 'Costume',
        'category': {'name': 'Dance'},
        'available_quantity': 2,
        'images': [
          {'url': 'https://example.test/image.jpg', 'is_primary': true},
        ],
      });
      final saved = PaginatedProducts(
        products: [product],
        total: 40,
        page: 1,
        totalPages: 2,
      );
      await cache.save(
        resource: StartupResource.products,
        scope: '$scope/branch',
        data: saved.toJson(),
      );
      final repo = fixtures.ProductsFake();
      final container = ProviderContainer(
        overrides: [
          startupCacheProvider.overrideWithValue(cache),
          startupCacheScopeProvider.overrideWithValue(scope),
          resolvedBranchIdProvider.overrideWith((ref) async => 'branch'),
          productRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      container.listen(productsProvider, (_, _) {});
      final restored = await container.read(productsProvider.future);
      expect(restored.products.single.categoryName, 'Dance');
      expect(
        restored.products.single.primaryImageUrl,
        'https://example.test/image.jpg',
      );
      await container.read(productsProvider.notifier).loadMore();
      expect(repo.requests.length, 1);
      repo.requests.single.complete(0);
      await container.pump();
      expect(container.read(productsProvider).value!.savedAt, isNull);
      expect(container.read(productsProvider).value!.products, isEmpty);
    },
  );

  test(
    'Calendar shows a saved month then replaces it with the live result',
    () async {
      await cache.save(
        resource: StartupResource.calendar,
        scope: '$scope/branch/start/end',
        data: {
          'orders': [order('saved').toJson()],
        },
      );
      final repo = DeferredCalendar();
      final events = StreamIterator(
        repo.watchSavedCalendar(
          cache: cache,
          scope: scope,
          branchId: 'branch',
          startDate: 'start',
          endDate: 'end',
          cancelToken: CancelToken(),
        ),
      );
      expect(await events.moveNext(), true);
      expect(events.current.orders.single.id, 'saved');
      expect(events.current.savedAt, isNotNull);
      repo.result.complete([order('fresh')]);
      expect(await events.moveNext(), true);
      expect(events.current.orders.single.id, 'fresh');
      expect(events.current.savedAt, isNull);
      expect(await events.moveNext(), false);
    },
  );

  for (final changed in [
    'other/branch/start/end',
    '$scope/other/start/end',
    '$scope/branch/next/end',
  ]) {
    test(
      'Calendar ignores a different account, branch or range: $changed',
      () async {
        await cache.save(
          resource: StartupResource.calendar,
          scope: changed,
          data: {
            'orders': [order('wrong').toJson()],
          },
        );
        final repo = DeferredCalendar();
        repo.result.complete([order('live')]);
        final events = await repo
            .watchSavedCalendar(
              cache: cache,
              scope: scope,
              branchId: 'branch',
              startDate: 'start',
              endDate: 'end',
              cancelToken: CancelToken(),
            )
            .toList();
        expect(events.length, 1);
        expect(events.single.orders.single.id, 'live');
      },
    );
  }

  test(
    'busy calendar computes independent pickup, ongoing and return buckets without duplicates',
    () async {
      final now = DateTime.now();
      final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final orders = List.generate(
        1500,
        (i) => Order.fromJson({
          'id': '$i',
          'status': 'scheduled',
          'start_date': '$month-02',
          'end_date': '$month-04',
          'total_amount': 10,
        }),
      );
      final container = ProviderContainer(
        overrides: [
          calendarOrdersProvider.overrideWith(
            (ref) => Stream.value(CalendarOrders(orders)),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(calendarOrdersProvider, (_, _) {});
      await container.read(calendarOrdersProvider.future);
      final days = container.read(calendarDaySummaryProvider);
      expect(days['$month-01']!.orders, isEmpty);
      expect(days['$month-02']!.startingOrders.length, 1500);
      expect(days['$month-02']!.totalRevenue, 15000);
      expect(days['$month-03']!.ongoingOrders.length, 1500);
      expect(days['$month-04']!.endingOrders.length, 1500);
      expect(days['$month-05']!.orders, isEmpty);
      expect(
        container.read(calendarMonthStatsProvider).scheduledThisMonth,
        1500,
      );
    },
  );
}
