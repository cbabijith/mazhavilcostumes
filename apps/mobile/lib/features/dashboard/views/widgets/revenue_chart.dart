import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/analytics_metrics.dart';

/// Custom-painted bar chart showing daily collection trends.
/// Matches the web dashboard's "Collection Trends" chart.
class RevenueChart extends StatelessWidget {
  final List<DailyRevenue> dailyRevenue;

  const RevenueChart({super.key, required this.dailyRevenue});

  @override
  Widget build(BuildContext context) {
    if (dailyRevenue.isEmpty) {
      return SizedBox(
        height: Responsive.h(120),
        child: Center(
          child: AutoSizeText(
            AppStrings.noDataForPeriod,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontSmall),
              color: AppColors.secondaryText,
            ),
            maxLines: 1,
          ),
        ),
      );
    }

    final maxAmount = dailyRevenue.fold<double>(
      1000,
      (max, d) => d.amount > max ? d.amount : max,
    );

    return SizedBox(
      height: Responsive.h(140),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: dailyRevenue.map((day) {
          final heightPercent = (day.amount / maxAmount * 100).clamp(2.0, 100.0);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(AppSizes.spacingTiny / 4),
              ),
              child: Tooltip(
                message: '₹${_formatAmount(day.amount)}\n${day.date}',
                preferBelow: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: heightPercent / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: day.amount > 0
                                ? AppColors.success
                                : AppColors.border,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                Responsive.r(AppSizes.spacingTiny / 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

/// Bar chart for booking velocity (upcoming pickups over 15 days).
class BookingVelocityChart extends StatelessWidget {
  final List<BookingVelocity> bookingVelocity;

  const BookingVelocityChart({super.key, required this.bookingVelocity});

  @override
  Widget build(BuildContext context) {
    if (bookingVelocity.isEmpty) {
      return SizedBox(
        height: Responsive.h(120),
        child: Center(
          child: AutoSizeText(
            AppStrings.noDataForPeriod,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontSmall),
              color: AppColors.secondaryText,
            ),
            maxLines: 1,
          ),
        ),
      );
    }

    final maxCount = bookingVelocity.fold<int>(
      5,
      (max, d) => d.count > max ? d.count : max,
    );

    return SizedBox(
      height: Responsive.h(120),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bookingVelocity.map((day) {
          final heightPercent = (day.count / maxCount * 100).clamp(2.0, 100.0);
          final isHot = heightPercent > 75;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(AppSizes.spacingTiny / 4),
              ),
              child: Tooltip(
                message: '${day.count} ${AppStrings.pickups}\n${day.date}',
                preferBelow: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: heightPercent / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isHot ? AppColors.warning : AppColors.text,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                Responsive.r(AppSizes.spacingTiny / 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
