import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/responsive.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final double? height;
  final double? width;
  final double? borderRadius;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final ButtonSize? size;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.height,
    this.width,
    this.borderRadius,
    this.icon,
    this.padding,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    
    final effectiveHeight = height ?? _getHeightForSize();
    final effectiveRadius = borderRadius ?? AppSizes.radiusMedium;
    final effectiveBgColor = backgroundColor ?? AppColors.primary;
    final effectiveFgColor = foregroundColor ?? Colors.white;
    final effectiveDisabledBgColor = disabledBackgroundColor ?? Colors.grey[400];

    return SizedBox(
      height: Responsive.h(effectiveHeight),
      width: width,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          foregroundColor: effectiveFgColor,
          disabledBackgroundColor: effectiveDisabledBgColor,
          elevation: 0,
          padding: padding ?? Responsive.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.r(effectiveRadius)),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: Responsive.icon(AppSizes.iconSmall),
                width: Responsive.icon(AppSizes.iconSmall),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: Responsive.icon(AppSizes.iconSmall)),
                    SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  double _getHeightForSize() {
    switch (size) {
      case ButtonSize.small:
        return AppSizes.buttonSmall;
      case ButtonSize.medium:
        return AppSizes.buttonMedium;
      case ButtonSize.large:
        return AppSizes.buttonLarge;
      case ButtonSize.xLarge:
        return AppSizes.buttonXLarge;
      default:
        return AppSizes.buttonLarge;
    }
  }
}

enum ButtonSize { small, medium, large, xLarge }
