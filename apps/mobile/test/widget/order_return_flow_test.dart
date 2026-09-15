/// Exercises the website-aligned mobile checklist without network writes.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/features/orders/models/order.dart';
import 'package:mobile/features/orders/repositories/order_repository.dart';
import 'package:mobile/features/orders/viewmodels/providers/order_provider.dart';
import 'package:mobile/features/orders/views/order_detail_view.dart';
import 'package:mobile/features/orders/widgets/order_return_footer.dart';

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
  int conditionSaves = 0;
  double? submittedDiscount;
  double? submittedLateFee;
  String? submittedNotes;

  @override
  Future<Order> getOrderById(String id, {CancelToken? cancelToken}) async =>
      order;

  @override
  Future<List<PaymentTransaction>> getOrderPayments(
    String orderId, {
    CancelToken? cancelToken,
  }) async => [];

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
      status: returned == 0 ? 'partial' : 'returned',
      total: order.totalAmount - (discount ?? 0),
      discount: order.discount + (discount ?? 0),
      late: lateFee ?? order.lateFee,
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

void main() {
  for (final savedLateFee in [0.0, 50.0]) {
    testWidgets('simple Good return preserves saved late fee $savedLateFee', (
      tester,
    ) async {
      final repository = FakeReturnRepository(savedLateFee: savedLateFee);
      await openOrder(tester, repository);
      final footer = find.byType(OrderReturnFooter);
      expect(
        find.descendant(of: footer, matching: find.byType(TextField)),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.projectedSettlement),
        savedLateFee > 0 ? findsOneWidget : findsNothing,
      );
      expect(find.text('Extra Late Fee (Optional)'), findsNothing);
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

  testWidgets(
    'Not Returned saves pending units and can later complete the return',
    (tester) async {
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
      expect(find.text('Confirm Partial Return'), findsOneWidget);
      await tapVisible(tester, find.text('Confirm & Save'));
      expect(repository.submissions.single.single['returned_quantity'], 0);
      expect(repository.submissions.single.single['damage_charges'], 0);
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
    },
  );

  testWidgets(
    'unmarked items must be checked; Mark All Good completes the checklist',
    (tester) async {
      final repository = FakeReturnRepository();
      await openOrder(tester, repository);
      await tapVisible(tester, find.text(AppStrings.savePartialReturn(1)));
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
        expect(find.text(AppStrings.savePartialReturn(1)), findsOneWidget);
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
