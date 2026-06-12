import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/analytics_metrics.dart';
import '../../viewmodels/providers/dashboard_provider.dart';
import 'revenue_chart.dart';

/// Analytics section of the dashboard — admin-only.
/// Shows revenue pacing, collection trends, revenue status cards,
/// cancellations, overdue, booking velocity, category revenue,
/// top performers, and dead stock.
class AnalyticsSection extends ConsumerWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsMetricsProvider);
    final prevLabel = ref.watch(analyticsPrevLabelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Responsive.h(AppSizes.spacingXXLarge)),
        // Section header + range filter
        _buildSectionHeader(context, ref),
        SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
        analyticsAsync.when(
          data: (metrics) => _buildAnalyticsContent(metrics, prevLabel),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error, ref),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, WidgetRef ref) {
    final selectedRange = ref.watch(analyticsRangeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: Responsive.icon(AppSizes.iconSmall),
              color: AppColors.secondaryText,
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
            Expanded(
              child: AutoSizeText(
                AppStrings.revenueAnalytics,
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontXLarge),
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
        // Range filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AnalyticsRange.values.map((range) {
              final isSelected = range == selectedRange;
              return Padding(
                padding: EdgeInsets.only(right: Responsive.w(AppSizes.spacingSmall)),
                child: GestureDetector(
                  onTap: () => ref.read(analyticsRangeProvider.notifier).select(range),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: Responsive.symmetric(
                      horizontal: AppSizes.spacingMedium,
                      vertical: AppSizes.spacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(
                        Responsive.r(AppSizes.radiusXXLarge),
                      ),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: AppSizes.spacingTiny / 4,
                      ),
                    ),
                    child: AutoSizeText(
                      range.label,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.secondaryText,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsContent(AnalyticsMetrics metrics, String prevLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Booking Sales + Amount Collection
        _buildPacingCard(
          title: AppStrings.bookingSales,
          description: AppStrings.bookingSalesDesc,
          amount: metrics.salesPacing.current,
          percentageChange: metrics.salesPacing.percentageChange,
          isPositive: metrics.salesPacing.isPositive,
          prevLabel: prevLabel,
          accentColor: AppColors.info,
        ),
        SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
        _buildAmountCollectionCard(metrics, prevLabel),
        SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),

        // Collection Trends Chart
        _buildChartCard(
          title: AppStrings.collectionTrends,
          description: AppStrings.collectionTrendsDesc,
          child: RevenueChart(dailyRevenue: metrics.dailyRevenue),
        ),
        SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),

        // Revenue Status Grid (2 columns)
        _buildRevenueStatusGrid(metrics),
        SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),

        // Cancellations + Overdue Returns
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: AppStrings.cancellations,
                value: metrics.cancellationStats.currentCount.toString(),
                subtitle:
                    '${metrics.cancellationStats.percentageChange.abs().round()}% ${AppStrings.vs} prev',
                valueColor: metrics.cancellationStats.currentCount > 0
                    ? AppColors.error
                    : AppColors.text,
                icon: Icons.cancel_outlined,
                iconColor: metrics.cancellationStats.currentCount > 0
                    ? AppColors.error
                    : AppColors.secondaryText,
              ),
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
            Expanded(
              child: _buildStatCard(
                title: AppStrings.overdueReturns,
                value: '${metrics.actionRequired.overdueCount}',
                subtitle:
                    '${metrics.actionRequired.overdueCount} ${AppStrings.overdueOrdersDesc}',
                valueColor: metrics.actionRequired.overdueCount > 0
                    ? AppColors.error
                    : AppColors.text,
                icon: Icons.error_outline,
                iconColor: metrics.actionRequired.overdueCount > 0
                    ? AppColors.error
                    : AppColors.secondaryText,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),

        // Booking Velocity Chart
        _buildChartCard(
          title: AppStrings.bookingVelocity,
          description: AppStrings.bookingVelocityDesc,
          child: BookingVelocityChart(bookingVelocity: metrics.bookingVelocity),
        ),
        SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),

        // Category Revenue
        _buildCategoryRevenueCard(metrics.categoryRevenue),
        SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),

        // Top Performers + Dead Stock
        _buildTopPerformersCard(metrics.topPerformers),
        SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
        _buildDeadStockCard(metrics.deadStock),
      ],
    );
  }

  // ── Pacing Card (Booking Sales) ──────────────────────────────────────

  Widget _buildPacingCard({
    required String title,
    required String description,
    required double amount,
    required double percentageChange,
    required bool isPositive,
    required String prevLabel,
    required Color accentColor,
  }) {
    return Container(
      padding: Responsive.all(AppSizes.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: Responsive.r(AppSizes.spacingSmall),
            offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      title,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontMedium),
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                    AutoSizeText(
                      description,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AutoSizeText(
                    _formatCurrency(amount),
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontXXLarge),
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: Responsive.icon(AppSizes.iconTiny),
                        color: isPositive ? AppColors.success : AppColors.error,
                      ),
                      SizedBox(width: Responsive.w(AppSizes.spacingTiny / 2)),
                      AutoSizeText(
                        '${percentageChange.abs().round()}% ${AppStrings.vs} $prevLabel',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontTiny),
                          fontWeight: FontWeight.w600,
                          color: isPositive ? AppColors.success : AppColors.error,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Amount Collection Card (with mode breakdown) ─────────────────────

  Widget _buildAmountCollectionCard(AnalyticsMetrics metrics, String prevLabel) {
    return Container(
      padding: Responsive.all(AppSizes.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: Responsive.r(AppSizes.spacingSmall),
            offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      AppStrings.amountCollection,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontMedium),
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                    AutoSizeText(
                      AppStrings.amountCollectionDesc,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AutoSizeText(
                    _formatCurrency(metrics.totalAmountCollection),
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontXXLarge),
                      fontWeight: FontWeight.w900,
                      color: AppColors.success,
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        metrics.revenuePacing.isPositive
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: Responsive.icon(AppSizes.iconTiny),
                        color: metrics.revenuePacing.isPositive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      SizedBox(width: Responsive.w(AppSizes.spacingTiny / 2)),
                      AutoSizeText(
                        '${metrics.revenuePacing.percentageChange.abs().round()}% ${AppStrings.vs} $prevLabel',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontTiny),
                          fontWeight: FontWeight.w600,
                          color: metrics.revenuePacing.isPositive
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          // Payment mode breakdown
          Container(
            padding: Responsive.symmetric(
              horizontal: AppSizes.spacingMedium,
              vertical: AppSizes.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(
                Responsive.r(AppSizes.radiusSmall),
              ),
            ),
            child: Row(
              children: [
                _buildModeChip(AppStrings.cash, metrics.totalCash),
                _buildModeDivider(),
                _buildModeChip(AppStrings.upi, metrics.totalUpi),
                _buildModeDivider(),
                _buildModeChip(AppStrings.gpay, metrics.totalGpay),
                _buildModeDivider(),
                _buildModeChip(AppStrings.bank, metrics.totalBankTransfer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String label, double amount) {
    return Expanded(
      child: Column(
        children: [
          AutoSizeText(
            label,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontTiny - 1),
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCurrency(amount),
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontSmall),
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeDivider() {
    return Container(
      width: AppSizes.spacingTiny / 4,
      height: Responsive.h(AppSizes.spacingXXLarge),
      color: AppColors.border,
      margin: EdgeInsets.symmetric(horizontal: Responsive.w(AppSizes.spacingSmall)),
    );
  }

  // ── Chart Card ───────────────────────────────────────────────────────

  Widget _buildChartCard({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      padding: Responsive.all(AppSizes.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: Responsive.r(AppSizes.spacingSmall),
            offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            title,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontMedium),
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
            maxLines: 1,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
          AutoSizeText(
            description,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontTiny),
              color: AppColors.secondaryText,
            ),
            maxLines: 1,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          child,
        ],
      ),
    );
  }

  // ── Revenue Status Grid ──────────────────────────────────────────────

  Widget _buildRevenueStatusGrid(AnalyticsMetrics metrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildRevenueStatusCard(
                title: AppStrings.realizedIncome,
                amount: metrics.revenueByStatus.completedRevenue,
                description: AppStrings.realizedIncomeDesc,
                icon: Icons.check_circle_outline,
                iconColor: AppColors.success,
                amountColor: AppColors.success,
              ),
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
            Expanded(
              child: _buildRevenueStatusCard(
                title: AppStrings.activeBalance,
                amount: metrics.revenueByStatus.activeBalance,
                description: AppStrings.activeBalanceDesc,
                icon: Icons.trending_up,
                iconColor: AppColors.info,
                amountColor: AppColors.info,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
        Row(
          children: [
            Expanded(
              child: _buildRevenueStatusCard(
                title: AppStrings.futureAdvances,
                amount: metrics.revenueByStatus.scheduledRevenue,
                description: AppStrings.futureAdvancesDesc,
                icon: Icons.calendar_today_outlined,
                iconColor: AppColors.warning,
                amountColor: AppColors.warning,
              ),
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
            Expanded(
              child: _buildRevenueStatusCard(
                title: AppStrings.dueFromReturned,
                amount: metrics.revenueByStatus.pendingAmount,
                description: AppStrings.dueFromReturnedDesc,
                icon: Icons.access_time,
                iconColor: metrics.revenueByStatus.pendingAmount > 0
                    ? AppColors.error
                    : AppColors.secondaryText,
                amountColor: metrics.revenueByStatus.pendingAmount > 0
                    ? AppColors.error
                    : AppColors.text,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueStatusCard({
    required String title,
    required double amount,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color amountColor,
  }) {
    return Container(
      padding: Responsive.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: Responsive.r(AppSizes.spacingSmall),
            offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AutoSizeText(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: Responsive.icon(AppSizes.iconTiny), color: iconColor),
            ],
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCurrency(amount),
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontXXLarge),
                fontWeight: FontWeight.w900,
                color: amountColor,
              ),
            ),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          AutoSizeText(
            description,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontTiny),
              color: AppColors.secondaryText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Stat Card (Cancellations / Overdue) ──────────────────────────────

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color valueColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: Responsive.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: Responsive.r(AppSizes.spacingSmall),
            offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AutoSizeText(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: Responsive.icon(AppSizes.iconTiny), color: iconColor),
            ],
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          AutoSizeText(
            value,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontXXLarge),
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
            maxLines: 1,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          AutoSizeText(
            subtitle,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontTiny),
              color: AppColors.secondaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Category Revenue Card ────────────────────────────────────────────

  Widget _buildCategoryRevenueCard(List<CategoryRevenue> categories) {
    return Container(
      padding: Responsive.all(AppSizes.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: Responsive.r(AppSizes.spacingSmall),
            offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            AppStrings.categoryRevenue,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontMedium),
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
            maxLines: 1,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
          AutoSizeText(
            AppStrings.categoryRevenueDesc,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontTiny),
              color: AppColors.secondaryText,
            ),
            maxLines: 1,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          if (categories.isEmpty)
            Padding(
              padding: Responsive.symmetric(vertical: AppSizes.spacingXXLarge),
              child: Center(
                child: AutoSizeText(
                  AppStrings.noCategoryData,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                ),
              ),
            )
          else
            ...categories.asMap().entries.map((entry) {
              final i = entry.key;
              final cat = entry.value;
              final barColors = [
                AppColors.text,
                AppColors.warning,
                AppColors.border,
                AppColors.success,
                Colors.purple,
              ];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: Responsive.h(AppSizes.spacingMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            cat.name,
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontSmall),
                              fontWeight: FontWeight.w500,
                              color: AppColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AutoSizeText(
                          '${cat.percentage}%',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        Responsive.r(AppSizes.spacingTiny),
                      ),
                      child: LinearProgressIndicator(
                        value: cat.percentage / 100,
                        minHeight: Responsive.h(AppSizes.spacingSmall),
                        backgroundColor: AppColors.scaffoldBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          barColors[i % barColors.length],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Top Performers Card ──────────────────────────────────────────────

  Widget _buildTopPerformersCard(List<TopPerformer> performers) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: Responsive.r(AppSizes.spacingSmall),
            offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: Responsive.all(AppSizes.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  AppStrings.topPerformers,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontMedium),
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                AutoSizeText(
                  AppStrings.topPerformersDesc,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontTiny),
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          if (performers.isEmpty)
            Padding(
              padding: Responsive.symmetric(vertical: AppSizes.spacingXXLarge),
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
            )
          else ...[
            // Table header
            Container(
              padding: Responsive.symmetric(
                horizontal: AppSizes.spacingLarge,
                vertical: AppSizes.spacingSmall,
              ),
              color: AppColors.scaffoldBackground,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AutoSizeText(
                      'Product',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      'Rentals',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: AutoSizeText(
                      'Revenue',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            // Table rows
            ...performers.map((p) => Container(
                  padding: Responsive.symmetric(
                    horizontal: AppSizes.spacingLarge,
                    vertical: AppSizes.spacingMedium,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.scaffoldBackground,
                        width: AppSizes.spacingTiny / 4,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AutoSizeText(
                          p.name,
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.w500,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          p.rentals.toString(),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: AutoSizeText(
                          _formatCurrency(p.revenue),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // ── Dead Stock Card ──────────────────────────────────────────────────

  Widget _buildDeadStockCard(List<DeadStockItem> deadStock) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: Responsive.r(AppSizes.spacingSmall),
            offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: Responsive.all(AppSizes.spacingLarge),
            child: AutoSizeText(
              AppStrings.deadStock,
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontMedium),
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              maxLines: 1,
            ),
          ),
          if (deadStock.isEmpty)
            Padding(
              padding: Responsive.symmetric(vertical: AppSizes.spacingXLarge),
              child: Center(
                child: AutoSizeText(
                  AppStrings.noDeadStock,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
              ),
            )
          else
            ...deadStock.map((item) => Container(
                  padding: Responsive.symmetric(
                    horizontal: AppSizes.spacingLarge,
                    vertical: AppSizes.spacingMedium,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.scaffoldBackground,
                        width: AppSizes.spacingTiny / 4,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          item.name,
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.w500,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AutoSizeText(
                        '${item.daysIdle} days idle',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontSmall),
                          fontWeight: FontWeight.w500,
                          color: AppColors.error,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ── Loading State ────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // Pacing cards
          _buildShimmerCard(height: Responsive.h(80)),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          _buildShimmerCard(height: Responsive.h(120)),
          SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),
          // Chart
          _buildShimmerCard(height: Responsive.h(180)),
          SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),
          // Revenue grid
          Row(
            children: [
              Expanded(child: _buildShimmerCard(height: Responsive.h(120))),
              SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
              Expanded(child: _buildShimmerCard(height: Responsive.h(120))),
            ],
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          Row(
            children: [
              Expanded(child: _buildShimmerCard(height: Responsive.h(120))),
              SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
              Expanded(child: _buildShimmerCard(height: Responsive.h(120))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
      ),
    );
  }

  // ── Error State ──────────────────────────────────────────────────────

  Widget _buildErrorState(Object error, WidgetRef ref) {
    return Container(
      padding: Responsive.all(AppSizes.spacingXXLarge),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: Responsive.icon(AppSizes.iconXLarge),
            color: AppColors.error,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          AutoSizeText(
            'Unable to load analytics',
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontLarge),
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          AutoSizeText(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontSmall),
              color: AppColors.secondaryText,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          SizedBox(
            width: double.infinity,
            height: Responsive.h(AppSizes.buttonSmall),
            child: ElevatedButton(
              onPressed: () => ref.invalidate(analyticsMetricsProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                ),
              ),
              child: AutoSizeText(
                AppStrings.retry,
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontMedium),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }
}
