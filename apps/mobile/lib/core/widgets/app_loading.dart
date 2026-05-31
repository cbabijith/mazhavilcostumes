import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/responsive.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;

  const AppLoading({
    super.key,
    this.message,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    
    final effectiveColor = color ?? AppColors.primary;
    final effectiveSize = size ?? AppSizes.iconXLarge;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: Responsive.icon(effectiveSize),
            height: Responsive.icon(effectiveSize),
            child: CircularProgressIndicator(
              color: effectiveColor,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            Text(
              message!,
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontMedium),
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const AppLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: AppLoading(message: message),
          ),
      ],
    );
  }
}
