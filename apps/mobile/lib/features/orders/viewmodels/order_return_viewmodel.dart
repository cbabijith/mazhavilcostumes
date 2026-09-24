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
      status == OrderStatus.partial ||
      status == OrderStatus.flagged;

  /// An inspection can be saved before the physical return is completed.
  Map<String, Object?> inspectionFor(OrderItem item) => {
    'status': switch (item.conditionRating) {
      ConditionRating.damaged => 'damaged',
      ConditionRating.excellent || ConditionRating.good => 'good',
      _ => null,
    },
    'damage_fee': item.damageCharges ?? 0.0,
    'damaged_quantity': outstandingQuantity(item) > 0
        ? (item.conditionRating == ConditionRating.damaged &&
                      (item.damagedQuantity ?? 0) > 0
                  ? item.damagedQuantity!
                  : outstandingQuantity(item))
              .clamp(1, outstandingQuantity(item))
        : 0,
    'notes': item.damageDescription ?? '',
    'return_count': outstandingQuantity(item),
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
        item.quantity == previous.quantity &&
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
  ) => items.fold(0.0, (sum, item) {
    final inspection = inspections[item.id];
    // Excluded rows retain their saved assessment on the server.
    if (outstandingQuantity(item) == 0 ||
        inspection?['status'] == null ||
        inspection?['status'] == 'missing' ||
        returningNow(item, inspection) == 0) {
      return sum + (item.damageCharges ?? 0);
    }
    return sum +
        (inspection?['status'] == 'damaged'
            ? (inspection?['damage_fee'] as num? ?? 0).toDouble()
            : 0);
  });

  /// Prefer the cumulative quantity; older API responses may set is_returned
  /// even when no units have physically returned.
  int receivedQuantity(OrderItem item) =>
      (item.returnedQuantity ?? 0).clamp(0, item.quantity);

  int outstandingQuantity(OrderItem item) =>
      item.quantity - receivedQuantity(item);

  int returningNow(OrderItem item, Map<String, Object?>? inspection) =>
      inspection?['status'] == 'missing'
      ? 0
      : ((inspection?['return_count'] as int?) ?? outstandingQuantity(item))
            .clamp(0, outstandingQuantity(item));

  /// Quantities sent to the API are cumulative, while the control shows this visit.
  int returnedQuantity(OrderItem item, Map<String, Object?>? inspection) =>
      receivedQuantity(item) +
      (inspection?['status'] == 'good' || inspection?['status'] == 'damaged'
          ? returningNow(item, inspection)
          : 0);

  Map<String, Object?> withStatus(
    OrderItem item,
    Map<String, Object?> inspection,
    String status,
  ) {
    final count = status == 'missing'
        ? 0
        : returningNow(item, inspection) > 0
        ? returningNow(item, inspection)
        : outstandingQuantity(item);
    return {
      ...inspection,
      'status': status,
      'return_count': count,
      'damaged_quantity': status == 'damaged' && count > 0
          ? ((inspection['damaged_quantity'] as int? ?? 0) > 0
                    ? inspection['damaged_quantity'] as int
                    : count)
                .clamp(1, count)
          : 0,
      'damage_fee': status == 'damaged' ? inspection['damage_fee'] ?? 0.0 : 0.0,
      'notes': status == 'damaged' ? inspection['notes'] ?? '' : '',
    };
  }

  Map<String, Object?> withReturningCount(
    OrderItem item,
    Map<String, Object?> inspection,
    int count,
  ) {
    final clamped = count.clamp(0, outstandingQuantity(item));
    return {
      ...inspection,
      'return_count': clamped,
      'damaged_quantity': inspection['status'] == 'damaged' && clamped > 0
          ? ((inspection['damaged_quantity'] as int?) ?? clamped).clamp(
              1,
              clamped,
            )
          : 0,
    };
  }

  int pendingUnits(
    List<OrderItem> items,
    Map<String, Map<String, Object?>> inspections,
  ) => items.fold(
    0,
    (sum, item) => inspections[item.id]?['status'] == null
        ? sum
        : sum + item.quantity - returnedQuantity(item, inspections[item.id]),
  );

  /// Match the web checklist: every outstanding row needs a decision, and at
  /// least one unit must come back. A zero-count Good/Damaged row is invalid.
  String? inspectionError(
    List<OrderItem> items,
    Map<String, Map<String, Object?>> inspections,
  ) {
    final outstanding = items.where((item) => outstandingQuantity(item) > 0);
    if (outstanding.any((item) => inspections[item.id]?['status'] == null)) {
      return AppStrings.incompleteCheckup;
    }
    if (outstanding.any(
      (item) =>
          inspections[item.id]?['status'] != 'missing' &&
          returningNow(item, inspections[item.id]) == 0,
    )) {
      return AppStrings.invalidReturnCount;
    }
    if (!outstanding.any(
      (item) => returningNow(item, inspections[item.id]) > 0,
    )) {
      return AppStrings.noItemsReturned;
    }
    return null;
  }

  /// Summarize this visit in units, including good units on a damaged line.
  ({int good, int damaged}) inspectionSummary(
    List<OrderItem> items,
    Map<String, Map<String, Object?>> inspections,
  ) {
    var good = 0;
    var damaged = 0;
    for (final item in items) {
      final draft = inspections[item.id];
      if (draft?['status'] != 'good' && draft?['status'] != 'damaged') continue;
      final count = returningNow(item, draft);
      final damagedCount = draft?['status'] == 'damaged'
          ? ((draft?['damaged_quantity'] as int?) ?? count).clamp(0, count)
          : 0;
      damaged += damagedCount;
      good += count - damagedCount;
    }
    return (good: good, damaged: damaged);
  }

  /// Only send units received now; excluded rows keep their saved assessment.
  List<Map<String, dynamic>> returnPayload(
    List<OrderItem> items,
    Map<String, Map<String, Object?>> inspections,
  ) => [
    for (final item in items)
      if (returnedQuantity(item, inspections[item.id]) > receivedQuantity(item))
        _returnItem(item, inspections[item.id] ?? {}),
  ];

  Map<String, dynamic> _returnItem(
    OrderItem item,
    Map<String, Object?> inspection,
  ) {
    final damaged = inspection['status'] == 'damaged';
    return {
      'item_id': item.id,
      'returned_quantity': returnedQuantity(item, inspection),
      'condition_rating': damaged ? 'damaged' : 'excellent',
      'damage_charges': damaged ? inspection['damage_fee'] ?? 0 : 0,
      'damaged_quantity': damaged
          ? ((inspection['damaged_quantity'] as int?) ??
                    returningNow(item, inspection))
                .clamp(1, returningNow(item, inspection))
          : 0,
      'damage_description': damaged ? inspection['notes'] ?? '' : '',
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
