/// Offline coverage for startup latency, freshness and account boundaries.
library;

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/cache/startup_snapshot_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StartupSnapshotCache cache;
  late DateTime now;
  const scope = 'api/user/store/admin/branch';
  const resource = StartupResource.operations;
  Map<String, dynamic> decode(Map<String, dynamic> value) => value;

  Future<void> save() =>
      cache.save(resource: resource, scope: scope, data: {'count': 2});
  Future<StartupSnapshot<Map<String, dynamic>>?> read([
    String account = scope,
  ]) => cache.read(resource: resource, scope: account, decode: decode);
  Stream<StartupSnapshot<Map<String, dynamic>>> watch(
    Future<Map<String, dynamic>> Function() fetch, {
    CancelToken? token,
  }) => cache.watch(
    resource: resource,
    scope: scope,
    fetch: fetch,
    decode: decode,
    encode: decode,
    cancelToken: token ?? CancelToken(),
  );

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    now = DateTime.utc(2026, 11, 2, 12);
    cache = StartupSnapshotCache(now: () => now);
  });

  test(
    'saved data arrives before HTTP and is replaced by fresh data',
    () async {
      await save();
      final pending = Completer<Map<String, dynamic>>();
      final events = StreamIterator(watch(() => pending.future));
      expect(await events.moveNext(), isTrue);
      expect(events.current.data['count'], 2);
      expect(events.current.savedAt, now);
      expect(pending.isCompleted, isFalse);
      pending.complete({'count': 3});
      expect(await events.moveNext(), isTrue);
      expect(events.current.data['count'], 3);
      expect(events.current.savedAt, isNull);
      expect(await events.moveNext(), isFalse);
    },
  );

  test('account, role, API and branch scope must match exactly', () async {
    await save();
    for (final changed in [
      'other-api/user/store/admin/branch',
      'api/other/store/admin/branch',
      'api/user/other/admin/branch',
      'api/user/store/staff/branch',
      'api/user/store/admin/other',
    ]) {
      expect(await read(changed), isNull);
    }
    expect(await read(), isNotNull);
  });

  test(
    'old day, expired, future and malformed snapshots are ignored',
    () async {
      await save();
      now = now.add(const Duration(hours: 25));
      expect(await read(), isNull);
      now = DateTime.utc(2026, 11, 2, 18, 29);
      await save();
      now = now.add(const Duration(minutes: 2)); // Midnight in India.
      expect(await read(), isNull);
      now = now.subtract(const Duration(minutes: 3));
      expect(await read(), isNull);
      FlutterSecureStorage.setMockInitialValues({
        'startup_snapshot_v1_operations': 'invalid json',
      });
      expect(await read(), isNull);
    },
  );

  test(
    'network failure keeps saved data but explicitly marks refresh failure',
    () async {
      await save();
      final events = await watch(
        () => Future.error(StateError('offline')),
      ).toList();
      expect(events.length, 2);
      expect(events.last.data['count'], 2);
      expect(events.last.refreshFailed, isTrue);
      expect(events.last.savedAt, isNotNull);
    },
  );

  test('authorization failure does not fall back to cached success', () async {
    await save();
    final options = RequestOptions(path: '/dashboard/operational');
    final error = DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 403),
    );
    final events = StreamIterator(watch(() => Future.error(error)));
    expect(await events.moveNext(), isTrue);
    await expectLater(events.moveNext(), throwsA(isA<DioException>()));
    expect(await read(), isNull);
  });

  test('logout prevents a late response from repopulating snapshots', () async {
    final pending = Completer<Map<String, dynamic>>();
    final token = CancelToken();
    final result = watch(() => pending.future, token: token).toList();
    await Future<void>.delayed(Duration.zero);
    await cache.clearAll();
    token.cancel();
    pending.complete({'count': 9});
    expect(await result, isEmpty);
    expect(await read(), isNull);
  });

  test(
    'mutation clears snapshot and prevents an older GET from saving it again',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      final result = watch(() => pending.future).toList();
      await Future<void>.delayed(Duration.zero);
      await cache.clear(resource);
      pending.complete({'count': 9});
      await result;
      expect(await read(), isNull);
    },
  );

  test('without cache a failed request surfaces the actual error', () async {
    await expectLater(
      watch(() => Future.error(StateError('offline'))).toList(),
      throwsStateError,
    );
  });
}
