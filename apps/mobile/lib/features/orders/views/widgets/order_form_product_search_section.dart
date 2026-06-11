part of '../order_form_view.dart';

extension _OrderFormProductSearchSection on _OrderFormViewState {
  Widget _buildProductSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
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
                              _showProductDropdown = false;
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
                    _showProductDropdown = value.isNotEmpty;
                  });
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(
                    const Duration(milliseconds: 500),
                    () {
                      _searchProducts(value);
                    },
                  );
                },
                onTap: () {
                  if (_productSearchController.text.isNotEmpty) {
                    _update(() => _showProductDropdown = true);
                  }
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
        ),
        if (_showProductDropdown && _productSearchQuery.isNotEmpty) ...[
          SizedBox(height: Responsive.h(4)),
          _buildProductDropdownList(),
        ],
      ],
    );
  }

  Widget _buildProductDropdownList() {
    final products = _productSearchResults;

    return Container(
      constraints: BoxConstraints(maxHeight: Responsive.h(200)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(8)),
        clipBehavior: Clip.antiAlias,
        child: _isSearchingProducts && products.isEmpty
            ? Center(
                child: Padding(
                  padding: Responsive.all(16),
                  child: const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              )
            : products.isEmpty
            ? Padding(
                padding: Responsive.all(16),
                child: Center(
                  child: Text(
                    'No product found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: Responsive.sp(13),
                    ),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: products.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final sAvail = _searchAvailabilityMap[product.id];
                  bool isAvail = product.availableQuantity > 0;
                  if (sAvail != null) {
                    final int availableWithPriority =
                        (sAvail['availableWithPriority'] as num?)?.toInt() ?? 0;
                    isAvail = availableWithPriority > 0;
                  }

                  return Material(
                    type: MaterialType.transparency,
                    child: Opacity(
                      opacity: isAvail ? 1.0 : 0.5,
                      child: ListTile(
                        contentPadding: Responsive.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: Responsive.w(40),
                          height: Responsive.w(40),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(
                              Responsive.r(6),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child:
                              product.primaryImageUrl != null &&
                                  product.primaryImageUrl!.isNotEmpty
                              ? Image.network(
                                  product.primaryImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.grey[400],
                                    size: Responsive.icon(18),
                                  ),
                                )
                              : Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.grey[400],
                                  size: Responsive.icon(18),
                                ),
                        ),
                        title: Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.sp(13),
                          ),
                        ),
                        subtitle: Builder(
                          builder: (context) {
                            final rateText =
                                '₹${product.pricePerDay.toStringAsFixed(2)}   ';
                            if (_isCheckingSearchAvailability) {
                              return Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: Responsive.sp(11),
                                  ),
                                  children: [
                                    TextSpan(text: rateText),
                                    TextSpan(
                                      text: 'Checking dates...',
                                      style: TextStyle(
                                        color: Colors.teal.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (sAvail != null) {
                              final int available =
                                  (sAvail['available'] as num?)?.toInt() ?? 0;
                              final int availableWithPriority =
                                  (sAvail['availableWithPriority'] as num?)
                                      ?.toInt() ??
                                  0;

                              String availText = '';
                              Color textColor = Colors.grey[600]!;
                              FontWeight fontWeight = FontWeight.normal;

                              if (available > 0) {
                                availText = '$available free for dates';
                                textColor = AppColors.success;
                              } else if (availableWithPriority > 0) {
                                availText =
                                    '0 free ($availableWithPriority with priority cleaning)';
                                textColor = AppColors.warning;
                              } else {
                                availText = '0 free (Unavailable)';
                                textColor = AppColors.error;
                                fontWeight = FontWeight.bold;
                              }

                              return Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: Responsive.sp(11),
                                  ),
                                  children: [
                                    TextSpan(text: rateText),
                                    TextSpan(
                                      text: availText,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: fontWeight,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Text(
                              '₹${product.pricePerDay.toStringAsFixed(2)}   Stock: ${product.availableQuantity}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: Responsive.sp(11),
                              ),
                            );
                          },
                        ),
                        trailing: isAvail
                            ? Icon(
                                Icons.add_rounded,
                                color: AppColors.primary,
                                size: Responsive.icon(20),
                              )
                            : Icon(
                                Icons.block_rounded,
                                color: Colors.grey,
                                size: Responsive.icon(20),
                              ),
                        onTap: isAvail
                            ? () => _addProductToOrder(product)
                            : null,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
