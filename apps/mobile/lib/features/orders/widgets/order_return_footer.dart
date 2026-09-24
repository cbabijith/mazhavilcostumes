/// Website-aligned return footer: payment, pending notice, discount and save.
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';

class OrderReturnFooter extends StatelessWidget {
  const OrderReturnFooter({
    super.key,
    required this.pendingUnits,
    required this.discountController,
    required this.onDiscountChanged,
    required this.onSubmit,
    required this.balanceDue,
    required this.onCollectPayment,
    this.settlementPreview,
  });

  final int pendingUnits;
  final TextEditingController discountController;
  final ValueChanged<String> onDiscountChanged;
  final VoidCallback? onSubmit;
  final double balanceDue;
  final VoidCallback? onCollectPayment;
  final Widget? settlementPreview;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Container(
      padding: Responsive.all(AppSizes.spacingLarge),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppSizes.spacingTiny / 4,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (settlementPreview != null) ...[
            settlementPreview!,
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          ],
          if (balanceDue > 0) ...[
            Container(
              key: const ValueKey('return-payment-due'),
              padding: Responsive.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                ),
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: Responsive.icon(AppSizes.iconSmall),
                      ),
                      SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.paymentDue(balanceDue),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontSmall),
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                            SizedBox(
                              height: Responsive.h(AppSizes.spacingTiny),
                            ),
                            Text(
                              AppStrings.returnPaymentHint,
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontSmall),
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                  FilledButton(
                    onPressed: onCollectPayment,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    child: Text(
                      AppStrings.collectPayment,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          ],
          if (pendingUnits > 0) ...[
            Container(
              padding: Responsive.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                ),
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColors.error,
                    size: Responsive.icon(AppSizes.iconTiny),
                  ),
                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.partialReturn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny),
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                        Text(
                          AppStrings.pendingReturnMessage(pendingUnits),
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          ],
          Text(
            AppStrings.returnDiscount.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontTiny),
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
          TextField(
            key: const ValueKey('return-discount'),
            controller: discountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: onDiscountChanged,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontSmall),
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '0',
              isDense: true,
              contentPadding: Responsive.all(AppSizes.spacingMedium),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: pendingUnits > 0
                  ? AppColors.warning
                  : AppColors.text,
              foregroundColor: AppColors.background,
              padding: Responsive.all(AppSizes.spacingLarge),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
              ),
            ),
            child: Text(
              pendingUnits > 0
                  ? AppStrings.savePartialReturn(pendingUnits)
                  : AppStrings.completeReturn,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontMedium),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
