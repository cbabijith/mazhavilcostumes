import 'package:equatable/equatable.dart';

// Order domain models for the Rentocostume mobile app.
//
// Mirrors the Next.js Order domain types and enums, ensuring exact mapping
// of fields (start/end dates, tax structures, discount types, late flags, and relationships).

enum OrderStatus {
  pending,
  confirmed,
  scheduled,
  delivered,
  inUse,
  ongoing,
  partial,
  returned,
  completed,
  cancelled,
  flagged,
}

enum PaymentStatus {
  pending,
  partial,
  paid,
  refundWaived;

  String toJsonValue() {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.partial:
        return 'partial';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.refundWaived:
        return 'refund_waived';
    }
  }
}

enum PaymentMethod {
  cash,
  upi,
  bankTransfer,
  gpay,
  other;

  String toJsonValue() {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.upi:
        return 'upi';
      case PaymentMethod.bankTransfer:
        return 'bank_transfer';
      case PaymentMethod.gpay:
        return 'gpay';
      case PaymentMethod.other:
        return 'other';
    }
  }
}

enum ConditionRating {
  excellent,
  good,
  fair,
  damaged,
}

enum DeliveryMethod {
  pickup,
  delivery,
}

class ProductInfo extends Equatable {
  final String id;
  final String name;
  final String? primaryImageUrl;

  const ProductInfo({
    required this.id,
    required this.name,
    this.primaryImageUrl,
  });

  @override
  List<Object?> get props => [id, name, primaryImageUrl];

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    String? primaryUrl;
    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      final primary = images.where((i) => i['is_primary'] == true);
      primaryUrl = primary.isNotEmpty ? primary.first['url'] as String? : images.first['url'] as String?;
    }
    return ProductInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      primaryImageUrl: primaryUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double pricePerDay;
  final double totalPrice;
  final double subtotal;
  final double discount;
  final String discountType; // 'flat' | 'percent'
  final double gstPercentage;
  final double baseAmount;
  final double gstAmount;
  final ConditionRating? conditionRating;
  final String? damageDescription;
  final double? damageCharges;
  final int? damagedQuantity;
  final bool? isReturned;
  final String? returnedAt;
  final int? returnedQuantity;
  final String createdAt;
  final ProductInfo? product;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.pricePerDay,
    required this.totalPrice,
    required this.subtotal,
    this.discount = 0.0,
    this.discountType = 'flat',
    this.gstPercentage = 0.0,
    this.baseAmount = 0.0,
    this.gstAmount = 0.0,
    this.conditionRating,
    this.damageDescription,
    this.damageCharges,
    this.damagedQuantity,
    this.isReturned,
    this.returnedAt,
    this.returnedQuantity,
    required this.createdAt,
    this.product,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        quantity,
        pricePerDay,
        totalPrice,
        subtotal,
        discount,
        discountType,
        gstPercentage,
        baseAmount,
        gstAmount,
        conditionRating,
        damageDescription,
        damageCharges,
        damagedQuantity,
        isReturned,
        returnedAt,
        returnedQuantity,
        createdAt,
        product,
      ];

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      pricePerDay: (json['price_per_day'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type'] as String? ?? 'flat',
      gstPercentage: (json['gst_percentage'] as num?)?.toDouble() ?? 0.0,
      baseAmount: (json['base_amount'] as num?)?.toDouble() ?? 0.0,
      gstAmount: (json['gst_amount'] as num?)?.toDouble() ?? 0.0,
      conditionRating: json['condition_rating'] != null
          ? _parseConditionRating(json['condition_rating'] as String)
          : null,
      damageDescription: json['damage_description'] as String?,
      damageCharges: (json['damage_charges'] as num?)?.toDouble(),
      damagedQuantity: json['damaged_quantity'] as int?,
      isReturned: json['is_returned'] as bool?,
      returnedAt: json['returned_at'] as String?,
      returnedQuantity: json['returned_quantity'] as int?,
      createdAt: json['created_at'] as String? ?? '',
      product: json['product'] != null && json['product'] is Map
          ? ProductInfo.fromJson(Map<String, dynamic>.from(json['product']))
          : null,
    );
  }

  static ConditionRating _parseConditionRating(String value) {
    switch (value.toLowerCase()) {
      case 'excellent':
        return ConditionRating.excellent;
      case 'good':
        return ConditionRating.good;
      case 'fair':
        return ConditionRating.fair;
      case 'damaged':
        return ConditionRating.damaged;
      default:
        return ConditionRating.good;
    }
  }

  String _conditionRatingToString() {
    switch (conditionRating) {
      case ConditionRating.excellent:
        return 'excellent';
      case ConditionRating.good:
        return 'good';
      case ConditionRating.fair:
        return 'fair';
      case ConditionRating.damaged:
        return 'damaged';
      case null:
        return '';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price_per_day': pricePerDay,
      'total_price': totalPrice,
      'subtotal': subtotal,
      'discount': discount,
      'discount_type': discountType,
      'gst_percentage': gstPercentage,
      'base_amount': baseAmount,
      'gst_amount': gstAmount,
      'condition_rating': _conditionRatingToString(),
      'damage_description': damageDescription,
      'damage_charges': damageCharges,
      'damaged_quantity': damagedQuantity,
      'is_returned': isReturned,
      'returned_at': returnedAt,
      'returned_quantity': returnedQuantity,
      'created_at': createdAt,
    };
  }
}

