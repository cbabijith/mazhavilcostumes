/// Verifies the return API contract with a transport that cannot access a network.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/api_client.dart';
import 'package:mobile/features/orders/repositories/order_repository.dart';

import '../support/order_return_fixtures.dart';

class ReturnRequestAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({'data': returnOrder(status: 'returned').toJson()}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'mobile uses the existing API late_fee field and return discount',
    () async {
      final dio = apiClient.dio;
      final oldAdapter = dio.httpClientAdapter;
      final oldInterceptors = List<Interceptor>.of(dio.interceptors);
      final adapter = ReturnRequestAdapter();
      dio.httpClientAdapter = adapter;
      dio.interceptors.clear();
      addTearDown(() {
        dio.httpClientAdapter = oldAdapter;
        dio.interceptors.addAll(oldInterceptors);
      });

      await OrderRepository().processReturn(
        orderId: 'test-order',
        items: [
          {'item_id': 'test-item', 'condition_rating': 'excellent'},
        ],
        lateFee: 70,
        discount: 70,
        notes: 'Checked at counter',
      );

      expect(adapter.request!.method, 'PATCH');
      expect(adapter.request!.path, '/orders/test-order/return');
      final body = adapter.request!.data as Map<String, dynamic>;
      expect(body['late_fee'], 70);
      expect(body.containsKey('additional_late_fee'), isFalse);
      expect(body['discount'], 70);
      expect(body['notes'], 'Checked at counter');
    },
  );
}
