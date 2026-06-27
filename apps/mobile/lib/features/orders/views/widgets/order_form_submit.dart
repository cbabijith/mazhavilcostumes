part of '../order_form_view.dart';

extension _OrderFormSubmit on _OrderFormViewState {
  Future<void> _submit() async {
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a customer')));
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 item')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    // Date validation: return date cannot be before pickup date
    final startVal = _parseDisplayDate(_startDateController.text);
    final endVal = _parseDisplayDate(_endDateController.text);
    if (startVal != null && endVal != null) {
      if (endVal.isBefore(startVal)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Return date cannot be earlier than pickup date'),
          ),
        );
        return;
      }
    }

    // Check conflict warning
    final hasConflicts = _items.any((i) => !i.isAvailable);
    if (hasConflicts) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Stock Conflicts Detected'),
          content: const Text(
            'Some items do not have enough availability for these dates. Proceed anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text('Proceed'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    // Check priority cleaning items flow (only for new orders)
    final List<OrderItemInput> priorityItems = _items.where((item) {
      return item.productId.isNotEmpty &&
          item.priorityCleaningNeeded &&
          item.quantity > item.available;
    }).toList();

    bool confirmPriority = false;
    if (priorityItems.isNotEmpty && widget.order == null) {
      final List<Map<String, dynamic>> infoList = [];
      for (final item in priorityItems) {
        final neededExtra = item.quantity - item.available;
        if (neededExtra <= 0) continue;

        int accumulated = 0;
        for (final info in item.priorityCleaningInfo) {
          if (accumulated >= neededExtra) break;
          final returningQuantity = info['returningQuantity'] as int? ?? 0;
          final useFromThis = returningQuantity < (neededExtra - accumulated)
              ? returningQuantity
              : (neededExtra - accumulated);

          infoList.add({
            'productName': item.productName,
            'direction': info['direction'],
            'usedQuantity': useFromThis,
            'returningQuantity': returningQuantity,
            'returningOrderCustomer': info['returningOrderCustomer'],
            'returningOrderEndDate': info['returningOrderEndDate'],
            'returningOrderStartDate': info['returningOrderStartDate'],
          });
          accumulated += useFromThis;
        }
      }

      if (!mounted) return;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.flash_on_rounded,
                  color: AppColors.warning,
                  size: Responsive.icon(24),
                ),
                SizedBox(width: Responsive.w(8)),
                Text(
                  'Priority Cleaning Required',
                  style: TextStyle(
                    fontSize: Responsive.sp(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'The following products need priority cleaning to fulfill this order. Staff will be notified in the Cleaning Queue.',
                    style: TextStyle(
                      fontSize: Responsive.sp(12),
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: infoList.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: Responsive.h(6)),
                      itemBuilder: (context, i) {
                        final info = infoList[i];
                        final productName = info['productName'] as String;
                        final direction = info['direction'] as String;
                        final usedQty = info['usedQuantity'] as int;
                        final returningQty = info['returningQuantity'] as int;
                        final customer =
                            info['returningOrderCustomer'] as String? ??
                            'Unknown';

                        String formatDt(String d) {
                          if (d.isEmpty) return '';
                          try {
                            final date = DateTime.parse(d);
                            final months = [
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec',
                            ];
                            return '${months[date.month - 1]} ${date.day}';
                          } catch (_) {
                            return d;
                          }
                        }

                        String desc = '';
                        if (direction == 'returning_before') {
                          final returningDate =
                              info['returningOrderEndDate'] as String? ?? '';
                          desc =
                              '${usedQty == returningQty ? returningQty : "$usedQty of $returningQty"} units — rush-clean from $customer (returning ${formatDt(returningDate)})';
                        } else {
                          final pickupDate =
                              info['returningOrderStartDate'] as String? ?? '';
                          desc =
                              '$usedQty ${usedQty == 1 ? 'unit' : 'units'} — skip prep for $customer (pickup ${formatDt(pickupDate)})';
                        }

                        return Container(
                          padding: Responsive.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.05),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.15),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: TextStyle(
                                  fontSize: Responsive.sp(12),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: Responsive.h(2)),
                              Text(
                                desc,
                                style: TextStyle(
                                  fontSize: Responsive.sp(11),
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: Responsive.sp(13),
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                icon: Icon(Icons.flash_on_rounded, size: Responsive.icon(16)),
                label: Text(
                  'Confirm & Create',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.sp(13),
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (proceed != true) return;
      confirmPriority = true;
    }

    _update(() => _isLoading = true);

    final double advanceAmount =
        double.tryParse(_advanceAmountController.text) ?? 0.0;

    final Map<String, dynamic> body = {
      'customer_id': _selectedCustomerId,
      'branch_id': _selectedBranchId,
      if (widget.order != null) ...{
        'start_date': _toIsoDate(_startDateController.text),
        'end_date': _toIsoDate(_endDateController.text),
      } else ...{
        'rental_start_date': _toIsoDate(_startDateController.text),
        'rental_end_date': _toIsoDate(_endDateController.text),
      },
      'event_date': _toIsoDate(_startDateController.text),
      if (_selectedDeliveryMethod != null)
        'delivery_method': _selectedDeliveryMethod!.name,
      'discount': double.tryParse(_discountController.text) ?? 0.0,
      'discount_type': _orderDiscountType,
      'advance_amount': advanceAmount,
      'advance_collected': advanceAmount > 0,
      if (advanceAmount > 0 && _advancePaymentMethod != null)
        'advance_payment_method': _advancePaymentMethod!.toJsonValue(),
      'subtotal': _subtotal,
      'gst_amount': _gstAmount,
      'total_amount': _totalAmount,
      'amount_paid': widget.order != null
          ? (double.tryParse(_amountPaidController.text) ?? advanceAmount)
          : advanceAmount,
      'payment_status': advanceAmount > 0
          ? (advanceAmount >= _totalAmount ? 'paid' : 'partial')
          : 'pending',
      'items': _items
          .where((item) => item.productId.isNotEmpty)
          .map(
            (item) => {
              'product_id': item.productId,
              'quantity': item.quantity,
              'price_per_day': item.pricePerDay,
              'original_price_per_day': item.originalPricePerDay,
              'discount': item.discount,
              'discount_type': item.discountType,
            },
          )
          .toList(),
    };

    if (_deliveryAddressController.text.trim().isNotEmpty) {
      body['delivery_address'] = _deliveryAddressController.text.trim();
    }
    if (_pickupAddressController.text.trim().isNotEmpty) {
      body['pickup_address'] = _pickupAddressController.text.trim();
    }
    if (_notesController.text.trim().isNotEmpty) {
      body['notes'] = _notesController.text.trim();
    }

    if (widget.order == null) {
      body.addAll({'priority_cleaning_confirmed': confirmPriority});
    }

    try {
      if (widget.order != null) {
        await ref
            .read(orderOperationsProvider)
            .updateOrder(widget.order!.id, body);
      } else {
        await ref.read(orderOperationsProvider).createOrder(body);
      }

      if (mounted) {
        // Selective invalidation - only invalidate list, not individual order cache
        ref.invalidate(ordersProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      _update(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving order: $e')));
      }
    }
  }
}
