import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/viewmodels/providers/auth_provider.dart';
import '../viewmodels/providers/dashboard_provider.dart';
import '../domain/operational_card.dart';
import 'widgets/analytics_section.dart';
import '../../customers/viewmodels/providers/customer_provider.dart';
import '../../../core/providers/navigation_provider.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  int _activeTab = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _activeTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customersCacheProvider);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final operationalAsync = ref.watch(operationalMetricsProvider);
    final user = ref.watch(authUserProvider);
    final isAdmin = user != null && user.isAdmin;

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final padding = screenWidth * DashboardConstants.screenPaddingPercent;
                final bottomPadding = MediaQuery.of(context).padding.bottom;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: padding,
                        right: padding,
                        top: padding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPageHeader(screenWidth),
                          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                          if (isAdmin) ...[
                            _buildTabBar(screenWidth),
                            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: !isAdmin
                          ? RefreshIndicator(
                              onRefresh: () async {
                                ref.invalidate(operationalMetricsProvider);
                              },
                              color: AppColors.primary,
                              backgroundColor: Colors.white,
                              child: CustomScrollView(
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: padding,
                                        right: padding,
                                        bottom: padding + bottomPadding + screenWidth * 0.02,
                                      ),
                                      child: operationalAsync.when(
                                        data: (metrics) => _buildDashboardContent(metrics, screenWidth),
                                        loading: () => _buildLoadingState(screenWidth),
                                        error: (error, stack) => _buildErrorState(error, stack, screenWidth),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _activeTab = index;
                                });
                              },
                              children: [
                                // Page 0: Operations
                                RefreshIndicator(
                                  onRefresh: () async {
                                    ref.invalidate(operationalMetricsProvider);
                                  },
                                  color: AppColors.primary,
                                  backgroundColor: Colors.white,
                                  child: CustomScrollView(
                                    slivers: [
                                      SliverToBoxAdapter(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: padding,
                                            right: padding,
                                            bottom: padding + bottomPadding + screenWidth * 0.02,
                                          ),
                                          child: operationalAsync.when(
                                            data: (metrics) => _buildDashboardContent(metrics, screenWidth),
                                            loading: () => _buildLoadingState(screenWidth),
                                            error: (error, stack) => _buildErrorState(error, stack, screenWidth),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Page 1: Analytics
                                RefreshIndicator(
                                  onRefresh: () async {
                                    ref.invalidate(analyticsMetricsProvider);
                                    ref.invalidate(categoryRevenueProvider);
                                    ref.invalidate(inventoryRoiProvider);
                                  },
                                  color: AppColors.primary,
                                  backgroundColor: Colors.white,
                                  child: CustomScrollView(
                                    slivers: [
                                      SliverToBoxAdapter(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: padding,
                                            right: padding,
                                            bottom: padding + bottomPadding + screenWidth * 0.02,
                                          ),
                                          child: const AnalyticsSection(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                );
              },
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
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          ...pendingCards.map((card) => _buildWarningActionCard(card, screenWidth)),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
        ],
        _buildSectionHeader(AppStrings.allOperations, Icons.dashboard_rounded, AppColors.text, screenWidth),
        SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: Responsive.w(AppSizes.spacingMedium),
            mainAxisSpacing: Responsive.h(AppSizes.spacingMedium),
            childAspectRatio: 1.25,
          ),
          itemCount: clearCards.length,
          itemBuilder: (context, index) {
            return _buildGridActionCard(clearCards[index], screenWidth);
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, double screenWidth) {
    return Row(
      children: [
        Icon(icon, size: Responsive.icon(AppSizes.iconSmall), color: color),
        SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
        Expanded(
          child: AutoSizeText(
            title,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontMedium),
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

  Widget _buildWarningActionCard(OperationalCard card, double screenWidth) {
    final color = _getColorForCard(card.color);
    final hasValue = card.orderCount > 0 ||
                     (card.isProgressCard && card.totalCount! > 0) ||
                     (card.amount != null && card.amount! > 0);
    
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(AppSizes.spacingSmall)),
      height: Responsive.h(85),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.04),
            blurRadius: Responsive.r(AppSizes.spacingSmall),
            offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: AppSizes.spacingTiny / 4,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left status highlight stripe
            Container(
              width: Responsive.w(4),
              color: color,
            ),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => navigateToOrdersWithUrl(ref, card.filterUrl),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(Responsive.r(AppSizes.radiusMedium)),
                    bottomRight: Radius.circular(Responsive.r(AppSizes.radiusMedium)),
                  ),
                  child: Padding(
                    padding: Responsive.symmetric(
                      horizontal: AppSizes.spacingLarge,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: Responsive.w(AppSizes.spacingXXLarge * 1.5),
                          height: Responsive.h(AppSizes.spacingXXLarge * 1.5),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                          ),
                          child: Icon(
                            _getIconForCard(card.icon),
                            color: color,
                            size: Responsive.icon(AppSizes.iconTiny),
                          ),
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                card.label,
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontSmall),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                              AutoSizeText(
                                card.statusText,
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontTiny),
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                        if (hasValue)
                          Container(
                            padding: Responsive.symmetric(
                              horizontal: AppSizes.spacingMedium,
                              vertical: AppSizes.spacingSmall,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                            ),
                            child: Text(
                              card.isProgressCard
                                  ? '${card.completedCount}/${card.totalCount}'
                                  : card.amount != null
                                      ? CurrencyFormatter.formatINR(card.amount!)
                                      : card.orderCount.toString(),
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontMedium),
                                fontWeight: FontWeight.w900,
                                color: color,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: Responsive.icon(AppSizes.iconMedium),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridActionCard(OperationalCard card, double screenWidth) {
    final color = _getColorForCard(card.color);
    final hasValue = card.orderCount > 0 ||
                     (card.isProgressCard && card.totalCount! > 0) ||
                     (card.amount != null && card.amount! > 0);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: Responsive.r(AppSizes.spacingSmall),
            offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
          ),
        ],
        border: Border.all(
          color: AppColors.border,
          width: AppSizes.spacingTiny / 4,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => navigateToOrdersWithUrl(ref, card.filterUrl),
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
          child: Padding(
            padding: Responsive.all(AppSizes.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: Responsive.w(AppSizes.spacingXXLarge * 1.5),
                      height: Responsive.h(AppSizes.spacingXXLarge * 1.5),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                      ),
                      child: Icon(
                        _getIconForCard(card.icon),
                        color: color,
                        size: Responsive.icon(AppSizes.iconTiny),
                      ),
                    ),
                    if (hasValue)
                      Container(
                        padding: Responsive.symmetric(
                          horizontal: AppSizes.spacingSmall,
                          vertical: AppSizes.spacingTiny,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                        ),
                        child: Text(
                          card.isProgressCard
                              ? '${card.completedCount}/${card.totalCount}'
                              : card.amount != null
                                  ? CurrencyFormatter.formatINR(card.amount!)
                                  : card.orderCount.toString(),
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: Responsive.icon(AppSizes.iconSmall),
                      ),
                  ],
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      card.label,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                    AutoSizeText(
                      card.statusText,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          _buildShimmerWarningCard(screenWidth),
          _buildShimmerWarningCard(screenWidth),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          _buildShimmerSectionHeader(screenWidth),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: Responsive.w(AppSizes.spacingMedium),
              mainAxisSpacing: Responsive.h(AppSizes.spacingMedium),
              childAspectRatio: 1.25,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return _buildShimmerGridCard(screenWidth);
            },
          ),
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

  Widget _buildShimmerWarningCard(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(AppSizes.spacingSmall)),
      height: Responsive.h(85),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
      ),
    );
  }

  Widget _buildShimmerGridCard(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
      ),
    );
  }

  Widget _buildErrorState(Object error, StackTrace? stack, double screenWidth) {
    debugPrint('[DashboardView] Error: $error');
    debugPrint('[DashboardView] Stack: $stack');
    
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

  Widget _buildTabBar(double screenWidth) {
    return Container(
      padding: Responsive.all(AppSizes.spacingTiny),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        border: Border.all(
          color: AppColors.border,
          width: AppSizes.spacingTiny / 4,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: Responsive.symmetric(
                  vertical: AppSizes.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: _activeTab == 0 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                  boxShadow: _activeTab == 0
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: Responsive.r(AppSizes.spacingTiny),
                            offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dashboard_rounded,
                      size: Responsive.icon(AppSizes.iconTiny),
                      color: _activeTab == 0 ? Colors.white : AppColors.secondaryText,
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                    Text(
                      'Operations',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        fontWeight: _activeTab == 0 ? FontWeight.bold : FontWeight.w500,
                        color: _activeTab == 0 ? Colors.white : AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: Responsive.symmetric(
                  vertical: AppSizes.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: _activeTab == 1 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                  boxShadow: _activeTab == 1
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: Responsive.r(AppSizes.spacingTiny),
                            offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: Responsive.icon(AppSizes.iconTiny),
                      color: _activeTab == 1 ? Colors.white : AppColors.secondaryText,
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                    Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        fontWeight: _activeTab == 1 ? FontWeight.bold : FontWeight.w500,
                        color: _activeTab == 1 ? Colors.white : AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
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
