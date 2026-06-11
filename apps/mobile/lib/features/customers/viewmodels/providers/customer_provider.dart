import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../models/customer.dart';
import '../../repositories/customer_repository.dart';

// Repository provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

// Customers list provider with keepAlive for caching
final customersProvider = FutureProvider.autoDispose.family<PaginatedCustomers, Map<String, dynamic>>((ref, params) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomers(
    page: params['page'] ?? 1,
    limit: params['limit'] ?? 20,
    query: params['query'],
    phone: params['phone'],
    sortBy: params['sortBy'] ?? 'created_at',
    sortOrder: params['sortOrder'] ?? 'desc',
    lightweight: params['lightweight'] ?? false,
  );
}, name: 'customersProvider');

// Keep the provider alive for 5 minutes to enable hybrid search
final customersCacheProvider = Provider.autoDispose((ref) {
  ref.keepAlive();
  return ref.watch(customersProvider({'page': 1, 'limit': 100, 'lightweight': true}));
}, name: 'customersCacheProvider');

// Single customer provider
final customerProvider = FutureProvider.family.autoDispose<Customer, String>((ref, id) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerById(id);
}, name: 'customerProvider');

// Hybrid search state
class CustomerSearchState {
  final List<Customer> results;
  final bool isLoading;
  final bool isSearchingRemote;
  final String? error;

  CustomerSearchState({
    this.results = const [],
    this.isLoading = false,
    this.isSearchingRemote = false,
    this.error,
  });

  CustomerSearchState copyWith({
    List<Customer>? results,
    bool? isLoading,
    bool? isSearchingRemote,
    String? error,
  }) {
    return CustomerSearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      isSearchingRemote: isSearchingRemote ?? this.isSearchingRemote,
      error: error,
    );
  }
}

// Hybrid search provider - combines local cache search with remote API search
class CustomerSearchNotifier extends Notifier<CustomerSearchState> {
  Timer? _debounceTimer;

  @override
  CustomerSearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return CustomerSearchState();
  }

  // Local search against cached customers (0ms latency)
  List<Customer> _searchLocal(String query) {
    final cache = ref.read(customersCacheProvider);
    final cachedCustomers = cache.value?.customers ?? [];
    
    if (query.isEmpty) return cachedCustomers;
    
    final lowerQuery = query.toLowerCase();
    return cachedCustomers.where((customer) {
      return customer.name.toLowerCase().contains(lowerQuery) ||
             customer.phone.contains(query);
    }).toList();
  }

  // Search with hybrid approach
  void search(String query) {
    // Cancel any pending remote search
    _debounceTimer?.cancel();
    
    // Step 1: Instant local search (0ms)
    final localResults = _searchLocal(query);
    state = state.copyWith(
      results: localResults,
      isLoading: false,
      error: null,
    );
    
    // Step 2: Debounced remote search (300ms)
    if (query.isNotEmpty) {
      state = state.copyWith(isSearchingRemote: true);
      _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
        try {
          final repository = ref.read(customerRepositoryProvider);
          final remoteResults = await repository.getCustomers(
            query: query,
            limit: 20,
            lightweight: true,
          );
          
          // Merge local and remote results, deduplicating by ID
          final mergedResults = [...localResults];
          final existingIds = mergedResults.map((c) => c.id).toSet();
          
          for (final customer in remoteResults.customers) {
            if (!existingIds.contains(customer.id)) {
              mergedResults.add(customer);
            }
          }
          
          state = state.copyWith(
            results: mergedResults,
            isSearchingRemote: false,
          );
        } catch (e) {
          state = state.copyWith(
            isSearchingRemote: false,
            error: e.toString(),
          );
        }
      });
    } else {
      state = state.copyWith(isSearchingRemote: false);
    }
  }

  void clear() {
    _debounceTimer?.cancel();
    state = CustomerSearchState();
  }
}

final customerSearchProvider = NotifierProvider.autoDispose<CustomerSearchNotifier, CustomerSearchState>(CustomerSearchNotifier.new, name: 'customerSearchProvider');

// Customer operations provider - simple function-based approach
class CustomerOperations {
  final CustomerRepository _repository;

  CustomerOperations(this._repository);

  Future<Customer> createCustomer(Map<String, dynamic> body) async {
    return await _repository.createCustomer(body);
  }

  Future<void> updateCustomer(String id, Map<String, dynamic> body) async {
    await _repository.updateCustomer(id, body);
  }

  Future<void> deleteCustomer(String id) async {
    await _repository.deleteCustomer(id);
  }
}

final customerOperationsProvider = Provider<CustomerOperations>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CustomerOperations(repository);
}, name: 'customerOperationsProvider');
