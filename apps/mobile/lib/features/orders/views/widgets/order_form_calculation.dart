part of '../order_form_view.dart';

extension _OrderFormCalculation on _OrderFormViewState {
  void _calculateTotals() {
    // 1. Calculate rental days (inclusive counting: pickup day + return day)
    final startVal = _parseDisplayDate(_startDateController.text);
    final endVal = _parseDisplayDate(_endDateController.text);
    if (startVal != null && endVal != null) {
      try {
        final diff = endVal.difference(startVal).inDays;
        _rentalDays = diff >= 0 ? diff + 1 : 1;
      } catch (_) {
        _rentalDays = 1;
      }
    } else {
      _rentalDays = 1;
    }

    // 2. Pricing multiplier: base price covers first 3 days, each extra day adds 1x
    final pricingMultiplier = (_rentalDays - 2) > 1 ? (_rentalDays - 2) : 1;

    // 3. Sum up items
    double subtotal = 0.0;
    double itemDiscountTotal = 0.0;
    double totalGstAmount = 0.0;

    for (final item in _items) {
      final double lineTotal =
          item.quantity * item.pricePerDay * pricingMultiplier;
      final double itemDisc = item.discountType == 'percent'
          ? lineTotal * (item.discount / 100)
          : item.discount * item.quantity;
      final double effectiveDisc = itemDisc < lineTotal ? itemDisc : lineTotal;

      subtotal += lineTotal;
      itemDiscountTotal += effectiveDisc;

      final double lineAfterDiscount = lineTotal - effectiveDisc;
      final double gstRate = item.gstPercentage;

      if (_isGstEnabled && gstRate > 0) {
        final double base = lineAfterDiscount / (1 + gstRate / 100);
        final double gst = lineAfterDiscount - base;
        totalGstAmount += gst;
      }
    }

    final double afterItemDiscount = subtotal - itemDiscountTotal;

    // Order-level discount
    final double orderDiscountInput =
        double.tryParse(_discountController.text) ?? 0.0;
    final double orderDiscAmt = _orderDiscountType == 'percent'
        ? afterItemDiscount * (orderDiscountInput / 100)
        : orderDiscountInput;
    final double effectiveOrderDiscount = orderDiscAmt < afterItemDiscount
        ? orderDiscAmt
        : afterItemDiscount;

    final double afterAllDiscounts = afterItemDiscount - effectiveOrderDiscount;
    double gstAmount = totalGstAmount;

    if (effectiveOrderDiscount > 0 && afterItemDiscount > 0) {
      final double ratio = afterAllDiscounts / afterItemDiscount;
      gstAmount = totalGstAmount * ratio;
    }

    _update(() {
      _subtotal = subtotal;
      _gstAmount = gstAmount;
      _totalAmount = afterAllDiscounts;
    });
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _update(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
      _calculateTotals();
      _checkAllItemsAvailability();
    }
  }

  String _formatDisplayDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  String _toIsoDate(String displayText) {
    if (displayText.isEmpty) return '';
    try {
      final date = DateFormat('dd/MM/yyyy').parse(displayText);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return displayText;
    }
  }

  DateTime? _parseDisplayDate(String displayText) {
    if (displayText.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(displayText);
    } catch (_) {
      return null;
    }
  }
}
