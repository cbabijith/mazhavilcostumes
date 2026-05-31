import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/responsive.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.onTap,
    this.boxShadow,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    
    final effectiveBgColor = backgroundColor ?? Colors.white;
    final effectiveRadius = borderRadius ?? AppSizes.radiusMedium;
    final effectivePadding = padding ?? 
        Responsive.all(AppSizes.spacingMedium);
    final effectiveMargin = margin ?? EdgeInsets.zero;

    final card = Container(
      width: width,
      height: height,
      margin: effectiveMargin,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(Responsive.r(effectiveRadius)),
        border: border ?? (borderColor != null 
            ? Border.all(color: borderColor!)
            : null),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: Responsive.r(8),
            offset: Offset(0, Responsive.h(3)),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.r(effectiveRadius)),
        child: card,
      );
    }

    return card;
  }
}
