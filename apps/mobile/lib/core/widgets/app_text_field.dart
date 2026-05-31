import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/responsive.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final int? maxLength;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorColor,
    this.borderRadius,
    this.contentPadding,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    
    final effectiveFillColor = fillColor ?? AppColors.background;
    final effectiveBorderColor = borderColor ?? AppColors.border;
    final effectiveFocusedBorderColor = focusedBorderColor ?? AppColors.primary;
    final effectiveErrorColor = errorColor ?? AppColors.error;
    final effectiveRadius = borderRadius ?? AppSizes.radiusMedium;
    final effectivePadding = contentPadding ?? 
        Responsive.symmetric(horizontal: AppSizes.spacingLarge, vertical: AppSizes.spacingLarge);
    final effectiveStyle = style ?? TextStyle(
      fontSize: Responsive.sp(AppSizes.fontMedium),
      color: AppColors.text,
    );
    final effectiveLabelStyle = labelStyle ?? TextStyle(
      color: AppColors.secondaryText,
      fontSize: Responsive.sp(AppSizes.fontSmall),
    );
    final effectiveHintStyle = hintStyle ?? TextStyle(
      color: AppColors.secondaryText,
      fontSize: Responsive.sp(AppSizes.fontMedium),
    );

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      maxLines: maxLines,
      maxLength: maxLength,
      readOnly: readOnly,
      onTap: onTap,
      style: effectiveStyle,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null 
            ? Icon(prefixIcon, size: Responsive.icon(AppSizes.iconSmall), color: AppColors.secondaryText)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: effectiveFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.r(effectiveRadius)),
          borderSide: BorderSide(color: effectiveBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.r(effectiveRadius)),
          borderSide: BorderSide(color: effectiveBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.r(effectiveRadius)),
          borderSide: BorderSide(color: effectiveFocusedBorderColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.r(effectiveRadius)),
          borderSide: BorderSide(color: effectiveErrorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.r(effectiveRadius)),
          borderSide: BorderSide(color: effectiveErrorColor, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.r(effectiveRadius)),
          borderSide: BorderSide(color: effectiveBorderColor.withValues(alpha: 0.5)),
        ),
        labelStyle: effectiveLabelStyle,
        hintStyle: effectiveHintStyle,
        contentPadding: effectivePadding,
        counterText: maxLength != null ? '' : null,
      ),
    );
  }
}
