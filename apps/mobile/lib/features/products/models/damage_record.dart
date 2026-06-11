import 'package:equatable/equatable.dart';

/// Simplified order item info embedded in a damage record.
class DamageOrderItem extends Equatable {
  final String id;
  final int quantity;
  final String? damageDescription;
  final double? damageCharges;
  final String? conditionRating;

  const DamageOrderItem({
    required this.id,
    required this.quantity,
    this.damageDescription,
    this.damageCharges,
    this.conditionRating,
  });

  @override
  List<Object?> get props => [id, quantity, damageDescription, damageCharges, conditionRating];

  factory DamageOrderItem.fromJson(Map<String, dynamic> json) {
    return DamageOrderItem(
      id: json['id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      damageDescription: json['damage_description'] as String?,
      damageCharges: (json['damage_charges'] as num?)?.toDouble(),
      conditionRating: json['condition_rating'] as String?,
    );
  }
}

/// Simplified order info embedded in a damage record.
class DamageOrderSummary extends Equatable {
  final String id;
  final String status;
  final String? customerName;

  const DamageOrderSummary({
    required this.id,
    required this.status,
    this.customerName,
  });

  @override
  List<Object?> get props => [id, status, customerName];

  factory DamageOrderSummary.fromJson(Map<String, dynamic> json) {
    String? customerName;
    if (json['customer'] is Map<String, dynamic>) {
      customerName = (json['customer'] as Map<String, dynamic>)['name'] as String?;
    }
    return DamageOrderSummary(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      customerName: customerName,
    );
  }
}

/// Historical damage assessment record for a product unit.
class DamageRecord extends Equatable {
  final String id;
  final String orderId;
  final String orderItemId;
  final String productId;
  final String branchId;
  final int unitIndex;
  final String decision;
  final String? notes;
  final String? assessedBy;
  final String? assessedAt;
  final String createdAt;
  final String updatedAt;
  final DamageOrderItem? orderItem;
  final DamageOrderSummary? order;

  const DamageRecord({
    required this.id,
    required this.orderId,
    required this.orderItemId,
    required this.productId,
    required this.branchId,
    required this.unitIndex,
    required this.decision,
    this.notes,
    this.assessedBy,
    this.assessedAt,
    required this.createdAt,
    required this.updatedAt,
    this.orderItem,
    this.order,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        orderItemId,
        productId,
        branchId,
        unitIndex,
        decision,
        notes,
        assessedBy,
        assessedAt,
        createdAt,
        updatedAt,
        orderItem,
        order,
      ];

  factory DamageRecord.fromJson(Map<String, dynamic> json) {
    DamageOrderItem? orderItem;
    if (json['order_item'] is Map<String, dynamic>) {
      orderItem = DamageOrderItem.fromJson(json['order_item'] as Map<String, dynamic>);
    }
    DamageOrderSummary? order;
    if (json['order'] is Map<String, dynamic>) {
      order = DamageOrderSummary.fromJson(json['order'] as Map<String, dynamic>);
    }
    return DamageRecord(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      orderItemId: json['order_item_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      branchId: json['branch_id'] as String? ?? '',
      unitIndex: json['unit_index'] as int? ?? 0,
      decision: json['decision'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      assessedBy: json['assessed_by'] as String?,
      assessedAt: json['assessed_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      orderItem: orderItem,
      order: order,
    );
  }
}
