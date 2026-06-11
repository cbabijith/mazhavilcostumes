import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
import '../../products/views/qr_scanner_dialog.dart';


class OrderFormView extends ConsumerStatefulWidget {
  final Order? order;

  const OrderFormView({super.key, this.order});

  @override
  ConsumerState<OrderFormView> createState() => _OrderFormViewState();
}

class _OrderFormViewState extends ConsumerState<OrderFormView> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Debounce and Cancel tokens for APIs
  Timer? _searchDebounce;
  CancelToken? _productSearchCancelToken;
  CancelToken? _searchAvailCancelToken;
  
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

  // Product search state
  final _productSearchController = TextEditingController();
  bool _showProductDropdown = false;
  String _productSearchQuery = '';
  List<p_model.Product> _productSearchResults = [];
  bool _isSearchingProducts = false;

  // Product search availability state
  Map<String, Map<String, dynamic>> _searchAvailabilityMap = {};
  bool _isCheckingSearchAvailability = false;
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
      
      _startDateController.text = _formatDisplayDate(widget.order!.startDate);
      _endDateController.text = _formatDisplayDate(widget.order!.endDate);
      _eventDateController.text = _formatDisplayDate(widget.order!.eventDate);
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
    } else {
      // Default dates for new order matching web
      final today = DateTime.now();
      final twoDaysLater = today.add(const Duration(days: 2));
      _startDateController.text = DateFormat('dd/MM/yyyy').format(today);
      _endDateController.text = DateFormat('dd/MM/yyyy').format(twoDaysLater);
      _eventDateController.text = DateFormat('dd/MM/yyyy').format(today);
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
    _searchDebounce?.cancel();
    _productSearchCancelToken?.cancel('Form disposed');
    _searchAvailCancelToken?.cancel('Form disposed');
    for (final item in _items) {
      item.cancelToken?.cancel('Form disposed');
    }
    _productSearchController.dispose();
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
    final startVal = _parseDisplayDate(_startDateController.text);
    final endVal = _parseDisplayDate(_endDateController.text);
    if (startVal != null && endVal != null) {
      try {
        final diff = endVal.difference(startVal).inDays;
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
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
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
    // Auto-fill delivery address from customer (matching web behavior — new orders only)
    if (widget.order == null && customer.address != null && customer.address!.isNotEmpty) {
      _deliveryAddressController.text = customer.address!;
    }
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
    final trimmed = _phoneSearchController.text.trim();
    final isPhone = RegExp(r'^\d+$').hasMatch(trimmed);
    
    showDialog(
      context: context,
      builder: (context) => _AddCustomerDialog(
        initialName: isPhone ? '' : trimmed,
        initialPhone: isPhone ? trimmed : '',
        onCustomerCreated: (customer) {
          _selectCustomer(customer);
        },
      ),
    );
  }

  void _searchProducts(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _productSearchResults = [];
        _isSearchingProducts = false;
        _searchAvailabilityMap = {};
      });
      return;
    }

    _productSearchCancelToken?.cancel('New search started');
    _productSearchCancelToken = CancelToken();

    setState(() => _isSearchingProducts = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      final result = await repo.getProducts(
        search: query.trim(),
        branchId: _selectedBranchId,
        cancelToken: _productSearchCancelToken,
      );
      // Filter out products already in _items
      final filtered = result.products.where((p) => !_items.any((item) => item.productId == p.id)).toList();
      if (!mounted) return;
      setState(() {
        _productSearchResults = filtered;
        _isSearchingProducts = false;
      });
      _checkSearchProductsAvailability(filtered);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return;
      }
      if (!mounted) return;
      setState(() => _isSearchingProducts = false);
    }
  }

  void _checkSearchProductsAvailability(List<p_model.Product> products) async {
    if (products.isEmpty || _startDateController.text.isEmpty || _endDateController.text.isEmpty || _selectedBranchId == null) {
      setState(() {
        _searchAvailabilityMap = {};
        _isCheckingSearchAvailability = false;
      });
      print('DEBUG checkAvailability early return: '
          'products: ${products.length}, '
          'startDate: ${_startDateController.text}, '
          'endDate: ${_endDateController.text}, '
          'branchId: $_selectedBranchId');
      return;
    }

    _searchAvailCancelToken?.cancel('New availability check started');
    _searchAvailCancelToken = CancelToken();

    setState(() {
      _isCheckingSearchAvailability = true;
    });

    try {
      final operations = ref.read(orderOperationsProvider);
      print('DEBUG checkAvailability calling API with: '
          'startDate: ${_toIsoDate(_startDateController.text)}, '
          'endDate: ${_toIsoDate(_endDateController.text)}, '
          'branchId: $_selectedBranchId');
      
      final result = await operations.checkAvailability(
        startDate: _toIsoDate(_startDateController.text),
        endDate: _toIsoDate(_endDateController.text),
        branchId: _selectedBranchId!,
        items: products.map((p) => <String, dynamic>{
          'product_id': p.id,
          'quantity': 1,
        }).toList(),
        excludeOrderId: widget.order?.id,
        cancelToken: _searchAvailCancelToken,
      );

      final itemsList = result['items'] as List<dynamic>? ?? [];
      print('DEBUG checkAvailability API result items count: ${itemsList.length}');
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
      setState(() {
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
        setState(() {
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
  void _addProductToOrder(p_model.Product product) {
    final sAvail = _searchAvailabilityMap[product.id];
    if (sAvail != null) {
      final int availableWithPriority = (sAvail['availableWithPriority'] as num?)?.toInt() ?? 0;
      if (availableWithPriority < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unavailable: 0 available for the selected dates (even with priority cleaning).'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _items.add(OrderItemInput(
        productId: product.id,
        productName: product.name,
        quantity: 1,
        pricePerDay: product.pricePerDay,
        gstPercentage: product.gstPercentage,
      ));
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

  Future<void> _checkItemAvailability(int index) async {
    final item = _items[index];
    if (item.productId.isEmpty || _startDateController.text.isEmpty || _endDateController.text.isEmpty || _selectedBranchId == null) return;

    item.cancelToken?.cancel('New check started');
    item.cancelToken = CancelToken();

    setState(() => item.isChecking = true);
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
          }
        ],
        excludeOrderId: widget.order?.id,
        cancelToken: item.cancelToken,
      );

      final itemsList = result['items'] as List<dynamic>? ?? [];
      if (itemsList.isNotEmpty && itemsList.first is Map) {
        final i = Map<String, dynamic>.from(itemsList.first as Map);
        final isItemAvailable = i['isAvailable'] as bool? ?? true;
        final available = (i['available'] as num?)?.toInt() ?? 0;
        final availableWithPriority = (i['availableWithPriority'] as num?)?.toInt() ?? 0;
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
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return;
      }
      setState(() => item.isChecking = false);
    }
  }

  void _checkAllItemsAvailability() {
    for (int i = 0; i < _items.length; i++) {
      _checkItemAvailability(i);
    }
    _checkSearchProductsAvailability(_productSearchResults);
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
    final startVal = _parseDisplayDate(_startDateController.text);
    final endVal = _parseDisplayDate(_endDateController.text);
    if (startVal != null && endVal != null) {
      if (endVal.isBefore(startVal)) {
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
      'rental_start_date': _toIsoDate(_startDateController.text),
      'rental_end_date': _toIsoDate(_endDateController.text),
      'event_date': _toIsoDate(_startDateController.text),
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

  String _formatDisplayDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  String _toIsoDate(String displayText) {
    if (displayText.isEmpty) return '';
    try {
      final date = DateFormat('dd/MM/yyyy').parse(displayText);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return displayText;
    }
  }

  DateTime? _parseDisplayDate(String displayText) {
    if (displayText.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(displayText);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isEditing = widget.order != null;

    // Synchronize selected branch ID from effectiveBranchIdProvider for new orders
    final currentBranchId = ref.watch(effectiveBranchIdProvider);
    if (!isEditing && _selectedBranchId != currentBranchId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedBranchId = currentBranchId;
          });
          // Re-trigger checking availability when the branch becomes available
          _checkAllItemsAvailability();
        }
      });
    }

    // Listen to customerSearchProvider to keep it alive during typing
    ref.listen(customerSearchProvider, (_, __) {});

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
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
                    _buildSectionHeader('Customer', icon: Icons.person_outline_rounded),
                    _buildCard(children: [
                      // Customer Search Field with Dropdown
                      _buildCustomerSearchField(),
                    ]),
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    _buildSectionHeader('Rental Period', icon: Icons.calendar_today_outlined),
                    _buildCard(children: [
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
                          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                          Expanded(
                            child: _buildDateField(
                              label: 'End Date',
                              controller: _endDateController,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                      _buildQuickDateButtons(),
                      SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                      // Total rental days indicator matching web
                      Container(
                        padding: Responsive.symmetric(
                          horizontal: AppSizes.spacingMedium,
                          vertical: AppSizes.spacingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: Responsive.w(AppSizes.spacingXXLarge),
                              height: Responsive.w(AppSizes.spacingXXLarge),
                              decoration: const BoxDecoration(
                                color: AppColors.text,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$_rentalDays',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.sp(AppSizes.fontSmall),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                            Text(
                              'Total rental days',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontSmall),
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildDateWarnings(),
                      SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                      // Buffer days info banner matching web
                      Container(
                        padding: Responsive.all(AppSizes.spacingSmall),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.05),
                          border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.info,
                              size: Responsive.icon(AppSizes.iconTiny),
                            ),
                            SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                            Expanded(
                              child: Text(
                                'Most products are blocked 1 day before pickup and 1 day after return for preparation. (Note: Some categories like Ornaments are exempt from this gap).',
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontTiny),
                                  color: AppColors.info,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    _buildSectionHeader('Rent Items', icon: Icons.shopping_bag_outlined),
                    _buildProductSearchField(),
                    SizedBox(height: Responsive.h(12)),
                    if (_items.isEmpty)
                      Container(
                        height: Responsive.h(120),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(Responsive.r(12)),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined, color: Colors.grey[400], size: Responsive.icon(28)),
                            SizedBox(height: Responsive.h(8)),
                            Text(
                              'Search and add products',
                              style: TextStyle(color: Colors.grey[500], fontSize: Responsive.sp(13)),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _buildItemCard(item, index);
                      }),
                    // === TOTALS (matching web bg-slate-50 section) ===
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    Container(
                      padding: Responsive.all(AppSizes.spacingLarge),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Subtotal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), color: Colors.grey[600])),
                              Text('₹${_subtotal.toStringAsFixed(2)}', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.w500, color: Colors.grey[700])),
                            ],
                          ),
                          // Info line: items · days · rate (matching web)
                          Padding(
                            padding: Responsive.only(top: AppSizes.spacingTiny / 2),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: Responsive.icon(AppSizes.iconTiny - 4), color: Colors.grey[400]),
                                SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                Expanded(
                                  child: Text(
                                    '${_items.where((i) => i.productId.isNotEmpty).length} ${_items.where((i) => i.productId.isNotEmpty).length == 1 ? 'item' : 'items'} · $_rentalDays days · Rate: ×${(_rentalDays - 2) > 1 ? (_rentalDays - 2) : 1}',
                                    style: TextStyle(fontSize: Responsive.sp(AppSizes.fontTiny), color: Colors.grey[400]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Item Discounts (shown only if any)
                          Builder(builder: (_) {
                            double itemDiscountTotal = 0.0;
                            final pricingMultiplier = (_rentalDays - 2) > 1 ? (_rentalDays - 2) : 1;
                            for (final item in _items) {
                              final lineTotal = item.quantity * item.pricePerDay * pricingMultiplier;
                              final itemDisc = item.discountType == 'percent'
                                  ? lineTotal * (item.discount / 100)
                                  : item.discount * item.quantity;
                              itemDiscountTotal += itemDisc < lineTotal ? itemDisc : lineTotal;
                            }
                            if (itemDiscountTotal <= 0) return const SizedBox.shrink();
                            return Padding(
                              padding: Responsive.only(top: AppSizes.spacingSmall),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.local_offer_outlined, size: Responsive.icon(AppSizes.iconTiny - 4), color: Colors.orange[600]),
                                      SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                      Text('Item Discounts', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), color: Colors.orange[600])),
                                    ],
                                  ),
                                  Text('−₹${itemDiscountTotal.toStringAsFixed(2)}', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.w500, color: Colors.orange[600])),
                                ],
                              ),
                            );
                          }),
                          // Order Discount (shown only if any)
                          Builder(builder: (_) {
                            final orderDiscountInput = double.tryParse(_discountController.text) ?? 0.0;
                            if (orderDiscountInput <= 0) return const SizedBox.shrink();
                            // Calculate effective order discount
                            double itemDiscountTotal = 0.0;
                            final pricingMultiplier = (_rentalDays - 2) > 1 ? (_rentalDays - 2) : 1;
                            for (final item in _items) {
                              final lineTotal = item.quantity * item.pricePerDay * pricingMultiplier;
                              final itemDisc = item.discountType == 'percent'
                                  ? lineTotal * (item.discount / 100)
                                  : item.discount * item.quantity;
                              itemDiscountTotal += itemDisc < lineTotal ? itemDisc : lineTotal;
                            }
                            final afterItemDiscount = _subtotal - itemDiscountTotal;
                            final orderDiscAmt = _orderDiscountType == 'percent'
                                ? afterItemDiscount * (orderDiscountInput / 100)
                                : orderDiscountInput;
                            final effectiveOrderDiscount = orderDiscAmt < afterItemDiscount ? orderDiscAmt : afterItemDiscount;
                            if (effectiveOrderDiscount <= 0) return const SizedBox.shrink();
                            return Padding(
                              padding: Responsive.only(top: AppSizes.spacingSmall),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.percent_rounded, size: Responsive.icon(AppSizes.iconTiny - 4), color: Colors.purple[600]),
                                      SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                      Text('Order Discount', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), color: Colors.purple[600])),
                                    ],
                                  ),
                                  Text('−₹${effectiveOrderDiscount.toStringAsFixed(2)}', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.w500, color: Colors.purple[600])),
                                ],
                              ),
                            );
                          }),
                          // GST breakdown (if enabled)
                          if (_isGstEnabled && _gstAmount > 0) ...[
                            Padding(
                              padding: Responsive.only(top: AppSizes.spacingSmall),
                              child: Container(
                                padding: Responsive.only(top: AppSizes.spacingSmall),
                                decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Base Amount (excl. GST)', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), color: Colors.grey[500])),
                                        Text('₹${(_totalAmount - _gstAmount).toStringAsFixed(2)}', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), fontWeight: FontWeight.w500, color: Colors.grey[500])),
                                      ],
                                    ),
                                    SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.info_outline_rounded, size: Responsive.icon(AppSizes.iconTiny - 4), color: Colors.blue[600]),
                                            SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                            Text('GST (included)', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), color: Colors.blue[600])),
                                          ],
                                        ),
                                        Text('₹${_gstAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), fontWeight: FontWeight.w600, color: Colors.blue[600])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          // Grand Total
                          Padding(
                            padding: Responsive.only(top: AppSizes.spacingMedium),
                            child: Container(
                              padding: Responsive.only(top: AppSizes.spacingMedium),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Grand Total', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontLarge), fontWeight: FontWeight.w600, color: Colors.grey[900])),
                                      SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today_outlined, size: Responsive.icon(AppSizes.iconTiny - 4), color: Colors.grey[400]),
                                          SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                          Text(
                                            '$_rentalDays days${_isGstEnabled && _gstAmount > 0 ? ' · Incl. GST' : ''}',
                                            style: TextStyle(fontSize: Responsive.sp(AppSizes.fontTiny), color: Colors.grey[400]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '₹${_totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: Responsive.sp(AppSizes.fontXXXLarge), fontWeight: FontWeight.bold, color: Colors.grey[900], letterSpacing: -0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // === ORDER DISCOUNT + ADVANCE (matching web below-totals section) ===
                    if (_items.isNotEmpty) ...[
                      Container(
                        padding: Responsive.all(AppSizes.spacingLarge),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            left: BorderSide(color: Colors.grey.shade200),
                            right: BorderSide(color: Colors.grey.shade200),
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(Responsive.r(AppSizes.radiusMedium)),
                            bottomRight: Radius.circular(Responsive.r(AppSizes.radiusMedium)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Order Discount
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.percent_rounded, size: Responsive.icon(AppSizes.iconTiny), color: Colors.purple[400]),
                                    SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                                    Text('Order Discount', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.w600, color: Colors.grey[900])),
                                  ],
                                ),
                                Container(
                                  height: Responsive.h(28),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildDiscountTypeToggleButton(
                                        label: '₹ Flat',
                                        isSelected: _orderDiscountType == 'flat',
                                        onTap: () {
                                          setState(() => _orderDiscountType = 'flat');
                                          _calculateTotals();
                                        },
                                      ),
                                      _buildDiscountTypeToggleButton(
                                        label: '% Pct',
                                        isSelected: _orderDiscountType == 'percent',
                                        onTap: () {
                                          setState(() => _orderDiscountType = 'percent');
                                          _calculateTotals();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                            TextFormField(
                              controller: _discountController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: Responsive.sp(AppSizes.fontLarge), fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                prefixText: _orderDiscountType == 'percent' ? '% ' : '₹ ',
                                prefixStyle: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.w600, color: Colors.grey[500]),
                                hintText: '0',
                                contentPadding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
                              ),
                              onChanged: (_) => _calculateTotals(),
                            ),
                            // "Saving X" feedback
                            Builder(builder: (_) {
                              final orderDiscountInput = double.tryParse(_discountController.text) ?? 0.0;
                              if (orderDiscountInput <= 0) return const SizedBox.shrink();
                              double itemDiscountTotal = 0.0;
                              final pricingMultiplier = (_rentalDays - 2) > 1 ? (_rentalDays - 2) : 1;
                              for (final item in _items) {
                                final lineTotal = item.quantity * item.pricePerDay * pricingMultiplier;
                                final itemDisc = item.discountType == 'percent'
                                    ? lineTotal * (item.discount / 100)
                                    : item.discount * item.quantity;
                                itemDiscountTotal += itemDisc < lineTotal ? itemDisc : lineTotal;
                              }
                              final afterItemDiscount = _subtotal - itemDiscountTotal;
                              final orderDiscAmt = _orderDiscountType == 'percent'
                                  ? afterItemDiscount * (orderDiscountInput / 100)
                                  : orderDiscountInput;
                              final effectiveOrderDiscount = orderDiscAmt < afterItemDiscount ? orderDiscAmt : afterItemDiscount;
                              if (effectiveOrderDiscount <= 0) return const SizedBox.shrink();
                              return Padding(
                                padding: Responsive.only(top: AppSizes.spacingTiny),
                                child: Text(
                                  'Saving ₹${effectiveOrderDiscount.toStringAsFixed(2)} on this order',
                                  style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), color: Colors.purple[600], fontWeight: FontWeight.w500),
                                ),
                              );
                            }),
                            // Divider
                            Padding(
                              padding: Responsive.symmetric(vertical: AppSizes.spacingMedium),
                              child: Divider(height: 1, color: Colors.grey.shade100),
                            ),
                            // Advance Payment
                            Row(
                              children: [
                                Icon(Icons.account_balance_wallet_outlined, size: Responsive.icon(AppSizes.iconTiny), color: Colors.grey[400]),
                                SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                                Text('Advance Payment', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.w600, color: Colors.grey[900])),
                                SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                Text('(Optional)', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), color: Colors.grey[400])),
                              ],
                            ),
                            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _advanceAmountController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(fontSize: Responsive.sp(AppSizes.fontLarge), fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      prefixText: '₹ ',
                                      prefixStyle: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.w600, color: Colors.grey[500]),
                                      hintText: '0',
                                      contentPadding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
                                    ),
                                    onChanged: (val) => setState(() {}),
                                  ),
                                ),
                                if ((double.tryParse(_advanceAmountController.text) ?? 0.0) > 0.0) ...[
                                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                                  SizedBox(
                                    width: Responsive.w(110),
                                    child: DropdownButtonFormField<PaymentMethod>(
                                      value: _advancePaymentMethod,
                                      isDense: true,
                                      style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), color: Colors.grey[800]),
                                      decoration: InputDecoration(
                                        contentPadding: Responsive.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingSmall),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
                                      ),
                                      items: PaymentMethod.values.map((method) {
                                        return DropdownMenuItem(
                                          value: method,
                                          child: Text(method.name[0].toUpperCase() + method.name.substring(1), style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall))),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(() => _advancePaymentMethod = val),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            // Advance payment feedback banners (matching web)
                            Builder(builder: (_) {
                              final advanceAmount = double.tryParse(_advanceAmountController.text) ?? 0.0;
                              if (advanceAmount <= 0) return const SizedBox.shrink();
                              final exceeds = advanceAmount > _totalAmount;
                              final isFullPayment = advanceAmount >= _totalAmount && !exceeds;
                              return Column(
                                children: [
                                  SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                                  if (exceeds)
                                    Container(
                                      padding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withValues(alpha: 0.05),
                                        border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
                                        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.warning_amber_rounded, size: Responsive.icon(AppSizes.iconTiny), color: AppColors.error),
                                          SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                                          Expanded(
                                            child: Text(
                                              'Advance cannot exceed grand total (₹${_totalAmount.toStringAsFixed(2)})',
                                              style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), color: AppColors.error, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else if (isFullPayment)
                                    Container(
                                      padding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.05),
                                        border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
                                        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle_outline_rounded, size: Responsive.icon(AppSizes.iconTiny), color: AppColors.success),
                                          SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                                          Expanded(
                                            child: Text(
                                              'Full payment collected — no balance due at return',
                                              style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), color: AppColors.success, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                                      decoration: BoxDecoration(
                                        color: AppColors.info.withValues(alpha: 0.05),
                                        border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
                                        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.info_outline_rounded, size: Responsive.icon(AppSizes.iconTiny), color: AppColors.info),
                                          SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                                          Expanded(
                                            child: Text(
                                              'Balance due at return: ₹${(_totalAmount - advanceAmount).toStringAsFixed(2)}',
                                              style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), color: AppColors.info, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            }),
                            // Amount paid (edit mode only)
                            if (isEditing) ...[
                              SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                              TextFormField(
                                controller: _amountPaidController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                                decoration: InputDecoration(
                                  labelText: 'Total Amount Paid (₹)',
                                  contentPadding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    // === FINAL SUMMARY (Advance deduction + Balance + warnings) ===
                    Builder(builder: (_) {
                      final advanceAmount = double.tryParse(_advanceAmountController.text) ?? 0.0;
                      final exceeds = advanceAmount > _totalAmount;
                      final hasConflicts = _items.any((i) => !i.isAvailable);
                      if (advanceAmount <= 0 && !hasConflicts) return const SizedBox.shrink();
                      return Container(
                        margin: Responsive.only(top: AppSizes.spacingSmall),
                        padding: Responsive.all(AppSizes.spacingLarge),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (advanceAmount > 0 && !exceeds) ...[
                              Container(
                                padding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.05),
                                  border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
                                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Less: Advance Paid', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.w500, color: Colors.blue[700])),
                                    Text('−₹${advanceAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.bold, color: Colors.blue[700])),
                                  ],
                                ),
                              ),
                              SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Balance Due', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                  Text('₹${((_totalAmount - advanceAmount) > 0 ? (_totalAmount - advanceAmount) : 0.0).toStringAsFixed(2)}', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.bold, color: Colors.grey[900])),
                                ],
                              ),
                            ],
                            if (hasConflicts) ...[
                              if (advanceAmount > 0 && !exceeds) SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                              Container(
                                padding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.05),
                                  border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
                                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, size: Responsive.icon(AppSizes.iconSmall), color: AppColors.error),
                                    SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                                    Expanded(
                                      child: Text(
                                        'Some items are not available for the selected dates. Adjust quantities or change dates.',
                                        style: TextStyle(fontSize: Responsive.sp(AppSizes.fontSmall), color: AppColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    // === ADDRESS & NOTES (matching web's simple layout) ===
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    _buildSectionHeader('Address & Notes', icon: Icons.location_on_outlined),
                    _buildCard(children: [
                      Text('Customer / Delivery Address', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.w600, color: Colors.grey[900])),
                      SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                      TextFormField(
                        controller: _deliveryAddressController,
                        style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                        decoration: InputDecoration(
                          hintText: 'Enter address for delivery or record...',
                          hintStyle: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), color: Colors.grey[400]),
                          contentPadding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                      Text('Notes', style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), fontWeight: FontWeight.w600, color: Colors.grey[900])),
                      SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                      TextFormField(
                        controller: _notesController,
                        style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                        decoration: InputDecoration(
                          hintText: 'Optional notes about this order...',
                          hintStyle: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), color: Colors.grey[400]),
                          contentPadding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
                        ),
                        maxLines: 2,
                      ),
                      // Edit-mode only: Order Status + Payment Status
                      if (isEditing) ...[
                        SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                        DropdownButtonFormField<OrderStatus>(
                          value: _selectedStatus,
                          style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), color: AppColors.primary),
                          decoration: InputDecoration(
                            labelText: 'Order Status',
                            contentPadding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
                          ),
                          items: OrderStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedStatus = val),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                        DropdownButtonFormField<PaymentStatus>(
                          value: _selectedPaymentStatus,
                          style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), color: AppColors.primary),
                          decoration: InputDecoration(
                            labelText: 'Payment Status',
                            contentPadding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall))),
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
                    SizedBox(height: Responsive.h(AppSizes.spacingXXLarge)),
                    // === SUBMIT BUTTON ===
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: Responsive.symmetric(vertical: AppSizes.spacingLarge),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium))),
                        elevation: AppSizes.spacingTiny / 2,
                      ),
                      onPressed: _submit,
                      child: Text(
                        isEditing ? 'Save Changes' : 'Confirm Order',
                        style: TextStyle(fontSize: Responsive.sp(AppSizes.fontLarge), fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingHuge)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: Responsive.only(bottom: AppSizes.spacingSmall, left: AppSizes.spacingTiny),
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
                  labelText: 'Search Costume',
                  hintText: 'Search products or scan barcode...',
                  hintStyle: TextStyle(fontSize: Responsive.sp(14), color: Colors.grey),
                  prefixIcon: Icon(Icons.search_rounded, size: Responsive.icon(20)),
                  suffixIcon: _productSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, size: Responsive.icon(18)),
                          onPressed: () {
                            _productSearchController.clear();
                            _searchDebounce?.cancel();
                            _productSearchCancelToken?.cancel('Search cleared');
                            _searchAvailCancelToken?.cancel('Search cleared');
                            setState(() {
                              _productSearchQuery = '';
                              _showProductDropdown = false;
                              _productSearchResults = [];
                              _searchAvailabilityMap = {};
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(8))),
                  contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _productSearchQuery = value;
                    _showProductDropdown = value.isNotEmpty;
                  });
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                    _searchProducts(value);
                  });
                },
                onTap: () {
                  if (_productSearchController.text.isNotEmpty) {
                    setState(() => _showProductDropdown = true);
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
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
                  child: const CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            : products.isEmpty
                ? Padding(
                    padding: Responsive.all(16),
                    child: Center(
                      child: Text(
                        'No product found',
                        style: TextStyle(color: Colors.grey[600], fontSize: Responsive.sp(13)),
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
                        final int availableWithPriority = (sAvail['availableWithPriority'] as num?)?.toInt() ?? 0;
                        isAvail = availableWithPriority > 0;
                      }

                      return Material(
                        type: MaterialType.transparency,
                        child: Opacity(
                          opacity: isAvail ? 1.0 : 0.5,
                          child: ListTile(
                            contentPadding: Responsive.symmetric(horizontal: 12, vertical: 4),
                            leading: Container(
                              width: Responsive.w(40),
                              height: Responsive.w(40),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(Responsive.r(6)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: product.primaryImageUrl != null && product.primaryImageUrl!.isNotEmpty
                                  ? Image.network(
                                      product.primaryImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
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
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.sp(13)),
                            ),
                            subtitle: Builder(
                              builder: (context) {
                                final rateText = '₹${product.pricePerDay.toStringAsFixed(2)}   ';
                                if (_isCheckingSearchAvailability) {
                                  return Text.rich(
                                    TextSpan(
                                      style: TextStyle(color: Colors.grey[600], fontSize: Responsive.sp(11)),
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
                                  final int available = (sAvail['available'] as num?)?.toInt() ?? 0;
                                  final int availableWithPriority = (sAvail['availableWithPriority'] as num?)?.toInt() ?? 0;
                                  
                                  String availText = '';
                                  Color textColor = Colors.grey[600]!;
                                  FontWeight fontWeight = FontWeight.normal;
                                  
                                  if (available > 0) {
                                    availText = '$available free for dates';
                                    textColor = AppColors.success;
                                  } else if (availableWithPriority > 0) {
                                    availText = '0 free ($availableWithPriority with priority cleaning)';
                                    textColor = AppColors.warning;
                                  } else {
                                    availText = '0 free (Unavailable)';
                                    textColor = AppColors.error;
                                    fontWeight = FontWeight.bold;
                                  }
                                  
                                  return Text.rich(
                                    TextSpan(
                                      style: TextStyle(color: Colors.grey[600], fontSize: Responsive.sp(11)),
                                      children: [
                                        TextSpan(text: rateText),
                                        TextSpan(
                                          text: availText,
                                          style: TextStyle(color: textColor, fontWeight: fontWeight),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                
                                return Text(
                                  '₹${product.pricePerDay.toStringAsFixed(2)}   Stock: ${product.availableQuantity}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: Responsive.sp(11)),
                                );
                              },
                            ),
                            trailing: isAvail
                                ? Icon(Icons.add_rounded, color: AppColors.primary, size: Responsive.icon(20))
                                : Icon(Icons.block_rounded, color: Colors.grey, size: Responsive.icon(20)),
                            onTap: isAvail ? () => _addProductToOrder(product) : null,
                          ),
                        ),
                      );
                    },
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
          Container(
            padding: Responsive.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(Responsive.r(8)),
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: Responsive.icon(20)),
                SizedBox(width: Responsive.w(8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Costume Product', style: TextStyle(fontSize: Responsive.sp(10), color: Colors.grey)),
                      SizedBox(height: Responsive.h(2)),
                      Text(item.productName, style: TextStyle(fontSize: Responsive.sp(14), fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    ],
                  ),
                ),
              ],
            ),
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


  Widget _buildQuickDateButtons() {
    return Row(
      children: [
        Text(
          'Quick End Date: ',
          style: TextStyle(
            fontSize: Responsive.sp(12),
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(width: Responsive.w(8)),
        _buildQuickDateButton(label: '+1 Day', days: 1),
        SizedBox(width: Responsive.w(8)),
        _buildQuickDateButton(label: '+2 Days', days: 2),
      ],
    );
  }

  Widget _buildQuickDateButton({required String label, required int days}) {
    final startText = _startDateController.text;
    final bool isEnabled = startText.isNotEmpty;

    bool isSelected = false;
    if (isEnabled && _endDateController.text.isNotEmpty) {
      try {
        final start = _parseDisplayDate(startText);
        final end = _parseDisplayDate(_endDateController.text);
        if (start != null && end != null) {
          final expectedEnd = start.add(Duration(days: days));
          isSelected = end.year == expectedEnd.year &&
              end.month == expectedEnd.month &&
              end.day == expectedEnd.day;
        }
      } catch (_) {}
    }

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
        backgroundColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        foregroundColor: isSelected ? AppColors.primary : Colors.grey[700],
        padding: Responsive.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onPressed: isEnabled
          ? () {
              try {
                final start = _parseDisplayDate(startText);
                if (start != null) {
                  final end = start.add(Duration(days: days));
                  setState(() {
                    _endDateController.text = DateFormat('dd/MM/yyyy').format(end);
                  });
                  _calculateTotals();
                  _checkAllItemsAvailability();
                }
              } catch (_) {}
            }
          : null,
      child: Text(
        label,
        style: TextStyle(
          fontSize: Responsive.sp(12),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDateWarnings() {
    final startText = _startDateController.text;
    final endText = _endDateController.text;

    if (startText.isEmpty) return const SizedBox.shrink();

    final List<Widget> warnings = [];

    // 1. Backdated warning
    try {
      final start = _parseDisplayDate(startText);
      if (start != null) {
        final today = DateTime.now();
        final todayMidnight = DateTime(today.year, today.month, today.day);
        if (start.isBefore(todayMidnight)) {
          warnings.add(
            Container(
              margin: Responsive.only(top: AppSizes.spacingSmall),
              padding: Responsive.all(AppSizes.spacingSmall),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.05),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: Responsive.icon(AppSizes.iconTiny)),
                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                  Expanded(
                    child: Text(
                      '⚠️ Backdated Bill: You are creating/editing an order with a pickup date in the past.',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (_) {}

    // 2. Invalid end date warning
    if (endText.isNotEmpty) {
      try {
        final start = _parseDisplayDate(startText);
        final end = _parseDisplayDate(endText);
        if (start != null && end != null) {
          if (end.isBefore(start)) {
            warnings.add(
              Container(
                margin: Responsive.only(top: AppSizes.spacingSmall),
                padding: Responsive.all(AppSizes.spacingSmall),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline_rounded, color: AppColors.error, size: Responsive.icon(AppSizes.iconTiny)),
                    SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                    Expanded(
                      child: Text(
                        'Return date cannot be before the pickup date. Please choose a valid return date.',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontSmall),
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      } catch (_) {}
    }

    if (warnings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: warnings,
    );
  }

  void _openBarcodeScanner() {
    showDialog(
      context: context,
      builder: (context) => QRScannerDialog(
        onScanMatched: (productId) async {
          try {
            setState(() => _isLoading = true);
            final repo = ref.read(productRepositoryProvider);
            final product = await repo.getProductById(productId);
            
            final existingIndex = _items.indexWhere((item) => item.productId == product.id);
            if (existingIndex != -1) {
              setState(() {
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
              setState(() {
                _items.add(OrderItemInput(
                  productId: product.id,
                  productName: product.name,
                  quantity: 1,
                  pricePerDay: product.pricePerDay,
                  gstPercentage: product.gstPercentage,
                ));
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
            setState(() => _isLoading = false);
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

class OrderItemInput {
  String productId = '';
  String productName = '';
  int quantity = 1;
  double pricePerDay = 0.0;
  double gstPercentage = 0.0;
  bool isAvailable = true;
  bool isChecking = false;
  String? availableStockInfo;
  CancelToken? cancelToken;

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
    this.cancelToken,
  });
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
        child: (searchState.isLoading || searchState.isSearchingRemote) && customers.isEmpty && searchQuery.isEmpty
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
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Create "$searchQuery"',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: Responsive.sp(13),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
  final String initialName;
  final String initialPhone;
  final Function(Customer) onCustomerCreated;

  const _AddCustomerDialog({
    required this.initialName,
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
    _nameController.text = widget.initialName;
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
