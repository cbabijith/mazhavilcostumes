part of '../order_form_view.dart';

extension _OrderFormProductSearchSection on _OrderFormViewState {
  Widget _buildProductSearchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _productSearchController,
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: Responsive.sp(14)),
            decoration: InputDecoration(
              labelText: 'Search Items',
              hintText: 'Search products or scan barcode...',
              hintStyle: TextStyle(
                fontSize: Responsive.sp(14),
                color: Colors.grey,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: Responsive.icon(20),
              ),
              suffixIcon: _productSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        size: Responsive.icon(18),
                      ),
                      onPressed: () {
                        _productSearchController.clear();
                        _searchDebounce?.cancel();
                        _productSearchCancelToken?.cancel('Search cleared');
                        _searchAvailCancelToken?.cancel('Search cleared');
                        _update(() {
                          _productSearchQuery = '';
                          _productSearchResults = [];
                          _searchAvailabilityMap = {};
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Responsive.r(8)),
              ),
              contentPadding: Responsive.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              _update(() {
                _productSearchQuery = value;
              });
              _searchDebounce?.cancel();
              _searchDebounce = Timer(
                const Duration(milliseconds: 500),
                () {
                  _searchProducts(value);
                },
              );
            },
          ),
        ),
        SizedBox(width: Responsive.w(8)),
        Container(
          height: Responsive.h(48),
          width: Responsive.h(48),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(Responsive.r(8)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(Responsive.r(8)),
              onTap: _openBarcodeScanner,
              child: Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.primary,
                size: Responsive.icon(22),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildCatalogResultsList() {
    final products = _productSearchResults;

    if (_isSearchingProducts && products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: Responsive.all(16),
          child: Text(
            'No products found matching "$_productSearchQuery"',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: Responsive.sp(AppSizes.fontMedium),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: widget.order != null,
      physics: widget.order != null
          ? const NeverScrollableScrollPhysics()
          : null,
      padding: Responsive.symmetric(vertical: 8),
      itemCount: products.length,
      separatorBuilder: (context, index) => SizedBox(height: Responsive.h(8)),
      itemBuilder: (context, index) {
        final product = products[index];
        final sAvail = _searchAvailabilityMap[product.id];
        bool isAvail = product.availableQuantity > 0;
        if (sAvail != null) {
          final int availableWithPriority =
              (sAvail['availableWithPriority'] as num?)?.toInt() ?? 0;
          isAvail = availableWithPriority > 0;
        }

        // Check if already in cart
        final cartIndex = _items.indexWhere((item) => item.productId == product.id);
        final isInCart = cartIndex != -1;

        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: Responsive.all(AppSizes.spacingMedium),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: Responsive.w(64),
                  height: Responsive.w(64),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: product.primaryImageUrl != null && product.primaryImageUrl!.isNotEmpty
                      ? Image.network(product.primaryImageUrl!, fit: BoxFit.cover)
                      : Icon(Icons.shopping_bag_outlined, color: Colors.grey[400], size: Responsive.icon(28)),
                ),
                SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.sp(AppSizes.fontMedium),
                          color: Colors.grey[900],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Responsive.h(4)),
                      Text(
                        '₹${product.pricePerDay.toStringAsFixed(2)} / day',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontSmall),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: Responsive.h(4)),
                      // Availability Status
                      Builder(
                        builder: (context) {
                          if (_isCheckingSearchAvailability) {
                            return Text(
                              'Checking dates...',
                              style: TextStyle(fontSize: Responsive.sp(AppSizes.fontTiny), color: Colors.teal),
                            );
                          }
                          if (sAvail != null) {
                            final int available = (sAvail['available'] as num?)?.toInt() ?? 0;
                            final int availableWithPriority = (sAvail['availableWithPriority'] as num?)?.toInt() ?? 0;
                            if (available > 0) {
                              return Text('$available free for dates', style: TextStyle(color: AppColors.success, fontSize: Responsive.sp(AppSizes.fontTiny)));
                            } else if (availableWithPriority > 0) {
                              return Text('0 free ($availableWithPriority with priority cleaning)', style: TextStyle(color: AppColors.warning, fontSize: Responsive.sp(AppSizes.fontTiny)));
                            } else {
                              return Text('Unavailable', style: TextStyle(color: AppColors.error, fontSize: Responsive.sp(AppSizes.fontTiny), fontWeight: FontWeight.bold));
                            }
                          }
                          return Text('Stock: ${product.availableQuantity}', style: TextStyle(color: Colors.grey[600], fontSize: Responsive.sp(AppSizes.fontTiny)));
                        },
                      ),
                    ],
                  ),
                ),
                // Add / Qty controls
                if (isInCart)
                  _buildInlineCartQtyControls(_items[cartIndex])
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAvail ? AppColors.primary : Colors.grey[300],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: Size(Responsive.w(70), Responsive.h(32)),
                      padding: Responsive.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                      ),
                    ),
                    onPressed: isAvail ? () => _addProductToOrder(product) : null,
                    child: Text(
                      isAvail ? 'ADD' : 'OUT',
                      style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInlineCartQtyControls(OrderItemInput item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.remove_rounded, color: AppColors.primary, size: Responsive.icon(18)),
            onPressed: () {
              _update(() {
                if (item.quantity > 1) {
                  item.quantity--;
                  item.quantityController.text = item.quantity.toString();
                  final idx = _items.indexOf(item);
                  _checkItemAvailability(idx);
                } else {
                  _items.remove(item);
                }
              });
              _calculateTotals();
            },
          ),
          Padding(
            padding: Responsive.symmetric(horizontal: 8),
            child: Text(
              '${item.quantity}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.sp(AppSizes.fontMedium)),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.add_rounded, color: AppColors.primary, size: Responsive.icon(18)),
            onPressed: () {
              final maxQty = item.availableWithPriority > 0 ? item.availableWithPriority : item.available;
              if (maxQty > 0 && item.quantity >= maxQty) {
                final msg = item.availableWithPriority > item.available
                    ? 'Maximum $maxQty available for these dates (${item.available} free + ${maxQty - item.available} with priority cleaning).'
                    : 'Maximum $maxQty available for these dates.';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg), backgroundColor: AppColors.error),
                );
                return;
              }
              _update(() {
                item.quantity++;
                item.quantityController.text = item.quantity.toString();
                final idx = _items.indexOf(item);
                _checkItemAvailability(idx);
              });
              _calculateTotals();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList() {
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, color: Colors.grey[400], size: Responsive.icon(48)),
            SizedBox(height: Responsive.h(12)),
            Text(
              'No items added to order yet',
              style: TextStyle(color: Colors.grey[500], fontSize: Responsive.sp(AppSizes.fontMedium)),
            ),
            SizedBox(height: Responsive.h(8)),
            Text(
              'Use the search bar above to find and add costumes',
              style: TextStyle(color: Colors.grey[400], fontSize: Responsive.sp(AppSizes.fontSmall)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: widget.order != null,
      physics: widget.order != null
          ? const NeverScrollableScrollPhysics()
          : null,
      padding: Responsive.symmetric(vertical: 8),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(_items[index], index);
      },
    );
  }
}
