import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/providers/startup_cache_provider.dart';
import '../../../auth/viewmodels/providers/auth_provider.dart';
import '../../models/branch.dart';
import '../../repositories/branch_repository.dart';

// Repository provider
final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  return BranchRepository();
});

// Branches list provider
final branchesProvider = FutureProvider.autoDispose<List<Branch>>((ref) async {
  final user = ref.watch(authUserProvider);
  if (user == null) return [];

  final repository = ref.watch(branchRepositoryProvider);
  return repository.getBranches();
});

/// Saved branch choices unblock startup while the server refreshes permissions.
final startupBranchesProvider = StreamProvider.autoDispose<List<Branch>>((ref) {
  final scope = ref.watch(startupCacheScopeProvider);
  if (scope == null) return Stream.value(<Branch>[]);
  final token = CancelToken();
  ref.onDispose(token.cancel);
  return ref
      .watch(branchRepositoryProvider)
      .watchStartupBranches(
        cache: ref.watch(startupCacheProvider),
        scope: scope,
        cancelToken: token,
      );
});

// Single branch provider
final branchProvider = FutureProvider.family.autoDispose<Branch, String>((
  ref,
  id,
) async {
  final repository = ref.watch(branchRepositoryProvider);
  return repository.getBranchById(id);
});

/// Selected branch ID. Defaults to first active branch for admins.
class SelectedBranchNotifier extends Notifier<String?> {
  String? _selectedId;
  bool _hasSelection = false;
  String? _userId;

  @override
  String? build() {
    // Auto-select first branch for admins on initial load
    final user = ref.watch(authUserProvider);
    if (_userId != user?.id) {
      _userId = user?.id;
      _selectedId = null;
      _hasSelection = false;
    }
    if (user?.canSwitchBranches == true) {
      final branchesAsync = ref.watch(startupBranchesProvider);
      final branches = branchesAsync.value;
      if (branches != null) {
        if (_hasSelection &&
            (_selectedId == null ||
                branches.any(
                  (branch) => branch.id == _selectedId && branch.isActive,
                ))) {
          return _selectedId;
        }
        if (branches.isNotEmpty) {
          final firstActive = branches.firstWhere(
            (b) => b.isActive,
            orElse: () => branches.first,
          );
          _hasSelection = true;
          return _selectedId = firstActive.id;
        }
        _selectedId = null;
        _hasSelection = false;
        return null;
      }
      return _selectedId;
    }
    return null;
  }

  void select(String? branchId) {
    _hasSelection = true;
    _selectedId = branchId;
    state = branchId;
  }
}

final selectedBranchIdProvider =
    NotifierProvider<SelectedBranchNotifier, String?>(
      SelectedBranchNotifier.new,
    );

final effectiveBranchIdProvider = Provider<String?>((ref) {
  final user = ref.watch(authUserProvider);
  final selectedBranchId = ref.watch(selectedBranchIdProvider);

  if (user == null) return null;
  if (user.canSwitchBranches) return selectedBranchId;
  return user.branchId;
});

/// Wait for the initial branch selection instead of requesting every branch first.
final resolvedBranchIdProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(authUserProvider);
  final branchId = ref.watch(effectiveBranchIdProvider);
  if (user?.canSwitchBranches == true &&
      !ref.watch(startupBranchesProvider.select((value) => value.hasValue))) {
    await ref.watch(startupBranchesProvider.future);
    if (!ref.mounted) throw StateError('Branch selection superseded');
    return ref.read(effectiveBranchIdProvider);
  }
  return branchId;
});

final selectedBranchProvider = Provider<AsyncValue<Branch?>>((ref) {
  final selectedBranchId = ref.watch(selectedBranchIdProvider);
  if (selectedBranchId == null) return const AsyncData<Branch?>(null);

  return ref.watch(startupBranchesProvider).whenData((branches) {
    for (final branch in branches) {
      if (branch.id == selectedBranchId) return branch;
    }
    return null;
  });
});

// Branch operations - simple function-based approach
class BranchOperations {
  final BranchRepository _repository;
  final void Function() _onChanged;

  BranchOperations(this._repository, this._onChanged);

  Future<void> createBranch(Map<String, dynamic> body) async {
    await _repository.createBranch(body);
    _onChanged();
  }

  Future<void> updateBranch(String id, Map<String, dynamic> body) async {
    await _repository.updateBranch(id, body);
    _onChanged();
  }

  Future<void> deleteBranch(String id) async {
    await _repository.deleteBranch(id);
    _onChanged();
  }
}

final branchOperationsProvider = Provider<BranchOperations>((ref) {
  final repository = ref.watch(branchRepositoryProvider);
  return BranchOperations(
    repository,
    () => ref.invalidate(startupBranchesProvider),
  );
});
