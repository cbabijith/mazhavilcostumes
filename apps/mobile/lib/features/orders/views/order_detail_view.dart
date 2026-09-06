import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/api_client.dart';
import '../../../core/utils/responsive.dart';
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

class _OrderDetailViewState extends ConsumerState<OrderDetailView>
    with AutomaticKeepAliveClientMixin {
  late Order _currentOrder;
  bool _isLoading = false;
  bool _isLoadingDetails = false;

  final Map<String, Map<String, dynamic>> _localReturnItems = {};
  final Map<String, TextEditingController> _notesControllers = {};
  final Map<String, TextEditingController> _feeControllers = {};

  final GlobalKey _itemsCardKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _extraDiscountController = TextEditingController();
  final TextEditingController _returnNotesController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _initializeReturnItems();

    // Auto-open dialogs based on flags
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOrder(showLoading: false);
      if (widget.autoOpenReturn) {
        _scrollToItemsCard();
      } else if (widget.autoOpenPayment) {
        _openPaymentDialog();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _extraDiscountController.dispose();
    _returnNotesController.dispose();
    for (final ctrl in _notesControllers.values) {
      ctrl.dispose();
    }
    for (final ctrl in _feeControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _scrollToItemsCard() {
    if (_itemsCardKey.currentContext != null) {
      Scrollable.ensureVisible(
        _itemsCardKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _markAllGood() {
    setState(() {
      for (final item in _currentOrder.items ?? []) {
        _localReturnItems[item.id] = {
          'status': 'good',
          'damage_fee': 0.0,
          'damaged_quantity': 0,
          'notes': '',
        };
        if (_notesControllers.containsKey(item.id)) {
          _notesControllers[item.id]!.text = '';
        }
        if (_feeControllers.containsKey(item.id)) {
          _feeControllers[item.id]!.text = '0';
        }
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All items marked Good'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _initializeReturnItems() {
    _localReturnItems.clear();
    final items = _currentOrder.items ?? [];
    for (final item in items) {
      String? status;
      if (item.isReturned == true) {
        status = item.conditionRating == ConditionRating.damaged
            ? 'damaged'
            : 'good';
      }
      _localReturnItems[item.id] = {
        'status': status,
        'damage_fee': item.damageCharges ?? 0.0,
        'damaged_quantity': item.damagedQuantity ?? item.quantity,
        'notes': item.damageDescription ?? '',
      };
    }
  }

  TextEditingController _getNotesController(
    String itemId,
    String initialValue,
  ) {
    return _notesControllers.putIfAbsent(
      itemId,
      () => TextEditingController(text: initialValue),
    );
  }

  TextEditingController _getFeeController(String itemId, double initialValue) {
    return _feeControllers.putIfAbsent(
      itemId,
      () => TextEditingController(
        text: initialValue > 0 ? initialValue.toStringAsFixed(0) : '0',
      ),
    );
  }

  void _openAdjustmentDialog() {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.r(AppSizes.radiusXLarge)),
        ),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: Responsive.w(AppSizes.screenPaddingSmall),
                right: Responsive.w(AppSizes.screenPaddingSmall),
                top: Responsive.h(AppSizes.screenPaddingSmall),
                bottom: MediaQuery.of(modalContext).viewInsets.bottom +
                    MediaQuery.of(context).padding.bottom +
                    Responsive.h(AppSizes.spacingLarge),
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
                          'Apply Discount',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontLarge),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: Responsive.icon(AppSizes.iconMedium),
                          ),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                    Text(
                      'Directly deduct an amount from the order total. This directly updates the order balance.',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    Text(
                      'DISCOUNT AMOUNT (₹)',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[500],
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        fontSize: Responsive.sp(22),
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: Icon(
                          Icons.currency_rupee_rounded,
                          color: AppColors.primary,
                          size: Responsive.icon(AppSizes.iconMedium),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(
                            Responsive.r(AppSizes.radiusMedium),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            Responsive.r(AppSizes.radiusMedium),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    Text(
                      'REASON / NOTES (OPTIONAL)',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[500],
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                    TextField(
                      controller: notesController,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontMedium),
                      ),
                      decoration: InputDecoration(
                        hintText: 'E.g. Loyal customer discount',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(
                            Responsive.r(AppSizes.radiusSmall),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingXXLarge)),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: Responsive.symmetric(
                                vertical: AppSizes.spacingMedium,
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  Responsive.r(AppSizes.radiusSmall),
                                ),
                              ),
                            ),
                            onPressed: () => Navigator.pop(modalContext),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontMedium),
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: Responsive.symmetric(
                                vertical: AppSizes.spacingMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  Responsive.r(AppSizes.radiusSmall),
                                ),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final val =
                                  double.tryParse(amountController.text) ??
                                  0.0;
                              if (val <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a discount amount greater than 0',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final double updatedTotal =
                                  (_currentOrder.totalAmount - val).clamp(
                                    0.0,
                                    double.infinity,
                                  );
                              final double newDiscount =
                                  _currentOrder.discount + val;
                              final double newAmountPaid =
                                  _currentOrder.amountPaid;
                              final String newPaymentStatus =
                                  newAmountPaid >= updatedTotal
                                      ? 'paid'
                                      : newAmountPaid > 0
                                          ? 'partial'
                                          : 'pending';

                              Navigator.pop(modalContext);
                              setState(() => _isLoading = true);
                              try {
                                final noteReason =
                                    notesController.text.trim();
                                final noteUpdate = noteReason.isNotEmpty
                                    ? (_currentOrder.notes != null &&
                                            _currentOrder.notes!.isNotEmpty
                                        ? '${_currentOrder.notes} | Discount: $noteReason'
                                        : 'Discount: $noteReason')
                                    : null;

                                await ref
                                    .read(orderOperationsProvider)
                                    .updateOrder(_currentOrder.id, {
                                      'total_amount': updatedTotal,
                                      'discount': newDiscount,
                                      'payment_status': newPaymentStatus,
                                      'notes': ?noteUpdate,
                                    });

                                await _refreshOrder();
                                ref.invalidate(
                                  orderPaymentsProvider(_currentOrder.id),
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Discount of ₹${val.toStringAsFixed(2)} applied successfully.',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setState(() => _isLoading = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to apply discount: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              'Apply Discount',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontMedium),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildInteractiveItemControls(OrderItem item) {
    final state =
        _localReturnItems[item.id] ??
        {
          'status': null,
          'damage_fee': 0.0,
          'damaged_quantity': item.quantity,
          'notes': '',
        };

    final currentStatus = state['status'];
    final isGood = currentStatus == 'good';
    final isDamaged = currentStatus == 'damaged';

    final notesCtrl = _getNotesController(item.id, state['notes'] as String);
    final feeCtrl = _getFeeController(
      item.id,
      (state['damage_fee'] as num).toDouble(),
    );

    final dbStatus = item.isReturned == true
        ? (item.conditionRating == ConditionRating.damaged ? 'damaged' : 'good')
        : null;
    final double dbFee = item.damageCharges ?? 0.0;
    final int dbDamagedQty = item.conditionRating == ConditionRating.damaged
        ? (item.damagedQuantity ?? 0)
        : 0;
    final String dbNotes = item.damageDescription ?? '';

    final currentDamagedQty = isDamaged
        ? (state['damaged_quantity'] as int)
        : 0;
    final isDirty =
        currentStatus != dbStatus ||
        (state['damage_fee'] as double) != dbFee ||
        currentDamagedQty != dbDamagedQty ||
        (state['notes'] as String) != dbNotes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
        // Condition Segmented Buttons (Good / Damaged)
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
                  isGood
                      ? Icons.check_circle_rounded
                      : Icons.check_circle_outline_rounded,
                  size: Responsive.icon(AppSizes.iconTiny),
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
                    color: isGood
                        ? AppColors.success
                        : AppColors.success.withValues(alpha: 0.4),
                    width: AppSizes.spacingTiny / 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.r(AppSizes.radiusSmall),
                    ),
                  ),
                  padding: Responsive.symmetric(
                    vertical: AppSizes.spacingSmall,
                  ),
                ),
              ),
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _localReturnItems[item.id]!['status'] = 'damaged';
                    if ((_localReturnItems[item.id]!['damaged_quantity']
                            as int) ==
                        0) {
                      _localReturnItems[item.id]!['damaged_quantity'] =
                          item.quantity;
                    }
                  });
                },
                icon: Icon(
                  isDamaged
                      ? Icons.warning_rounded
                      : Icons.warning_amber_rounded,
                  size: Responsive.icon(AppSizes.iconTiny),
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
                    color: isDamaged
                        ? AppColors.warning
                        : AppColors.warning.withValues(alpha: 0.4),
                    width: AppSizes.spacingTiny / 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.r(AppSizes.radiusSmall),
                    ),
                  ),
                  padding: Responsive.symmetric(
                    vertical: AppSizes.spacingSmall,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (isDamaged) ...[
          SizedBox(height: Responsive.h(AppSizes.spacingSmall + 2)),
          Container(
            padding: Responsive.all(AppSizes.spacingMedium),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.05),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
                width: AppSizes.spacingTiny / 4,
              ),
              borderRadius: BorderRadius.circular(
                Responsive.r(AppSizes.radiusSmall),
              ),
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
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                TextField(
                  controller: notesCtrl,
                  style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall)),
                  decoration: InputDecoration(
                    hintText: 'Describe damage (e.g. Broken clasp, stain)',
                    hintStyle: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontSmall),
                      color: AppColors.secondaryText,
                    ),
                    isDense: true,
                    contentPadding: Responsive.symmetric(
                      vertical: AppSizes.spacingSmall,
                      horizontal: AppSizes.spacingSmall,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.r(AppSizes.radiusSmall / 2),
                      ),
                      borderSide: BorderSide(
                        color: AppColors.border,
                        width: AppSizes.spacingTiny / 4,
                      ),
                    ),
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
                            'Damaged Qty (of ${item.quantity})',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontTiny),
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                          Container(
                            padding: Responsive.symmetric(
                              horizontal: AppSizes.spacingSmall,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.border,
                                width: AppSizes.spacingTiny / 4,
                              ),
                              borderRadius: BorderRadius.circular(
                                Responsive.r(AppSizes.radiusSmall / 2),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: state['damaged_quantity'] as int,
                                isExpanded: true,
                                items:
                                    List.generate(item.quantity, (i) => i + 1)
                                        .map(
                                          (i) => DropdownMenuItem(
                                            value: i,
                                            child: Text(
                                              '$i',
                                              style: TextStyle(
                                                fontSize: Responsive.sp(
                                                  AppSizes.fontSmall,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _localReturnItems[item
                                              .id]!['damaged_quantity'] =
                                          val;
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
                          SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                          TextField(
                            controller: feeCtrl,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontSmall),
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: Responsive.symmetric(
                                vertical: AppSizes.spacingSmall,
                                horizontal: AppSizes.spacingSmall,
                              ),
                              prefixText: '₹ ',
                              prefixStyle: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontSmall),
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryText,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  Responsive.r(AppSizes.radiusSmall / 2),
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.border,
                                  width: AppSizes.spacingTiny / 4,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              _localReturnItems[item.id]!['damage_fee'] =
                                  double.tryParse(val) ?? 0.0;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Auto-marked Good banner
                if (currentDamagedQty > 0 && currentDamagedQty < item.quantity) ...[
                  SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                  Container(
                    padding: Responsive.symmetric(
                      horizontal: AppSizes.spacingSmall,
                      vertical: AppSizes.spacingTiny,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                        Responsive.r(AppSizes.radiusSmall / 2),
                      ),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.25),
                        width: AppSizes.spacingTiny / 4,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: Responsive.icon(AppSizes.iconTiny - 2),
                          color: AppColors.success,
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                        Expanded(
                          child: Text(
                            '${item.quantity - currentDamagedQty} of ${item.quantity} units auto-marked Good',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontTiny),
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                SizedBox(
                  width: double.infinity,
                  child: isDirty
                      ? ElevatedButton.icon(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            try {
                              await ref
                                  .read(orderOperationsProvider)
                                  .updateOrderItemDamage(
                                    itemId: item.id,
                                    conditionRating: 'damaged',
                                    damageDescription: state['notes'] as String,
                                    damageCharges:
                                        (state['damage_fee'] as num).toDouble(),
                                    damagedQuantity:
                                        state['damaged_quantity'] as int,
                                  );
                              await _refreshOrder();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Item damage details saved successfully.',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() => _isLoading = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to save item damage: $e',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                          icon: Icon(
                            Icons.save_rounded,
                            size: Responsive.icon(AppSizes.iconTiny),
                          ),
                          label: const Text('Save Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: Responsive.symmetric(
                              vertical: AppSizes.spacingSmall,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Responsive.r(AppSizes.radiusSmall),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          padding: Responsive.symmetric(
                            vertical: AppSizes.spacingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
                              width: AppSizes.spacingTiny / 4,
                            ),
                            borderRadius: BorderRadius.circular(
                              Responsive.r(AppSizes.radiusSmall),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.warning,
                                size: Responsive.icon(AppSizes.iconTiny),
                              ),
                              SizedBox(
                                width: Responsive.w(AppSizes.spacingSmall),
                              ),
                              Text(
                                'Saved',
                                style: TextStyle(
                                  color: AppColors.warning,
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
                        await ref
                            .read(orderOperationsProvider)
                            .updateOrderItemDamage(
                              itemId: item.id,
                              conditionRating: 'excellent',
                              damageDescription: null,
                              damageCharges: 0.0,
                              damagedQuantity: 0,
                            );
                        await _refreshOrder();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item condition set to GOOD.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => _isLoading = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update condition: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    icon: Icon(
                      Icons.save_rounded,
                      size: Responsive.icon(AppSizes.iconTiny),
                    ),
                    label: const Text('Save Condition'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: Responsive.symmetric(
                        vertical: AppSizes.spacingSmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                      ),
                    ),
                  )
                : Container(
                    padding: Responsive.symmetric(
                      vertical: AppSizes.spacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                        width: AppSizes.spacingTiny / 4,
                      ),
                      borderRadius: BorderRadius.circular(
                        Responsive.r(AppSizes.radiusSmall),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: Responsive.icon(AppSizes.iconTiny),
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
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

  Future<void> _refreshOrder({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isLoadingDetails = true);
    }
    try {
      final updated = await ref
          .read(orderRepositoryProvider)
          .getOrderById(_currentOrder.id);
      ref.invalidate(orderPaymentsProvider(_currentOrder.id));
      if (mounted) {
        setState(() {
          _currentOrder = updated;
          _initializeReturnItems();
          _isLoading = false;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingDetails = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to refresh order: $e')));
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
              icon: Icon(
                Icons.edit_outlined,
                size: Responsive.icon(AppSizes.iconMedium),
                color: AppColors.primary,
              ),
              onPressed: () => Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => OrderFormView(order: _currentOrder),
                    ),
                  )
                  .then((_) {
                    // Selective invalidation - only invalidate list, keep detail cache
                    ref.invalidate(ordersProvider);
                    _refreshOrder();
                  }),
            ),
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              size: Responsive.icon(AppSizes.iconMedium),
              color: AppColors.primary,
            ),
            onPressed: _showShareBottomSheet,
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              size: Responsive.icon(AppSizes.iconMedium),
              color: AppColors.primary,
            ),
            onPressed: _refreshOrder,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: Responsive.icon(AppSizes.iconMedium),
              color: AppColors.error,
            ),
            onPressed: _deleteOrder,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              padding: Responsive.all(AppSizes.screenPaddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  _buildStatusStepper(),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  _buildUrgentAlertBanner(),
                  if (_currentOrder.hasStockConflict &&
                      _currentOrder.status != OrderStatus.completed &&
                      _currentOrder.status != OrderStatus.cancelled)
                    SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  _buildLogisticsQuickStats(),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  _buildCustomerCard(),

                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  _buildItemsCard(),
                  if (!(_currentOrder.status == OrderStatus.ongoing ||
                          _currentOrder.status == OrderStatus.inUse ||
                          _currentOrder.status == OrderStatus.delivered ||
                          _currentOrder.status == OrderStatus.partial ||
                          _currentOrder.status == OrderStatus.flagged) &&
                      (_currentOrder.status == OrderStatus.flagged ||
                          _currentOrder.damageChargesTotal > 0 ||
                          _currentOrder.lateFee > 0)) ...[
                    SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                    _buildProjectedSettlementCard(
                      onCollectPayment: _openPaymentDialog,
                    ),
                  ],
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
    final statusText = _currentOrder.isLate
        ? 'OVERDUE'
        : _formatStatusName(_currentOrder.status);
    final isPaid = balanceDue <= 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          Responsive.r(AppSizes.radiusMedium),
        ),
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
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
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
                  color: isPaid
                      ? AppColors.success.withValues(alpha: 0.25)
                      : AppColors.error.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                  border: Border.all(
                    color: isPaid
                        ? AppColors.success.withValues(alpha: 0.4)
                        : AppColors.error.withValues(alpha: 0.5),
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
                      isPaid
                          ? '₹${_currentOrder.amountPaid.toStringAsFixed(2)}'
                          : '₹${balanceDue.toStringAsFixed(2)}',
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
    final rentalEndMidnight = rentalEnd != null
        ? DateTime(rentalEnd.year, rentalEnd.month, rentalEnd.day)
        : null;

    final createdAt = DateTime.tryParse(_currentOrder.createdAt);
    final createdAtMidnight = createdAt != null
        ? DateTime(createdAt.year, createdAt.month, createdAt.day)
        : null;

    final rentalStart = DateTime.tryParse(_currentOrder.startDate);
    final rentalStartMidnight = rentalStart != null
        ? DateTime(rentalStart.year, rentalStart.month, rentalStart.day)
        : null;

    final isBackdated =
        rentalStartMidnight != null &&
        createdAtMidnight != null &&
        rentalStartMidnight.isBefore(createdAtMidnight);
    final isExpired =
        !isBackdated &&
        rentalEndMidnight != null &&
        todayMidnight.isAfter(rentalEndMidnight);
    final isEarlyStart =
        rentalStartMidnight != null && todayMidnight.isBefore(rentalStartMidnight);

    if ((_currentOrder.status == OrderStatus.confirmed ||
            _currentOrder.status == OrderStatus.scheduled ||
            _currentOrder.status == OrderStatus.pending) &&
        isExpired) {
      return Padding(
        padding: Responsive.only(top: AppSizes.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: Responsive.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: Responsive.icon(AppSizes.iconSmall + 2),
                  ),
                  SizedBox(width: Responsive.w(8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rental Period Expired',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                          ),
                        ),
                        SizedBox(height: Responsive.h(4)),
                        Text(
                          'The scheduled return date for this order has already passed. You can record it as returned if the costume was given offline, or cancel it.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: Responsive.symmetric(
                        vertical: AppSizes.spacingSmall + 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                      ),
                    ),
                    onPressed: _openBackfillReturnDialog,
                    icon: Icon(
                      Icons.check_circle_outline_rounded,
                      size: Responsive.icon(AppSizes.iconSmall),
                    ),
                    label: Text(
                      'Record Returned',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openCancelDialog,
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                      size: Responsive.icon(AppSizes.iconSmall),
                    ),
                    label: Text(
                      'Cancel Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      padding: Responsive.symmetric(
                        vertical: AppSizes.spacingSmall + 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final status = _currentOrder.status;
    final isFinalized =
        status == OrderStatus.completed ||
        status == OrderStatus.cancelled ||
        status == OrderStatus.returned;
    if (isFinalized) return const SizedBox.shrink();

    final bool showStartRental =
        status == OrderStatus.confirmed || status == OrderStatus.scheduled;
    final bool showProcessReturn =
        status == OrderStatus.ongoing ||
        status == OrderStatus.delivered ||
        status == OrderStatus.inUse ||
        status == OrderStatus.partial ||
        status == OrderStatus.flagged;
    final bool showCollectPayment =
        _currentOrder.paymentStatus != PaymentStatus.paid;
    final bool showCancel =
        status != OrderStatus.cancelled && status != OrderStatus.completed;

    Widget buildStartRentalButton({required bool isExpanded}) {
      final hasConflict = _currentOrder.hasStockConflict;
      final btn = ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: hasConflict ? Colors.red.shade100 : Colors.white,
          foregroundColor: hasConflict ? AppColors.error : AppColors.primary,
          elevation: 0,
          padding: Responsive.symmetric(vertical: AppSizes.spacingMedium - 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Responsive.r(AppSizes.radiusSmall),
            ),
          ),
        ),
        onPressed: () {
          if (hasConflict) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Inventory Fulfillment Conflict: Resolve stock issues before starting rental.',
                ),
              ),
            );
            return;
          }
          _startRentalWithCheck();
        },
        icon: Icon(
          hasConflict ? Icons.warning_amber_rounded : Icons.play_arrow_rounded,
          size: Responsive.icon(AppSizes.iconSmall),
        ),
        label: Text(
          hasConflict ? 'Stock Conflict' : AppStrings.startRental,
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontSmall),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      return isExpanded ? Expanded(child: btn) : btn;
    }

    Widget buildProcessReturnButton({required bool isExpanded}) {
      final btn = ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warning,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: Responsive.symmetric(vertical: AppSizes.spacingMedium - 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Responsive.r(AppSizes.radiusSmall),
            ),
          ),
        ),
        onPressed: _scrollToItemsCard,
        icon: Icon(
          Icons.assignment_turned_in_rounded,
          size: Responsive.icon(AppSizes.iconSmall),
        ),
        label: Text(
          'Process Return',
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontSmall),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      return isExpanded ? Expanded(child: btn) : btn;
    }

    Widget buildCollectPaymentButton({required bool isExpanded}) {
      final btn = OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 1.5),
          foregroundColor: Colors.white,
          padding: Responsive.symmetric(vertical: AppSizes.spacingMedium - 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Responsive.r(AppSizes.radiusSmall),
            ),
          ),
        ),
        onPressed: _openPaymentDialog,
        icon: Icon(
          Icons.payment_rounded,
          size: Responsive.icon(AppSizes.iconSmall),
        ),
        label: Text(
          'Collect Payment',
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontSmall),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      return isExpanded ? Expanded(child: btn) : btn;
    }

    Widget buildCancelButton({required bool isExpanded}) {
      final btn = OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.0,
          ),
          foregroundColor: Colors.red[100],
          padding: Responsive.symmetric(vertical: AppSizes.spacingMedium - 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Responsive.r(AppSizes.radiusSmall),
            ),
          ),
        ),
        onPressed: _openCancelDialog,
        icon: Icon(
          Icons.cancel_outlined,
          size: Responsive.icon(AppSizes.iconSmall),
          color: Colors.red[100],
        ),
        label: Text(
          'Cancel',
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontSmall),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      return isExpanded ? Expanded(child: btn) : btn;
    }

    // Determine layout based on counts
    final activeActions = <String>[];
    if (showStartRental) activeActions.add('start');
    if (showProcessReturn) activeActions.add('return');
    if (showCollectPayment) activeActions.add('payment');
    if (showCancel) activeActions.add('cancel');

    final hasPendingReturns = _currentOrder.items?.any((i) => (i.returnedQuantity ?? 0) < i.quantity) ?? false;
    final showPartialReturnBanner = (_currentOrder.status == OrderStatus.partial || (_currentOrder.status == OrderStatus.flagged && hasPendingReturns));

    if (activeActions.isEmpty && !showPartialReturnBanner) return const SizedBox.shrink();

    return Padding(
      padding: Responsive.only(top: AppSizes.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showPartialReturnBanner) ...[
            Container(
              width: double.infinity,
              margin: Responsive.only(bottom: AppSizes.spacingSmall),
              padding: Responsive.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: Colors.amber.shade50.withValues(alpha: 0.9),
                border: Border.all(color: Colors.amber.shade300),
                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.amber.shade900,
                    size: Responsive.icon(AppSizes.iconMedium),
                  ),
                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Partial Return Pending',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                        Text(
                          'Some items are still with the customer. Tap "Process Return" when remaining items arrive.',
                          style: TextStyle(
                            color: Colors.amber.shade800,
                            fontSize: Responsive.sp(AppSizes.fontTiny),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (activeActions.isNotEmpty)
            Builder(
              builder: (context) {
                if (activeActions.length == 3) {
                  // Stack primary action on top, secondary actions side by side below
                  final primaryType = showStartRental ? 'start' : 'return';
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: primaryType == 'start'
                            ? buildStartRentalButton(isExpanded: false)
                            : buildProcessReturnButton(isExpanded: false),
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                      Row(
                        children: [
                          buildCancelButton(isExpanded: true),
                          SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                          buildCollectPaymentButton(isExpanded: true),
                        ],
                      ),
                    ],
                  );
                } else if (activeActions.length == 2) {
                  // Show side by side
                  final List<Widget> rowChildren = [];
                  if (showCancel) {
                    rowChildren.add(buildCancelButton(isExpanded: true));
                  }
                  if (showCollectPayment) {
                    if (rowChildren.isNotEmpty) {
                      rowChildren.add(
                        SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                      );
                    }
                    rowChildren.add(buildCollectPaymentButton(isExpanded: true));
                  }
                  if (showStartRental) {
                    if (rowChildren.isNotEmpty) {
                      rowChildren.add(
                        SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                      );
                    }
                    rowChildren.add(buildStartRentalButton(isExpanded: true));
                  }
                  if (showProcessReturn) {
                    if (rowChildren.isNotEmpty) {
                      rowChildren.add(
                        SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                      );
                    }
                    rowChildren.add(buildProcessReturnButton(isExpanded: true));
                  }
                  return Row(children: rowChildren);
                } else {
                  // Single action - full width
                  return SizedBox(
                    width: double.infinity,
                    child: showStartRental
                        ? buildStartRentalButton(isExpanded: false)
                        : showProcessReturn
                        ? buildProcessReturnButton(isExpanded: false)
                        : showCollectPayment
                        ? buildCollectPaymentButton(isExpanded: false)
                        : buildCancelButton(isExpanded: false),
                  );
                }
              },
            ),
          if (showStartRental && isEarlyStart && rentalStart != null) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Container(
              padding: Responsive.symmetric(
                horizontal: AppSizes.spacingMedium,
                vertical: AppSizes.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: AppSizes.spacingTiny / 4,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_outlined,
                    color: Colors.white,
                    size: Responsive.icon(AppSizes.iconSmall - 2),
                  ),
                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                  Text(
                    'Pickup: ${DateFormat('dd MMM, yyyy').format(rentalStart)}',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
        borderRadius: BorderRadius.circular(
          Responsive.r(AppSizes.radiusMedium),
        ),
        border: Border.all(
          color: AppColors.border,
          width: AppSizes.spacingTiny / 4,
        ),
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
                    ? (step.activeColor?.withValues(alpha: 0.08) ??
                          AppColors.primary.withValues(alpha: 0.08))
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
                          color: step.isActive
                              ? AppColors.text
                              : Colors.grey[400],
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
    if (!_currentOrder.hasStockConflict ||
        _currentOrder.status == OrderStatus.completed ||
        _currentOrder.status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    final conflicts = _currentOrder.conflictDetails ?? [];

    return Container(
      width: double.infinity,
      padding: Responsive.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: AppSizes.spacingTiny / 4,
        ),
        borderRadius: BorderRadius.circular(
          Responsive.r(AppSizes.radiusMedium),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: Responsive.all(AppSizes.spacingSmall),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: Responsive.icon(AppSizes.iconMedium),
                ),
              ),
              SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INVENTORY FULFILLMENT CONFLICT DETECTED',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        fontWeight: FontWeight.w900,
                        color: AppColors.error,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                    Text(
                      'Total inventory for one or more items in this order has dropped below required levels due to damage or write-offs. This order is currently at risk of incomplete fulfillment.',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall - 1),
                        color: AppColors.error.withValues(alpha: 0.85),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (conflicts.isNotEmpty) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            Wrap(
              spacing: Responsive.w(AppSizes.spacingSmall),
              runSpacing: Responsive.h(AppSizes.spacingSmall),
              children: conflicts.map<Widget>((conflict) {
                final String name = (conflict is Map)
                    ? (conflict['productName'] ?? conflict['product_name'] ?? 'Item').toString()
                    : 'Item';
                final int shortfall = (conflict is Map)
                    ? (int.tryParse(conflict['shortfall']?.toString() ?? '1') ?? 1)
                    : 1;

                return Container(
                  padding: Responsive.symmetric(
                    horizontal: AppSizes.spacingSmall + 2,
                    vertical: AppSizes.spacingTiny + 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.25),
                      width: AppSizes.spacingTiny / 4,
                    ),
                    borderRadius: BorderRadius.circular(
                      Responsive.r(AppSizes.radiusSmall),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: Responsive.symmetric(
                          horizontal: AppSizes.spacingTiny + 2,
                          vertical: AppSizes.spacingTiny / 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            Responsive.r(AppSizes.spacingTiny),
                          ),
                        ),
                        child: Text(
                          'CONFLICT',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny - 1),
                            fontWeight: FontWeight.w900,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.w(AppSizes.spacingTiny + 2)),
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        margin: Responsive.symmetric(
                          horizontal: AppSizes.spacingTiny + 2,
                        ),
                        width: 1,
                        height: Responsive.h(12),
                        color: AppColors.error.withValues(alpha: 0.25),
                      ),
                      Text(
                        'Shortfall: $shortfall unit${shortfall > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontTiny),
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.4),
                  width: AppSizes.spacingTiny / 4,
                ),
                foregroundColor: AppColors.error,
                padding: Responsive.symmetric(
                  horizontal: AppSizes.spacingMedium,
                  vertical: AppSizes.spacingSmall,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderFormView(order: _currentOrder),
                  ),
                ).then((_) {
                  ref.invalidate(ordersProvider);
                  _refreshOrder();
                });
              },
              icon: Icon(
                Icons.edit_outlined,
                size: Responsive.icon(AppSizes.iconSmall - 2),
              ),
              label: Text(
                'MODIFY ORDER',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
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
        borderRadius: BorderRadius.circular(
          Responsive.r(AppSizes.radiusMedium),
        ),
        border: Border.all(
          color: AppColors.border,
          width: AppSizes.spacingTiny / 4,
        ),
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
              value:
                  '${_currentOrder.items?.fold(0, (sum, i) => sum + i.quantity) ?? 0} pcs',
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
            Icon(
              icon,
              size: Responsive.icon(AppSizes.iconTiny),
              color: iconColor,
            ),
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
        borderRadius: BorderRadius.circular(
          Responsive.r(AppSizes.radiusMedium),
        ),
        border: Border.all(
          color: AppColors.border,
          width: AppSizes.spacingTiny / 4,
        ),
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
            borderRadius: BorderRadius.circular(
              Responsive.r(AppSizes.radiusSmall),
            ),
            child: Container(
              width: double.infinity,
              padding: Responsive.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
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
              borderRadius: BorderRadius.circular(
                Responsive.r(AppSizes.radiusSmall),
              ),
              child: Container(
                width: double.infinity,
                padding: Responsive.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  border: Border.all(color: AppColors.border, width: 1),
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
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
          if (_currentOrder.deliveryAddress != null &&
              _currentOrder.deliveryAddress!.isNotEmpty) ...[
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
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
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
          if (_currentOrder.pickupAddress != null &&
              _currentOrder.pickupAddress!.isNotEmpty) ...[
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
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
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
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
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
          if (_currentOrder.notes != null &&
              _currentOrder.notes!.isNotEmpty) ...[
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
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
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
    final bool isReturnable =
        _currentOrder.status == OrderStatus.ongoing ||
        _currentOrder.status == OrderStatus.inUse ||
        _currentOrder.status == OrderStatus.delivered ||
        _currentOrder.status == OrderStatus.partial ||
        _currentOrder.status == OrderStatus.flagged;

    return Container(
      key: _itemsCardKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          Responsive.r(AppSizes.radiusMedium),
        ),
        border: Border.all(
          color: AppColors.border,
          width: AppSizes.spacingTiny / 4,
        ),
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
                if (isReturnable) ...[
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _markAllGood,
                    icon: Icon(
                      Icons.check_circle_rounded,
                      size: Responsive.icon(AppSizes.iconTiny),
                      color: AppColors.success,
                    ),
                    label: Text(
                      'Mark All Good',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: BorderSide(
                        color: AppColors.success.withValues(alpha: 0.4),
                        width: AppSizes.spacingTiny / 4,
                      ),
                      padding: Responsive.symmetric(
                        horizontal: AppSizes.spacingSmall,
                        vertical: AppSizes.spacingTiny,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          if (_isLoadingDetails && items.isEmpty)
            Padding(
              padding: Responsive.all(AppSizes.spacingMedium),
              child: Shimmer.fromColors(
                baseColor: AppColors.shimmerBase,
                highlightColor: AppColors.shimmerHighlight,
                child: Column(
                  children: List.generate(
                    2,
                    (index) => Padding(
                      padding: Responsive.only(
                        bottom: index == 1 ? 0.0 : AppSizes.spacingMedium,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: Responsive.w(AppSizes.iconHuge),
                            height: Responsive.w(AppSizes.iconHuge),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(
                                Responsive.r(AppSizes.radiusSmall),
                              ),
                            ),
                          ),
                          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: Responsive.h(AppSizes.fontMedium),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(
                                      Responsive.r(AppSizes.radiusSmall) / 2,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: Responsive.h(
                                    AppSizes.spacingSmall - 2,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: Responsive.w(
                                        AppSizes.spacingXXXLarge,
                                      ),
                                      height: Responsive.h(AppSizes.fontSmall),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(
                                          Responsive.r(AppSizes.radiusSmall) /
                                              2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: Responsive.w(
                                        AppSizes.spacingSmall,
                                      ),
                                    ),
                                    Container(
                                      width: Responsive.w(
                                        AppSizes.iconHuge +
                                            AppSizes.spacingSmall,
                                      ),
                                      height: Responsive.h(AppSizes.fontSmall),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(
                                          Responsive.r(AppSizes.radiusSmall) /
                                              2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          else if (items.isEmpty)
            Padding(
              padding: Responsive.all(AppSizes.spacingLarge),
              child: Center(
                child: Text(
                  AppStrings.noItemsFound,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontMedium),
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final item = items[index];
                final rItem = _localReturnItems[item.id] ?? {};
                final isLocalGood = rItem['status'] == 'good';
                final isLocalDamaged = rItem['status'] == 'damaged';
                final hasDbDamage = (item.damageCharges ?? 0.0) > 0 ||
                    (item.damagedQuantity ?? 0) > 0 ||
                    item.conditionRating == ConditionRating.damaged;
                final isDamagedItem = hasDbDamage;

                Color cardColor = Colors.transparent;
                Border? cardBorder;

                if (isReturnable) {
                  if (isLocalDamaged) {
                    cardColor = AppColors.warning.withValues(alpha: 0.06);
                    cardBorder = Border.all(
                      color: AppColors.warning.withValues(alpha: 0.4),
                      width: AppSizes.spacingTiny / 4,
                    );
                  } else if (isLocalGood) {
                    cardColor = AppColors.success.withValues(alpha: 0.04);
                    cardBorder = Border.all(
                      color: AppColors.success.withValues(alpha: 0.25),
                      width: AppSizes.spacingTiny / 4,
                    );
                  }
                } else if (isDamagedItem) {
                  cardColor = AppColors.warning.withValues(alpha: 0.06);
                  cardBorder = Border.all(
                    color: AppColors.warning.withValues(alpha: 0.45),
                    width: AppSizes.spacingTiny / 4,
                  );
                }

                final int returnedQty = item.returnedQuantity ??
                    (item.isReturned == true ? item.quantity : 0);
                final bool isFullyReturned = item.isReturned == true ||
                    (returnedQty >= item.quantity && item.quantity > 0);
                final bool isPartiallyReturned =
                    !isFullyReturned && returnedQty > 0;
                final bool hasRecordedReturn =
                    isFullyReturned || isPartiallyReturned;
                final int damagedQty = item.damagedQuantity ??
                    (hasDbDamage
                        ? (isFullyReturned ? item.quantity : 1)
                        : 0);
                final double damageCharges = item.damageCharges ?? 0.0;

                return Container(
                  margin: Responsive.symmetric(
                    horizontal: AppSizes.spacingSmall,
                    vertical: AppSizes.spacingTiny / 2,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(
                      Responsive.r(AppSizes.radiusSmall),
                    ),
                    border: cardBorder,
                  ),
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
                              borderRadius: BorderRadius.circular(
                                Responsive.r(AppSizes.radiusSmall),
                              ),
                              border: Border.all(
                                color: AppColors.border,
                                width: AppSizes.spacingTiny / 4,
                              ),
                            ),
                            child: item.product?.primaryImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      Responsive.r(AppSizes.radiusSmall),
                                    ),
                                    child: Image.network(
                                      item.product!.primaryImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.image_not_supported_outlined,
                                            color: AppColors.secondaryText,
                                          ),
                                    ),
                                  )
                                : Icon(
                                    Icons.image_not_supported_outlined,
                                    color: AppColors.secondaryText,
                                  ),
                          ),
                          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product?.name ??
                                      'Product #${item.productId.substring(0, 8)}',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(AppSizes.fontSmall),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                                Wrap(
                                  spacing: Responsive.w(AppSizes.spacingSmall),
                                  runSpacing: Responsive.h(AppSizes.spacingTiny),
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: Responsive.symmetric(
                                        horizontal: AppSizes.spacingSmall - 2,
                                        vertical: AppSizes.spacingTiny / 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          Responsive.r(AppSizes.radiusSmall / 2),
                                        ),
                                      ),
                                      child: Text(
                                        'x${item.quantity}',
                                        style: TextStyle(
                                          fontSize: Responsive.sp(
                                            AppSizes.fontTiny,
                                          ),
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '₹${item.pricePerDay.toStringAsFixed(0)}/day',
                                      style: TextStyle(
                                        fontSize: Responsive.sp(
                                          AppSizes.fontTiny + 1,
                                        ),
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    if (item.discount > 0)
                                      Container(
                                        padding: Responsive.symmetric(
                                          horizontal: AppSizes.spacingSmall - 2,
                                          vertical: AppSizes.spacingTiny / 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            Responsive.r(AppSizes.radiusSmall / 2),
                                          ),
                                        ),
                                        child: Text(
                                          item.discountType == 'percent'
                                              ? '-${item.discount.toStringAsFixed(0)}% Off'
                                              : '-₹${item.discount.toStringAsFixed(0)} Flat Off',
                                          style: TextStyle(
                                            fontSize: Responsive.sp(
                                              AppSizes.fontTiny,
                                            ),
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ),
                                    if (item.gstPercentage > 0)
                                      Container(
                                        padding: Responsive.symmetric(
                                          horizontal: AppSizes.spacingSmall - 2,
                                          vertical: AppSizes.spacingTiny / 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.info.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            Responsive.r(AppSizes.radiusSmall / 2),
                                          ),
                                        ),
                                        child: Text(
                                          '${item.gstPercentage.toStringAsFixed(0)}% GST Incl.',
                                          style: TextStyle(
                                            fontSize: Responsive.sp(
                                              AppSizes.fontTiny,
                                            ),
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.info,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (item.gstAmount > 0 || item.discount > 0)
                                  Padding(
                                    padding: Responsive.only(
                                      top: AppSizes.spacingTiny,
                                    ),
                                    child: Text(
                                      'Base: ₹${item.baseAmount.toStringAsFixed(2)} + GST: ₹${item.gstAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: Responsive.sp(
                                          AppSizes.fontTiny + 1,
                                        ),
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ),
                                if (hasRecordedReturn || hasDbDamage || !isReturnable)
                                  Padding(
                                    padding: Responsive.only(
                                      top: AppSizes.spacingTiny,
                                    ),
                                    child: Wrap(
                                      spacing: Responsive.w(AppSizes.spacingSmall),
                                      runSpacing: Responsive.h(AppSizes.spacingTiny),
                                      children: [
                                        if (isFullyReturned)
                                          Container(
                                            padding: Responsive.symmetric(
                                              horizontal: AppSizes.spacingSmall - 2,
                                              vertical: AppSizes.spacingTiny / 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.success.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(
                                                Responsive.r(AppSizes.radiusSmall / 2),
                                              ),
                                              border: Border.all(
                                                color: AppColors.success.withValues(alpha: 0.3),
                                                width: AppSizes.spacingTiny / 4,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check_circle_outline_rounded,
                                                  size: Responsive.icon(AppSizes.iconTiny - 2),
                                                  color: AppColors.success,
                                                ),
                                                SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                                Text(
                                                  'Returned: $returnedQty / ${item.quantity}',
                                                  style: TextStyle(
                                                    fontSize: Responsive.sp(AppSizes.fontTiny - 1),
                                                    color: AppColors.success,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else if (isPartiallyReturned)
                                          Container(
                                            padding: Responsive.symmetric(
                                              horizontal: AppSizes.spacingSmall - 2,
                                              vertical: AppSizes.spacingTiny / 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.info.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(
                                                Responsive.r(AppSizes.radiusSmall / 2),
                                              ),
                                              border: Border.all(
                                                color: AppColors.info.withValues(alpha: 0.3),
                                                width: AppSizes.spacingTiny / 4,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.timelapse_rounded,
                                                  size: Responsive.icon(AppSizes.iconTiny - 2),
                                                  color: AppColors.info,
                                                ),
                                                SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                                Text(
                                                  'Partial Return: $returnedQty / ${item.quantity}',
                                                  style: TextStyle(
                                                    fontSize: Responsive.sp(AppSizes.fontTiny - 1),
                                                    color: AppColors.info,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else if (!isReturnable)
                                          Container(
                                            padding: Responsive.symmetric(
                                              horizontal: AppSizes.spacingSmall - 2,
                                              vertical: AppSizes.spacingTiny / 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(
                                                Responsive.r(AppSizes.radiusSmall / 2),
                                              ),
                                            ),
                                            child: Text(
                                              'Returned: 0 / ${item.quantity}',
                                              style: TextStyle(
                                                fontSize: Responsive.sp(AppSizes.fontTiny - 1),
                                                color: AppColors.secondaryText,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        if (hasDbDamage && damagedQty > 0)
                                          Container(
                                            padding: Responsive.symmetric(
                                              horizontal: AppSizes.spacingSmall - 2,
                                              vertical: AppSizes.spacingTiny / 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.warning.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(
                                                Responsive.r(AppSizes.radiusSmall / 2),
                                              ),
                                              border: Border.all(
                                                color: AppColors.warning.withValues(alpha: 0.4),
                                                width: AppSizes.spacingTiny / 4,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.warning_amber_rounded,
                                                  size: Responsive.icon(AppSizes.iconTiny - 2),
                                                  color: AppColors.warning,
                                                ),
                                                SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                                Text(
                                                  'Damaged: $damagedQty',
                                                  style: TextStyle(
                                                    fontSize: Responsive.sp(AppSizes.fontTiny - 1),
                                                    color: AppColors.warning,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (damageCharges > 0)
                                          Container(
                                            padding: Responsive.symmetric(
                                              horizontal: AppSizes.spacingSmall - 2,
                                              vertical: AppSizes.spacingTiny / 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.warning.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(
                                                Responsive.r(AppSizes.radiusSmall / 2),
                                              ),
                                              border: Border.all(
                                                color: AppColors.warning.withValues(alpha: 0.4),
                                                width: AppSizes.spacingTiny / 4,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.currency_rupee_rounded,
                                                  size: Responsive.icon(AppSizes.iconTiny - 2),
                                                  color: AppColors.warning,
                                                ),
                                                Text(
                                                  'Damage Fee: ₹${damageCharges.toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    fontSize: Responsive.sp(AppSizes.fontTiny - 1),
                                                    color: AppColors.warning,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (hasDbDamage && (item.quantity - damagedQty) > 0)
                                          Container(
                                            padding: Responsive.symmetric(
                                              horizontal: AppSizes.spacingSmall - 2,
                                              vertical: AppSizes.spacingTiny / 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.success.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(
                                                Responsive.r(AppSizes.radiusSmall / 2),
                                              ),
                                            ),
                                            child: Text(
                                              '✓ ${(item.quantity - damagedQty)} of ${item.quantity} auto-marked Good',
                                              style: TextStyle(
                                                fontSize: Responsive.sp(AppSizes.fontTiny - 1),
                                                color: AppColors.success,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                if (hasDbDamage &&
                                    item.damageDescription != null &&
                                    item.damageDescription!.isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    margin: Responsive.only(top: AppSizes.spacingSmall),
                                    padding: Responsive.all(AppSizes.spacingSmall),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                        Responsive.r(AppSizes.radiusSmall),
                                      ),
                                      border: Border.all(
                                        color: AppColors.warning.withValues(alpha: 0.3),
                                        width: AppSizes.spacingTiny / 4,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.report_problem_outlined,
                                              size: Responsive.icon(AppSizes.iconTiny - 2),
                                              color: AppColors.warning,
                                            ),
                                            SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                            Text(
                                              'DAMAGE NOTES',
                                              style: TextStyle(
                                                fontSize: Responsive.sp(AppSizes.fontTiny - 2),
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.warning,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                                        Text(
                                          item.damageDescription!,
                                          style: TextStyle(
                                            fontSize: Responsive.sp(AppSizes.fontTiny),
                                            color: AppColors.text,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
          if (isReturnable && items.isNotEmpty)
            _buildItemsReturnFooter(items),
        ],
      ),
    );
  }

  Widget _buildItemsReturnFooter(List<OrderItem> items) {
    // 1. Calculate live damage fees from _localReturnItems
    double liveDamageTotal = 0.0;
    for (final item in items) {
      final state = _localReturnItems[item.id];
      final status = state?['status'];
      if (status == 'damaged') {
        liveDamageTotal += (state?['damage_fee'] as num? ?? 0.0).toDouble();
      }
    }

    final double extraDiscount =
        double.tryParse(_extraDiscountController.text) ?? 0.0;

    return Container(
      padding: Responsive.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppSizes.spacingTiny / 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Settlement Preview
          _buildProjectedSettlementCard(
            liveDamage: liveDamageTotal,
            liveDiscount: extraDiscount,
            onCollectPayment: _openPaymentDialog,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),

          // Return Discount (Optional)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Return Discount (Optional)',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontTiny),
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
              TextField(
                controller: _extraDiscountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontSmall),
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  isDense: true,
                  contentPadding: Responsive.symmetric(
                    horizontal: AppSizes.spacingSmall,
                    vertical: AppSizes.spacingSmall,
                  ),
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryText,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.r(AppSizes.radiusSmall),
                    ),
                    borderSide: BorderSide(
                      color: AppColors.border,
                      width: AppSizes.spacingTiny / 4,
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),

          // Optional Return Notes
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Return Notes (optional)',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontTiny),
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
              TextField(
                controller: _returnNotesController,
                style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall)),
                decoration: InputDecoration(
                  hintText: 'e.g. Returned on time, minor wear',
                  isDense: true,
                  contentPadding: Responsive.symmetric(
                    horizontal: AppSizes.spacingSmall,
                    vertical: AppSizes.spacingSmall,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.r(AppSizes.radiusSmall),
                    ),
                    borderSide: BorderSide(
                      color: AppColors.border,
                      width: AppSizes.spacingTiny / 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),

          // Primary Return Completion Action
          SizedBox(
            width: double.infinity,
            height: Responsive.h(AppSizes.spacingHuge + AppSizes.spacingSmall),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                ),
              ),
              onPressed: () => _confirmAndSubmitInlineReturn(items),
              icon: Icon(
                Icons.assignment_turned_in_rounded,
                size: Responsive.icon(AppSizes.iconSmall),
              ),
              label: Text(
                'Complete Return Process',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontMedium),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndSubmitInlineReturn(List<OrderItem> items) async {
    // 1. Check for unmarked items
    final unmarked = items.where((item) {
      final status = _localReturnItems[item.id]?['status'];
      return status == null;
    }).toList();

    if (unmarked.isNotEmpty) {
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.warning,
                size: Responsive.icon(AppSizes.iconMedium),
              ),
              SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
              const Text('Incomplete Checkup'),
            ],
          ),
          content: Text(
            '${unmarked.length} item(s) have not been inspected yet. Would you like to mark them as Good and proceed, or review them?',
            style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'review'),
              child: const Text('Review Items'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, 'mark_good'),
              child: const Text('Mark Remaining Good & Proceed'),
            ),
          ],
        ),
      );

      if (action != 'mark_good') return;

      // Auto mark remaining unmarked as good
      for (final item in unmarked) {
        _localReturnItems[item.id] = {
          'status': 'good',
          'damage_fee': 0.0,
          'damaged_quantity': 0,
          'notes': '',
        };
        if (_notesControllers.containsKey(item.id)) {
          _notesControllers[item.id]!.text = '';
        }
        if (_feeControllers.containsKey(item.id)) {
          _feeControllers[item.id]!.text = '0';
        }
      }
      setState(() {});
    }

    // 2. Compute summary
    double liveDamageTotal = 0.0;
    int goodCount = 0;
    int damagedCount = 0;

    for (final item in items) {
      final state = _localReturnItems[item.id];
      if (state?['status'] == 'damaged') {
        damagedCount++;
        liveDamageTotal += (state?['damage_fee'] as num? ?? 0.0).toDouble();
      } else {
        goodCount++;
      }
    }

    final double extraDiscount =
        double.tryParse(_extraDiscountController.text) ?? 0.0;
    final double originalBaseTotal =
        _currentOrder.totalAmount -
        _currentOrder.damageChargesTotal -
        _currentOrder.lateFee;
    final double newTotal =
        originalBaseTotal + liveDamageTotal - extraDiscount;
    final double balanceDue = newTotal - _currentOrder.amountPaid;

    // 3. Confirmation Dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm & Complete Return'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to complete the return process for this order?',
              style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall)),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            Container(
              padding: Responsive.all(AppSizes.spacingSmall),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
                border: Border.all(
                  color: AppColors.border,
                  width: AppSizes.spacingTiny / 4,
                ),
              ),
              child: Column(
                children: [
                  _buildSettlementRow(
                    'Inspected Items',
                    '${items.length} ($goodCount Good, $damagedCount Damaged)',
                  ),
                  if (liveDamageTotal > 0)
                    _buildSettlementRow(
                      'Damage Fees',
                      '+₹${liveDamageTotal.toStringAsFixed(2)}',
                      valueColor: AppColors.warning,
                      isBoldValue: true,
                    ),
                  if (extraDiscount > 0)
                    _buildSettlementRow(
                      'Return Discount',
                      '−₹${extraDiscount.toStringAsFixed(2)}',
                      valueColor: AppColors.success,
                      isBoldValue: true,
                    ),
                  Padding(
                    padding: Responsive.symmetric(
                      vertical: AppSizes.spacingTiny / 2,
                    ),
                    child: const Divider(height: 1, color: AppColors.border),
                  ),
                  _buildSettlementRow(
                    'New Total',
                    '₹${newTotal.toStringAsFixed(2)}',
                    isBoldLabel: true,
                    isBoldValue: true,
                  ),
                  _buildSettlementRow(
                    'Amount Paid',
                    '−₹${_currentOrder.amountPaid.toStringAsFixed(2)}',
                    valueColor: AppColors.success,
                    isBoldValue: true,
                  ),
                  _buildSettlementRow(
                    'Balance Due',
                    '₹${balanceDue.toStringAsFixed(2)}',
                    isBoldLabel: true,
                    isBoldValue: true,
                    valueColor:
                        balanceDue > 0 ? AppColors.error : AppColors.success,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm & Complete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 4. Build return items payload
    final returnItemsPayload = <Map<String, dynamic>>[];
    for (final item in items) {
      final rItem = _localReturnItems[item.id] ?? {};
      final isDamaged = rItem['status'] == 'damaged';
      final damagedQty = isDamaged
          ? (rItem['damaged_quantity'] as int? ?? item.quantity)
          : 0;
      final fee = isDamaged
          ? (rItem['damage_fee'] as double? ?? 0.0)
          : 0.0;
      final notes = isDamaged
          ? (rItem['notes'] as String? ?? '')
          : '';

      returnItemsPayload.add({
        'item_id': item.id,
        'returned_quantity': item.quantity,
        'condition_rating': isDamaged ? 'damaged' : 'excellent',
        if (isDamaged) ...{
          'damage_description': notes,
          'damage_charges': fee,
          'damaged_quantity': damagedQty,
        },
      });
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(orderOperationsProvider)
          .processReturn(
            orderId: _currentOrder.id,
            items: returnItemsPayload,
            notes: _returnNotesController.text,
            lateFee: 0.0,
            discount: extraDiscount,
          );
      await _refreshOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order return completed successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete return: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildProjectedSettlementCard({
    double? liveDamage,
    double? liveLate,
    double? liveDiscount,
    VoidCallback? onCollectPayment,
  }) {
    final double damageFees = liveDamage ?? _currentOrder.damageChargesTotal;
    final double lateFees = liveLate ?? _currentOrder.lateFee;
    final double discount = liveDiscount ?? _currentOrder.discount;

    // Base order total before any return-time adjustments (damage, late fee)
    final double originalBaseTotal =
        _currentOrder.totalAmount -
        _currentOrder.damageChargesTotal -
        _currentOrder.lateFee;

    final double newTotal = originalBaseTotal + damageFees + lateFees - discount;
    final double amountPaid = _currentOrder.amountPaid;
    final double balanceDue = newTotal - amountPaid;

    final bool showLateWarning = lateFees > 0 && !_currentOrder.isLate;

    return Container(
      width: double.infinity,
      padding: Responsive.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.4),
          width: AppSizes.spacingTiny / 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: AppColors.warning,
                size: Responsive.icon(AppSizes.iconSmall),
              ),
              SizedBox(width: Responsive.w(AppSizes.spacingTiny + 2)),
              Text(
                'PROJECTED SETTLEMENT',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontTiny),
                  fontWeight: FontWeight.w900,
                  color: AppColors.warning,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          _buildSettlementRow(
            'Base Order Total',
            '₹${originalBaseTotal.toStringAsFixed(2)}',
            isBoldValue: true,
          ),
          if (damageFees > 0) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
            _buildSettlementRow(
              '+ Damage Fees',
              '+₹${damageFees.toStringAsFixed(2)}',
              valueColor: AppColors.warning,
              isBoldValue: true,
            ),
          ],
          if (lateFees > 0) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
            _buildSettlementRow(
              '+ Late Fee',
              '+₹${lateFees.toStringAsFixed(2)}',
              valueColor: AppColors.error,
              isBoldValue: true,
            ),
          ],
          if (discount > 0) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
            _buildSettlementRow(
              '− Discount',
              '−₹${discount.toStringAsFixed(2)}',
              valueColor: AppColors.success,
              isBoldValue: true,
            ),
          ],
          SizedBox(height: Responsive.h(AppSizes.spacingTiny + 2)),
          Divider(
            color: AppColors.warning.withValues(alpha: 0.3),
            height: 1,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingTiny + 2)),
          _buildSettlementRow(
            'New Total',
            '₹${newTotal.toStringAsFixed(2)}',
            isBoldLabel: true,
            isBoldValue: true,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
          _buildSettlementRow(
            'Less: Paid',
            '−₹${amountPaid.toStringAsFixed(2)}',
            valueColor: AppColors.success,
            isBoldValue: true,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingTiny + 2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance Due',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontMedium),
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              Text(
                '₹${balanceDue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontLarge),
                  fontWeight: FontWeight.w900,
                  color: balanceDue > 0 ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
          if (showLateWarning) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Container(
              padding: Responsive.all(AppSizes.spacingSmall),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.warning,
                    size: Responsive.icon(AppSizes.iconSmall),
                  ),
                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ON-TIME RETURN WARNING',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny - 1),
                            fontWeight: FontWeight.w900,
                            color: AppColors.warning,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                        Text(
                          'This order is returned on-time. Extra late fee of ₹${lateFees.toStringAsFixed(2)} is being applied.',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny),
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (balanceDue > 0) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            Container(
              padding: Responsive.all(AppSizes.spacingSmall + 2),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: AppSizes.spacingTiny / 4,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: Responsive.all(AppSizes.spacingTiny),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: Responsive.icon(AppSizes.iconSmall),
                    ),
                  ),
                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Due — ₹${balanceDue.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                        Text(
                          'Collect the remaining balance before or after completing the return.',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny),
                            color: AppColors.error.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onCollectPayment != null) ...[
                    SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                    ElevatedButton(
                      onPressed: onCollectPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: Responsive.symmetric(
                          horizontal: AppSizes.spacingMedium,
                          vertical: AppSizes.spacingSmall,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                        ),
                      ),
                      child: Text(
                        'Collect Payment',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettlementRow(
    String label,
    String value, {
    bool isBoldLabel = false,
    bool isBoldValue = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontSmall),
            fontWeight: isBoldLabel ? FontWeight.w900 : FontWeight.normal,
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontSmall),
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsCard() {
    final paymentsAsync = ref.watch(orderPaymentsProvider(_currentOrder.id));
    print(
      '[OrderDetailView] _buildPaymentsCard. Order ID: ${_currentOrder.id}, status: ${_currentOrder.status}',
    );
    print(
      '[OrderDetailView] Order advance Collected: ${_currentOrder.advanceCollected}, advanceAmount: ${_currentOrder.advanceAmount}, amountPaid: ${_currentOrder.amountPaid}',
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          Responsive.r(AppSizes.radiusMedium),
        ),
        border: Border.all(
          color: AppColors.border,
          width: AppSizes.spacingTiny / 4,
        ),
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
            loading: () {
              print('[OrderDetailView] paymentsAsync: LOADING...');
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
            error: (err, stack) {
              print('[OrderDetailView] paymentsAsync: ERROR: $err');
              print(stack);
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading payments: $err',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            },
            data: (transactions) {
              print(
                '[OrderDetailView] paymentsAsync: DATA loaded. DB count: ${transactions.length}',
              );

              final displayedTransactions = List<PaymentTransaction>.from(
                transactions,
              );

              // Calculate sum of payments from the database
              final dbPaymentsSum = transactions.fold<double>(
                0.0,
                (sum, tx) => sum + tx.amount,
              );
              double missingAmount = _currentOrder.amountPaid - dbPaymentsSum;
              print(
                '[OrderDetailView] dbPaymentsSum: $dbPaymentsSum, currentOrder.amountPaid: ${_currentOrder.amountPaid}, missingAmount: $missingAmount',
              );

              if (missingAmount > 0.01) {
                // Determine if we need to synthesize an advance payment
                final hasAdvanceInDb = transactions.any(
                  (tx) => tx.paymentType.toLowerCase() == 'advance',
                );
                final shouldSynthesizeAdvance =
                    !hasAdvanceInDb &&
                    _currentOrder.advanceCollected &&
                    _currentOrder.advanceAmount > 0.01;

                if (shouldSynthesizeAdvance) {
                  final advanceVirtualAmount =
                      missingAmount < _currentOrder.advanceAmount
                      ? missingAmount
                      : _currentOrder.advanceAmount;

                  print(
                    '[OrderDetailView] Synthesizing virtual advance transaction of ₹$advanceVirtualAmount',
                  );
                  displayedTransactions.add(
                    PaymentTransaction(
                      id: 'virtual-advance',
                      orderId: _currentOrder.id,
                      paymentType: 'advance',
                      amount: advanceVirtualAmount,
                      paymentMode:
                          _currentOrder.advancePaymentMethod?.toJsonValue() ??
                          'cash',
                      paymentDate:
                          _currentOrder.advanceCollectedAt ??
                          _currentOrder.createdAt,
                      notes: 'Advance payment (Inferred from order details)',
                      createdBy: null,
                      createdByName: 'System',
                    ),
                  );

                  missingAmount -= advanceVirtualAmount;
                }

                // If there's still a missing amount, synthesize a final/partial payment
                if (missingAmount > 0.01) {
                  print(
                    '[OrderDetailView] Synthesizing virtual final transaction of ₹$missingAmount',
                  );
                  displayedTransactions.add(
                    PaymentTransaction(
                      id: 'virtual-payment',
                      orderId: _currentOrder.id,
                      paymentType: 'final',
                      amount: missingAmount,
                      paymentMode: 'cash',
                      paymentDate: _currentOrder.createdAt,
                      notes: 'Payment (Inferred from order amount paid)',
                      createdBy: null,
                      createdByName: 'System',
                    ),
                  );
                }
              }

              print(
                '[OrderDetailView] Total displayed transactions: ${displayedTransactions.length}',
              );

              if (displayedTransactions.isEmpty) {
                return Padding(
                  padding: Responsive.all(AppSizes.spacingMedium),
                  child: Text(
                    'No transactions recorded.',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: Responsive.sp(AppSizes.fontSmall),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedTransactions.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final tx = displayedTransactions[index];
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
                                    padding: Responsive.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: txTypeColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      tx.paymentType.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: Responsive.sp(
                                          AppSizes.fontTiny,
                                        ),
                                        fontWeight: FontWeight.w800,
                                        color: txTypeColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: Responsive.w(AppSizes.spacingSmall),
                                  ),
                                  Container(
                                    padding: Responsive.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      tx.paymentMode.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: Responsive.sp(
                                          AppSizes.fontTiny,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: Responsive.h(AppSizes.spacingTiny + 2),
                              ),
                              Text(
                                _formatDate(tx.paymentDate),
                                style: TextStyle(
                                  fontSize: Responsive.sp(
                                    AppSizes.fontTiny + 1,
                                  ),
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              if (tx.transactionId != null &&
                                  tx.transactionId!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    'Ref: ${tx.transactionId}',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(
                                        AppSizes.fontTiny + 1,
                                      ),
                                      color: AppColors.secondaryText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (tx.notes != null && tx.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Notes: ${tx.notes}',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(
                                        AppSizes.fontTiny + 1,
                                      ),
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
                                      fontSize: Responsive.sp(
                                        AppSizes.fontTiny,
                                      ),
                                      color: AppColors.secondaryText.withValues(
                                        alpha: 0.8,
                                      ),
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
    String formatCancelledAt(String isoString) {
      try {
        final date = DateTime.parse(isoString);
        return DateFormat('dd MMM, yyyy h:mm a').format(date);
      } catch (_) {
        return isoString;
      }
    }

    final balanceDue = _currentOrder.totalAmount - _currentOrder.amountPaid;
    final isPaid = balanceDue <= 0;
    final items = _currentOrder.items ?? [];

    final rawSubtotal = items.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );
    final afterItemDiscountTotal = items.fold<double>(
      0.0,
      (sum, item) => sum + item.baseAmount + item.gstAmount,
    );
    final itemDiscountsTotal = rawSubtotal - afterItemDiscountTotal;

    final totalBaseExclGst = items.fold<double>(
      0.0,
      (sum, item) => sum + item.baseAmount,
    );
    final totalGst = items.fold<double>(
      0.0,
      (sum, item) => sum + item.gstAmount,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          Responsive.r(AppSizes.radiusMedium),
        ),
        border: Border.all(
          color: AppColors.border,
          width: AppSizes.spacingTiny / 4,
        ),
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
                if (_currentOrder.status != OrderStatus.completed &&
                    _currentOrder.status != OrderStatus.cancelled)
                  TextButton.icon(
                    onPressed: _openAdjustmentDialog,
                    icon: Icon(
                      Icons.local_offer_outlined,
                      size: Responsive.icon(14),
                      color: AppColors.primary,
                    ),
                    label: Text(
                      'Discount',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: Responsive.symmetric(
                        horizontal: AppSizes.spacingSmall,
                        vertical: AppSizes.spacingTiny,
                      ),
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
                _buildReceiptRow(
                  'Subtotal',
                  '₹${rawSubtotal.toStringAsFixed(2)}',
                ),
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
                      padding: Responsive.only(
                        left: AppSizes.spacingMedium,
                        top: 2,
                        bottom: 2,
                      ),
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
                _buildReceiptRow(
                  'Base Amount (excl. GST)',
                  '₹${totalBaseExclGst.toStringAsFixed(2)}',
                ),
                _buildReceiptRow(
                  'GST (included)',
                  '₹${totalGst.toStringAsFixed(2)}',
                  valueColor: AppColors.info,
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                const Divider(height: 1, color: AppColors.border),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                if (_currentOrder.discount > 0)
                  _buildReceiptRow(
                    'Order Discount',
                    '-₹${_currentOrder.discount.toStringAsFixed(2)}',
                    isDiscount: true,
                  ),
                if (_currentOrder.damageChargesTotal > 0)
                  _buildReceiptRow(
                    'Damage Charges',
                    '₹${_currentOrder.damageChargesTotal.toStringAsFixed(2)}',
                  ),
                if (_currentOrder.lateFee > 0)
                  _buildReceiptRow(
                    'Late Fee',
                    '₹${_currentOrder.lateFee.toStringAsFixed(2)}',
                  ),
                SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                if (_currentOrder.status == OrderStatus.cancelled) ...[
                  if (_currentOrder.advanceAmount > 0.01)
                    _buildReceiptRow(
                      'Original Advance',
                      '₹${_currentOrder.advanceAmount.toStringAsFixed(2)}',
                    ),
                  SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                  if (_currentOrder.amountPaid == 0) ...[
                    // Case A: Fully refunded
                    Container(
                      padding: Responsive.all(AppSizes.spacingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          width: AppSizes.spacingTiny / 4,
                        ),
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Advance Refunded',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontSmall),
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                          Text(
                            '-₹${_currentOrder.advanceAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium),
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                    _buildReceiptRow(
                      'No Balance Due',
                      '₹0.00',
                      valueColor: AppColors.secondaryText,
                    ),
                  ] else if (_currentOrder.paymentStatus ==
                      PaymentStatus.refundWaived) ...[
                    // Case B: Refund waived — money kept
                    Container(
                      padding: Responsive.all(AppSizes.spacingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: AppSizes.spacingTiny / 4,
                        ),
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: Responsive.icon(AppSizes.iconSmall),
                                color: AppColors.primary,
                              ),
                              SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                              Text(
                                'Refund waived — money kept',
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontSmall),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₹${_currentOrder.amountPaid.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                    _buildReceiptRow(
                      'No Balance Due',
                      '₹0.00',
                      valueColor: AppColors.secondaryText,
                    ),
                  ] else ...[
                    // Case C: Money still held — pending refund
                    Container(
                      padding: Responsive.all(AppSizes.spacingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          width: AppSizes.spacingTiny / 4,
                        ),
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount Held',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontSmall),
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                          Text(
                            '₹${_currentOrder.amountPaid.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium),
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                    _buildReceiptRow(
                      'Refundable',
                      '₹${_currentOrder.amountPaid.toStringAsFixed(2)}',
                      valueColor: AppColors.warning,
                      isBold: true,
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade100,
                          foregroundColor: Colors.amber.shade900,
                          elevation: 0,
                          side: BorderSide(
                            color: Colors.amber.shade300,
                            width: AppSizes.spacingTiny / 4,
                          ),
                          padding: Responsive.symmetric(
                            vertical: AppSizes.spacingMedium - 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Responsive.r(AppSizes.radiusSmall),
                            ),
                          ),
                        ),
                        onPressed: _openCancellationRefundDialog,
                        icon: Icon(
                          Icons.replay_rounded,
                          size: Responsive.icon(AppSizes.iconSmall),
                        ),
                        label: Text(
                          'Refund Payment (₹${_currentOrder.amountPaid.toStringAsFixed(2)})',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.teal.shade50,
                          foregroundColor: Colors.teal.shade800,
                          side: BorderSide(
                            color: Colors.teal.shade200,
                            width: AppSizes.spacingTiny / 4,
                          ),
                          padding: Responsive.symmetric(
                            vertical: AppSizes.spacingMedium - 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Responsive.r(AppSizes.radiusSmall),
                            ),
                          ),
                        ),
                        onPressed: _openKeepMoneyDialog,
                        child: Text(
                          'Keep Money — No Refund Needed',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_currentOrder.cancellationReason != null &&
                      _currentOrder.cancellationReason!.trim().isNotEmpty) ...[
                    SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                    Container(
                      width: double.infinity,
                      padding: Responsive.all(AppSizes.spacingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.05),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.15),
                          width: AppSizes.spacingTiny / 4,
                        ),
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cancellation Reason',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontSmall),
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                          SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                          Text(
                            _currentOrder.cancellationReason!,
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontSmall),
                              color: AppColors.error,
                            ),
                          ),
                          if (_currentOrder.cancelledAt != null) ...[
                            SizedBox(
                              height: Responsive.h(AppSizes.spacingTiny),
                            ),
                            Text(
                              'Cancelled on ${formatCancelledAt(_currentOrder.cancelledAt!)}',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontTiny),
                                color: AppColors.error.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  _buildReceiptRow(
                    'Total Amount',
                    '₹${_currentOrder.totalAmount.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                  _buildReceiptRow(
                    'Advance/Deposit',
                    '₹${_currentOrder.advanceAmount.toStringAsFixed(2)}',
                  ),
                  _buildReceiptRow(
                    'Amount Paid',
                    '₹${_currentOrder.amountPaid.toStringAsFixed(2)}',
                    valueColor: AppColors.success,
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                  Container(
                    padding: Responsive.all(AppSizes.spacingMedium),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.success.withValues(alpha: 0.08)
                          : AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                        Responsive.r(AppSizes.radiusSmall),
                      ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    bool isDiscount = false,
  }) {
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
              color:
                  valueColor ??
                  (isDiscount ? AppColors.success : AppColors.text),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startRentalWithCheck() async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final creationDateStr = _currentOrder.createdAt.split('T')[0];
    final isBackdated = _currentOrder.startDate.compareTo(creationDateStr) < 0;

    final todayDate = DateTime.parse(todayStr);
    final endDate = DateTime.tryParse(_currentOrder.endDate);
    if (!isBackdated && endDate != null && endDate.isBefore(todayDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rental Expired: Cannot start a rental whose scheduled return date has already passed. Please create a new order instead.',
          ),
        ),
      );
      return;
    }

    if (_currentOrder.hasStockConflict) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot start rental: Inventory fulfillment conflict detected. Please resolve stock issues first.',
          ),
        ),
      );
      return;
    }

    final checkStartDate = isBackdated ? _currentOrder.startDate : todayStr;

    setState(() => _isLoading = true);

    try {
      final itemsPayload = (_currentOrder.items ?? [])
          .map((i) => {'product_id': i.productId, 'quantity': i.quantity})
          .toList();

      final checkResult = await ref
          .read(orderOperationsProvider)
          .checkAvailability(
            startDate: checkStartDate,
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

      // If available, transition status to ongoing and sync start_date
      await ref.read(orderOperationsProvider).updateOrder(_currentOrder.id, {
        'status': 'ongoing',
        'start_date': checkStartDate,
      });
      await _refreshOrder();
      ref.invalidate(ordersProvider);
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
              ...itemsList
                  .where((i) => !(i['isAvailable'] as bool? ?? true))
                  .map((i) {
                    final name = i['product_name'] ?? 'Product';
                    final avail = i['available'] ?? 0;
                    final req = i['requested'] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '• $name: Requested $req, but only $avail available.',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
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

  void _openBackfillReturnDialog() {
    final noteController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.r(AppSizes.radiusLarge)),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: Responsive.w(AppSizes.spacingLarge),
                right: Responsive.w(AppSizes.spacingLarge),
                top: Responsive.h(AppSizes.spacingLarge),
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
                    Responsive.h(AppSizes.spacingLarge),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Record as Returned',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontLarge),
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  Container(
                    padding: Responsive.all(AppSizes.spacingMedium),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: AppSizes.spacingTiny / 4,
                      ),
                      borderRadius: BorderRadius.circular(
                        Responsive.r(AppSizes.radiusSmall),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recording an untracked rental',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                        Text(
                          'This order was never marked as delivered or ongoing in the system, but the return date has passed. Use this to record that the costume was actually given and has been returned. A note explaining why it was not tracked is required.',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                            color: Colors.amber.shade800,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  RichText(
                    text: TextSpan(
                      text: 'REASON / NOTE ',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondaryText,
                        letterSpacing: 0.5,
                      ),
                      children: const [
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'e.g., Staff was not present at delivery. Costume was given offline and returned on time.',
                      hintStyle: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        color: AppColors.secondaryText.withValues(alpha: 0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                        borderSide: BorderSide(
                          color: Colors.amber.shade600,
                          width: AppSizes.spacingTiny / 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: Responsive.symmetric(
                              vertical: AppSizes.spacingMedium - 2,
                            ),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Responsive.r(AppSizes.radiusSmall),
                              ),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(sheetContext),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium),
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            padding: Responsive.symmetric(
                              vertical: AppSizes.spacingMedium - 2,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Responsive.r(AppSizes.radiusSmall),
                              ),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final note = noteController.text.trim();
                                  if (note.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a reason note',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setSheetState(() => isSubmitting = true);
                                  try {
                                    await ref
                                        .read(orderOperationsProvider)
                                        .updateOrder(_currentOrder.id, {
                                          'status': 'returned',
                                          'backfill_note': note,
                                        });
                                    if (sheetContext.mounted) {
                                      Navigator.pop(sheetContext);
                                    }
                                    await _refreshOrder();
                                    ref.invalidate(ordersProvider);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Order recorded as returned successfully',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setSheetState(() => isSubmitting = false);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to record return: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: isSubmitting
                              ? SizedBox(
                                  width: Responsive.w(18),
                                  height: Responsive.h(18),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Confirm & Record',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(
                                      AppSizes.fontMedium,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openKeepMoneyDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.r(AppSizes.radiusLarge)),
        ),
      ),
      builder: (sheetContext) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: Responsive.all(AppSizes.spacingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Keep Money — Confirm',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontLarge),
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  Container(
                    padding: Responsive.all(AppSizes.spacingMedium),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      border: Border.all(
                        color: Colors.teal.shade200,
                        width: AppSizes.spacingTiny / 4,
                      ),
                      borderRadius: BorderRadius.circular(
                        Responsive.r(AppSizes.radiusSmall),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No refund will be issued',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade900,
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                        Text(
                          'You are choosing to keep ₹${_currentOrder.amountPaid.toStringAsFixed(2)} from this cancelled order. This action will mark the refund as waived and the amount will remain in your revenue.',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                            color: Colors.teal.shade800,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  Container(
                    width: double.infinity,
                    padding: Responsive.all(AppSizes.spacingMedium),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: AppSizes.spacingTiny / 4,
                      ),
                      borderRadius: BorderRadius.circular(
                        Responsive.r(AppSizes.radiusSmall),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'AMOUNT TO KEEP',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny),
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondaryText,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                        Text(
                          '₹${_currentOrder.amountPaid.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontXLarge + 4),
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: Responsive.symmetric(
                              vertical: AppSizes.spacingMedium - 2,
                            ),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Responsive.r(AppSizes.radiusSmall),
                              ),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(sheetContext),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium),
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
                            padding: Responsive.symmetric(
                              vertical: AppSizes.spacingMedium - 2,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Responsive.r(AppSizes.radiusSmall),
                              ),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setSheetState(() => isSubmitting = true);
                                  try {
                                    await ref
                                        .read(orderOperationsProvider)
                                        .updateOrder(_currentOrder.id, {
                                          'payment_status': PaymentStatus.refundWaived.toJsonValue(),
                                        });
                                    if (sheetContext.mounted) {
                                      Navigator.pop(sheetContext);
                                    }
                                    await _refreshOrder();
                                    ref.invalidate(ordersProvider);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Refund marked as waived — money kept.',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setSheetState(() => isSubmitting = false);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to update refund status: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: isSubmitting
                              ? SizedBox(
                                  width: Responsive.w(18),
                                  height: Responsive.h(18),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Confirm — Keep',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(
                                      AppSizes.fontMedium,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openCancellationRefundDialog() {
    final maxRefund = _currentOrder.amountPaid;
    final amountController = TextEditingController(
      text: maxRefund.toStringAsFixed(0),
    );
    final notesController = TextEditingController(text: 'Cancellation Refund');
    String paymentMode = 'cash';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.r(AppSizes.radiusLarge)),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: Responsive.w(AppSizes.spacingLarge),
                right: Responsive.w(AppSizes.spacingLarge),
                top: Responsive.h(AppSizes.spacingLarge),
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
                    Responsive.h(AppSizes.spacingLarge),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Refund Payment',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontLarge),
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  Text(
                    'REFUND AMOUNT (₹)',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontTiny),
                      fontWeight: FontWeight.w900,
                      color: AppColors.secondaryText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontXLarge),
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.currency_rupee_rounded,
                        size: Responsive.icon(AppSizes.iconMedium),
                      ),
                      helperText:
                          'Maximum refundable: ₹${maxRefund.toStringAsFixed(2)}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                        borderSide: BorderSide(
                          color: Colors.amber.shade700,
                          width: AppSizes.spacingTiny / 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  Text(
                    'REFUND METHOD',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontTiny),
                      fontWeight: FontWeight.w900,
                      color: AppColors.secondaryText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                  DropdownButtonFormField<String>(
                    initialValue: paymentMode,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'upi', child: Text('UPI / GPay')),
                      DropdownMenuItem(
                        value: 'bank_transfer',
                        child: Text('Bank Transfer'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setSheetState(() => paymentMode = val);
                    },
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                  Text(
                    'NOTES / REF ID (OPTIONAL)',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontTiny),
                      fontWeight: FontWeight.w900,
                      color: AppColors.secondaryText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                  TextField(
                    controller: notesController,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                    ),
                    decoration: InputDecoration(
                      hintText: 'E.g. Refunded via UPI',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: Responsive.symmetric(
                              vertical: AppSizes.spacingMedium - 2,
                            ),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Responsive.r(AppSizes.radiusSmall),
                              ),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(sheetContext),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium),
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            padding: Responsive.symmetric(
                              vertical: AppSizes.spacingMedium - 2,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Responsive.r(AppSizes.radiusSmall),
                              ),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final amt =
                                      double.tryParse(amountController.text) ??
                                      0.0;
                                  if (amt <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a valid refund amount',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (amt > maxRefund) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Refund cannot exceed paid amount (₹${maxRefund.toStringAsFixed(2)})',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setSheetState(() => isSubmitting = true);
                                  try {
                                    await ref
                                        .read(orderOperationsProvider)
                                        .collectPayment(
                                          orderId: _currentOrder.id,
                                          amount: amt,
                                          paymentMode: paymentMode,
                                          paymentType: 'refund',
                                          notes: notesController.text
                                                  .trim()
                                                  .isEmpty
                                              ? 'Cancellation Refund'
                                              : notesController.text.trim(),
                                        );
                                    if (sheetContext.mounted) {
                                      Navigator.pop(sheetContext);
                                    }
                                    await _refreshOrder();
                                    ref.invalidate(ordersProvider);
                                    ref.invalidate(
                                      orderPaymentsProvider(_currentOrder.id),
                                    );
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '₹${amt.toStringAsFixed(2)} has been refunded.',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setSheetState(() => isSubmitting = false);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to process refund: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: isSubmitting
                              ? SizedBox(
                                  width: Responsive.w(18),
                                  height: Responsive.h(18),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Confirm Refund',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(
                                      AppSizes.fontMedium,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Cancel Order'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Are you sure you want to cancel this order?'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Cancellation Reason',
                        hintText: 'e.g. Customer cancelled / Event postponed',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (paidAmount > 0) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Total Paid so far: ₹${paidAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: Text('Full Refund (₹${paidAmount.toStringAsFixed(0)})'),
                            selected: refundController.text == paidAmount.toStringAsFixed(0) ||
                                refundController.text == paidAmount.toString(),
                            onSelected: (selected) {
                              if (selected) {
                                setDialogState(() {
                                  refundController.text = paidAmount.toStringAsFixed(0);
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Waive / Keep Advance (₹0)'),
                            selected: refundController.text == '0' || refundController.text == '0.0',
                            onSelected: (selected) {
                              if (selected) {
                                setDialogState(() {
                                  refundController.text = '0';
                                  if (reasonController.text.trim().isEmpty) {
                                    reasonController.text = 'Advance retained as cancellation fee';
                                  }
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: refundController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Refund Amount (₹)',
                          helperText: 'Enter 0 to retain the advance with shop',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a cancellation reason'),
                        ),
                      );
                      return;
                    }
                    final refund = double.tryParse(refundController.text) ?? 0.0;
                    Navigator.pop(dialogContext);
                    setState(() => _isLoading = true);
                    try {
                      await ref
                          .read(orderOperationsProvider)
                          .updateOrder(_currentOrder.id, {
                            'status': 'cancelled',
                            'cancellation_reason': reason,
                            if (paidAmount > 0) 'refund_amount': refund,
                          });
                      await _refreshOrder();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order cancelled successfully'),
                          ),
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
      },
    );
  }

  void _openPaymentDialog() {
    final maxCollect = _currentOrder.totalAmount - _currentOrder.amountPaid;
    final amountController = TextEditingController(
      text: maxCollect.toStringAsFixed(0),
    );
    String paymentMode = 'upi';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                    style: TextStyle(
                      fontSize: Responsive.sp(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Balance Due: ₹${maxCollect.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: Responsive.sp(12),
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: Responsive.sp(15)),
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),
                  DropdownButtonFormField<String>(
                    initialValue: paymentMode,
                    decoration: InputDecoration(
                      labelText: 'Payment Mode',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'upi', child: Text('UPI / GPay')),
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'card', child: Text('Card')),
                      DropdownMenuItem(
                        value: 'bank_transfer',
                        child: Text('Bank Transfer'),
                      ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final amt =
                            double.tryParse(amountController.text) ?? 0.0;
                        if (amt <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid amount'),
                            ),
                          );
                          return;
                        }

                        if (amt > maxCollect) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Warning: Amount exceeds balance due of ₹${maxCollect.toStringAsFixed(0)}',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(modalContext);
                        setState(() => _isLoading = true);
                        try {
                          await ref
                              .read(orderOperationsProvider)
                              .collectPayment(
                                orderId: _currentOrder.id,
                                amount: amt,
                                paymentMode: paymentMode,
                              );
                          final newAmountPaid = _currentOrder.amountPaid + amt;
                          final newPaymentStatus =
                              newAmountPaid >= _currentOrder.totalAmount
                              ? 'paid'
                              : 'partial';
                          await ref
                              .read(orderOperationsProvider)
                              .updateOrder(_currentOrder.id, {
                                'amount_paid': newAmountPaid,
                                'payment_status': newPaymentStatus,
                              });
                          await _refreshOrder();
                          ref.invalidate(
                            orderPaymentsProvider(_currentOrder.id),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Payment recorded successfully'),
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() => _isLoading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to record payment: $e'),
                              ),
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
    String initialMode = tx.paymentMode.toLowerCase();
    if (!['upi', 'gpay', 'cash', 'bank_transfer'].contains(initialMode)) {
      initialMode = 'upi';
    }
    String paymentMode = initialMode;
    final amountController = TextEditingController(text: tx.amount.toString());
    final transactionIdController =
        TextEditingController(text: tx.transactionId ?? '');
    final notesController = TextEditingController(text: tx.notes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.r(AppSizes.radiusXLarge)),
        ),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            Widget buildModeButton(Map<String, dynamic> mode) {
              final isSelected = paymentMode == mode['id'];
              final iconData = mode['icon'] as IconData;
              final label = mode['label'] as String;
              return InkWell(
                onTap: () => setModalState(() => paymentMode = mode['id'] as String),
                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                child: Container(
                  padding: Responsive.symmetric(
                    vertical: AppSizes.spacingMedium,
                    horizontal: AppSizes.spacingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(
                      Responsive.r(AppSizes.radiusSmall),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        iconData,
                        size: Responsive.icon(AppSizes.iconMedium),
                        color: isSelected ? AppColors.primary : Colors.grey[600],
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny),
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final modes = [
              {'id': 'upi', 'label': 'UPI', 'icon': Icons.qr_code_scanner_rounded},
              {'id': 'gpay', 'label': 'GPay', 'icon': Icons.account_balance_wallet_outlined},
              {'id': 'cash', 'label': 'Cash', 'icon': Icons.payments_outlined},
              {'id': 'bank_transfer', 'label': 'Bank Transfer', 'icon': Icons.account_balance_outlined},
            ];

            return Padding(
              padding: EdgeInsets.only(
                left: Responsive.w(AppSizes.screenPaddingSmall),
                right: Responsive.w(AppSizes.screenPaddingSmall),
                top: Responsive.h(AppSizes.screenPaddingSmall),
                bottom: MediaQuery.of(modalContext).viewInsets.bottom +
                    MediaQuery.of(context).padding.bottom +
                    Responsive.h(AppSizes.spacingXXLarge),
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
                          'Edit Payment',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontLarge),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: Responsive.icon(AppSizes.iconMedium),
                          ),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                    // 1. Header info card
                    Container(
                      width: double.infinity,
                      padding: Responsive.all(AppSizes.spacingLarge),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusMedium),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PAYMENT TYPE',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontTiny),
                              fontWeight: FontWeight.w900,
                              color: Colors.grey[500],
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                          Text(
                            tx.paymentType.toUpperCase(),
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                          Text(
                            'Original Amount: ₹${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontSmall),
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    // 2. Amount field
                    Text(
                      'PAYMENT AMOUNT (₹)',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[500],
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        fontSize: Responsive.sp(22),
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: Icon(
                          Icons.currency_rupee_rounded,
                          color: AppColors.primary,
                          size: Responsive.icon(AppSizes.iconMedium),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(
                            Responsive.r(AppSizes.radiusMedium),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(
                            Responsive.r(AppSizes.radiusMedium),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    // 3. Payment Mode Selection
                    Text(
                      'PAYMENT MODE',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[500],
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: buildModeButton(modes[0])),
                            SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                            Expanded(child: buildModeButton(modes[1])),
                          ],
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                        Row(
                          children: [
                            Expanded(child: buildModeButton(modes[2])),
                            SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                            Expanded(child: buildModeButton(modes[3])),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    // 4. Transaction / Ref ID Field
                    Text(
                      'TRANSACTION / REFERENCE ID (OPTIONAL)',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[500],
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                    TextField(
                      controller: transactionIdController,
                      decoration: InputDecoration(
                        hintText: 'E.g. UPI Ref # or UTR / Txn ID',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(
                            Responsive.r(AppSizes.radiusSmall),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    // 5. Notes Field
                    Text(
                      'NOTES (OPTIONAL)',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[500],
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        hintText: 'E.g. Paid via customer mobile',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(
                            Responsive.r(AppSizes.radiusSmall),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingXXLarge)),
                    // 6. Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: Responsive.symmetric(
                                vertical: AppSizes.spacingMedium,
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  Responsive.r(AppSizes.radiusSmall),
                                ),
                              ),
                            ),
                            onPressed: () => Navigator.pop(modalContext),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontMedium),
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: Responsive.symmetric(
                                vertical: AppSizes.spacingMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  Responsive.r(AppSizes.radiusSmall),
                                ),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final amt =
                                  double.tryParse(amountController.text) ?? 0.0;
                              if (amt <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a valid amount'),
                                  ),
                                );
                                return;
                              }

                              Navigator.pop(modalContext);
                              setState(() => _isLoading = true);
                              try {
                                if (tx.id.startsWith('virtual-')) {
                                  await ref
                                      .read(orderOperationsProvider)
                                      .collectPayment(
                                        orderId: _currentOrder.id,
                                        amount: amt,
                                        paymentMode: paymentMode,
                                        paymentType: tx.paymentType,
                                        notes: notesController.text.trim(),
                                      );
                                } else {
                                  await ref
                                      .read(orderOperationsProvider)
                                      .updatePayment(
                                        paymentId: tx.id,
                                        amount: amt,
                                        paymentMode: paymentMode,
                                        transactionId: transactionIdController.text.trim().isNotEmpty
                                            ? transactionIdController.text.trim()
                                            : null,
                                        notes: notesController.text.trim(),
                                      );
                                }
                                await _refreshOrder();
                                ref.invalidate(
                                  orderPaymentsProvider(_currentOrder.id),
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        tx.id.startsWith('virtual-')
                                            ? 'Payment record created successfully'
                                            : 'Transaction updated successfully',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setState(() => _isLoading = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to update transaction: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontMedium),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!tx.id.startsWith('virtual-')) ...[
                      SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: Responsive.symmetric(
                              vertical: AppSizes.spacingSmall,
                            ),
                          ),
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: Responsive.icon(AppSizes.iconSmall),
                          ),
                          label: Text(
                            'Delete Payment Record',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontSmall),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Delete Payment Record'),
                                content: const Text(
                                  'Are you sure you want to delete this payment record? This action will update the order\'s financial balance and status, and cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              Navigator.pop(modalContext);
                              setState(() => _isLoading = true);
                              try {
                                await ref
                                    .read(orderOperationsProvider)
                                    .deletePayment(tx.id);
                                await _refreshOrder();
                                ref.invalidate(
                                  orderPaymentsProvider(_currentOrder.id),
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Payment record deleted successfully',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setState(() => _isLoading = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to delete payment: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ],
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete order: $e')));
        }
      }
    }
  }

  Color _getTransactionTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
      case 'advance':
        return Colors.teal;
      case 'final':
        return Colors.green;
      case 'refund':
        return Colors.red;
      case 'adjustment':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _formatStatusName(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.scheduled:
        return 'Scheduled';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.inUse:
        return 'In Use';
      case OrderStatus.ongoing:
        return 'Ongoing';
      case OrderStatus.partial:
        return 'Partial';
      case OrderStatus.returned:
        return 'Returned';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.flagged:
        return 'Flagged';
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

  void _showShareBottomSheet() {
    final customerName = _currentOrder.customer?.name ?? 'Customer';
    final customerPhone = _currentOrder.customer?.phone ?? '';
    final orderIdShort = _currentOrder.id.length > 8
        ? _currentOrder.id.substring(0, 8)
        : _currentOrder.id;
    final startDate = _formatDate(_currentOrder.startDate);
    final endDate = _formatDate(_currentOrder.endDate);

    String message = '';
    switch (_currentOrder.status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
      case OrderStatus.scheduled:
        message =
            'Hi $customerName, this is regarding your upcoming order #$orderIdShort scheduled for $startDate. Please confirm your availability.';
        break;
      case OrderStatus.ongoing:
      case OrderStatus.inUse:
        message =
            'Hi $customerName, your order #$orderIdShort is currently active. Please remember to return by $endDate.';
        break;
      case OrderStatus.partial:
        message =
            'Hi $customerName, your order #$orderIdShort has partial returns pending. Please complete the return process.';
        break;
      case OrderStatus.delivered:
        message =
            'Hi $customerName, your order #$orderIdShort has been delivered. Enjoy your event! Please return by $endDate.';
        break;
      case OrderStatus.returned:
        message =
            'Hi $customerName, thank you for returning your order #$orderIdShort. We hope you had a great experience!';
        break;
      case OrderStatus.completed:
        message =
            'Hi $customerName, your order #$orderIdShort has been completed. Thank you for choosing Mazhavil Dance Costumes!';
        break;
      case OrderStatus.cancelled:
        message =
            'Hi $customerName, your order #$orderIdShort has been cancelled. Contact us if you need assistance.';
        break;
      case OrderStatus.flagged:
        message =
            'Hi $customerName, there is an issue with your order #$orderIdShort. Please contact us immediately.';
        break;
    }

    final apiBaseUrl = apiClient.dio.options.baseUrl;
    final finalInvoiceUrl =
        '$apiBaseUrl/orders/${_currentOrder.id}/invoice?type=final';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.r(AppSizes.radiusXXLarge)),
        ),
      ),
      builder: (modalContext) {
        return Padding(
          padding: Responsive.all(AppSizes.screenPaddingSmall),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Share Invoice & Status',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontLarge),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: Responsive.icon(AppSizes.iconMedium),
                      color: AppColors.secondaryText,
                    ),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                ],
              ),
              const Divider(color: AppColors.border),
              SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
              _buildShareOptionItem(
                context: modalContext,
                icon: Icons.picture_as_pdf_rounded,
                iconColor: AppColors.primary,
                title: 'Share Invoice (PDF)',
                subtitle: 'Download and share PDF invoice',
                onTap: () {
                  Navigator.pop(modalContext);
                  _downloadAndShareInvoice(type: 'final');
                },
              ),
              _buildShareOptionItem(
                context: modalContext,
                icon: Icons.message_rounded,
                iconColor: const Color(0xFF25D366), // WhatsApp Green
                title: 'WhatsApp Customer',
                subtitle: 'Send order status update to customer',
                onTap: () async {
                  Navigator.pop(modalContext);
                  if (customerPhone.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Customer phone number is empty'),
                        ),
                      );
                    }
                    return;
                  }

                  String formattedPhone = customerPhone.replaceAll(
                    RegExp(r'\D'),
                    '',
                  );
                  if (formattedPhone.length == 10) {
                    formattedPhone = '91$formattedPhone';
                  }

                  final whatsappUrl = Uri.parse(
                    'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}',
                  );
                  try {
                    await launchUrl(
                      whatsappUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    try {
                      await launchUrl(
                        whatsappUrl,
                        mode: LaunchMode.platformDefault,
                      );
                    } catch (e2) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not launch WhatsApp: $e2'),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              _buildShareOptionItem(
                context: modalContext,
                icon: Icons.copy_rounded,
                iconColor: AppColors.secondaryText,
                title: 'Copy Invoice URL',
                subtitle: 'Copy link to clipboard',
                onTap: () async {
                  Navigator.pop(modalContext);
                  await Clipboard.setData(ClipboardData(text: finalInvoiceUrl));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invoice URL copied to clipboard'),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadAndShareInvoice({
    required String type,
    String? shareText,
  }) async {
    // Show a loading indicator dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Center(
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                Responsive.r(AppSizes.radiusMedium),
              ),
            ),
            child: Padding(
              padding: Responsive.all(AppSizes.screenPaddingSmall),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  Text(
                    'Generating Invoice PDF...',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final response = await apiClient.dio.get<List<int>>(
        '/orders/${_currentOrder.id}/invoice',
        queryParameters: {'type': type},
        options: Options(responseType: ResponseType.bytes),
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (response.data != null) {
        final tempDir = await getTemporaryDirectory();
        final fileName =
            'Invoice_${_currentOrder.id.substring(0, 8).toUpperCase()}_$type.pdf';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.data!);

        final xFile = XFile(file.path);
        await Share.shareXFiles(
          [xFile],
          text:
              shareText ??
              'Invoice ($type) for order #${_currentOrder.id.substring(0, 8).toUpperCase()}',
        );
      } else {
        throw Exception('No data received from server');
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share invoice: $e')));
      }
    }
  }

  Widget _buildShareOptionItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
      child: Padding(
        padding: Responsive.symmetric(
          horizontal: AppSizes.spacingSmall,
          vertical: AppSizes.spacingMedium,
        ),
        child: Row(
          children: [
            Container(
              padding: Responsive.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: Responsive.icon(AppSizes.iconMedium),
                color: iconColor,
              ),
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontSmall),
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: Responsive.icon(AppSizes.iconMedium),
              color: AppColors.secondaryText.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
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
