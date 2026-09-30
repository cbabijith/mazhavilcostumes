/// Offline checks for financial adjustment validation and persistence contracts.
library;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/features/orders/models/order.dart';
import 'package:mobile/features/orders/models/order_adjustment.dart';
import 'package:mobile/features/orders/repositories/order_repository.dart';
import 'package:mobile/features/orders/viewmodels/order_adjustment_viewmodel.dart';
import 'package:mobile/features/orders/viewmodels/providers/order_provider.dart';

import '../support/order_return_fixtures.dart';

class FakeAdjustmentRepository extends OrderRepository {
  FakeAdjustmentRepository(this.latest);

  Order latest;
  int reads = 0;
  int attempts = 0;
  bool failRead = false;
  bool failSave = false;
  Completer<Order>? pendingRead;
  final List<Map<String, Object?>> updates = [];

  @override
  Future<Order> getOrderById(String id, {CancelToken? cancelToken}) async {
    reads++;
    if (failRead) throw StateError('Read failed');
    return pendingRead == null ? latest : await pendingRead!.future;
  }

  @override
  Future<Order> updateOrder(
    String id,
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    attempts++;
    if (failSave) throw StateError('Save failed');
    updates.add(Map<String, Object?>.from(body));
    latest = Order.fromJson({...latest.toJson(), ...body});
    return latest;
  }
}

