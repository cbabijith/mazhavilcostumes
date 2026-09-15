/// Local order fixtures for return-flow tests; no live customer data is used.
library;

import 'package:mobile/features/orders/models/order.dart';

Order returnOrder({
  String status = 'ongoing',
  double total = 150,
  double paid = 100,
  double discount = 70,
  double damage = 0,
  double late = 0,
  String? condition,
  bool returned = false,
  int quantity = 1,
  int? returnedQuantity,
}) => Order.fromJson({
  'id': 'test-order',
  'invoice_number': 'TEST-RETURN',
  'status': status,
  'start_date': '2026-09-12',
  'end_date': '2026-09-13',
  'event_date': '2026-09-12',
  'created_at': '2026-09-10T12:00:00Z',
  'total_amount': total,
  'amount_paid': paid,
  'advance_amount': paid,
  'discount': discount,
  'damage_charges_total': damage,
  'late_fee': late,
  'customer': {'id': 'test-customer', 'name': 'Example customer', 'phone': ''},
  'items': [
    {
      'id': 'test-item',
      'product_id': 'test-product',
      'order_id': 'test-order',
      'quantity': quantity,
      'price_per_day': 420,
      'discount': 200,
      'subtotal': 420,
      'base_amount': 141.51,
      'gst_amount': 8.49,
      'damage_charges': damage,
      'damaged_quantity': damage > 0 ? 1 : 0,
      'condition_rating': condition,
      'is_returned': returned,
      'returned_quantity': returnedQuantity,
      'product': {'id': 'test-product', 'name': 'Test costume', 'images': []},
    },
  ],
});
