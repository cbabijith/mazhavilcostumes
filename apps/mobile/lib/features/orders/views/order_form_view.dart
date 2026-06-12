library;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/api_client.dart';
import '../../../core/utils/responsive.dart';
import '../../branches/viewmodels/providers/branch_provider.dart';
import '../../customers/models/customer.dart';
import '../../customers/viewmodels/providers/customer_provider.dart';
import '../../products/models/product.dart' as p_model;
import '../../products/viewmodels/providers/product_provider.dart';
import '../../products/views/qr_scanner_dialog.dart';
import '../models/order.dart';
import '../models/order_item_input.dart';
import '../viewmodels/providers/order_provider.dart';
import './widgets/add_customer_dialog.dart';
import './widgets/customer_search_dropdown.dart';

part 'widgets/order_form_calculation.dart';
part 'widgets/order_form_api.dart';
part 'widgets/order_form_helpers.dart';
part 'widgets/order_form_submit.dart';
part 'widgets/order_form_customer_section.dart';
part 'widgets/order_form_rental_period_section.dart';
part 'widgets/order_form_product_search_section.dart';
part 'widgets/order_form_cart_items_section.dart';
part 'widgets/order_form_totals_section.dart';

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

  void _update(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

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
      _advanceAmountController.text = widget.order!.advanceAmount
          .toStringAsFixed(0);
      _amountPaidController.text = widget.order!.amountPaid.toStringAsFixed(0);
      _discountController.text = widget.order!.discount.toStringAsFixed(0);
      _selectedStatus = widget.order!.status;
      _selectedPaymentStatus = widget.order!.paymentStatus;
      _selectedDeliveryMethod = widget.order!.deliveryMethod;
      _orderDiscountType = widget.order!.discountType;
      _advancePaymentMethod =
          widget.order!.advancePaymentMethod ?? PaymentMethod.cash;

      if (widget.order!.items != null) {
        _items.addAll(
          widget.order!.items!.map(
            (item) => OrderItemInput(
              productId: item.productId,
              productName: item.product?.name ?? 'Linked Product',
              quantity: item.quantity,
              pricePerDay: item.pricePerDay,
              gstPercentage: item.gstPercentage,
              isAvailable: true,
              discount: item.discount,
              discountType: item.discountType,
            ),
          ),
        );
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

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _productSearchCancelToken?.cancel('Form disposed');
    _searchAvailCancelToken?.cancel('Form disposed');
    for (final item in _items) {
      item.cancelToken?.cancel('Form disposed');
      item.dispose();
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
    ref.listen(customerSearchProvider, (previous, next) {});

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Order' : 'Create Order',
          style: TextStyle(
            fontSize: Responsive.sp(18),
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: Responsive.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader(
                      'Customer',
                      icon: Icons.person_outline_rounded,
                    ),
                    _buildCard(
                      children: [
                        // Customer Search Field with Dropdown
                        _buildCustomerSearchField(),
                      ],
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    _buildSectionHeader(
                      'Rental Period',
                      icon: Icons.calendar_today_outlined,
                    ),
                    _buildCard(
                      children: [
                        // Dates Selectors
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(
                                label: 'Start Date',
                                controller: _startDateController,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ),
                            SizedBox(
                              width: Responsive.w(AppSizes.spacingMedium),
                            ),
                            Expanded(
                              child: _buildDateField(
                                label: 'End Date',
                                controller: _endDateController,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
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
                            borderRadius: BorderRadius.circular(
                              Responsive.r(AppSizes.radiusSmall),
                            ),
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
                              SizedBox(
                                width: Responsive.w(AppSizes.spacingSmall),
                              ),
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
                            border: Border.all(
                              color: AppColors.info.withValues(alpha: 0.15),
                            ),
                            borderRadius: BorderRadius.circular(
                              Responsive.r(AppSizes.radiusSmall),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.info,
                                size: Responsive.icon(AppSizes.iconTiny),
                              ),
                              SizedBox(
                                width: Responsive.w(AppSizes.spacingSmall),
                              ),
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
                      ],
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    _buildSectionHeader(
                      'Rent Items',
                      icon: Icons.shopping_bag_outlined,
                    ),
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
                            Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.grey[400],
                              size: Responsive.icon(28),
                            ),
                            SizedBox(height: Responsive.h(8)),
                            Text(
                              'Search and add products',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: Responsive.sp(13),
                              ),
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
                    _buildTotalsCard(),
                    // === ORDER DISCOUNT + ADVANCE (matching web below-totals section) ===
                    if (_items.isNotEmpty) ...[
                      _buildDiscountAndAdvanceSection(isEditing),
                    ],
                    // === FINAL SUMMARY (Advance deduction + Balance + warnings) ===
                    _buildFinalSummaryCard(),
                    // === ADDRESS & NOTES (matching web's simple layout) ===
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    _buildSectionHeader(
                      'Address & Notes',
                      icon: Icons.location_on_outlined,
                    ),
                    _buildCard(
                      children: [
                        Text(
                          'Customer / Delivery Address',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontMedium),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                        TextFormField(
                          controller: _deliveryAddressController,
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontMedium),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter address for delivery or record...',
                            hintStyle: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium),
                              color: Colors.grey[400],
                            ),
                            contentPadding: Responsive.symmetric(
                              horizontal: AppSizes.spacingMedium,
                              vertical: AppSizes.spacingSmall,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Responsive.r(AppSizes.radiusSmall),
                              ),
                            ),
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                        Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontMedium),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                        TextFormField(
                          controller: _notesController,
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontMedium),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Optional notes about this order...',
                            hintStyle: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium),
                              color: Colors.grey[400],
                            ),
                            contentPadding: Responsive.symmetric(
                              horizontal: AppSizes.spacingMedium,
                              vertical: AppSizes.spacingSmall,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Responsive.r(AppSizes.radiusSmall),
                              ),
                            ),
                          ),
                          maxLines: 2,
                        ),
                        // Edit-mode only: Order Status + Payment Status
                        if (isEditing) ...[
                          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                          DropdownButtonFormField<OrderStatus>(
                            initialValue: _selectedStatus,
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium),
                              color: AppColors.primary,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Order Status',
                              contentPadding: Responsive.symmetric(
                                horizontal: AppSizes.spacingMedium,
                                vertical: AppSizes.spacingSmall,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  Responsive.r(AppSizes.radiusSmall),
                                ),
                              ),
                            ),
                            items: OrderStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedStatus = val),
                          ),
                          SizedBox(
                            height: Responsive.h(AppSizes.spacingMedium),
                          ),
                          DropdownButtonFormField<PaymentStatus>(
                            initialValue: _selectedPaymentStatus,
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium),
                              color: AppColors.primary,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Payment Status',
                              contentPadding: Responsive.symmetric(
                                horizontal: AppSizes.spacingMedium,
                                vertical: AppSizes.spacingSmall,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  Responsive.r(AppSizes.radiusSmall),
                                ),
                              ),
                            ),
                            items: PaymentStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedPaymentStatus = val),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingHuge)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, Responsive.h(48)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Responsive.r(AppSizes.radiusMedium),
                          ),
                        ),
                        elevation: AppSizes.spacingTiny / 2,
                      ),
                      onPressed: _submit,
                      child: Text(
                        isEditing ? 'Save Changes' : 'Confirm Order',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontLarge),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingHuge)),
                  ],
                ),
              ),
            ),
    );
  }
}
