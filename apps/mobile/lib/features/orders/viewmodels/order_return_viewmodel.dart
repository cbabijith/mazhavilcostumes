/// Presentation rules for order inspections and return settlement previews.
/// The API remains responsible for validating and saving financial changes.
library;

import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../models/order.dart';

typedef ReturnSettlement = ({
  double baseTotal,
  double damageFees,
  double lateFees,
  double discount,
  double total,
  double balanceDue,
});

final orderReturnViewModelProvider = Provider<OrderReturnViewModel>(
  (ref) => const OrderReturnViewModel(),
);

class OrderReturnViewModel {
  const OrderReturnViewModel();

  /// Match the return API's accepted statuses.
  bool canReturn(OrderStatus status) =>
      status == OrderStatus.ongoing ||
      status == OrderStatus.inUse ||
      status == OrderStatus.partial;

  /// An inspection can be saved before the physical return is completed.
  Map<String, Object?> inspectionFor(OrderItem item) => {
    'status':
        (item.isReturned == true || receivedQuantity(item) > 0) &&
            receivedQuantity(item) < item.quantity
        ? 'missing'
        : switch (item.conditionRating) {
            ConditionRating.damaged => 'damaged',
            ConditionRating.excellent || ConditionRating.good => 'good',
            _ => null,
          },
    'damage_fee': item.damageCharges ?? 0.0,
    'damaged_quantity': item.damagedQuantity ?? item.quantity,
    'notes': item.damageDescription ?? '',
  };

  /// Refresh saved values while retaining inspections edited on this screen.
  Map<String, Map<String, Object?>> mergeInspections({
    required Order updated,
    required Order? previous,
    required Map<String, Map<String, Object?>> local,
  }) {
    final oldItems = {
      for (final item in previous?.items ?? <OrderItem>[]) item.id: item,
    };
    return {
      for (final item in updated.items ?? <OrderItem>[])
        item.id: _mergeInspection(
          item,
          oldItems[item.id],
          local[item.id],
          preserveDraft: canReturn(updated.status),
        ),
    };
  }

  Map<String, Object?> _mergeInspection(
    OrderItem item,
    OrderItem? previous,
    Map<String, Object?>? local, {
    required bool preserveDraft,
  }) {
    if (preserveDraft &&
        previous != null &&
        local != null &&
        item.isReturned == previous.isReturned &&
        receivedQuantity(item) == receivedQuantity(previous)) {
      final saved = inspectionFor(previous);
      final edited = saved.keys.any((key) => saved[key] != local[key]);
      if (edited) return Map.of(local);
    }
    return inspectionFor(item);
  }

  /// Use the saved total, which already includes the original order discount.
  /// Replace damage charges, preserve existing late fees, and apply new inputs once.
  ReturnSettlement settlement(
    Order order, {
    double? damageFees,
    double additionalLateFee = 0,
    double additionalDiscount = 0,
  }) {
    final base = order.totalAmount - order.damageChargesTotal - order.lateFee;
    final damage = damageFees ?? order.damageChargesTotal;
    final late = order.lateFee + additionalLateFee;
    final total = _money(
      math.max(0, base + damage + late - additionalDiscount),
    );
    return (
      baseTotal: base,
      damageFees: damage,
      lateFees: late,
      discount: additionalDiscount,
      total: total,
      balanceDue: _money(math.max(0, total - order.amountPaid)),
    );
  }

  double inspectionDamage(
    List<OrderItem> items,
    Map<String, Map<String, Object?>> inspections,
  ) => returnPayload(
    items,
    inspections,
  ).fold(0.0, (sum, item) => sum + (item['damage_charges'] as num).toDouble());

  /// Prefer the cumulative quantity; older API responses may set is_returned
  /// even when no units have physically returned.
  int receivedQuantity(OrderItem item) =>
      (item.returnedQuantity ?? (item.isReturned == true ? item.quantity : 0))
          .clamp(0, item.quantity);

  int returnedQuantity(OrderItem item, Map<String, Object?>? inspection) =>
      inspection?['status'] == 'good' || inspection?['status'] == 'damaged'
      ? item.quantity
      : receivedQuantity(item);

  int pendingUnits(
    List<OrderItem> items,
    Map<String, Map<String, Object?>> inspections,
  ) => items.fold(
    0,
    (sum, item) =>
        sum + item.quantity - returnedQuantity(item, inspections[item.id]),
  );

  /// Build cumulative return quantities without reducing previously received stock.
  List<Map<String, dynamic>> returnPayload(
    List<OrderItem> items,
    Map<String, Map<String, Object?>> inspections,
  ) => [
    for (final item in items) _returnItem(item, inspections[item.id] ?? {}),
  ];

  Map<String, dynamic> _returnItem(
    OrderItem item,
    Map<String, Object?> inspection,
  ) {
    final damaged = inspection['status'] == 'damaged';
    final keepSavedDamage =
        inspection['status'] == 'missing' &&
        receivedQuantity(item) > 0 &&
        item.conditionRating == ConditionRating.damaged;
    return {
      'item_id': item.id,
      'returned_quantity': returnedQuantity(item, inspection),
      'condition_rating': damaged || keepSavedDamage ? 'damaged' : 'excellent',
      'damage_charges': damaged
          ? inspection['damage_fee'] ?? 0
          : keepSavedDamage
          ? item.damageCharges ?? 0
          : 0,
      'damaged_quantity': damaged
          ? inspection['damaged_quantity'] ?? item.quantity
          : keepSavedDamage
          ? item.damagedQuantity ?? 0
          : 0,
      'damage_description': damaged
          ? inspection['notes'] ?? ''
          : keepSavedDamage
          ? item.damageDescription ?? ''
          : '',
    };
  }

  /// Reject malformed and negative discounts before confirmation/payment.
  String? adjustmentError(String discount) {
    if (discount.trim().isEmpty) return null;
    final amount = double.tryParse(discount);
    if (amount == null || !amount.isFinite || amount < 0) {
      return AppStrings.invalidReturnAdjustment;
    }
    return null;
  }

  /// Keep a temporarily invalid text input from breaking a live preview.
  double previewAmount(String input) {
    final amount = double.tryParse(input);
    return amount != null && amount.isFinite && amount >= 0 ? amount : 0;
  }

  double _money(num value) => (value * 100).roundToDouble() / 100;
}
