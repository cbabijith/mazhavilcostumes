/// Day-wise Booking report row
///
/// Mirrors `DayWiseBookingRow` from the admin API
/// (`GET /api/reports/day-wise-booking`).
class DayWiseBooking {
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String productNames;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final String status;

  const DayWiseBooking({
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.productNames,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.status,
  });

  factory DayWiseBooking.fromJson(Map<String, dynamic> json) {
    return DayWiseBooking(
      orderId: json['order_id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? 'Unknown',
      customerPhone: json['customer_phone'] as String? ?? '',
      productNames: json['product_names'] as String? ?? '',
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
    );
  }
}
