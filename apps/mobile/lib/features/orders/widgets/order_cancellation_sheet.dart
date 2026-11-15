/// Staff-accessible cancellation UI; validation and saving live in the viewmodel.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../models/order.dart';
import '../viewmodels/order_cancellation_viewmodel.dart';

class OrderCancellationSheet extends ConsumerStatefulWidget {
  const OrderCancellationSheet({super.key, required this.order});
  final Order order;

  @override
  ConsumerState<OrderCancellationSheet> createState() =>
      _OrderCancellationSheetState();
}

class _OrderCancellationSheetState
    extends ConsumerState<OrderCancellationSheet> {
  final _refundController = TextEditingController(text: '0');

  @override
  void dispose() {
    _refundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final draft = ref.watch(
      orderCancellationViewModelProvider(widget.order.id),
    );
    final viewModel = ref.read(
      orderCancellationViewModelProvider(widget.order.id).notifier,
    );
    final busy = draft.submission.isLoading;
    final textStyle = TextStyle(
      fontSize: Responsive.sp(AppSizes.fontMedium),
      color: AppColors.text,
    );
    final gap = SizedBox(height: Responsive.h(AppSizes.spacingMedium));
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.cancelOrder,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.sp(AppSizes.fontLarge),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
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
                gap,
                TextField(
                  key: const ValueKey('cancellation-reason'),
                  enabled: !busy,
                  maxLines: 3,
                  style: textStyle,
                  onChanged: (value) => viewModel.edit(reason: value),
                  decoration: const InputDecoration(
                    labelText: AppStrings.cancellationReason,
                  ),
                ),
                if (widget.order.amountPaid > 0) ...[
                  gap,
                  TextField(
                    key: const ValueKey('cancellation-refund'),
                    controller: _refundController,
                    enabled: !busy,
                    style: textStyle,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) => viewModel.edit(refund: value),
                    decoration: const InputDecoration(
                      labelText: AppStrings.refundNow,
                    ),
                  ),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () {
                            _refundController.text = widget.order.amountPaid
                                .toStringAsFixed(2);
                            viewModel.edit(refund: _refundController.text);
                          },
                    child: Text(
                      AppStrings.cancellationFullRefund,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle,
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: draft.mode,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: AppStrings.refundMode,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'cash',
                        child: Text(AppStrings.cash),
                      ),
                      DropdownMenuItem(
                        value: 'upi',
                        child: Text(AppStrings.upi),
                      ),
                      DropdownMenuItem(
                        value: 'gpay',
                        child: Text(AppStrings.gpay),
                      ),
                      DropdownMenuItem(
                        value: 'bank_transfer',
                        child: Text('Bank transfer'),
                      ),
                      DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                    ],
                    onChanged: busy
                        ? null
                        : (value) {
                            if (value != null) viewModel.edit(mode: value);
                          },
                  ),
                  gap,
                  Text(
                    AppStrings.refundRemainderDue,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                ],
                if (widget.order.cancellationNeedsStockConfirmation) ...[
                  gap,
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: draft.stockReturned,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: busy
                        ? null
                        : (value) =>
                              viewModel.edit(stockReturned: value ?? false),
                    title: Text(
                      AppStrings.cancellationStockConfirmation,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle,
                    ),
                  ),
                ],
                if (draft.submission.hasError) ...[
                  gap,
                  Text(
                    '${AppStrings.cancellationFailed}: ${draft.submission.error}',
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.copyWith(color: AppColors.error),
                  ),
                ],
                gap,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: busy
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(AppStrings.keepOrder),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                    Expanded(
                      child: FilledButton(
                        onPressed: busy
                            ? null
                            : () async {
                                final saved = await viewModel.save();
                                  if (saved && context.mounted) {
                                  Navigator.of(context).pop(true);
                                  }
                              },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            busy ? AppStrings.saving : AppStrings.cancelOrder,
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
    );
  }
}
