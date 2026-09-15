/// Regression tests for mobile inspection recovery and return money previews.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/orders/models/order.dart';
import 'package:mobile/features/orders/viewmodels/order_return_viewmodel.dart';

import '../support/order_return_fixtures.dart';

void main() {
  const viewModel = OrderReturnViewModel();

  test('saved order discount is not deducted from the preview again', () {
    expect(viewModel.settlement(returnOrder()).total, 150);
  });

  test('a genuinely new return discount is applied once', () {
    expect(
      viewModel.settlement(returnOrder(), additionalDiscount: 70).total,
      80,
    );
    expect(
      viewModel
          .settlement(
            returnOrder(total: 220, discount: 0),
            additionalDiscount: 70,
          )
          .total,
      150,
    );
  });

  test('preview preserves existing late fee and adds only the new fee', () {
    final result = viewModel.settlement(
      returnOrder(total: 200, late: 50),
      additionalLateFee: 20,
    );
    expect(result.total, 220);
    expect(result.lateFees, 70);
  });

  test('damage changes replace previous damage charges', () {
    final order = returnOrder(total: 180, damage: 30);
    expect(viewModel.settlement(order, damageFees: 50).total, 200);
    expect(viewModel.settlement(order, damageFees: 0).total, 150);
  });

  test('payment limit includes pending damage and return discounts', () {
    final result = viewModel.settlement(
      returnOrder(),
      damageFees: 50,
      additionalDiscount: 10,
    );
    expect(result.total, 190);
    expect(result.balanceDue, 90);
  });

  test('settled order summary keeps the saved total including its fees', () {
    final result = viewModel.settlement(
      returnOrder(status: 'returned', total: 200, late: 30, damage: 20),
    );
    expect(result.total, 200);
    expect(result.discount, 0);
  });

  test('balance never becomes negative and money is rounded to cents', () {
    expect(viewModel.settlement(returnOrder(paid: 200)).balanceDue, 0);
    expect(
      viewModel
          .settlement(
            returnOrder(total: 150.1),
            additionalLateFee: 1,
            additionalDiscount: 0.8,
          )
          .total,
      150.3,
    );
  });

  for (final condition in ['excellent', 'damaged']) {
    test('restores saved $condition inspection before physical return', () {
      final item = returnOrder(condition: condition).items!.single;
      expect(
        viewModel.inspectionFor(item)['status'],
        condition == 'excellent' ? 'good' : 'damaged',
      );
    });
  }

  test('refresh preserves unsaved inspection edits', () {
    final order = returnOrder();
    final draft = viewModel.inspectionFor(order.items!.single)
      ..['status'] = 'damaged'
      ..['damage_fee'] = 50.0
      ..['notes'] = 'Torn seam';
    final merged = viewModel.mergeInspections(
      updated: returnOrder(),
      previous: order,
      local: {'test-item': draft},
    );
    expect(merged['test-item'], draft);
  });

  test(
    'refresh picks up remote changes when local inspection is untouched',
    () {
      final order = returnOrder();
      final merged = viewModel.mergeInspections(
        updated: returnOrder(condition: 'damaged', damage: 40),
        previous: order,
        local: {'test-item': viewModel.inspectionFor(order.items!.single)},
      );
      expect(merged['test-item']!['status'], 'damaged');
      expect(merged['test-item']!['damage_fee'], 40);
    },
  );

  test('completed return discards stale inspection draft', () {
    final order = returnOrder();
    final merged = viewModel.mergeInspections(
      updated: returnOrder(
        status: 'returned',
        condition: 'excellent',
        returned: true,
      ),
      previous: order,
      local: {
        'test-item': {'status': 'damaged', 'damage_fee': 50.0},
      },
    );
    expect(merged['test-item']!['status'], 'good');
    expect(merged['test-item']!['damage_fee'], 0);
  });

  test('return actions match API status restrictions', () {
    final allowed = OrderStatus.values.where(viewModel.canReturn).toSet();
    expect(allowed, {
      OrderStatus.ongoing,
      OrderStatus.inUse,
      OrderStatus.partial,
    });
  });

  test(
    'invalid adjustment input does not crash previews and blocks submission',
    () {
      for (final invalid in ['-1', 'NaN', 'Infinity', 'wrong']) {
        expect(viewModel.previewAmount(invalid), 0);
        expect(viewModel.adjustmentError(invalid), isNotNull);
      }
      expect(viewModel.adjustmentError('70'), isNull);
      expect(viewModel.adjustmentError(''), isNull);
    },
  );

  test('Not Returned sends zero units and keeps the rent unchanged', () {
    final order = returnOrder(quantity: 2);
    final draft = {
      'test-item': <String, Object?>{'status': 'missing'},
    };
    expect(viewModel.pendingUnits(order.items!, draft), 2);
    final payload = viewModel.returnPayload(order.items!, draft).single;
    expect(payload['returned_quantity'], 0);
    expect(payload['damage_charges'], 0);
    expect(viewModel.settlement(order).total, 150);
  });

  test(
    'partial return restores pending state and never reduces received units',
    () {
      final order = returnOrder(
        status: 'partial',
        quantity: 3,
        returned: true,
        returnedQuantity: 1,
        condition: 'excellent',
      );
      final draft = {'test-item': viewModel.inspectionFor(order.items!.single)};
      expect(draft['test-item']!['status'], 'missing');
      expect(viewModel.pendingUnits(order.items!, draft), 2);
      expect(
        viewModel
            .returnPayload(order.items!, draft)
            .single['returned_quantity'],
        1,
      );
      draft['test-item']!['status'] = 'good';
      expect(viewModel.pendingUnits(order.items!, draft), 0);
      expect(
        viewModel
            .returnPayload(order.items!, draft)
            .single['returned_quantity'],
        3,
      );
    },
  );

  test('zero returned quantity overrides the legacy is_returned flag', () {
    final item = returnOrder(
      status: 'partial',
      returned: true,
      returnedQuantity: 0,
      condition: 'excellent',
    ).items!.single;
    expect(viewModel.inspectionFor(item)['status'], 'missing');
    expect(viewModel.receivedQuantity(item), 0);
  });

  test('pending units preserve damage already charged for received units', () {
    final order = returnOrder(
      status: 'partial',
      quantity: 2,
      returned: true,
      returnedQuantity: 1,
      condition: 'damaged',
      damage: 30,
      total: 180,
    );
    final draft = {'test-item': viewModel.inspectionFor(order.items!.single)};
    final damage = viewModel.inspectionDamage(order.items!, draft);
    expect(damage, 30);
    expect(viewModel.settlement(order, damageFees: damage).total, 180);
    expect(
      viewModel.returnPayload(order.items!, draft).single['damage_charges'],
      30,
    );
  });
}
