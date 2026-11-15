/// Exercises API error decoding through the real client without network access.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/api_client.dart';
import 'package:mobile/features/orders/repositories/order_repository.dart';

class ErrorResponseAdapter implements HttpClientAdapter {
  Object? body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(body),
    409,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  late ErrorResponseAdapter adapter;

  setUp(() {
    final dio = apiClient.dio;
    final originalAdapter = dio.httpClientAdapter;
    final originalInterceptors = List<Interceptor>.of(dio.interceptors);
    adapter = ErrorResponseAdapter();
    dio.httpClientAdapter = adapter;
    dio.interceptors.clear();
    addTearDown(() {
      dio.httpClientAdapter = originalAdapter;
      dio.interceptors
        ..clear()
        ..addAll(originalInterceptors);
    });
  });

  const conflict = 'Conflict. The resource already exists or has conflicts.';
  for (final (name, body, expected) in <(String, Object?, String)>[
    (
      'structured',
      {
        'error': {'message': 'Payment rejected by server', 'code': 'P0001'},
      },
      'Payment rejected by server',
    ),
    ('legacy', {'error': 'Legacy error'}, 'Legacy error'),
    ('top-level', {'message': 'Top-level error'}, 'Top-level error'),
    (
      'malformed nested',
      {
        'error': {
          'message': ['invalid'],
        },
        'message': 'Readable fallback',
      },
      'Readable fallback',
    ),
    (
      'blank',
      {
        'error': {'message': '  '},
      },
      conflict,
    ),
    ('numeric', {'error': 123, 'message': false}, conflict),
    ('missing', null, conflict),
    ('non-object', ['unexpected'], conflict),
  ]) {
    test('$name error preserves a readable payment failure', () async {
      adapter.body = body;
      await expectLater(
        OrderRepository().collectPayment(
          orderId: 'test-order',
          amount: 10,
          paymentMode: 'cash',
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            'Exception: Failed to collect payment: Exception: $expected',
          ),
        ),
      );
    });
  }
}
