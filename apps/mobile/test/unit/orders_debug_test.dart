import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mobile/features/orders/repositories/order_repository.dart';
import 'package:mobile/core/supabase/api_client.dart';

void main() {
  test('Inspect order repository query parameters', () async {
    apiClient.dio.interceptors.clear(); // Clear existing interceptors for test
    apiClient.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("\n=== REQUEST URL ===");
        print("${options.method} ${options.baseUrl}${options.path}");
        print("=== QUERY PARAMETERS ===");
        print(options.queryParameters);
        print("=== SERIALIZED URI ===");
        print(options.uri.toString());
        print("=====================\n");
        // Reject request to halt execution and print values
        return handler.reject(DioException(
          requestOptions: options,
          message: "Intercepted for debugging",
        ));
      },
    ));

    final repository = OrderRepository();
    try {
      await repository.getOrders(
        status: 'ongoing',
        dateFilter: 'custom',
        dateField: 'end_date',
        dateTo: '2026-06-21',
      );
    } catch (e) {
      // Expected exception from interception
    }
  });
}
