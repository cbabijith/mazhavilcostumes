/// Compact, responsive condition choices matching the website return checklist.
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';

class ReturnConditionSelector extends StatelessWidget {
  const ReturnConditionSelector({
    super.key,
    required this.status,
    required this.onChanged,
  });

  final String? status;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    const choices = [
      (
        'good',
        AppStrings.returnGood,
        Icons.check_circle_outline,
        AppColors.success,
      ),
      (
        'damaged',
        AppStrings.returnDamaged,
        Icons.warning_amber_rounded,
        AppColors.warning,
      ),
      ('missing', AppStrings.notReturned, Icons.access_time, AppColors.error),
    ];
    return Wrap(
      spacing: Responsive.w(AppSizes.spacingSmall),
      runSpacing: Responsive.h(AppSizes.spacingSmall),
      children: [
        for (final (value, label, icon, color) in choices)
          OutlinedButton.icon(
            onPressed: () => onChanged(value),
            icon: Icon(icon, size: Responsive.icon(AppSizes.iconTiny)),
            label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            style: OutlinedButton.styleFrom(
              foregroundColor: status == value ? AppColors.background : color,
              backgroundColor: status == value ? color : AppColors.background,
              textStyle: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontSmall),
                fontWeight: FontWeight.bold,
              ),
              padding: Responsive.symmetric(
                horizontal: AppSizes.spacingSmall,
                vertical: AppSizes.spacingSmall,
              ),
              side: BorderSide(
                color: status == value ? color : AppColors.border,
                width: AppSizes.spacingTiny / 4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
