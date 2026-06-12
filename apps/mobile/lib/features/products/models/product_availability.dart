import 'package:equatable/equatable.dart';

/// A single booking overlapping a calendar day.
class DayBooking extends Equatable {
  final String orderId;
  final String customerName;
  final int quantity;
  final String startDate;
  final String endDate;
  final String status;
  final bool isBuffer;

  const DayBooking({
    required this.orderId,
    required this.customerName,
    required this.quantity,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.isBuffer,
  });

  @override
  List<Object?> get props => [orderId, customerName, quantity, startDate, endDate, status, isBuffer];

  factory DayBooking.fromJson(Map<String, dynamic> json) {
    return DayBooking(
      orderId: json['orderId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? 'Unknown',
      quantity: json['quantity'] as int? ?? 0,
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      status: json['status'] as String? ?? '',
      isBuffer: json['isBuffer'] as bool? ?? false,
    );
  }
}

/// Availability status for a single calendar day.
class AvailabilityDay extends Equatable {
  final String date;
  final int total;
  final int reserved;
  final int bufferReserved;
  final int available;
  final String status; // available | partial | unavailable | buffer
  final List<DayBooking> bookings;

  const AvailabilityDay({
    required this.date,
    required this.total,
    required this.reserved,
    required this.bufferReserved,
    required this.available,
    required this.status,
    required this.bookings,
  });

  @override
  List<Object?> get props => [date, total, reserved, bufferReserved, available, status, bookings];

  factory AvailabilityDay.fromJson(Map<String, dynamic> json) {
    final bookingsRaw = json['bookings'] as List<dynamic>? ?? [];
    final bookings = bookingsRaw
        .map((e) => DayBooking.fromJson(e as Map<String, dynamic>))
        .toList();

    return AvailabilityDay(
      date: json['date'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      reserved: json['reserved'] as int? ?? 0,
      bufferReserved: json['bufferReserved'] as int? ?? 0,
      available: json['available'] as int? ?? 0,
      status: json['status'] as String? ?? 'available',
      bookings: bookings,
    );
  }
}

/// Full availability calendar response for a product over a date range.
class ProductAvailability extends Equatable {
  final String productId;
  final String productName;
  final int totalQuantity;
  final List<AvailabilityDay> days;

  const ProductAvailability({
    required this.productId,
    required this.productName,
    required this.totalQuantity,
    required this.days,
  });

  @override
  List<Object?> get props => [productId, productName, totalQuantity, days];

  factory ProductAvailability.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final daysRaw = data['days'] as List<dynamic>? ?? [];
    final days = daysRaw
        .map((e) => AvailabilityDay.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProductAvailability(
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      totalQuantity: data['totalQuantity'] as int? ?? 0,
      days: days,
    );
  }
}
