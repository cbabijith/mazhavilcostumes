/// Reproduces grand-total layout constraints without network or order writes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/utils/responsive.dart';
import 'package:mobile/features/orders/views/order_form_view.dart';

void main() {
  const details = '365 days (Nov 14 – Nov 14, 2027) · Rate: ×363 · Incl. GST';
  for (final width in [320.0, 375.0, 600.0]) {
    for (final textScale in [1.0, 1.6, 2.0]) {
      testWidgets('grand total fits width $width at text scale $textScale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 844),
                textScaler: TextScaler.linear(textScale),
              ),
              child: Scaffold(
                body: Builder(
                  builder: (context) {
                    Responsive.init(context);
                    return SingleChildScrollView(
                      // Match the scrolling form's outer and card padding.
                      padding: Responsive.all(AppSizes.spacingLarge * 2),
                      child: const OrderFormGrandTotal(
                        totalAmount: 12345678.90,
                        rentalDetails: details,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('₹12345678.90'), findsOneWidget);
        expect(find.text(AppStrings.grandTotal), findsOneWidget);
        final value = tester.getRect(find.text('₹12345678.90'));
        final caption = tester.getRect(find.text(details));
        expect(value.right, lessThanOrEqualTo(width));
        expect(value.left, greaterThanOrEqualTo(0));
        expect(caption.top, greaterThanOrEqualTo(value.bottom));
        expect(caption.right, lessThanOrEqualTo(width));
      });
    }
  }
}
