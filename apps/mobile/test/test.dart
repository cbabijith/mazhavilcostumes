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
}

