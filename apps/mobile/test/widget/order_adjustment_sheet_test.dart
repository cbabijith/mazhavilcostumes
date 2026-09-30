/// Offline interaction checks for the responsive financial adjustment sheet.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/features/orders/models/order_adjustment.dart';
import 'package:mobile/features/orders/viewmodels/providers/order_provider.dart';
import 'package:mobile/features/orders/widgets/order_adjustment_sheet.dart';

import '../support/order_return_fixtures.dart';
import '../unit/order_adjustment_viewmodel_test.dart'
    show FakeAdjustmentRepository;

Future<void> openSheet(
  WidgetTester tester,
  FakeAdjustmentRepository repository, {
  double width = 390,
  double textScale = 1,
  double keyboardInset = 0,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        orderOperationsProvider.overrideWithValue(OrderOperations(repository)),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            viewInsets: EdgeInsets.only(bottom: keyboardInset),
          ),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                final saved = await showModalBottomSheet<bool>(
                  context: context,
                  isDismissible: false,
                  enableDrag: false,
                  isScrollControlled: true,
                  builder: (_) =>
                      OrderAdjustmentSheet(order: repository.latest),
                );
                if (saved == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.adjustmentSaved)),
                  );
                }
              },
              child: const Text('Open sheet'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open sheet'));
  await tester.pumpAndSettle();
}

Future<void> selectType(WidgetTester tester, String label) async {
  await tester.tap(find.byType(DropdownButtonFormField<OrderAdjustmentType>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> apply(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, AppStrings.applyAdjustment);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('all four adjustment kinds are available', (tester) async {
    final repository = FakeAdjustmentRepository(returnOrder());
    await openSheet(tester, repository);
    await tester.tap(find.byType(DropdownButtonFormField<OrderAdjustmentType>));
    await tester.pumpAndSettle();
    for (final label in [
      AppStrings.returnDiscount,
      AppStrings.lateFee,
      AppStrings.damageFee,
      AppStrings.extraCharge,
    ]) {
      expect(find.text(label), findsWidgets);
    }
  });

  testWidgets('invalid input stays open without requests', (tester) async {
    final repository = FakeAdjustmentRepository(returnOrder());
    await openSheet(tester, repository);
    await tester.enterText(
      find.byKey(const ValueKey('adjustment-amount')),
      'NaN',
    );
    await apply(tester);
    expect(find.text(AppStrings.invalidFinancialAdjustment), findsOneWidget);
    expect(repository.reads, 0);
    expect(repository.updates, isEmpty);
  });

  testWidgets('late fee saves without fabricating a payment and closes', (
    tester,
  ) async {
    final repository = FakeAdjustmentRepository(returnOrder(late: 20));
    await openSheet(tester, repository);
    await selectType(tester, AppStrings.lateFee);
    await tester.enterText(
      find.byKey(const ValueKey('adjustment-amount')),
      '30',
    );
    await tester.enterText(
      find.byKey(const ValueKey('adjustment-notes')),
      'Overdue return',
    );
    await apply(tester);
    expect(repository.updates.single['late_fee'], 50);
    expect(repository.updates.single.containsKey('amount_paid'), isFalse);
    expect(find.byType(OrderAdjustmentSheet), findsNothing);
    expect(find.text(AppStrings.adjustmentSaved), findsOneWidget);
  });

  testWidgets('save failure retains amount, type and reason for retry', (
    tester,
  ) async {
    final repository = FakeAdjustmentRepository(returnOrder())..failSave = true;
    await openSheet(tester, repository);
    await selectType(tester, AppStrings.extraCharge);
    await tester.enterText(
      find.byKey(const ValueKey('adjustment-amount')),
      '45',
    );
    await tester.enterText(
      find.byKey(const ValueKey('adjustment-notes')),
      'Delivery',
    );
    await apply(tester);
    expect(find.textContaining('Save failed'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
    expect(find.text('Delivery'), findsOneWidget);
    expect(find.text(AppStrings.extraCharge), findsOneWidget);
    repository.failSave = false;
    await apply(tester);
    expect(repository.updates.single['total_amount'], 195);
    expect(
      repository.updates.single['notes'],
      'Extra Charge: ₹45.00 — Delivery',
    );
  });

  testWidgets('on-time warning applies only to a newly entered late fee', (
    tester,
  ) async {
    final due = DateTime.now().add(const Duration(days: 1));
    final repository = FakeAdjustmentRepository(
      returnOrder(late: 15, endDate: due.toIso8601String().split('T').first),
    );
    await openSheet(tester, repository);
    await selectType(tester, AppStrings.lateFee);
    expect(find.textContaining(AppStrings.onTimeReturnWarning), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('adjustment-amount')),
      '10',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining(AppStrings.onTimeReturnWarning), findsOneWidget);
    await selectType(tester, AppStrings.damageFee);
    expect(find.textContaining(AppStrings.onTimeReturnWarning), findsNothing);
  });

  testWidgets('busy saves disable editing, close and duplicate submission', (
    tester,
  ) async {
    final repository = FakeAdjustmentRepository(returnOrder());
    repository.pendingRead = Completer();
    await openSheet(tester, repository);
    await tester.enterText(
      find.byKey(const ValueKey('adjustment-amount')),
      '25',
    );
    final applyButton = find.widgetWithText(
      FilledButton,
      AppStrings.applyAdjustment,
    );
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('adjustment-amount')),
          )
          .enabled,
      isFalse,
    );
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, AppStrings.saving),
          )
          .onPressed,
      isNull,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(OrderAdjustmentSheet), findsOneWidget);
    expect(repository.reads, 1);
    repository.pendingRead!.complete(repository.latest);
    await tester.pumpAndSettle();
    expect(repository.updates, hasLength(1));
    expect(find.byType(OrderAdjustmentSheet), findsNothing);
  });

  testWidgets('small screens with large text and keyboard stay usable', (
    tester,
  ) async {
    final repository = FakeAdjustmentRepository(returnOrder());
    await openSheet(
      tester,
      repository,
      width: 320,
      textScale: 2,
      keyboardInset: 260,
    );
    await selectType(tester, AppStrings.damageFee);
    await tester.enterText(
      find.byKey(const ValueKey('adjustment-amount')),
      '25',
    );
    await apply(tester);
    expect(tester.takeException(), isNull);
    expect(repository.updates.single['damage_charges_total'], 25);
  });
}
