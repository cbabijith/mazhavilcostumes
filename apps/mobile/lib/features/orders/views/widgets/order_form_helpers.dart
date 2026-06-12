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
    if (sAvail != null) {
      final int availableWithPriority =
          (sAvail['availableWithPriority'] as num?)?.toInt() ?? 0;
      if (availableWithPriority < 1) {
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
    }

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
      _productSearchController.clear();
      _productSearchQuery = '';
      _showProductDropdown = false;
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
      builder: (context) => QRScannerDialog(
        onScanMatched: (productId) async {
          try {
            _update(() => _isLoading = true);
            final repo = ref.read(productRepositoryProvider);
            final product = await repo.getProductById(productId);

            final existingIndex = _items.indexWhere(
              (item) => item.productId == product.id,
            );
            if (existingIndex != -1) {
              _update(() {
                _items[existingIndex].quantity += 1;
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