void main() {
  late FakeAdjustmentRepository repository;
  late ProviderContainer container;
  late OrderAdjustmentViewModel viewModel;
  var invalidations = 0;

  setUp(() {
    invalidations = 0;
    repository = FakeAdjustmentRepository(
      returnOrder(total: 200, late: 30, damage: 20),
    );
    container = ProviderContainer(
      overrides: [
        orderOperationsProvider.overrideWithValue(
          OrderOperations(repository, onChanged: () => invalidations++),
        ),
      ],
    );
    container.listen(
      orderAdjustmentViewModelProvider(repository.latest.id),
      (_, _) {},
    );
    viewModel = container.read(
      orderAdjustmentViewModelProvider(repository.latest.id).notifier,
    );
  });

  tearDown(() => container.dispose());

  test('invalid amounts never load or modify an order', () async {
    for (final input in [
      '',
      'abc',
      '-5',
      '0',
      'NaN',
      'Infinity',
      '1e400',
      '.001',
    ]) {
      viewModel.setAmount(input);
      expect(await viewModel.save(), isFalse, reason: input);
      expect(repository.reads, 0);
      expect(repository.updates, isEmpty);
    }
    expect(
      OrderAdjustmentViewModel.amountError('NaN'),
      AppStrings.invalidFinancialAdjustment,
    );
  });

  test('currency is rounded once and labels remain explicit in notes', () {
    final order = Order.fromJson({
      ...repository.latest.toJson(),
      'notes': 'Original booking note',
    });
    final body = OrderAdjustmentViewModel.updateBody(
      order: order,
      type: OrderAdjustmentType.lateFee,
      amount: 10.125,
      notes: '  One additional day  ',
    );
    expect(body['late_fee'], 40.13);
    expect(body['total_amount'], 210.13);
    expect(
      body['notes'],
      'Original booking note\nLate Fee: ₹10.13 — One additional day',
    );
  });

  for (final type in OrderAdjustmentType.values) {
    test(
      '$type uses latest amounts and never changes money collected',
      () async {
        viewModel.selectType(type);
        viewModel.setAmount('15');
        repository.latest = Order.fromJson({
          ...repository.latest.toJson(),
          'total_amount': 260,
          'late_fee': 60,
          'discount': 90,
          'damage_charges_total': 40,
          'payment_status': 'refund_waived',
        });
        expect(await viewModel.save(), isTrue);
        final body = repository.updates.single;
        expect(
          body['total_amount'],
          type == OrderAdjustmentType.discount ? 245 : 275,
        );
        expect(body.containsKey('amount_paid'), isFalse);
        expect(body.containsKey('payment_status'), isFalse);
        expect(repository.latest.amountPaid, 100);
        expect(repository.latest.paymentStatus, PaymentStatus.refundWaived);
        final field = switch (type) {
          OrderAdjustmentType.discount => 'discount',
          OrderAdjustmentType.lateFee => 'late_fee',
          OrderAdjustmentType.damageFee => 'damage_charges_total',
          OrderAdjustmentType.extraCharge => null,
        };
        if (field != null) {
          expect(body[field], switch (type) {
            OrderAdjustmentType.discount => 105,
            OrderAdjustmentType.lateFee => 75,
            OrderAdjustmentType.damageFee => 55,
            OrderAdjustmentType.extraCharge => 0,
          });
        } else {
          expect(body.keys, unorderedEquals(['total_amount', 'notes']));
        }
        expect(repository.reads, 1);
        expect(invalidations, 1);
      },
    );
  }

  test('stored percent-labelled discount is money and becomes flat', () async {
    repository.latest = Order.fromJson({
      ...repository.latest.toJson(),
      'discount_type': 'percent',
      'discount': 70,
      'subtotal': 1000,
    });
    viewModel.setAmount('10');
    expect(await viewModel.save(), isTrue);
    expect(repository.updates.single['discount'], 80);
    expect(repository.updates.single['discount_type'], 'flat');
    expect(repository.updates.single['total_amount'], 190);
  });

  test('discount cannot make the payable total negative', () async {
    viewModel.setAmount('1000');
    expect(await viewModel.save(), isTrue);
    expect(repository.updates.single['total_amount'], 0);
  });

  test('failed writes preserve the full draft and allow retry', () async {
    repository.failSave = true;
    viewModel.selectType(OrderAdjustmentType.damageFee);
    viewModel.setAmount('25');
    viewModel.setNotes('Broken accessory');
    expect(await viewModel.save(), isFalse);
    final draft = container.read(
      orderAdjustmentViewModelProvider(repository.latest.id),
    );
    expect(draft.type, OrderAdjustmentType.damageFee);
    expect(draft.amount, '25');
    expect(draft.notes, 'Broken accessory');
    expect(draft.submission.hasError, isTrue);
    expect(invalidations, 0);
    repository.failSave = false;
    expect(await viewModel.save(), isTrue);
    expect(repository.updates.single['damage_charges_total'], 45);
    expect(invalidations, 1);
  });

  test('failed fresh reads never submit a stale order total', () async {
    repository.failRead = true;
    viewModel.setAmount('25');
    expect(await viewModel.save(), isFalse);
    expect(repository.attempts, 0);
    expect(invalidations, 0);
  });

  test('duplicate taps and edits cannot change an in-flight draft', () async {
    repository.pendingRead = Completer<Order>();
    viewModel.selectType(OrderAdjustmentType.lateFee);
    viewModel.setAmount('25');
    final firstSave = viewModel.save();
    expect(await viewModel.save(), isFalse);
    viewModel.setAmount('99');
    repository.pendingRead!.complete(repository.latest);
    expect(await firstSave, isTrue);
    expect(repository.reads, 1);
    expect(repository.updates.single['late_fee'], 55);
  });

  test('only a positive new late fee warns on an on-time order', () {
    final dueDay = returnOrder(endDate: '2026-09-30');
    final now = DateTime(2026, 9, 30, 23, 59);
    viewModel.setAmount('10');
    expect(viewModel.showOnTimeWarning(dueDay, now: now), isFalse);
    viewModel.selectType(OrderAdjustmentType.lateFee);
    expect(viewModel.showOnTimeWarning(dueDay, now: now), isTrue);
    expect(
      viewModel.showOnTimeWarning(returnOrder(endDate: '2026-09-29'), now: now),
      isFalse,
    );
    viewModel.setAmount('0');
    expect(viewModel.showOnTimeWarning(dueDay, now: now), isFalse);
  });
}
