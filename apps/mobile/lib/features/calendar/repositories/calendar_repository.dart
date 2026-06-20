import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/supabase/api_client.dart';
import '../../orders/models/order.dart';

/// Repository for calling next.js calendar API endpoints.
class CalendarRepository {
  final _api = apiClient;

  /// Fetch active orders that overlap with the range.
  Future<List<Order>> getCalendarOrders({
    required String branchId,
    required String startDate,
    required String endDate,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _api.get(
        '/calendar',
        queryParameters: {
          'branch_id': branchId,
          'start_date': startDate,
          'end_date': endDate,
        },
        cancelToken: cancelToken,
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('[CalendarRepository] Failed to load calendar orders: $e\n$stackTrace');
      throw Exception('Failed to load calendar orders: $e');
    }
  }
}
