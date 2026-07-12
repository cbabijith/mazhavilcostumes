import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/viewmodels/providers/auth_provider.dart';
import '../../branches/viewmodels/providers/branch_provider.dart';
import '../providers/product_details_provider.dart';
import '../models/product.dart';
import '../models/product_analytics.dart';
import '../models/damage_record.dart';
import '../models/product_availability.dart';
import '../viewmodels/providers/product_provider.dart';
import '../../orders/views/order_detail_view.dart';
import '../../orders/viewmodels/providers/order_provider.dart';
import 'product_form_view.dart';

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

  Future<void> _navigateToOrder(BuildContext context, String orderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final repo = ref.read(orderRepositoryProvider);
      final order = await repo.getOrderById(orderId);
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss progress dialog
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailView(order: order),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load order: $e'),
            backgroundColor: const Color(0xFFFF6B8A),
          ),
        );
      }
    }
  }

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
    final selectedBranchId = ref.watch(effectiveBranchIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailsAsync.when(
        data: (state) => _buildBody(context, state, isAdminOrManager, selectedBranchId),
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
      bool isAdminOrManager, String? selectedBranchId) {
    final product = state.product;
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(product, isAdminOrManager, selectedBranchId, state.branchInventory),
        SliverToBoxAdapter(
          child: Padding(
            padding: Responsive.symmetric(
              horizontal: AppSizes.spacingMedium,
              vertical: AppSizes.spacingSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(product),
                SizedBox(height: Responsive.h(8)),
                _buildMetricsGrid(state, isAdminOrManager, selectedBranchId),
                SizedBox(height: Responsive.h(8)),
                if (isAdminOrManager) ...[
                  _buildAnalyticsSection(state.analytics),
                  SizedBox(height: Responsive.h(8)),
                ],
                _buildGeneralInfoCard(product),
                SizedBox(height: Responsive.h(8)),
                _buildProductIdentifiersCard(product),
                SizedBox(height: Responsive.h(8)),
                _buildBranchStockSection(state.branchInventory, product, selectedBranchId),
                SizedBox(height: Responsive.h(8)),
                _buildCalendarSection(state.availability),
                SizedBox(height: Responsive.h(8)),
                if (isAdminOrManager) ...[
                  _buildMonthlyRevenueSection(state.analytics),
                  SizedBox(height: Responsive.h(8)),
                ],
                if (state.analytics?.items.isNotEmpty ?? false) ...[
                  _buildRentalHistorySection(state.analytics!.items),
                  SizedBox(height: Responsive.h(8)),
                ],
                if (isAdminOrManager && state.damageHistory.isNotEmpty) ...[
                  _buildDamageHistorySection(state.damageHistory),
                  SizedBox(height: Responsive.h(8)),
                ],
                SizedBox(height: Responsive.h(40)),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildSliverAppBar(
      Product product, bool isAdminOrManager, String? selectedBranchId, List<BranchInventory> branchInventory) {
    return SliverAppBar(
      expandedHeight: Responsive.h(220),
      pinned: true,
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Responsive.r(24)),
          bottomRight: Radius.circular(Responsive.r(24)),
        ),
      ),
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
        if (isAdminOrManager) ...[
          IconButton(
            icon: Icon(Icons.edit_rounded, size: Responsive.icon(22)),
            tooltip: 'Edit Product',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductFormView(productId: product.id),
                ),
              ).then((_) {
                ref.invalidate(productDetailsProvider(product.id));
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: Responsive.icon(22), color: const Color(0xFFFF6B8A)),
            tooltip: 'Delete Product',
            onPressed: () => _confirmDeleteProduct(context, ref, product),
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(Responsive.r(24)),
            bottomRight: Radius.circular(Responsive.r(24)),
          ),
          child: Stack(
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
                    _buildStatusBadge(product, selectedBranchId, branchInventory),
                    if (product.isFeatured)
                      _buildPillBadge('Featured', const Color(0xFFF5A623)),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildStatusBadge(Product product, String? selectedBranchId, List<BranchInventory> branchInventory) {
    if (!product.isActive) {
      return _buildPillBadge('Inactive', Colors.grey);
    }

    final selectedBranchInv = selectedBranchId != null
        ? branchInventory.cast<BranchInventory?>().firstWhere(
              (inv) => inv?.branchId == selectedBranchId,
              orElse: () => null,
            )
        : null;

    final int availQty = selectedBranchId != null
        ? (selectedBranchInv != null ? selectedBranchInv.availableQuantity : 0)
        : product.availableQuantity;
    final int lowStockThreshold = selectedBranchId != null
        ? (selectedBranchInv != null ? selectedBranchInv.lowStockThreshold : 0)
        : product.lowStockThreshold;

    Color bgColor;
    String label;
    if (availQty <= 0) {
      bgColor = const Color(0xFFFF6B8A);
      label = 'Out of Stock';
    } else if (availQty <= lowStockThreshold) {
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Responsive.w(2.5),
          height: Responsive.h(11),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(Responsive.r(1.5)),
          ),
        ),
        SizedBox(width: Responsive.w(6)),
        Text(
          title,
          style: TextStyle(
            fontSize: Responsive.sp(12),
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactPriceItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(9),
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Responsive.h(2)),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(13),
            fontWeight: FontWeight.w900,
            color: color == AppColors.warning ? const Color(0xFFD97706) : color,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDivider() {
    return Container(
      width: Responsive.w(1),
      height: Responsive.h(18),
      color: Colors.grey[200],
    );
  }

  Widget _buildHeaderSection(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.categoryName != null) ...[
          Container(
            padding: Responsive.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(Responsive.r(20)),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Text(
              product.categoryName!.toUpperCase(),
              style: TextStyle(
                fontSize: Responsive.sp(9),
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 0.6,
              ),
            ),
          ),
          SizedBox(height: Responsive.h(6)),
        ],
        AutoSizeText(
          product.name,
          style: TextStyle(
            fontSize: Responsive.sp(18),
            fontWeight: FontWeight.w900,
            color: AppColors.text,
            height: 1.15,
          ),
          maxLines: 2,
          minFontSize: 14,
          overflow: TextOverflow.ellipsis,
        ),
        if (product.sku != null && product.sku!.isNotEmpty) ...[
          SizedBox(height: Responsive.h(4)),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: product.sku!));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('SKU copied to clipboard'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: Container(
              padding: Responsive.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey[50]?.withValues(alpha: 0.5) ?? const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(Responsive.r(6)),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SKU: ${product.sku}',
                    style: TextStyle(
                      fontSize: Responsive.sp(10),
                      color: Colors.grey[500],
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: Responsive.w(3)),
                  Icon(Icons.copy_rounded, size: Responsive.icon(10), color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricsGrid(
      ProductDetailsState state, bool isAdminOrManager, String? selectedBranchId) {
    final product = state.product;
    final analytics = state.analytics;

    final selectedBranchInv = selectedBranchId != null
        ? state.branchInventory.cast<BranchInventory?>().firstWhere(
              (inv) => inv?.branchId == selectedBranchId,
              orElse: () => null,
            )
        : null;

    final int totalQty = selectedBranchId != null
        ? (selectedBranchInv != null ? selectedBranchInv.quantity : 0)
        : product.totalQuantity;
    final int availQty = selectedBranchId != null
        ? (selectedBranchInv != null ? selectedBranchInv.availableQuantity : 0)
        : product.availableQuantity;
    final int lowStockThreshold = selectedBranchId != null
        ? (selectedBranchInv != null ? selectedBranchInv.lowStockThreshold : 0)
        : product.lowStockThreshold;

    final items = [
      if (isAdminOrManager)
        _MetricItem(
          label: 'Lifetime Revenue',
          value: analytics != null
              ? '₹${analytics.totalRevenue.toStringAsFixed(0)}'
              : '—',
          color: const Color(0xFF10B981),
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
        value: '${analytics?.totalUnitsRented ?? 0}',
        color: const Color(0xFFF59E0B),
        icon: Icons.repeat_rounded,
      ),
      _MetricItem(
        label: 'Available',
        value: '$availQty / $totalQty',
        color: availQty == 0
            ? const Color(0xFFEF4444)
            : availQty <= lowStockThreshold
                ? const Color(0xFFF59E0B)
                : const Color(0xFF10B981),
        icon: Icons.inventory_2_outlined,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Responsive.w(8),
        mainAxisSpacing: Responsive.h(8),
        childAspectRatio: 2.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => AppCard(
        padding: Responsive.symmetric(
          horizontal: AppSizes.spacingSmall,
          vertical: AppSizes.spacingSmall - 2,
        ),
        borderColor: const Color(0xFFF1F5F9),
        borderRadius: AppSizes.radiusMedium,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: Responsive.r(6),
            offset: Offset(0, Responsive.h(1)),
          )
        ],
        child: Row(
          children: [
            Container(
              padding: Responsive.all(5),
              decoration: BoxDecoration(
                color: items[i].color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(items[i].icon, size: Responsive.icon(14), color: items[i].color),
            ),
            SizedBox(width: Responsive.w(6)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      items[i].value,
                      style: TextStyle(
                        fontSize: Responsive.sp(14),
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                        height: 1.1,
                      ),
                    ),
                  ),
                  Text(
                    items[i].label,
                    style: TextStyle(
                      fontSize: Responsive.sp(9),
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (items[i].label == 'Active Rentals' && (analytics?.activeOrders ?? 0) > 0)
              Container(
                width: Responsive.w(5),
                height: Responsive.w(5),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(ProductAnalytics? analytics) {
    if (analytics == null) return const SizedBox.shrink();
    final roi = analytics.roi;

    final items = [
      _AnalyticsCardItem(
        label: 'Purchase Price',
        value: '₹${analytics.purchasePrice.toStringAsFixed(0)}',
        subtext: 'Original cost',
        color: Colors.grey[700]!,
        icon: Icons.shopping_bag_outlined,
      ),
      _AnalyticsCardItem(
        label: 'ROI',
        value: roi != null ? '${roi >= 0 ? '+' : ''}$roi%' : 'N/A',
        subtext: roi != null ? (roi > 0 ? 'Profitable' : 'Below cost') : 'Set purchase price',
        color: roi != null && roi >= 100
            ? const Color(0xFF10B981)
            : roi != null && roi < 0
                ? const Color(0xFFEF4444)
                : const Color(0xFFF59E0B),
        icon: Icons.trending_up_rounded,
      ),
      _AnalyticsCardItem(
        label: 'Usage Rate',
        value: '${analytics.usageRate}%',
        subtext: '${analytics.totalRentalDays} rental days',
        color: const Color(0xFF3B82F6),
        icon: Icons.bar_chart_rounded,
      ),
      _AnalyticsCardItem(
        label: 'Avg Duration',
        value: '${analytics.avgRentalDuration} days',
        subtext: 'Per rental',
        color: const Color(0xFF8B5CF6),
        icon: Icons.timelapse_rounded,
      ),
      _AnalyticsCardItem(
        label: 'Cancelled',
        value: '${analytics.cancelledOrders}',
        subtext: 'Orders cancelled',
        color: const Color(0xFFEF4444),
        icon: Icons.cancel_presentation_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Enhanced Analytics'),
        SizedBox(height: Responsive.h(10)),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: Responsive.w(8),
            mainAxisSpacing: Responsive.h(8),
            childAspectRatio: 2.3,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) => AppCard(
            padding: Responsive.symmetric(
              horizontal: AppSizes.spacingSmall,
              vertical: AppSizes.spacingSmall - 2,
            ),
            borderColor: const Color(0xFFF1F5F9),
            borderRadius: AppSizes.radiusMedium,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: Responsive.r(6),
                offset: Offset(0, Responsive.h(1)),
              )
            ],
            child: Row(
              children: [
                Container(
                  padding: Responsive.all(5),
                  decoration: BoxDecoration(
                    color: items[i].color.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(items[i].icon, size: Responsive.icon(14), color: items[i].color),
                ),
                SizedBox(width: Responsive.w(6)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          items[i].value,
                          style: TextStyle(
                            fontSize: Responsive.sp(14),
                            fontWeight: FontWeight.w900,
                            color: items[i].label == 'ROI' ? items[i].color : AppColors.text,
                            height: 1.1,
                          ),
                        ),
                      ),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontSize: Responsive.sp(9),
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralInfoCard(Product product) {
    return AppCard(
      padding: Responsive.symmetric(
        horizontal: AppSizes.spacingSmall + 2,
        vertical: AppSizes.spacingSmall,
      ),
      borderColor: const Color(0xFFF1F5F9),
      borderRadius: AppSizes.radiusMedium,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.012),
          blurRadius: Responsive.r(8),
          offset: Offset(0, Responsive.h(1.5)),
        )
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('General Info'),
          SizedBox(height: Responsive.h(8)),
          Container(
            padding: Responsive.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(Responsive.r(8)),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCompactPriceItem('Rent / Day', '₹${product.pricePerDay.toStringAsFixed(0)}', AppColors.warning),
                _buildCompactDivider(),
                _buildCompactPriceItem('Deposit', '₹${product.securityDeposit.toStringAsFixed(0)}', AppColors.primary),
                if (product.purchasePrice > 0) ...[
                  _buildCompactDivider(),
                  _buildCompactPriceItem('Purchase Price', '₹${product.purchasePrice.toStringAsFixed(0)}', Colors.grey[700]!),
                ],
                if (product.gstPercentage > 0) ...[
                  _buildCompactDivider(),
                  _buildCompactPriceItem('GST Rate', '${product.gstPercentage.toStringAsFixed(0)}%', const Color(0xFF3B82F6)),
                ],
              ],
            ),
          ),
          if (product.minRentalDays != null ||
              product.maxRentalDays != null) ...[
            SizedBox(height: Responsive.h(8)),
            Wrap(
              spacing: Responsive.w(6),
              runSpacing: Responsive.h(6),
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
            SizedBox(height: Responsive.h(8)),
            Text(
              product.description!,
              style: TextStyle(
                  fontSize: Responsive.sp(12),
                  color: Colors.grey[700],
                  height: 1.4),
            ),
          ],
          if (product.material != null ||
              product.metalPurity != null ||
              product.metalColor != null ||
              product.weightGrams != null ||
              product.condition != null) ...[
            SizedBox(height: Responsive.h(8)),
            Wrap(
              spacing: Responsive.w(6),
              runSpacing: Responsive.h(6),
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

  Widget _buildProductIdentifiersCard(Product product) {
    return AppCard(
      padding: Responsive.symmetric(
        horizontal: AppSizes.spacingSmall + 2,
        vertical: AppSizes.spacingSmall,
      ),
      borderColor: const Color(0xFFF1F5F9),
      borderRadius: AppSizes.radiusMedium,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.012),
          blurRadius: Responsive.r(8),
          offset: Offset(0, Responsive.h(1.5)),
        )
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Product Identifiers'),
          SizedBox(height: Responsive.h(8)),
          _buildIdentifierRow('SKU', product.sku ?? 'N/A'),
          Divider(color: Colors.grey[100], height: Responsive.h(10)),
          _buildIdentifierRow('Barcode', product.barcode ?? 'N/A'),
          Divider(color: Colors.grey[100], height: Responsive.h(10)),
          _buildIdentifierRow(
            'System ID',
            product.id,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: product.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('System ID copied to clipboard'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIdentifierRow(String label, String value, {VoidCallback? onCopy}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(12),
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(width: Responsive.w(12)),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  padding: Responsive.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(Responsive.r(4)),
                    border: Border.all(color: Colors.grey[300]!, width: 0.5),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: Responsive.sp(11),
                        fontFamily: 'monospace',
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              if (onCopy != null) ...[
                SizedBox(width: Responsive.w(6)),
                InkWell(
                  onTap: onCopy,
                  borderRadius: BorderRadius.circular(Responsive.r(4)),
                  child: Padding(
                    padding: Responsive.all(4),
                    child: Icon(Icons.copy_rounded, size: Responsive.icon(16), color: Colors.grey[500]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBranchStockSection(
      List<BranchInventory> branchInventory, Product product, String? selectedBranchId) {
    return AppCard(
      padding: Responsive.symmetric(
        horizontal: AppSizes.spacingSmall + 2,
        vertical: AppSizes.spacingSmall,
      ),
      borderColor: const Color(0xFFF1F5F9),
      borderRadius: AppSizes.radiusMedium,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.012),
          blurRadius: Responsive.r(8),
          offset: Offset(0, Responsive.h(1.5)),
        )
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Branch Stock'),
          SizedBox(height: Responsive.h(8)),
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
            ...branchInventory.map((b) {
              final isSelectedBranch = b.branchId == selectedBranchId;
              final isOut = b.availableQuantity == 0;
              final isLow = !isOut && b.availableQuantity <= b.lowStockThreshold;

              return Padding(
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
                                fontWeight: isSelectedBranch ? FontWeight.w800 : FontWeight.w600,
                                color: isSelectedBranch ? AppColors.primary : AppColors.text),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${b.availableQuantity} / ${b.quantity}',
                          style: TextStyle(
                              fontSize: Responsive.sp(12),
                              fontWeight: FontWeight.w800,
                              color: isOut ? const Color(0xFFEF4444) : AppColors.text),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(6)),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final ratio = b.quantity > 0
                            ? b.availableQuantity / b.quantity
                            : 0.0;
                        final color = isOut
                            ? const Color(0xFFEF4444)
                            : isLow
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF10B981);
                        return Container(
                          width: constraints.maxWidth,
                          height: Responsive.h(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius:
                                BorderRadius.circular(Responsive.r(2)),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: ratio.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius:
                                    BorderRadius.circular(Responsive.r(2)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: Responsive.h(6)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Threshold: ${b.lowStockThreshold}',
                          style: TextStyle(
                            fontSize: Responsive.sp(10),
                            color: Colors.grey[500],
                          ),
                        ),
                        if (isOut || isLow)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOut ? Icons.cancel_outlined : Icons.warning_amber_rounded,
                                size: Responsive.icon(12),
                                color: isOut ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                              ),
                              SizedBox(width: Responsive.w(2)),
                              Text(
                                isOut ? 'Out of stock' : 'Low stock',
                                style: TextStyle(
                                  fontSize: Responsive.sp(10),
                                  fontWeight: FontWeight.w600,
                                  color: isOut ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
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
        borderColor: const Color(0xFFF1F5F9),
        borderRadius: AppSizes.radiusMedium,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: Responsive.r(10),
            offset: Offset(0, Responsive.h(2)),
          )
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Booking Calendar'),
            SizedBox(height: Responsive.h(12)),
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
      borderColor: const Color(0xFFF1F5F9),
      borderRadius: AppSizes.radiusMedium,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.015),
          blurRadius: Responsive.r(10),
          offset: Offset(0, Responsive.h(2)),
        )
      ],
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
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          _buildCalendarGrid(days, currentMonth),
          SizedBox(height: Responsive.h(12)),
          Wrap(
            spacing: Responsive.w(12),
            runSpacing: Responsive.h(6),
            children: [
              _buildLegendDot('Available', const Color(0xFF10B981)),
              _buildLegendDot('Partial', const Color(0xFFF59E0B)),
              _buildLegendDot('Booked', const Color(0xFFEF4444)),
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
      borderColor: const Color(0xFFF1F5F9),
      borderRadius: AppSizes.radiusMedium,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.015),
          blurRadius: Responsive.r(10),
          offset: Offset(0, Responsive.h(2)),
        )
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Rental History'),
          SizedBox(height: Responsive.h(12)),
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
    final customerPhone = order?.customer?.phone;
    final status = order?.status ?? 'unknown';
    final dateRange = (order?.startDate != null && order?.endDate != null)
        ? '${order!.startDate} → ${order.endDate}'
        : '';

    return InkWell(
      onTap: order != null ? () => _navigateToOrder(context, order.id) : null,
      borderRadius: BorderRadius.circular(Responsive.r(8)),
      child: Padding(
        padding: Responsive.symmetric(vertical: 8, horizontal: 4),
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
                  if (customerPhone != null && customerPhone.isNotEmpty) ...[
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      customerPhone,
                      style: TextStyle(
                        fontSize: Responsive.sp(11),
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (dateRange.isNotEmpty) ...[
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      dateRange,
                      style: TextStyle(
                        fontSize: Responsive.sp(11),
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
      borderColor: const Color(0xFFF1F5F9),
      borderRadius: AppSizes.radiusMedium,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.015),
          blurRadius: Responsive.r(10),
          offset: Offset(0, Responsive.h(2)),
        )
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Damage History'),
          SizedBox(height: Responsive.h(12)),
          ...records.map((r) {
            final dateStr = r.assessedAt ?? r.createdAt;
            String dateFormatted = '';
            try {
              if (dateStr.isNotEmpty) {
                dateFormatted = DateFormat('MMM d, yyyy').format(DateTime.parse(dateStr));
              }
            } catch (_) {}
            
            return InkWell(
              onTap: () => _navigateToOrder(context, r.orderId),
              borderRadius: BorderRadius.circular(Responsive.r(8)),
              child: Padding(
                padding: Responsive.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                              if (dateFormatted.isNotEmpty) ...[
                                SizedBox(height: Responsive.h(2)),
                                Text(
                                  dateFormatted,
                                  style: TextStyle(
                                      fontSize: Responsive.sp(11), color: Colors.grey[500]),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: Responsive.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(Responsive.r(6)),
                            border: Border.all(color: Colors.grey[300]!, width: 0.5),
                          ),
                          child: Text(
                            'Unit ${r.unitIndex}',
                            style: TextStyle(
                              fontSize: Responsive.sp(10),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.w(8)),
                        Container(
                          padding: Responsive.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: r.decision == 'reuse'
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : r.decision == 'not_reuse'
                                    ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                                    : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(Responsive.r(6)),
                          ),
                          child: Text(
                            r.decision == 'not_reuse' ? 'WRITTEN OFF' : r.decision.toUpperCase(),
                            style: TextStyle(
                                fontSize: Responsive.sp(10),
                                fontWeight: FontWeight.w700,
                                color: r.decision == 'reuse'
                                    ? const Color(0xFF10B981)
                                    : r.decision == 'not_reuse'
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFFF59E0B)),
                          ),
                        ),
                      ],
                    ),
                    if (r.notes != null && r.notes!.isNotEmpty) ...[
                      SizedBox(height: Responsive.h(6)),
                      Container(
                        width: double.infinity,
                        padding: Responsive.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(Responsive.r(6)),
                          border: Border.all(color: Colors.grey[200]!, width: 0.5),
                        ),
                        child: Text(
                          r.notes!,
                          style: TextStyle(
                            fontSize: Responsive.sp(11),
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showBarcodeDialog(Product product) {
    final barcode = product.barcode ?? 'N/A';

    final List<double> stripeWidths = [];
    for (int i = 0; i < barcode.length; i++) {
      final code = barcode.codeUnitAt(i);
      stripeWidths.add((code % 3 + 1).toDouble());
      stripeWidths.add((code % 2 + 1).toDouble());
    }
    while (stripeWidths.length < 30) {
      stripeWidths.addAll([2.0, 1.0, 3.0, 2.0]);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Product Barcode',
          style: TextStyle(
            fontSize: Responsive.sp(16),
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: Responsive.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Responsive.r(12)),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: Responsive.r(10),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: Responsive.sp(12),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.sku != null)
                        Text(
                          product.sku!,
                          style: TextStyle(
                            fontSize: Responsive.sp(10),
                            fontFamily: 'monospace',
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(16)),
                  SizedBox(
                    height: Responsive.h(60),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(stripeWidths.length, (index) {
                        final isBlack = index % 2 == 0;
                        final width = stripeWidths[index];
                        return Container(
                          width: Responsive.w(width),
                          color: isBlack ? Colors.black : Colors.transparent,
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: Responsive.h(10)),
                  Text(
                    barcode,
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                fontSize: Responsive.sp(13),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: barcode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Barcode copied to clipboard'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            icon: Icon(Icons.copy_rounded, size: Responsive.icon(16)),
            label: Text(
              'Copy',
              style: TextStyle(fontSize: Responsive.sp(12)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteProduct(BuildContext context, WidgetRef ref, Product product) async {
    // 1. Pre-delete check
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    
    final repo = ref.read(productRepositoryProvider);
    final deleteCheck = await repo.canDeleteProduct(product.id);
    
    if (context.mounted) {
      Navigator.of(context).pop(); // Dismiss progress indicator
    }
    
    final dataMap = deleteCheck['data'] as Map<String, dynamic>?;
    final canDelete = deleteCheck['canDelete'] as bool? ?? dataMap?['canDelete'] as bool? ?? false;
    final reason = deleteCheck['reason'] as String? ?? dataMap?['reason'] as String? ?? 'Cannot delete this product';
    
    if (!canDelete) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber[700], size: Responsive.icon(24)),
                SizedBox(width: Responsive.w(8)),
                const Text('Cannot Delete Product'),
              ],
            ),
            content: Text(reason),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }
    
    // 2. Confirmation dialog
    if (context.mounted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B8A)),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      
      if (confirm == true) {
        // Show progress dialog
        if (!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(child: CircularProgressIndicator()),
        );
        
        try {
          await ref.read(productsProvider.notifier).deleteProduct(product.id);
          if (context.mounted) {
            Navigator.of(context).pop(); // Dismiss progress dialog
            // Navigate back to the products list and show success
            Navigator.of(context).pop(); 
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product deleted successfully'),
                backgroundColor: Color(0xFF2ECC71),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop(); // Dismiss progress dialog
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to delete product: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      }
    }
  }

  Widget _buildMonthlyRevenueSection(ProductAnalytics? analytics) {
    if (analytics == null || analytics.monthlyRevenue.isEmpty) {
      return const SizedBox.shrink();
    }

    final list = analytics.monthlyRevenue;
    final maxRevenue = list.map((e) => e.revenue).fold<double>(1.0, (m, e) => e > m ? e : m);

    return AppCard(
      borderColor: const Color(0xFFF1F5F9),
      borderRadius: AppSizes.radiusMedium,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.015),
          blurRadius: Responsive.r(10),
          offset: Offset(0, Responsive.h(2)),
        )
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Monthly Revenue (Last 6 Months)'),
          SizedBox(height: Responsive.h(12)),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(2.8),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
                ),
                children: [
                  Padding(
                    padding: Responsive.symmetric(vertical: 6),
                    child: Text('Month', style: TextStyle(fontSize: Responsive.sp(11), fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  ),
                  Padding(
                    padding: Responsive.symmetric(vertical: 6),
                    child: Text('Rentals', textAlign: TextAlign.right, style: TextStyle(fontSize: Responsive.sp(11), fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  ),
                  Padding(
                    padding: Responsive.symmetric(vertical: 6),
                    child: Text('Revenue', textAlign: TextAlign.right, style: TextStyle(fontSize: Responsive.sp(11), fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  ),
                ],
              ),
              ...list.map((m) {
                final ratio = maxRevenue > 0 ? m.revenue / maxRevenue : 0.0;
                return TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 0.5)),
                  ),
                  children: [
                    Padding(
                      padding: Responsive.symmetric(vertical: 8),
                      child: Text(m.month, style: TextStyle(fontSize: Responsive.sp(12), fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ),
                    Padding(
                      padding: Responsive.symmetric(vertical: 8),
                      child: Text('${m.rentals}', textAlign: TextAlign.right, style: TextStyle(fontSize: Responsive.sp(12), color: Colors.grey[700])),
                    ),
                    Padding(
                      padding: Responsive.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: Responsive.w(40),
                            height: Responsive.h(4),
                            margin: EdgeInsets.only(right: Responsive.w(6)),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(Responsive.r(2)),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: ratio.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(Responsive.r(2)),
                                ),
                              ),
                            ),
                          ),
                          Text('₹${m.revenue.toStringAsFixed(0)}', style: TextStyle(fontSize: Responsive.sp(12), fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ],
                );
              }),
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                ),
                children: [
                  Padding(
                    padding: Responsive.symmetric(vertical: 8, horizontal: 4),
                    child: Text('Total', style: TextStyle(fontSize: Responsive.sp(12), fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                  Padding(
                    padding: Responsive.symmetric(vertical: 8),
                    child: Text(
                      '${list.fold<int>(0, (sum, item) => sum + item.rentals)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: Responsive.sp(12), fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  Padding(
                    padding: Responsive.symmetric(vertical: 8),
                    child: Text(
                      '₹${list.fold<double>(0.0, (sum, item) => sum + item.revenue).toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: Responsive.sp(12), fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

}

class _AnalyticsCardItem {
  final String label;
  final String value;
  final String subtext;
  final Color color;
  final IconData icon;

  const _AnalyticsCardItem({
    required this.label,
    required this.value,
    required this.subtext,
    required this.color,
    required this.icon,
  });
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

