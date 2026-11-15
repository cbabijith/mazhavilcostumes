/// Offline collection preparation tests: no real orders, stock or payments.
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/orders/models/order.dart';
import 'package:mobile/features/orders/viewmodels/order_payment_preparation.dart';
import 'package:mobile/features/orders/viewmodels/providers/order_provider.dart';

import '../support/order_return_fixtures.dart';
import 'order_adjustment_viewmodel_test.dart' show FakeAdjustmentRepository;

class LostResponseRepository extends FakeAdjustmentRepository {
  LostResponseRepository(super.latest);
  bool loseResponse = true;
  @override
  Future<Order> updateOrder(
    String id,
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    final result = await super.updateOrder(id, body, cancelToken: cancelToken);
    if (loseResponse) throw StateError('Response lost after saving');
    return result;
  }
}

void main() {
  late FakeAdjustmentRepository repository;
  late OrderPaymentPreparation preparation;
  Future<Order> save({double fee = 10, double discount = 0}) =>
      preparation.save(
        operations: OrderOperations(repository),
        orderId: repository.latest.id,
        lateFee: fee,
        discount: discount,
      );
  setUp(() {
    repository = FakeAdjustmentRepository(
      returnOrder(total: 80, paid: 80, discount: 0, quantity: 2),
    );
    preparation = OrderPaymentPreparation();
  });

  test(
    'fee makes paid ongoing rental collectable without touching items',
    () async {
      final result = await save();
      expect(result.totalAmount, 90);
      expect(result.amountPaid, 80);
      expect(result.lateFee, 10);
      expect(result.status, OrderStatus.ongoing);
      expect(result.items!.single.returnedQuantity ?? 0, 0);
      expect(
        repository.updates.single.keys,
        unorderedEquals(['total_amount', 'late_fee', 'notes']),
      );
    },
  );

  test('fee plus discount preserve existing amounts in one update', () async {
    repository.latest = returnOrder(total: 270, late: 50, discount: 15);
    final result = await save(fee: 25.5, discount: 10);
    expect(result.totalAmount, 285.5);
    expect(result.lateFee, 75.5);
    expect(result.discount, 25);
    expect(repository.updates, hasLength(1));
    expect(result.notes, contains('Late Fee: ₹25.50'));
    expect(result.notes, contains('Discount: ₹10.00'));
  });

  test(
    'net zero adjustments are still saved and not recorded as payment',
    () async {
      final result = await save(discount: 10);
      expect(result.totalAmount, 80);
      expect(result.lateFee, 10);
      expect(result.discount, 10);
      expect(result.amountPaid, 80);
      expect(repository.updates.single.containsKey('amount_paid'), isFalse);
    },
  );

  test('failed PATCH keeps the same absolute plan on retry', () async {
    repository.failSave = true;
    await expectLater(save(), throwsStateError);
    repository.failSave = false;
    final result = await save();
    expect(result.lateFee, 10);
    expect(repository.updates, hasLength(1));
  });

  test('lost response is reconciled without adding the fee again', () async {
    repository = LostResponseRepository(repository.latest);
    await expectLater(save(), throwsStateError);
    expect(repository.latest.lateFee, 10);
    final result = await save();
    expect(result.lateFee, 10);
    expect(repository.attempts, 1);
    expect(repository.updates, hasLength(1));
  });

  test('retry cannot overwrite a newer financial change', () async {
    repository.failSave = true;
    await expectLater(save(), throwsStateError);
    repository.failSave = false;
    repository.latest = returnOrder(total: 100, late: 20);
    await expectLater(save(), throwsStateError);
    expect(repository.updates, isEmpty);
    expect(repository.latest.lateFee, 20);
  });

  test('invalid drafts and finalized orders never write', () async {
    for (final fee in [-1.0, double.nan, double.infinity]) {
      await expectLater(save(fee: fee), throwsArgumentError);
    }
    for (final status in ['completed', 'cancelled']) {
      repository.latest = returnOrder(status: status);
      await expectLater(save(), throwsStateError);
    }
    expect(repository.updates, isEmpty);
  });
}
