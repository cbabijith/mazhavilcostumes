/// Shared freshness notice for encrypted list and calendar snapshots.
library;

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/responsive.dart';

class SavedDataStatus extends StatelessWidget {
  const SavedDataStatus({
    super.key,
    required this.savedAt,
    required this.refreshFailed,
    required this.onRetry,
  });

  final DateTime? savedAt;
  final bool refreshFailed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (savedAt == null) return const SizedBox.shrink();
    return InkWell(
      onTap: refreshFailed ? onRetry : null,
      child: Padding(
        padding: Responsive.symmetric(
          horizontal: AppSizes.spacingLarge,
          vertical: AppSizes.spacingSmall,
        ),
        child: Text(
          refreshFailed
              ? AppStrings.savedDataRefreshFailed
              : AppStrings.refreshingSavedData,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontSmall),
            color: refreshFailed ? AppColors.error : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}
