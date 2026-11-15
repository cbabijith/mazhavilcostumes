/// Staff order-detail cancellation integration and responsive sheet interactions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/features/orders/viewmodels/providers/order_provider.dart';
import 'package:mobile/features/orders/widgets/order_cancellation_sheet.dart';
import '../support/order_return_fixtures.dart';
import '../unit/order_adjustment_viewmodel_test.dart'
    show FakeAdjustmentRepository;
import 'order_return_flow_test.dart'
    show FakeReturnRepository, openOrder, tapVisible;

Future<void> openSheet(
  WidgetTester tester,
  FakeAdjustmentRepository repository,
) async {
  tester.view.physicalSize = const Size(320, 680);
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
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                builder: (_) =>
                    OrderCancellationSheet(order: repository.latest),
              ),
              child: const Text('Open cancellation'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open cancellation'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'staff can cancel an ongoing order through the real details page',
    (tester) async {
      final repository = FakeReturnRepository();
      await openOrder(
        tester,
        repository,
      ); // Authenticated fixture is a staff member.
      await tapVisible(tester, find.text('Cancel').first);
      expect(find.byType(OrderCancellationSheet), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('cancellation-reason')),
        'Event cancelled',
      );
      await tester.enterText(
        find.byKey(const ValueKey('cancellation-refund')),
        '25.01',
      );
      await tapVisible(tester, find.byType(CheckboxListTile));
      await tapVisible(
        tester,
        find.widgetWithText(FilledButton, AppStrings.cancelOrder),
      );
      expect(repository.adjustments.single, {
        'status': 'cancelled',
        'cancellation_reason': 'Event cancelled',
        'refund_amount': 25.01,
        'refund_payment_mode': 'cash',
        'stock_returned': true,
      });
      expect(find.byType(OrderCancellationSheet), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'invalid input blocks saving and failure keeps the sheet open for retry',
    (tester) async {
      final repository = FakeAdjustmentRepository(returnOrder());
      await openSheet(tester, repository);
      await tapVisible(
        tester,
        find.widgetWithText(FilledButton, AppStrings.cancelOrder),
      );
      expect(repository.updates, isEmpty);
      await tester.enterText(
        find.byKey(const ValueKey('cancellation-reason')),
        'Customer request',
      );
      await tapVisible(tester, find.byType(CheckboxListTile));
      repository.failSave = true;
      await tapVisible(
        tester,
        find.widgetWithText(FilledButton, AppStrings.cancelOrder),
      );
      expect(find.byType(OrderCancellationSheet), findsOneWidget);
      expect(find.text('Customer request'), findsOneWidget);
      expect(repository.updates, isEmpty);
      expect(tester.takeException(), isNull);
      repository.failSave = false;
      await tapVisible(
        tester,
        find.widgetWithText(FilledButton, AppStrings.cancelOrder),
      );
      expect(repository.updates.single['refund_amount'], 0);
      expect(find.byType(OrderCancellationSheet), findsNothing);
    },
  );

  testWidgets(
    'full refund preserves paise and narrow layouts do not overflow',
    (tester) async {
      final repository = FakeAdjustmentRepository(returnOrder(paid: 100.25));
      await openSheet(tester, repository);
      await tester.enterText(
        find.byKey(const ValueKey('cancellation-reason')),
        'Event cancelled',
      );
      await tapVisible(tester, find.text(AppStrings.cancellationFullRefund));
      await tapVisible(tester, find.byType(CheckboxListTile));
      await tapVisible(
        tester,
        find.widgetWithText(FilledButton, AppStrings.cancelOrder),
      );
      expect(repository.updates.single['refund_amount'], 100.25);
      expect(tester.takeException(), isNull);
    },
  );
}
