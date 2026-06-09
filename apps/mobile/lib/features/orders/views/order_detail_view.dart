import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/responsive.dart';
import '../../products/views/qr_scanner_dialog.dart';
import '../models/order.dart';
import '../viewmodels/providers/order_provider.dart';
import 'order_form_view.dart';

class OrderDetailView extends ConsumerStatefulWidget {
  final Order order;

  const OrderDetailView({super.key, required this.order});

  @override
  ConsumerState<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends ConsumerState<OrderDetailView> {
  late Order _currentOrder;
  bool _isLoading = false;

  static const _primary = Color(0xFF434343);
  static const _accent = Color(0xFFF7C873);
  static const _bg = Color(0xFFF8F8F8);

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  Future<void> _refreshOrder() async {
    setState(() => _isLoading = true);
    try {
      final updated = await ref.read(orderRepositoryProvider).getOrderById(_currentOrder.id);
      setState(() {
        _currentOrder = updated;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final balanceDue = _currentOrder.totalAmount - _currentOrder.amountPaid;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          '#${_currentOrder.id.substring(0, 8)} - ${_currentOrder.customer?.name ?? 'Unknown'}',
          style: TextStyle(
            fontSize: Responsive.sp(15),
            fontWeight: FontWeight.bold,
            color: _primary,
          ),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, size: Responsive.icon(22), color: _primary),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => OrderFormView(order: _currentOrder)))
                .then((_) => _refreshOrder()),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, size: Responsive.icon(22), color: _primary),
            onPressed: _refreshOrder,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: Responsive.icon(22), color: Colors.red[400]),
            onPressed: _deleteOrder,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : SingleChildScrollView(
              padding: Responsive.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(),
                  SizedBox(height: Responsive.h(12)),
                  _buildUrgentAlertBanner(),
                  SizedBox(height: Responsive.h(12)),
                  _buildLogisticsQuickStats(),
                  SizedBox(height: Responsive.h(16)),
                  _buildInfoCard(
                    title: 'Customer Information',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _buildDetailRow('Name', _currentOrder.customer?.name ?? 'N/A'),
                      _buildDetailRow('Phone', _currentOrder.customer?.phone ?? 'N/A'),
                      if (_currentOrder.customer?.altPhone != null)
                        _buildDetailRow('Alt Phone', _currentOrder.customer!.altPhone!),
                      if (_currentOrder.customer?.email != null)
                        _buildDetailRow('Email', _currentOrder.customer!.email!),
                      if (_currentOrder.branch != null)
                        _buildDetailRow('Branch', _currentOrder.branch!.name),
                    ],
                  ),
                  SizedBox(height: Responsive.h(16)),
                  _buildInfoCard(
                    title: 'Fulfillment Dates',
                    icon: Icons.calendar_month_outlined,
                    children: [
                      _buildDetailRow('Start Date', _formatDate(_currentOrder.startDate)),
                      _buildDetailRow('End Date', _formatDate(_currentOrder.endDate)),
                      _buildDetailRow('Event Date', _formatDate(_currentOrder.eventDate)),
                      if (_currentOrder.isLate)
                        _buildDetailRow('Late Flag', 'Overdue', valueColor: Colors.red),
                    ],
                  ),
                  SizedBox(height: Responsive.h(16)),
                  _buildItemsCard(),
                  SizedBox(height: Responsive.h(16)),
                  _buildInfoCard(
                    title: 'Financial Information',
                    icon: Icons.account_balance_wallet_outlined,
                    children: [
                      _buildDetailRow('Subtotal', '₹${_currentOrder.subtotal.toStringAsFixed(2)}'),
                      _buildDetailRow('GST Amount', '₹${_currentOrder.gstAmount.toStringAsFixed(2)}'),
                      _buildDetailRow('Discount', '₹${_currentOrder.discount.toStringAsFixed(2)}'),
                      _buildDetailRow('Damage Charges', '₹${_currentOrder.damageChargesTotal.toStringAsFixed(2)}'),
                      _buildDetailRow('Late Fee', '₹${_currentOrder.lateFee.toStringAsFixed(2)}'),
                      const Divider(height: 16),
                      _buildDetailRow('Total Amount', '₹${_currentOrder.totalAmount.toStringAsFixed(2)}', isBold: true),
                      _buildDetailRow('Advance/Deposit', '₹${_currentOrder.advanceAmount.toStringAsFixed(2)}'),
                      _buildDetailRow('Amount Paid', '₹${_currentOrder.amountPaid.toStringAsFixed(2)}',
                          valueColor: Colors.green),
                      _buildDetailRow(
                        'Balance Due',
                        '₹${balanceDue.toStringAsFixed(2)}',
                        isBold: true,
                        valueColor: balanceDue > 0 ? const Color(0xFFFF6B8A) : Colors.green,
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(16)),
                  _buildPaymentsCard(),
                  SizedBox(height: Responsive.h(16)),
                  _buildInfoCard(
                    title: 'Logistics Details',
                    icon: Icons.local_shipping_outlined,
                    children: [
                      if (_currentOrder.deliveryMethod != null)
                        _buildDetailRow('Method', _currentOrder.deliveryMethod!.name.toUpperCase()),
                      if (_currentOrder.deliveryAddress != null && _currentOrder.deliveryAddress!.isNotEmpty)
                        _buildDetailRow('Delivery Address', _currentOrder.deliveryAddress!),
                      if (_currentOrder.pickupAddress != null && _currentOrder.pickupAddress!.isNotEmpty)
                        _buildDetailRow('Pickup Address', _currentOrder.pickupAddress!),
                      if (_currentOrder.notes != null && _currentOrder.notes!.isNotEmpty)
                        _buildDetailRow('Notes', _currentOrder.notes!),
                    ],
                  ),
                  SizedBox(height: Responsive.h(24)),
                  _buildActionsRow(),
                  SizedBox(height: Responsive.h(40)),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusHeader() {
    final statusColor = _currentOrder.isLate ? const Color(0xFFFF6B8A) : _getStatusColor(_currentOrder.status);
    final statusText = _currentOrder.isLate ? 'OVERDUE' : _formatStatusName(_currentOrder.status);

    return Container(
      padding: Responsive.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(12)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order Status', style: TextStyle(fontSize: Responsive.sp(11), color: Colors.grey)),
              SizedBox(height: Responsive.h(4)),
              Container(
                padding: Responsive.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Responsive.r(8)),
                ),
                child: Text(
                  statusText.toUpperCase(),
                  style: TextStyle(fontSize: Responsive.sp(12), fontWeight: FontWeight.w800, color: statusColor),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Payment Status', style: TextStyle(fontSize: Responsive.sp(11), color: Colors.grey)),
              SizedBox(height: Responsive.h(4)),
              Text(
                _currentOrder.paymentStatus.name.toUpperCase(),
                style: TextStyle(
                  fontSize: Responsive.sp(13),
                  fontWeight: FontWeight.bold,
                  color: _currentOrder.paymentStatus == PaymentStatus.paid ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentAlertBanner() {
    if (!_currentOrder.hasStockConflict) return const SizedBox.shrink();

    final conflicts = _currentOrder.conflictDetails ?? [];

    return Container(
      width: double.infinity,
      padding: Responsive.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!, width: 1.5),
        borderRadius: BorderRadius.circular(Responsive.r(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: Responsive.icon(20)),
              SizedBox(width: Responsive.w(8)),
              Expanded(
                child: Text(
                  'URGENT: Stock Conflict Detected',
                  style: TextStyle(
                    color: Colors.red[900],
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.sp(13),
                  ),
                ),
              ),
            ],
          ),
          if (conflicts.isNotEmpty) ...[
            SizedBox(height: Responsive.h(8)),
            ...conflicts.map((c) {
              final name = c['productName'] ?? 'Unknown Product';
              final short = c['shortfall'] ?? 0;
              return Padding(
                padding: Responsive.symmetric(vertical: 2),
                child: Text(
                  '• $name: Shortfall of $short pc(s)',
                  style: TextStyle(
                    color: Colors.red[850],
                    fontSize: Responsive.sp(11),
                  ),
                ),
              );
            }),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Shortfall of product units for this booking detected.',
                style: TextStyle(color: Colors.red[850], fontSize: Responsive.sp(11)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogisticsQuickStats() {
    return Container(
      padding: Responsive.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(12)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickStatItem('OUT (PICKUP)', _formatDate(_currentOrder.startDate), Icons.login_rounded),
          Container(height: 24, width: 1, color: Colors.grey[200]),
          _buildQuickStatItem('IN (RETURN)', _formatDate(_currentOrder.endDate), Icons.logout_rounded),
          Container(height: 24, width: 1, color: Colors.grey[200]),
          _buildQuickStatItem('TOTAL ITEMS', '${_currentOrder.items?.fold(0, (sum, i) => sum + i.quantity) ?? 0} pcs',
              Icons.shopping_bag_outlined),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: Responsive.icon(14), color: Colors.grey[500]),
            SizedBox(width: Responsive.w(4)),
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(10),
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(4)),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(12),
            fontWeight: FontWeight.bold,
            color: _primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(14)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: Responsive.all(12),
            child: Row(
              children: [
                Icon(icon, size: Responsive.icon(20), color: _primary),
                SizedBox(width: Responsive.w(8)),
                Text(
                  title,
                  style: TextStyle(fontSize: Responsive.sp(14), fontWeight: FontWeight.bold, color: _primary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: Responsive.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: Responsive.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Responsive.w(130),
            child: Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(13),
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: Responsive.sp(13),
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    final items = _currentOrder.items ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(14)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: Responsive.all(12),
            child: Row(
              children: [
                Icon(Icons.shopping_bag_outlined, size: Responsive.icon(20), color: _primary),
                SizedBox(width: Responsive.w(8)),
                Text(
                  'Order Items (${items.length})',
                  style: TextStyle(fontSize: Responsive.sp(14), fontWeight: FontWeight.bold, color: _primary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final item = items[index];
              return Padding(
                padding: Responsive.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: Responsive.w(50),
                      height: Responsive.w(50),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(Responsive.r(8)),
                      ),
                      child: item.product?.primaryImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(Responsive.r(8)),
                              child: Image.network(item.product!.primaryImageUrl!, fit: BoxFit.cover),
                            )
                          : Icon(Icons.image_not_supported_outlined, color: Colors.grey[400]),
                    ),
                    SizedBox(width: Responsive.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product?.name ?? 'Product #${item.productId.substring(0, 8)}',
                            style: TextStyle(fontSize: Responsive.sp(13), fontWeight: FontWeight.bold, color: _primary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: Responsive.h(4)),
                          Text(
                            'Qty: ${item.quantity}  |  Rate: ₹${item.pricePerDay.toStringAsFixed(0)}/day',
                            style: TextStyle(fontSize: Responsive.sp(11), color: Colors.grey[600]),
                          ),
                          if (item.isReturned == true)
                            Padding(
                              padding: Responsive.only(top: 4),
                              child: Text(
                                'Returned: ${item.returnedQuantity ?? item.quantity} (${item.conditionRating?.name ?? 'Good'})',
                                style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: Responsive.sp(13), fontWeight: FontWeight.bold, color: _primary),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsCard() {
    final paymentsAsync = ref.watch(orderPaymentsProvider(_currentOrder.id));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(14)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: Responsive.all(12),
            child: Row(
              children: [
                Icon(Icons.payment_rounded, size: Responsive.icon(20), color: _primary),
                SizedBox(width: Responsive.w(8)),
                Text(
                  'Transaction History',
                  style: TextStyle(fontSize: Responsive.sp(14), fontWeight: FontWeight.bold, color: _primary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          paymentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading payments: $err', style: const TextStyle(color: Colors.red)),
            ),
            data: (transactions) {
              if (transactions.isEmpty) {
                return Padding(
                  padding: Responsive.all(16),
                  child: Text(
                    'No transactions recorded.',
                    style: TextStyle(color: Colors.grey[500], fontSize: Responsive.sp(12)),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final tx = transactions[index];
                  return Padding(
                    padding: Responsive.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    tx.paymentType.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: Responsive.sp(11),
                                      fontWeight: FontWeight.w800,
                                      color: _getTransactionTypeColor(tx.paymentType),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '₹${tx.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(13),
                                      fontWeight: FontWeight.bold,
                                      color: _primary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Responsive.h(4)),
                              Text(
                                'Mode: ${tx.paymentMode.toUpperCase()}  |  ${_formatDate(tx.paymentDate)}',
                                style: TextStyle(fontSize: Responsive.sp(11), color: Colors.grey[600]),
                              ),
                              if (tx.notes != null && tx.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Notes: ${tx.notes}',
                                    style: TextStyle(fontSize: Responsive.sp(11), color: Colors.grey[500], fontStyle: FontStyle.italic),
                                  ),
                                ),
                              if (tx.createdByName != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    'Processed by: ${tx.createdByName}',
                                    style: TextStyle(fontSize: Responsive.sp(10), color: Colors.grey[400]),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, size: Responsive.icon(16), color: Colors.blue),
                          onPressed: () => _openEditTransactionDialog(tx),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    final actions = <Widget>[];

    // Status transition action buttons
    if (_currentOrder.status == OrderStatus.confirmed || _currentOrder.status == OrderStatus.scheduled) {
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              padding: Responsive.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _startRentalWithCheck,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Rental'),
          ),
        ),
      );
    }

    if (_currentOrder.status == OrderStatus.ongoing || _currentOrder.status == OrderStatus.delivered || _currentOrder.status == OrderStatus.inUse) {
      if (actions.isNotEmpty) actions.add(SizedBox(width: Responsive.w(12)));
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: _primary,
              padding: Responsive.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _openReturnDialog,
            icon: const Icon(Icons.assignment_turned_in_rounded),
            label: const Text('Process Return'),
          ),
        ),
      );
    }

    // Payment collection button
    if (_currentOrder.paymentStatus != PaymentStatus.paid) {
      if (actions.isNotEmpty) actions.add(SizedBox(width: Responsive.w(12)));
      actions.add(
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _primary),
              foregroundColor: _primary,
              padding: Responsive.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _openPaymentDialog,
            icon: const Icon(Icons.payment_rounded),
            label: const Text('Collect Pay'),
          ),
        ),
      );
    }

    // Cancel order button
    if (_currentOrder.status != OrderStatus.cancelled && _currentOrder.status != OrderStatus.completed) {
      if (actions.isNotEmpty) actions.add(SizedBox(width: Responsive.w(12)));
      actions.add(
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              foregroundColor: Colors.red,
              padding: Responsive.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _openCancelDialog,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel Order'),
          ),
        ),
      );
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: actions);
  }

  Future<void> _startRentalWithCheck() async {
    setState(() => _isLoading = true);

    try {
      final itemsPayload = (_currentOrder.items ?? []).map((i) => {
        'product_id': i.productId,
        'quantity': i.quantity,
      }).toList();

      final checkResult = await ref.read(orderOperationsProvider).checkAvailability(
        startDate: _currentOrder.startDate,
        endDate: _currentOrder.endDate,
        branchId: _currentOrder.branchId,
        items: itemsPayload,
        excludeOrderId: _currentOrder.id,
      );

      final allAvailable = checkResult['allAvailable'] ?? false;

      if (!allAvailable) {
        setState(() => _isLoading = false);
        if (mounted) {
          final itemsList = checkResult['items'] as List<dynamic>? ?? [];
          _showFulfillmentFailedModal(itemsList);
        }
        return;
      }

      // If available, transition status to ongoing
      await ref.read(orderOperationsProvider).updateOrder(_currentOrder.id, {'status': 'ongoing'});
      await _refreshOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rental started successfully!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Availability check failed: $e')),
        );
      }
    }
  }

  void _showFulfillmentFailedModal(List<dynamic> itemsList) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Fulfillment Blocked'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Stock shortfall detected for the selected period:'),
              const SizedBox(height: 12),
              ...itemsList.where((i) => !(i['isAvailable'] as bool? ?? true)).map((i) {
                final name = i['product_name'] ?? 'Product';
                final avail = i['available'] ?? 0;
                final req = i['requested'] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '• $name: Requested $req, but only $avail available.',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent),
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _openCancelDialog() {
    final reasonController = TextEditingController();
    final refundController = TextEditingController(text: '0');
    final paidAmount = _currentOrder.amountPaid;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to cancel this order?'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Cancellation Reason',
                  border: OutlineInputBorder(),
                ),
              ),
              if (paidAmount > 0) ...[
                const SizedBox(height: 12),
                Text('Total Paid so far: ₹$paidAmount'),
                const SizedBox(height: 6),
                TextField(
                  controller: refundController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Refund Amount (₹)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a cancellation reason')),
                  );
                  return;
                }
                final refund = double.tryParse(refundController.text) ?? 0.0;
                Navigator.pop(context);
                setState(() => _isLoading = true);
                try {
                  await ref.read(orderOperationsProvider).updateOrder(_currentOrder.id, {
                    'status': 'cancelled',
                    'cancellation_reason': reason,
                    if (paidAmount > 0) 'refund_amount': refund,
                  });
                  await _refreshOrder();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order cancelled successfully')),
                    );
                  }
                } catch (e) {
                  setState(() => _isLoading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cancellation failed: $e')),
                    );
                  }
                }
              },
              child: const Text('Confirm Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _openPaymentDialog() {
    final maxCollect = _currentOrder.totalAmount - _currentOrder.amountPaid;
    final amountController = TextEditingController(text: maxCollect.toStringAsFixed(0));
    String paymentMode = 'upi';
    String paymentType = 'final';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Collect Payment',
                    style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold, color: _primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Balance Due: ₹${maxCollect.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: Responsive.sp(12), color: Colors.grey[600]),
                  ),
                  SizedBox(height: Responsive.h(16)),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: Responsive.sp(15)),
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),
                  DropdownButtonFormField<String>(
                    value: paymentMode,
                    decoration: InputDecoration(
                      labelText: 'Payment Mode',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'upi', child: Text('UPI / GPay')),
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'card', child: Text('Card')),
                      DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                      DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => paymentMode = val);
                    },
                  ),
                  SizedBox(height: Responsive.h(16)),
                  DropdownButtonFormField<String>(
                    value: paymentType,
                    decoration: InputDecoration(
                      labelText: 'Transaction Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'advance', child: Text('Advance Deposit')),
                      DropdownMenuItem(value: 'final', child: Text('Final Settlement')),
                      DropdownMenuItem(value: 'refund', child: Text('Refund')),
                      DropdownMenuItem(value: 'adjustment', child: Text('Adjustment')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => paymentType = val);
                    },
                  ),
                  SizedBox(height: Responsive.h(24)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final amt = double.tryParse(amountController.text) ?? 0.0;
                        if (amt <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid amount')),
                          );
                          return;
                        }

                        if (amt > maxCollect && paymentType != 'refund') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Warning: Amount exceeds balance due of ₹${maxCollect.toStringAsFixed(0)}')),
                          );
                          return;
                        }

                        Navigator.pop(context);
                        setState(() => _isLoading = true);
                        try {
                          await ref.read(orderOperationsProvider).collectPayment(
                                orderId: _currentOrder.id,
                                amount: amt,
                                paymentMode: paymentMode,
                                paymentType: paymentType,
                              );
                          await _refreshOrder();
                          ref.invalidate(orderPaymentsProvider(_currentOrder.id));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment recorded successfully')),
                            );
                          }
                        } catch (e) {
                          setState(() => _isLoading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to record payment: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Record Payment'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openEditTransactionDialog(PaymentTransaction tx) {
    String paymentMode = tx.paymentMode;
    final notesController = TextEditingController(text: tx.notes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Transaction Details',
                    style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold, color: _primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Amount: ₹${tx.amount.toStringAsFixed(2)}  |  Type: ${tx.paymentType.toUpperCase()}',
                    style: TextStyle(fontSize: Responsive.sp(12), color: Colors.grey[600]),
                  ),
                  SizedBox(height: Responsive.h(16)),
                  DropdownButtonFormField<String>(
                    value: paymentMode,
                    decoration: InputDecoration(
                      labelText: 'Payment Mode',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'upi', child: Text('UPI / GPay')),
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'card', child: Text('Card')),
                      DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                      DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => paymentMode = val);
                    },
                  ),
                  SizedBox(height: Responsive.h(16)),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: Responsive.h(24)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() => _isLoading = true);
                        try {
                          await ref.read(orderOperationsProvider).updatePayment(
                            paymentId: tx.id,
                            paymentMode: paymentMode,
                            notes: notesController.text.trim(),
                          );
                          await _refreshOrder();
                          ref.invalidate(orderPaymentsProvider(_currentOrder.id));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Transaction updated successfully')),
                            );
                          }
                        } catch (e) {
                          setState(() => _isLoading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to update transaction: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Update Transaction'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openReturnDialog() {
    final items = _currentOrder.items ?? [];
    final returnQuantities = <String, int>{};
    final returnConditions = <String, ConditionRating>{};
    final damageQuantities = <String, int>{};
    final damageCharges = <String, double>{};
    final damageDescriptions = <String, String>{};

    final lateFeeController = TextEditingController(text: '0');
    final discountController = TextEditingController(text: '0');
    final notesController = TextEditingController();

    // Default initialization
    for (final item in items) {
      final maxReturn = item.quantity - (item.returnedQuantity ?? 0);
      returnQuantities[item.id] = maxReturn;
      returnConditions[item.id] = ConditionRating.good;
      damageQuantities[item.id] = 0;
      damageCharges[item.id] = 0.0;
      damageDescriptions[item.id] = '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double liveDamageTotal = 0.0;
            returnConditions.forEach((itemId, cond) {
              if (cond == ConditionRating.damaged) {
                liveDamageTotal += damageCharges[itemId] ?? 0.0;
              }
            });

            final double parsedLate = double.tryParse(lateFeeController.text) ?? 0.0;
            final double parsedDiscount = double.tryParse(discountController.text) ?? 0.0;
            final balanceDue = _currentOrder.totalAmount - _currentOrder.amountPaid + liveDamageTotal + parsedLate - parsedDiscount;

            // Barcode scan function
            void handleBarcodeScan() {
              showDialog(
                context: context,
                builder: (context) => QRScannerDialog(
                  onRawCodeScanned: (rawCode) async {
                    try {
                      final response = await Supabase.instance.client
                          .from('products')
                          .select('id')
                          .or('sku.eq.$rawCode,barcode.eq.$rawCode')
                          .maybeSingle();

                      if (response != null && response['id'] != null) {
                        final matchedId = response['id'] as String;
                        final matchedItem = items.firstWhere(
                          (item) => item.productId == matchedId,
                          orElse: () => throw Exception('Product not found in this order'),
                        );

                        setModalState(() {
                          final maxReturn = matchedItem.quantity - (matchedItem.returnedQuantity ?? 0);
                          returnQuantities[matchedItem.id] = maxReturn;
                          returnConditions[matchedItem.id] = ConditionRating.good;
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Item marked as GOOD: ${matchedItem.product?.name ?? "Product"}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No matching item in order for barcode/SKU')),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error resolving barcode: $e')),
                        );
                      }
                    }
                  },
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Process Returns Check-In',
                          style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold, color: _primary),
                        ),
                        IconButton(
                          icon: Icon(Icons.qr_code_scanner_rounded, color: _primary, size: Responsive.icon(22)),
                          onPressed: handleBarcodeScan,
                        ),
                      ],
                    ),
                    const Divider(),
                    ...items.map((item) {
                      final maxReturn = item.quantity - (item.returnedQuantity ?? 0);
                      if (maxReturn <= 0) return const SizedBox.shrink();

                      final currentCondition = returnConditions[item.id];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product?.name ?? 'Product #${item.productId.substring(0, 8)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Text('Qty: '),
                                DropdownButton<int>(
                                  value: returnQuantities[item.id],
                                  items: List.generate(maxReturn + 1, (i) => i)
                                      .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setModalState(() => returnQuantities[item.id] = val);
                                    }
                                  },
                                ),
                                const Spacer(),
                                const Text('Condition: '),
                                DropdownButton<ConditionRating>(
                                  value: currentCondition,
                                  items: ConditionRating.values
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase())))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setModalState(() => returnConditions[item.id] = val);
                                    }
                                  },
                                ),
                              ],
                            ),
                            if (currentCondition == ConditionRating.damaged) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('Damaged Qty: '),
                                  DropdownButton<int>(
                                    value: damageQuantities[item.id],
                                    items: List.generate(returnQuantities[item.id]! + 1, (i) => i)
                                        .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() => damageQuantities[item.id] = val);
                                      }
                                    },
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: Responsive.w(120),
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Damage Fee (₹)', isDense: true),
                                      onChanged: (val) {
                                        setModalState(() {
                                          damageCharges[item.id] = double.tryParse(val) ?? 0.0;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                decoration: const InputDecoration(labelText: 'Describe Damage', isDense: true),
                                onChanged: (val) {
                                  damageDescriptions[item.id] = val;
                                },
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                for (final item in items) {
                                  returnQuantities[item.id] = item.quantity - (item.returnedQuantity ?? 0);
                                  returnConditions[item.id] = ConditionRating.excellent;
                                }
                              });
                            },
                            child: const Text('Mark All Good'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: lateFeeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Late Fee charges (₹)'),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    SizedBox(height: Responsive.h(12)),
                    TextField(
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Discounts (₹)'),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    SizedBox(height: Responsive.h(12)),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Return Notes'),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Live Return Financials Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Damage Fees Total:'),
                              Text('₹${liveDamageTotal.toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Additional Late Fee:'),
                              Text('₹${parsedLate.toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Additional Discount:'),
                              Text('₹${parsedDiscount.toStringAsFixed(2)}'),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Projected Balance Due:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '₹${balanceDue.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: balanceDue > 0 ? const Color(0xFFFF6B8A) : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.h(24)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          final returnItemsPayload = <Map<String, dynamic>>[];
                          returnQuantities.forEach((itemId, qty) {
                            if (qty > 0) {
                              returnItemsPayload.add({
                                'item_id': itemId,
                                'returned_quantity': qty,
                                'condition_rating': returnConditions[itemId]!.name.toLowerCase(),
                                if (returnConditions[itemId] == ConditionRating.damaged) ...{
                                  'damage_description': damageDescriptions[itemId],
                                  'damage_charges': damageCharges[itemId],
                                  'damaged_quantity': damageQuantities[itemId],
                                }
                              });
                            }
                          });

                          if (returnItemsPayload.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select at least 1 item to return')),
                            );
                            return;
                          }

                          Navigator.pop(context);
                          setState(() => _isLoading = true);
                          try {
                            await ref.read(orderOperationsProvider).processReturn(
                                  orderId: _currentOrder.id,
                                  items: returnItemsPayload,
                                  notes: notesController.text,
                                  lateFee: double.tryParse(lateFeeController.text) ?? 0.0,
                                  discount: double.tryParse(discountController.text) ?? 0.0,
                                );
                            await _refreshOrder();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Return processed successfully')),
                              );
                            }
                          } catch (e) {
                            setState(() => _isLoading = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to process return: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Settle & Submit Return'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await ref.read(orderOperationsProvider).deleteOrder(_currentOrder.id);
        if (mounted) {
          ref.invalidate(ordersProvider);
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete order: $e')),
          );
        }
      }
    }
  }

  Color _getStatusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return const Color(0xFFF5A623);
      case OrderStatus.confirmed:
      case OrderStatus.scheduled: return const Color(0xFF4A90D9);
      case OrderStatus.delivered:
      case OrderStatus.inUse:
      case OrderStatus.ongoing: return const Color(0xFF7B68EE);
      case OrderStatus.returned: return const Color(0xFF2ECC71);
      case OrderStatus.completed: return const Color(0xFF2ECC71);
      case OrderStatus.cancelled: return const Color(0xFF95A5A6);
      case OrderStatus.flagged: return const Color(0xFFFF6B8A);
      case OrderStatus.partial: return const Color(0xFFF5A623);
    }
  }

  Color _getTransactionTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
      case 'advance': return Colors.teal;
      case 'final': return Colors.green;
      case 'refund': return Colors.red;
      case 'adjustment': return Colors.orange;
      default: return Colors.blue;
    }
  }

  String _formatStatusName(OrderStatus s) {
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
