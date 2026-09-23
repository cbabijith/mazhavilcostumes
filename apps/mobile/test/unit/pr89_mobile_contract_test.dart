/// Offline settings API and return/dashboard cache regressions for PR #89.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/api_client.dart';
import 'package:mobile/features/branches/viewmodels/providers/branch_provider.dart';
import 'package:mobile/features/dashboard/domain/operational_card.dart';
import 'package:mobile/features/dashboard/viewmodels/providers/dashboard_provider.dart';
import 'package:mobile/features/orders/models/order.dart';
import 'package:mobile/features/orders/repositories/order_repository.dart';
import 'package:mobile/features/orders/viewmodels/providers/order_provider.dart';
import 'package:mobile/features/settings/repositories/settings_repository.dart';

import '../support/order_return_fixtures.dart';

class SettingsAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  Object response = {
    'success': true,
    'data': {'value': ''},
  };

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class SettledOrderRepository extends OrderRepository {
  bool fail = false;
  final requestedStatuses = <Object?>[];

  @override
  Future<PaginatedOrders> getOrders({
    int page = 1,
    int limit = 25,
    String? customerId,
    String? branchId,
    Object? status,
    String? query,
    String? dateFilter,
    String? dateField,
    String? dateFrom,
    String? dateTo,
    Object? excludeStatus,
    Object? paymentStatus,
    bool? hasStockConflict,
    CancelToken? cancelToken,
  }) async {
    requestedStatuses.add(status);
    return PaginatedOrders(
      orders: [],
      total: 0,
      page: page,
      limit: limit,
      totalPages: 0,
      hasNext: false,
      hasPrev: false,
    );
  }

  @override
  Future<Order> processReturn({
    required String orderId,
    required List<Map<String, dynamic>> items,
    String? notes,
    double? lateFee,
    double? discount,
    CancelToken? cancelToken,
  }) async {
    if (fail) throw StateError('Return failed');
    return Order.fromJson({
      ...returnOrder(status: 'completed', total: 100, paid: 100).toJson(),
      'payment_status': 'paid',
    });
  }

  @override
  Future<Map<String, dynamic>> collectPayment({
    required String orderId,
    required double amount,
    required String paymentMode,
    String? paymentType,
    String? notes,
    CancelToken? cancelToken,
  }) async => {'success': true};
}

void main() {
  test(
    'GSTIN uses the shared settings API and preserves empty values',
    () async {
      final dio = apiClient.dio;
      final originalAdapter = dio.httpClientAdapter;
      final originalInterceptors = List<Interceptor>.of(dio.interceptors);
      final adapter = SettingsAdapter();
      dio.httpClientAdapter = adapter;
      dio.interceptors.clear();
      addTearDown(() {
        dio.httpClientAdapter = originalAdapter;
        dio.interceptors.addAll(originalInterceptors);
      });
      final repository = SettingsRepository();
      expect(await repository.getGstNumber(), '');
      expect(adapter.requests.last.path, '/settings');
      expect(adapter.requests.last.queryParameters, {'key': 'gst_number'});
      expect(await repository.saveGstNumber(''), '');
      expect(adapter.requests.last.method, 'PATCH');
      expect(adapter.requests.last.data, {'key': 'gst_number', 'value': ''});
      adapter.response = {'success': false, 'error': 'Unavailable'};
      await expectLater(repository.getGstNumber(), throwsFormatException);
      adapter.response = {
        'success': true,
        'data': {'value': null},
      };
      await expectLater(repository.getGstNumber(), throwsFormatException);
    },
  );

  test(
    'settled returns and payments refresh cards; failed returns do not',
    () async {
      final repository = SettledOrderRepository();
      var reads = 0;
      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(repository),
          effectiveBranchIdProvider.overrideWithValue(null),
          operationalMetricsProvider.overrideWith((ref) async {
            reads++;
            return OperationalMetrics(cards: []);
          }),
        ],
      );
      addTearDown(container.dispose);
      container.listen(ordersProvider, (_, _) {});
      await container.read(ordersProvider.future);
      await container
          .read(ordersProvider.notifier)
          .setFilters(status: 'revenue_due');
      container.listen(operationalMetricsProvider, (_, _) {});
      await container.read(operationalMetricsProvider.future);
      expect(reads, 1);
      final operations = container.read(orderOperationsProvider);
      final settled = await operations.processReturn(
        orderId: 'test-order',
        items: [],
      );
      expect(settled.status, OrderStatus.completed);
      expect(settled.paymentStatus, PaymentStatus.paid);
      await container.read(ordersProvider.future);
      expect(repository.requestedStatuses.last, 'revenue_due');
      await container.read(operationalMetricsProvider.future);
      expect(reads, 2);
      await operations.collectPayment(
        orderId: 'test-order',
        amount: 10,
        paymentMode: 'cash',
      );
      await container.read(operationalMetricsProvider.future);
      expect(reads, 3);
      repository.fail = true;
      await expectLater(
        operations.processReturn(orderId: 'test-order', items: []),
        throwsStateError,
      );
      await container.read(operationalMetricsProvider.future);
      expect(reads, 3);
    },
  );
}
