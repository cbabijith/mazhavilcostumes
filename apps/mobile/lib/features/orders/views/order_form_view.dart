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
  String _productSearchQuery = '';
  List<p_model.Product> _productSearchResults = [];
  bool _isSearchingProducts = false;

  // Product search availability state
  Map<String, Map<String, dynamic>> _searchAvailabilityMap = {};
  bool _isCheckingSearchAvailability = false;
  DeliveryMethod? _selectedDeliveryMethod = DeliveryMethod.pickup;
  final List<OrderItemInput> _items = [];
  final Set<String> _expandedBookings = {};
  int _currentPage = 0;
  late final PageController _pageController;

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
    _pageController = PageController();

    // Default branch ID from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentBranchId = ref.read(effectiveBranchIdProvider);
      if (currentBranchId != null && _selectedBranchId == null) {
        setState(() {
          _selectedBranchId = currentBranchId;
        });
      }
      // Prefetch customer cache to ensure it is warm/warming up
      ref.read(customersCacheProvider);
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
              originalPricePerDay: item.originalPricePerDay ?? item.pricePerDay,
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
    _pageController.dispose();
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

    String appBarTitle = '1. Customer & Dates';
    if (isEditing) {
      appBarTitle = widget.order!.invoiceNumber != null
          ? 'Edit Order #${widget.order!.invoiceNumber}'
          : 'Edit Order #${widget.order!.id.substring(0, 8)}';
    } else if (_currentPage == 1) {
      appBarTitle = '2. Select Costumes';
    } else if (_currentPage == 2) {
      appBarTitle = '3. Review & Checkout';
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: TextStyle(
            fontSize: Responsive.sp(18),
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        leading: (isEditing || _currentPage > 0)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (isEditing) {
                    Navigator.pop(context);
                  } else {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              )
            : null,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
          _update(() {
            _showCustomerDropdown = false;
          });
        },
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: _buildFormContent(isEditing),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.25),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar:
          _currentPage == 1 ? _buildFloatingCartSummaryBar() : null,
    );
  }

  Widget _buildFloatingCartSummaryBar() {
    if (_items.isEmpty) return const SizedBox.shrink();

    final hasInvalidPrice = _items.any((item) => item.pricePerDay < item.originalPricePerDay);

    return SafeArea(
      child: Container(
        padding: Responsive.all(AppSizes.spacingMedium),
        margin: Responsive.symmetric(
          horizontal: AppSizes.spacingMedium,
          vertical: AppSizes.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_items.length} ${_items.length == 1 ? 'item' : 'items'} added',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontSmall),
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: Responsive.h(2)),
                Text(
                  'Subtotal: ₹${_subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontMedium),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasInvalidPrice ? Colors.grey[300] : AppColors.primary,
                foregroundColor: hasInvalidPrice ? Colors.grey[500] : Colors.white,
                minimumSize: Size(Responsive.w(150), Responsive.h(40)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                ),
              ),
              onPressed: hasInvalidPrice
                  ? null
                  : () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Review & Pay'),
                  SizedBox(width: Responsive.w(4)),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: hasInvalidPrice ? Colors.grey[500] : Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupSection(bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          'Customer',
          icon: Icons.person_outline_rounded,
        ),
        _buildCard(
          children: [
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
                SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
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
      ],
    );
  }

  List<Widget> _buildCostumesSection(bool isEditing) {
    return [
      _buildSectionHeader(
        'Selected Costumes',
        icon: Icons.checkroom_outlined,
      ),
      _buildProductSearchField(),
      SizedBox(height: Responsive.h(12)),
      if (isEditing)
        _productSearchQuery.isNotEmpty
            ? _buildCatalogResultsList()
            : _buildCartItemsList()
      else
        Expanded(
          child: _productSearchQuery.isNotEmpty
              ? _buildCatalogResultsList()
              : _buildCartItemsList(),
        ),
    ];
  }

  Widget _buildCheckoutSection(bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTotalsCard(),
        if (_items.isNotEmpty) ...[
          _buildDiscountAndAdvanceSection(isEditing),
        ],
        _buildFinalSummaryCard(),
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
          ],
        ),
        SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
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
          onPressed: () {
            if (_selectedCustomerId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please select a customer')),
              );
              return;
            }
            if (_items.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please add at least one item')),
              );
              return;
            }
            if (!_formKey.currentState!.validate()) return;
            _submit();
          },
          child: Text(
            isEditing ? 'Save Changes' : 'Confirm Order',
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontLarge),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent(bool isEditing) {
    if (isEditing) {
      return SingleChildScrollView(
        padding: Responsive.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSetupSection(isEditing),
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            ..._buildCostumesSection(isEditing),
            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            _buildCheckoutSection(isEditing),
          ],
        ),
      );
    }

    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      children: [
        // Page 0: Customer & Rental Period
        SingleChildScrollView(
          padding: Responsive.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSetupSection(isEditing),
              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
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
                ),
                onPressed: () {
                  if (_selectedCustomerId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select a customer')),
                    );
                    return;
                  }
                  if (!_formKey.currentState!.validate()) return;
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Select Costumes',
                      style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontLarge),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: Responsive.w(8)),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Page 1: Product Selection Catalog
        Padding(
          padding: Responsive.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._buildCostumesSection(isEditing),
            ],
          ),
        ),

        // Page 2: Checkout & Billing
        SingleChildScrollView(
          padding: Responsive.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCheckoutSection(isEditing),
            ],
          ),
        ),
      ],
    );
  }
}
