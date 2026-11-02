/// Encrypted, bounded startup snapshots. Network responses remain authoritative.
library;

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_durations.dart';

enum StartupResource { branches, operations, orders, calendar, products }

class StartupSnapshot<T> {
  final T data;
  final DateTime? savedAt;
  final bool refreshFailed;

  const StartupSnapshot(this.data, {this.savedAt, this.refreshFailed = false});
}

/// Bounded encrypted slots, scoped to account, permissions, API and branch. This is
/// only a display cache: it never authorizes requests or validates stock/payments.
class StartupSnapshotCache {
  StartupSnapshotCache({
    FlutterSecureStorage? storage,
    DateTime Function()? now,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _now = now ?? DateTime.now;

  final FlutterSecureStorage _storage;
  final DateTime Function() _now;
  final _generations = <StartupResource, int>{};
  final _invalidated = <StartupResource>{};
  Future<void> _writes = Future<void>.value();

  String _key(StartupResource resource) =>
      'startup_snapshot_v1_${resource.name}';

  Future<StartupSnapshot<T>?> read<T>({
    required StartupResource resource,
    required String scope,
    required T Function(Map<String, dynamic>) decode,
  }) async {
    if (_invalidated.contains(resource)) return null;
    final generation = _generations[resource];
    try {
      final raw = await _storage
          .read(key: _key(resource))
          .timeout(AppDurations.snapshotReadTimeout);
      if (raw == null ||
          generation != _generations[resource] ||
          _invalidated.contains(resource)) {
        return null;
      }
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['scope'] != scope) return null;
      final savedAt = DateTime.parse(json['savedAt'] as String);
      final now = _now();
      final age = now.difference(savedAt);
      if (age.isNegative || age > AppDurations.startupSnapshotMaxAge) {
        return null;
      }
      // Operational cards describe today's work in the shop's India timezone.
      if ((resource == StartupResource.operations ||
              resource == StartupResource.calendar) &&
          _shopDay(savedAt) != _shopDay(now)) {
        return null;
      }
      return StartupSnapshot(
        decode(json['data'] as Map<String, dynamic>),
        savedAt: savedAt,
      );
    } catch (_) {
      // Corrupt/missing/slow storage must never delay or fail the network load.
      return null;
    }
  }

  String _shopDay(DateTime date) => date
      .toUtc()
      .add(AppDurations.shopUtcOffset)
      .toIso8601String()
      .split('T')
      .first;

  Future<void> _enqueue(Future<void> Function() operation) {
    // Serialize writes and deletions, including an in-flight write at logout.
    _writes = _writes.then((_) => operation()).catchError((Object _) {});
    return _writes;
  }

  Future<void> save({
    required StartupResource resource,
    required String scope,
    required Map<String, dynamic> data,
  }) {
    final generation = _generations[resource];
    final value = jsonEncode({
      'scope': scope,
      'savedAt': _now().toIso8601String(),
      'data': data,
    });
    return _enqueue(() async {
      if (generation == _generations[resource]) {
        await _storage.write(key: _key(resource), value: value);
        if (generation == _generations[resource]) _invalidated.remove(resource);
      }
    });
  }

  Future<void> clear(StartupResource resource) {
    _invalidated.add(resource);
    _generations[resource] = (_generations[resource] ?? 0) + 1;
    return _enqueue(() => _storage.delete(key: _key(resource)));
  }

  Future<void> clearAll() =>
      Future.wait(StartupResource.values.map(clear)).then((_) {});

  /// Start HTTP immediately, show a valid snapshot while it runs, then replace
  /// it. Attach the error handler before reading disk to avoid unhandled errors.
  Stream<StartupSnapshot<T>> watch<T>({
    required StartupResource resource,
    required String scope,
    required Future<T> Function() fetch,
    required T Function(Map<String, dynamic>) decode,
    required Map<String, dynamic> Function(T) encode,
    required CancelToken cancelToken,
  }) async* {
    final generation = _generations[resource];
    final pending = Future<T>.sync(fetch)
        .then<({T? data, Object? error, StackTrace? stack})>(
          (data) => (data: data, error: null, stack: null),
          onError: (Object error, StackTrace stack) =>
              (data: null, error: error, stack: stack),
        );
    final saved = await read(resource: resource, scope: scope, decode: decode);
    if (cancelToken.isCancelled) return;
    if (saved != null) yield saved;
    final result = await pending;
    if (cancelToken.isCancelled) return;
    final error = result.error;
    if (error != null) {
      final denied =
          error is DioException &&
          (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403);
      if (saved == null || denied) {
        if (denied) unawaited(clear(resource));
        Error.throwWithStackTrace(error, result.stack!);
      }
      yield StartupSnapshot(
        saved.data,
        savedAt: saved.savedAt,
        refreshFailed: true,
      );
      return;
    }
    final data = result.data as T;
    if (generation == _generations[resource]) {
      unawaited(save(resource: resource, scope: scope, data: encode(data)));
    }
    yield StartupSnapshot(data);
  }
}

final startupSnapshotCache = StartupSnapshotCache();
