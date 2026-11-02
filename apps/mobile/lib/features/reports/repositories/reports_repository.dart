import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/supabase/api_client.dart';
import '../domain/day_wise_booking.dart';
import '../domain/top_costume.dart';

/// Reports Repository
///
/// Fetches report data from the Next.js admin API. The mobile app stays a
/// thin client — all aggregation/business logic lives on the server
/// (`reportService` in the admin app).
class ReportsRepository {
  final _api = apiClient;

  /// Day-wise booking schedule: orders starting between [fromDate] and
  /// [toDate] (inclusive), across all non-cancelled active statuses.
  Future<List<DayWiseBooking>> getDayWiseBookings({
    required String fromDate,
    required String toDate,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _api.get(
        '/reports/day-wise-booking',
        queryParameters: {
          'from_date': fromDate,
          'to_date': toDate,
        },
        cancelToken: cancelToken,
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final rows = data['rows'] as List<dynamic>? ?? [];
      debugPrint('[ReportsRepository] Parsed ${rows.length} day-wise bookings');
      return rows
          .map((row) => DayWiseBooking.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ReportsRepository] Error fetching day-wise bookings: $e');
      throw Exception('Failed to load day-wise bookings: $e');
    }
  }

  /// Top costumes ranked by rental count or revenue.
  Future<List<TopCostume>> getTopCostumes({
    String rankBy = 'count',
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _api.get(
        '/reports/top-costumes',
        queryParameters: {
          'rank_by': rankBy,
          'limit': limit,
        },
        cancelToken: cancelToken,
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final rows = data['rows'] as List<dynamic>? ?? [];
      debugPrint('[ReportsRepository] Parsed ${rows.length} top costumes (rank_by=$rankBy)');
      return rows
          .map((row) => TopCostume.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ReportsRepository] Error fetching top costumes: $e');
      throw Exception('Failed to load top costumes: $e');
    }
  }
}
