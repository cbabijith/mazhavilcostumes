/// A calendar overview and the freshness of its local display snapshot.
library;

import '../../orders/models/order.dart';

class CalendarOrders {
  const CalendarOrders(this.orders, {this.savedAt, this.refreshFailed = false});
  final List<Order> orders;
  final DateTime? savedAt;
  final bool refreshFailed;
}
