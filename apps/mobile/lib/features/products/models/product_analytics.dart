import 'package:equatable/equatable.dart';

/// Monthly revenue entry for analytics.
class MonthlyRevenue extends Equatable {
  final String month;
  final double revenue;
  final int rentals;

  const MonthlyRevenue({
    required this.month,
    required this.revenue,
    required this.rentals,
  });

  @override
  List<Object?> get props => [month, revenue, rentals];

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenue(
      month: json['month'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      rentals: json['rentals'] as int? ?? 0,
    );
  }
}

/// Simplified customer summary embedded in order items.
class CustomerSummary extends Equatable {
  final String id;
  final String name;
  final String? phone;

  const CustomerSummary({
    required this.id,
    required this.name,
    this.phone,
  });

  @override
  List<Object?> get props => [id, name, phone];

  factory CustomerSummary.fromJson(Map<String, dynamic> json) {
    return CustomerSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      phone: json['phone'] as String?,
    );
  }
}

/// Simplified branch summary embedded in order items.
class BranchSummary extends Equatable {
  final String id;
  final String name;

  const BranchSummary({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];

  factory BranchSummary.fromJson(Map<String, dynamic> json) {
    return BranchSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

/// Parent order summary embedded in rental history items.
class OrderSummary extends Equatable {
  final String id;
  final String status;
  final String? startDate;
  final String? endDate;
  final double? totalAmount;
  final String? branchId;
  final String? customerId;
  final String? createdAt;
  final CustomerSummary? customer;
  final BranchSummary? branch;

  const OrderSummary({
    required this.id,
    required this.status,
    this.startDate,
    this.endDate,
    this.totalAmount,
    this.branchId,
    this.customerId,
    this.createdAt,
    this.customer,
    this.branch,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        startDate,
        endDate,
        totalAmount,
        branchId,
        customerId,
        createdAt,
        customer,
        branch,
      ];

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    CustomerSummary? customer;
    if (json['customer'] is Map<String, dynamic>) {
      customer = CustomerSummary.fromJson(json['customer'] as Map<String, dynamic>);
    }
    BranchSummary? branch;
    if (json['branch'] is Map<String, dynamic>) {
      branch = BranchSummary.fromJson(json['branch'] as Map<String, dynamic>);
    }
    return OrderSummary(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      branchId: json['branch_id'] as String?,
      customerId: json['customer_id'] as String?,
      createdAt: json['created_at'] as String?,
      customer: customer,
      branch: branch,
    );
  }
}

/// Individual order item row returned by the product orders API.
class ProductOrderItem extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double pricePerDay;
  final double subtotal;
  final String createdAt;
  final OrderSummary? order;

  const ProductOrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.pricePerDay,
    required this.subtotal,
    required this.createdAt,
    this.order,
  });

  @override
  List<Object?> get props => [id, orderId, productId, quantity, pricePerDay, subtotal, createdAt, order];

  factory ProductOrderItem.fromJson(Map<String, dynamic> json) {
    OrderSummary? order;
    if (json['order'] is Map<String, dynamic>) {
      order = OrderSummary.fromJson(json['order'] as Map<String, dynamic>);
    }
    return ProductOrderItem(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      pricePerDay: (json['price_per_day'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String? ?? '',
      order: order,
    );
  }
}

/// Aggregated analytics for a single product.
class ProductAnalytics extends Equatable {
  final int totalOrders;
  final int totalUnitsRented;
  final double totalRevenue;
  final int activeOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int uniqueCustomers;
  final List<MonthlyRevenue> monthlyRevenue;
  final int usageRate;
  final int avgRentalDuration;
  final int? roi;
  final double purchasePrice;
  final int totalRentalDays;
  final int daysSinceCreation;
  final List<ProductOrderItem> items;

  const ProductAnalytics({
    required this.totalOrders,
    required this.totalUnitsRented,
    required this.totalRevenue,
    required this.activeOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.uniqueCustomers,
    required this.monthlyRevenue,
    required this.usageRate,
    required this.avgRentalDuration,
    this.roi,
    required this.purchasePrice,
    required this.totalRentalDays,
    required this.daysSinceCreation,
    required this.items,
  });

  @override
  List<Object?> get props => [
        totalOrders,
        totalUnitsRented,
        totalRevenue,
        activeOrders,
        completedOrders,
        cancelledOrders,
        uniqueCustomers,
        monthlyRevenue,
        usageRate,
        avgRentalDuration,
        roi,
        purchasePrice,
        totalRentalDays,
        daysSinceCreation,
        items,
      ];

  factory ProductAnalytics.fromJson(Map<String, dynamic> json) {
    final analytics = json['analytics'] as Map<String, dynamic>? ?? {};

    final monthlyRaw = analytics['monthlyRevenue'] as List<dynamic>? ?? [];
    final monthlyRevenue = monthlyRaw
        .map((e) => MonthlyRevenue.fromJson(e as Map<String, dynamic>))
        .toList();

    final itemsRaw = json['items'] as List<dynamic>? ?? [];
    final items = itemsRaw
        .map((e) => ProductOrderItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProductAnalytics(
      totalOrders: analytics['totalOrders'] as int? ?? 0,
      totalUnitsRented: analytics['totalUnitsRented'] as int? ?? 0,
      totalRevenue: (analytics['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      activeOrders: analytics['activeOrders'] as int? ?? 0,
      completedOrders: analytics['completedOrders'] as int? ?? 0,
      cancelledOrders: analytics['cancelledOrders'] as int? ?? 0,
      uniqueCustomers: analytics['uniqueCustomers'] as int? ?? 0,
      monthlyRevenue: monthlyRevenue,
      usageRate: analytics['usageRate'] as int? ?? 0,
      avgRentalDuration: analytics['avgRentalDuration'] as int? ?? 0,
      roi: analytics['roi'] as int?,
      purchasePrice: (analytics['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      totalRentalDays: analytics['totalRentalDays'] as int? ?? 0,
      daysSinceCreation: analytics['daysSinceCreation'] as int? ?? 0,
      items: items,
    );
  }
}
