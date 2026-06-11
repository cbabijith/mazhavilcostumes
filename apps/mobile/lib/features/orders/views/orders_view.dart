import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../models/order.dart';
import '../viewmodels/providers/order_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'order_detail_view.dart';
import 'order_form_view.dart';

/// Orders list with horizontal filter chips matching DB statuses.
class OrdersView extends ConsumerStatefulWidget {
  const OrdersView({super.key});

  @override
  ConsumerState<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends ConsumerState<OrdersView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String? _selectedChip; // null = All

  static const _statusFilters = <String, String?>{
    'All': null,
    'Scheduled': 'scheduled',
    'Ongoing': 'ongoing',
    'Late': 'late_return',
    'Partial': 'partial',
    'Returned': 'returned',
    'Completed': 'completed',
    'Flagged': 'flagged',
    'Cancelled': 'cancelled',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - Responsive.h(AppSizes.spacingXXXLarge)) {
      ref.read(ordersProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final ordersAsync = ref.watch(ordersProvider);

    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
              Expanded(
                child: ordersAsync.when(
                  data: (paginated) {
                    if (paginated.orders.isEmpty) return _buildEmptyState();
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => ref.invalidate(ordersProvider),
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: Responsive.only(left: AppSizes.screenPaddingSmall, right: AppSizes.screenPaddingSmall, top: AppSizes.spacingSmall, bottom: AppSizes.spacingMassive),
                        itemCount: paginated.orders.length,
                        separatorBuilder: (context, index) => SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                        itemBuilder: (context, i) => _buildOrderCard(paginated.orders[i]),
                      ),
                    );
                  },
                  loading: () => _buildShimmerList(),
                  error: (e, _) => _buildErrorState(e.toString()),
                ),
              ),
            ],
          ),
            Positioned(
              right: Responsive.w(AppSizes.screenPaddingSmall),
              bottom: Responsive.h(AppSizes.screenPaddingSmall),
              child: FloatingActionButton(
                heroTag: 'order_fab',
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const OrderFormView()))
                    .then((_) => ref.invalidate(ordersProvider)),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 3,
                child: Icon(Icons.add_rounded, size: Responsive.icon(AppSizes.iconMedium)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: Responsive.only(left: AppSizes.screenPaddingSmall, right: AppSizes.screenPaddingSmall, top: AppSizes.spacingMedium, bottom: AppSizes.spacingTiny),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusLarge)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: Responsive.r(AppSizes.radiusMedium),
              offset: Offset(0, Responsive.h(AppSizes.spacingTiny)),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            ref.read(ordersProvider.notifier).search(val);
          },
          onSubmitted: (val) {
            ref.read(ordersProvider.notifier).search(val);
          },
          textInputAction: TextInputAction.search,
          style: TextStyle(fontSize: Responsive.sp(AppSizes.fontLarge)),
          decoration: InputDecoration(
            hintText: 'Search by customer name...',
            hintStyle: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search_rounded, size: Responsive.icon(AppSizes.iconMedium), color: AppColors.primary),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, size: Responsive.icon(AppSizes.iconSmall), color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(ordersProvider.notifier).search('');
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingMedium),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final ordersAsync = ref.watch(ordersProvider);
    final allOrders = ordersAsync.value?.orders ?? [];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: Responsive.symmetric(horizontal: AppSizes.screenPaddingSmall, vertical: AppSizes.spacingTiny),
      child: Row(
        children: _statusFilters.entries.map((entry) {
          final isActive = entry.value == _selectedChip;
          final count = entry.value == null
              ? allOrders.length
              : entry.value == 'late_return'
                  ? allOrders.where((o) => o.isLate).length
                  : allOrders.where((o) => _statusToString(o.status) == entry.value).length;
          return Padding(
            padding: Responsive.only(right: AppSizes.spacingSmall),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedChip = entry.value);
                ref.read(ordersProvider.notifier).filterByStatus(entry.value);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: Responsive.symmetric(horizontal: AppSizes.spacingXLarge, vertical: AppSizes.spacingSmall),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusXLarge)),
                  border: Border.all(color: isActive ? AppColors.primary : Colors.grey.shade300),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: Responsive.r(AppSizes.radiusSmall),
                            offset: Offset(0, Responsive.h(AppSizes.spacingTiny)),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : AppColors.primary,
                      ),
                    ),
                    SizedBox(width: Responsive.w(4)),
                    Container(
                      padding: Responsive.symmetric(horizontal: AppSizes.spacingTiny, vertical: 1),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.25)
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(Responsive.r(10)),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontTiny),
                          fontWeight: FontWeight.w700,
                          color: isActive ? Colors.white : AppColors.primary,
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

  Widget _buildOrderCard(Order order) {
    final statusColor = order.isLate ? AppColors.error : _getStatusColor(order.status);
    final customerName = order.customer?.name ?? 'Unknown';
    final customerPhone = order.customer?.phone ?? '';
    final itemCount = order.items?.length ?? 0;
    final balanceDue = order.totalAmount - order.amountPaid;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusLarge)),
        border: Border.all(color: Colors.grey[200]!, width: AppSizes.spacingTiny / 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: Responsive.r(AppSizes.radiusMedium),
            offset: Offset(0, Responsive.h(AppSizes.spacingTiny + AppSizes.spacingTiny / 2)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusLarge)),
        child: InkWell(
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusLarge)),
          onTap: () {
            // Pre-fetch order details before navigation for instant load
            ref.read(orderProvider(order.id));
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => OrderDetailView(order: order)))
                .then((_) => ref.invalidate(ordersProvider));
          },
          child: Padding(
            padding: Responsive.all(AppSizes.spacingMedium),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: Responsive.w(AppSizes.spacingXLarge),
                      height: Responsive.w(AppSizes.spacingXLarge),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(Responsive.r(10)),
                      ),
                      child: Center(
                        child: Text(
                          customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                          style: TextStyle(fontSize: Responsive.sp(AppSizes.fontXLarge), fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingSmall + AppSizes.spacingTiny / 2)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customerName,
                              style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.w700, color: AppColors.primary),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          Row(
                            children: [
                              Text(
                                'ID: ${order.id.substring(0, 8).toUpperCase()}',
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontTiny),
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                ),
                              ),
                              SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                              Text(
                                '• Booked: ${_fmtDate(order.createdAt)}',
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontTiny),
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          if (customerPhone.isNotEmpty)
                            Text(customerPhone,
                                style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall - 1), color: Colors.grey[500]),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                          Row(
                            children: [
                              if (order.branch != null) ...[
                                Icon(Icons.storefront_rounded, size: Responsive.icon(AppSizes.fontTiny + AppSizes.spacingTiny / 2), color: Colors.grey[500]),
                                SizedBox(width: Responsive.w(AppSizes.spacingTiny / 2 + 1)),
                                Text(
                                  order.branch!.name,
                                  style: TextStyle(fontSize: Responsive.sp(10), color: Colors.grey[600]),
                                ),
                                SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                              ],
                              if (order.deliveryMethod != null) ...[
                                Icon(
                                  order.deliveryMethod == DeliveryMethod.pickup
                                      ? Icons.shopping_bag_outlined
                                      : Icons.local_shipping_outlined,
                                  size: Responsive.icon(AppSizes.fontTiny + AppSizes.spacingTiny / 2),
                                  color: Colors.grey[500],
                                ),
                                SizedBox(width: Responsive.w(AppSizes.spacingTiny / 2 + 1)),
                                Text(
                                  order.deliveryMethod == DeliveryMethod.pickup ? 'Pickup' : 'Delivery',
                                  style: TextStyle(fontSize: Responsive.sp(10), color: Colors.grey[600]),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: Responsive.symmetric(horizontal: AppSizes.spacingSmall + AppSizes.spacingTiny / 2, vertical: AppSizes.spacingTiny + 1),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                            border: Border.all(color: statusColor.withValues(alpha: 0.4), width: AppSizes.spacingTiny / 4),
                          ),
                          child: Text(
                            order.isLate ? 'Overdue' : _formatStatus(order.status),
                            style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall + 1), fontWeight: FontWeight.w800, color: statusColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (order.hasStockConflict && order.status != OrderStatus.completed && order.status != OrderStatus.cancelled)
                          Container(
                            margin: Responsive.only(top: AppSizes.spacingTiny),
                            padding: Responsive.symmetric(horizontal: AppSizes.spacingTiny, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall - 2)),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_amber_rounded, size: Responsive.icon(AppSizes.fontTiny), color: AppColors.error),
                                SizedBox(width: Responsive.w(AppSizes.spacingTiny / 2 + 1)),
                                Text(
                                  'Conflict',
                                  style: TextStyle(fontSize: Responsive.sp(AppSizes.fontTiny - 1), color: AppColors.error, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        if (order.hasPriorityCleaning && order.status != OrderStatus.completed && order.status != OrderStatus.cancelled)
                          Container(
                            margin: Responsive.only(top: AppSizes.spacingTiny),
                            padding: Responsive.symmetric(horizontal: AppSizes.spacingTiny, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall - 2)),
                              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome_rounded, size: Responsive.icon(AppSizes.fontTiny), color: AppColors.warning),
                                SizedBox(width: Responsive.w(AppSizes.spacingTiny / 2 + 1)),
                                Text(
                                  'Priority Prep',
                                  style: TextStyle(fontSize: Responsive.sp(AppSizes.fontTiny - 1), color: AppColors.warning, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                Divider(height: AppSizes.spacingTiny / 4, color: Colors.grey[200]),
                SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: Responsive.icon(AppSizes.fontSmall + AppSizes.spacingTiny / 2), color: Colors.grey[400]),
                          SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                          Expanded(
                            child: Text(
                              '${_fmtDate(order.startDate)} — ${_fmtDate(order.endDate)}',
                              style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall + 1), color: Colors.grey[600]),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: Responsive.symmetric(horizontal: AppSizes.spacingTiny, vertical: 1),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall - 2))),
                      child: Text('$itemCount item${itemCount != 1 ? 's' : ''}',
                          style: TextStyle(fontSize: Responsive.sp(AppSizes.fontTiny), fontWeight: FontWeight.w600, color: Colors.grey[600]),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                    if (order.status != OrderStatus.completed && order.status != OrderStatus.cancelled) ...[
                      Container(
                        padding: Responsive.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingTiny + 1),
                        decoration: BoxDecoration(
                          color: order.paymentStatus == PaymentStatus.paid
                              ? AppColors.success.withValues(alpha: 0.1)
                              : order.paymentStatus == PaymentStatus.partial
                                  ? AppColors.warning.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                          border: Border.all(
                            color: order.paymentStatus == PaymentStatus.paid
                                ? AppColors.success.withValues(alpha: 0.3)
                                : order.paymentStatus == PaymentStatus.partial
                                    ? AppColors.warning.withValues(alpha: 0.3)
                                    : AppColors.error.withValues(alpha: 0.3),
                            width: AppSizes.spacingTiny / 4,
                          ),
                        ),
                        child: Text(
                          order.paymentStatus == PaymentStatus.paid
                              ? 'Paid'
                              : order.paymentStatus == PaymentStatus.partial
                                  ? 'Partial'
                                  : 'Unpaid',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny),
                            fontWeight: FontWeight.w800,
                            color: order.paymentStatus == PaymentStatus.paid
                                ? AppColors.success
                                : order.paymentStatus == PaymentStatus.partial
                                    ? AppColors.warning
                                    : AppColors.error,
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (balanceDue > 0) ...[
                          Container(
                            padding: Responsive.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingTiny + 1),
                            child: Text('Due: ₹${balanceDue.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: Responsive.sp(AppSizes.fontLarge - 1), fontWeight: FontWeight.w800, color: AppColors.error),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          Text('Total: ₹${order.totalAmount.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: Responsive.sp(AppSizes.fontTiny), fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ] else ...[
                          Text('₹${order.totalAmount.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.w800, color: AppColors.primary),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(10)),
                Divider(height: 1, color: Colors.grey[200]),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny + AppSizes.spacingTiny / 2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (customerPhone.isNotEmpty) ...[
                      OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse('tel:$customerPhone');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        icon: Icon(Icons.phone_rounded, color: AppColors.info, size: Responsive.icon(AppSizes.fontSmall + AppSizes.spacingTiny / 2)),
                        label: Text('Call', style: TextStyle(color: AppColors.info, fontSize: Responsive.sp(AppSizes.fontSmall + 1), fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          padding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingTiny + 1),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide(color: AppColors.info.withValues(alpha: 0.4)),
                          backgroundColor: AppColors.info.withValues(alpha: 0.1),
                        ),
                      ),
                      SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                    ],
                    if (balanceDue > 0 && order.status != OrderStatus.completed && order.status != OrderStatus.cancelled) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          ref.read(orderProvider(order.id));
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => OrderDetailView(order: order, autoOpenPayment: true)))
                              .then((_) => ref.invalidate(ordersProvider));
                        },
                        icon: Icon(Icons.account_balance_wallet_rounded, size: Responsive.icon(AppSizes.fontSmall + AppSizes.spacingTiny / 2), color: AppColors.warning),
                        label: Text('Collect', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall + 1), fontWeight: FontWeight.w600, color: AppColors.warning)),
                        style: OutlinedButton.styleFrom(
                          padding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingTiny + 1),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide(color: AppColors.warning.withValues(alpha: 0.5)),
                          backgroundColor: AppColors.warning.withValues(alpha: 0.05),
                        ),
                      ),
                      SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                    ],
                    _buildContextualActionButton(order),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContextualActionButton(Order order) {
    // Hand Over for Scheduled/Pending orders
    if (order.status == OrderStatus.scheduled || order.status == OrderStatus.pending) {
      return ElevatedButton.icon(
        onPressed: () => _confirmHandOver(order),
        icon: Icon(Icons.send_rounded, size: Responsive.icon(AppSizes.iconTiny), color: Colors.white),
        label: Text('Hand Over', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), fontWeight: FontWeight.w700, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          padding: Responsive.symmetric(horizontal: AppSizes.spacingLarge, vertical: AppSizes.spacingSmall),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: AppColors.info,
          foregroundColor: Colors.white,
          elevation: AppSizes.spacingTiny / 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
        ),
      );
    }
    
    // Return for Ongoing/In-Use orders
    if (order.status == OrderStatus.ongoing || order.status == OrderStatus.inUse) {
      return ElevatedButton.icon(
        onPressed: () {
          ref.read(orderProvider(order.id));
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => OrderDetailView(order: order, autoOpenReturn: true)))
              .then((_) => ref.invalidate(ordersProvider));
        },
        icon: Icon(Icons.keyboard_return_rounded, size: Responsive.icon(AppSizes.iconTiny), color: Colors.white),
        label: Text('Return', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), fontWeight: FontWeight.w700, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          padding: Responsive.symmetric(horizontal: AppSizes.spacingLarge, vertical: AppSizes.spacingSmall),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          elevation: AppSizes.spacingTiny / 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
        ),
      );
    }
    
    // Hide for orders with no action needed
    return const SizedBox.shrink();
  }

  Future<void> _confirmHandOver(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Hand Over'),
        content: Text('Have you handed over all items to ${order.customer?.name ?? 'the customer'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(orderOperationsProvider).updateOrder(order.id, {'status': 'ongoing'});
        ref.invalidate(ordersProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order marked as ongoing')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update order: $e')),
          );
        }
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: Responsive.icon(AppSizes.iconXXLarge), color: Colors.grey[300]),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          Text('No Orders Found', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontLarge + 1), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: Responsive.icon(AppSizes.iconLarge + AppSizes.iconTiny)),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          Text('Failed to Load', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontLarge + 1), fontWeight: FontWeight.bold)),
          SizedBox(height: Responsive.h(AppSizes.spacingTiny + AppSizes.spacingTiny / 2)),
          Padding(
            padding: Responsive.symmetric(horizontal: AppSizes.spacingXXLarge),
            child: Text(error, textAlign: TextAlign.center,
                style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), color: Colors.grey[600]),
                maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(ordersProvider),
            icon: Icon(Icons.refresh_rounded, size: Responsive.icon(AppSizes.iconSmall - AppSizes.spacingTiny / 2)),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: Responsive.only(left: AppSizes.screenPaddingSmall, right: AppSizes.screenPaddingSmall, top: AppSizes.spacingMedium),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: Responsive.only(bottom: AppSizes.spacingSmall),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: Responsive.h(AppSizes.spacingMassive + AppSizes.spacingXXLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusLarge)),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return AppColors.warning;
      case OrderStatus.confirmed:
      case OrderStatus.scheduled: return AppColors.info;
      case OrderStatus.delivered:
      case OrderStatus.inUse:
      case OrderStatus.ongoing: return AppColors.info.withValues(alpha: 0.8);
      case OrderStatus.returned:
      case OrderStatus.completed: return AppColors.success;
      case OrderStatus.cancelled: return Colors.grey;
      case OrderStatus.flagged: return AppColors.error;
      case OrderStatus.partial: return AppColors.warning;
    }
  }

  String _statusToString(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return 'pending';
      case OrderStatus.confirmed: return 'confirmed';
      case OrderStatus.scheduled: return 'scheduled';
      case OrderStatus.delivered: return 'delivered';
      case OrderStatus.inUse: return 'in_use';
      case OrderStatus.ongoing: return 'ongoing';
      case OrderStatus.partial: return 'partial';
      case OrderStatus.returned: return 'returned';
      case OrderStatus.completed: return 'completed';
      case OrderStatus.cancelled: return 'cancelled';
      case OrderStatus.flagged: return 'flagged';
    }
  }

  String _formatStatus(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.scheduled: return 'Scheduled';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.inUse: return 'In Use';
      case OrderStatus.ongoing: return 'Ongoing';
      case OrderStatus.partial: return 'Partial';
      case OrderStatus.returned: return 'Returned';
      case OrderStatus.completed: return 'Completed';
      case OrderStatus.cancelled: return 'Cancelled';
      case OrderStatus.flagged: return 'Flagged';
    }
  }

  String _fmtDate(String dateStr) {
    try {
      return DateFormat('d MMM').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }
}
