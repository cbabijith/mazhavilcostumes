import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/views/dashboard_view.dart';
import 'package:mobile/main.dart';

void main() {
  group('DashboardView Responsive Tests', () {
    testWidgets(
      'Dashboard has no overflow on 320x568 (small mobile)',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DashboardView(),
            ),
          ),
        );

        // Set screen size to small mobile
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpAndSettle();

        // Check for overflow
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'No overflow should occur on 320x568');
      },
    );

    testWidgets(
      'Dashboard has no overflow on 360x800 (medium mobile)',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DashboardView(),
            ),
          ),
        );

        // Set screen size to medium mobile
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpAndSettle();

        // Check for overflow
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'No overflow should occur on 360x800');
      },
    );

    testWidgets(
      'Dashboard has no overflow on 393x852 (large mobile)',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DashboardView(),
            ),
          ),
        );

        // Set screen size to large mobile
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpAndSettle();

        // Check for overflow
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'No overflow should occur on 393x852');
      },
    );

    testWidgets(
      'Dashboard has no overflow on 412x915 (extra large mobile)',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DashboardView(),
            ),
          ),
        );

        // Set screen size to extra large mobile
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpAndSettle();

        // Check for overflow
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'No overflow should occur on 412x915');
      },
    );

    testWidgets(
      'Dashboard has no overflow on 768x1024 (tablet)',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DashboardView(),
            ),
          ),
        );

        // Set screen size to tablet
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpAndSettle();

        // Check for overflow
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'No overflow should occur on 768x1024');
      },
    );
  });

  group('DashboardView Text Scale Tests', () {
    testWidgets(
      'Dashboard has no overflow with text scale 1.0',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DashboardView(),
            ),
          ),
        );

        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpAndSettle();

        final exception = tester.takeException();
        expect(exception, isNull, reason: 'No overflow with text scale 1.0');
      },
    );

    testWidgets(
      'Dashboard has no overflow with text scale 1.5',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(1.5),
                  ),
                  child: const MaterialApp(
                    home: DashboardView(),
                  ),
                );
              },
            ),
          ),
        );

        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpAndSettle();

        final exception = tester.takeException();
        expect(exception, isNull, reason: 'No overflow with text scale 1.5');
      },
    );

    testWidgets(
      'Dashboard has no overflow with text scale 2.0',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(2.0),
                  ),
                  child: const MaterialApp(
                    home: DashboardView(),
                  ),
                );
              },
            ),
          ),
        );

        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpAndSettle();

        final exception = tester.takeException();
        expect(exception, isNull, reason: 'No overflow with text scale 2.0');
      },
    );
  });

  group('DashboardView Landscape Tests', () {
    testWidgets(
      'Dashboard has no overflow in landscape mode (small)',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DashboardView(),
            ),
          ),
        );

        // Set to landscape mode (swapped dimensions)
        tester.view.physicalSize = const Size(568, 320);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpAndSettle();

        final exception = tester.takeException();
        expect(exception, isNull, reason: 'No overflow in landscape mode (568x320)');
      },
    );

    testWidgets(
      'Dashboard has no overflow in landscape mode (medium)',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DashboardView(),
            ),
          ),
        );

        // Set to landscape mode (swapped dimensions)
        tester.view.physicalSize = const Size(800, 360);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpAndSettle();

        final exception = tester.takeException();
        expect(exception, isNull, reason: 'No overflow in landscape mode (800x360)');
      },
    );

    testWidgets(
      'Dashboard has no overflow in landscape mode (large)',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DashboardView(),
            ),
          ),
        );

        // Set to landscape mode (swapped dimensions)
        tester.view.physicalSize = const Size(915, 412);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpAndSettle();

        final exception = tester.takeException();
        expect(exception, isNull, reason: 'No overflow in landscape mode (915x412)');
      },
    );
  });

  group('DashboardView Combined Tests', () {
    testWidgets(
      'Dashboard has no overflow on small mobile with text scale 1.5',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(1.5),
                  ),
                  child: const MaterialApp(
                    home: DashboardView(),
                  ),
                );
              },
            ),
          ),
        );

        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpAndSettle();

        final exception = tester.takeException();
        expect(exception, isNull, reason: 'No overflow on 320x568 with text scale 1.5');
      },
    );

    testWidgets(
      'Dashboard has no overflow in landscape with text scale 2.0',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(2.0),
                  ),
                  child: const MaterialApp(
                    home: DashboardView(),
                  ),
                );
              },
            ),
          ),
        );

        tester.view.physicalSize = const Size(800, 360);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpAndSettle();

        final exception = tester.takeException();
        expect(exception, isNull, reason: 'No overflow in landscape with text scale 2.0');
      },
    );
  });
}
