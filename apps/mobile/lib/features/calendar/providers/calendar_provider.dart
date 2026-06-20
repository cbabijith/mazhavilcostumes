import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../branches/viewmodels/providers/branch_provider.dart';
import '../../orders/models/order.dart';
import '../models/calendar_day_summary.dart';
import '../repositories/calendar_repository.dart';

/// Month-level statistics summary
class CalendarMonthStats {
  final int ongoingToday;
  final int scheduledThisMonth;
  final int endingToday;
  final int lateReturns;
  final double totalRevenue;

  const CalendarMonthStats({
    required this.ongoingToday,
    required this.scheduledThisMonth,
    required this.endingToday,
    required this.lateReturns,
    required this.totalRevenue,
  });
}

/// Repository provider for calendar
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository();
});

/// Selected month state provider
class CalendarMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void goToPrevMonth() {
    state = DateTime(state.year, state.month - 1);
  }

  void goToNextMonth() {
    state = DateTime(state.year, state.month + 1);
  }

  void goToToday() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month);
  }
}

final calendarMonthProvider = NotifierProvider<CalendarMonthNotifier, DateTime>(
  CalendarMonthNotifier.new,
);

/// Selected date state provider (for day detail cards display)
class CalendarSelectedDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void select(DateTime? date) {
    state = date != null ? DateTime(date.year, date.month, date.day) : null;
  }
}

final calendarSelectedDateProvider =
    NotifierProvider<CalendarSelectedDateNotifier, DateTime?>(
  CalendarSelectedDateNotifier.new,
);

/// Helper to parse ISO date strings safely
DateTime _parseDateString(String dateStr) {
  if (dateStr.length >= 10) {
    final parts = dateStr.substring(0, 10).split('-');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }
  }
  return DateTime.parse(dateStr);
}

/// Provider for raw calendar orders from the backend
final calendarOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final repo = ref.watch(calendarRepositoryProvider);
  final branchId = ref.watch(effectiveBranchIdProvider);
  if (branchId == null || branchId.isEmpty || branchId == 'null' || branchId == 'undefined') {
    return const [];
  }
  
  final month = ref.watch(calendarMonthProvider);

  // Buffer range: start of month - 7 days to end of month + 7 days
  final startOfCurrentMonth = DateTime(month.year, month.month, 1);
  final endOfCurrentMonth = DateTime(month.year, month.month + 1, 0);

  final fetchStart = startOfCurrentMonth.subtract(const Duration(days: 7));
  final fetchEnd = endOfCurrentMonth.add(const Duration(days: 7));

  final startDateStr =
      "${fetchStart.year}-${fetchStart.month.toString().padLeft(2, '0')}-${fetchStart.day.toString().padLeft(2, '0')}";
  final endDateStr =
      "${fetchEnd.year}-${fetchEnd.month.toString().padLeft(2, '0')}-${fetchEnd.day.toString().padLeft(2, '0')}";

  try {
    final orders = await repo.getCalendarOrders(
      branchId: branchId,
      startDate: startDateStr,
      endDate: endDateStr,
    );
    debugPrint('[calendarOrdersProvider] Successfully fetched ${orders.length} orders for branch: $branchId');
    return orders;
  } catch (e, stackTrace) {
    debugPrint('[calendarOrdersProvider] Error loading calendar orders: $e\n$stackTrace');
    rethrow;
  }
});

