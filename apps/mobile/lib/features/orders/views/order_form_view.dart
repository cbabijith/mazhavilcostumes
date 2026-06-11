import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../../customers/viewmodels/providers/customer_provider.dart';
import '../../customers/models/customer.dart';
import '../../products/viewmodels/providers/product_provider.dart';
import '../../products/models/product.dart' as p_model;
import '../../branches/viewmodels/providers/branch_provider.dart';
import '../models/order.dart';
import '../viewmodels/providers/order_provider.dart';

class OrderFormView extends ConsumerStatefulWidget {
  final Order? order;

  const OrderFormView({super.key, this.order});

  @override
  ConsumerState<OrderFormView> createState() => _OrderFormViewState();
}

class _OrderFormViewState extends ConsumerState<OrderFormView> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Selected entities details
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  String? _selectedBranchId;

  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _notesController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _advanceAmountController = TextEditingController(text: '0');
  final _amountPaidController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _phoneSearchController = TextEditingController();

  // Customer search state
  bool _showCustomerDropdown = false;
  String _searchQuery = '';

  OrderStatus? _selectedStatus = OrderStatus.pending;
  PaymentStatus? _selectedPaymentStatus = PaymentStatus.pending;
  DeliveryMethod? _selectedDeliveryMethod = DeliveryMethod.pickup;
  final List<OrderItemInput> _items = [];

  // Totals calculations
  int _rentalDays = 1;
  double _subtotal = 0.0;
  double _gstAmount = 0.0;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Default branch ID from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentBranchId = ref.read(effectiveBranchIdProvider);
      if (currentBranchId != null && _selectedBranchId == null) {
        setState(() {
          _selectedBranchId = currentBranchId;
        });
      }
    });

    if (widget.order != null) {
      _selectedCustomerId = widget.order!.customerId;
      _selectedCustomerName = widget.order!.customer?.name ?? 'Linked Customer';
      _phoneSearchController.text = widget.order!.customer?.phone ?? '';
      _selectedBranchId = widget.order!.branchId;
      
      _startDateController.text = widget.order!.startDate;
      _endDateController.text = widget.order!.endDate;
      _eventDateController.text = widget.order!.eventDate;
      _notesController.text = widget.order!.notes ?? '';
      _deliveryAddressController.text = widget.order!.deliveryAddress ?? '';
      _pickupAddressController.text = widget.order!.pickupAddress ?? '';
      _advanceAmountController.text = widget.order!.advanceAmount.toStringAsFixed(0);
      _amountPaidController.text = widget.order!.amountPaid.toStringAsFixed(0);
      _discountController.text = widget.order!.discount.toStringAsFixed(0);
      _selectedStatus = widget.order!.status;
      _selectedPaymentStatus = widget.order!.paymentStatus;
      _selectedDeliveryMethod = widget.order!.deliveryMethod;
      
      if (widget.order!.items != null) {
        _items.addAll(widget.order!.items!.map((item) => OrderItemInput(
              productId: item.productId,
              productName: item.product?.name ?? 'Linked Product',
              quantity: item.quantity,
              pricePerDay: item.pricePerDay,
              gstPercentage: item.gstPercentage,
              isAvailable: true,
            )));
      }
      _calculateTotals();
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _eventDateController.dispose();
    _notesController.dispose();
    _deliveryAddressController.dispose();
    _pickupAddressController.dispose();
    _advanceAmountController.dispose();
    _amountPaidController.dispose();
    _discountController.dispose();
    _phoneSearchController.dispose();
    super.dispose();
  }

  void _calculateTotals() {
    // 1. Calculate rental days (inclusive counting: pickup day + return day)
    if (_startDateController.text.isNotEmpty && _endDateController.text.isNotEmpty) {
      try {
        final start = DateTime.parse(_startDateController.text);
        final end = DateTime.parse(_endDateController.text);
        final diff = end.difference(start).inDays;
        _rentalDays = diff >= 0 ? diff + 1 : 1;
      } catch (_) {
        _rentalDays = 1;
      }
    } else {
      _rentalDays = 1;
    }

    // 2. Pricing multiplier: base price covers first 3 days, each extra day adds 1x
    final pricingMultiplier = (_rentalDays - 2) > 1 ? (_rentalDays - 2) : 1;

    // 3. Sum up items
    double itemsSum = 0.0;
    for (final item in _items) {
      itemsSum += item.quantity * item.pricePerDay * pricingMultiplier;
    }

    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final totalAfterDiscount = itemsSum - discount > 0 ? itemsSum - discount : 0.0;

    // 4. GST-inclusive: the rent amount ALREADY includes GST
    // Formula: base = amount / (1 + rate/100), gst = amount - base
    // When there's an order-level discount, proportionally reduce GST
    double totalGst = 0.0;
    final double ratio = itemsSum > 0 ? totalAfterDiscount / itemsSum : 1.0;

    for (final item in _items) {
      final double lineTotal = item.quantity * item.pricePerDay * pricingMultiplier;
      final double gstRate = item.gstPercentage > 0 ? item.gstPercentage : 18.0; // 18% standard fallback
      final double base = lineTotal / (1 + gstRate / 100);
      final double gst = lineTotal - base;
      totalGst += gst * ratio;
    }

    setState(() {
      _subtotal = itemsSum;
      _gstAmount = totalGst;
      _totalAmount = totalAfterDiscount;
    });
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white, surface: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T')[0];
      });
      _calculateTotals();
      _checkAllItemsAvailability();
    }
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomerId = customer.id;
      _selectedCustomerName = customer.name;
      _phoneSearchController.text = customer.phone;
      _showCustomerDropdown = false;
      _searchQuery = '';
    });
  }

  void _clearCustomer() {
    setState(() {
      _selectedCustomerId = null;
      _selectedCustomerName = null;
      _phoneSearchController.text = '';
      _showCustomerDropdown = false;
      _searchQuery = '';
    });
  }

  void _openAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddCustomerDialog(
        initialPhone: _phoneSearchController.text,
        onCustomerCreated: (customer) {
          _selectCustomer(customer);
        },
      ),
    );
  }

  void _openProductLookup(int itemIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return _SearchSelectorDialog(
          title: 'Select Product',
          hint: 'Search products...',
          fetchList: (query) async {
            final repo = ref.read(productRepositoryProvider);
            final result = await repo.getProducts(search: query);
            return result.products
                .map((p) => _LookupItem(
                      id: p.id,
                      label: p.name,
                      subtitle: 'Rate: ₹${p.pricePerDay.toStringAsFixed(0)}/day  |  Stock: ${p.availableQuantity}',
                      extraData: p,
                    ))
                .toList();
          },
          onSelect: (item) {
            final product = item.extraData as p_model.Product;
            setState(() {
              _items[itemIndex].productId = product.id;
              _items[itemIndex].productName = product.name;
              _items[itemIndex].pricePerDay = product.pricePerDay;
              _items[itemIndex].gstPercentage = product.gstPercentage;
            });
            _calculateTotals();
            _checkItemAvailability(itemIndex);
          },
        );
      },
    );
  }

  Future<void> _checkItemAvailability(int index) async {
    final item = _items[index];
    if (item.productId.isEmpty || _startDateController.text.isEmpty || _endDateController.text.isEmpty || _selectedBranchId == null) return;

    setState(() => item.isChecking = true);
    try {
      final operations = ref.read(orderOperationsProvider);
      final result = await operations.checkAvailability(
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        branchId: _selectedBranchId!,
        items: [
          {
            'product_id': item.productId,
            'quantity': item.quantity,
          }
        ],
      );

      final itemsList = result['items'] as List<dynamic>? ?? [];
      bool isAvail = true;
      int minAvailable = 999;

      for (final i in itemsList) {
        final isItemAvailable = i['isAvailable'] as bool? ?? true;
        final available = i['available'] as int? ?? 0;
        if (!isItemAvailable) {
          isAvail = false;
        }
        if (available < minAvailable) {
          minAvailable = available;
        }
      }

      setState(() {
        item.isAvailable = isAvail;
        item.availableStockInfo = isAvail ? null : 'Conflict (Max avail: $minAvailable)';
        item.isChecking = false;
      });
    } catch (_) {
      setState(() => item.isChecking = false);
    }
  }

  void _checkAllItemsAvailability() {
    for (int i = 0; i < _items.length; i++) {
      _checkItemAvailability(i);
    }
  }

  void _addItem() {
    setState(() {
      _items.add(OrderItemInput());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _calculateTotals();
  }

  Future<void> _submit() async {
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a customer')));
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least 1 item')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    // Check conflict warning
    final hasConflicts = _items.any((i) => !i.isAvailable);
    if (hasConflicts) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Stock Conflicts Detected'),
          content: const Text('Some items do not have enough availability for these dates. Proceed anyway?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text('Proceed'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _isLoading = true);

    final body = {
      'customer_id': _selectedCustomerId,
      'branch_id': _selectedBranchId,
      'rental_start_date': _startDateController.text,
      'rental_end_date': _endDateController.text,
      'event_date': _eventDateController.text.isEmpty ? null : _eventDateController.text,
      'delivery_method': _selectedDeliveryMethod?.name,
      'delivery_address': _deliveryAddressController.text.trim().isEmpty ? null : _deliveryAddressController.text.trim(),
      'pickup_address': _pickupAddressController.text.trim().isEmpty ? null : _pickupAddressController.text.trim(),
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      'items': _items.where((item) => item.productId.isNotEmpty).map((item) => {
        'product_id': item.productId,
        'quantity': item.quantity,
        'price_per_day': item.pricePerDay,
      }).toList(),
    };

    if (widget.order != null) {
      body.addAll({
        'status': _selectedStatus?.name,
        'advance_amount': double.tryParse(_advanceAmountController.text) ?? 0,
        'amount_paid': double.tryParse(_amountPaidController.text) ?? 0,
        'payment_status': _selectedPaymentStatus?.name,
        'discount': double.tryParse(_discountController.text) ?? 0,
      });
    }

    try {
      if (widget.order != null) {
        await ref.read(orderOperationsProvider).updateOrder(widget.order!.id, body);
      } else {
        await ref.read(orderOperationsProvider).createOrder(body);
      }

      if (mounted) {
        // Selective invalidation - only invalidate list, not individual order cache
        ref.invalidate(ordersProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isEditing = widget.order != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Order' : 'Create Order',
            style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold, color: AppColors.primary)),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: Responsive.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader('Fulfillment Basics'),
                    _buildCard(children: [
                      // Customer Search Field with Dropdown
                      _buildCustomerSearchField(),
                      SizedBox(height: Responsive.h(12)),
                      // Dates Selectors
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: 'Start Date',
                              controller: _startDateController,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          SizedBox(width: Responsive.w(12)),
                          Expanded(
                            child: _buildDateField(
                              label: 'End Date',
                              controller: _endDateController,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(12)),
                      _buildDateField(
                        label: 'Event Date',
                        controller: _eventDateController,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ]),
                    SizedBox(height: Responsive.h(16)),
                    _buildSectionHeader('Rent Items'),
                    ..._items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildItemCard(item, index);
                    }),
                    SizedBox(height: Responsive.h(8)),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: Responsive.symmetric(vertical: 12),
                      ),
                      onPressed: _addItem,
                      icon: Icon(Icons.add_rounded, size: Responsive.icon(20)),
                      label: Text('Add costume item', style: TextStyle(fontSize: Responsive.sp(13))),
                    ),
                    SizedBox(height: Responsive.h(16)),
                    _buildSectionHeader('Pricing Summary'),
                    _buildCard(children: [
                      _buildTotalSummaryRow('Subtotal', '₹${_subtotal.toStringAsFixed(2)}'),
                      _buildTotalSummaryRow('GST (18% Standard)', '₹${_gstAmount.toStringAsFixed(2)}'),
                      SizedBox(height: Responsive.h(8)),
                      TextFormField(
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: Responsive.sp(14)),
                        decoration: InputDecoration(
                          labelText: 'Flat Discount (₹)',
                          contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (_) => _calculateTotals(),
                      ),
                      const Divider(height: 24),
                      _buildTotalSummaryRow('Grand Total', '₹${_totalAmount.toStringAsFixed(2)}', isBold: true),
                      if (isEditing) ...[
                        SizedBox(height: Responsive.h(12)),
                        TextFormField(
                          controller: _advanceAmountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: Responsive.sp(14)),
                          decoration: InputDecoration(
                            labelText: 'Advance Collected (₹)',
                            contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        TextFormField(
                          controller: _amountPaidController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: Responsive.sp(14)),
                          decoration: InputDecoration(
                            labelText: 'Amount Paid (₹)',
                            contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ]),
                    SizedBox(height: Responsive.h(16)),
                    _buildSectionHeader('Logistics & Notes'),
                    _buildCard(children: [
                      DropdownButtonFormField<DeliveryMethod>(
                        initialValue: _selectedDeliveryMethod,
                        style: TextStyle(fontSize: Responsive.sp(14), color: AppColors.primary),
                        decoration: InputDecoration(
                          labelText: 'Fulfillment Method',
                          contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: DeliveryMethod.values.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDeliveryMethod = value;
                          });
                        },
                      ),
                      SizedBox(height: Responsive.h(12)),
                      if (_selectedDeliveryMethod == DeliveryMethod.delivery) ...[
                        TextFormField(
                          controller: _deliveryAddressController,
                          style: TextStyle(fontSize: Responsive.sp(14)),
                          decoration: InputDecoration(
                            labelText: 'Delivery Address',
                            contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(height: Responsive.h(12)),
                      ],
                      if (_selectedDeliveryMethod == DeliveryMethod.pickup) ...[
                        TextFormField(
                          controller: _pickupAddressController,
                          style: TextStyle(fontSize: Responsive.sp(14)),
                          decoration: InputDecoration(
                            labelText: 'Pickup Branch Location',
                            contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(height: Responsive.h(12)),
                      ],
                      TextFormField(
                        controller: _notesController,
                        style: TextStyle(fontSize: Responsive.sp(14)),
                        decoration: InputDecoration(
                          labelText: 'Order Notes',
                          contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        maxLines: 2,
                      ),
                      if (isEditing) ...[
                        SizedBox(height: Responsive.h(12)),
                        DropdownButtonFormField<OrderStatus>(
                          initialValue: _selectedStatus,
                          style: TextStyle(fontSize: Responsive.sp(14), color: AppColors.primary),
                          decoration: InputDecoration(
                            labelText: 'Order Status',
                            contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: OrderStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedStatus = val),
                        ),
                        SizedBox(height: Responsive.h(12)),
                        DropdownButtonFormField<PaymentStatus>(
                          initialValue: _selectedPaymentStatus,
                          style: TextStyle(fontSize: Responsive.sp(14), color: AppColors.primary),
                          decoration: InputDecoration(
                            labelText: 'Payment Status',
                            contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: PaymentStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedPaymentStatus = val),
                        ),
                      ],
                    ]),
                    SizedBox(height: Responsive.h(24)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: Responsive.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _submit,
                      child: Text(
                        isEditing ? 'Update Order Details' : 'Place Rental Booking',
                        style: TextStyle(fontSize: Responsive.sp(14), fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: Responsive.h(40)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: Responsive.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: Responsive.sp(13), fontWeight: FontWeight.bold, color: Colors.grey[700]),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
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
                Icon(Icons.person_rounded, color: AppColors.primary, size: Responsive.icon(20)),
                SizedBox(width: Responsive.w(8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer', style: TextStyle(fontSize: Responsive.sp(10), color: Colors.grey)),
                      SizedBox(height: Responsive.h(2)),
                      Text(_selectedCustomerName ?? '', style: TextStyle(fontSize: Responsive.sp(14), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.clear_rounded, color: Colors.grey[600], size: Responsive.icon(20)),
                  onPressed: _clearCustomer,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ] else ...[
          // Phone search input
          TextField(
            controller: _phoneSearchController,
            keyboardType: TextInputType.phone,
            style: TextStyle(fontSize: Responsive.sp(14)),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter phone to search...',
              hintStyle: TextStyle(fontSize: Responsive.sp(14), color: Colors.grey),
              prefixIcon: Icon(Icons.search_rounded, size: Responsive.icon(20)),
              suffixIcon: _phoneSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, size: Responsive.icon(18)),
                      onPressed: () {
                        _phoneSearchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _showCustomerDropdown = false;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(8))),
              contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _showCustomerDropdown = value.length >= 3;
              });
              // Trigger hybrid search
              if (value.length >= 3) {
                ref.read(customerSearchProvider.notifier).search(value);
              } else {
                ref.read(customerSearchProvider.notifier).clear();
              }
            },
            onTap: () {
              if (_phoneSearchController.text.length >= 3) {
                setState(() => _showCustomerDropdown = true);
              }
            },
          ),
        ],
        // Customer dropdown
        if (_showCustomerDropdown && _selectedCustomerId == null) ...[
          SizedBox(height: Responsive.h(4)),
          _CustomerSearchDropdown(
            searchQuery: _searchQuery,
            onSelectCustomer: _selectCustomer,
            onAddCustomer: _openAddCustomerDialog,
            onClose: () => setState(() => _showCustomerDropdown = false),
          ),
        ],
      ],
    );
  }

  Widget _buildLookupField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.r(8)),
      child: Container(
        padding: Responsive.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(Responsive.r(8)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: Responsive.icon(20)),
            SizedBox(width: Responsive.w(8)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: Responsive.sp(10), color: Colors.grey)),
                  SizedBox(height: Responsive.h(2)),
                  Text(value, style: TextStyle(fontSize: Responsive.sp(14), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(fontSize: Responsive.sp(14)),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(Icons.calendar_today_rounded, size: Responsive.icon(18)),
        contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onTap: () => _selectDate(controller),
      validator: validator,
    );
  }

  Widget _buildItemCard(OrderItemInput item, int index) {
    return Container(
      margin: Responsive.only(bottom: 12),
      padding: Responsive.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(12)),
        border: Border.all(color: item.isAvailable ? Colors.transparent : Colors.red.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Costume #${index + 1}',
                  style: TextStyle(fontSize: Responsive.sp(12), fontWeight: FontWeight.bold, color: AppColors.primary)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.red[400], size: Responsive.icon(20)),
                onPressed: () => _removeItem(index),
              ),
            ],
          ),
          _buildLookupField(
            label: 'Costume Product',
            value: item.productName.isEmpty ? 'Select costume...' : item.productName,
            icon: Icons.search_rounded,
            onTap: () => _openProductLookup(index),
          ),
          SizedBox(height: Responsive.h(12)),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.quantity.toString(),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: Responsive.sp(14)),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    setState(() {
                      item.quantity = int.tryParse(val) ?? 1;
                    });
                    _calculateTotals();
                    _checkItemAvailability(index);
                  },
                ),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: TextFormField(
                  key: ValueKey('rate_$index'),
                  initialValue: item.pricePerDay.toStringAsFixed(0),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: Responsive.sp(14)),
                  decoration: InputDecoration(
                    labelText: 'Rate/day (₹)',
                    contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    setState(() {
                      item.pricePerDay = double.tryParse(val) ?? 0.0;
                    });
                    _calculateTotals();
                  },
                ),
              ),
            ],
          ),
          if (item.isChecking)
            Padding(
              padding: Responsive.only(top: 8),
              child: Row(
                children: [
                  SizedBox(
                      width: Responsive.w(12),
                      height: Responsive.w(12),
                      child: const CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary)),
                  SizedBox(width: Responsive.w(6)),
                  Text('Checking availability...', style: TextStyle(fontSize: Responsive.sp(11), color: Colors.grey)),
                ],
              ),
            )
          else if (item.availableStockInfo != null)
            Padding(
              padding: Responsive.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: Responsive.icon(16)),
                  SizedBox(width: Responsive.w(4)),
                  Text(item.availableStockInfo!, style: TextStyle(fontSize: Responsive.sp(11), color: Colors.orange)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: Responsive.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.sp(13),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primary : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.sp(13),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primary : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderItemInput {
  String productId = '';
  String productName = '';
  int quantity = 1;
  double pricePerDay = 0.0;
  double gstPercentage = 0.0;
  bool isAvailable = true;
  bool isChecking = false;
  String? availableStockInfo;

  OrderItemInput({
    this.productId = '',
    this.productName = '',
    this.quantity = 1,
    this.pricePerDay = 0.0,
    this.gstPercentage = 0.0,
    this.isAvailable = true,
  });
}

class _LookupItem {
  final String id;
  final String label;
  final String subtitle;
  final dynamic extraData;

  _LookupItem({required this.id, required this.label, required this.subtitle, this.extraData});
}

class _SearchSelectorDialog extends StatefulWidget {
  final String title;
  final String hint;
  final Future<List<_LookupItem>> Function(String) fetchList;
  final ValueChanged<_LookupItem> onSelect;

  const _SearchSelectorDialog({
    required this.title,
    required this.hint,
    required this.fetchList,
    required this.onSelect,
  });

  @override
  State<_SearchSelectorDialog> createState() => _SearchSelectorDialogState();
}

class _SearchSelectorDialogState extends State<_SearchSelectorDialog> {
  final _searchController = TextEditingController();
  List<_LookupItem> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _triggerSearch('');
  }

  Future<void> _triggerSearch(String query) async {
    setState(() => _loading = true);
    try {
      final list = await widget.fetchList(query);
      setState(() {
        _results = list;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(14))),
      child: Padding(
        padding: Responsive.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold)),
            SizedBox(height: Responsive.h(12)),
            TextField(
              controller: _searchController,
              style: TextStyle(fontSize: Responsive.sp(14)),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(fontSize: Responsive.sp(14), color: Colors.grey),
                prefixIcon: Icon(Icons.search, size: Responsive.icon(20)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(10))),
                contentPadding: Responsive.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (val) {
                _triggerSearch(val);
              },
            ),
            SizedBox(height: Responsive.h(12)),
            Container(
              constraints: BoxConstraints(maxHeight: Responsive.h(250)),
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _results.isEmpty
                      ? const Center(child: Text('No results found.'))
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _results.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                             final item = _results[i];
                             return ListTile(
                               contentPadding: Responsive.symmetric(horizontal: 8, vertical: 4),
                               title: Text(item.label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.sp(14))),
                               subtitle: Text(item.subtitle, style: TextStyle(color: Colors.grey[600], fontSize: Responsive.sp(12))),
                               onTap: () {
                                 widget.onSelect(item);
                                 Navigator.pop(context);
                               },
                             );
                          },
                        ),
            ),
            SizedBox(height: Responsive.h(12)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(color: AppColors.primary, fontSize: Responsive.sp(13))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerSearchDropdown extends ConsumerWidget {
  final String searchQuery;
  final Function(Customer) onSelectCustomer;
  final VoidCallback onAddCustomer;
  final VoidCallback onClose;

  const _CustomerSearchDropdown({
    required this.searchQuery,
    required this.onSelectCustomer,
    required this.onAddCustomer,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Responsive.init(context);
    
    // Use hybrid search provider for 0ms local search + debounced remote search
    final searchState = ref.watch(customerSearchProvider);
    final customers = searchState.results;

    return Container(
      constraints: BoxConstraints(maxHeight: Responsive.h(200)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: searchState.isLoading && customers.isEmpty
          ? Center(
              child: Padding(
                padding: Responsive.all(16),
                child: const CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          : searchState.error != null && customers.isEmpty
              ? Center(
                  child: Padding(
                    padding: Responsive.all(16),
                    child: Text('Error loading customers', style: TextStyle(color: Colors.red, fontSize: Responsive.sp(12))),
                  ),
                )
              : customers.isEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: Responsive.all(16),
                          child: Text(
                            'No customer found',
                            style: TextStyle(color: Colors.grey[600], fontSize: Responsive.sp(13)),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: Responsive.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            border: Border(top: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: InkWell(
                            onTap: () {
                              onClose();
                              onAddCustomer();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded, color: AppColors.primary, size: Responsive.icon(18)),
                                SizedBox(width: Responsive.w(8)),
                                Text(
                                  'Add New Customer',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: Responsive.sp(13),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: customers.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return ListTile(
                          contentPadding: Responsive.symmetric(horizontal: 12, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                              style: TextStyle(color: AppColors.primary, fontSize: Responsive.sp(14), fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            customer.name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.sp(13)),
                          ),
                          subtitle: Text(
                            customer.phone,
                            style: TextStyle(color: Colors.grey[600], fontSize: Responsive.sp(11)),
                          ),
                          onTap: () {
                            onSelectCustomer(customer);
                            onClose();
                          },
                        );
                      },
                    ),
    );
  }
}

class _AddCustomerDialog extends ConsumerStatefulWidget {
  final String initialPhone;
  final Function(Customer) onCustomerCreated;

  const _AddCustomerDialog({
    required this.initialPhone,
    required this.onCustomerCreated,
  });

  @override
  ConsumerState<_AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<_AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.initialPhone;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final operations = ref.read(customerOperationsProvider);
      final customer = await operations.createCustomer({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      });

      if (mounted) {
        widget.onCustomerCreated(customer);
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create customer: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(14))),
      child: Padding(
        padding: Responsive.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add New Customer',
              style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            SizedBox(height: Responsive.h(20)),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontSize: Responsive.sp(14)),
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(8))),
                      contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      if (value.trim().length < 10) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Responsive.h(12)),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(fontSize: Responsive.sp(14)),
                    decoration: InputDecoration(
                      labelText: 'Name *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(8))),
                      contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Responsive.h(12)),
                  TextFormField(
                    controller: _addressController,
                    style: TextStyle(fontSize: Responsive.sp(14)),
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(8))),
                      contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(20)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(8))),
                      padding: Responsive.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(fontSize: Responsive.sp(13))),
                  ),
                ),
                SizedBox(width: Responsive.w(12)),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(8))),
                      padding: Responsive.symmetric(vertical: 12),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Save', style: TextStyle(fontSize: Responsive.sp(13), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
