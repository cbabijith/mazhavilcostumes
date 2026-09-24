/// Responsive controls for units physically returning during this visit.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';

class ReturnQuantitySelector extends StatefulWidget {
  const ReturnQuantitySelector({
    super.key,
    required this.count,
    required this.outstanding,
    required this.status,
    required this.onChanged,
  });

  final int count;
  final int outstanding;
  final String? status;
  final ValueChanged<int> onChanged;

  @override
  State<ReturnQuantitySelector> createState() => _ReturnQuantitySelectorState();
}

class _ReturnQuantitySelectorState extends State<ReturnQuantitySelector> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.count.toString(),
  );

  @override
  void didUpdateWidget(ReturnQuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _controller.text = widget.count.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final missing = widget.status == 'missing';
    final buttonStyle = IconButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
      ),
      foregroundColor: AppColors.text,
      side: const BorderSide(color: AppColors.border),
    );
    final hint = missing
        ? AppStrings.stayingWithCustomer
        : widget.status != null && widget.count < widget.outstanding
        ? AppStrings.unitsStayingOut(widget.outstanding - widget.count)
        : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.returningNow,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontTiny),
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryText,
          ),
        ),
        SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
        Row(
          children: [
            IconButton.outlined(
              style: buttonStyle,
              tooltip: AppStrings.decreaseReturnQuantity,
              icon: Icon(
                Icons.remove,
                size: Responsive.icon(AppSizes.iconSmall),
              ),
              onPressed: missing || widget.count <= 0
                  ? null
                  : () => widget.onChanged(widget.count - 1),
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !missing,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontLarge),
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: Responsive.all(AppSizes.spacingSmall),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.r(AppSizes.radiusSmall),
                    ),
                  ),
                ),
                onChanged: (value) {
                  final count = (int.tryParse(value) ?? 0).clamp(
                    0,
                    widget.outstanding,
                  );
                  if (value != count.toString()) {
                    _controller.text = count.toString();
                  }
                  widget.onChanged(count);
                },
              ),
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
            IconButton.outlined(
              style: buttonStyle,
              tooltip: AppStrings.increaseReturnQuantity,
              icon: Icon(Icons.add, size: Responsive.icon(AppSizes.iconSmall)),
              onPressed: missing || widget.count >= widget.outstanding
                  ? null
                  : () => widget.onChanged(widget.count + 1),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
        Wrap(
          spacing: Responsive.w(AppSizes.spacingSmall),
          runSpacing: Responsive.h(AppSizes.spacingTiny),
          children: [
            Text(
              AppStrings.unitsOut(widget.outstanding),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontSmall),
                color: AppColors.secondaryText,
              ),
            ),
            if (hint != null)
              Text(
                hint,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontSmall),
                  color: missing ? AppColors.error : AppColors.warning,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
