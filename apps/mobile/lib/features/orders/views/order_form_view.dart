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
import '../../../core/supabase/api_client.dart';


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
  final Set<String> _expandedBookings = {};

  // Totals calculations
  int _rentalDays = 1;
  double _subtotal = 0.0;
  double _gstAmount = 0.0;
  double _totalAmount = 0.0;

  // Parity with website settings and discount types
  bool _isGstEnabled = false;
  String _orderDiscountType = 'flat'; // 'flat' | 'percent'
  PaymentMethod? _advancePaymentMethod = PaymentMethod.cash;

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
      _orderDiscountType = widget.order!.discountType;
      _advancePaymentMethod = widget.order!.advancePaymentMethod ?? PaymentMethod.cash;
      
      if (widget.order!.items != null) {
        _items.addAll(widget.order!.items!.map((item) => OrderItemInput(
              productId: item.productId,
              productName: item.product?.name ?? 'Linked Product',
              quantity: item.quantity,
              pricePerDay: item.pricePerDay,
              gstPercentage: item.gstPercentage,
              isAvailable: true,
              discount: item.discount,
              discountType: item.discountType,
            )));
      }
      _calculateTotals();
    }
    _fetchGstSettings();
  }

  Future<void> _fetchGstSettings() async {
    try {
      final response = await apiClient.get('/settings?key=is_gst_enabled');
      if (response.statusCode == 200 && response.data != null) {
        final val = response.data['data']?['value'];
        setState(() {
          _isGstEnabled = val == true || val == 'true';
        });
        _calculateTotals();
      }
    } catch (e) {
      print('Error fetching GST settings: $e');
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
    double subtotal = 0.0;
    double itemDiscountTotal = 0.0;
    double totalGstAmount = 0.0;

    for (final item in _items) {
      final double lineTotal = item.quantity * item.pricePerDay * pricingMultiplier;
      final double itemDisc = item.discountType == 'percent'
          ? lineTotal * (item.discount / 100)
          : item.discount * item.quantity;
      final double effectiveDisc = itemDisc < lineTotal ? itemDisc : lineTotal;

      subtotal += lineTotal;
      itemDiscountTotal += effectiveDisc;

      final double lineAfterDiscount = lineTotal - effectiveDisc;
      final double gstRate = item.gstPercentage;

      if (_isGstEnabled && gstRate > 0) {
        final double base = lineAfterDiscount / (1 + gstRate / 100);
        final double gst = lineAfterDiscount - base;
        totalGstAmount += gst;
      }
    }

    final double afterItemDiscount = subtotal - itemDiscountTotal;

    // Order-level discount
    final double orderDiscountInput = double.tryParse(_discountController.text) ?? 0.0;
    final double orderDiscAmt = _orderDiscountType == 'percent'
        ? afterItemDiscount * (orderDiscountInput / 100)
        : orderDiscountInput;
    final double effectiveOrderDiscount = orderDiscAmt < afterItemDiscount ? orderDiscAmt : afterItemDiscount;

    final double afterAllDiscounts = afterItemDiscount - effectiveOrderDiscount;
    double gstAmount = totalGstAmount;

    if (effectiveOrderDiscount > 0 && afterItemDiscount > 0) {
      final double ratio = afterAllDiscounts / afterItemDiscount;
      gstAmount = totalGstAmount * ratio;
    }

    setState(() {
      _subtotal = subtotal;
      _gstAmount = gstAmount;
      _totalAmount = afterAllDiscounts;
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
        excludeOrderId: widget.order?.id,
      );

      final itemsList = result['items'] as List<dynamic>? ?? [];
      if (itemsList.isNotEmpty) {
        final i = itemsList.first;
        final isItemAvailable = i['isAvailable'] as bool? ?? true;
        final available = i['available'] as int? ?? 0;
        final availableWithPriority = i['availableWithPriority'] as int? ?? 0;
        final priorityCleaningNeeded = i['priorityCleaningNeeded'] as bool? ?? false;
        final priorityCleaningInfo = i['priorityCleaningInfo'] as List<dynamic>? ?? [];
        final overlappingOrders = i['overlappingOrders'] as List<dynamic>? ?? [];

        setState(() {
          item.isAvailable = isItemAvailable;
          item.available = available;
          item.availableWithPriority = availableWithPriority;
          item.priorityCleaningNeeded = priorityCleaningNeeded;
          item.priorityCleaningInfo = priorityCleaningInfo;
          item.overlappingOrders = overlappingOrders;
          item.isChecking = false;

          if (!isItemAvailable) {
            item.availableStockInfo = 'Conflict (Max avail: $availableWithPriority)';
          } else if (priorityCleaningNeeded) {
            item.availableStockInfo = 'Priority cleaning needed (Avail: $available, Max with Priority: $availableWithPriority)';
          } else {
            item.availableStockInfo = null;
          }
        });
      } else {
        setState(() {
          item.isChecking = false;
        });
      }
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

    // Date validation: return date cannot be before pickup date
    if (_startDateController.text.isNotEmpty && _endDateController.text.isNotEmpty) {
      final start = DateTime.parse(_startDateController.text);
      final end = DateTime.parse(_endDateController.text);
      if (end.isBefore(start)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Return date cannot be earlier than pickup date')),
        );
        return;
      }
    }

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

    // Check priority cleaning items flow (only for new orders)
    final List<OrderItemInput> priorityItems = _items.where((item) {
      return item.productId.isNotEmpty && 
             item.priorityCleaningNeeded && 
             item.quantity > item.available;
    }).toList();

    bool confirmPriority = false;
    if (priorityItems.isNotEmpty && widget.order == null) {
      final List<Map<String, dynamic>> infoList = [];
      for (final item in priorityItems) {
        final neededExtra = item.quantity - item.available;
        if (neededExtra <= 0) continue;

        int accumulated = 0;
        for (final info in item.priorityCleaningInfo) {
          if (accumulated >= neededExtra) break;
          final returningQuantity = info['returningQuantity'] as int? ?? 0;
          final useFromThis = returningQuantity < (neededExtra - accumulated)
              ? returningQuantity
              : (neededExtra - accumulated);
          
          infoList.add({
            'productName': item.productName,
            'direction': info['direction'],
            'usedQuantity': useFromThis,
            'returningQuantity': returningQuantity,
            'returningOrderCustomer': info['returningOrderCustomer'],
            'returningOrderEndDate': info['returningOrderEndDate'],
            'returningOrderStartDate': info['returningOrderStartDate'],
          });
          accumulated += useFromThis;
        }
      }

      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Row(
              children: [
                Icon(Icons.flash_on_rounded, color: AppColors.warning, size: Responsive.icon(24)),
                SizedBox(width: Responsive.w(8)),
                Text(
                  'Priority Cleaning Required',
                  style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'The following products need priority cleaning to fulfill this order. Staff will be notified in the Cleaning Queue.',
                    style: TextStyle(fontSize: Responsive.sp(12), color: Colors.grey[600]),
                  ),
                  SizedBox(height: Responsive.h(12)),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: infoList.length,
                      separatorBuilder: (_, __) => SizedBox(height: Responsive.h(6)),
                      itemBuilder: (context, i) {
                        final info = infoList[i];
                        final productName = info['productName'] as String;
                        final direction = info['direction'] as String;
                        final usedQty = info['usedQuantity'] as int;
                        final returningQty = info['returningQuantity'] as int;
                        final customer = info['returningOrderCustomer'] as String? ?? 'Unknown';
                        
                        String formatDt(String d) {
                          if (d.isEmpty) return '';
                          try {
                            final date = DateTime.parse(d);
                            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            return '${months[date.month - 1]} ${date.day}';
                          } catch (_) {
                            return d;
                          }
                        }

                        String desc = '';
                        if (direction == 'returning_before') {
                          final returningDate = info['returningOrderEndDate'] as String? ?? '';
                          desc = '${usedQty == returningQty ? returningQty : "$usedQty of $returningQty"} units — rush-clean from $customer (returning ${formatDt(returningDate)})';
                        } else {
                          final pickupDate = info['returningOrderStartDate'] as String? ?? '';
                          desc = '$usedQty ${usedQty == 1 ? 'unit' : 'units'} — skip prep for $customer (pickup ${formatDt(pickupDate)})';
                        }

                        return Container(
                          padding: Responsive.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.05),
                            border: Border.all(color: AppColors.warning.withValues(alpha: 0.15)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: TextStyle(fontSize: Responsive.sp(12), fontWeight: FontWeight.bold, color: Colors.grey[800]),
                              ),
                              SizedBox(height: Responsive.h(2)),
                              Text(
                                desc,
                                style: TextStyle(fontSize: Responsive.sp(11), color: AppColors.warning, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontSize: Responsive.sp(13))),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context, true),
                icon: Icon(Icons.flash_on_rounded, size: Responsive.icon(16)),
                label: Text('Confirm & Create', style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.sp(13))),
              ),
            ],
          );
        },
      );

      if (proceed != true) return;
      confirmPriority = true;
    }

    setState(() => _isLoading = true);

    final double advanceAmount = double.tryParse(_advanceAmountController.text) ?? 0.0;
    
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
      'discount': double.tryParse(_discountController.text) ?? 0.0,
      'discount_type': _orderDiscountType,
      'advance_amount': advanceAmount,
      'advance_collected': advanceAmount > 0,
      'advance_payment_method': advanceAmount > 0 ? _advancePaymentMethod?.name : null,
      'subtotal': _subtotal,
      'gst_amount': _gstAmount,
      'total_amount': _totalAmount,
      'amount_paid': widget.order != null ? (double.tryParse(_amountPaidController.text) ?? advanceAmount) : advanceAmount,
      'payment_status': widget.order != null 
          ? _selectedPaymentStatus?.name 
          : (advanceAmount > 0 
              ? (advanceAmount >= _totalAmount ? 'paid' : 'partial')
              : 'pending'),
      'items': _items.where((item) => item.productId.isNotEmpty).map((item) => {
        'product_id': item.productId,
        'quantity': item.quantity,
        'price_per_day': item.pricePerDay,
        'discount': item.discount,
        'discount_type': item.discountType,
      }).toList(),
    };

    if (widget.order != null) {
      body.addAll({
        'status': _selectedStatus?.name,
      });
    } else {
      body.addAll({
        'priority_cleaning_confirmed': confirmPriority,
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

    // Listen to customerSearchProvider to keep it alive during typing
    ref.listen(customerSearchProvider, (_, __) {});

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
                      _buildTotalSummaryRow('GST (incl.)', '₹${_gstAmount.toStringAsFixed(2)}'),
                      SizedBox(height: Responsive.h(8)),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _discountController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: Responsive.sp(14)),
                              decoration: InputDecoration(
                                labelText: 'Order Discount',
                                contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onChanged: (_) => _calculateTotals(),
                            ),
                          ),
                          SizedBox(width: Responsive.w(8)),
                          Container(
                            height: Responsive.h(48),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildDiscountTypeToggleButton(
                                  label: '₹',
                                  isSelected: _orderDiscountType == 'flat',
                                  onTap: () {
                                    setState(() {
                                      _orderDiscountType = 'flat';
                                    });
                                    _calculateTotals();
                                  },
                                ),
                                Container(width: 1, color: Colors.grey.shade300, height: Responsive.h(24)),
                                _buildDiscountTypeToggleButton(
                                  label: '%',
                                  isSelected: _orderDiscountType == 'percent',
                                  onTap: () {
                                    setState(() {
                                      _orderDiscountType = 'percent';
                                    });
                                    _calculateTotals();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildTotalSummaryRow('Grand Total', '₹${_totalAmount.toStringAsFixed(2)}', isBold: true),
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
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                      if ((double.tryParse(_advanceAmountController.text) ?? 0.0) > 0.0) ...[
                        SizedBox(height: Responsive.h(12)),
                        DropdownButtonFormField<PaymentMethod>(
                          value: _advancePaymentMethod,
                          style: TextStyle(fontSize: Responsive.sp(14), color: AppColors.primary),
                          decoration: InputDecoration(
                            labelText: 'Advance Payment Method',
                            contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: PaymentMethod.values.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(method.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _advancePaymentMethod = val;
                            });
                          },
                        ),
                      ],
                      if (isEditing) ...[
                        SizedBox(height: Responsive.h(12)),
                        TextFormField(
                          controller: _amountPaidController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: Responsive.sp(14)),
                          decoration: InputDecoration(
                            labelText: 'Total Amount Paid (₹)',
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
          // Name/phone search input
          TextField(
            controller: _phoneSearchController,
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: Responsive.sp(14)),
            decoration: InputDecoration(
              labelText: 'Customer',
              hintText: 'Search customer by name or phone...',
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

  Widget _buildDiscountTypeToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: Responsive.symmetric(horizontal: 16),
        height: double.infinity,
        alignment: Alignment.center,
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        child: Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(14),
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingRow(dynamic b) {
    final String customerName = b['customerName'] as String? ?? 'Unknown';
    final int qty = b['quantity'] as int? ?? 1;
    final String startStr = b['startDate'] as String? ?? '';
    final String endStr = b['endDate'] as String? ?? '';
    final String? bufferStart = b['bufferStartDate'] as String?;
    final String? bufferEnd = b['bufferEndDate'] as String?;
    final bool bufferSkipped = b['bufferSkipped'] as bool? ?? false;

    String formatDt(String d) {
      if (d.isEmpty) return '';
      try {
        final date = DateTime.parse(d);
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[date.month - 1]} ${date.day}';
      } catch (_) {
        return d;
      }
    }

    final dateRange = '${formatDt(startStr)} – ${formatDt(endStr)}';
    
    return Container(
      padding: Responsive.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$customerName — $qty ${qty > 1 ? 'units' : 'unit'}',
                  style: TextStyle(fontSize: Responsive.sp(11), fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                dateRange,
                style: TextStyle(fontSize: Responsive.sp(10), color: Colors.grey.shade600),
              ),
            ],
          ),
          if (bufferStart != null && bufferEnd != null) ...[
            SizedBox(height: Responsive.h(2)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bufferSkipped ? 'Gap: Skipped (Priority Cleaning ON)' : 'Gap: ${formatDt(bufferStart)} & ${formatDt(bufferEnd)}',
                  style: TextStyle(
                    fontSize: Responsive.sp(9),
                    color: bufferSkipped ? Colors.grey.shade400 : AppColors.warning,
                    fontWeight: FontWeight.bold,
                    decoration: bufferSkipped ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemCard(OrderItemInput item, int index) {
    return Container(
      margin: Responsive.only(bottom: 12),
      padding: Responsive.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(12)),
        border: Border.all(color: item.isAvailable ? Colors.transparent : AppColors.error.withValues(alpha: 0.2), width: 1.5),
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
                icon: Icon(Icons.delete_outline_rounded, color: AppColors.error.withValues(alpha: 0.8), size: Responsive.icon(20)),
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
          SizedBox(height: Responsive.h(12)),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.discount == 0.0 ? '' : item.discount.toStringAsFixed(0),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: Responsive.sp(14)),
                  decoration: InputDecoration(
                    labelText: 'Item Discount',
                    hintText: '0',
                    contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    setState(() {
                      item.discount = double.tryParse(val) ?? 0.0;
                    });
                    _calculateTotals();
                  },
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              Container(
                height: Responsive.h(48),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDiscountTypeToggleButton(
                      label: '₹',
                      isSelected: item.discountType == 'flat',
                      onTap: () {
                        setState(() {
                          item.discountType = 'flat';
                        });
                        _calculateTotals();
                      },
                    ),
                    Container(width: 1, color: Colors.grey.shade300, height: Responsive.h(24)),
                    _buildDiscountTypeToggleButton(
                      label: '%',
                      isSelected: item.discountType == 'percent',
                      onTap: () {
                        setState(() {
                          item.discountType = 'percent';
                        });
                        _calculateTotals();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Live Availability Badge
          if (item.productId.isNotEmpty) ...[
            SizedBox(height: Responsive.h(8)),
            Container(
              padding: Responsive.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: item.isChecking 
                    ? Colors.grey.shade50 
                    : (item.isAvailable 
                        ? AppColors.success.withValues(alpha: 0.1) 
                        : AppColors.error.withValues(alpha: 0.1)),
                border: Border.all(
                  color: item.isChecking
                      ? Colors.grey.shade200
                      : (item.isAvailable
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.error.withValues(alpha: 0.2)),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  if (item.isChecking) ...[
                    SizedBox(
                      width: Responsive.w(12),
                      height: Responsive.w(12),
                      child: const CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
                    ),
                    SizedBox(width: Responsive.w(6)),
                    Text(
                      'Checking availability...',
                      style: TextStyle(fontSize: Responsive.sp(11), color: Colors.grey),
                    ),
                  ] else ...[
                    Icon(
                      item.isAvailable ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                      color: item.isAvailable ? AppColors.success : AppColors.error,
                      size: Responsive.icon(16),
                    ),
                    SizedBox(width: Responsive.w(6)),
                    Expanded(
                      child: Text(
                        item.isAvailable
                            ? '${item.available} of ${item.availableWithPriority} free for this period' + 
                              (item.priorityCleaningNeeded ? ' (with priority cleaning)' : '')
                            : 'Unavailable — only ${item.available} free (need ${item.quantity})',
                        style: TextStyle(
                          fontSize: Responsive.sp(11),
                          fontWeight: FontWeight.bold,
                          color: item.isAvailable ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          // Auto Priority Cleaning Warning Banner
          if (item.productId.isNotEmpty && item.priorityCleaningNeeded && item.quantity > item.available) ...[
            SizedBox(height: Responsive.h(8)),
            Container(
              padding: Responsive.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flash_on_rounded, color: AppColors.warning, size: Responsive.icon(16)),
                      SizedBox(width: Responsive.w(4)),
                      Expanded(
                        child: Text(
                          '${item.available} freely available, need ${item.quantity - item.available} via priority cleaning',
                          style: TextStyle(
                            fontSize: Responsive.sp(11),
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...(() {
                    final neededExtra = item.quantity - item.available;
                    int accumulated = 0;
                    final List<Widget> list = [];
                    for (final info in item.priorityCleaningInfo) {
                      if (accumulated >= neededExtra) break;
                      final returningQuantity = info['returningQuantity'] as int? ?? 0;
                      final useFromThis = returningQuantity < (neededExtra - accumulated)
                          ? returningQuantity
                          : (neededExtra - accumulated);
                      
                      final String direction = info['direction'] as String? ?? '';
                      final String customer = info['returningOrderCustomer'] as String? ?? 'Unknown';
                      
                      String formatDt(String d) {
                        if (d.isEmpty) return '';
                        try {
                          final date = DateTime.parse(d);
                          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          return '${months[date.month - 1]} ${date.day}';
                        } catch (_) {
                          return d;
                        }
                      }

                      Widget textWidget;
                      if (direction == 'returning_before') {
                        final returningDate = info['returningOrderEndDate'] as String? ?? '';
                        textWidget = Text(
                          '⚡ $useFromThis units — rush-clean from $customer (returning ${formatDt(returningDate)})',
                          style: TextStyle(fontSize: Responsive.sp(10), color: AppColors.warning),
                        );
                      } else {
                        final pickupDate = info['returningOrderStartDate'] as String? ?? '';
                        textWidget = Text(
                          '⚡ $useFromThis units — skip prep for $customer (pickup ${formatDt(pickupDate)})',
                          style: TextStyle(fontSize: Responsive.sp(10), color: AppColors.warning),
                        );
                      }

                      list.add(Padding(
                        padding: Responsive.only(top: 4, left: 20),
                        child: textWidget,
                      ));
                      accumulated += useFromThis;
                    }
                    return list;
                  }())
                ],
              ),
            ),
          ],
          // Existing Bookings Section
          if (item.productId.isNotEmpty && item.overlappingOrders.isNotEmpty) ...[
            SizedBox(height: Responsive.h(8)),
            StatefulBuilder(
              builder: (context, setStateBuilder) {
                final isExpanded = _expandedBookings.contains(item.productId);
                final firstBooking = item.overlappingOrders.first;
                final remainingCount = item.overlappingOrders.length - 1;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EXISTING BOOKINGS',
                          style: TextStyle(
                            fontSize: Responsive.sp(10),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (remainingCount > 0)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedBookings.remove(item.productId);
                                } else {
                                  _expandedBookings.add(item.productId);
                                }
                              });
                              setStateBuilder(() {});
                            },
                            child: Row(
                              children: [
                                Text(
                                  isExpanded ? 'Collapse' : '+$remainingCount more',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(10),
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  size: Responsive.icon(14),
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(4)),
                    _buildBookingRow(firstBooking),
                    if (isExpanded)
                      ...item.overlappingOrders.skip(1).map((b) => Padding(
                            padding: Responsive.only(top: 4),
                            child: _buildBookingRow(b),
                          )),
                  ],
                );
              },
            ),
          ],
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

  // Parity with website
  double discount = 0.0;
  String discountType = 'flat'; // 'flat' | 'percent'
  int available = 0;
  int availableWithPriority = 0;
  bool priorityCleaningNeeded = false;
  List<dynamic> priorityCleaningInfo = const [];
  List<dynamic> overlappingOrders = const [];

  OrderItemInput({
    this.productId = '',
    this.productName = '',
    this.quantity = 1,
    this.pricePerDay = 0.0,
    this.gstPercentage = 0.0,
    this.isAvailable = true,
    this.discount = 0.0,
    this.discountType = 'flat',
    this.available = 0,
    this.availableWithPriority = 0,
    this.priorityCleaningNeeded = false,
    this.priorityCleaningInfo = const [],
    this.overlappingOrders = const [],
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
                             return Material(
                               type: MaterialType.transparency,
                               child: ListTile(
                                 contentPadding: Responsive.symmetric(horizontal: 8, vertical: 4),
                                 title: Text(item.label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.sp(14))),
                                 subtitle: Text(item.subtitle, style: TextStyle(color: Colors.grey[600], fontSize: Responsive.sp(12))),
                                 onTap: () {
                                   widget.onSelect(item);
                                   Navigator.pop(context);
                                 },
                               ),
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
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(8)),
        clipBehavior: Clip.antiAlias,
        child: (searchState.isLoading || searchState.isSearchingRemote) && customers.isEmpty
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
                          return Material(
                            type: MaterialType.transparency,
                            child: ListTile(
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
                            ),
                          );
                        },
                      ),
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
