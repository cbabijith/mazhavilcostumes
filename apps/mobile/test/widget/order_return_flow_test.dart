/// Exercises the website-aligned mobile checklist without network writes.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/features/orders/models/order.dart';
import 'package:mobile/features/orders/models/order_adjustment.dart';
import 'package:mobile/features/orders/repositories/order_repository.dart';
import 'package:mobile/features/orders/viewmodels/providers/order_provider.dart';
import 'package:mobile/features/orders/views/order_detail_view.dart';
import 'package:mobile/features/orders/widgets/order_adjustment_sheet.dart';
import 'package:mobile/features/orders/widgets/order_return_footer.dart';
import 'package:mobile/features/orders/widgets/return_quantity_selector.dart';

import '../support/order_return_fixtures.dart';

class FakeReturnRepository extends OrderRepository {
  FakeReturnRepository({double savedLateFee = 0})
    : order = returnOrder(
        total: 220 + savedLateFee,
        discount: 0,
        late: savedLateFee,
      );

  Order order;
  final List<List<Map<String, dynamic>>> submissions = [];
  final List<Map<String, dynamic>> adjustments = [];
  final List<String> requests = [];
  int conditionSaves = 0;
  int paymentAttempts = 0;
  double? submittedDiscount;
  double? submittedLateFee;
  String? submittedNotes;

  @override
  Future<Order> getOrderById(String id, {CancelToken? cancelToken}) async {
    requests.add('GET');
    return order;
  }

  @override
  Future<Order> updateOrder(
    String id,
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    requests.add('PATCH');
    adjustments.add(Map.of(body));
    order = Order.fromJson({
      ...order.toJson(),
      // A missing inspection stays unmarked when the fake response is decoded.
      'items': [
        for (final item in order.items ?? <OrderItem>[])
          {...item.toJson(), 'condition_rating': item.conditionRating?.name},
      ],
      ...body,
    });
    return order;
  }

  @override
  Future<List<PaymentTransaction>> getOrderPayments(
    String orderId, {
    CancelToken? cancelToken,
  }) async => [];

  @override
  Future<Map<String, dynamic>> collectPayment({
    required String orderId,
    required double amount,
    required String paymentMode,
    String? paymentType,
    String? notes,
    CancelToken? cancelToken,
  }) async {
    paymentAttempts++;
    throw StateError('Payment requests must remain blocked in this fixture');
  }

  @override
  Future<void> updateOrderItemDamage({
    required String itemId,
    required String conditionRating,
    String? damageDescription,
    required double damageCharges,
    required int damagedQuantity,
    CancelToken? cancelToken,
  }) async {
    conditionSaves++;
  }

  @override
  Future<Order> processReturn({
    required String orderId,
    required List<Map<String, dynamic>> items,
    String? notes,
    double? lateFee,
    double? discount,
    CancelToken? cancelToken,
  }) async {
    submissions.add(items);
    submittedDiscount = discount;
    submittedLateFee = lateFee;
    submittedNotes = notes;
    final returned = items.single['returned_quantity'] as int;
    order = returnOrder(
      status: returned < order.items!.single.quantity ? 'partial' : 'returned',
      quantity: order.items!.single.quantity,
      total:
          order.totalAmount +
          (lateFee ?? order.lateFee) -
          order.lateFee -
          (discount ?? 0),
      discount: order.discount + (discount ?? 0),
      late: lateFee ?? order.lateFee,
      endDate: order.endDate,
      condition: items.single['condition_rating'] as String,
      returned: true,
      returnedQuantity: returned,
    );
    return order;
  }
}

