/// Responsive financial adjustment sheet; the viewmodel owns every save rule.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../models/order.dart';
import '../models/order_adjustment.dart';
import '../viewmodels/order_adjustment_viewmodel.dart';

class OrderAdjustmentSheet extends ConsumerStatefulWidget {
  const OrderAdjustmentSheet({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<OrderAdjustmentSheet> createState() =>
      _OrderAdjustmentSheetState();
}

class _OrderAdjustmentSheetState extends ConsumerState<OrderAdjustmentSheet> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    final saved = await ref
        .read(orderAdjustmentViewModelProvider(widget.order.id).notifier)
        .save();
    if (saved && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final draft = ref.watch(orderAdjustmentViewModelProvider(widget.order.id));
    final viewModel = ref.read(
      orderAdjustmentViewModelProvider(widget.order.id).notifier,
    );
    final busy = draft.submission.isLoading;
    final localizations = MaterialLocalizations.of(context);
    final textStyle = TextStyle(
      fontSize: Responsive.sp(AppSizes.fontMedium),
      color: AppColors.text,
    );
    return PopScope(
      canPop: !busy,
      child: SafeArea(
        child: Padding(
          padding: Responsive.all(AppSizes.spacingLarge).copyWith(
            bottom:
                MediaQuery.viewInsetsOf(context).bottom +
                Responsive.h(AppSizes.spacingLarge),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.financialAdjustment,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle.copyWith(
                            fontSize: Responsive.sp(AppSizes.fontLarge),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: localizations.closeButtonTooltip,
                        onPressed: busy
                            ? null
                            : () => Navigator.of(context).pop(false),
                        icon: Icon(
                          Icons.close_rounded,
                          size: Responsive.icon(AppSizes.iconMedium),
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  DropdownButtonFormField<OrderAdjustmentType>(
                    initialValue: draft.type,
                    isExpanded: true,
                    style: textStyle,
                    decoration: const InputDecoration(
                      labelText: AppStrings.adjustmentType,
                    ),
                    items: [
                      for (final type in OrderAdjustmentType.values)
                        DropdownMenuItem(
                          value: type,
                          child: Text(
                            OrderAdjustmentViewModel.label(type),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: busy
                        ? null
                        : (type) {
                            if (type != null) viewModel.selectType(type);
                          },
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  TextFormField(
                    key: const ValueKey('adjustment-amount'),
                    initialValue: draft.amount,
                    enabled: !busy,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: textStyle,
                    validator: OrderAdjustmentViewModel.amountError,
                    onChanged: viewModel.setAmount,
                    decoration: const InputDecoration(
                      labelText: AppStrings.adjustmentAmount,
                      errorMaxLines: 3,
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  TextFormField(
                    key: const ValueKey('adjustment-notes'),
                    initialValue: draft.notes,
                    enabled: !busy,
                    style: textStyle,
                    onChanged: viewModel.setNotes,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: AppStrings.adjustmentNotes,
                    ),
                  ),
                  if (viewModel.showOnTimeWarning(widget.order)) ...[
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    Container(
                      padding: Responsive.all(AppSizes.spacingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(
                          alpha: AppSizes.spacingTiny / AppSizes.spacingHuge,
                        ),
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                      ),
                      child: Text(
                        '${AppStrings.onTimeReturnWarning}\n'
                        '${AppStrings.onTimeLateFeeWarning(OrderAdjustmentViewModel.parseAmount(draft.amount)!)}',
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle.copyWith(color: AppColors.warning),
                      ),
                    ),
                  ],
                  if (draft.submission.hasError) ...[
                    SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                    Text(
                      '${AppStrings.adjustmentFailed}: '
                      '${draft.submission.error}',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle.copyWith(color: AppColors.error),
                    ),
                  ],
                  SizedBox(height: Responsive.h(AppSizes.spacingXXLarge)),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: busy
                              ? null
                              : () => Navigator.of(context).pop(false),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(localizations.cancelButtonLabel),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                      Expanded(
                        child: FilledButton(
                          onPressed: busy ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.background,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              busy
                                  ? AppStrings.saving
                                  : AppStrings.applyAdjustment,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
