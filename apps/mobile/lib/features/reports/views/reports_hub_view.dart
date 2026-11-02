import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import 'day_wise_booking_report_view.dart';
import 'top_costumes_report_view.dart';

/// A report entry on the hub screen
class ReportEntry {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final WidgetBuilder builder;

  const ReportEntry({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.builder,
  });
}

/// Reports Hub View
///
/// Landing screen for business reports. New reports plug in by adding
/// entries to the list below.
class ReportsHubView extends StatelessWidget {
  const ReportsHubView({super.key});

  List<ReportEntry> get _reports => [
        ReportEntry(
          title: AppStrings.dayWiseBooking,
          description: AppStrings.dayWiseBookingDesc,
          icon: Icons.event_available_rounded,
          iconColor: AppColors.info,
          builder: (context) => const DayWiseBookingReportView(),
        ),
        ReportEntry(
          title: AppStrings.topCostumes,
          description: AppStrings.topCostumesDesc,
          icon: Icons.emoji_events_rounded,
          iconColor: AppColors.gold,
          builder: (context) => const TopCostumesReportView(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          AppStrings.reports,
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
      body: ListView(
        padding: Responsive.all(AppSizes.spacingLarge),
        children: [
          Text(
            'Select a report to analyze your business performance.',
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontMedium),
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          ..._reports.map((report) => Padding(
                padding: Responsive.only(bottom: AppSizes.spacingMedium),
                child: _buildReportCard(context, report),
              )),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ReportEntry report) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: report.builder),
      ),
      child: Container(
        padding: Responsive.all(AppSizes.spacingLarge),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
          border: Border.all(
            color: AppColors.border,
            width: AppSizes.spacingTiny / 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: Responsive.r(AppSizes.spacingSmall),
              offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: Responsive.icon(AppSizes.iconXLarge),
              height: Responsive.icon(AppSizes.iconXLarge),
              decoration: BoxDecoration(
                color: report.iconColor.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
              ),
              child: Icon(
                report.icon,
                size: Responsive.icon(AppSizes.iconMedium),
                color: report.iconColor,
              ),
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                  Text(
                    report.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontSmall),
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
            Icon(
              Icons.chevron_right_rounded,
              size: Responsive.icon(AppSizes.iconMedium),
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
