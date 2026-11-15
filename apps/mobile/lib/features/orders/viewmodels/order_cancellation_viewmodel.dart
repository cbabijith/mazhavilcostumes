/// Validates cancellation drafts and submits through the existing order operations.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../models/order.dart';
import 'providers/order_provider.dart';

typedef OrderCancellationState = ({
  String reason,
  String refund,
  String mode,
  bool stockReturned,
  AsyncValue<void> submission,
});

final orderCancellationViewModelProvider = NotifierProvider.autoDispose
    .family<OrderCancellationViewModel, OrderCancellationState, String>(
      OrderCancellationViewModel.new,
    );

class OrderCancellationViewModel extends Notifier<OrderCancellationState> {
  OrderCancellationViewModel(this.orderId);
  final String orderId;

  @override
  OrderCancellationState build() => (
    reason: '',
    refund: '0',
    mode: 'cash',
    stockReturned: false,
    submission: const AsyncData<void>(null),
  );

  void edit({
    String? reason,
    String? refund,
    String? mode,
    bool? stockReturned,
  }) {
    if (state.submission.isLoading) return;
    state = (
      reason: reason ?? state.reason,
      refund: refund ?? state.refund,
      mode: mode ?? state.mode,
      stockReturned: stockReturned ?? state.stockReturned,
      submission: const AsyncData<void>(null),
    );
  }

  /// The API repeats these validations against locked live rows.
  static String? validationError(Order order, OrderCancellationState draft) {
    if (!order.canCancel) return AppStrings.cancellationUnavailable;
    if (draft.reason.trim().isEmpty || draft.reason.trim().length > 2000) {
      return AppStrings.cancellationReasonRequired;
    }
    final amount = double.tryParse(draft.refund.trim());
    if (amount == null ||
        !amount.isFinite ||
        amount < 0 ||
        amount > order.amountPaid ||
        (amount * 100 - (amount * 100).round()).abs() > 0.000001) {
      return AppStrings.invalidCancellationRefund;
    }
    if (order.cancellationNeedsStockConfirmation && !draft.stockReturned) {
      return AppStrings.cancellationStockRequired;
    }
    return null;
  }

  /// Refresh paid amount/status before submitting; retain the draft on failure.
  Future<bool> save() async {
    if (state.submission.isLoading) return false;
    final draft = state;
    state = (
      reason: draft.reason,
      refund: draft.refund,
      mode: draft.mode,
      stockReturned: draft.stockReturned,
      submission: const AsyncLoading<void>(),
    );
    try {
      final operations = ref.read(orderOperationsProvider);
      final latest = await operations.getOrderById(orderId);
      if (!ref.mounted) return false;
      final error = validationError(latest, draft);
      if (error != null && latest.status != OrderStatus.cancelled) {
        throw StateError(error);
      }
      await operations.updateOrder(orderId, {
        'status': 'cancelled',
        'cancellation_reason': draft.reason.trim(),
        'refund_amount': double.parse(draft.refund.trim()),
        'refund_payment_mode': draft.mode,
        'stock_returned': draft.stockReturned,
      });
      if (!ref.mounted) return false;
      state = (
        reason: draft.reason,
        refund: draft.refund,
        mode: draft.mode,
        stockReturned: draft.stockReturned,
        submission: const AsyncData<void>(null),
      );
      return true;
    } catch (error, stack) {
      if (ref.mounted) {
        state = (
          reason: draft.reason,
          refund: draft.refund,
          mode: draft.mode,
          stockReturned: draft.stockReturned,
          submission: AsyncError<void>(error, stack),
        );
      }
      return false;
    }
  }
}