class Order extends Equatable {
  final String id;
  final String storeId;
  final String customerId;
  final String branchId;
  final OrderStatus status;
  final String startDate;
  final String endDate;
  final String eventDate;
  final double totalAmount;
  final double subtotal;
  final double gstAmount;
  final double advanceAmount;
  final bool advanceCollected;
  final PaymentMethod? advancePaymentMethod;
  final String? advanceCollectedAt;
  final double amountPaid;
  final PaymentStatus paymentStatus;
  final bool hasPriorityCleaning;
  final bool hasStockConflict;
  final List<dynamic>? conflictDetails;
  final String? notes;
  final DeliveryMethod? deliveryMethod;
  final String? deliveryAddress;
  final String? pickupAddress;
  final double lateFee;
  final double discount;
  final String discountType; // 'flat' | 'percent'
  final double damageChargesTotal;
  final String? cancellationReason;
  final String? cancelledBy;
  final String? cancelledAt;
  final bool isLate;
  final String createdAt;
  final String? updatedAt;
  final CustomerInfo? customer;
  final List<OrderItem>? items;
  final BranchInfo? branch;

  // Legacy field support for UI/views compatibility
  double get securityDeposit => advanceAmount;

  const Order({
    required this.id,
    required this.storeId,
    required this.customerId,
    required this.branchId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.eventDate,
    required this.totalAmount,
    required this.subtotal,
    required this.gstAmount,
    required this.advanceAmount,
    this.advanceCollected = false,
    this.advancePaymentMethod,
    this.advanceCollectedAt,
    required this.amountPaid,
    required this.paymentStatus,
    this.hasPriorityCleaning = false,
    this.hasStockConflict = false,
    this.conflictDetails,
    this.notes,
    this.deliveryMethod,
    this.deliveryAddress,
    this.pickupAddress,
    required this.lateFee,
    required this.discount,
    this.discountType = 'flat',
    required this.damageChargesTotal,
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledAt,
    this.isLate = false,
    required this.createdAt,
    this.updatedAt,
    this.customer,
    this.items,
    this.branch,
  });

