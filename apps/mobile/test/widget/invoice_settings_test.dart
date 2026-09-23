/// Exercises GSTIN editing, authorization and failed saves without live writes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/features/auth/viewmodels/providers/auth_provider.dart';
import 'package:mobile/features/settings/repositories/settings_repository.dart';
import 'package:mobile/features/settings/viewmodels/invoice_settings_viewmodel.dart';
import 'package:mobile/features/settings/views/invoice_settings_view.dart';

class FakeSettingsRepository extends SettingsRepository {
  String value = '32ATOPS2936C1ZO';
  int reads = 0;
  final List<String> saves = [];
  bool failRead = false;
  bool failSave = false;

  @override
  Future<String> getGstNumber() async {
    reads++;
    if (failRead) throw StateError('Offline');
    return value;
  }

  @override
  Future<String> saveGstNumber(String value) async {
    if (failSave) throw StateError('Save failed');
    saves.add(value);
    this.value = value;
    return value;
  }
}

Future<void> openSettings(
  WidgetTester tester,
  FakeSettingsRepository repository, {
  UserRole role = UserRole.admin,
  double width = 390,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authUserProvider.overrideWithValue(
          AuthUser(
            id: 'test-admin',
            email: 'test@example.test',
            name: 'Test',
            role: role,
          ),
        ),
        settingsRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const Scaffold(body: InvoiceSettingsView()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> saveSettings(WidgetTester tester) async {
  final save = find.byType(FilledButton);
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'loads saved value, normalizes edits and keeps a cleared GSTIN empty',
    (tester) async {
      final repository = FakeSettingsRepository();
      await openSettings(tester, repository);
      expect(find.text(repository.value), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), ' 32abcde1234f1z5 ');
      await saveSettings(tester);
      expect(repository.saves, ['32ABCDE1234F1Z5']);
      expect(find.text(AppStrings.invoiceSettingsSaved), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '');
      await saveSettings(tester);
      expect(repository.saves.last, '');
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        '',
      );
    },
  );

  testWidgets('invalid GSTIN is rejected without sending a request', (
    tester,
  ) async {
    final repository = FakeSettingsRepository();
    await openSettings(tester, repository);
    await tester.enterText(find.byType(TextFormField), '32ATOPS2936C0ZO');
    await saveSettings(tester);
    expect(find.text(AppStrings.invalidGstNumber), findsOneWidget);
    expect(repository.saves, isEmpty);
  });

  testWidgets('failed saves retain the draft and allow retry', (tester) async {
    final repository = FakeSettingsRepository()..failSave = true;
    await openSettings(tester, repository);
    await tester.enterText(find.byType(TextFormField), '32ABCDE1234F1Z5');
    await saveSettings(tester);
    expect(find.textContaining('Save failed'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      '32ABCDE1234F1Z5',
    );
    expect(find.text(AppStrings.invoiceSettingsSaved), findsNothing);
    repository.failSave = false;
    await saveSettings(tester);
    expect(repository.saves, ['32ABCDE1234F1Z5']);
  });

  testWidgets('failed reads cannot overwrite an unknown GSTIN and can retry', (
    tester,
  ) async {
    final repository = FakeSettingsRepository()..failRead = true;
    await openSettings(tester, repository);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    repository.failRead = false;
    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();
    expect(find.text(repository.value), findsOneWidget);
  });

  for (final role in [UserRole.staff, UserRole.manager]) {
    testWidgets('$role cannot load or edit GSTIN', (tester) async {
      final repository = FakeSettingsRepository();
      await openSettings(tester, repository, role: role);
      expect(find.text(AppStrings.settingsAdminOnly), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      expect(repository.reads, 0);
    });
  }

  testWidgets('narrow screens and large text do not overflow', (tester) async {
    await openSettings(
      tester,
      FakeSettingsRepository(),
      width: 320,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
