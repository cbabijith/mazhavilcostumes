/// Account and environment boundaries for locally saved startup data.
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/viewmodels/auth_provider.dart';
import '../cache/startup_snapshot_cache.dart';
import '../supabase/api_client.dart';

final startupCacheProvider = Provider<StartupSnapshotCache>(
  (ref) => startupSnapshotCache,
);

final startupCacheScopeProvider = Provider<String?>((ref) {
  final user = ref.watch(authUserProvider);
  if (user == null) return null;
  return jsonEncode([
    apiClient.dio.options.baseUrl,
    user.id,
    user.storeId,
    user.role,
    user.branchId,
    user.staffId,
  ]);
});
