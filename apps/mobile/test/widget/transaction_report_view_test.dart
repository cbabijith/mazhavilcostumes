/// Verifies invoice labels in the mobile revenue transaction list.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/domain/transaction_detail.dart';
import 'package:mobile/features/dashboard/viewmodels/providers/dashboard_provider.dart';
import 'package:mobile/features/dashboard/views/transaction_report_view.dart';

void main() {
  testWidgets('transactions display the invoice number or a missing value', (
    tester,
  ) async {
    const range = TransactionReportParam(
      fromDate: '2026-11-04',
      toDate: '2026-11-04',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionReportProvider(range).overrideWith((ref) async => [
            for (final invoice in ['MAZ-2627-0007', null])
              TransactionDetail.fromJson({
                'order_id': 'order-12345',
                'invoice_number': invoice,
                'date': range.fromDate,
                'amount': 100,
                'payment_type': 'advance',
                'payment_mode': 'cash',
                'status': 'completed',
              }),
          ]),
        ],
        child: MaterialApp(
          home: TransactionReportView(
            fromDate: range.fromDate,
            toDate: range.toDate,
            rangeLabel: 'Today',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Invoice: MAZ-2627-0007'), findsOneWidget);
    expect(find.text('Invoice: —'), findsOneWidget);
    expect(find.textContaining('12345'), findsNothing);
  });
}
