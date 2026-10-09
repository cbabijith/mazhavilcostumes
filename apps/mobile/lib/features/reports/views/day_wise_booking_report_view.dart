import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../domain/day_wise_booking.dart';
import '../viewmodels/providers/reports_provider.dart';

/// Date range presets for the day-wise booking report
enum BookingReportRange {
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  thisYear('This Year');

  final String label;
  const BookingReportRange(this.label);
}

/// Day-wise Booking Report View
///
/// Shows the daily pickup/delivery schedule (orders by start date) with
/// customer contact, products, rental period, amount and status.
class DayWiseBookingReportView extends ConsumerStatefulWidget {
  const DayWiseBookingReportView({super.key});

  @override
  ConsumerState<DayWiseBookingReportView> createState() =>
      _DayWiseBookingReportViewState();
}

class _DayWiseBookingReportViewState
    extends ConsumerState<DayWiseBookingReportView> {
  BookingReportRange _range = BookingReportRange.today;

  Map<String, String> _datesForRange(BookingReportRange range) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    switch (range) {
      case BookingReportRange.today:
        return {'fromDate': today, 'toDate': today};
      case BookingReportRange.thisWeek:
        // Monday-start week (matches the analytics section)
        final diff = now.weekday - DateTime.monday;
        final monday = now.subtract(Duration(days: diff));
        return {
          'fromDate': DateFormat('yyyy-MM-dd').format(monday),
          'toDate': today,
        };
      case BookingReportRange.thisMonth:
        final first = DateTime(now.year, now.month, 1);
        final last = DateTime(now.year, now.month + 1, 0);
        return {
          'fromDate': DateFormat('yyyy-MM-dd').format(first),
          'toDate': DateFormat('yyyy-MM-dd').format(last),
        };
      case BookingReportRange.thisYear:
        final first = DateTime(now.year, 1, 1);
        final last = DateTime(now.year, 12, 31);
        return {
          'fromDate': DateFormat('yyyy-MM-dd').format(first),
          'toDate': DateFormat('yyyy-MM-dd').format(last),
        };
    }
  }

  Future<void> _refresh() {
    final dates = _datesForRange(_range);
    return ref.refresh(
      dayWiseBookingsProvider(
        DayWiseBookingParam(
          fromDate: dates['fromDate']!,
          toDate: dates['toDate']!,
        ),
      ).future,
    );
  }

  Future<void> _callCustomer(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = _datesForRange(_range);
    final param = DayWiseBookingParam(
      fromDate: dates['fromDate']!,
      toDate: dates['toDate']!,
    );
    final reportAsync = ref.watch(dayWiseBookingsProvider(param));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          AppStrings.dayWiseBooking,
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.sp(AppSizes.fontLarge),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: AppSizes.spacingTiny / 4,
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: Column(
        children: [
          _buildRangeChips(),
          Expanded(
            child: reportAsync.when(
              data: (bookings) => _buildContent(bookings),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeChips() {
    return Container(
      color: Colors.white,
      padding: Responsive.symmetric(
        horizontal: AppSizes.spacingMedium,
        vertical: AppSizes.spacingSmall,
      ),
      child: SizedBox(
        height: Responsive.h(AppSizes.spacingXXLarge + AppSizes.spacingXXXLarge),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: BookingReportRange.values.map((range) {
            final isSelected = range == _range;
            return Padding(
              padding: Responsive.only(right: AppSizes.spacingSmall),
              child: GestureDetector(
                onTap: () => setState(() => _range = range),
                child: Container(
                  padding: Responsive.symmetric(
                    horizontal: AppSizes.spacingMedium,
                    vertical: AppSizes.spacingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(
                        Responsive.r(AppSizes.spacingHuge)),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: AppSizes.spacingTiny / 4,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      range.label,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected ? Colors.white : AppColors.secondaryText,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent(List<DayWiseBooking> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState();
    }

    // Group bookings by start date (chronological)
    final grouped = <String, List<DayWiseBooking>>{};
    for (final booking in bookings) {
      final key = DateFormat('yyyy-MM-dd').format(booking.startDate);
      (grouped[key] ??= []).add(booking);
    }
    final sortedDays = grouped.keys.toList()..sort();

    final totalValue = bookings.fold<double>(
      0,
      (sum, booking) => sum + booking.totalAmount,
    );

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primary,
      child: ListView(
        padding: Responsive.all(AppSizes.spacingLarge),
        children: [
          _buildSummaryCard(
            orderCount: bookings.length,
            totalValue: totalValue,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          ...sortedDays.map((day) => _buildDaySection(day, grouped[day]!)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required int orderCount,
    required double totalValue,
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bookings',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                Text(
                  '$orderCount orders',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontXXLarge),
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total Value',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    CurrencyFormatter.formatINR(totalValue),
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontXXLarge),
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(String day, List<DayWiseBooking> bookings) {
    String header;
    try {
      final parsed = DateTime.parse(day);
      final label = DateFormat('EEE, dd MMM yyyy').format(parsed);
      final todayStr =
          DateFormat('yyyy-MM-dd').format(DateTime.now());
      header = day == todayStr ? 'Today · $label' : label;
    } catch (_) {
      header = day;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: Responsive.only(
            top: AppSizes.spacingSmall,
            bottom: AppSizes.spacingSmall,
          ),
          child: Text(
            '$header (${bookings.length})',
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontMedium),
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
        ...bookings.map((booking) => Padding(
              padding: Responsive.only(bottom: AppSizes.spacingSmall),
              child: _buildBookingCard(booking),
            )),
      ],
    );
  }

  Widget _buildBookingCard(DayWiseBooking booking) {
    final period =
        '${DateFormat('dd MMM').format(booking.startDate)} → ${DateFormat('dd MMM').format(booking.endDate)}';

    return Container(
      padding: Responsive.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
        border: Border.all(
          color: AppColors.border,
          width: AppSizes.spacingTiny / 4,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontMedium),
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    _buildStatusBadge(booking.status),
                  ],
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                Text(
                  booking.productNames,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontTiny),
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatINR(booking.totalAmount),
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontLarge),
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
              if (booking.customerPhone.isNotEmpty)
                GestureDetector(
                  onTap: () => _callCustomer(booking.customerPhone),
                  child: Container(
                    padding: Responsive.all(AppSizes.spacingTiny),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.call_rounded,
                      size: Responsive.icon(AppSizes.iconTiny),
                      color: AppColors.info,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor = AppColors.secondaryText.withValues(alpha: 0.1);
    Color textColor = AppColors.secondaryText;

    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'completed' || lowerStatus == 'returned') {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
    } else if (lowerStatus == 'ongoing' ||
        lowerStatus == 'in_use' ||
        lowerStatus == 'delivered') {
      bgColor = AppColors.info.withValues(alpha: 0.1);
      textColor = AppColors.info;
    } else if (lowerStatus == 'cancelled') {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      textColor = AppColors.error;
    } else if (lowerStatus == 'scheduled' ||
        lowerStatus == 'confirmed' ||
        lowerStatus == 'pending') {
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      textColor = AppColors.warning;
    }

    return Container(
      padding: Responsive.symmetric(
        horizontal: AppSizes.spacingSmall,
        vertical: AppSizes.spacingTiny / 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius:
            BorderRadius.circular(Responsive.r(AppSizes.radiusSmall / 2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: Responsive.sp(AppSizes.fontTiny - 1),
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: Responsive.all(AppSizes.spacingHuge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: Responsive.icon(AppSizes.iconHuge),
              color: AppColors.secondaryText.withValues(alpha: 0.3),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            Text(
              AppStrings.noBookingsFound,
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontLarge),
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Text(
              'Bookings starting in ${_range.label.toLowerCase()} will appear here.',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontMedium),
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: Responsive.all(AppSizes.spacingHuge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: Responsive.icon(AppSizes.iconHuge),
              color: AppColors.error,
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            Text(
              AppStrings.failedToLoadReport,
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontLarge),
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontMedium),
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: Icon(
                Icons.refresh_rounded,
                size: Responsive.icon(AppSizes.iconSmall),
              ),
              label: const Text(AppStrings.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: Responsive.symmetric(
                  horizontal: AppSizes.spacingLarge,
                  vertical: AppSizes.spacingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