  @override
  List<Object?> get props => [
        id,
        storeId,
        customerId,
        branchId,
        status,
        startDate,
        endDate,
        eventDate,
        totalAmount,
        subtotal,
        gstAmount,
        advanceAmount,
        advanceCollected,
        advancePaymentMethod,
        advanceCollectedAt,
        amountPaid,
        paymentStatus,
        hasPriorityCleaning,
        hasStockConflict,
        conflictDetails,
        notes,
        deliveryMethod,
        deliveryAddress,
        pickupAddress,
        lateFee,
        discount,
        discountType,
        damageChargesTotal,
        cancellationReason,
        cancelledBy,
        cancelledAt,
        isLate,
        createdAt,
        updatedAt,
        customer,
        items,
        branch,
      ];

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      storeId: json['store_id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      branchId: json['branch_id'] as String? ?? '',
      status: _parseOrderStatus(json['status'] as String? ?? 'pending'),
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      eventDate: json['event_date'] as String? ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      gstAmount: (json['gst_amount'] as num?)?.toDouble() ?? 0.0,
      advanceAmount: (json['advance_amount'] as num?)?.toDouble() ??
          (json['security_deposit'] as num?)?.toDouble() ??
          0.0,
      advanceCollected: json['advance_collected'] as bool? ??
          json['deposit_collected'] as bool? ??
          false,
      advancePaymentMethod: json['advance_payment_method'] != null
          ? _parsePaymentMethod(json['advance_payment_method'] as String)
          : json['deposit_payment_method'] != null
              ? _parsePaymentMethod(json['deposit_payment_method'] as String)
              : null,
      advanceCollectedAt: json['advance_collected_at'] as String? ??
          json['deposit_collected_at'] as String?,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: _parsePaymentStatus(json['payment_status'] as String? ?? 'pending'),
      hasPriorityCleaning: json['has_priority_cleaning'] as bool? ?? false,
      hasStockConflict: json['has_stock_conflict'] as bool? ?? false,
      conflictDetails: json['conflict_details'] as List<dynamic>?,
      notes: json['notes'] as String?,
      deliveryMethod: json['delivery_method'] != null
          ? _parseDeliveryMethod(json['delivery_method'] as String)
          : null,
      deliveryAddress: json['delivery_address'] as String?,
      pickupAddress: json['pickup_address'] as String?,
      lateFee: (json['late_fee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type'] as String? ?? 'flat',
      damageChargesTotal: (json['damage_charges_total'] as num?)?.toDouble() ?? 0.0,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledBy: json['cancelled_by'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
      isLate: json['is_late'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String?,
      customer: json['customer'] != null
          ? (json['customer'] is List
              ? (json['customer'].isNotEmpty
                  ? CustomerInfo.fromJson(Map<String, dynamic>.from(json['customer'][0]))
                  : null)
              : CustomerInfo.fromJson(Map<String, dynamic>.from(json['customer'])))
          : null,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      branch: json['branch'] != null ? BranchInfo.fromJson(json['branch']) : null,
    );
  }

  static OrderStatus _parseOrderStatus(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'scheduled':
        return OrderStatus.scheduled;
      case 'delivered':
        return OrderStatus.delivered;
      case 'in_use':
        return OrderStatus.inUse;
      case 'ongoing':
        return OrderStatus.ongoing;
      case 'partial':
        return OrderStatus.partial;
      case 'returned':
        return OrderStatus.returned;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'flagged':
        return OrderStatus.flagged;
      default:
        return OrderStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'partial':
        return PaymentStatus.partial;
      case 'paid':
        return PaymentStatus.paid;
      case 'refund_waived':
        return PaymentStatus.refundWaived;
      default:
        return PaymentStatus.pending;
    }
  }

  static PaymentMethod _parsePaymentMethod(String value) {
    switch (value.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'upi':
        return PaymentMethod.upi;
      case 'bank_transfer':
        return PaymentMethod.bankTransfer;
      case 'gpay':
        return PaymentMethod.gpay;
      case 'other':
        return PaymentMethod.other;
      default:
        return PaymentMethod.other;
    }
  }

  static DeliveryMethod _parseDeliveryMethod(String value) {
    switch (value.toLowerCase()) {
      case 'pickup':
        return DeliveryMethod.pickup;
      case 'delivery':
        return DeliveryMethod.delivery;
      default:
        return DeliveryMethod.pickup;
    }
  }

  String _orderStatusToString() {
    return status.name;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'customer_id': customerId,
      'branch_id': branchId,
      'status': _orderStatusToString(),
      'start_date': startDate,
      'end_date': endDate,
      'event_date': eventDate,
      'total_amount': totalAmount,
      'subtotal': subtotal,
      'gst_amount': gstAmount,
      'advance_amount': advanceAmount,
      'advance_collected': advanceCollected,
      'advance_payment_method': advancePaymentMethod?.toJsonValue(),
      'advance_collected_at': advanceCollectedAt,
      'amount_paid': amountPaid,
      'payment_status': paymentStatus.toJsonValue(),
      'has_priority_cleaning': hasPriorityCleaning,
      'has_stock_conflict': hasStockConflict,
      'conflict_details': conflictDetails,
      'notes': notes,
      'delivery_method': deliveryMethod?.name,
      'delivery_address': deliveryAddress,
      'pickup_address': pickupAddress,
      'late_fee': lateFee,
      'discount': discount,
      'discount_type': discountType,
      'damage_charges_total': damageChargesTotal,
      'cancellation_reason': cancellationReason,
      'cancelled_by': cancelledBy,
      'cancelled_at': cancelledAt,
      'is_late': isLate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'customer': customer?.toJson(),
      'items': items?.map((e) => e.toJson()).toList(),
      'branch': branch?.toJson(),
    };
  }
}

class CustomerInfo extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? altPhone;
  final String? email;
  final String? address;

  const CustomerInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.altPhone,
    this.email,
    this.address,
  });

  @override
  List<Object?> get props => [id, name, phone, altPhone, email, address];

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      altPhone: json['alt_phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'alt_phone': altPhone,
      'email': email,
      'address': address,
    };
  }
}

class BranchInfo extends Equatable {
  final String id;
  final String name;

  const BranchInfo({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];

  factory BranchInfo.fromJson(Map<String, dynamic> json) {
    return BranchInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class PaymentTransaction extends Equatable {
  final String id;
  final String orderId;
  final String paymentType;
  final double amount;
  final String paymentMode;
  final String? transactionId;
  final String paymentDate;
  final String? notes;
  final String? createdBy;
  final String? createdByName;

  const PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.paymentType,
    required this.amount,
    required this.paymentMode,
    this.transactionId,
    required this.paymentDate,
    this.notes,
    this.createdBy,
    this.createdByName,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        paymentType,
        amount,
        paymentMode,
        transactionId,
        paymentDate,
        notes,
        createdBy,
        createdByName,
      ];

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    String? staffName;
    if (json['staff'] != null) {
      if (json['staff'] is Map) {
        staffName = json['staff']['name']?.toString();
      } else if (json['staff'] is List && (json['staff'] as List).isNotEmpty) {
        staffName = (json['staff'] as List).first['name']?.toString();
      }
    }

    return PaymentTransaction(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      paymentType: json['payment_type']?.toString() ?? '',
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      paymentMode: json['payment_mode']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString(),
      paymentDate: json['payment_date']?.toString() ?? 
                   json['created_at']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdByName: staffName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'payment_type': paymentType,
      'amount': amount,
      'payment_mode': paymentMode,
      'transaction_id': transactionId,
      'payment_date': paymentDate,
      'notes': notes,
      'created_by': createdBy,
    };
  }
}

