import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../../products/views/qr_scanner_dialog.dart';
import '../../products/viewmodels/providers/product_provider.dart';
import '../models/order.dart';
import '../viewmodels/providers/order_provider.dart';
import 'order_form_view.dart';

class OrderDetailView extends ConsumerStatefulWidget {
  final Order order;
  final bool autoOpenReturn;
  final bool autoOpenPayment;

  const OrderDetailView({
    super.key,
    required this.order,
    this.autoOpenReturn = false,
    this.autoOpenPayment = false,
  });

  @override
  ConsumerState<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends ConsumerState<OrderDetailView> with AutomaticKeepAliveClientMixin {
  late Order _currentOrder;
  bool _isLoading = false;
  
  final Map<String, Map<String, dynamic>> _localReturnItems = {};
  final Map<String, TextEditingController> _notesControllers = {};
  final Map<String, TextEditingController> _feeControllers = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _initializeReturnItems();
    
    // Auto-open dialogs based on flags
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autoOpenReturn) {
        _openReturnDialog();
      } else if (widget.autoOpenPayment) {
        _openPaymentDialog();
      }
    });
  }

  @override
  void dispose() {
    for (final ctrl in _notesControllers.values) {
      ctrl.dispose();
    }
    for (final ctrl in _feeControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _initializeReturnItems() {
    _localReturnItems.clear();
    final items = _currentOrder.items ?? [];
    for (final item in items) {
      String? status;
      if (item.isReturned == true) {
        status = item.conditionRating == ConditionRating.damaged ? 'damaged' : 'good';
      }
      _localReturnItems[item.id] = {
        'status': status,
        'damage_fee': item.damageCharges ?? 0.0,
        'damaged_quantity': item.damagedQuantity ?? item.quantity,
        'notes': item.damageDescription ?? '',
      };
    }
  }

  TextEditingController _getNotesController(String itemId, String initialValue) {
    return _notesControllers.putIfAbsent(itemId, () => TextEditingController(text: initialValue));
  }

  TextEditingController _getFeeController(String itemId, double initialValue) {
    return _feeControllers.putIfAbsent(
      itemId,
      () => TextEditingController(text: initialValue > 0 ? initialValue.toStringAsFixed(0) : '0'),
    );
  }

  void _openAdjustmentDialog() {
    String adjustmentType = 'discount';
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apply Financial Adjustment',
                    style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  SizedBox(height: Responsive.h(16)),
                  DropdownButtonFormField<String>(
                    initialValue: adjustmentType,
                    decoration: InputDecoration(
                      labelText: 'Adjustment Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'discount', child: Text('Discount (reduces total)')),
                      DropdownMenuItem(value: 'late_fee', child: Text('Late Fee (increases total)')),
                      DropdownMenuItem(value: 'damage_fee', child: Text('Damage Fee (increases total)')),
                      DropdownMenuItem(value: 'extra_charge', child: Text('Extra Charge (increases total)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => adjustmentType = val);
                    },
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
                  TextField(
                    controller: notesController,
                    style: TextStyle(fontSize: Responsive.sp(15)),
                    decoration: InputDecoration(
                      labelText: 'Reason / Notes',
                      hintText: 'E.g. Loyal customer discount',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: Responsive.h(24)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final val = double.tryParse(amountController.text) ?? 0.0;
                        if (val <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter an amount greater than 0')),
                          );
                          return;
                        }

                        final isDeduction = adjustmentType == 'discount';
                        final double updatedTotal = isDeduction 
                            ? (_currentOrder.totalAmount - val).clamp(0.0, double.infinity) 
                            : _currentOrder.totalAmount + val;
                            
                        final double newLateFee = adjustmentType == 'late_fee' 
                            ? _currentOrder.lateFee + val 
                            : _currentOrder.lateFee;
                            
                        final double newDiscount = adjustmentType == 'discount' 
                            ? _currentOrder.discount + val 
                            : _currentOrder.discount;
                            
                        final double newDamage = adjustmentType == 'damage_fee' 
                            ? _currentOrder.damageChargesTotal + val 
                            : _currentOrder.damageChargesTotal;
                            
                        final double newAmountPaid = _currentOrder.amountPaid;
                        final String newPaymentStatus = newAmountPaid >= updatedTotal 
                            ? 'paid' 
                            : newAmountPaid > 0 
                                ? 'partial' 
                                : 'pending';

                        final String label = adjustmentType == 'discount' 
                            ? 'Discount' 
                            : adjustmentType == 'late_fee' 
                                ? 'Late Fee' 
                                : adjustmentType == 'damage_fee' 
                                    ? 'Damage Fee' 
                                    : 'Extra Charge';

                        Navigator.pop(modalContext);
                        setState(() => _isLoading = true);
                        try {
                          // 1. Record as adjustment payment
                          await ref.read(orderOperationsProvider).collectPayment(
                            orderId: _currentOrder.id,
                            amount: val,
                            paymentMode: 'cash',
                            paymentType: 'adjustment',
                            notes: '$label: ${notesController.text.trim().isNotEmpty ? notesController.text.trim() : 'N/A'}',
                          );

                          // 2. Update order totals
                          await ref.read(orderOperationsProvider).updateOrder(_currentOrder.id, {
                            'total_amount': updatedTotal,
                            'late_fee': newLateFee,
                            'discount': newDiscount,
                            'damage_charges_total': newDamage,
                            'payment_status': newPaymentStatus,
                          });

                          await _refreshOrder();
                          ref.invalidate(orderPaymentsProvider(_currentOrder.id));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$label of ₹${val.toStringAsFixed(2)} has been applied.')),
                            );
                          }
                        } catch (e) {
                          setState(() => _isLoading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to apply adjustment: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Apply Adjustment'),
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

  Widget _buildInteractiveItemControls(OrderItem item) {
    final state = _localReturnItems[item.id] ?? {
      'status': null,
      'damage_fee': 0.0,
      'damaged_quantity': item.quantity,
      'notes': '',
    };

    final currentStatus = state['status'];
    final isGood = currentStatus == 'good';
    final isDamaged = currentStatus == 'damaged';

    final notesCtrl = _getNotesController(item.id, state['notes'] as String);
    final feeCtrl = _getFeeController(item.id, state['damage_fee'] as double);

    final dbStatus = item.isReturned == true
        ? (item.conditionRating == ConditionRating.damaged ? 'damaged' : 'good')
        : null;
    final double dbFee = item.damageCharges ?? 0.0;
    final int dbDamagedQty = item.conditionRating == ConditionRating.damaged ? (item.damagedQuantity ?? 0) : 0;
    final String dbNotes = item.damageDescription ?? '';

    final currentDamagedQty = isDamaged ? (state['damaged_quantity'] as int) : 0;
    final isDirty = currentStatus != dbStatus ||
        (state['damage_fee'] as double) != dbFee ||
        currentDamagedQty != dbDamagedQty ||
        (state['notes'] as String) != dbNotes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _localReturnItems[item.id]!['status'] = 'good';
                    _localReturnItems[item.id]!['damaged_quantity'] = 0;
                    _localReturnItems[item.id]!['damage_fee'] = 0.0;
                    _localReturnItems[item.id]!['notes'] = '';
                    feeCtrl.text = '0';
                    notesCtrl.text = '';
                  });
                },
                icon: Icon(
                  isGood ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                  size: Responsive.icon(16),
                  color: isGood ? Colors.white : AppColors.success,
                ),
                label: Text(
                  'Good',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isGood ? AppColors.success : Colors.white,
                  foregroundColor: isGood ? Colors.white : AppColors.success,
                  side: BorderSide(
                    color: isGood ? AppColors.success : AppColors.success.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                  ),
                  padding: Responsive.symmetric(vertical: AppSizes.spacingSmall),
                ),
              ),
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _localReturnItems[item.id]!['status'] = 'damaged';
                    if ((_localReturnItems[item.id]!['damaged_quantity'] as int) == 0) {
                      _localReturnItems[item.id]!['damaged_quantity'] = item.quantity;
                    }
                  });
                },
                icon: Icon(
                  isDamaged ? Icons.warning_rounded : Icons.warning_amber_rounded,
                  size: Responsive.icon(16),
                  color: isDamaged ? Colors.white : AppColors.warning,
                ),
                label: Text(
                  'Damaged',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDamaged ? AppColors.warning : Colors.white,
                  foregroundColor: isDamaged ? Colors.white : AppColors.warning,
                  side: BorderSide(
                    color: isDamaged ? AppColors.warning : AppColors.warning.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                  ),
                  padding: Responsive.symmetric(vertical: AppSizes.spacingSmall),
                ),
              ),
            ),
          ],
        ),
        if (isDamaged) ...[
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          Container(
            padding: Responsive.all(AppSizes.spacingMedium),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.05),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.2), width: 1),
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Damage Notes',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontTiny),
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: Responsive.h(4)),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    hintText: 'Describe damage (e.g. Broken clasp)',
                    hintStyle: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), color: Colors.grey),
                    isDense: true,
                    contentPadding: Responsive.symmetric(vertical: AppSizes.spacingSmall, horizontal: AppSizes.spacingSmall),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    _localReturnItems[item.id]!['notes'] = val;
                    setState(() {});
                  },
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Damaged Qty',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontTiny),
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          SizedBox(height: Responsive.h(4)),
                          Container(
                            padding: Responsive.symmetric(horizontal: AppSizes.spacingSmall),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: state['damaged_quantity'] as int,
                                isExpanded: true,
                                items: List.generate(item.quantity, (i) => i + 1)
                                    .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _localReturnItems[item.id]!['damaged_quantity'] = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fee (₹)',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontTiny),
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          SizedBox(height: Responsive.h(4)),
                          TextField(
                            controller: feeCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              _localReturnItems[item.id]!['damage_fee'] = double.tryParse(val) ?? 0.0;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                SizedBox(
                  width: double.infinity,
                  child: isDirty
                      ? ElevatedButton.icon(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            try {
                              await ref.read(orderOperationsProvider).updateOrderItemDamage(
                                    itemId: item.id,
                                    conditionRating: 'damaged',
                                    damageDescription: state['notes'] as String,
                                    damageCharges: state['damage_fee'] as double,
                                    damagedQuantity: state['damaged_quantity'] as int,
                                  );
                              await _refreshOrder();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Item damage details saved successfully.')),
                                );
                              }
                            } catch (e) {
                              setState(() => _isLoading = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to save item damage: $e')),
                                );
                              }
                            }
                          },
                          icon: Icon(Icons.save_rounded, size: Responsive.icon(16)),
                          label: const Text('Save Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                            ),
                          ),
                        )
                      : Container(
                          padding: Responsive.symmetric(vertical: AppSizes.spacingSmall),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppColors.success, size: Responsive.icon(16)),
                              SizedBox(width: Responsive.w(8)),
                              Text(
                                'Saved',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Responsive.sp(AppSizes.fontSmall),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
        if (isGood) ...[
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          SizedBox(
            width: double.infinity,
            child: isDirty
                ? ElevatedButton.icon(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      try {
                        await ref.read(orderOperationsProvider).updateOrderItemDamage(
                              itemId: item.id,
                              conditionRating: 'excellent',
                              damageDescription: null,
                              damageCharges: 0.0,
                              damagedQuantity: 0,
                            );
                        await _refreshOrder();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Item condition set to GOOD.')),
                          );
                        }
                      } catch (e) {
                        setState(() => _isLoading = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update condition: $e')),
                          );
                        }
                      }
                    },
                    icon: Icon(Icons.save_rounded, size: Responsive.icon(16)),
                    label: const Text('Save Condition'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                      ),
                    ),
                  )
                : Container(
                    padding: Responsive.symmetric(vertical: AppSizes.spacingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: Responsive.icon(16)),
                        SizedBox(width: Responsive.w(8)),
                        Text(
                          'Good Condition Saved',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  Future<void> _refreshOrder() async {
    setState(() => _isLoading = true);
    try {
      final updated = await ref.read(orderRepositoryProvider).getOrderById(_currentOrder.id);
      setState(() {
        _currentOrder = updated;
        _initializeReturnItems();
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    Responsive.init(context);

    final isEditable = ![
      OrderStatus.cancelled,
      OrderStatus.completed,
      OrderStatus.returned,
      OrderStatus.ongoing,
      OrderStatus.inUse,
    ].contains(_currentOrder.status);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontLarge),
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (isEditable)
            IconButton(
              icon: Icon(Icons.edit_outlined, size: Responsive.icon(AppSizes.iconMedium), color: AppColors.primary),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => OrderFormView(order: _currentOrder)))
                  .then((_) {
                    // Selective invalidation - only invalidate list, keep detail cache
                    ref.invalidate(ordersProvider);
                    _refreshOrder();
                  }),
            ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, size: Responsive.icon(AppSizes.iconMedium), color: AppColors.primary),
            onPressed: _refreshOrder,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: Responsive.icon(AppSizes.iconMedium), color: AppColors.error),
            onPressed: _deleteOrder,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: Responsive.all(AppSizes.screenPaddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  _buildStatusStepper(),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  _buildUrgentAlertBanner(),
                  if (_currentOrder.hasStockConflict)
                    SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  _buildLogisticsQuickStats(),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  _buildCustomerCard(),

                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  _buildItemsCard(),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  _buildFinancialReceiptCard(),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  _buildPaymentsCard(),
                  SizedBox(height: Responsive.h(AppSizes.spacingMassive)),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroCard() {
    final balanceDue = _currentOrder.totalAmount - _currentOrder.amountPaid;
    final statusText = _currentOrder.isLate ? 'OVERDUE' : _formatStatusName(_currentOrder.status);
    final isPaid = balanceDue <= 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: Responsive.r(AppSizes.radiusSmall),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: Responsive.all(AppSizes.screenPaddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentOrder.invoiceNumber != null
                    ? 'Invoice: ${_currentOrder.invoiceNumber}'
                    : '#${_currentOrder.id.substring(0, 8).toUpperCase()}',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontLarge),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
              Container(
                padding: Responsive.symmetric(
                  horizontal: AppSizes.spacingSmall + 2,
                  vertical: AppSizes.spacingTiny,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusText.toUpperCase(),
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          Text(
            _currentOrder.customer?.name ?? 'Unknown Customer',
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontMedium + 1),
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          const Divider(color: Colors.white24, height: 1),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL AMOUNT',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontTiny),
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: Responsive.h(2)),
                  Text(
                    '₹${_currentOrder.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontLarge + 2),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: Responsive.symmetric(
                  horizontal: AppSizes.spacingMedium,
                  vertical: AppSizes.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: isPaid ? AppColors.success.withValues(alpha: 0.25) : AppColors.error.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                  border: Border.all(
                    color: isPaid ? AppColors.success.withValues(alpha: 0.4) : AppColors.error.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isPaid ? 'PAID' : 'DUE BALANCE',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      isPaid ? '₹0.00' : '₹${balanceDue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontMedium),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildHeroActions(),
        ],
      ),
    );
  }

  Widget _buildHeroActions() {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    final rentalEnd = DateTime.tryParse(_currentOrder.endDate);
    final rentalEndMidnight = rentalEnd != null ? DateTime(rentalEnd.year, rentalEnd.month, rentalEnd.day) : null;

    final createdAt = DateTime.tryParse(_currentOrder.createdAt);
    final createdAtMidnight = createdAt != null ? DateTime(createdAt.year, createdAt.month, createdAt.day) : null;

    final rentalStart = DateTime.tryParse(_currentOrder.startDate);
    final rentalStartMidnight = rentalStart != null ? DateTime(rentalStart.year, rentalStart.month, rentalStart.day) : null;

    final isBackdated = rentalStartMidnight != null && createdAtMidnight != null && rentalStartMidnight.isBefore(createdAtMidnight);
    final isExpired = !isBackdated && rentalEndMidnight != null && todayMidnight.isAfter(rentalEndMidnight);

    if ((_currentOrder.status == OrderStatus.confirmed || _currentOrder.status == OrderStatus.scheduled) && isExpired) {
      return Padding(
        padding: Responsive.only(top: AppSizes.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: Responsive.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[200]!, width: 1),
                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.error, size: Responsive.icon(AppSizes.iconSmall)),
                  SizedBox(width: Responsive.w(8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rental Period Expired',
                          style: TextStyle(
                            color: Colors.red[900],
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                          ),
                        ),
                        SizedBox(height: Responsive.h(4)),
                        Text(
                          'The return date for this scheduled order has already passed. You cannot start this rental. Please cancel this order and create a fresh one.',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openCancelDialog,
                icon: Icon(Icons.cancel_outlined, color: AppColors.error, size: Responsive.icon(AppSizes.iconSmall)),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Cancel Order',
                    style: TextStyle(color: AppColors.error, fontSize: Responsive.sp(AppSizes.fontSmall), fontWeight: FontWeight.bold),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error, width: AppSizes.spacingTiny * 0.375),
                  padding: Responsive.symmetric(vertical: AppSizes.spacingSmall),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final actions = <Widget>[];

    // Status transition action buttons
    if (_currentOrder.status == OrderStatus.confirmed || _currentOrder.status == OrderStatus.scheduled) {
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: Responsive.symmetric(vertical: AppSizes.spacingSmall),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
            ),
            onPressed: _startRentalWithCheck,
            icon: Icon(Icons.play_arrow_rounded, size: Responsive.icon(AppSizes.iconSmall)),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                AppStrings.startRental,
                style: TextStyle(fontSize: Responsive.sp(AppSizes.fontTiny + 1), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    }

    if (_currentOrder.status == OrderStatus.ongoing || _currentOrder.status == OrderStatus.delivered || _currentOrder.status == OrderStatus.inUse) {
      if (actions.isNotEmpty) actions.add(SizedBox(width: Responsive.w(AppSizes.spacingSmall)));
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: Responsive.symmetric(vertical: AppSizes.spacingSmall),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
            ),
            onPressed: _openReturnDialog,
            icon: Icon(Icons.assignment_turned_in_rounded, size: Responsive.icon(AppSizes.iconSmall)),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Process Return',
                style: TextStyle(fontSize: Responsive.sp(AppSizes.fontTiny + 1), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    }

    // Payment collection button
    if (_currentOrder.paymentStatus != PaymentStatus.paid) {
      if (actions.isNotEmpty) actions.add(SizedBox(width: Responsive.w(AppSizes.spacingSmall)));
      actions.add(
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white, width: AppSizes.spacingTiny * 0.375),
              foregroundColor: Colors.white,
              padding: Responsive.symmetric(vertical: AppSizes.spacingSmall),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
            ),
            onPressed: _openPaymentDialog,
            icon: Icon(Icons.payment_rounded, size: Responsive.icon(AppSizes.iconSmall)),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Collect Payment',
                style: TextStyle(fontSize: Responsive.sp(AppSizes.fontTiny + 1), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    }

    // Cancel order button
    if (_currentOrder.status != OrderStatus.cancelled && _currentOrder.status != OrderStatus.completed) {
      if (actions.isNotEmpty) actions.add(SizedBox(width: Responsive.w(AppSizes.spacingSmall)));
      actions.add(
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.45), width: AppSizes.spacingTiny / 4),
              foregroundColor: Colors.red[100],
              padding: Responsive.symmetric(vertical: AppSizes.spacingSmall),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
            ),
            onPressed: _openCancelDialog,
            icon: Icon(Icons.cancel_outlined, size: Responsive.icon(AppSizes.iconSmall), color: Colors.red[100]),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: Responsive.sp(AppSizes.fontTiny + 1), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: Responsive.only(top: AppSizes.spacingMedium),
      child: Row(children: actions),
    );
  }

  Widget _buildStatusStepper() {
    final status = _currentOrder.status;
    final amountPaid = _currentOrder.amountPaid;
    final isCancelled = status == OrderStatus.cancelled;

    final steps = [
      _StepItem(
        label: 'Created',
        stepNumber: 'Step 1',
        isActive: true,
        icon: Icons.calendar_today_rounded,
      ),
      _StepItem(
        label: 'Payment',
        stepNumber: 'Step 2',
        isActive: amountPaid > 0,
        icon: Icons.account_balance_wallet_rounded,
      ),
      _StepItem(
        label: 'Ready',
        stepNumber: 'Step 3',
        isActive: const [
          OrderStatus.confirmed,
          OrderStatus.scheduled,
          OrderStatus.ongoing,
          OrderStatus.inUse,
          OrderStatus.partial,
          OrderStatus.returned,
          OrderStatus.completed,
        ].contains(status),
        icon: Icons.inventory_2_rounded,
      ),
      _StepItem(
        label: 'Rented',
        stepNumber: 'Step 4',
        isActive: const [
          OrderStatus.ongoing,
          OrderStatus.inUse,
          OrderStatus.partial,
          OrderStatus.returned,
          OrderStatus.completed,
        ].contains(status),
        icon: Icons.local_shipping_rounded,
      ),
      _StepItem(
        label: isCancelled ? 'Cancelled' : 'Completed',
        stepNumber: 'Step 5',
        isActive: const [
          OrderStatus.returned,
          OrderStatus.completed,
          OrderStatus.cancelled,
        ].contains(status),
        icon: isCancelled ? Icons.cancel_rounded : Icons.check_circle_rounded,
        activeColor: isCancelled ? AppColors.error : AppColors.success,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        border: Border.all(color: AppColors.border, width: AppSizes.spacingTiny / 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: Responsive.r(AppSizes.radiusSmall),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: Responsive.symmetric(
        horizontal: AppSizes.spacingMedium,
        vertical: AppSizes.spacingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER STATUS TIMELINE',
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontTiny),
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index % 2 == 1) {
                final stepIndex = index ~/ 2;
                final nextStepActive = steps[stepIndex + 1].isActive;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: nextStepActive
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.grey[200],
                  ),
                );
              } else {
                final step = steps[index ~/ 2];
                final color = step.isActive
                    ? (step.activeColor ?? AppColors.primary)
                    : Colors.grey[300]!;
                final bg = step.isActive
                    ? (step.activeColor?.withValues(alpha: 0.08) ?? AppColors.primary.withValues(alpha: 0.08))
                    : Colors.grey[50]!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: Responsive.w(36),
                      height: Responsive.w(36),
                      decoration: BoxDecoration(
                        color: bg,
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 1.5),
                      ),
                      child: Center(
                        child: Icon(
                          step.icon,
                          size: Responsive.icon(16),
                          color: color,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(6)),
                    SizedBox(
                      width: Responsive.w(60),
                      child: Text(
                        step.label,
                        style: TextStyle(
                          fontSize: Responsive.sp(9),
                          fontWeight: FontWeight.bold,
                          color: step.isActive ? AppColors.text : Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      step.stepNumber,
                      style: TextStyle(
                        fontSize: Responsive.sp(8),
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                );
              }
            }),
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
      padding: Responsive.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1.5),
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: Responsive.icon(AppSizes.iconSmall)),
              SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
              Expanded(
                child: Text(
                  'URGENT: Stock Conflict Detected',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                  ),
                ),
              ),
            ],
          ),
          if (conflicts.isNotEmpty) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            ...conflicts.map((c) {
              final name = c['productName'] ?? 'Unknown Product';
              final short = c['shortfall'] ?? 0;
              return Padding(
                padding: Responsive.symmetric(vertical: 2),
                child: Text(
                  '• $name: Shortfall of $short pc(s)',
                  style: TextStyle(
                    color: AppColors.error.withValues(alpha: 0.9),
                    fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                  ),
                ),
              );
            }),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Shortfall of product units for this booking detected.',
                style: TextStyle(color: AppColors.error, fontSize: Responsive.sp(AppSizes.fontTiny + 1)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogisticsQuickStats() {
    final isLate = _currentOrder.isLate;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        border: Border.all(color: AppColors.border, width: AppSizes.spacingTiny / 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: Responsive.r(AppSizes.radiusSmall),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: Responsive.all(AppSizes.spacingMedium),
      child: Row(
        children: [
          Expanded(
            child: _buildLogisticsGridItem(
              title: 'PICKUP DATE',
              value: _formatDate(_currentOrder.startDate),
              icon: Icons.login_rounded,
              iconColor: AppColors.primary,
            ),
          ),
          Container(
            height: Responsive.h(AppSizes.spacingLarge + AppSizes.spacingSmall),
            width: 1,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildLogisticsGridItem(
              title: 'RETURN DATE',
              value: _formatDate(_currentOrder.endDate),
              icon: Icons.logout_rounded,
              iconColor: isLate ? AppColors.error : AppColors.secondaryText,
              valueColor: isLate ? AppColors.error : AppColors.text,
              isLate: isLate,
            ),
          ),
          Container(
            height: Responsive.h(AppSizes.spacingLarge + AppSizes.spacingSmall),
            width: 1,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildLogisticsGridItem(
              title: 'TOTAL ITEMS',
              value: '${_currentOrder.items?.fold(0, (sum, i) => sum + i.quantity) ?? 0} pcs',
              icon: Icons.shopping_bag_outlined,
              iconColor: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsGridItem({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    Color? valueColor,
    bool isLate = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: Responsive.icon(AppSizes.iconTiny), color: iconColor),
            SizedBox(width: Responsive.w(4)),
            Text(
              title,
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontTiny),
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontSmall),
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.text,
          ),
        ),
        if (isLate) ...[
          SizedBox(height: Responsive.h(2)),
          Container(
            padding: Responsive.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'LATE',
              style: TextStyle(
                fontSize: Responsive.sp(8),
                fontWeight: FontWeight.w800,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }


  Widget _buildCustomerCard() {
    final customer = _currentOrder.customer;
    if (customer == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        border: Border.all(color: AppColors.border, width: AppSizes.spacingTiny / 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: Responsive.r(AppSizes.radiusSmall),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: Responsive.all(AppSizes.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CUSTOMER',
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontTiny),
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
          Text(
            customer.name,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontXLarge + 1),
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          
          // Primary Call Button (Green pill styled button like web)
          InkWell(
            onTap: () async {
              final uri = Uri.parse('tel:${customer.phone}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
            child: Container(
              width: double.infinity,
              padding: Responsive.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.2), width: 1.5),
                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_rounded,
                    size: Responsive.icon(AppSizes.iconSmall),
                    color: AppColors.success,
                  ),
                  SizedBox(width: Responsive.w(8)),
                  Text(
                    customer.phone,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                      fontWeight: FontWeight.w900,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Alt Phone call button if present
          if (customer.altPhone != null && customer.altPhone!.isNotEmpty) ...[
            SizedBox(height: Responsive.h(8)),
            InkWell(
              onTap: () async {
                final uri = Uri.parse('tel:${customer.altPhone}');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
              child: Container(
                width: double.infinity,
                padding: Responsive.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  border: Border.all(color: AppColors.border, width: 1),
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_rounded,
                      size: Responsive.icon(16),
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(width: Responsive.w(8)),
                    Text(
                      '${customer.altPhone} (Alt)',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Email & Branch if present
          if (customer.email != null && customer.email!.isNotEmpty) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: Responsive.icon(16),
                  color: AppColors.secondaryText,
                ),
                SizedBox(width: Responsive.w(8)),
                Expanded(
                  child: Text(
                    customer.email!,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontSmall),
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (_currentOrder.branch != null) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: Responsive.icon(16),
                  color: AppColors.secondaryText,
                ),
                SizedBox(width: Responsive.w(8)),
                Expanded(
                  child: Text(
                    'Branch: ${_currentOrder.branch!.name}',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontSmall),
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Delivery Address (Styled Pin Section)
          if (_currentOrder.deliveryAddress != null && _currentOrder.deliveryAddress!.isNotEmpty) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            const Divider(color: AppColors.border, height: 1),
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            Text(
              'DELIVERY ADDRESS',
              style: TextStyle(
                fontSize: Responsive.sp(9),
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingTiny + 2)),
            Container(
              width: double.infinity,
              padding: Responsive.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                border: Border.all(color: AppColors.border, width: 0.5),
                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: Responsive.icon(18),
                    color: AppColors.secondaryText,
                  ),
                  SizedBox(width: Responsive.w(8)),
                  Expanded(
                    child: Text(
                      _currentOrder.deliveryAddress!,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        color: AppColors.text,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Pickup Address (if present)
          if (_currentOrder.pickupAddress != null && _currentOrder.pickupAddress!.isNotEmpty) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            const Divider(color: AppColors.border, height: 1),
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            Text(
              'PICKUP ADDRESS',
              style: TextStyle(
                fontSize: Responsive.sp(9),
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingTiny + 2)),
            Container(
              width: double.infinity,
              padding: Responsive.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                border: Border.all(color: AppColors.border, width: 0.5),
                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.store_mall_directory_outlined,
                    size: Responsive.icon(18),
                    color: AppColors.secondaryText,
                  ),
                  SizedBox(width: Responsive.w(8)),
                  Expanded(
                    child: Text(
                      _currentOrder.pickupAddress!,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        color: AppColors.text,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Customer Address (Styled Pin Section)
          if (customer.address != null && customer.address!.isNotEmpty) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            const Divider(color: AppColors.border, height: 1),
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            Text(
              'CUSTOMER ADDRESS',
              style: TextStyle(
                fontSize: Responsive.sp(9),
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingTiny + 2)),
            Container(
              width: double.infinity,
              padding: Responsive.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                border: Border.all(color: AppColors.border, width: 0.5),
                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: Responsive.icon(18),
                    color: AppColors.secondaryText,
                  ),
                  SizedBox(width: Responsive.w(8)),
                  Expanded(
                    child: Text(
                      customer.address!,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        color: AppColors.text,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Order Notes (if present, amber box matching web)
          if (_currentOrder.notes != null && _currentOrder.notes!.isNotEmpty) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            const Divider(color: AppColors.border, height: 1),
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            Text(
              'ORDER NOTES',
              style: TextStyle(
                fontSize: Responsive.sp(9),
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingTiny + 2)),
            Container(
              width: double.infinity,
              padding: Responsive.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.05),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.15), width: 1),
                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: Responsive.icon(18),
                    color: AppColors.warning,
                  ),
                  SizedBox(width: Responsive.w(8)),
                  Expanded(
                    child: Text(
                      '"${_currentOrder.notes!}"',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        color: AppColors.text,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildItemsCard() {
    final items = _currentOrder.items ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        border: Border.all(color: AppColors.border, width: AppSizes.spacingTiny / 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: Responsive.r(AppSizes.radiusSmall),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: Responsive.all(AppSizes.spacingMedium),
            child: Row(
              children: [
                Container(
                  padding: Responsive.all(AppSizes.spacingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: Responsive.icon(AppSizes.iconSmall),
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: Responsive.w(AppSizes.spacingSmall + 2)),
                Text(
                  'Order Items (${items.length})',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontMedium),
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final item = items[index];
              final isReturnable = _currentOrder.status == OrderStatus.ongoing ||
                  _currentOrder.status == OrderStatus.inUse ||
                  _currentOrder.status == OrderStatus.delivered ||
                  _currentOrder.status == OrderStatus.partial;

              return Padding(
                padding: Responsive.all(AppSizes.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: Responsive.w(56),
                          height: Responsive.w(56),
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBackground,
                            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                            border: Border.all(color: AppColors.border, width: 0.5),
                          ),
                          child: item.product?.primaryImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                                  child: Image.network(
                                    item.product!.primaryImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.image_not_supported_outlined, color: Colors.grey[400]),
                                  ),
                                )
                              : Icon(Icons.image_not_supported_outlined, color: Colors.grey[400]),
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product?.name ?? 'Product #${item.productId.substring(0, 8)}',
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontSmall),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: Responsive.h(4)),
                              Wrap(
                                spacing: Responsive.w(AppSizes.spacingSmall),
                                runSpacing: Responsive.h(4),
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: Responsive.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'x${item.quantity}',
                                      style: TextStyle(
                                        fontSize: Responsive.sp(AppSizes.fontTiny),
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹${item.pricePerDay.toStringAsFixed(0)}/day',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  if (item.discount > 0)
                                    Container(
                                      padding: Responsive.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.discountType == 'percent'
                                            ? '-${item.discount.toStringAsFixed(0)}% Off'
                                            : '-₹${item.discount.toStringAsFixed(0)} Flat Off',
                                        style: TextStyle(
                                          fontSize: Responsive.sp(AppSizes.fontTiny),
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                  if (item.gstPercentage > 0)
                                    Container(
                                      padding: Responsive.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.info.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${item.gstPercentage.toStringAsFixed(0)}% GST Incl.',
                                        style: TextStyle(
                                          fontSize: Responsive.sp(AppSizes.fontTiny),
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.info,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (item.gstAmount > 0 || item.discount > 0)
                                Padding(
                                  padding: Responsive.only(top: 4),
                                  child: Text(
                                    'Base: ₹${item.baseAmount.toStringAsFixed(2)} + GST: ₹${item.gstAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              if (item.isReturned == true)
                                Padding(
                                  padding: Responsive.only(top: AppSizes.spacingTiny),
                                  child: Container(
                                    padding: Responsive.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Returned: ${item.returnedQuantity ?? item.quantity} (${item.conditionRating?.name.toUpperCase() ?? 'GOOD'})',
                                      style: TextStyle(
                                        fontSize: Responsive.sp(9),
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              if (item.isReturned == true && item.conditionRating == ConditionRating.damaged) ...[
                                if (item.damageDescription != null && item.damageDescription!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'Damage Notes: ${item.damageDescription}',
                                      style: TextStyle(
                                        fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                                        color: AppColors.warning,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                if ((item.damageCharges ?? 0.0) > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      'Damage Fee: ₹${item.damageCharges?.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                                        color: AppColors.warning,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                        Text(
                          '₹${item.totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    if (isReturnable) _buildInteractiveItemControls(item),
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
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        border: Border.all(color: AppColors.border, width: AppSizes.spacingTiny / 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: Responsive.r(AppSizes.radiusSmall),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: Responsive.all(AppSizes.spacingMedium),
            child: Row(
              children: [
                Container(
                  padding: Responsive.all(AppSizes.spacingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.payment_rounded,
                    size: Responsive.icon(AppSizes.iconSmall),
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: Responsive.w(AppSizes.spacingSmall + 2)),
                Text(
                  'Transaction History',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontMedium),
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          paymentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading payments: $err', style: const TextStyle(color: AppColors.error)),
            ),
            data: (transactions) {
              if (transactions.isEmpty) {
                return Padding(
                  padding: Responsive.all(AppSizes.spacingMedium),
                  child: Text(
                    'No transactions recorded.',
                    style: TextStyle(color: AppColors.secondaryText, fontSize: Responsive.sp(AppSizes.fontSmall)),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final txTypeColor = _getTransactionTypeColor(tx.paymentType);
                  return Padding(
                    padding: Responsive.all(AppSizes.spacingMedium),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: Responsive.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: txTypeColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      tx.paymentType.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: Responsive.sp(AppSizes.fontTiny),
                                        fontWeight: FontWeight.w800,
                                        color: txTypeColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                                  Container(
                                    padding: Responsive.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.grey[300]!, width: 0.5),
                                    ),
                                    child: Text(
                                      tx.paymentMode.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: Responsive.sp(AppSizes.fontTiny),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Responsive.h(AppSizes.spacingTiny + 2)),
                              Text(
                                _formatDate(tx.paymentDate),
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              if (tx.notes != null && tx.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Notes: ${tx.notes}',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                                      color: AppColors.secondaryText,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              if (tx.createdByName != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    'Processed by: ${tx.createdByName}',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(AppSizes.fontTiny),
                                      color: AppColors.secondaryText.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${tx.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontSmall),
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                size: Responsive.icon(AppSizes.iconTiny),
                                color: AppColors.info,
                              ),
                              onPressed: () => _openEditTransactionDialog(tx),
                            ),
                          ],
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

  Widget _buildFinancialReceiptCard() {
    final balanceDue = _currentOrder.totalAmount - _currentOrder.amountPaid;
    final isPaid = balanceDue <= 0;
    final items = _currentOrder.items ?? [];

    final rawSubtotal = items.fold<double>(0.0, (sum, item) => sum + item.subtotal);
    final afterItemDiscountTotal = items.fold<double>(0.0, (sum, item) => sum + item.baseAmount + item.gstAmount);
    final itemDiscountsTotal = rawSubtotal - afterItemDiscountTotal;

    final totalBaseExclGst = items.fold<double>(0.0, (sum, item) => sum + item.baseAmount);
    final totalGst = items.fold<double>(0.0, (sum, item) => sum + item.gstAmount);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        border: Border.all(color: AppColors.border, width: AppSizes.spacingTiny / 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: Responsive.r(AppSizes.radiusSmall),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: Responsive.all(AppSizes.spacingMedium),
            child: Row(
              children: [
                Container(
                  padding: Responsive.all(AppSizes.spacingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: Responsive.icon(AppSizes.iconSmall),
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: Responsive.w(AppSizes.spacingSmall + 2)),
                Text(
                  'Financial Information',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontMedium),
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                if (_currentOrder.status != OrderStatus.completed && _currentOrder.status != OrderStatus.cancelled)
                  TextButton.icon(
                    onPressed: _openAdjustmentDialog,
                    icon: Icon(Icons.edit_outlined, size: Responsive.icon(14), color: AppColors.primary),
                    label: Text(
                      'Adjust',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: Responsive.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingTiny),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: Responsive.all(AppSizes.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReceiptRow('Subtotal', '₹${rawSubtotal.toStringAsFixed(2)}'),
                if (itemDiscountsTotal > 0) ...[
                  Padding(
                    padding: Responsive.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ITEM DISCOUNTS',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny),
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                        Text(
                          '-₹${itemDiscountsTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...items.map((item) {
                    final itemRaw = item.subtotal;
                    final itemAfter = item.baseAmount + item.gstAmount;
                    final itemDisc = itemRaw - itemAfter;
                    if (itemDisc <= 0) return const SizedBox.shrink();

                    return Padding(
                      padding: Responsive.only(left: AppSizes.spacingMedium, top: 2, bottom: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.product?.name ?? 'Product',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontTiny),
                                fontStyle: FontStyle.italic,
                                color: AppColors.secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '-₹${itemDisc.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontTiny),
                              fontStyle: FontStyle.italic,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                const Divider(height: 1, color: AppColors.border),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                _buildReceiptRow('Base Amount (excl. GST)', '₹${totalBaseExclGst.toStringAsFixed(2)}'),
                _buildReceiptRow('GST (included)', '₹${totalGst.toStringAsFixed(2)}', valueColor: AppColors.info),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                const Divider(height: 1, color: AppColors.border),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                if (_currentOrder.discount > 0)
                  _buildReceiptRow('Order Discount', '-₹${_currentOrder.discount.toStringAsFixed(2)}', isDiscount: true),
                if (_currentOrder.damageChargesTotal > 0)
                  _buildReceiptRow('Damage Charges', '₹${_currentOrder.damageChargesTotal.toStringAsFixed(2)}'),
                if (_currentOrder.lateFee > 0)
                  _buildReceiptRow('Late Fee', '₹${_currentOrder.lateFee.toStringAsFixed(2)}'),
                SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                _buildReceiptRow('Total Amount', '₹${_currentOrder.totalAmount.toStringAsFixed(2)}', isBold: true),
                _buildReceiptRow('Advance/Deposit', '₹${_currentOrder.advanceAmount.toStringAsFixed(2)}'),
                _buildReceiptRow('Amount Paid', '₹${_currentOrder.amountPaid.toStringAsFixed(2)}', valueColor: AppColors.success),
                SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                Container(
                  padding: Responsive.all(AppSizes.spacingMedium),
                  decoration: BoxDecoration(
                    color: isPaid ? AppColors.success.withValues(alpha: 0.08) : AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Balance Due',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontMedium),
                          fontWeight: FontWeight.bold,
                          color: isPaid ? AppColors.success : AppColors.error,
                        ),
                      ),
                      Text(
                        '₹${balanceDue.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontLarge),
                          fontWeight: FontWeight.bold,
                          color: isPaid ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, Color? valueColor, bool isDiscount = false}) {
    return Padding(
      padding: Responsive.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontSmall),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? AppColors.text : AppColors.secondaryText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontSmall),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? (isDiscount ? AppColors.success : AppColors.text),
            ),
          ),
        ],
      ),
    );
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
      builder: (dialogContext) {
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
              onPressed: () => Navigator.pop(dialogContext),
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
      builder: (dialogContext) {
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
              onPressed: () => Navigator.pop(dialogContext),
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
                Navigator.pop(dialogContext);
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Collect Payment',
                    style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold, color: AppColors.primary),
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
                    initialValue: paymentMode,
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
                  SizedBox(height: Responsive.h(24)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
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

                        if (amt > maxCollect) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Warning: Amount exceeds balance due of ₹${maxCollect.toStringAsFixed(0)}')),
                          );
                          return;
                        }

                        Navigator.pop(modalContext);
                        setState(() => _isLoading = true);
                        try {
                          await ref.read(orderOperationsProvider).collectPayment(
                                orderId: _currentOrder.id,
                                amount: amt,
                                paymentMode: paymentMode,
                              );
                          final newAmountPaid = _currentOrder.amountPaid + amt;
                          final newPaymentStatus = newAmountPaid >= _currentOrder.totalAmount ? 'paid' : 'partial';
                          await ref.read(orderOperationsProvider).updateOrder(_currentOrder.id, {
                            'amount_paid': newAmountPaid,
                            'payment_status': newPaymentStatus,
                          });
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
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Transaction Details',
                    style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Amount: ₹${tx.amount.toStringAsFixed(2)}  |  Type: ${tx.paymentType.toUpperCase()}',
                    style: TextStyle(fontSize: Responsive.sp(12), color: Colors.grey[600]),
                  ),
                  SizedBox(height: Responsive.h(16)),
                  DropdownButtonFormField<String>(
                    initialValue: paymentMode,
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        Navigator.pop(modalContext);
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
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
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
                context: modalContext,
                builder: (dialogContext) => QRScannerDialog(
                  onRawCodeScanned: (rawCode) async {
                    try {
                      final response = await ref.read(productRepositoryProvider)
                          .getProducts(search: rawCode, limit: 1);

                      if (response.products.isNotEmpty) {
                        final matchedProduct = response.products.first;
                        final matchedId = matchedProduct.id;
                        final matchedItem = items.firstWhere(
                          (item) => item.productId == matchedId,
                          orElse: () => throw Exception('Product not found in this order'),
                        );

                        setModalState(() {
                          final maxReturn = matchedItem.quantity - (matchedItem.returnedQuantity ?? 0);
                          returnQuantities[matchedItem.id] = maxReturn;
                          returnConditions[matchedItem.id] = ConditionRating.good;
                        });

                        if (modalContext.mounted) {
                          ScaffoldMessenger.of(modalContext).showSnackBar(
                            SnackBar(
                              content: Text('Item marked as GOOD: ${matchedItem.product?.name ?? "Product"}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        if (modalContext.mounted) {
                          ScaffoldMessenger.of(modalContext).showSnackBar(
                            const SnackBar(content: Text('No matching item in order for barcode/SKU')),
                          );
                        }
                      }
                    } catch (e) {
                      if (modalContext.mounted) {
                        ScaffoldMessenger.of(modalContext).showSnackBar(
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
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
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
                          style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        IconButton(
                          icon: Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: Responsive.icon(22)),
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
                          backgroundColor: AppColors.primary,
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

                          Navigator.pop(modalContext);
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
      return DateFormat('d MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

class _StepItem {
  final String label;
  final String stepNumber;
  final bool isActive;
  final IconData icon;
  final Color? activeColor;

  _StepItem({
    required this.label,
    required this.stepNumber,
    required this.isActive,
    required this.icon,
    this.activeColor,
  });
}
