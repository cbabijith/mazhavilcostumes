import 'package:dio/dio.dart';
import '../../../core/cache/startup_snapshot_cache.dart';
import '../models/calendar_orders.dart';
import '../../../core/supabase/api_client.dart';
import '../../orders/models/order.dart';

/// Repository for calling next.js calendar API endpoints.
class CalendarRepository {
  final _api = apiClient;

  /// The exact branch/range is part of the key, so changing months never shows another month's orders.
  Stream<CalendarOrders> watchSavedCalendar({
    required StartupSnapshotCache cache,
    required String scope,
    required String branchId,
    required String startDate,
    required String endDate,
    required CancelToken cancelToken,
  }) => cache
      .watch<List<Order>>(
        resource: StartupResource.calendar,
        scope: '$scope/$branchId/$startDate/$endDate',
        fetch: () => getCalendarOrders(
          branchId: branchId,
          startDate: startDate,
          endDate: endDate,
          cancelToken: cancelToken,
        ),
        decode: (json) => (json['orders'] as List)
            .map((value) => Order.fromJson(Map<String, dynamic>.from(value)))
            .toList(),
        encode: (orders) => {
          'orders': orders.map((order) => order.toJson()).toList(),
        },
        cancelToken: cancelToken,
      )
      .map(
        (snapshot) => CalendarOrders(
          snapshot.data,
          savedAt: snapshot.savedAt,
          refreshFailed: snapshot.refreshFailed,
        ),
      );

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
          'summary': true,
        },
        cancelToken: cancelToken,
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to load calendar orders: $e');
    }
  }
}
