part of '../order_form_view.dart';

extension _OrderFormCustomerSection on _OrderFormViewState {
  Widget _buildSectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: Responsive.only(
        bottom: AppSizes.spacingSmall,
        left: AppSizes.spacingTiny,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: Responsive.icon(AppSizes.iconTiny),
              color: Colors.grey[600],
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontMedium),
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: Responsive.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildCustomerSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Selected customer display or search input
        if (_selectedCustomerId != null) ...[
          Container(
            padding: Responsive.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(Responsive.r(8)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: Responsive.icon(20),
                ),
                SizedBox(width: Responsive.w(8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer',
                        style: TextStyle(
                          fontSize: Responsive.sp(10),
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: Responsive.h(2)),
                      Text(
                        _selectedCustomerName ?? '',
                        style: TextStyle(
                          fontSize: Responsive.sp(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Colors.grey[600],
                    size: Responsive.icon(20),
                  ),
                  onPressed: _clearCustomer,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ] else ...[
          // Name/phone search input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneSearchController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: Responsive.sp(14)),
                  decoration: InputDecoration(
                    labelText: 'Customer',
                    hintText: 'Search customer by name or phone...',
                    hintStyle: TextStyle(
                      fontSize: Responsive.sp(14),
                      color: Colors.grey,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: Responsive.icon(20),
                    ),
                    suffixIcon: _phoneSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              size: Responsive.icon(18),
                            ),
                            onPressed: () {
                              _phoneSearchController.clear();
                              _update(() {
                                _searchQuery = '';
                                _showCustomerDropdown = false;
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
                      _searchQuery = value;
                      _showCustomerDropdown = value.isNotEmpty;
                    });
                    // Trigger hybrid search
                    if (value.isNotEmpty) {
                      ref.read(customerSearchProvider.notifier).search(value);
                    } else {
                      ref.read(customerSearchProvider.notifier).clear();
                    }
                  },
                  onTap: () {
                    if (_phoneSearchController.text.isNotEmpty) {
                      _update(() => _showCustomerDropdown = true);
                    }
                  },
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              Container(
                height: Responsive.h(48),
                width: Responsive.h(48),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(Responsive.r(8)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Responsive.r(8)),
                    onTap: _openAddCustomerDialog,
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      color: AppColors.primary,
                      size: Responsive.icon(22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        // Customer dropdown
        if (_showCustomerDropdown && _selectedCustomerId == null) ...[
          SizedBox(height: Responsive.h(4)),
          CustomerSearchDropdown(
            searchQuery: _searchQuery,
            onSelectCustomer: _selectCustomer,
            onAddCustomer: _openAddCustomerDialog,
            onClose: () => _update(() => _showCustomerDropdown = false),
          ),
        ],
      ],
    );
  }
}
