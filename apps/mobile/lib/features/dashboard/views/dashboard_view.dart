import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../viewmodels/providers/dashboard_provider.dart';
import '../domain/operational_card.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final operationalAsync = ref.watch(operationalMetricsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: DashboardConstants.gradientTopLeftOpacity),
              AppColors.primary.withValues(alpha: DashboardConstants.gradientMidOpacity),
              AppColors.primary.withValues(alpha: DashboardConstants.gradientBottomOpacity),
              Colors.white,
            ],
            stops: const [0.0, 0.2, 0.5, 1.0],
          ),
        ),
        child: CustomPaint(
          painter: MeshGradientPainter(AppColors.primary),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(operationalMetricsProvider),
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final padding = screenWidth * DashboardConstants.screenPaddingPercent;
                  final bottomPadding = MediaQuery.of(context).padding.bottom;
                  
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: padding,
                            right: padding,
                            top: padding,
                            bottom: padding + bottomPadding + screenWidth * 0.02,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPageHeader(screenWidth),
                              SizedBox(height: screenWidth * 0.025),
                              operationalAsync.when(
                                data: (metrics) => _buildDashboardContent(metrics, screenWidth),
                                loading: () => _buildLoadingState(screenWidth),
                                error: (error, stack) => _buildErrorState(error, stack, screenWidth),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          AppStrings.appName,
          style: TextStyle(
            fontSize: screenWidth * 0.055,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: screenWidth * 0.006),
        AutoSizeText(
          AppStrings.todaysOverview,
          style: TextStyle(
            fontSize: screenWidth * 0.032,
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDashboardContent(OperationalMetrics metrics, double screenWidth) {
    final pendingCards = metrics.cards.where((c) => c.hasWarning).toList();
    final clearCards = metrics.cards.where((c) => !c.hasWarning).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pendingCards.isNotEmpty) ...[
          _buildSectionHeader(AppStrings.pendingTasks, Icons.warning_amber_rounded, AppColors.warning, screenWidth),
          SizedBox(height: screenWidth * 0.015),
          ...pendingCards.map((card) => _buildCompactActionCard(card)),
          SizedBox(height: screenWidth * DashboardConstants.sectionSpacingPercent),
        ],
        _buildSectionHeader(AppStrings.allOperations, Icons.dashboard, AppColors.text, screenWidth),
        SizedBox(height: screenWidth * 0.015),
        ...clearCards.map((card) => _buildCompactActionCard(card)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, double screenWidth) {
    return Row(
      children: [
        Icon(icon, size: screenWidth * 0.05, color: color),
        SizedBox(width: screenWidth * 0.02),
        Expanded(
          child: AutoSizeText(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactActionCard(OperationalCard card) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final cardHeight = screenWidth * DashboardConstants.cardHeightPercent;
        final iconSize = screenWidth * DashboardConstants.iconSizePercent;
        final spacing = screenWidth * DashboardConstants.cardSpacingPercent;
        final color = _getColorForCard(card.color);
        final hasValue = card.orderCount > 0 || (card.isProgressCard && card.totalCount! > 0);
        
        return Container(
          margin: EdgeInsets.only(bottom: screenWidth * DashboardConstants.cardBottomMarginPercent),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(cardHeight * 0.12),
            elevation: card.hasWarning ? 2 : 1,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(cardHeight * 0.12),
              child: Container(
                height: cardHeight,
                padding: EdgeInsets.all(spacing),
                child: Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(iconSize * 0.2),
                      ),
                      child: Icon(
                        _getIconForCard(card.icon),
                        color: color,
                        size: iconSize * 0.45,
                      ),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: ClipRect(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AutoSizeText(
                              card.label,
                              style: TextStyle(
                                fontSize: iconSize * 0.28,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AutoSizeText(
                              card.statusText,
                              style: TextStyle(
                                fontSize: iconSize * 0.24,
                                color: AppColors.secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (hasValue)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing * 0.6,
                      vertical: spacing * 0.25,
                    ),
                    decoration: BoxDecoration(
                      color: card.hasWarning ? color.withValues(alpha: 0.15) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(iconSize * 0.15),
                    ),
                    child: AutoSizeText(
                      card.isProgressCard
                          ? '${card.completedCount}/${card.totalCount}'
                          : card.orderCount.toString(),
                      style: TextStyle(
                        fontSize: iconSize * 0.38,
                        fontWeight: FontWeight.bold,
                        color: card.hasWarning ? color : AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: iconSize * 0.45,
                  ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getColorForCard(String colorName) {
    switch (colorName) {
      case 'blue': return Colors.blue;
      case 'emerald': return Colors.green;
      case 'violet': return Colors.purple;
      case 'amber': return Colors.amber;
      case 'rose': return Colors.red;
      case 'red': return Colors.red;
      case 'indigo': return Colors.indigo;
      default: return AppColors.primary;
    }
  }

  IconData _getIconForCard(String iconName) {
    switch (iconName) {
      case 'calendar-plus': return Icons.calendar_today;
      case 'truck': return Icons.local_shipping;
      case 'package-check': return Icons.inventory_2;
      case 'boxes': return Icons.inventory;
      case 'alert-triangle': return Icons.warning;
      case 'clock-alert': return Icons.access_time;
      case 'banknote': return Icons.account_balance_wallet;
      default: return Icons.info;
    }
  }


  Widget _buildLoadingState(double screenWidth) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerSectionHeader(screenWidth),
          SizedBox(height: screenWidth * 0.015),
          _buildShimmerCompactCard(screenWidth),
          _buildShimmerCompactCard(screenWidth),
          SizedBox(height: screenWidth * 0.03),
          _buildShimmerSectionHeader(screenWidth),
          SizedBox(height: screenWidth * 0.015),
          _buildShimmerCompactCard(screenWidth),
          _buildShimmerCompactCard(screenWidth),
          _buildShimmerCompactCard(screenWidth),
        ],
      ),
    );
  }

  Widget _buildShimmerSectionHeader(double screenWidth) {
    return Container(
      width: screenWidth * 0.35,
      height: screenWidth * 0.05,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.01),
      ),
    );
  }

  Widget _buildShimmerCompactCard(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * DashboardConstants.cardBottomMarginPercent),
      height: screenWidth * DashboardConstants.cardHeightPercent,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
      ),
    );
  }

  Widget _buildErrorState(Object error, StackTrace? stack, double screenWidth) {
    print('[DashboardView] Error: $error');
    print('[DashboardView] Stack: $stack');
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.06),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: screenWidth * 0.12, color: AppColors.error),
          SizedBox(height: screenWidth * 0.04),
          AutoSizeText(
            AppStrings.unableToLoadDashboard,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: screenWidth * 0.02),
          AutoSizeText(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: AppColors.secondaryText,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: screenWidth * 0.04),
          SizedBox(
            width: double.infinity,
            height: screenWidth * 0.12,
            child: ElevatedButton(
              onPressed: () => ref.invalidate(operationalMetricsProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
              child: AutoSizeText(
                AppStrings.retry,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MeshGradientPainter extends CustomPainter {
  final Color baseColor;

  MeshGradientPainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = baseColor.withValues(alpha: DashboardConstants.meshPaintOpacity);

    // Draw mesh-like pattern
    final path = Path();
    final gridSize = DashboardConstants.meshGridSize;
    
    for (double y = 0; y < size.height; y += gridSize) {
      for (double x = 0; x < size.width; x += gridSize) {
        // Create subtle wave pattern
        final offsetX = x + (y % (gridSize * 2) == 0 ? 0 : gridSize / 2);
        final offsetY = y;
        
        // Draw diamond shapes
        path.moveTo(offsetX + gridSize / 2, offsetY);
        path.lineTo(offsetX + gridSize, offsetY + gridSize / 2);
        path.lineTo(offsetX + gridSize / 2, offsetY + gridSize);
        path.lineTo(offsetX, offsetY + gridSize / 2);
        path.close();
      }
    }
    
    canvas.drawPath(path, paint);

    // Add subtle dots
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = baseColor.withValues(alpha: DashboardConstants.meshDotPaintOpacity);

    for (double y = 0; y < size.height; y += gridSize * 2) {
      for (double x = 0; x < size.width; x += gridSize * 2) {
        canvas.drawCircle(Offset(x, y), DashboardConstants.meshDotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
