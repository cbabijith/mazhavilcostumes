part of '../order_form_view.dart';

extension _OrderFormTotalsSection on _OrderFormViewState {
  Widget _buildDiscountTypeToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: Responsive.symmetric(horizontal: 16),
        height: double.infinity,
        alignment: Alignment.center,
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        child: Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(14),
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalsCard() {
    return Container(
      padding: Responsive.all(AppSizes.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(
          Responsive.r(AppSizes.radiusMedium),
        ),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontMedium),
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '₹${_subtotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontMedium),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          // Info line: items · days · rate (matching web)
          Padding(
            padding: Responsive.only(top: AppSizes.spacingTiny / 2),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: Responsive.icon(AppSizes.iconTiny - 4),
                  color: Colors.grey[400],
                ),
                SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                Expanded(
                  child: Text(
                    '${_items.where((i) => i.productId.isNotEmpty).length} ${_items.where((i) => i.productId.isNotEmpty).length == 1 ? 'item' : 'items'} · $_rentalDays days · Rate: ×${(_rentalDays - 2) > 1 ? (_rentalDays - 2) : 1}',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontTiny),
                      color: Colors.grey[400],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Item Discounts (shown only if any)
          Builder(
            builder: (_) {
              double itemDiscountTotal = 0.0;
              final pricingMultiplier = (_rentalDays - 2) > 1
                  ? (_rentalDays - 2)
                  : 1;
              for (final item in _items) {
                final lineTotal =
                    item.quantity * item.pricePerDay * pricingMultiplier;
                final itemDisc = item.discountType == 'percent'
                    ? lineTotal * (item.discount / 100)
                    : item.discount * item.quantity;
                itemDiscountTotal += itemDisc < lineTotal
                    ? itemDisc
                    : lineTotal;
              }
              if (itemDiscountTotal <= 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: Responsive.only(top: AppSizes.spacingSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: Responsive.icon(AppSizes.iconTiny - 4),
                          color: Colors.orange[600],
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                        Text(
                          'Item Discounts',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontMedium),
                            color: Colors.orange[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '−₹${itemDiscountTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontMedium),
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Order Discount (shown only if any)
          Builder(
            builder: (_) {
              final orderDiscountInput =
                  double.tryParse(_discountController.text) ?? 0.0;
              if (orderDiscountInput <= 0) {
                return const SizedBox.shrink();
              }
              // Calculate effective order discount
              double itemDiscountTotal = 0.0;
              final pricingMultiplier = (_rentalDays - 2) > 1
                  ? (_rentalDays - 2)
                  : 1;
              for (final item in _items) {
                final lineTotal =
                    item.quantity * item.pricePerDay * pricingMultiplier;
                final itemDisc = item.discountType == 'percent'
                    ? lineTotal * (item.discount / 100)
                    : item.discount * item.quantity;
                itemDiscountTotal += itemDisc < lineTotal
                    ? itemDisc
                    : lineTotal;
              }
              final afterItemDiscount = _subtotal - itemDiscountTotal;
              final orderDiscAmt = _orderDiscountType == 'percent'
                  ? afterItemDiscount * (orderDiscountInput / 100)
                  : orderDiscountInput;
              final effectiveOrderDiscount = orderDiscAmt < afterItemDiscount
                  ? orderDiscAmt
                  : afterItemDiscount;
              if (effectiveOrderDiscount <= 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: Responsive.only(top: AppSizes.spacingSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.percent_rounded,
                          size: Responsive.icon(AppSizes.iconTiny - 4),
                          color: Colors.purple[600],
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                        Text(
                          'Order Discount',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontMedium),
                            color: Colors.purple[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '−₹${effectiveOrderDiscount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontMedium),
                        fontWeight: FontWeight.w500,
                        color: Colors.purple[600],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // GST breakdown (if enabled)
          if (_isGstEnabled && _gstAmount > 0) ...[
            Padding(
              padding: Responsive.only(top: AppSizes.spacingSmall),
              child: Container(
                padding: Responsive.only(top: AppSizes.spacingSmall),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Base Amount (excl. GST)',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          '₹${(_totalAmount - _gstAmount).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: Responsive.icon(AppSizes.iconTiny - 4),
                              color: Colors.blue[600],
                            ),
                            SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                            Text(
                              'GST (included)',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontSmall),
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹${_gstAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          // Grand Total
          Padding(
            padding: Responsive.only(top: AppSizes.spacingMedium),
            child: Container(
              padding: Responsive.only(top: AppSizes.spacingMedium),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grand Total',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontLarge),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: Responsive.icon(AppSizes.iconTiny - 4),
                            color: Colors.grey[400],
                          ),
                          SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                          Text(
                            '$_rentalDays days${_isGstEnabled && _gstAmount > 0 ? ' · Incl. GST' : ''}',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontTiny),
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '₹${_totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontXXXLarge),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountAndAdvanceSection(bool isEditing) {
    return Container(
      padding: Responsive.all(AppSizes.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey.shade200),
          right: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Responsive.r(AppSizes.radiusMedium)),
          bottomRight: Radius.circular(Responsive.r(AppSizes.radiusMedium)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order Discount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.percent_rounded,
                    size: Responsive.icon(AppSizes.iconTiny),
                    color: Colors.purple[400],
                  ),
                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                  Text(
                    'Order Discount',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                ],
              ),
              Container(
                height: Responsive.h(28),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDiscountTypeToggleButton(
                      label: '₹ Flat',
                      isSelected: _orderDiscountType == 'flat',
                      onTap: () {
                        _update(() {
                          _orderDiscountType = 'flat';
                        });
                        _calculateTotals();
                      },
                    ),
                    _buildDiscountTypeToggleButton(
                      label: '% Pct',
                      isSelected: _orderDiscountType == 'percent',
                      onTap: () {
                        _update(() {
                          _orderDiscountType = 'percent';
                        });
                        _calculateTotals();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          TextFormField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontLarge),
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: _orderDiscountType == 'percent' ? '% ' : '₹ ',
              prefixStyle: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontMedium),
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
              hintText: '0',
              contentPadding: Responsive.symmetric(
                horizontal: AppSizes.spacingMedium,
                vertical: AppSizes.spacingSmall,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
              ),
            ),
            onChanged: (_) => _calculateTotals(),
          ),
          // "Saving X" feedback
          Builder(
            builder: (_) {
              final orderDiscountInput =
                  double.tryParse(_discountController.text) ?? 0.0;
              if (orderDiscountInput <= 0) {
                return const SizedBox.shrink();
              }
              double itemDiscountTotal = 0.0;
              final pricingMultiplier = (_rentalDays - 2) > 1
                  ? (_rentalDays - 2)
                  : 1;
              for (final item in _items) {
                final lineTotal =
                    item.quantity * item.pricePerDay * pricingMultiplier;
                final itemDisc = item.discountType == 'percent'
                    ? lineTotal * (item.discount / 100)
                    : item.discount * item.quantity;
                itemDiscountTotal += itemDisc < lineTotal
                    ? itemDisc
                    : lineTotal;
              }
              final afterItemDiscount = _subtotal - itemDiscountTotal;
              final orderDiscAmt = _orderDiscountType == 'percent'
                  ? afterItemDiscount * (orderDiscountInput / 100)
                  : orderDiscountInput;
              final effectiveOrderDiscount = orderDiscAmt < afterItemDiscount
                  ? orderDiscAmt
                  : afterItemDiscount;
              if (effectiveOrderDiscount <= 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: Responsive.only(top: AppSizes.spacingTiny),
                child: Text(
                  'Saving ₹${effectiveOrderDiscount.toStringAsFixed(2)} on this order',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    color: Colors.purple[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
          // Divider
          Padding(
            padding: Responsive.symmetric(vertical: AppSizes.spacingMedium),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),
          // Advance Payment
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: Responsive.icon(AppSizes.iconTiny),
                color: Colors.grey[400],
              ),
              SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
              Text(
                'Advance Payment',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontMedium),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                ),
              ),
              SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
              Text(
                '(Optional)',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontSmall),
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _advanceAmountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontLarge),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                    hintText: '0',
                    contentPadding: Responsive.symmetric(
                      horizontal: AppSizes.spacingMedium,
                      vertical: AppSizes.spacingSmall,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.r(AppSizes.radiusSmall),
                      ),
                    ),
                  ),
                  onChanged: (val) => _update(() {}),
                ),
              ),
              if ((double.tryParse(_advanceAmountController.text) ?? 0.0) >
                  0.0) ...[
                SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                SizedBox(
                  width: Responsive.w(110),
                  child: DropdownButtonFormField<PaymentMethod>(
                    initialValue: _advancePaymentMethod,
                    isDense: true,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontSmall),
                      color: Colors.grey[800],
                    ),
                    decoration: InputDecoration(
                      contentPadding: Responsive.symmetric(
                        horizontal: AppSizes.spacingSmall,
                        vertical: AppSizes.spacingSmall,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                      ),
                    ),
                    items: PaymentMethod.values.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(
                          method.name[0].toUpperCase() +
                              method.name.substring(1),
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontSmall),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => _update(() {
                      _advancePaymentMethod = val;
                    }),
                  ),
                ),
              ],
            ],
          ),
          // Advance payment feedback banners (matching web)
          Builder(
            builder: (_) {
              final advanceAmount =
                  double.tryParse(_advanceAmountController.text) ?? 0.0;
              if (advanceAmount <= 0) {
                return const SizedBox.shrink();
              }
              final exceeds = advanceAmount > _totalAmount;
              final isFullPayment = advanceAmount >= _totalAmount && !exceeds;
              return Column(
                children: [
                  SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                  if (exceeds)
                    Container(
                      padding: Responsive.symmetric(
                        horizontal: AppSizes.spacingMedium,
                        vertical: AppSizes.spacingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.05),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.15),
                        ),
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: Responsive.icon(AppSizes.iconTiny),
                            color: AppColors.error,
                          ),
                          SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                          Expanded(
                            child: Text(
                              'Advance cannot exceed grand total (₹${_totalAmount.toStringAsFixed(2)})',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontSmall),
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isFullPayment)
                    Container(
                      padding: Responsive.symmetric(
                        horizontal: AppSizes.spacingMedium,
                        vertical: AppSizes.spacingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.05),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.15),
                        ),
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: Responsive.icon(AppSizes.iconTiny),
                            color: AppColors.success,
                          ),
                          SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                          Expanded(
                            child: Text(
                              'Full payment collected — no balance due at return',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontSmall),
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: Responsive.symmetric(
                        horizontal: AppSizes.spacingMedium,
                        vertical: AppSizes.spacingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.05),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.15),
                        ),
                        borderRadius: BorderRadius.circular(
                          Responsive.r(AppSizes.radiusSmall),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: Responsive.icon(AppSizes.iconTiny),
                            color: AppColors.info,
                          ),
                          SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                          Expanded(
                            child: Text(
                              'Balance due at return: ₹${(_totalAmount - advanceAmount).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontSmall),
                                color: AppColors.info,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          // Amount paid (edit mode only)
          if (isEditing) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            TextFormField(
              controller: _amountPaidController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
              decoration: InputDecoration(
                labelText: 'Total Amount Paid (₹)',
                contentPadding: Responsive.symmetric(
                  horizontal: AppSizes.spacingMedium,
                  vertical: AppSizes.spacingSmall,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinalSummaryCard() {
    final advanceAmount = double.tryParse(_advanceAmountController.text) ?? 0.0;
    final exceeds = advanceAmount > _totalAmount;
    final hasConflicts = _items.any((i) => !i.isAvailable);
    if (advanceAmount <= 0 && !hasConflicts) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: Responsive.only(top: AppSizes.spacingSmall),
      padding: Responsive.all(AppSizes.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          Responsive.r(AppSizes.radiusMedium),
        ),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (advanceAmount > 0 && !exceeds) ...[
            Container(
              padding: Responsive.symmetric(
                horizontal: AppSizes.spacingMedium,
                vertical: AppSizes.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.05),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.15),
                ),
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Less: Advance Paid',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    '−₹${advanceAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balance Due',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontMedium),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                Text(
                  '₹${((_totalAmount - advanceAmount) > 0 ? (_totalAmount - advanceAmount) : 0.0).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontMedium),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
              ],
            ),
          ],
          if (hasConflicts) ...[
            if (advanceAmount > 0 && !exceeds)
              SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Container(
              padding: Responsive.symmetric(
                horizontal: AppSizes.spacingMedium,
                vertical: AppSizes.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.15),
                ),
                borderRadius: BorderRadius.circular(
                  Responsive.r(AppSizes.radiusSmall),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: Responsive.icon(AppSizes.iconSmall),
                    color: AppColors.error,
                  ),
                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                  Expanded(
                    child: Text(
                      'Some items are not available for the selected dates. Adjust quantities or change dates.',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        color: AppColors.error,
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
}
