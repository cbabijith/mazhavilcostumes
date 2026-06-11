part of '../order_form_view.dart';

extension _OrderFormCartItemsSection on _OrderFormViewState {
  Widget _buildBookingRow(dynamic b) {
    final String customerName = b['customerName'] as String? ?? 'Unknown';
    final int qty = b['quantity'] as int? ?? 1;
    final String startStr = b['startDate'] as String? ?? '';
    final String endStr = b['endDate'] as String? ?? '';
    final String? bufferStart = b['bufferStartDate'] as String?;
    final String? bufferEnd = b['bufferEndDate'] as String?;
    final bool bufferSkipped = b['bufferSkipped'] as bool? ?? false;

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

    final dateRange = '${formatDt(startStr)} – ${formatDt(endStr)}';

    return Container(
      padding: Responsive.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$customerName — $qty ${qty > 1 ? 'units' : 'unit'}',
                  style: TextStyle(
                    fontSize: Responsive.sp(11),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                dateRange,
                style: TextStyle(
                  fontSize: Responsive.sp(10),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (bufferStart != null && bufferEnd != null) ...[
            SizedBox(height: Responsive.h(2)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bufferSkipped
                      ? 'Gap: Skipped (Priority Cleaning ON)'
                      : 'Gap: ${formatDt(bufferStart)} & ${formatDt(bufferEnd)}',
                  style: TextStyle(
                    fontSize: Responsive.sp(9),
                    color: bufferSkipped
                        ? Colors.grey.shade400
                        : AppColors.warning,
                    fontWeight: FontWeight.bold,
                    decoration: bufferSkipped
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemCard(OrderItemInput item, int index) {
    return Container(
      margin: Responsive.only(bottom: 12),
      padding: Responsive.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(12)),
        border: Border.all(
          color: item.isAvailable
              ? Colors.transparent
              : AppColors.error.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Costume #${index + 1}',
                style: TextStyle(
                  fontSize: Responsive.sp(12),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error.withValues(alpha: 0.8),
                  size: Responsive.icon(20),
                ),
                onPressed: () => _removeItem(index),
              ),
            ],
          ),
          Container(
            padding: Responsive.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(Responsive.r(8)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.primary,
                  size: Responsive.icon(20),
                ),
                SizedBox(width: Responsive.w(8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Costume Product',
                        style: TextStyle(
                          fontSize: Responsive.sp(10),
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: Responsive.h(2)),
                      Text(
                        item.productName,
                        style: TextStyle(
                          fontSize: Responsive.sp(14),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(12)),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.quantity.toString(),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: Responsive.sp(14)),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    contentPadding: Responsive.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (val) {
                    _update(() {
                      item.quantity = int.tryParse(val) ?? 1;
                    });
                    _calculateTotals();
                    _checkItemAvailability(index);
                  },
                ),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: TextFormField(
                  key: ValueKey('rate_$index'),
                  initialValue: item.pricePerDay.toStringAsFixed(0),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: Responsive.sp(14)),
                  decoration: InputDecoration(
                    labelText: 'Rate/day (₹)',
                    contentPadding: Responsive.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (val) {
                    _update(() {
                      item.pricePerDay = double.tryParse(val) ?? 0.0;
                    });
                    _calculateTotals();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(12)),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.discount == 0.0
                      ? ''
                      : item.discount.toStringAsFixed(0),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: Responsive.sp(14)),
                  decoration: InputDecoration(
                    labelText: 'Item Discount',
                    hintText: '0',
                    contentPadding: Responsive.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (val) {
                    _update(() {
                      item.discount = double.tryParse(val) ?? 0.0;
                    });
                    _calculateTotals();
                  },
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              Container(
                height: Responsive.h(48),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDiscountTypeToggleButton(
                      label: '₹',
                      isSelected: item.discountType == 'flat',
                      onTap: () {
                        _update(() {
                          item.discountType = 'flat';
                        });
                        _calculateTotals();
                      },
                    ),
                    Container(
                      width: 1,
                      color: Colors.grey.shade300,
                      height: Responsive.h(24),
                    ),
                    _buildDiscountTypeToggleButton(
                      label: '%',
                      isSelected: item.discountType == 'percent',
                      onTap: () {
                        _update(() {
                          item.discountType = 'percent';
                        });
                        _calculateTotals();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Live Availability Badge
          if (item.productId.isNotEmpty) ...[
            SizedBox(height: Responsive.h(8)),
            Container(
              padding: Responsive.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: item.isChecking
                    ? Colors.grey.shade50
                    : (item.isAvailable
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1)),
                border: Border.all(
                  color: item.isChecking
                      ? Colors.grey.shade200
                      : (item.isAvailable
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.error.withValues(alpha: 0.2)),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  if (item.isChecking) ...[
                    SizedBox(
                      width: Responsive.w(12),
                      height: Responsive.w(12),
                      child: const CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: Responsive.w(6)),
                    Text(
                      'Checking availability...',
                      style: TextStyle(
                        fontSize: Responsive.sp(11),
                        color: Colors.grey,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      item.isAvailable
                          ? Icons.check_circle_outline_rounded
                          : Icons.error_outline_rounded,
                      color: item.isAvailable
                          ? AppColors.success
                          : AppColors.error,
                      size: Responsive.icon(16),
                    ),
                    SizedBox(width: Responsive.w(6)),
                    Expanded(
                      child: Text(
                        item.isAvailable
                            ? '${item.available} of ${item.availableWithPriority} free for this period${item.priorityCleaningNeeded ? ' (with priority cleaning)' : ''}'
                            : 'Unavailable — only ${item.available} free (need ${item.quantity})',
                        style: TextStyle(
                          fontSize: Responsive.sp(11),
                          fontWeight: FontWeight.bold,
                          color: item.isAvailable
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          // Auto Priority Cleaning Warning Banner
          if (item.productId.isNotEmpty &&
              item.priorityCleaningNeeded &&
              item.quantity > item.available) ...[
            SizedBox(height: Responsive.h(8)),
            Container(
              padding: Responsive.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flash_on_rounded,
                        color: AppColors.warning,
                        size: Responsive.icon(16),
                      ),
                      SizedBox(width: Responsive.w(4)),
                      Expanded(
                        child: Text(
                          '${item.available} freely available, need ${item.quantity - item.available} via priority cleaning',
                          style: TextStyle(
                            fontSize: Responsive.sp(11),
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...(() {
                    final neededExtra = item.quantity - item.available;
                    int accumulated = 0;
                    final List<Widget> list = [];
                    for (final info in item.priorityCleaningInfo) {
                      if (accumulated >= neededExtra) break;
                      final returningQuantity =
                          info['returningQuantity'] as int? ?? 0;
                      final useFromThis =
                          returningQuantity < (neededExtra - accumulated)
                          ? returningQuantity
                          : (neededExtra - accumulated);

                      final String direction =
                          info['direction'] as String? ?? '';
                      final String customer =
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

                      Widget textWidget;
                      if (direction == 'returning_before') {
                        final returningDate =
                            info['returningOrderEndDate'] as String? ?? '';
                        textWidget = Text(
                          '⚡ $useFromThis units — rush-clean from $customer (returning ${formatDt(returningDate)})',
                          style: TextStyle(
                            fontSize: Responsive.sp(10),
                            color: AppColors.warning,
                          ),
                        );
                      } else {
                        final pickupDate =
                            info['returningOrderStartDate'] as String? ?? '';
                        textWidget = Text(
                          '⚡ $useFromThis units — skip prep for $customer (pickup ${formatDt(pickupDate)})',
                          style: TextStyle(
                            fontSize: Responsive.sp(10),
                            color: AppColors.warning,
                          ),
                        );
                      }

                      list.add(
                        Padding(
                          padding: Responsive.only(top: 4, left: 20),
                          child: textWidget,
                        ),
                      );
                      accumulated += useFromThis;
                    }
                    return list;
                  }()),
                ],
              ),
            ),
          ],
          // Existing Bookings Section
          if (item.productId.isNotEmpty &&
              item.overlappingOrders.isNotEmpty) ...[
            SizedBox(height: Responsive.h(8)),
            StatefulBuilder(
              builder: (context, setStateBuilder) {
                final isExpanded = _expandedBookings.contains(item.productId);
                final firstBooking = item.overlappingOrders.first;
                final remainingCount = item.overlappingOrders.length - 1;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EXISTING BOOKINGS',
                          style: TextStyle(
                            fontSize: Responsive.sp(10),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (remainingCount > 0)
                          GestureDetector(
                            onTap: () {
                              _update(() {
                                if (isExpanded) {
                                  _expandedBookings.remove(item.productId);
                                } else {
                                  _expandedBookings.add(item.productId);
                                }
                              });
                              setStateBuilder(() {});
                            },
                            child: Row(
                              children: [
                                Text(
                                  isExpanded
                                      ? 'Collapse'
                                      : '+$remainingCount more',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(10),
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: Responsive.icon(14),
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(4)),
                    _buildBookingRow(firstBooking),
                    if (isExpanded)
                      ...item.overlappingOrders
                          .skip(1)
                          .map(
                            (b) => Padding(
                              padding: Responsive.only(top: 4),
                              child: _buildBookingRow(b),
                            ),
                          ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
