import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../domain/transaction_detail.dart';
import '../viewmodels/providers/dashboard_provider.dart';

/// Detailed Transaction List Report View
class TransactionReportView extends ConsumerWidget {
  final String fromDate;
  final String toDate;
  final String? branchId;
  final String rangeLabel;

  const TransactionReportView({
    super.key,
    required this.fromDate,
    required this.toDate,
    this.branchId,
    required this.rangeLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final param = TransactionReportParam(
      fromDate: fromDate,
      toDate: toDate,
      branchId: branchId,
    );

    final reportAsync = ref.watch(transactionReportProvider(param));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.sp(AppSizes.fontLarge),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: AppSizes.spacingTiny / 4,
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: reportAsync.when(
        data: (transactions) => _buildContent(context, ref, transactions),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stack) => _buildErrorState(context, ref, error),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<TransactionDetail> transactions,
  ) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    // Dynamic totals calculation
    double totalCash = 0;
    double totalUpi = 0;
    double totalGpay = 0;
    double totalBank = 0;
    double totalRefunds = 0;
    double netTotal = 0;

    for (final tx in transactions) {
      final amount = tx.amount;
      final mode = tx.paymentMode.toLowerCase();
      final type = tx.paymentType.toLowerCase();

      netTotal += amount;

      if (type == 'refund') {
        totalRefunds += amount.abs();
      } else {
        if (mode == 'cash') {
          totalCash += amount;
        } else if (mode == 'upi') {
          totalUpi += amount;
        } else if (mode == 'gpay') {
          totalGpay += amount;
        } else if (mode.contains('bank')) {
          totalBank += amount;
        }
      }
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(
        transactionReportProvider(
          TransactionReportParam(
            fromDate: fromDate,
            toDate: toDate,
            branchId: branchId,
          ),
        ).future,
      ),
      color: AppColors.primary,
      child: ListView(
        padding: Responsive.all(AppSizes.spacingLarge),
        children: [
          // Range info sub-title
          _buildRangeHeader(),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),

          // Premium summary breakdown card
          _buildSummaryCard(
            netTotal: netTotal,
            totalCash: totalCash,
            totalUpi: totalUpi,
            totalGpay: totalGpay,
            totalBank: totalBank,
            totalRefunds: totalRefunds,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),

          // List Header
          Text(
            'Detailed Ledger (${transactions.length} Transactions)',
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontMedium),
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),

          // Transaction list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => SizedBox(
              height: Responsive.h(AppSizes.spacingSmall),
            ),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _buildTransactionItem(tx);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRangeHeader() {
    // Parse Dates for nice Indian locale styling e.g. "12 Jun, 2026"
    String formatReportDate(String dateStr) {
      try {
        final parsed = DateTime.parse(dateStr);
        return DateFormat('dd MMM, yyyy').format(parsed);
      } catch (_) {
        return dateStr;
      }
    }

    return Container(
      padding: Responsive.symmetric(
        horizontal: AppSizes.spacingMedium,
        vertical: AppSizes.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
        border: Border.all(color: AppColors.border, width: AppSizes.spacingTiny / 4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scope Range: $rangeLabel',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                Text(
                  'From ${formatReportDate(fromDate)} to ${formatReportDate(toDate)}',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontTiny),
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.date_range_rounded,
            size: Responsive.icon(AppSizes.iconMedium),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required double netTotal,
    required double totalCash,
    required double totalUpi,
    required double totalGpay,
    required double totalBank,
    required double totalRefunds,
  }) {
    return Container(
      padding: Responsive.all(AppSizes.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: Responsive.r(AppSizes.spacingSmall),
            offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Collection',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontSmall),
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryText,
                ),
              ),
              Container(
                padding: Responsive.symmetric(
                  horizontal: AppSizes.spacingSmall,
                  vertical: AppSizes.spacingTiny / 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                ),
                child: Text(
                  'RECEIVED',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontTiny - 1),
                    fontWeight: FontWeight.w900,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          AutoSizeText(
            CurrencyFormatter.formatINR(netTotal),
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontHuge),
              fontWeight: FontWeight.w900,
              color: AppColors.success,
            ),
            maxLines: 1,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          const Divider(color: AppColors.border),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          _buildSummaryRow(AppStrings.cash, totalCash, Icons.payments_outlined, AppColors.info),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          _buildSummaryRow(AppStrings.upi, totalUpi, Icons.qr_code_scanner, AppColors.primary),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          _buildSummaryRow(AppStrings.gpay, totalGpay, Icons.account_balance_wallet, AppColors.warning),
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          _buildSummaryRow(AppStrings.bank, totalBank, Icons.account_balance, AppColors.secondaryText),
          if (totalRefunds > 0) ...[
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            _buildSummaryRow('Refunds Issued', totalRefunds, Icons.history_rounded, AppColors.error, isRefund: true),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount,
    IconData icon,
    Color iconColor, {
    bool isRefund = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: Responsive.icon(AppSizes.iconTiny), color: iconColor),
        SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontSmall),
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '${isRefund ? "-" : ""}${CurrencyFormatter.formatINR(amount)}',
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontSmall),
            fontWeight: FontWeight.bold,
            color: isRefund ? AppColors.error : AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionDetail tx) {
    final isRefund = tx.paymentType.toLowerCase() == 'refund';
    final formattedAmount = CurrencyFormatter.formatINR(tx.amount.abs());

    // Formatting date
    final dateStr = DateFormat('dd MMM, hh:mm a').format(tx.date);

    return Container(
      padding: Responsive.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
        border: Border.all(color: AppColors.border, width: AppSizes.spacingTiny / 4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tx.invoiceNumber != null
                          ? 'Invoice: ${tx.invoiceNumber}'
                          : 'Order #${tx.orderId.substring(tx.orderId.length > 5 ? tx.orderId.length - 5 : 0).toUpperCase()}',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                    _buildStatusBadge(tx.status),
                  ],
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                Text(
                  tx.customerName,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontMedium),
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontTiny),
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
          // Right side
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isRefund ? "-" : "+"}$formattedAmount',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontLarge),
                  fontWeight: FontWeight.w900,
                  color: isRefund ? AppColors.error : AppColors.success,
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBadge(
                    tx.paymentType.toUpperCase(),
                    isRefund
                        ? AppColors.error.withValues(alpha: 0.1)
                        : tx.paymentType.toLowerCase() == 'advance'
                            ? AppColors.info.withValues(alpha: 0.1)
                            : AppColors.secondaryText.withValues(alpha: 0.1),
                    isRefund
                        ? AppColors.error
                        : tx.paymentType.toLowerCase() == 'advance'
                            ? AppColors.info
                            : AppColors.secondaryText,
                  ),
                  SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                  _buildBadge(
                    tx.paymentMode.toUpperCase(),
                    tx.paymentMode.toLowerCase() == 'cash'
                        ? AppColors.info.withValues(alpha: 0.1)
                        : tx.paymentMode.toLowerCase() == 'upi'
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : tx.paymentMode.toLowerCase() == 'gpay'
                                ? AppColors.warning.withValues(alpha: 0.1)
                                : AppColors.secondaryText.withValues(alpha: 0.1),
                    tx.paymentMode.toLowerCase() == 'cash'
                        ? AppColors.info
                        : tx.paymentMode.toLowerCase() == 'upi'
                            ? AppColors.primary
                            : tx.paymentMode.toLowerCase() == 'gpay'
                                ? AppColors.warning
                                : AppColors.secondaryText,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: Responsive.symmetric(
        horizontal: AppSizes.spacingSmall,
        vertical: AppSizes.spacingTiny / 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall / 2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: Responsive.sp(AppSizes.fontTiny - 1),
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor = AppColors.secondaryText.withValues(alpha: 0.1);
    Color textColor = AppColors.secondaryText;

    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'completed' || lowerStatus == 'returned') {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
    } else if (lowerStatus == 'ongoing' || lowerStatus == 'in_use' || lowerStatus == 'delivered') {
      bgColor = AppColors.info.withValues(alpha: 0.1);
      textColor = AppColors.info;
    } else if (lowerStatus == 'cancelled') {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      textColor = AppColors.error;
    }

    return _buildBadge(status.toUpperCase(), bgColor, textColor);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: Responsive.all(AppSizes.spacingHuge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: Responsive.icon(AppSizes.iconHuge),
              color: AppColors.secondaryText.withValues(alpha: 0.3),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            Text(
              'No transactions recorded yet',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontLarge),
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Text(
              'Transactions will appear here as soon as you process payments or refunds for this period.',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontMedium),
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: Responsive.all(AppSizes.spacingHuge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: Responsive.icon(AppSizes.iconHuge),
              color: AppColors.error,
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            Text(
              'Failed to load transactions',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontLarge),
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontMedium),
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(
                transactionReportProvider(
                  TransactionReportParam(
                    fromDate: fromDate,
                    toDate: toDate,
                    branchId: branchId,
                  ),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: Responsive.icon(AppSizes.iconSmall)),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: Responsive.symmetric(
                  horizontal: AppSizes.spacingLarge,
                  vertical: AppSizes.spacingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.r(AppSizes.radiusSmall),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
