import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/viewmodels/providers/auth_provider.dart';
import '../providers/product_details_provider.dart';
import '../models/product.dart';
import '../models/product_analytics.dart';
import '../models/damage_record.dart';
import '../models/product_availability.dart';

/// Product detail view — image carousel, pricing, stock, and quick actions.
class ProductDetailView extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailView({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends ConsumerState<ProductDetailView> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final user = ref.watch(authUserProvider);
    final isAdminOrManager = user?.canManage ?? false;
    final detailsAsync = ref.watch(productDetailsProvider(widget.productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailsAsync.when(
        data: (state) => _buildBody(context, state, isAdminOrManager),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildErrorState(context, e),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object e) {
    return Center(
      child: Padding(
        padding: Responsive.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: Responsive.icon(48), color: Colors.red[300]),
            SizedBox(height: Responsive.h(12)),
            Text('Failed to load product',
                style: TextStyle(
                    fontSize: Responsive.sp(16),
                    fontWeight: FontWeight.bold)),
            SizedBox(height: Responsive.h(8)),
            Text(e.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: Responsive.sp(12),
                    color: Colors.grey[600]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            SizedBox(height: Responsive.h(16)),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.invalidate(productDetailsProvider(widget.productId)),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductDetailsState state,
      bool isAdminOrManager) {
    final product = state.product;
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(product, isAdminOrManager),
        SliverToBoxAdapter(
          child: Padding(
            padding: Responsive.all(AppSizes.screenPaddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(product),
                SizedBox(height: Responsive.h(16)),
                _buildMetricsGrid(state, isAdminOrManager),
                SizedBox(height: Responsive.h(16)),
                if (isAdminOrManager) ...[
                  _buildAnalyticsSection(state.analytics),
                  SizedBox(height: Responsive.h(16)),
                ],
                _buildGeneralInfoCard(product),
                SizedBox(height: Responsive.h(16)),
                _buildBranchStockSection(state.branchInventory, product),
                SizedBox(height: Responsive.h(16)),
                _buildCalendarSection(state.availability),
                SizedBox(height: Responsive.h(16)),
                if (state.analytics?.items.isNotEmpty ?? false) ...[
                  _buildRentalHistorySection(state.analytics!.items),
                  SizedBox(height: Responsive.h(16)),
                ],
                if (isAdminOrManager && state.damageHistory.isNotEmpty) ...[
                  _buildDamageHistorySection(state.damageHistory),
                  SizedBox(height: Responsive.h(16)),
                ],
                SizedBox(height: Responsive.h(100)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(
      Product product, bool isAdminOrManager) {
    return SliverAppBar(
      expandedHeight: Responsive.h(320),
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Container(
          padding: Responsive.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back_rounded, size: Responsive.icon(22)),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (product.barcode != null && product.barcode!.isNotEmpty)
          IconButton(
            icon: Icon(Icons.qr_code_rounded, size: Responsive.icon(22)),
            tooltip: 'Print Barcode',
            onPressed: () => _showBarcodeDialog(product),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            if (product.images.isNotEmpty)
              PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentImageIndex = i),
                itemCount: product.images.length,
                itemBuilder: (context, i) {
                  final img = product.images[i];
                  return CachedNetworkImage(
                    imageUrl: img.url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: AppColors.primary.withValues(alpha: 0.1)),
                    errorWidget: (context, url, error) => _buildPlaceholderImage(),
                  );
                },
              )
            else
              _buildPlaceholderImage(),
            if (product.images.length > 1)
              Positioned(
                bottom: Responsive.h(12),
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(product.images.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin:
                          EdgeInsets.symmetric(horizontal: Responsive.w(3)),
                      width: i == _currentImageIndex
                          ? Responsive.w(20)
                          : Responsive.w(7),
                      height: Responsive.h(6),
                      decoration: BoxDecoration(
                        color: i == _currentImageIndex
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(Responsive.r(3)),
                      ),
                    );
                  }),
                ),
              ),
            Positioned(
              top: Responsive.h(50),
              right: Responsive.w(12),
              child: Wrap(
                spacing: Responsive.w(6),
                children: [
                  _buildStatusBadge(product),
                  if (product.isFeatured)
                    _buildPillBadge('Featured', const Color(0xFFF5A623)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(Icons.inventory_2_outlined,
            size: Responsive.icon(64), color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildStatusBadge(Product product) {
    final stock = product.availableQuantity;

    Color bgColor;
    String label;
    if (!product.isActive) {
      bgColor = Colors.grey;
      label = 'Inactive';
    } else if (stock <= 0) {
      bgColor = const Color(0xFFFF6B8A);
      label = 'Out of Stock';
    } else if (stock <= product.lowStockThreshold) {
      bgColor = const Color(0xFFF5A623);
      label = 'Low Stock';
    } else {
      bgColor = const Color(0xFF2ECC71);
      label = 'Available';
    }

    return _buildPillBadge(label, bgColor);
  }

  Widget _buildPillBadge(String label, Color bgColor) {
    return Container(
      padding: Responsive.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Responsive.r(8)),
        boxShadow: [
          BoxShadow(
              color: bgColor.withValues(alpha: 0.4),
              blurRadius: Responsive.r(8))
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: Responsive.sp(11),
            fontWeight: FontWeight.w700,
            color: Colors.white),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: Responsive.sp(14),
          fontWeight: FontWeight.w700,
          color: AppColors.primary),
    );
  }

  Widget _buildPriceItem(String label, String value, Color color) {
    return Container(
      padding: Responsive.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Responsive.r(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: Responsive.sp(11), color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: Responsive.h(4)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                  fontSize: Responsive.sp(20),
                  fontWeight: FontWeight.w800,
                  color: color == AppColors.warning ? const Color(0xFFD4A540) : AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          product.name,
          style: TextStyle(
            fontSize: Responsive.sp(22),
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
          maxLines: 2,
          minFontSize: 14,
          overflow: TextOverflow.ellipsis,
        ),
        if (product.sku != null && product.sku!.isNotEmpty) ...[
          SizedBox(height: Responsive.h(4)),
          Text(
            'SKU: ${product.sku}',
            style: TextStyle(
                fontSize: Responsive.sp(12),
                color: Colors.grey[500],
                fontFamily: 'monospace'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (product.categoryName != null) ...[
          SizedBox(height: Responsive.h(4)),
          Text(
            product.categoryName!,
            style: TextStyle(
                fontSize: Responsive.sp(12), color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildMetricsGrid(
      ProductDetailsState state, bool isAdminOrManager) {
    final product = state.product;
    final analytics = state.analytics;
    final items = [
      if (isAdminOrManager)
        _MetricItem(
          label: 'Lifetime Revenue',
          value: analytics != null
              ? '₹${analytics.totalRevenue.toStringAsFixed(0)}'
              : '—',
          color: const Color(0xFF2ECC71),
          icon: Icons.account_balance_wallet_outlined,
        ),
      _MetricItem(
        label: 'Active Rentals',
        value: '${analytics?.activeOrders ?? 0}',
        color: const Color(0xFF3B82F6),
        icon: Icons.local_shipping_outlined,
      ),
      _MetricItem(
        label: 'Total Rents',
        value: '${analytics?.totalOrders ?? 0}',
        color: AppColors.warning,
        icon: Icons.repeat_rounded,
      ),
      _MetricItem(
        label: 'Available',
        value:
            '${product.availableQuantity} / ${product.totalQuantity}',
        color: product.availableQuantity == 0
            ? const Color(0xFFFF6B8A)
            : product.availableQuantity <= product.lowStockThreshold
                ? const Color(0xFFF5A623)
                : const Color(0xFF2ECC71),
        icon: Icons.inventory_2_outlined,
      ),
    ];
    return SizedBox(
      height: Responsive.h(100),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => SizedBox(width: Responsive.w(10)),
        itemBuilder: (context, i) => SizedBox(
          width: Responsive.w(140),
          child: AppCard(
            padding: Responsive.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(items[i].icon,
                    size: Responsive.icon(18), color: items[i].color),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        items[i].value,
                        style: TextStyle(
                          fontSize: Responsive.sp(18),
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      items[i].label,
                      style: TextStyle(
                          fontSize: Responsive.sp(11), color: Colors.grey[600]),
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

  Widget _buildAnalyticsSection(ProductAnalytics? analytics) {
    if (analytics == null) return const SizedBox.shrink();
    final roi = analytics.roi;
    final items = [
      _AnalyticsRow(
        label: 'Purchase Price',
        value: '₹${analytics.purchasePrice.toStringAsFixed(0)}',
        color: Colors.grey[700]!,
      ),
      _AnalyticsRow(
        label: 'ROI',
        value: roi != null ? '${roi >= 0 ? '+' : ''}$roi%' : 'N/A',
        color: roi != null && roi >= 0
            ? const Color(0xFF2ECC71)
            : const Color(0xFFFF6B8A),
      ),
      _AnalyticsRow(
        label: 'Usage Rate',
        value: '${analytics.usageRate}%',
        color: const Color(0xFF3B82F6),
      ),
      _AnalyticsRow(
        label: 'Avg Duration',
        value: '${analytics.avgRentalDuration} days',
        color: const Color(0xFFF5A623),
      ),
      _AnalyticsRow(
        label: 'Cancelled',
        value: '${analytics.cancelledOrders}',
        color: const Color(0xFFFF6B8A),
      ),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Analytics'),
          SizedBox(height: Responsive.h(10)),
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(8)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                            fontSize: Responsive.sp(13),
                            color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontSize: Responsive.sp(14),
                        fontWeight: FontWeight.w700,
                        color: item.color,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoCard(Product product) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('General Info'),
          SizedBox(height: Responsive.h(12)),
          Row(
            children: [
              Expanded(
                child: _buildPriceItem(
                    'Rent / Day',
                    '₹${product.pricePerDay.toStringAsFixed(0)}',
                    AppColors.warning),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: _buildPriceItem(
                    'Deposit',
                    '₹${product.securityDeposit.toStringAsFixed(0)}',
                    AppColors.primary),
              ),
            ],
          ),
          if (product.minRentalDays != null ||
              product.maxRentalDays != null) ...[
            SizedBox(height: Responsive.h(12)),
            Wrap(
              spacing: Responsive.w(8),
              runSpacing: Responsive.h(8),
              children: [
                if (product.minRentalDays != null)
                  _buildInfoChip('Min ${product.minRentalDays} days', Icons.timer_outlined),
                if (product.maxRentalDays != null)
                  _buildInfoChip('Max ${product.maxRentalDays} days', Icons.timer_off_outlined),
              ],
            ),
          ],
          if (product.description != null &&
              product.description!.isNotEmpty) ...[
            SizedBox(height: Responsive.h(12)),
            Text(
              product.description!,
              style: TextStyle(
                  fontSize: Responsive.sp(13),
                  color: Colors.grey[700],
                  height: 1.5),
            ),
          ],
          if (product.material != null ||
              product.metalPurity != null ||
              product.metalColor != null ||
              product.weightGrams != null ||
              product.condition != null) ...[
            SizedBox(height: Responsive.h(12)),
            Wrap(
              spacing: Responsive.w(8),
              runSpacing: Responsive.h(8),
              children: [
                if (product.material != null)
                  _buildSpecChip('Material', product.material!),
                if (product.metalPurity != null)
                  _buildSpecChip('Purity', product.metalPurity!),
                if (product.metalColor != null)
                  _buildSpecChip('Color', product.metalColor!),
                if (product.weightGrams != null)
                  _buildSpecChip('Weight', '${product.weightGrams}g'),
                if (product.condition != null)
                  _buildSpecChip('Condition', product.condition!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBranchStockSection(
      List<BranchInventory> branchInventory, Product product) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Branch Stock'),
          SizedBox(height: Responsive.h(10)),
          if (branchInventory.isEmpty)
            Row(
              children: [
                Expanded(
                    child: _buildStockItem('Total', '${product.totalQuantity}')),
                Expanded(
                    child: _buildStockItem(
                        'Available', '${product.availableQuantity}')),
                Expanded(
                    child: _buildStockItem(
                        'Reserved', '${product.reservedQuantity}')),
              ],
            )
          else
            ...branchInventory.map((b) => Padding(
                  padding: EdgeInsets.only(bottom: Responsive.h(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              b.branchName ?? 'Branch',
                              style: TextStyle(
                                  fontSize: Responsive.sp(13),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${b.stockCount} / ${product.totalQuantity}',
                            style: TextStyle(
                                fontSize: Responsive.sp(12),
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(6)),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final ratio = product.totalQuantity > 0
                              ? b.stockCount / product.totalQuantity
                              : 0.0;
                          final color = b.stockCount == 0
                              ? const Color(0xFFFF6B8A)
                              : b.stockCount <= product.lowStockThreshold
                                  ? const Color(0xFFF5A623)
                                  : const Color(0xFF2ECC71);
                          return Container(
                            width: constraints.maxWidth,
                            height: Responsive.h(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius:
                                  BorderRadius.circular(Responsive.r(4)),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: ratio.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius:
                                      BorderRadius.circular(Responsive.r(4)),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildStockItem(String label, String value) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
                fontSize: Responsive.sp(20),
                fontWeight: FontWeight.w800,
                color: AppColors.primary),
          ),
        ),
        SizedBox(height: Responsive.h(2)),
        Text(label,
            style: TextStyle(
                fontSize: Responsive.sp(11), color: Colors.grey[500]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: Responsive.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Responsive.r(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: Responsive.icon(14), color: Colors.grey[600]),
          SizedBox(width: Responsive.w(4)),
          Flexible(
            child: Text(text,
                style: TextStyle(
                    fontSize: Responsive.sp(11), color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(String label, String value) {
    return Container(
      padding: Responsive.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Responsive.r(8)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: Responsive.sp(9),
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: Responsive.h(2)),
          Text(value,
              style: TextStyle(
                  fontSize: Responsive.sp(12),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(ProductAvailability? availability) {
    if (availability == null || availability.days.isEmpty) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Booking Calendar'),
            SizedBox(height: Responsive.h(10)),
            Text('No availability data',
                style: TextStyle(
                    fontSize: Responsive.sp(13), color: Colors.grey[600])),
          ],
        ),
      );
    }

    final days = availability.days;
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final monthLabel = DateFormat('MMMM yyyy').format(currentMonth);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Booking Calendar'),
              Text(
                monthLabel,
                style: TextStyle(
                    fontSize: Responsive.sp(12),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(10)),
          _buildCalendarGrid(days, currentMonth),
          SizedBox(height: Responsive.h(8)),
          Wrap(
            spacing: Responsive.w(8),
            runSpacing: Responsive.h(4),
            children: [
              _buildLegendDot('Available', const Color(0xFF2ECC71)),
              _buildLegendDot('Partial', const Color(0xFFF5A623)),
              _buildLegendDot('Booked', const Color(0xFFFF6B8A)),
              _buildLegendDot('Buffer', const Color(0xFF3B82F6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<AvailabilityDay> days, DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final startWeekday = firstDayOfMonth.weekday % 7;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize =
            (constraints.maxWidth - Responsive.w(6 * 2)) / 7;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((d) => SizedBox(
                        width: cellSize,
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                                fontSize: Responsive.sp(10),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500]),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: Responsive.h(4)),
            Wrap(
              spacing: Responsive.w(2),
              runSpacing: Responsive.h(2),
              children: [
                ...List.generate(startWeekday, (_) => SizedBox(width: cellSize, height: cellSize)),
                ...List.generate(daysInMonth, (i) {
                  final dayNum = i + 1;
                  final dateStr =
                      '${month.year}-${month.month.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}';
                  final dayData = days.cast<AvailabilityDay?>().firstWhere(
                    (d) => d?.date == dateStr,
                    orElse: () => null,
                  );
                  return _buildCalendarDayCell(dayNum, dayData, cellSize);
                }),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarDayCell(int dayNum, AvailabilityDay? day, double cellSize) {
    Color bgColor = Colors.transparent;
    Color borderColor = Colors.grey[300]!;
    if (day != null) {
      switch (day.status) {
        case 'available':
          bgColor = const Color(0xFF2ECC71).withValues(alpha: 0.15);
          borderColor = const Color(0xFF2ECC71);
          break;
        case 'partial':
          bgColor = const Color(0xFFF5A623).withValues(alpha: 0.15);
          borderColor = const Color(0xFFF5A623);
          break;
        case 'unavailable':
          bgColor = const Color(0xFFFF6B8A).withValues(alpha: 0.15);
          borderColor = const Color(0xFFFF6B8A);
          break;
        case 'buffer':
          bgColor = const Color(0xFF3B82F6).withValues(alpha: 0.15);
          borderColor = const Color(0xFF3B82F6);
          break;
      }
    }
    return GestureDetector(
      onTap: day != null && day.bookings.isNotEmpty
          ? () => _showDayBookings(day)
          : null,
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 0.5),
          borderRadius: BorderRadius.circular(Responsive.r(4)),
        ),
        child: Center(
          child: Text(
            '$dayNum',
            style: TextStyle(
              fontSize: Responsive.sp(11),
              fontWeight: FontWeight.w600,
              color: day != null && day.status == 'unavailable'
                  ? const Color(0xFFFF6B8A)
                  : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  void _showDayBookings(AvailabilityDay day) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: Responsive.all(16),
        constraints: BoxConstraints(
          maxHeight: Responsive.screenHeight * 0.5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bookings for ${day.date}',
              style: TextStyle(
                  fontSize: Responsive.sp(16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
            SizedBox(height: Responsive.h(12)),
            Expanded(
              child: ListView.builder(
                itemCount: day.bookings.length,
                itemBuilder: (context, i) {
                  final b = day.bookings[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      b.customerName,
                      style: TextStyle(
                          fontSize: Responsive.sp(14),
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${b.startDate} → ${b.endDate}  •  Qty: ${b.quantity}${b.isBuffer ? ' (buffer)' : ''}',
                      style: TextStyle(fontSize: Responsive.sp(11)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Container(
                      padding: Responsive.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: b.isBuffer
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                            : const Color(0xFFFF6B8A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Responsive.r(6)),
                      ),
                      child: Text(
                        b.isBuffer ? 'Buffer' : 'Booked',
                        style: TextStyle(
                            fontSize: Responsive.sp(10),
                            fontWeight: FontWeight.w700,
                            color: b.isBuffer
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFFFF6B8A)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Responsive.w(8),
          height: Responsive.w(8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: Responsive.w(4)),
        Text(label,
            style: TextStyle(fontSize: Responsive.sp(11), color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildRentalHistorySection(List<ProductOrderItem> items) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Rental History'),
          SizedBox(height: Responsive.h(10)),
          ...items.take(10).map((item) => _buildRentalHistoryRow(item)),
          if (items.length > 10)
            Padding(
              padding: EdgeInsets.only(top: Responsive.h(8)),
              child: Text(
                '+ ${items.length - 10} more orders',
                style:
                    TextStyle(fontSize: Responsive.sp(12), color: Colors.grey[500]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRentalHistoryRow(ProductOrderItem item) {
    final order = item.order;
    final customerName = order?.customer?.name ?? 'Unknown';
    final status = order?.status ?? 'unknown';
    final dateRange = (order?.startDate != null && order?.endDate != null)
        ? '${order!.startDate} → ${order.endDate}'
        : '';
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(8)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: TextStyle(
                      fontSize: Responsive.sp(13),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dateRange.isNotEmpty)
                  Text(
                    dateRange,
                    style:
                        TextStyle(fontSize: Responsive.sp(11), color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: Responsive.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Responsive.r(6)),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                  fontSize: Responsive.sp(10),
                  fontWeight: FontWeight.w700,
                  color: _statusColor(status)),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF5A623);
      case 'confirmed':
      case 'preparing':
      case 'out_for_delivery':
        return const Color(0xFF3B82F6);
      case 'delivered':
      case 'active':
      case 'ongoing':
        return const Color(0xFF2ECC71);
      case 'returned':
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
      case 'refunded':
        return const Color(0xFFFF6B8A);
      default:
        return Colors.grey;
    }
  }

  Widget _buildDamageHistorySection(List<DamageRecord> records) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Damage History'),
          SizedBox(height: Responsive.h(10)),
          ...records.map((r) => Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(8)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.order?.customerName ?? 'Unknown',
                            style: TextStyle(
                                fontSize: Responsive.sp(13),
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Decision: ${r.decision}',
                            style: TextStyle(
                                fontSize: Responsive.sp(11), color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: Responsive.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: r.decision == 'reuse'
                            ? const Color(0xFF2ECC71).withValues(alpha: 0.1)
                            : r.decision == 'not_reuse'
                                ? const Color(0xFFFF6B8A).withValues(alpha: 0.1)
                                : const Color(0xFFF5A623).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Responsive.r(6)),
                      ),
                      child: Text(
                        r.decision.toUpperCase(),
                        style: TextStyle(
                            fontSize: Responsive.sp(10),
                            fontWeight: FontWeight.w700,
                            color: r.decision == 'reuse'
                                ? const Color(0xFF2ECC71)
                                : r.decision == 'not_reuse'
                                    ? const Color(0xFFFF6B8A)
                                    : const Color(0xFFF5A623)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showBarcodeDialog(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Barcode', style: TextStyle(fontSize: Responsive.sp(16))),
        content: Text(product.barcode ?? 'N/A',
            style: TextStyle(
                fontSize: Responsive.sp(14),
                fontFamily: 'monospace',
                letterSpacing: 2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

}

class _MetricItem {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
}

class _AnalyticsRow {
  final String label;
  final String value;
  final Color color;

  const _AnalyticsRow({
    required this.label,
    required this.value,
    required this.color,
  });
}
