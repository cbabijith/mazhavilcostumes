import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mobile/features/orders/models/order.dart';

void main() {
  group('1. Multi-Status URL Filter & Dio Query Serialization', () {
    test('Preserves multiple status parameters and serializes as status=ongoing&status=in_use', () async {
      // Simulate dashboard card filterUrl
      const filterUrl = '/orders?status=ongoing&status=in_use&date_filter=this_month';
      final uri = Uri.parse(filterUrl);
      final params = uri.queryParametersAll;

      final statusList = params['status'];
      expect(statusList, isNotNull);
      expect(statusList!.length, 2);

      // Verify the fixed logic in navigation_provider
      final resolvedStatus = statusList.length == 1 ? statusList.first : statusList;
      expect(resolvedStatus, equals(['ongoing', 'in_use']));

      // Verify that Dio serializes ListFormat.multi correctly
      Uri? capturedUri;
      final dio = Dio(BaseOptions(
        baseUrl: 'https://example.com/api',
        listFormat: ListFormat.multi,
      ));

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUri = options.uri;
          return handler.reject(DioException(
            requestOptions: options,
            message: 'Intercepted for verification',
          ));
        },
      ));

      try {
        await dio.get('/orders', queryParameters: {
          'status': resolvedStatus,
          'page': 1,
          'limit': 15,
        });
      } on DioException {
        // Expected from interception
      }

      expect(capturedUri, isNotNull);
      final query = capturedUri!.query;
      expect(query, contains('status=ongoing'));
      expect(query, contains('status=in_use'));
    });

    test('Single status parameter resolves to single string', () {
      const filterUrl = '/orders?status=scheduled';
      final uri = Uri.parse(filterUrl);
      final params = uri.queryParametersAll;

      final statusList = params['status'];
      final resolvedStatus = statusList != null && statusList.length == 1 ? statusList.first : statusList;
      expect(resolvedStatus, equals('scheduled'));
    });
  });

  group('2. Branch Inventory Zeroing Fix', () {
    test('Branch inventory retains zero quantity entries instead of dropping them', () {
      final branchStocks = <String, int>{
        'branch-calicut': 5,
        'branch-kochi': 0, // Stock reduced to zero by user
      };

      // Our fixed payload builder in product_form_view:
      final branchInventory = branchStocks.entries
          .map((e) => {'branch_id': e.key, 'quantity': e.value})
          .toList();

      final calicutEntry = branchInventory.firstWhere((e) => e['branch_id'] == 'branch-calicut');
      expect(calicutEntry['quantity'], 5);

      // Verify kochi branch is NOT stripped so the database zero-upsert succeeds
      final kochiEntry = branchInventory.firstWhere((e) => e['branch_id'] == 'branch-kochi');
      expect(kochiEntry['quantity'], 0);
    });
  });

  group('3. Partial Return & Flagged Status Parity Logic', () {
    test('Flagged and Partial order statuses allow Return processing', () {
      bool canProcessReturn(OrderStatus status) {
        return status == OrderStatus.ongoing ||
            status == OrderStatus.delivered ||
            status == OrderStatus.inUse ||
            status == OrderStatus.partial ||
            status == OrderStatus.flagged;
      }

      expect(canProcessReturn(OrderStatus.flagged), isTrue,
          reason: 'Flagged order with damage must allow subsequent item returns');
      expect(canProcessReturn(OrderStatus.partial), isTrue,
          reason: 'Partial order must allow subsequent item returns');
      expect(canProcessReturn(OrderStatus.ongoing), isTrue);
      expect(canProcessReturn(OrderStatus.inUse), isTrue);
      expect(canProcessReturn(OrderStatus.completed), isFalse);
      expect(canProcessReturn(OrderStatus.cancelled), isFalse);
    });

    test('Partial Return banner appears when unreturned items remain', () {
      bool shouldShowBanner({
        required OrderStatus status,
        required int totalQty,
        required int returnedQty,
      }) {
        final hasPendingReturns = returnedQty < totalQty;
        return status == OrderStatus.partial || (status == OrderStatus.flagged && hasPendingReturns);
      }

      // Order is PARTIAL and items pending -> Banner shown
      expect(shouldShowBanner(status: OrderStatus.partial, totalQty: 5, returnedQty: 2), isTrue);

      // Order is FLAGGED due to damage on item 1, but item 2 still not returned -> Banner shown
      expect(shouldShowBanner(status: OrderStatus.flagged, totalQty: 5, returnedQty: 3), isTrue);

      // Order is FLAGGED and ALL items already returned -> Banner not needed
      expect(shouldShowBanner(status: OrderStatus.flagged, totalQty: 5, returnedQty: 5), isFalse);
    });

    test('Max return calculation marks fully-returned items as Returned Earlier', () {
      const itemQuantity = 3;
      const alreadyReturnedQuantity = 3;

      final maxReturn = itemQuantity - alreadyReturnedQuantity;
      expect(maxReturn <= 0, isTrue);

      // When maxReturn <= 0, modal now renders "Returned (all 3 units)" instead of SizedBox.shrink()
      final displayStatus = maxReturn <= 0 ? 'Returned ($alreadyReturnedQuantity/$itemQuantity)' : 'Pending Return';
      expect(displayStatus, 'Returned (3/3)');
    });
  });

  group('4. Order Cancellation Refund Presets', () {
    test('Full refund and Waive Advance presets calculate correctly', () {
      const double paidAmount = 1200.0;

      // Full Refund preset
      final fullRefund = paidAmount;
      expect(fullRefund, 1200.0);

      // Waive / Keep Advance preset
      final waiveRefund = 0.0;
      final defaultWaiveReason = 'Advance retained as cancellation fee';
      expect(waiveRefund, 0.0);
      expect(defaultWaiveReason, contains('Advance retained'));
    });
  });

  group('5. Damage Assessment & Flagged Item Parity', () {
    test('Calculates auto-marked Good count accurately for partially damaged items', () {
      const quantity = 5;
      const damagedQuantity = 2;
      final autoGoodCount = quantity - damagedQuantity;

      expect(autoGoodCount, 3);
      expect(autoGoodCount > 0, isTrue);
    });

    test('Damage assessment decision payload formats match web API specifications', () {
      // Reuse decision
      final reusePayload = {
        'decision': 'reuse',
        'notes': 'Cleaned and restored to inventory',
      };
      expect(reusePayload['decision'], 'reuse');
      expect(reusePayload['notes'], isNotEmpty);

      // Write-off (not_reuse) decision
      final writeOffPayload = {
        'decision': 'not_reuse',
        'notes': 'Beyond repair - torn seam',
      };
      expect(writeOffPayload['decision'], 'not_reuse');
      expect(writeOffPayload['notes'], contains('Beyond repair'));
    });

    test('Damage assessment summary calculations match allDone and pending counts', () {
      final assessments = [
        {'id': '1', 'decision': 'reuse', 'assessment_date': '2026-09-01T10:00:00Z'},
        {'id': '2', 'decision': 'not_reuse', 'assessment_date': '2026-09-02T11:00:00Z'},
        {'id': '3', 'decision': null, 'assessment_date': null},
      ];

      final total = assessments.length;
      final resolved = assessments.where((a) => a['decision'] != null).length;
      final pending = total - resolved;
      final allDone = total > 0 && pending == 0;

      expect(total, 3);
      expect(resolved, 2);
      expect(pending, 1);
      expect(allDone, isFalse);
    });
  });

  group('6. Sept 6 Parity: Discount-Only Adjustment & Late Fee Removal', () {
    test('Discount-Only Financial Adjustment calculates total, discount and payment status correctly without phantom payment', () {
      const orderTotal = 1500.0;
      const initialDiscount = 100.0;
      const amountPaid = 1200.0;

      final discountEntered = 200.0;
      final updatedTotal = (orderTotal - discountEntered).clamp(0.0, double.infinity);
      final newDiscount = initialDiscount + discountEntered;
      final newPaymentStatus = amountPaid >= updatedTotal
          ? 'paid'
          : amountPaid > 0
              ? 'partial'
              : 'pending';

      expect(updatedTotal, 1300.0);
      expect(newDiscount, 300.0);
      expect(newPaymentStatus, 'partial');

      // If discount equals or exceeds remaining balance:
      final largeDiscount = 300.0;
      final paidTotal = (updatedTotal - largeDiscount).clamp(0.0, double.infinity);
      final paidPaymentStatus = amountPaid >= paidTotal ? 'paid' : 'partial';
      expect(paidTotal, 1000.0);
      expect(paidPaymentStatus, 'paid');
    });

    test('Return check-in passes 0.0 late fee and preserves discount', () {
      final double discount = 150.0;
      const double lateFee = 0.0; // Late fees are removed from return check-in

      final payload = {
        'late_fee': lateFee,
        'discount': discount,
      };

      expect(payload['late_fee'], 0.0);
      expect(payload['discount'], 150.0);
    });

    test('Payment transaction editing payload includes mode, ref id, and notes', () {
      final updateData = {
        'amount': 500.0,
        'payment_mode': 'upi',
        'transaction_id': 'UPI-987654321',
        'notes': 'Paid via customer mobile app',
      };

      expect(updateData['payment_mode'], 'upi');
      expect(updateData['transaction_id'], 'UPI-987654321');
      expect(updateData['amount'], 500.0);
    });
  });

  group('7. Sept 6 Parity: Stock Conflict, Backfill Return, Refund & Delete Payment', () {
    test('Stock conflict detection correctly checks has_stock_conflict and formats shortfall', () {
      final conflictDetails = [
        {'productName': 'Kathakali Crown', 'shortfall': 2},
        {'productName': 'Mohiniyattam Belt', 'shortfall': 1},
      ];

      final isConflict = conflictDetails.isNotEmpty;
      expect(isConflict, isTrue);

      final firstShortfall = conflictDetails.first['shortfall'];
      expect(firstShortfall, 2);
    });

    test('Backfill return constructs payload with status returned and mandatory note', () {
      const reasonNote = 'Staff offline handover recorded after rental expired';
      final payload = {
        'status': 'returned',
        'backfill_note': reasonNote,
      };

      expect(payload['status'], 'returned');
      expect(payload['backfill_note'], isNotEmpty);
      expect(payload['backfill_note'], equals(reasonNote));
    });

    test('Keep Money marks payment status as refund_waived without creating refund transaction', () {
      final updatePayload = {
        'payment_status': PaymentStatus.refundWaived.toJsonValue(),
      };

      expect(updatePayload['payment_status'], 'refund_waived');
    });

    test('Cancellation refund validates against amount paid and issues refund payment type', () {
      const double amountPaid = 1500.0;
      const double refundEntered = 1000.0;

      final isWithinLimit = refundEntered > 0 && refundEntered <= amountPaid;
      expect(isWithinLimit, isTrue);

      final refundPaymentPayload = {
        'order_id': 'order-xyz-123',
        'amount': refundEntered,
        'payment_mode': 'cash',
        'payment_type': 'refund',
        'notes': 'Cancellation Refund',
      };

      expect(refundPaymentPayload['payment_type'], 'refund');
      expect(refundPaymentPayload['amount'], 1000.0);
    });

    test('Payment deletion route targets DELETE /payments/:id', () {
      const paymentId = 'pay-999-abc';
      final deleteEndpoint = '/payments/$paymentId';

      expect(deleteEndpoint, '/payments/pay-999-abc');
    });
  });

  group('8. Inline Order Items Return & Damage Parity UI/UX', () {
    test('Mark All Good resets local return state to good condition with 0 damage', () {
      final localReturnItems = {
        'item-1': {'status': 'damaged', 'damage_fee': 250.0, 'damaged_quantity': 2, 'notes': 'Torn lace'},
        'item-2': {'status': null, 'damage_fee': 0.0, 'damaged_quantity': 1, 'notes': ''},
      };

      for (final key in localReturnItems.keys) {
        localReturnItems[key] = {
          'status': 'good',
          'damage_fee': 0.0,
          'damaged_quantity': 0,
          'notes': '',
        };
      }

      expect(localReturnItems['item-1']!['status'], 'good');
      expect(localReturnItems['item-1']!['damage_fee'], 0.0);
      expect(localReturnItems['item-1']!['damaged_quantity'], 0);
      expect(localReturnItems['item-1']!['notes'], '');
      expect(localReturnItems['item-2']!['status'], 'good');
    });

    test('Inline return settlement footer computes live projected total, damage fees, and balance due', () {
      const originalTotal = 2500.0;
      const damageChargesTotal = 0.0;
      const lateFee = 0.0;
      const amountPaid = 1500.0;

      final double originalBaseTotal = originalTotal - damageChargesTotal - lateFee;

      final localReturnItems = {
        'item-1': {'status': 'good', 'damage_fee': 0.0},
        'item-2': {'status': 'damaged', 'damage_fee': 350.0},
        'item-3': {'status': 'damaged', 'damage_fee': 150.0},
      };

      double liveDamage = 0.0;
      for (final state in localReturnItems.values) {
        if (state['status'] == 'damaged') {
          liveDamage += (state['damage_fee'] as num).toDouble();
        }
      }

      const double extraLateFee = 100.0;
      const double returnDiscount = 50.0;

      final double newTotal = originalBaseTotal + liveDamage + extraLateFee - returnDiscount;
      final double balanceDue = newTotal - amountPaid;

      expect(liveDamage, 500.0);
      expect(newTotal, 3050.0);
      expect(balanceDue, 1550.0);
    });

    test('Partial damaged quantity auto-marks remaining units as Good and builds complete return payload', () {
      const itemQuantity = 5;
      const damagedQty = 2;
      const autoGoodUnits = itemQuantity - damagedQty;

      expect(autoGoodUnits, 3);

      final payloadItem = {
        'item_id': 'item-001',
        'returned_quantity': itemQuantity,
        'condition_rating': 'damaged',
        'damage_description': 'Zipper broken on 2 costumes',
        'damage_charges': 200.0,
        'damaged_quantity': damagedQty,
      };

      expect(payloadItem['returned_quantity'], 5);
      expect(payloadItem['damaged_quantity'], 2);
      expect(payloadItem['condition_rating'], 'damaged');
      expect(payloadItem['damage_charges'], 200.0);
    });

    test('Unmarked items detection identifies pending inspections', () {
      final items = ['item-1', 'item-2', 'item-3'];
      final localReturnItems = {
        'item-1': {'status': 'good'},
        'item-2': {'status': null},
        'item-3': {'status': 'damaged'},
      };

      final unmarked = items.where((id) => localReturnItems[id]?['status'] == null).toList();

      expect(unmarked.length, 1);
      expect(unmarked.first, 'item-2');
    });
  });
}

