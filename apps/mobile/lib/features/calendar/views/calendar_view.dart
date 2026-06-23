import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../branches/viewmodels/providers/branch_provider.dart';
import '../../orders/models/order.dart';
import '../../orders/views/order_detail_view.dart';
import '../models/calendar_day_summary.dart';
import '../providers/calendar_provider.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  String _activeTab = 'pickups'; // 'pickups' | 'ongoing' | 'returns'

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final currentMonth = ref.watch(calendarMonthProvider);
    final selectedDate = ref.watch(calendarSelectedDateProvider);
    final branchId = ref.watch(effectiveBranchIdProvider);
    final ordersAsync = ref.watch(calendarOrdersProvider);
    final daySummaries = ref.watch(calendarDaySummaryProvider);
    final monthStats = ref.watch(calendarMonthStatsProvider);

    // If no branch is selected (which only happens for super_admins/admins initially), show prompt
    if (branchId == null || branchId.isEmpty) {
      return Container(
        color: AppColors.scaffoldBackground,
        child: Center(
          child: Padding(
            padding: Responsive.all(AppSizes.screenPaddingSmall),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.storefront_rounded,
                  size: Responsive.icon(AppSizes.iconHuge),
                  color: Colors.grey[400],
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                Text(
                  'Select a Branch',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontXLarge),
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                Text(
                  'Choose a branch from the top menu to view its booking calendar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: AppColors.scaffoldBackground,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(calendarOrdersProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: Responsive.symmetric(
            horizontal: AppSizes.screenPaddingSmall,
            vertical: AppSizes.spacingMedium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Month Navigation Header
              _buildMonthHeader(currentMonth),
              SizedBox(height: Responsive.h(AppSizes.spacingMedium)),

              // 2. Monthly Stats Ribbon
              _buildStatsRibbon(monthStats, ordersAsync.isLoading),
              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),

              // 3. Calendar Grid Card
              _buildCalendarCard(currentMonth, selectedDate, daySummaries, ordersAsync.isLoading),
              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),

              // 4. Selected Day Bookings Detail Panel
              _buildDayDetailPanel(selectedDate, daySummaries),
              SizedBox(height: Responsive.h(AppSizes.spacingXXLarge)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Month Navigation Header ──────────────────────────────────────────
  Widget _buildMonthHeader(DateTime month) {
    final monthLabel = DateFormat('MMMM yyyy').format(month);

    return Row(
      children: [
        Text(
          monthLabel,
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontXLarge),
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const Spacer(),
        // Prev Month Button
        IconButton(
          onPressed: () => ref.read(calendarMonthProvider.notifier).goToPrevMonth(),
          icon: const Icon(Icons.chevron_left_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.text,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            elevation: AppSizes.spacingTiny / 4,
            padding: Responsive.all(AppSizes.spacingSmall),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
            ),
          ),
        ),
        SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
        // Next Month Button
        IconButton(
          onPressed: () => ref.read(calendarMonthProvider.notifier).goToNextMonth(),
          icon: const Icon(Icons.chevron_right_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.text,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            elevation: AppSizes.spacingTiny / 4,
            padding: Responsive.all(AppSizes.spacingSmall),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
            ),
          ),
        ),
        SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
        // Today Button
        TextButton(
          onPressed: () {
            ref.read(calendarMonthProvider.notifier).goToToday();
            ref.read(calendarSelectedDateProvider.notifier).select(DateTime.now());
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            elevation: AppSizes.spacingTiny / 4,
            padding: Responsive.symmetric(
              horizontal: AppSizes.spacingMedium,
              vertical: AppSizes.spacingSmall,
            ),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25), width: AppSizes.spacingTiny / 4),
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
            ),
          ),
          child: Text(
            'Today',
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontSmall),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ── Stats Ribbon ─────────────────────────────────────────────────────
  Widget _buildStatsRibbon(CalendarMonthStats stats, bool isLoading) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(
            label: 'Ongoing Today',
            value: isLoading ? '...' : '${stats.ongoingToday}',
            icon: Icons.play_circle_outline_rounded,
            iconColor: AppColors.primary,
            bgColor: AppColors.primary.withValues(alpha: 0.05),
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
          _buildStatCard(
            label: 'Scheduled',
            value: isLoading ? '...' : '${stats.scheduledThisMonth}',
            icon: Icons.schedule_rounded,
            iconColor: AppColors.info,
            bgColor: AppColors.info.withValues(alpha: 0.05),
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
          _buildStatCard(
            label: 'Ending Today',
            value: isLoading ? '...' : '${stats.endingToday}',
            icon: Icons.assignment_turned_in_outlined,
            iconColor: AppColors.warning,
            bgColor: AppColors.warning.withValues(alpha: 0.05),
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
          _buildStatCard(
            label: 'Late Returns',
            value: isLoading ? '...' : '${stats.lateReturns}',
            icon: Icons.error_outline_rounded,
            iconColor: AppColors.error,
            bgColor: AppColors.error.withValues(alpha: 0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      width: Responsive.w(132),
      padding: Responsive.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: Responsive.r(AppSizes.radiusSmall),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: Responsive.all(AppSizes.spacingSmall),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: Responsive.icon(AppSizes.iconSmall), color: iconColor),
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontLarge),
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: Responsive.h(2)),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Responsive.sp(9),
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Calendar Month Grid Card ─────────────────────────────────────────
  Widget _buildCalendarCard(
    DateTime month,
    DateTime? selectedDate,
    Map<String, CalendarDaySummary> summaries,
    bool isLoading,
  ) {
    return Container(
      padding: Responsive.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: Responsive.r(AppSizes.radiusMedium),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Weekdays Label Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((wd) => SizedBox(
                      width: Responsive.w(32),
                      child: Center(
                        child: Text(
                          wd,
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny),
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          // Grid Days content
          isLoading
              ? _buildCalendarShimmer()
              : _buildCalendarGrid(month, selectedDate, summaries),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          // Legend details
          _buildCalendarLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendarShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: 35,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid(
    DateTime month,
    DateTime? selectedDate,
    Map<String, CalendarDaySummary> summaries,
  ) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7;

    final totalWeeks = ((startWeekday + daysInMonth) / 7).ceil();
    final totalCells = totalWeeks * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final DateTime cellDate;
        final bool isCurrentMonth;

        if (index < startWeekday) {
          isCurrentMonth = false;
          cellDate = firstDayOfMonth.subtract(Duration(days: startWeekday - index));
        } else if (index < startWeekday + daysInMonth) {
          isCurrentMonth = true;
          final dayNum = index - startWeekday + 1;
          cellDate = DateTime(month.year, month.month, dayNum);
        } else {
          isCurrentMonth = false;
          cellDate = lastDayOfMonth.add(Duration(days: index - (startWeekday + daysInMonth) + 1));
        }

        final dateKey =
            "${cellDate.year}-${cellDate.month.toString().padLeft(2, '0')}-${cellDate.day.toString().padLeft(2, '0')}";
        final summary = summaries[dateKey];

        return _buildCalendarDayCell(cellDate, isCurrentMonth, selectedDate, summary);
      },
    );
  }

  Widget _buildCalendarDayCell(
    DateTime date,
    bool isCurrentMonth,
    DateTime? selectedDate,
    CalendarDaySummary? summary,
  ) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final isSelected = selectedDate != null &&
        date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;

    if (!isCurrentMonth) {
      return Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontSmall),
            color: Colors.grey[300],
          ),
        ),
      );
    }

    final totalBookings = summary?.orders.length ?? 0;

    // Highlights
    BoxDecoration cellDecoration = const BoxDecoration();
    TextStyle textStyle = TextStyle(
      fontSize: Responsive.sp(AppSizes.fontSmall),
      fontWeight: FontWeight.w600,
      color: AppColors.text,
    );

    if (isSelected && isToday) {
      cellDecoration = BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: Responsive.r(4),
            offset: const Offset(0, 2),
          ),
        ],
      );
      textStyle = textStyle.copyWith(color: Colors.white);
    } else if (isSelected) {
      cellDecoration = BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
        border: Border.all(color: AppColors.primary, width: AppSizes.spacingTiny / 2),
      );
      textStyle = textStyle.copyWith(color: AppColors.primary);
    } else if (isToday) {
      cellDecoration = BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
        border: Border.all(color: AppColors.text.withValues(alpha: 0.25), width: AppSizes.spacingTiny / 4),
      );
      textStyle = textStyle.copyWith(color: AppColors.primary);
    }

    return GestureDetector(
      onTap: () {
        ref.read(calendarSelectedDateProvider.notifier).select(date);
      },
      child: Container(
        decoration: cellDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${date.day}', style: textStyle),
                if (totalBookings > 0 && !isSelected) ...[
                  SizedBox(width: Responsive.w(2)),
                  Container(
                    width: Responsive.w(4),
                    height: Responsive.w(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            if (summary != null) ...[
              SizedBox(height: Responsive.h(4)),
              _buildCellDots(summary, isSelected),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCellDots(CalendarDaySummary summary, bool isSelected) {
    final hasPickup = summary.startingOrders.isNotEmpty;
    final hasOngoing = summary.ongoingOrders.isNotEmpty;
    final hasReturn = summary.endingOrders.isNotEmpty;
    final hasLate = summary.hasLateReturns || summary.hasActionNeeded;

    final dotColor = isSelected ? Colors.white : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasPickup) ...[
          Container(
            width: Responsive.w(3.5),
            height: Responsive.w(3.5),
            decoration: BoxDecoration(
              color: dotColor ?? AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: Responsive.w(1.5)),
        ],
        if (hasOngoing) ...[
          Container(
            width: Responsive.w(3.5),
            height: Responsive.w(3.5),
            decoration: BoxDecoration(
              color: dotColor ?? AppColors.info,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: Responsive.w(1.5)),
        ],
        if (hasReturn) ...[
          Container(
            width: Responsive.w(3.5),
            height: Responsive.w(3.5),
            decoration: BoxDecoration(
              color: dotColor ?? AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: Responsive.w(1.5)),
        ],
        if (hasLate) ...[
          Container(
            width: Responsive.w(3.5),
            height: Responsive.w(3.5),
            decoration: BoxDecoration(
              color: dotColor ?? AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCalendarLegend() {
    return Wrap(
      spacing: Responsive.w(AppSizes.spacingMedium),
      runSpacing: Responsive.h(AppSizes.spacingTiny),
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem('Pickups', AppColors.success),
        _buildLegendItem('Ongoing', AppColors.info),
        _buildLegendItem('Returns', AppColors.warning),
        _buildLegendItem('Alerts/Late', AppColors.error),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Responsive.w(6),
          height: Responsive.w(6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: Responsive.w(4)),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(10),
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Selected Day Bookings Detail Panel ───────────────────────────────
  Widget _buildDayDetailPanel(DateTime? date, Map<String, CalendarDaySummary> summaries) {
    if (date == null) {
      return Container(
        width: double.infinity,
        padding: Responsive.all(AppSizes.spacingXXLarge),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        ),
        child: Column(
          children: [
            Icon(Icons.calendar_today_rounded, size: Responsive.icon(32), color: Colors.grey[300]),
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Text(
              'Select a date to view bookings',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontSmall),
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    final dateKey =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final summary = summaries[dateKey];

    final dateLabel = DateFormat('EEEE, MMMM d, yyyy').format(date);
    final uniqueOrdersCount = summary?.orders.length ?? 0;

    final double totalRevenue = summary?.totalRevenue ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: Responsive.r(AppSizes.radiusMedium),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: Responsive.all(AppSizes.spacingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontMedium),
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: Responsive.h(2)),
                      Text(
                        uniqueOrdersCount == 1 ? '1 order scheduled' : '$uniqueOrdersCount orders scheduled',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontTiny),
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (totalRevenue > 0)
                  Container(
                    padding: Responsive.symmetric(
                      horizontal: AppSizes.spacingSmall,
                      vertical: AppSizes.spacingTiny,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                    ),
                    child: Text(
                      '+₹${totalRevenue.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),

          if (uniqueOrdersCount == 0)
            Padding(
              padding: Responsive.all(AppSizes.spacingXXLarge),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy_rounded, size: Responsive.icon(28), color: Colors.grey[300]),
                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                    Text(
                      'No bookings on this day',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Tab Segmented Selector
            _buildTabSelector(summary),
            const Divider(color: AppColors.border, height: 1),
            // Orders List
            _buildDayOrdersList(summary),
          ],
        ],
      ),
    );
  }

  Widget _buildTabSelector(CalendarDaySummary? summary) {
    final pickupCount = summary?.startingOrders.length ?? 0;
    final ongoingCount = summary?.ongoingOrders.length ?? 0;
    final returnCount = summary?.endingOrders.length ?? 0;

    return Padding(
      padding: Responsive.all(AppSizes.spacingMedium),
      child: Container(
        padding: Responsive.all(2),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        ),
        child: Row(
          children: [
            _buildTabItem('pickups', 'Pickups', pickupCount),
            _buildTabItem('ongoing', 'Ongoing', ongoingCount),
            _buildTabItem('returns', 'Returns', returnCount),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String value, String label, int count) {
    final isActive = _activeTab == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: Responsive.symmetric(vertical: AppSizes.spacingSmall + 2),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall + 2)),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: Responsive.r(2),
                      offset: const Offset(0, 1),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontTiny),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  color: isActive ? AppColors.text : AppColors.secondaryText,
                ),
              ),
              SizedBox(width: Responsive.w(4)),
              Container(
                padding: Responsive.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(Responsive.r(10)),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: Responsive.sp(9),
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppColors.primary : AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayOrdersList(CalendarDaySummary? summary) {
    if (summary == null) return const SizedBox.shrink();

    final List<Order> filteredOrders;
    final String emptyMessage;
    final IconData emptyIcon;

    switch (_activeTab) {
      case 'pickups':
        filteredOrders = summary.startingOrders;
        emptyMessage = 'No pickups starting today';
        emptyIcon = Icons.arrow_downward_rounded;
        break;
      case 'ongoing':
        filteredOrders = summary.ongoingOrders;
        emptyMessage = 'No ongoing rentals today';
        emptyIcon = Icons.sync_rounded;
        break;
      case 'returns':
        filteredOrders = summary.endingOrders;
        emptyMessage = 'No returns due today';
        emptyIcon = Icons.arrow_upward_rounded;
        break;
      default:
        filteredOrders = [];
        emptyMessage = 'No records';
        emptyIcon = Icons.info_outline;
    }

    if (filteredOrders.isEmpty) {
      return Padding(
        padding: Responsive.all(AppSizes.spacingXXLarge),
        child: Center(
          child: Column(
            children: [
              Icon(emptyIcon, size: Responsive.icon(22), color: Colors.grey[350]),
              SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
              Text(
                emptyMessage,
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontSmall),
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: Responsive.all(AppSizes.spacingMedium),
      itemCount: filteredOrders.length,
      separatorBuilder: (context, index) => SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    final avatarLetter = order.customer?.name.isNotEmpty == true
        ? order.customer!.name.substring(0, 1).toUpperCase()
        : '?';

    final shortId = order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id;
    final startLabel = DateFormat('MMM d').format(_parseDateString(order.startDate));
    final endLabel = DateFormat('MMM d, yyyy').format(_parseDateString(order.endDate));
    final itemCount = order.items?.length ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
        border: Border.all(color: AppColors.border, width: AppSizes.spacingTiny / 4),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
        child: InkWell(
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailView(order: order),
              ),
            ).then((_) {
              ref.invalidate(calendarOrdersProvider);
            });
          },
          child: Padding(
            padding: Responsive.all(AppSizes.spacingMedium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Circle
                CircleAvatar(
                  radius: Responsive.r(20),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  child: Text(
                    avatarLetter,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Name & Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              order.customer?.name ?? 'Unknown Customer',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(order),
                        ],
                      ),
                      SizedBox(height: Responsive.h(4)),
                      // ID
                      Text(
                        'ID: $shortId',
                        style: TextStyle(
                          fontSize: Responsive.sp(10),
                          color: AppColors.secondaryText,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                      // Dates
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: Responsive.icon(12), color: Colors.grey),
                          SizedBox(width: Responsive.w(4)),
                          Text(
                            '$startLabel → $endLabel',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontTiny),
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(4)),
                      // Items count
                      Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: Responsive.icon(12), color: Colors.grey),
                          SizedBox(width: Responsive.w(4)),
                          Expanded(
                            child: Text(
                              itemCount == 1 ? '1 item' : '$itemCount items',
                              style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontTiny),
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                      // Pricing footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${order.totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium),
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          if (order.amountPaid >= order.totalAmount)
                            Text(
                              'Paid',
                              style: TextStyle(
                                fontSize: Responsive.sp(9),
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            )
                          else if (order.amountPaid > 0)
                            Text(
                              'Partial (Paid: ₹${order.amountPaid.toStringAsFixed(0)})',
                              style: TextStyle(
                                fontSize: Responsive.sp(9),
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            )
                          else
                            Text(
                              'Unpaid',
                              style: TextStyle(
                                fontSize: Responsive.sp(9),
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Order order) {
    Color bgColor;
    Color textColor;
    String label;

    switch (order.status) {
      case OrderStatus.scheduled:
      case OrderStatus.confirmed:
        bgColor = AppColors.info.withValues(alpha: 0.08);
        textColor = AppColors.info;
        label = 'Scheduled';
        break;
      case OrderStatus.ongoing:
      case OrderStatus.inUse:
        bgColor = AppColors.primary.withValues(alpha: 0.08);
        textColor = AppColors.primary;
        label = 'Ongoing';
        break;
      case OrderStatus.returned:
      case OrderStatus.completed:
        bgColor = AppColors.success.withValues(alpha: 0.08);
        textColor = AppColors.success;
        label = 'Completed';
        break;
      case OrderStatus.partial:
        bgColor = AppColors.warning.withValues(alpha: 0.08);
        textColor = AppColors.warning;
        label = 'Partial';
        break;
      case OrderStatus.flagged:
        bgColor = AppColors.error.withValues(alpha: 0.08);
        textColor = AppColors.error;
        label = 'Flagged';
        break;
      case OrderStatus.cancelled:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
        label = 'Cancelled';
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
        label = order.status.name.toUpperCase();
    }

    // Override with Late Returns if flag is active
    if (order.isLate) {
      bgColor = AppColors.error.withValues(alpha: 0.08);
      textColor = AppColors.error;
      label = 'LATE';
    }

    return Container(
      padding: Responsive.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Responsive.r(6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: Responsive.sp(9),
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  DateTime _parseDateString(String dateStr) {
    if (dateStr.length >= 10) {
      final parts = dateStr.substring(0, 10).split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    }
    return DateTime.parse(dateStr);
  }
}
