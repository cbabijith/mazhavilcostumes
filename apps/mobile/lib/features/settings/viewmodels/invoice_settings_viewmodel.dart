/// Manages loading, validation and saving the business GSTIN.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/viewmodels/providers/auth_provider.dart';
import '../repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(),
);

final invoiceGstinProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(authUserProvider);
  if (user?.isAdmin != true) throw StateError(AppStrings.settingsAdminOnly);
  return ref.watch(settingsRepositoryProvider).getGstNumber();
});

final invoiceSettingsSaveProvider =
    AsyncNotifierProvider<InvoiceSettingsViewModel, void>(
      InvoiceSettingsViewModel.new,
    );

class InvoiceSettingsViewModel extends AsyncNotifier<void> {
  static final _gstinPattern = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
  );

  @override
  void build() {
    ref.watch(authUserProvider);
  }

  /// Mirrors server format validation for immediate form feedback.
  static String? validateGstNumber(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();
    return normalized.isEmpty || _gstinPattern.hasMatch(normalized)
        ? null
        : AppStrings.invalidGstNumber;
  }

  /// Retains the loaded value and draft on failures; never assumes a default.
  Future<bool> save(String value) async {
    if (state.isLoading || !ref.read(invoiceGstinProvider).hasValue) {
      return false;
    }
    final validationError = validateGstNumber(value);
    if (ref.read(authUserProvider)?.isAdmin != true ||
        validationError != null) {
      state = AsyncError<void>(
        StateError(validationError ?? AppStrings.settingsAdminOnly),
        StackTrace.current,
      );
      return false;
    }
    state = const AsyncLoading<void>();
    try {
      await ref
          .read(settingsRepositoryProvider)
          .saveGstNumber(value.trim().toUpperCase());
      if (!ref.mounted) return false;
      state = const AsyncData(null);
      ref.invalidate(invoiceGstinProvider);
      return true;
    } catch (error, stack) {
      if (ref.mounted) {
        state = AsyncError<void>(error, stack);
      }
      return false;
    }
  }
}
