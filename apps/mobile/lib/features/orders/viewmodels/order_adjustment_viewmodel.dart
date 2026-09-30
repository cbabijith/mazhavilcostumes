/// Financial adjustment drafts and saving through the existing order repository.
library;

import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../models/order.dart';
import '../models/order_adjustment.dart';
import 'order_return_viewmodel.dart';
import 'providers/order_provider.dart';

typedef OrderAdjustmentState = ({
  OrderAdjustmentType type,
  String amount,
  String notes,
  AsyncValue<void> submission,
});

final orderAdjustmentViewModelProvider = NotifierProvider.autoDispose
    .family<OrderAdjustmentViewModel, OrderAdjustmentState, String>(
      OrderAdjustmentViewModel.new,
    );

class OrderAdjustmentViewModel extends Notifier<OrderAdjustmentState> {
  OrderAdjustmentViewModel(this.orderId);

  final String orderId;

  @override
  OrderAdjustmentState build() => (
    type: OrderAdjustmentType.discount,
    amount: '',
    notes: '',
    submission: const AsyncData<void>(null),
  );

  static String label(OrderAdjustmentType type) => switch (type) {
    OrderAdjustmentType.discount => AppStrings.returnDiscount,
    OrderAdjustmentType.lateFee => AppStrings.lateFee,
    OrderAdjustmentType.damageFee => AppStrings.damageFee,
    OrderAdjustmentType.extraCharge => AppStrings.extraCharge,
  };

  /// Validate currency before any request; sub-paise values cannot become zero.
  static double? parseAmount(String input) {
    final parsed = double.tryParse(input.trim());
    if (parsed == null || !parsed.isFinite || parsed <= 0) return null;
    final rounded = _money(parsed);
    return rounded.isFinite && rounded > 0 ? rounded : null;
  }

  static String? amountError(String? input) => parseAmount(input ?? '') == null
      ? AppStrings.invalidFinancialAdjustment
      : null;

  void selectType(OrderAdjustmentType type) => _edit(type: type);
  void setAmount(String amount) => _edit(amount: amount);
  void setNotes(String notes) => _edit(notes: notes);

  void _edit({OrderAdjustmentType? type, String? amount, String? notes}) {
    if (state.submission.isLoading) return;
    state = (
      type: type ?? state.type,
      amount: amount ?? state.amount,
      notes: notes ?? state.notes,
      submission: const AsyncData<void>(null),
    );
  }

  /// A new manual late fee warns through the entire due day, just like return.
  bool showOnTimeWarning(Order order, {DateTime? now}) =>
      state.type == OrderAdjustmentType.lateFee &&
      parseAmount(state.amount) != null &&
      !const OrderReturnViewModel().isOverdue(order, now: now);

  /// Build an absolute update from freshly loaded amounts. Adjustments do not
  /// represent money collected, so the server reconciles payment status itself.
  static Map<String, Object?> updateBody({
    required Order order,
    required OrderAdjustmentType type,
    required double amount,
    required String notes,
  }) {
    final normalizedAmount = parseAmount(amount.toString());
    if (normalizedAmount == null) {
      throw ArgumentError(AppStrings.invalidFinancialAdjustment);
    }
    final total = _money(
      type == OrderAdjustmentType.discount
          ? math.max(0, order.totalAmount - normalizedAmount)
          : order.totalAmount + normalizedAmount,
    );
    final field = switch (type) {
      OrderAdjustmentType.discount => 'discount',
      OrderAdjustmentType.lateFee => 'late_fee',
      OrderAdjustmentType.damageFee => 'damage_charges_total',
      OrderAdjustmentType.extraCharge => null,
    };
    // Stored discount is currency even when discount_type retains 'percent'.
    final existing = switch (type) {
      OrderAdjustmentType.discount => order.discount,
      OrderAdjustmentType.lateFee => order.lateFee,
      OrderAdjustmentType.damageFee => order.damageChargesTotal,
      OrderAdjustmentType.extraCharge => 0.0,
    };
    final cumulative = _money(existing + normalizedAmount);
    if (!total.isFinite || !cumulative.isFinite) {
      throw ArgumentError(AppStrings.invalidFinancialAdjustment);
    }
    final reason = notes.trim();
    final annotation =
        '${label(type)}: ₹${normalizedAmount.toStringAsFixed(2)}'
        '${reason.isEmpty ? '' : ' — $reason'}';
    return {
      'total_amount': total,
      ?field: cumulative,
      if (type == OrderAdjustmentType.discount) 'discount_type': 'flat',
      'notes': [
        if (order.notes?.trim().isNotEmpty == true) order.notes!,
        annotation,
      ].join('\n'),
    };
  }

  /// Reload before saving to retain adjustments made since this sheet opened.
  /// Failed reads or writes retain the complete draft for a deliberate retry.
  Future<bool> save() async {
    if (state.submission.isLoading) return false;
    final draft = state;
    final amount = parseAmount(draft.amount);
    if (amount == null) {
      state = (
        type: draft.type,
        amount: draft.amount,
        notes: draft.notes,
        submission: AsyncError<void>(
          ArgumentError(AppStrings.invalidFinancialAdjustment),
          StackTrace.current,
        ),
      );
      return false;
    }
    state = (
      type: draft.type,
      amount: draft.amount,
      notes: draft.notes,
      submission: const AsyncLoading<void>(),
    );
    try {
      final operations = ref.read(orderOperationsProvider);
      final latest = await operations.getOrderById(orderId);
      final body = updateBody(
        order: latest,
        type: draft.type,
        amount: amount,
        notes: draft.notes,
      );
      await operations.updateOrder(orderId, body);
      if (!ref.mounted) return false;
      state = (
        type: draft.type,
        amount: draft.amount,
        notes: draft.notes,
        submission: const AsyncData<void>(null),
      );
      return true;
    } catch (error, stack) {
      if (ref.mounted) {
        state = (
          type: draft.type,
          amount: draft.amount,
          notes: draft.notes,
          submission: AsyncError<void>(error, stack),
        );
      }
      return false;
    }
  }

  static double _money(num value) => (value * 100).roundToDouble() / 100;
}
