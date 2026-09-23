/// Responsive admin-only editor for the GSTIN printed on shared API bills.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/viewmodels/providers/auth_provider.dart';
import '../viewmodels/invoice_settings_viewmodel.dart';

class InvoiceSettingsView extends ConsumerStatefulWidget {
  const InvoiceSettingsView({super.key});

  @override
  ConsumerState<InvoiceSettingsView> createState() =>
      _InvoiceSettingsViewState();
}

class _InvoiceSettingsViewState extends ConsumerState<InvoiceSettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _gstinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.listenManual(invoiceGstinProvider, (previous, next) {
      if (next is AsyncData<String>) _gstinController.text = next.value;
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _gstinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    final saved = await ref
        .read(invoiceSettingsSaveProvider.notifier)
        .save(_gstinController.text);
    if (saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.invoiceSettingsSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    if (ref.watch(authUserProvider)?.isAdmin != true) {
      return const Center(child: Text(AppStrings.settingsAdminOnly));
    }
    final settings = ref.watch(invoiceGstinProvider);
    final saveState = ref.watch(invoiceSettingsSaveProvider);
    if (!settings.hasValue && settings.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Form(
      key: _formKey,
      child: ListView(
        padding: Responsive.all(AppSizes.spacingLarge),
        children: [
          Text(
            AppStrings.gstNumberHelp,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontMedium),
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          if (settings.hasValue) ...[
            TextFormField(
              controller: _gstinController,
              enabled: !settings.isLoading && !saveState.isLoading,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              validator: InvoiceSettingsViewModel.validateGstNumber,
              decoration: const InputDecoration(
                labelText: AppStrings.gstNumber,
                errorMaxLines: 3,
              ),
              style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
              onFieldSubmitted: (_) => _save(),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            FilledButton(
              onPressed: settings.isLoading || saveState.isLoading
                  ? null
                  : _save,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  saveState.isLoading
                      ? AppStrings.saving
                      : AppStrings.saveInvoiceSettings,
                ),
              ),
            ),
          ],
          if (settings.hasError || saveState.hasError) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            Text(
              saveState.hasError
                  ? saveState.error.toString()
                  : AppStrings.settingsLoadFailed,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.error,
                fontSize: Responsive.sp(AppSizes.fontMedium),
              ),
            ),
            if (!settings.hasValue)
              TextButton(
                onPressed: () => ref.invalidate(invoiceGstinProvider),
                child: const Text(AppStrings.retry),
              ),
          ],
        ],
      ),
    );
  }
}
