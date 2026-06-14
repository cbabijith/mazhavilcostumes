import 'package:flutter/material.dart';

/// Mazhavil Costumes Brand Constants
class AppColors {
  static const Color primary = Color(0xFF059669); // Green
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color scaffoldBackground = Color(0xFFF9FAFB); // Slate/Grey 50 for page background contrast
  static const Color text = Color(0xFF111827); // Dark text
  static const Color secondaryText = Color(0xFF6B7280); // Gray text
  static const Color border = Color(0xFFE5E7EB); // Light border
  static const Color error = Color(0xFFEF4444); // Red
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF3B82F6); // Blue
}

class AppStrings {
  static const String appName = 'Mazhavil costumes';
  static const String adminDashboard = 'Admin Dashboard';
  static const String signIn = 'Sign In';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String enterYourEmail = 'Enter your email';
  static const String enterYourPassword = 'Enter your password';
  static const String pleaseEnterYourEmail = 'Please enter your email';
  static const String pleaseEnterAValidEmail = 'Please enter a valid email';
  static const String pleaseEnterYourPassword = 'Please enter your password';
  static const String passwordMustBeAtLeast6Characters = 'Password must be at least 6 characters';
  static const String invalidCredentials = 'Invalid credentials. Please try again.';
  static const String copyright = '© 2025 Mazhavil costumes';
  
  // Dashboard strings
  static const String todaysOverview = "Today's Overview";
  static const String pendingTasks = 'Pending Tasks';
  static const String allOperations = 'All Operations';
  static const String quickActions = 'Quick Actions';
  static const String newOrder = 'New Order';
  static const String newCustomer = 'New Customer';
  static const String newProduct = 'New Product';
  static const String unableToLoadDashboard = 'Unable to load dashboard';
  static const String retry = 'Retry';

  // Analytics strings
  static const String revenueAnalytics = 'Revenue & Analytics';
  static const String bookingSales = 'Booking Sales';
  static const String bookingSalesDesc = 'Total value of orders booked';
  static const String amountCollection = 'Amount Collection';
  static const String amountCollectionDesc = 'Actual cash flow received';
  static const String collectionTrends = 'Collection Trends';
  static const String collectionTrendsDesc = 'Daily cash flow breakdown';
  static const String realizedIncome = 'Realized Income';
  static const String realizedIncomeDesc = 'Revenue from fully returned orders';
  static const String activeBalance = 'Active Balance';
  static const String activeBalanceDesc = 'Uncollected from active rentals';
  static const String futureAdvances = 'Future Advances';
  static const String futureAdvancesDesc = 'Advances for upcoming bookings';
  static const String dueFromReturned = 'Due from Returned';
  static const String dueFromReturnedDesc = 'Unpaid balance for returned items';
  static const String cancellations = 'Cancellations';
  static const String overdueReturns = 'Overdue Returns';
  static const String overdueOrdersDesc = 'orders past return date';
  static const String categoryRevenue = 'Category Revenue';
  static const String categoryRevenueDesc = 'Revenue distribution by category';
  static const String bookingVelocity = 'Booking Velocity';
  static const String bookingVelocityDesc = 'Upcoming 15 days pickups';
  static const String topPerformers = 'Top Performers';
  static const String topPerformersDesc = 'Highest revenue products';
  static const String deadStock = 'Dead Stock (90+ Days)';
  static const String operationalBottlenecks = 'Operational Bottlenecks';
  static const String operationalBottlenecksDesc = 'Items stuck in process preventing revenue';
  static const String noBottlenecks = 'No active bottlenecks! Everything is running smoothly.';
  static const String noDataForPeriod = 'No data for this period';
  static const String noDeadStock = 'No dead stock detected';
  static const String noCategoryData = 'No category data';
  static const String cash = 'Cash';
  static const String upi = 'UPI';
  static const String gpay = 'GPay';
  static const String bank = 'Bank';
  static const String vs = 'vs';
  static const String pickups = 'pickups';
}

/// Dynamic Size Constants - These are base values that get scaled by Responsive utility
class AppSizes {
  // Font Sizes (base values, will be scaled by Responsive.sp)
  static const double fontTiny = 10;
  static const double fontSmall = 12;
  static const double fontMedium = 14;
  static const double fontLarge = 16;
  static const double fontXLarge = 18;
  static const double fontXXLarge = 20;
  static const double fontXXXLarge = 24;
  static const double fontHuge = 28;
  static const double fontMassive = 32;

  // Spacing (base values, will be scaled by Responsive methods)
  static const double spacingTiny = 4;
  static const double spacingSmall = 8;
  static const double spacingMedium = 12;
  static const double spacingLarge = 16;
  static const double spacingXLarge = 20;
  static const double spacingXXLarge = 24;
  static const double spacingXXXLarge = 32;
  static const double spacingHuge = 40;
  static const double spacingMassive = 48;

  // Border Radius (base values, will be scaled by Responsive.r)
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 20;
  static const double radiusXXLarge = 24;

  // Icon Sizes (base values, will be scaled by Responsive.icon)
  static const double iconTiny = 16;
  static const double iconSmall = 20;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double iconXLarge = 40;
  static const double iconXXLarge = 48;
  static const double iconHuge = 56;

  // Button Heights (base values, will be scaled by Responsive.h)
  static const double buttonSmall = 40;
  static const double buttonMedium = 48;
  static const double buttonLarge = 52;
  static const double buttonXLarge = 56;

  // Screen Padding (base values, will be scaled by Responsive methods)
  static const double screenPaddingSmall = 16;
  static const double screenPaddingMedium = 20;
  static const double screenPaddingLarge = 24;
}

/// Dashboard-specific constants
class DashboardConstants {
  // Responsive percentages for dashboard
  static const double cardHeightPercent = 0.30; // 30% of screen width
  static const double iconSizePercent = 0.16; // 16% of screen width
  static const double cardSpacingPercent = 0.07; // 7% of screen width
  static const double cardBottomMarginPercent = 0.03; // 3% of screen width
  static const double sectionSpacingPercent = 0.03; // 3% of screen width
  static const double screenPaddingPercent = 0.025; // 2.5% of screen width
  
  // Gradient opacity values
  static const double gradientTopLeftOpacity = 0.0375;
  static const double gradientMidOpacity = 0.02;
  static const double gradientBottomOpacity = 0.005;
  
  // Mesh texture settings
  static const double meshGridSize = 40.0;
  static const double meshPaintOpacity = 0.03;
  static const double meshDotPaintOpacity = 0.05;
  static const double meshDotRadius = 2.0;
}

/// Helper methods to get scaled sizes dynamically
class AppDimensions {
  /// Get scaled font size
  static double fontSize(double size) => size; // Will be used with Responsive.sp
  
  /// Get scaled height
  static double height(double size) => size; // Will be used with Responsive.h
  
  /// Get scaled width
  static double width(double size) => size; // Will be used with Responsive.w
  
  /// Get scaled radius
  static double radius(double size) => size; // Will be used with Responsive.r
  
  /// Get scaled icon size
  static double iconSize(double size) => size; // Will be used with Responsive.icon
}
