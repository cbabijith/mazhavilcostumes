part of '../order_form_view.dart';

extension _OrderFormApi on _OrderFormViewState {
  Future<void> _fetchGstSettings() async {
    try {
      final response = await apiClient.get('/settings?key=is_gst_enabled');
      if (response.statusCode == 200 && response.data != null) {
        final val = response.data['data']?['value'];
        _update(() {
          _isGstEnabled = val == true || val == 'true';
        });
        _calculateTotals();
      }
    } catch (e) {
      print('Error fetching GST settings: $e');
    }
  }

  void _searchProducts(String query) async {
    if (query.trim().isEmpty) {
      _update(() {
        _productSearchResults = [];
        _isSearchingProducts = false;
        _searchAvailabilityMap = {};
      });
      return;
    }

    _productSearchCancelToken?.cancel('New search started');
    _productSearchCancelToken = CancelToken();

    _update(() => _isSearchingProducts = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      final result = await repo.getProducts(
        search: query.trim(),
        branchId: _selectedBranchId,
        cancelToken: _productSearchCancelToken,
      );
      // Filter out products already in _items
      final filtered = result.products
          .where((p) => !_items.any((item) => item.productId == p.id))
          .toList();
      if (!mounted) return;
      _update(() {
        _productSearchResults = filtered;
        _isSearchingProducts = false;
      });
      _checkSearchProductsAvailability(filtered);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return;
      }
      if (!mounted) return;
      _update(() => _isSearchingProducts = false);
    }
  }

  void _checkSearchProductsAvailability(List<p_model.Product> products) async {
    if (products.isEmpty ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _selectedBranchId == null) {
      _update(() {
        _searchAvailabilityMap = {};
        _isCheckingSearchAvailability = false;
      });
      return;
    }

    _searchAvailCancelToken?.cancel('New availability check started');
    _searchAvailCancelToken = CancelToken();

    _update(() {
      _isCheckingSearchAvailability = true;
    });

    try {
      final operations = ref.read(orderOperationsProvider);
      final result = await operations.checkAvailability(
        startDate: _toIsoDate(_startDateController.text),
        endDate: _toIsoDate(_endDateController.text),
        branchId: _selectedBranchId!,
        items: products
            .map((p) => <String, dynamic>{'product_id': p.id, 'quantity': 1})
            .toList(),
        excludeOrderId: widget.order?.id,
        cancelToken: _searchAvailCancelToken,
      );

      final itemsList = result['items'] as List<dynamic>? ?? [];
      final Map<String, Map<String, dynamic>> tempMap = {};
      for (final item in itemsList) {
        if (item is Map) {
          final castedItem = Map<String, dynamic>.from(item);
          final pId = castedItem['product_id'] as String?;
          if (pId != null) {
            tempMap[pId] = castedItem;
          }
        }
      }

      if (!mounted) return;
      _update(() {
        if (_productSearchResults == products) {
          _searchAvailabilityMap = tempMap;
          _isCheckingSearchAvailability = false;
        }
      });
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return;
      }
      print('Error checking search products availability: $e');
      if (mounted) {
        _update(() {
          _isCheckingSearchAvailability = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Availability Check Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _checkItemAvailability(int index) async {
    final item = _items[index];
    if (item.productId.isEmpty ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _selectedBranchId == null) {
      return;
    }

    item.cancelToken?.cancel('New check started');
    item.cancelToken = CancelToken();

    _update(() => item.isChecking = true);
    try {
      final operations = ref.read(orderOperationsProvider);
      final result = await operations.checkAvailability(
        startDate: _toIsoDate(_startDateController.text),
        endDate: _toIsoDate(_endDateController.text),
        branchId: _selectedBranchId!,
        items: [
          <String, dynamic>{
            'product_id': item.productId,
            'quantity': item.quantity,
          },
        ],
        excludeOrderId: widget.order?.id,
        cancelToken: item.cancelToken,
      );

      final itemsList = result['items'] as List<dynamic>? ?? [];
      if (itemsList.isNotEmpty && itemsList.first is Map) {
        final i = Map<String, dynamic>.from(itemsList.first as Map);
        final isItemAvailable = i['isAvailable'] as bool? ?? true;
        final available = (i['available'] as num?)?.toInt() ?? 0;
        final availableWithPriority =
            (i['availableWithPriority'] as num?)?.toInt() ?? 0;
        final priorityCleaningNeeded =
            i['priorityCleaningNeeded'] as bool? ?? false;
        final priorityCleaningInfo =
            i['priorityCleaningInfo'] as List<dynamic>? ?? [];
        final overlappingOrders =
            i['overlappingOrders'] as List<dynamic>? ?? [];

        _update(() {
          item.isAvailable = isItemAvailable;
          item.available = available;
          item.availableWithPriority = availableWithPriority;
          item.priorityCleaningNeeded = priorityCleaningNeeded;
          item.priorityCleaningInfo = priorityCleaningInfo;
          item.overlappingOrders = overlappingOrders;
          item.isChecking = false;

          if (!isItemAvailable) {
            item.availableStockInfo =
                'Conflict (Max avail: $availableWithPriority)';
          } else if (priorityCleaningNeeded) {
            item.availableStockInfo =
                'Priority cleaning needed (Avail: $available, Max with Priority: $availableWithPriority)';
          } else {
            item.availableStockInfo = null;
          }
        });
      } else {
        _update(() {
          item.isChecking = false;
        });
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return;
      }
      _update(() => item.isChecking = false);
    }
  }

  void _checkAllItemsAvailability() {
    for (int i = 0; i < _items.length; i++) {
      _checkItemAvailability(i);
    }
    _checkSearchProductsAvailability(_productSearchResults);
  }
}
