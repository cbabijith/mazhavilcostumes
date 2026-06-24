class TransactionDetail {
  final DateTime date;
  final String orderId;
  final String customerName;
  final String paymentType;
  final String paymentMode;
  final double amount;
  final String status;
  final String? invoiceNumber;

  TransactionDetail({
    required this.date,
    required this.orderId,
    required this.customerName,
    required this.paymentType,
    required this.paymentMode,
    required this.amount,
    required this.status,
    this.invoiceNumber,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String? ?? json['payment_date'] as String? ?? DateTime.now().toIso8601String();
    return TransactionDetail(
      date: DateTime.tryParse(dateStr) ?? DateTime.now(),
      orderId: json['order_id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? 'Walk-in',
      paymentType: json['payment_type'] as String? ?? '',
      paymentMode: json['payment_mode'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      invoiceNumber: json['invoice_number'] as String?,
    );
  }
}
