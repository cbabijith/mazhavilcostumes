import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../domain/top_costume.dart';
import '../viewmodels/providers/reports_provider.dart';

/// Top Costumes Report View
///
/// Ranks costumes by rental count or lifetime revenue.
class TopCostumesReportView extends ConsumerStatefulWidget {
  const TopCostumesReportView({super.key});

  @override
  ConsumerState<TopCostumesReportView> createState() =>
      _TopCostumesReportViewState();
}

class _TopCostumesReportViewState extends ConsumerState<TopCostumesReportView> {
  TopCostumeRank _rank = TopCostumeRank.count;

  Future<void> _refresh() {
    return ref.refresh(
      topCostumesProvider(TopCostumesParam(rank: _rank, limit: 20)).future,
    );
  }

  @override
  Widget build(BuildContext context) {
    final param = TopCostumesParam(rank: _rank, limit: 20);
    final reportAsync = ref.watch(topCostumesProvider(param));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          AppStrings.topCostumes,
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
          _buildRankToggle(),
          Expanded(
            child: reportAsync.when(
              data: (costumes) => _buildContent(costumes),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, stack) => _buildErrorState(error, param),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankToggle() {
    return Container(
      color: Colors.white,
      padding: Responsive.symmetric(
        horizontal: AppSizes.spacingMedium,
        vertical: AppSizes.spacingSmall,
      ),
      child: Row(
        children: TopCostumeRank.values.map((rank) {
          final isSelected = rank == _rank;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _rank = rank),
              child: Container(
                margin: Responsive.only(
                  left: rank == TopCostumeRank.count ? 0 : AppSizes.spacingTiny / 2,
                  right: rank == TopCostumeRank.revenue ? 0 : AppSizes.spacingTiny / 2,
                ),
                padding: Responsive.symmetric(vertical: AppSizes.spacingSmall),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.scaffoldBackground,
                  borderRadius:
                      BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.border,
                    width: AppSizes.spacingTiny / 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    rank.label,
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
    );
  }

  Widget _buildContent(List<TopCostume> costumes) {
    if (costumes.isEmpty) {
      return _buildEmptyState();
    }

    final totalRentals =
        costumes.fold<int>(0, (sum, costume) => sum + costume.rentalCount);
    final totalRevenue =
        costumes.fold<double>(0, (sum, costume) => sum + costume.revenue);

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primary,
      child: ListView(
        padding: Responsive.all(AppSizes.spacingLarge),
        children: [
          _buildSummaryCard(
            costumeCount: costumes.length,
            totalRentals: totalRentals,
            totalRevenue: totalRevenue,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          Text(
            'Ranking (${_rank.label})',
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontMedium),
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          ...costumes.asMap().entries.map(
                (entry) => Padding(
                  padding: Responsive.only(bottom: AppSizes.spacingSmall),
                  child: _buildCostumeCard(entry.key + 1, entry.value),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required int costumeCount,
    required int totalRentals,
    required double totalRevenue,
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
                  'Top $costumeCount Costumes',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                Text(
                  '$totalRentals total rentals',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontXLarge),
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
                  'Combined Revenue',
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
                    CurrencyFormatter.formatINR(totalRevenue),
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontXLarge),
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

  Widget _buildCostumeCard(int rank, TopCostume costume) {
    // Medal colors for the top 3, neutral badge afterwards
    Color rankColor;
    IconData? rankIcon;
    if (rank == 1) {
      rankColor = AppColors.gold;
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 2) {
      rankColor = AppColors.silver;
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 3) {
      rankColor = AppColors.bronze;
      rankIcon = Icons.emoji_events_rounded;
    } else {
      rankColor = AppColors.secondaryText;
    }

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
        children: [
          Container(
            width: Responsive.icon(AppSizes.iconLarge),
            height: Responsive.icon(AppSizes.iconLarge),
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rankIcon != null
                  ? Icon(
                      rankIcon,
                      size: Responsive.icon(AppSizes.iconMedium),
                      color: rankColor,
                    )
                  : Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontMedium),
                        fontWeight: FontWeight.w900,
                        color: rankColor,
                      ),
                    ),
            ),
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  costume.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontMedium),
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                if (costume.categoryName.isNotEmpty) ...[
                  SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                  Text(
                    costume.categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontTiny),
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                Text(
                  '${costume.rentalCount} ${AppStrings.rentals} · ${costume.avgRentalDays} ${AppStrings.avgDays}',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontTiny),
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
          Text(
            CurrencyFormatter.formatINR(costume.revenue),
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontLarge),
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
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
              Icons.checkroom_rounded,
              size: Responsive.icon(AppSizes.iconHuge),
              color: AppColors.secondaryText.withValues(alpha: 0.3),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            Text(
              AppStrings.noCostumesFound,
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontLarge),
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, TopCostumesParam param) {
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
              onPressed: () => ref.refresh(topCostumesProvider(param)),
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
