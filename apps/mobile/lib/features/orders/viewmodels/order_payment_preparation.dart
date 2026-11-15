/// Saves confirmed financial drafts before collection, without returning items.
library;

import '../../../core/constants/app_constants.dart';
import '../models/order.dart';
import '../models/order_adjustment.dart';
import 'order_adjustment_viewmodel.dart';
import 'providers/order_provider.dart';

class OrderPaymentPreparation {
  ({
    String id,
    double lateFee,
    double discount,
    Map<String, Object?> before,
    Map<String, Object?> update,
  })?
  _pending;
  bool _applied = false;
  bool _saving = false;

  /// Use the existing adjustment API, then reload its persisted balance. Keep
  /// the same absolute update on a failed/ambiguous response so retrying this
  /// confirmation cannot add the draft twice in the current screen session.
  Future<Order> save({
    required OrderOperations operations,
    required String orderId,
    required double lateFee,
    required double discount,
  }) async {
    if (_saving) throw StateError(AppStrings.paymentPreparationBusy);
    if ([lateFee, discount].any((value) => !value.isFinite || value < 0)) {
      throw ArgumentError(AppStrings.invalidFinancialAdjustment);
    }
    _saving = true;
    try {
      final latest = await operations.getOrderById(orderId);
      if (!latest.acceptsPayments && _pending == null) {
        throw StateError(AppStrings.paymentUnavailable);
      }
      final pending = _pending;
      if (pending != null &&
          (pending.id != orderId ||
              pending.lateFee != lateFee ||
              pending.discount != discount)) {
        throw StateError(AppStrings.finishPendingAdjustment);
      }
      if (_pending == null) {
        final update = <String, Object?>{};
        if (lateFee > 0) {
          update.addAll(
            OrderAdjustmentViewModel.updateBody(
              order: latest,
              type: OrderAdjustmentType.lateFee,
              amount: lateFee,
              notes: '',
            ),
          );
        }
        if (discount > 0) {
          update.addAll(
            OrderAdjustmentViewModel.updateBody(
              order: Order.fromJson({...latest.toJson(), ...update}),
              type: OrderAdjustmentType.discount,
              amount: discount,
              notes: '',
            ),
          );
        }
        if (update.isEmpty) return latest;
        final original = latest.toJson();
        _pending = (
          id: orderId,
          lateFee: lateFee,
          discount: discount,
          before: {for (final key in update.keys) key: original[key]},
          update: update,
        );
      }
      final plan = _pending!;
      final current = latest.toJson();
      // A timed-out PATCH may already have committed. Reconcile before retry.
      final alreadySaved = plan.update.entries.every(
        (entry) => current[entry.key] == entry.value,
      );
      if (!_applied && !alreadySaved) {
        if (!latest.acceptsPayments) {
          throw StateError(AppStrings.paymentUnavailable);
        }
        if (!plan.before.entries.every(
          (entry) => current[entry.key] == entry.value,
        )) {
          throw StateError(AppStrings.adjustmentChangedOnServer);
        }
        await operations.updateOrder(orderId, plan.update);
        _applied = true;
      }
      final saved = _applied ? await operations.getOrderById(orderId) : latest;
      _pending = null;
      _applied = false;
      return saved;
    } finally {
      _saving = false;
    }
  }
}
