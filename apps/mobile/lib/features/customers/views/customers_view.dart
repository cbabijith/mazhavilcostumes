import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../models/customer.dart';
import '../viewmodels/providers/customer_provider.dart';
import 'customer_detail_view.dart';
import 'customer_form_view.dart';

class CustomersView extends ConsumerStatefulWidget {
  const CustomersView({super.key});

  @override
  ConsumerState<CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends ConsumerState<CustomersView> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  
  final List<Customer> _allCustomers = [];
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isFirstLoad = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPage();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoadingMore && !_isFirstLoad && _errorMsg == null) {
        _page++;
        _loadPage();
      }
    }
  }

  Future<void> _loadPage() async {
    if (_isLoadingMore) return;

    setState(() {
      _errorMsg = null;
      if (_page == 1) {
        _isFirstLoad = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final repo = ref.read(customerRepositoryProvider);
      final paginated = await repo.getCustomers(
        page: _page,
        limit: _limit,
        query: _searchController.text.isNotEmpty ? _searchController.text : null,
      );

      if (mounted) {
        setState(() {
          if (_page == 1) {
            _allCustomers.clear();
          }
          _allCustomers.addAll(paginated.customers);
          _hasMore = paginated.hasNext;
          _isFirstLoad = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString();
          _isFirstLoad = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _refreshList() {
    setState(() {
      _page = 1;
      _hasMore = true;
    });
    _loadPage();
    ref.invalidate(customersCacheProvider);
  }

  void _search() {
    _refreshList();
  }

  Future<void> _launchCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    String formattedPhone = cleanPhone;
    if (cleanPhone.length == 10) {
      formattedPhone = '91$cleanPhone';
    }
    final url = Uri.parse('https://wa.me/$formattedPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final cacheAsync = ref.watch(customersCacheProvider);

    // Compute Metrics dynamically from cache list
    int totalCount = 0;
    int verifiedCount = 0;
    int unverifiedCount = 0;

    if (cacheAsync.hasValue) {
      final allCustomers = cacheAsync.value?.customers ?? [];
      totalCount = allCustomers.length;
      verifiedCount = allCustomers
          .where((c) => c.idType != null && c.idNumber != null && c.idNumber!.isNotEmpty)
          .length;
      unverifiedCount = totalCount - verifiedCount;
    } else {
      totalCount = _allCustomers.length;
      verifiedCount = _allCustomers
          .where((c) => c.idType != null && c.idNumber != null && c.idNumber!.isNotEmpty)
          .length;
      unverifiedCount = totalCount - verifiedCount;
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Customers'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, size: Responsive.icon(AppSizes.iconLarge)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerFormView(),
                ),
              ).then((_) => _refreshList());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => _refreshList(),
        child: Column(
          children: [
            // 1. KPI Metrics Summary Header
            _buildMetricsHeader(
              total: totalCount,
              verified: verifiedCount,
              unverified: unverifiedCount,
            ),

            // 2. Modern Glassmorphism-style Search Box
            Padding(
              padding: Responsive.only(
                left: AppSizes.spacingLarge,
                right: AppSizes.spacingLarge,
                top: AppSizes.spacingSmall,
                bottom: AppSizes.spacingMedium,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: Responsive.r(12),
                      offset: Offset(0, Responsive.h(4)),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium + 1)),
                  decoration: InputDecoration(
                    hintText: 'Search customer name or phone...',
                    hintStyle: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                      color: AppColors.secondaryText,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: Responsive.icon(AppSizes.iconMedium),
                      color: AppColors.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              size: Responsive.icon(AppSizes.iconMedium),
                              color: AppColors.secondaryText,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _search();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: Responsive.symmetric(
                      horizontal: AppSizes.spacingMedium,
                      vertical: AppSizes.spacingMedium,
                    ),
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      _search();
                    });
                    setState(() {});
                  },
                  onSubmitted: (_) => _search(),
                ),
              ),
            ),

            // 3. Customers Grid / List Section
            Expanded(
              child: _buildListBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListBody() {
    if (_isFirstLoad && _allCustomers.isEmpty) {
      return _buildShimmerSkeleton();
    }
    
    if (_errorMsg != null && _allCustomers.isEmpty) {
      return _buildErrorState(_errorMsg!);
    }

    if (_allCustomers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: Responsive.symmetric(horizontal: AppSizes.spacingLarge),
      itemCount: _allCustomers.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _allCustomers.length) {
          return Padding(
            padding: Responsive.symmetric(vertical: AppSizes.spacingMedium),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        final customer = _allCustomers[index];
        return _buildCustomerItem(customer);
      },
    );
  }

  Widget _buildMetricsHeader({
    required int total,
    required int verified,
    required int unverified,
  }) {
    return Padding(
      padding: Responsive.all(AppSizes.spacingLarge),
      child: Row(
        children: [
          _buildMetricCard(
            title: 'Total',
            value: '$total',
            icon: Icons.people_alt_rounded,
            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingSmall + 2)),
          _buildMetricCard(
            title: 'Verified',
            value: '$verified',
            icon: Icons.verified_user_rounded,
            colors: [AppColors.info, AppColors.info.withValues(alpha: 0.8)],
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingSmall + 2)),
          _buildMetricCard(
            title: 'Pending ID',
            value: '$unverified',
            icon: Icons.pending_actions_rounded,
            colors: [AppColors.warning, AppColors.warning.withValues(alpha: 0.8)],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Expanded(
      child: Container(
        padding: Responsive.all(AppSizes.spacingMedium),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.25),
              blurRadius: Responsive.r(8),
              offset: Offset(0, Responsive.h(3)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: Responsive.icon(AppSizes.iconSmall + 2),
                  color: Colors.white70,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontLarge + 2),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerItem(Customer customer) {
    final hasId = customer.idType != null && customer.idNumber != null && customer.idNumber!.isNotEmpty;

    return Card(
      margin: Responsive.only(bottom: AppSizes.spacingMedium),
      elevation: AppSizes.spacingTiny / 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerDetailView(customer: customer),
            ),
          ).then((_) => _refreshList());
        },
        child: Padding(
          padding: Responsive.all(AppSizes.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Core info Row
              Row(
                children: [
                  // Photo Avatar
                  Container(
                    width: Responsive.w(52),
                    height: Responsive.w(52),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.08),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        width: AppSizes.spacingTiny / 2,
                      ),
                    ),
                    child: ClipOval(
                      child: customer.photoUrl != null && customer.photoUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: customer.photoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: AppColors.shimmerBase,
                                highlightColor: AppColors.shimmerHighlight,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => _buildInitialsAvatar(customer.name),
                            )
                          : _buildInitialsAvatar(customer.name),
                    ),
                  ),
                  SizedBox(width: Responsive.w(AppSizes.spacingMedium)),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontMedium + 1),
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              size: Responsive.icon(AppSizes.iconTiny),
                              color: AppColors.secondaryText,
                            ),
                            SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                            Text(
                              customer.phone,
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontSmall),
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Verification Badge
                  Container(
                    padding: Responsive.symmetric(
                      horizontal: AppSizes.spacingSmall,
                      vertical: AppSizes.spacingTiny,
                    ),
                    decoration: BoxDecoration(
                      color: hasId
                          ? AppColors.success.withValues(alpha: 0.08)
                          : AppColors.secondaryText.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                      border: Border.all(
                        color: hasId
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.secondaryText.withValues(alpha: 0.2),
                        width: AppSizes.spacingTiny / 4,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasId ? Icons.verified_rounded : Icons.pending_rounded,
                          size: Responsive.icon(AppSizes.iconTiny),
                          color: hasId ? AppColors.success : AppColors.secondaryText,
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingTiny - 1)),
                        Text(
                          hasId ? 'Verified ID' : 'Pending ID',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontTiny),
                            fontWeight: FontWeight.bold,
                            color: hasId ? AppColors.success : AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),

              Divider(color: AppColors.border, height: 1),

              SizedBox(height: Responsive.h(AppSizes.spacingSmall)),

              // Action Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Added: ${_formatDate(customer.createdAt)}',
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Row(
                    children: [
                      // Call action
                      _buildCircleActionButton(
                        icon: Icons.phone_rounded,
                        color: AppColors.primary,
                        onTap: () => _launchCall(customer.phone),
                      ),
                      SizedBox(width: Responsive.w(AppSizes.spacingSmall + 2)),

                      // WhatsApp action
                      _buildCircleActionButton(
                        icon: Icons.chat_rounded,
                        color: const Color(0xFF25D366),
                        onTap: () => _launchWhatsApp(customer.phone),
                      ),

                      if (customer.email != null && customer.email!.isNotEmpty) ...[
                        SizedBox(width: Responsive.w(AppSizes.spacingSmall + 2)),
                        // Email action
                        _buildCircleActionButton(
                          icon: Icons.mail_rounded,
                          color: AppColors.info,
                          onTap: () => _launchEmail(customer.email!),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusXXLarge)),
      child: Container(
        padding: Responsive.all(AppSizes.spacingSmall + 1),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: 0.15),
            width: AppSizes.spacingTiny / 4,
          ),
        ),
        child: Icon(
          icon,
          size: Responsive.icon(AppSizes.iconSmall - 1),
          color: color,
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: Responsive.sp(AppSizes.fontLarge),
        ),
      ),
    );
  }

  Widget _buildShimmerSkeleton() {
    return ListView.builder(
      padding: Responsive.symmetric(horizontal: AppSizes.spacingLarge),
      itemCount: 4,
      itemBuilder: (context, index) => Card(
        margin: Responsive.only(bottom: AppSizes.spacingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        ),
        child: Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Padding(
            padding: Responsive.all(AppSizes.spacingLarge),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: Responsive.w(52),
                      height: Responsive.w(52),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: Responsive.w(140),
                            height: Responsive.h(16),
                            color: Colors.white,
                          ),
                          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                          Container(
                            width: Responsive.w(80),
                            height: Responsive.h(12),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: Responsive.w(70),
                      height: Responsive.h(22),
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                Divider(color: Colors.grey[200], height: 1),
                SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: Responsive.w(60), height: Responsive.h(12), color: Colors.white),
                    Row(
                      children: [
                        Container(width: Responsive.w(30), height: Responsive.w(30), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                        Container(width: Responsive.w(30), height: Responsive.w(30), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: Responsive.all(AppSizes.spacingXXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: Responsive.all(AppSizes.spacingXXLarge),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: Responsive.icon(AppSizes.iconHuge),
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingXXLarge)),
            Text(
              'No Customers Found',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontLarge),
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Text(
              _searchController.text.isNotEmpty
                  ? 'We couldn\'t find any results matching your search.'
                  : 'Start adding customer details to keep record.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontSmall),
                color: AppColors.secondaryText,
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  _search();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: Responsive.icon(AppSizes.iconHuge),
            color: AppColors.error,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          Text(
            'Error: $error',
            style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          ElevatedButton(
            onPressed: () => _refreshList(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