Future<void> openOrder(
  WidgetTester tester,
  FakeReturnRepository repository,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [orderRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(home: OrderDetailView(order: repository.order)),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void expectMoneyRow(Finder scope, String label, String value) {
  final row = find
      .ancestor(
        of: find.descendant(of: scope, matching: find.text(label)),
        matching: find.byType(Row),
      )
      .first;
  expect(find.descendant(of: row, matching: find.text(value)), findsOneWidget);
}

Future<void> applyLateFeeAdjustment(
  WidgetTester tester,
  String amount,
  String reason,
) async {
  await tapVisible(tester, find.text(AppStrings.adjust));
  await tapVisible(
    tester,
    find.byType(DropdownButtonFormField<OrderAdjustmentType>),
  );
  await tapVisible(tester, find.text(AppStrings.lateFee).last);
  final amountField = find.byKey(const ValueKey('adjustment-amount'));
  final reasonField = find.byKey(const ValueKey('adjustment-notes'));
  await tester.ensureVisible(amountField);
  await tester.enterText(amountField, amount);
  await tester.ensureVisible(reasonField);
  await tester.enterText(reasonField, reason);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tapVisible(
    tester,
    find.widgetWithText(FilledButton, AppStrings.applyAdjustment),
  );
}

void main() {
  testWidgets(
    'return count can split a line across visits without double counting',
    (tester) async {
      final repository = FakeReturnRepository()
        ..order = returnOrder(quantity: 3);
      await openOrder(tester, repository);
      final selector = find.byType(ReturnQuantitySelector);
      final count = find.descendant(
        of: selector,
        matching: find.byType(TextField),
      );
      expect(tester.widget<TextField>(count).controller!.text, '3');
      expect(find.text(AppStrings.partialReturn), findsNothing);
      await tapVisible(
        tester,
        find.widgetWithText(OutlinedButton, AppStrings.returnGood),
      );
      await tapVisible(
        tester,
        find.byTooltip(AppStrings.decreaseReturnQuantity),
      );
      await tapVisible(
        tester,
        find.byTooltip(AppStrings.decreaseReturnQuantity),
      );
      expect(tester.widget<TextField>(count).controller!.text, '1');
      expect(find.text(AppStrings.savePartialReturn(2)), findsOneWidget);
      await tapVisible(tester, find.text(AppStrings.savePartialReturn(2)));
      expect(find.text('1 (1 Good, 0 Damaged)'), findsOneWidget);
      await tapVisible(tester, find.text('Confirm & Save'));
      expect(repository.submissions.single.single['returned_quantity'], 1);
      expect(find.text(AppStrings.unitsOut(2)), findsOneWidget);
      expect(tester.widget<TextField>(count).controller!.text, '2');
      await tapVisible(
        tester,
        find.byTooltip(AppStrings.decreaseReturnQuantity),
      );
      await tapVisible(tester, find.text(AppStrings.savePartialReturn(1)));
      await tapVisible(tester, find.text('Confirm & Save'));
      expect(repository.submissions.last.single['returned_quantity'], 2);
      expect(selector, findsNothing);
      await tapVisible(tester, find.text(AppStrings.completeReturn));
      await tapVisible(tester, find.text('Confirm & Complete'));
      expect(repository.submissions.last.single['returned_quantity'], 3);
      expect(find.byType(OrderReturnFooter), findsNothing);
    },
  );

  testWidgets(
    'quantity entry clamps damage, blocks zero, and Mark All Good resets count',
    (tester) async {
      final repository = FakeReturnRepository()
        ..order = returnOrder(quantity: 3);
      await openOrder(tester, repository);
      final selector = find.byType(ReturnQuantitySelector);
      final count = find.descendant(
        of: selector,
        matching: find.byType(TextField),
      );
      await tapVisible(
        tester,
        find.widgetWithText(OutlinedButton, AppStrings.returnDamaged),
      );
      await tester.ensureVisible(count);
      await tester.enterText(count, '2');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DropdownButton<int>>(find.byType(DropdownButton<int>))
            .value,
        2,
      );
      await tester.enterText(count, '99');
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(count).controller!.text, '3');
      await tester.enterText(count, '0');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text(AppStrings.savePartialReturn(3)));
      expect(find.text(AppStrings.invalidReturnCount), findsOneWidget);
      expect(repository.submissions, isEmpty);
      await tapVisible(
        tester,
        find.widgetWithText(OutlinedButton, AppStrings.notReturned),
      );
      expect(tester.widget<TextField>(count).enabled, isFalse);
      await tapVisible(tester, find.text('Mark All Good'));
      expect(tester.widget<TextField>(count).controller!.text, '3');
      expect(find.text(AppStrings.partialReturn), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'footer payment due opens collection with the live discounted balance',
    (tester) async {
      final repository = FakeReturnRepository();
      await openOrder(tester, repository);
      final banner = find.byKey(const ValueKey('return-payment-due'));
      expect(find.text(AppStrings.paymentDue(120)), findsOneWidget);
      final discount = find.byKey(const ValueKey('return-discount'));
      await tester.ensureVisible(discount);
      await tester.enterText(discount, '20');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.paymentDue(100)), findsOneWidget);
      await tapVisible(
        tester,
        find.descendant(
          of: banner,
          matching: find.text(AppStrings.collectPayment),
        ),
      );
      final amount = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextField),
      );
      expect(tester.widget<TextField>(amount).controller!.text, '100.00');
      expect(repository.submissions, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('new return controls fit a narrow screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final discount = TextEditingController();
    addTearDown(discount.dispose);
    final lateFee = TextEditingController();
    addTearDown(lateFee.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 844),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ReturnQuantitySelector(
                      count: 1,
                      outstanding: 3,
                      status: 'good',
                      onChanged: (_) {},
                    ),
                    OrderReturnFooter(
                      pendingUnits: 2,
                      balanceDue: 240,
                      discountController: discount,
                      onDiscountChanged: (_) {},
                      lateFeeController: lateFee,
                      onLateFeeChanged: (_) {},
                      onSubmit: () {},
                      onCollectPayment: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.returningNow), findsOneWidget);
    expect(find.byKey(const ValueKey('return-late-fee')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final savedLateFee in [0.0, 50.0]) {
    testWidgets('simple Good return preserves saved late fee $savedLateFee', (
      tester,
    ) async {
      final repository = FakeReturnRepository(savedLateFee: savedLateFee);
      await openOrder(tester, repository);
      final footer = find.byType(OrderReturnFooter);
      expect(
        find.descendant(of: footer, matching: find.byType(TextField)),
        findsNWidgets(2),
      );
      expect(
        find.text(AppStrings.projectedSettlement),
        savedLateFee > 0 ? findsOneWidget : findsNothing,
      );
      expect(find.byKey(const ValueKey('return-late-fee')), findsOneWidget);
      expect(find.text('Return Notes (optional)'), findsNothing);
      expect(find.text('DISCOUNT'), findsOneWidget);
      final discount = find.byKey(const ValueKey('return-discount'));
      await tester.ensureVisible(discount);
      await tester.enterText(discount, '70');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tapVisible(
        tester,
        find.widgetWithText(OutlinedButton, AppStrings.returnGood),
      );
      expect(repository.conditionSaves, 0);
      expect(repository.submissions, isEmpty);
      expect(find.text('Save Condition'), findsNothing);
      expect(find.text(AppStrings.partialReturn), findsNothing);
      expect(tester.widget<TextField>(discount).controller!.text, '70');
      await tapVisible(tester, find.text(AppStrings.completeReturn));
      expect(find.text('Confirm & Complete Return'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('₹${(150 + savedLateFee).toStringAsFixed(2)}'),
        ),
        findsOneWidget,
      );
      await tapVisible(tester, find.text('Confirm & Complete'));
      expect(repository.submissions.single.single['returned_quantity'], 1);
      expect(repository.submittedDiscount, 70);
      expect(repository.submittedLateFee, savedLateFee);
      expect(repository.submittedNotes, isNull);
      expect(find.byType(OrderReturnFooter), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('new late fee updates preview, receipt and saved return once', (
    tester,
  ) async {
    final repository = FakeReturnRepository(savedLateFee: 50);
    await openOrder(tester, repository);
    final lateFee = find.byKey(const ValueKey('return-late-fee'));
    final discount = find.byKey(const ValueKey('return-discount'));
    await tester.ensureVisible(lateFee);
    await tester.enterText(lateFee, '25.50');
    await tester.ensureVisible(discount);
    await tester.enterText(discount, '10');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final preview = find.byKey(const ValueKey('return-settlement-preview'));
    final receipt = find.byKey(const ValueKey('financial-receipt'));
    expectMoneyRow(preview, 'Base Order Total', '₹220.00');
    expectMoneyRow(preview, '+ Late Fee', '+₹75.50');
    expectMoneyRow(preview, 'New Total', '₹285.50');
    expectMoneyRow(preview, 'Balance Due', '₹185.50');
    expectMoneyRow(receipt, 'Late Fee', '₹75.50');
    expectMoneyRow(receipt, 'Initial Late Fee', '₹50.00');
    expectMoneyRow(receipt, 'Additional Late Fee', '₹25.50');
    expectMoneyRow(receipt, AppStrings.grandTotal, '₹285.50');
    expectMoneyRow(receipt, 'Balance Due', '₹185.50');
    expect(find.text(AppStrings.paymentDue(185.5)), findsOneWidget);
    expect(repository.order.lateFee, 50);
    expect(repository.order.totalAmount, 270);
    expect(repository.submissions, isEmpty);

    await tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, AppStrings.returnGood),
    );
    await tapVisible(tester, find.text(AppStrings.completeReturn));
    final confirmation = find.byType(AlertDialog);
    expectMoneyRow(confirmation, 'New Total', '₹285.50');
    expectMoneyRow(confirmation, 'Balance Due', '₹185.50');
    await tapVisible(tester, find.text('Confirm & Complete'));
    expect(repository.submittedLateFee, 75.5);
    expect(repository.submittedDiscount, 10);
    expect(repository.order.lateFee, 75.5);
    expect(repository.order.totalAmount, 285.5);
    expect(find.byType(OrderReturnFooter), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('collection amount and upper limit include the draft late fee', (
    tester,
  ) async {
    final repository = FakeReturnRepository(savedLateFee: 50);
    await openOrder(tester, repository);
    final lateFee = find.byKey(const ValueKey('return-late-fee'));
    final discount = find.byKey(const ValueKey('return-discount'));
    await tester.ensureVisible(lateFee);
    await tester.enterText(lateFee, '25.50');
    await tester.ensureVisible(discount);
    await tester.enterText(discount, '10');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final banner = find.byKey(const ValueKey('return-payment-due'));
    await tapVisible(
      tester,
      find.descendant(
        of: banner,
        matching: find.text(AppStrings.collectPayment),
      ),
    );
    final amount = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(amount).controller!.text, '185.50');
    await tester.enterText(amount, '185.51');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tapVisible(tester, find.text('Record Payment'));
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      find.text('Warning: Amount exceeds balance due of ₹186'),
      findsOneWidget,
    );
    expect(repository.paymentAttempts, 0);
    expect(repository.order.totalAmount, 270);
    expect(repository.submissions, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('partial return clears the new fee before the next visit', (
    tester,
  ) async {
    final repository = FakeReturnRepository(savedLateFee: 50)
      ..order = returnOrder(quantity: 2, total: 270, discount: 0, late: 50);
    await openOrder(tester, repository);
    final lateFee = find.byKey(const ValueKey('return-late-fee'));
    await tester.ensureVisible(lateFee);
    await tester.enterText(lateFee, '20');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, AppStrings.returnGood),
    );
    await tapVisible(tester, find.byTooltip(AppStrings.decreaseReturnQuantity));
    await tapVisible(tester, find.text(AppStrings.savePartialReturn(1)));
    await tapVisible(tester, find.text('Confirm & Save'));
    expect(repository.submittedLateFee, 70);
    expect(repository.order.totalAmount, 290);
    expect(tester.widget<TextField>(lateFee).controller!.text, '');
    expectMoneyRow(
      find.byKey(const ValueKey('return-settlement-preview')),
      '+ Late Fee',
      '+₹70.00',
    );
    await tapVisible(tester, find.text(AppStrings.completeReturn));
    await tapVisible(tester, find.text('Confirm & Complete'));
    expect(repository.submittedLateFee, 70);
    expect(repository.order.totalAmount, 290);
    expect(repository.submissions, hasLength(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('on-time warning applies only to a new additional fee', (
    tester,
  ) async {
    final repository = FakeReturnRepository(savedLateFee: 50)
      ..order = returnOrder(
        total: 270,
        discount: 0,
        late: 50,
        endDate: '9999-12-31',
      );
    await openOrder(tester, repository);
    final warning = find.text('ON-TIME RETURN WARNING');
    final lateFee = find.byKey(const ValueKey('return-late-fee'));
    expect(warning, findsNothing);
    await tester.ensureVisible(lateFee);
    await tester.enterText(lateFee, '20');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(warning, findsOneWidget);
    expect(
      find.text(
        'This order is returned on-time. Extra late fee of ₹20.00 is being applied.',
      ),
      findsOneWidget,
    );
    await tester.enterText(lateFee, '');
    await tester.pumpAndSettle();
    expect(warning, findsNothing);
    expect(repository.submissions, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('overdue return permits extra fee without an on-time warning', (
    tester,
  ) async {
    final repository = FakeReturnRepository()
      ..order = returnOrder(endDate: '2000-01-01');
    await openOrder(tester, repository);
    final lateFee = find.byKey(const ValueKey('return-late-fee'));
    await tester.ensureVisible(lateFee);
    await tester.enterText(lateFee, '20');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('ON-TIME RETURN WARNING'), findsNothing);
    expectMoneyRow(
      find.byKey(const ValueKey('return-settlement-preview')),
      '+ Late Fee',
      '+₹20.00',
    );
    expect(tester.takeException(), isNull);
  });

  for (final invalid in ['-1', 'NaN', 'Infinity']) {
    testWidgets('invalid late fee $invalid blocks return and collection', (
      tester,
    ) async {
      final repository = FakeReturnRepository();
      await openOrder(tester, repository);
      await tapVisible(
        tester,
        find.widgetWithText(OutlinedButton, AppStrings.returnGood),
      );
      final lateFee = find.byKey(const ValueKey('return-late-fee'));
      await tester.ensureVisible(lateFee);
      await tester.enterText(lateFee, invalid);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tapVisible(tester, find.text(AppStrings.completeReturn));
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(repository.submissions, isEmpty);
      final banner = find.byKey(const ValueKey('return-payment-due'));
      await tapVisible(
        tester,
        find.descendant(
          of: banner,
          matching: find.text(AppStrings.collectPayment),
        ),
      );
      expect(find.byType(BottomSheet), findsNothing);
      expect(repository.paymentAttempts, 0);
      expect(repository.order.lateFee, 0);
      expect(tester.widget<TextField>(lateFee).controller!.text, invalid);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Adjust refreshes a saved late fee and Good return keeps it once',
    (tester) async {
      final repository = FakeReturnRepository(savedLateFee: 50);
      await openOrder(tester, repository);
      repository.requests.clear();
      await applyLateFeeAdjustment(tester, '25', 'Returned late');
      expect(repository.requests.take(2), ['GET', 'PATCH']);
      expect(repository.requests.last, 'GET');
      expect(repository.adjustments, hasLength(1));
      expect(repository.adjustments.single['late_fee'], 75);
      expect(
        repository.adjustments.single['notes'],
        'Late Fee: ₹25.00 — Returned late',
      );
      expect(repository.adjustments.single.containsKey('amount_paid'), isFalse);
      expect(repository.paymentAttempts, 0);
      expect(repository.order.amountPaid, 100);
      expect(repository.order.customer?.id, 'test-customer');
      expect(repository.order.items?.single.id, 'test-item');
      expect(repository.order.items?.single.conditionRating, isNull);
      expect(find.byType(OrderAdjustmentSheet), findsNothing);
      final receipt = find.byKey(const ValueKey('financial-receipt'));
      expectMoneyRow(receipt, 'Late Fee', '₹75.00');
      expectMoneyRow(receipt, AppStrings.grandTotal, '₹295.00');
      expectMoneyRow(receipt, 'Balance Due', '₹195.00');
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('return-late-fee')))
            .controller!
            .text,
        '',
      );
      await tapVisible(
        tester,
        find.widgetWithText(OutlinedButton, AppStrings.returnGood),
      );
      await tapVisible(tester, find.text(AppStrings.completeReturn));
      expectMoneyRow(find.byType(AlertDialog), 'New Total', '₹295.00');
      await tapVisible(tester, find.text('Confirm & Complete'));
      expect(repository.submittedLateFee, 75);
      expect(repository.submittedDiscount, 0);
      expect(repository.order.totalAmount, 295);
      expect(repository.order.lateFee, 75);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Adjust cancellation and saving keep pending return drafts', (
    tester,
  ) async {
    final repository = FakeReturnRepository(savedLateFee: 50);
    await openOrder(tester, repository);
    final lateFee = find.byKey(const ValueKey('return-late-fee'));
    final discount = find.byKey(const ValueKey('return-discount'));
    await tester.ensureVisible(lateFee);
    await tester.enterText(lateFee, '20');
    await tester.ensureVisible(discount);
    await tester.enterText(discount, '10');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tapVisible(tester, find.text(AppStrings.adjust));
    await tester.enterText(
      find.byKey(const ValueKey('adjustment-amount')),
      '99',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tapVisible(
      tester,
      find.descendant(
        of: find.byType(OrderAdjustmentSheet),
        matching: find.widgetWithText(OutlinedButton, 'Cancel'),
      ),
    );
    expect(repository.adjustments, isEmpty);
    expect(repository.order.totalAmount, 270);
    expect(repository.order.lateFee, 50);
    expect(tester.widget<TextField>(lateFee).controller!.text, '20');
    expect(tester.widget<TextField>(discount).controller!.text, '10');

    await applyLateFeeAdjustment(tester, '25', 'Counter adjustment');
    expect(find.byType(OrderAdjustmentSheet), findsNothing);
    expect(repository.order.totalAmount, 295);
    expect(repository.order.lateFee, 75);
    expect(tester.widget<TextField>(lateFee).controller!.text, '20');
    expect(tester.widget<TextField>(discount).controller!.text, '10');
    final receipt = find.byKey(const ValueKey('financial-receipt'));
    expectMoneyRow(receipt, 'Late Fee', '₹95.00');
    expectMoneyRow(receipt, 'Initial Late Fee', '₹75.00');
    expectMoneyRow(receipt, 'Additional Late Fee', '₹20.00');
    expectMoneyRow(receipt, AppStrings.grandTotal, '₹305.00');
    await tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, AppStrings.returnGood),
    );
    await tapVisible(tester, find.text(AppStrings.completeReturn));
    await tapVisible(tester, find.text('Confirm & Complete'));
    expect(repository.submittedLateFee, 95);
    expect(repository.submittedDiscount, 10);
    expect(repository.order.totalAmount, 305);
    expect(repository.paymentAttempts, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Not Returned alone is blocked; Good can complete the return', (
    tester,
  ) async {
    final repository = FakeReturnRepository();
    await openOrder(tester, repository);
    await tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, AppStrings.notReturned),
    );
    expect(find.text(AppStrings.partialReturn), findsOneWidget);
    expect(find.text(AppStrings.savePartialReturn(1)), findsOneWidget);
    expect(repository.submissions, isEmpty);
    await tapVisible(tester, find.text(AppStrings.savePartialReturn(1)));
    expect(find.text(AppStrings.noItemsReturned), findsOneWidget);
    expect(repository.submissions, isEmpty);
    expect(find.text(AppStrings.savePartialReturn(1)), findsOneWidget);
    expect(find.text('Good Condition Saved'), findsNothing);
    await tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, AppStrings.returnGood),
    );
    expect(find.text(AppStrings.partialReturn), findsNothing);
    await tapVisible(tester, find.text(AppStrings.completeReturn));
    await tapVisible(tester, find.text('Confirm & Complete'));
    expect(repository.submissions.last.single['returned_quantity'], 1);
    expect(find.byType(OrderReturnFooter), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'unmarked items must be checked; Mark All Good completes the checklist',
    (tester) async {
      final repository = FakeReturnRepository();
      await openOrder(tester, repository);
      expect(find.text(AppStrings.partialReturn), findsNothing);
      await tapVisible(tester, find.text(AppStrings.completeReturn));
      expect(find.text(AppStrings.incompleteCheckup), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(repository.submissions, isEmpty);
      await tapVisible(tester, find.text('Mark All Good'));
      expect(find.text(AppStrings.partialReturn), findsNothing);
      expect(find.text(AppStrings.completeReturn), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('damage details appear only for Damaged', (tester) async {
    final repository = FakeReturnRepository();
    await openOrder(tester, repository);
    expect(find.text('Damage Notes'), findsNothing);
    await tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, AppStrings.returnDamaged),
    );
    expect(find.text('Damage Notes'), findsOneWidget);
    await tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, AppStrings.notReturned),
    );
    expect(find.text('Damage Notes'), findsNothing);
    expect(find.text(AppStrings.savePartialReturn(1)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final paid in [100.0, 150.0]) {
    testWidgets('discount updates preview and receipt live with $paid paid', (
      tester,
    ) async {
      final repository = FakeReturnRepository()
        ..order = returnOrder(total: 150, discount: 70, paid: paid);
      await openOrder(tester, repository);
      final preview = find.byKey(const ValueKey('return-settlement-preview'));
      final receipt = find.byKey(const ValueKey('financial-receipt'));
      final discount = find.byKey(const ValueKey('return-discount'));

      void expectRow(Finder scope, String label, String value) {
        final row = find
            .ancestor(
              of: find.descendant(of: scope, matching: find.text(label)),
              matching: find.byType(Row),
            )
            .first;
        expect(
          find.descendant(of: row, matching: find.text(value)),
          findsOneWidget,
        );
      }

      expect(preview, findsNothing);
      for (final input in ['10', '35.50']) {
        await tester.ensureVisible(discount);
        await tester.enterText(discount, input);
        await tester.pumpAndSettle();
        final adjustment = double.parse(input);
        final total = 150 - adjustment;
        final balance = (total - paid).clamp(0, double.infinity);
        expect(preview, findsOneWidget);
        expectRow(preview, 'Base Order Total', '₹150.00');
        expectRow(preview, '− Discount', '−₹${adjustment.toStringAsFixed(2)}');
        expectRow(preview, 'New Total', '₹${total.toStringAsFixed(2)}');
        expectRow(preview, 'Less: Paid', '−₹${paid.toStringAsFixed(2)}');
        expectRow(preview, 'Balance Due', '₹${balance.toStringAsFixed(2)}');
        expectRow(
          receipt,
          AppStrings.orderDiscount,
          '-₹${(70 + adjustment).toStringAsFixed(2)}',
        );
        expectRow(receipt, AppStrings.initialDiscount, '-₹70.00');
        expectRow(
          receipt,
          AppStrings.returnSettlementDiscount,
          '-₹${adjustment.toStringAsFixed(2)}',
        );
        expectRow(
          receipt,
          AppStrings.grandTotal,
          '₹${total.toStringAsFixed(2)}',
        );
        expectRow(receipt, 'Balance Due', '₹${balance.toStringAsFixed(2)}');
        expect(find.text(AppStrings.completeReturn), findsOneWidget);
      }

      for (final cleared in ['0', '', 'NaN']) {
        await tester.ensureVisible(discount);
        await tester.enterText(discount, cleared);
        await tester.pumpAndSettle();
        expect(preview, findsNothing);
        expect(find.text(AppStrings.returnSettlementDiscount), findsNothing);
        expectRow(receipt, AppStrings.orderDiscount, '-₹70.00');
        expectRow(receipt, AppStrings.grandTotal, '₹150.00');
      }
      expect(repository.order.totalAmount, 150);
      expect(repository.order.discount, 70);
      expect(repository.submissions, isEmpty);
      expect(repository.conditionSaves, 0);
      expect(tester.takeException(), isNull);
    });
  }
}
