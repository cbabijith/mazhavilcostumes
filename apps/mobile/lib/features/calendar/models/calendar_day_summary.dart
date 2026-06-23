import 'package:equatable/equatable.dart';
import '../../orders/models/order.dart';

/// Representation of a single day's summarized status and bookings list.
class CalendarDaySummary extends Equatable {
  final DateTime date;
  final List<Order> orders;
  final List<Order> startingOrders; // Pickups starting today
  final List<Order> endingOrders;   // Returns due today
  final List<Order> ongoingOrders;  // In use on this day
  final double totalRevenue;        // Sum of starting orders revenue
  final bool hasLateReturns;
  final bool hasActionNeeded;

  const CalendarDaySummary({
    required this.date,
    required this.orders,
    required this.startingOrders,
    required this.endingOrders,
    required this.ongoingOrders,
    required this.totalRevenue,
    required this.hasLateReturns,
    required this.hasActionNeeded,
  });

  @override
  List<Object?> get props => [
        date,
        orders,
        startingOrders,
        endingOrders,
        ongoingOrders,
        totalRevenue,
        hasLateReturns,
        hasActionNeeded,
      ];
}
