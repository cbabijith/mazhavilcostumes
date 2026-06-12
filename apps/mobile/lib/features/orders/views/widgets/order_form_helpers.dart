part of '../order_form_view.dart';

extension _OrderFormHelpers on _OrderFormViewState {
  void _selectCustomer(Customer customer) {
    _update(() {
      _selectedCustomerId = customer.id;
      _selectedCustomerName = customer.name;
      _phoneSearchController.text = customer.phone;
      _showCustomerDropdown = false;
      _searchQuery = '';
    });
    // Auto-fill delivery address from customer (matching web behavior — new orders only)
    if (widget.order == null &&
        customer.address != null &&
        customer.address!.isNotEmpty) {
      _deliveryAddressController.text = customer.address!;
    }
  }

  void _clearCustomer() {
    _update(() {
      _selectedCustomerId = null;
      _selectedCustomerName = null;
      _phoneSearchController.text = '';
      _showCustomerDropdown = false;
      _searchQuery = '';
    });
  }

  void _openAddCustomerDialog() {
    final trimmed = _phoneSearchController.text.trim();
    final isPhone = RegExp(r'^\d+$').hasMatch(trimmed);

    showDialog(
      context: context,
      builder: (context) => AddCustomerDialog(
        initialName: isPhone ? '' : trimmed,
        initialPhone: isPhone ? trimmed : '',
        onCustomerCreated: (customer) {
          _selectCustomer(customer);
        },
      ),
    );
  }

  void _addProductToOrder(p_model.Product product) {
    FocusScope.of(context).unfocus();
    final sAvail = _searchAvailabilityMap[product.id];
    int available = 0;
    int availableWithPriority = 0;
    if (sAvail != null) {
      final int availableWithPriorityVal =
          (sAvail['availableWithPriority'] as num?)?.toInt() ?? 0;
      if (availableWithPriorityVal < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unavailable: 0 available for the selected dates (even with priority cleaning).',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      available = (sAvail['available'] as num?)?.toInt() ?? 0;
      availableWithPriority = availableWithPriorityVal;
    }

    _update(() {
      _items.add(
        OrderItemInput(
          productId: product.id,
          productName: product.name,
          quantity: 1,
          pricePerDay: product.pricePerDay,
          gstPercentage: product.gstPercentage,
          available: available,
          availableWithPriority: availableWithPriority,
        ),
      );
      _productSearchController.clear();
      _productSearchQuery = '';
      _productSearchResults = [];
      _searchAvailabilityMap = {};
    });

    final newIndex = _items.length - 1;
    _calculateTotals();
    _checkItemAvailability(newIndex);
  }

  void _removeItem(int index) {
    _update(() {
      _items.removeAt(index);
    });
    _calculateTotals();
  }

  void _openBarcodeScanner() {
    showDialog(
      context: context,
      builder: (_) => QRScannerDialog(
        onScanMatched: (productId) async {
          try {
            _update(() => _isLoading = true);
            final repo = ref.read(productRepositoryProvider);
            final product = await repo.getProductById(productId);

            final existingIndex = _items.indexWhere(
              (item) => item.productId == product.id,
            );
            if (existingIndex != -1) {
              final existingItem = _items[existingIndex];
              final maxQty = existingItem.availableWithPriority > 0
                  ? existingItem.availableWithPriority
                  : existingItem.available;
              if (maxQty > 0 && existingItem.quantity >= maxQty) {
                _update(() => _isLoading = false);
                if (mounted) {
                  final msg =
                      existingItem.availableWithPriority >
                          existingItem.available
                      ? 'Maximum $maxQty available for these dates (${existingItem.available} free + ${maxQty - existingItem.available} with priority cleaning).'
                      : 'Maximum $maxQty available for these dates.';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
                return;
              }
              _update(() {
                _items[existingIndex].quantity += 1;
                _items[existingIndex].quantityController.text =
                    _items[existingIndex].quantity.toString();
                _isLoading = false;
              });
              _calculateTotals();
              _checkItemAvailability(existingIndex);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} quantity increased')),
                );
              }
            } else {
              _update(() {
                _items.add(
                  OrderItemInput(
                    productId: product.id,
                    productName: product.name,
                    quantity: 1,
                    pricePerDay: product.pricePerDay,
                    gstPercentage: product.gstPercentage,
                  ),
                );
                _isLoading = false;
              });
              final newIndex = _items.length - 1;
              _calculateTotals();
              _checkItemAvailability(newIndex);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} added to order')),
                );
              }
            }
          } catch (e) {
            _update(() => _isLoading = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add product: $e')),
              );
            }
          }
        },
      ),
    );
  }
}
