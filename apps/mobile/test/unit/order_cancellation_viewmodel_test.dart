/// Cancellation request and validation tests using offline repositories only.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/orders/models/order.dart';
import 'package:mobile/features/orders/viewmodels/order_cancellation_viewmodel.dart';
import 'package:mobile/features/orders/viewmodels/providers/order_provider.dart';
import '../support/order_return_fixtures.dart';
import 'order_adjustment_viewmodel_test.dart' show FakeAdjustmentRepository;

void main() {
  late FakeAdjustmentRepository repository;
  late ProviderContainer container;
  late OrderCancellationViewModel model;
  var invalidations = 0;
  setUp(() {
    invalidations = 0;
    repository = FakeAdjustmentRepository(returnOrder(paid: 100));
    container = ProviderContainer(
      overrides: [
        orderOperationsProvider.overrideWithValue(
          OrderOperations(repository, onChanged: () => invalidations++),
        ),
      ],
    );
    container.listen(
      orderCancellationViewModelProvider(repository.latest.id),
      (_, _) {},
    );
    model = container.read(
      orderCancellationViewModelProvider(repository.latest.id).notifier,
    );
  });
  tearDown(() => container.dispose());

  test(
    'full, partial and no refund are one cancellation request without balance edits',
    () async {
      for (final refund in ['0', '25.01', '100']) {
        repository.latest = returnOrder(paid: 100);
        model.edit(
          reason: '  Event cancelled  ',
          refund: refund,
          mode: 'upi',
          stockReturned: true,
        );
        expect(await model.save(), isTrue);
        expect(repository.updates.last, {
          'status': 'cancelled',
          'cancellation_reason': 'Event cancelled',
          'refund_amount': double.parse(refund),
          'refund_payment_mode': 'upi',
          'stock_returned': true,
        });
      }
      expect(invalidations, 3);
    },
  );

  test(
    'reason, finite currency, current paid amount and physical stock are validated',
    () async {
      model.edit(reason: 'Event cancelled', stockReturned: true);
      for (final refund in [
        '',
        'abc',
        'NaN',
        'Infinity',
        '-1',
        '100.01',
        '0.001',
      ]) {
        model.edit(refund: refund);
        expect(await model.save(), isFalse, reason: refund);
      }
      model.edit(refund: '25', reason: '  ');
      expect(await model.save(), isFalse);
      model.edit(reason: 'Event cancelled', stockReturned: false);
      expect(await model.save(), isFalse);
      model.edit(stockReturned: true, refund: '100');
      repository.latest = returnOrder(paid: 20);
      expect(await model.save(), isFalse);
      expect(repository.updates, isEmpty);
      expect(invalidations, 0);
    },
  );

  test(
    'scheduled needs no stock confirmation; returned and completed are blocked',
    () async {
      model.edit(reason: 'Event cancelled');
      repository.latest = returnOrder(status: 'scheduled');
      expect(await model.save(), isTrue);
      for (final status in ['returned', 'completed', 'partial', 'flagged']) {
        repository.latest = returnOrder(status: status);
        expect(await model.save(), isFalse);
      }
      expect(repository.updates.length, 1);
      expect(returnOrder(status: 'in_use').canCancel, isTrue);
      expect(returnOrder(status: 'cancelled').canCancel, isFalse);
    },
  );

  test(
    'failed saves retain drafts and do not invalidate business reports',
    () async {
      model.edit(reason: 'Event cancelled', refund: '10', stockReturned: true);
      repository.failSave = true;
      expect(await model.save(), isFalse);
      final draft = container.read(
        orderCancellationViewModelProvider(repository.latest.id),
      );
      expect(draft.reason, 'Event cancelled');
      expect(draft.refund, '10');
      expect(draft.submission.hasError, isTrue);
      expect(invalidations, 0);
      repository.failSave = false;
      expect(await model.save(), isTrue);
    },
  );

  test(
    'a retry after a lost response lets the server handle cancelled status idempotently',
    () async {
      model.edit(reason: 'Event cancelled', refund: '10', stockReturned: true);
      repository.latest = Order.fromJson({
        ...repository.latest.toJson(),
        'status': 'cancelled',
      });
      expect(await model.save(), isTrue);
      expect(repository.updates.length, 1);
    },
  );
}