/// Processes raw orders into day-by-day summaries for the active month view
final calendarDaySummaryProvider =
    Provider<Map<String, CalendarDaySummary>>((ref) {
  final ordersAsync = ref.watch(calendarOrdersProvider);
  final month = ref.watch(calendarMonthProvider);

  final map = <String, CalendarDaySummary>{};
  final orders = ordersAsync.value ?? const [];

  final endOfCurrentMonth = DateTime(month.year, month.month + 1, 0);

  // Initialize all days of the current month
  for (int dayNum = 1; dayNum <= endOfCurrentMonth.day; dayNum++) {
    final dayDate = DateTime(month.year, month.month, dayNum);
    final dateKey =
        "${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}";

    map[dateKey] = CalendarDaySummary(
      date: dayDate,
      orders: const [],
      startingOrders: const [],
      endingOrders: const [],
      ongoingOrders: const [],
      totalRevenue: 0.0,
      hasLateReturns: false,
      hasActionNeeded: false,
    );
  }

  final now = DateTime.now();
  final todayStr =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

  // Distribute bookings across the month
  for (final order in orders) {
    final start = _parseDateString(order.startDate);
    final end = _parseDateString(order.endDate);

    final cleanStart = DateTime(start.year, start.month, start.day);
    final cleanEnd = DateTime(end.year, end.month, end.day);

    for (int dayNum = 1; dayNum <= endOfCurrentMonth.day; dayNum++) {
      final dayDate = DateTime(month.year, month.month, dayNum);
      final dateKey =
          "${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}";

      // Check if dayDate falls between cleanStart and cleanEnd (inclusive)
      if (!dayDate.isBefore(cleanStart) && !dayDate.isAfter(cleanEnd)) {
        final summary = map[dateKey]!;

        final updatedOrders = List<Order>.from(summary.orders)..add(order);
        final updatedStarting = List<Order>.from(summary.startingOrders);
        final updatedEnding = List<Order>.from(summary.endingOrders);
        final updatedOngoing = List<Order>.from(summary.ongoingOrders);
        double totalRevenue = summary.totalRevenue;
        bool hasLateReturns = summary.hasLateReturns;
        bool hasActionNeeded = summary.hasActionNeeded;

        final isSameAsStart = dayDate.year == cleanStart.year &&
            dayDate.month == cleanStart.month &&
            dayDate.day == cleanStart.day;

        final isSameAsEnd = dayDate.year == cleanEnd.year &&
            dayDate.month == cleanEnd.month &&
            dayDate.day == cleanEnd.day;

        if (isSameAsStart) {
          updatedStarting.add(order);
          totalRevenue += order.totalAmount;
        } else if (isSameAsEnd) {
          updatedEnding.add(order);
        } else {
          updatedOngoing.add(order);
        }

        if (order.isLate || order.status == OrderStatus.flagged) {
          hasLateReturns = true;
        }

        if ((order.status == OrderStatus.scheduled ||
                order.status == OrderStatus.confirmed) &&
            order.startDate.compareTo(todayStr) <= 0) {
          hasActionNeeded = true;
        }

        map[dateKey] = CalendarDaySummary(
          date: dayDate,
          orders: updatedOrders,
          startingOrders: updatedStarting,
          endingOrders: updatedEnding,
          ongoingOrders: updatedOngoing,
          totalRevenue: totalRevenue,
          hasLateReturns: hasLateReturns,
          hasActionNeeded: hasActionNeeded,
        );
      }
    }
  }

  return map;
});

/// Month-level statistics summary provider
final calendarMonthStatsProvider = Provider<CalendarMonthStats>((ref) {
  final daySummaryMap = ref.watch(calendarDaySummaryProvider);
  final today = DateTime.now();
  final todayStr =
      "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

  final todaySummary = daySummaryMap[todayStr];

  int scheduledThisMonth = 0;
  int lateReturns = 0;
  final seenScheduled = <String>{};
  final seenLate = <String>{};

  for (final summary in daySummaryMap.values) {
    for (final order in summary.orders) {
      if ((order.status == OrderStatus.scheduled ||
              order.status == OrderStatus.confirmed) &&
          !seenScheduled.contains(order.id)) {
        seenScheduled.add(order.id);
        scheduledThisMonth++;
      }
      if ((order.isLate || order.status == OrderStatus.flagged) &&
          !seenLate.contains(order.id)) {
        seenLate.add(order.id);
        lateReturns++;
      }
    }
  }

  final totalRevenue = daySummaryMap.values
      .fold<double>(0.0, (sum, day) => sum + day.totalRevenue);

  return CalendarMonthStats(
    ongoingToday: todaySummary?.orders.length ?? 0,
    scheduledThisMonth: scheduledThisMonth,
    endingToday: todaySummary?.endingOrders.length ?? 0,
    lateReturns: lateReturns,
    totalRevenue: totalRevenue,
  );
});
