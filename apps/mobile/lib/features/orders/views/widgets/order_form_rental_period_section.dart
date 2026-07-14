part of '../order_form_view.dart';

extension _OrderFormRentalPeriodSection on _OrderFormViewState {
  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(fontSize: Responsive.sp(14)),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(
          Icons.calendar_today_rounded,
          size: Responsive.icon(18),
        ),
        contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onTap: () => _selectDate(controller),
      validator: validator,
    );
  }

  Widget _buildQuickDateButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickDateButton(label: '1 Day', totalDays: 1),
          SizedBox(width: Responsive.w(6)),
          _buildQuickDateButton(label: '2 Days', totalDays: 2),
          SizedBox(width: Responsive.w(6)),
          _buildQuickDateButton(label: '3 Days', totalDays: 3),
          SizedBox(width: Responsive.w(6)),
          _buildQuickDateButton(label: '4 Days', totalDays: 4),
          SizedBox(width: Responsive.w(6)),
          _buildQuickDateButton(label: '5 Days', totalDays: 5),
        ],
      ),
    );
  }

  Widget _buildQuickDateButton({required String label, required int totalDays}) {
    final startText = _startDateController.text;
    final bool isEnabled = startText.isNotEmpty;

    bool isSelected = false;
    if (isEnabled && _endDateController.text.isNotEmpty) {
      try {
        final start = _parseDisplayDate(startText);
        final end = _parseDisplayDate(_endDateController.text);
        if (start != null && end != null) {
          final expectedEnd = start.add(Duration(days: totalDays - 1));
          isSelected =
              end.year == expectedEnd.year &&
              end.month == expectedEnd.month &&
              end.day == expectedEnd.day;
        }
      } catch (_) {}
    }

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isSelected ? const Color(0xFF0F172A) : Colors.grey.shade300,
        ),
        backgroundColor: isSelected
            ? const Color(0xFF0F172A)
            : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : Colors.grey[700],
        padding: Responsive.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: isEnabled
          ? () {
              try {
                final start = _parseDisplayDate(startText);
                if (start != null) {
                  final end = start.add(Duration(days: totalDays - 1));
                  _update(() {
                    _endDateController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(end);
                  });
                  _calculateTotals();
                  _checkAllItemsAvailability();
                }
              } catch (_) {}
            }
          : null,
      child: Text(
        label,
        style: TextStyle(
          fontSize: Responsive.sp(11),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDateWarnings() {
    final startText = _startDateController.text;
    final endText = _endDateController.text;

    if (startText.isEmpty) return const SizedBox.shrink();

    final List<Widget> warnings = [];

    // 1. Backdated warning
    try {
      final start = _parseDisplayDate(startText);
      if (start != null) {
        final today = DateTime.now();
        final todayMidnight = DateTime(today.year, today.month, today.day);
        if (start.isBefore(todayMidnight)) {
          warnings.add(
            Container(
              margin: Responsive.only(top: AppSizes.spacingSmall),
              padding: Responsive.all(AppSizes.spacingSmall),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.05),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.2),
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
                    color: AppColors.warning,
                    size: Responsive.icon(AppSizes.iconTiny),
                  ),
                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                  Expanded(
                    child: Text(
                      '⚠️ Backdated Bill: You are creating/editing an order with a pickup date in the past.',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (_) {}

    // 2. Invalid end date warning
    if (endText.isNotEmpty) {
      try {
        final start = _parseDisplayDate(startText);
        final end = _parseDisplayDate(endText);
        if (start != null && end != null) {
          if (end.isBefore(start)) {
            warnings.add(
              Container(
                margin: Responsive.only(top: AppSizes.spacingSmall),
                padding: Responsive.all(AppSizes.spacingSmall),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: Responsive.icon(AppSizes.iconTiny),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                    Expanded(
                      child: Text(
                        'Return date cannot be before the pickup date. Please choose a valid return date.',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontSmall),
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      } catch (_) {}
    }

    if (warnings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: warnings,
    );
  }
}
