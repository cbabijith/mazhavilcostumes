import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
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
  final _searchFocusNode = FocusNode();
  int _page = 1;
  final int _limit = 20;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _search() {
    setState(() {
      _page = 1;
    });
  }

  // ── Shimmer Loading ──────────────────────────────────
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: Responsive.symmetric(
        horizontal: AppSizes.screenPaddingSmall,
        vertical: AppSizes.spacingSmall,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: Responsive.only(bottom: AppSizes.spacingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
            border: Border.all(color: AppColors.border),
          ),
          child: Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Accent strip shimmer
                  Container(
                    width: Responsive.w(AppSizes.spacingTiny),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Responsive.r(AppSizes.radiusMedium)),
                        bottomLeft: Radius.circular(Responsive.r(AppSizes.radiusMedium)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: Responsive.all(AppSizes.spacingLarge),
                      child: Row(
                        children: [
                          // Avatar shimmer
                          Container(
                            width: Responsive.w(AppSizes.iconXXLarge + AppSizes.spacingSmall),
                            height: Responsive.h(AppSizes.iconXXLarge + AppSizes.spacingSmall),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: Responsive.w(130),
                                  height: Responsive.h(AppSizes.spacingLarge),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.spacingTiny)),
                                  ),
                                ),
                                SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                                Container(
                                  width: Responsive.w(90),
                                  height: Responsive.h(AppSizes.spacingMedium),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.spacingTiny)),
                                  ),
                                ),
                                SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                                Container(
                                  width: Responsive.w(60),
                                  height: Responsive.h(AppSizes.spacingSmall + 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.spacingTiny)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: Responsive.w(AppSizes.iconLarge + AppSizes.spacingTiny),
                                height: Responsive.h(AppSizes.iconLarge + AppSizes.spacingTiny),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                              Container(
                                width: Responsive.w(AppSizes.iconLarge + AppSizes.spacingTiny),
                                height: Responsive.h(AppSizes.iconLarge + AppSizes.spacingTiny),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Gradient Header ──────────────────────────────────
  Widget _buildGradientHeader(int? totalCount) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            AppColors.primary.withValues(alpha: 0.02),
            Colors.white,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row
            Padding(
              padding: Responsive.symmetric(
                horizontal: AppSizes.screenPaddingSmall,
                vertical: AppSizes.spacingMedium,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Directory',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontXXLarge),
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                        if (totalCount != null)
                          Row(
                            children: [
                              Container(
                                width: Responsive.w(AppSizes.spacingSmall),
                                height: Responsive.h(AppSizes.spacingSmall),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.success.withValues(alpha: 0.4),
                                      blurRadius: Responsive.r(AppSizes.spacingTiny),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                              Text(
                                '$totalCount customers registered',
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Decorative icon
                  Container(
                    padding: Responsive.all(AppSizes.spacingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                    ),
                    child: Icon(
                      Icons.people_alt_rounded,
                      color: AppColors.primary,
                      size: Responsive.icon(AppSizes.iconMedium + AppSizes.spacingTiny),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: Responsive.only(
                left: AppSizes.screenPaddingSmall,
                right: AppSizes.screenPaddingSmall,
                bottom: AppSizes.spacingLarge,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: Responsive.r(AppSizes.spacingXLarge),
                      offset: Offset(0, Responsive.h(AppSizes.spacingTiny)),
                    ),
                  ],
                  border: Border.all(
                    color: _searchFocusNode.hasFocus
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (_) => _search(),
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontMedium),
                    color: AppColors.text,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name or mobile...',
                    hintStyle: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium),
                      color: AppColors.secondaryText.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Padding(
                      padding: Responsive.only(
                        left: AppSizes.spacingMedium,
                        right: AppSizes.spacingSmall,
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: AppColors.primary.withValues(alpha: 0.7),
                        size: Responsive.icon(AppSizes.iconSmall + 2),
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: Responsive.w(AppSizes.iconXLarge),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: AppColors.secondaryText,
                              size: Responsive.icon(AppSizes.iconSmall),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _search();
                            },
                          )
                        : null,
                    contentPadding: Responsive.symmetric(
                      horizontal: AppSizes.spacingMedium,
                      vertical: AppSizes.spacingMedium,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final customersAsync = ref.watch(customersProvider(CustomersParams(
      page: _page,
      limit: _limit,
      query: _searchController.text.isNotEmpty ? _searchController.text.trim() : null,
    )));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomerFormView(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: AppSizes.spacingSmall / 2,
        icon: Icon(
          Icons.person_add_rounded,
          size: Responsive.icon(AppSizes.iconSmall + 2),
          color: Colors.white,
        ),
        label: Text(
          'Add Customer',
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontMedium),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Gradient Header with Search
          _buildGradientHeader(
            customersAsync.value?.total,
          ),

          // Customer List View
          Expanded(
            child: customersAsync.when(
              loading: () => _buildShimmerList(),
              error: (error, stack) => _buildErrorState(error),
              data: (paginatedCustomers) {
                if (paginatedCustomers.customers.isEmpty) {
                  return _buildEmptyState();
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: Responsive.symmetric(
                          horizontal: AppSizes.screenPaddingSmall,
                          vertical: AppSizes.spacingSmall,
                        ),
                        itemCount: paginatedCustomers.customers.length,
                        itemBuilder: (context, index) {
                          final customer = paginatedCustomers.customers[index];
                          return CustomerCardItem(
                            customer: customer,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomerDetailView(customer: customer),
                                ),
                              ).then((_) {
                                ref.invalidate(customersProvider);
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (paginatedCustomers.totalPages > 1)
                      _buildPagination(paginatedCustomers),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: Responsive.all(AppSizes.spacingXXXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: Responsive.all(AppSizes.spacingXXLarge),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_off_rounded,
                size: Responsive.icon(AppSizes.iconXXLarge),
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),
            Text(
              'No customers found',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontLarge),
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Add your first customer to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                color: AppColors.secondaryText,
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _search();
                },
                icon: Icon(
                  Icons.clear_rounded,
                  size: Responsive.icon(AppSizes.iconSmall),
                ),
                label: Text(
                  'Clear Search',
                  style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                ),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Error State ──────────────────────────────────────
  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: Responsive.all(AppSizes.spacingXXXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: Responsive.all(AppSizes.spacingXLarge),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: Responsive.icon(AppSizes.iconXLarge),
                color: AppColors.error.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),
            Text(
              'Failed to load customers',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontLarge),
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Padding(
              padding: Responsive.symmetric(horizontal: AppSizes.spacingXLarge),
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontSmall),
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(customersProvider),
              icon: Icon(
                Icons.refresh_rounded,
                size: Responsive.icon(AppSizes.iconSmall),
              ),
              label: Text(
                'Retry',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontMedium),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: Responsive.symmetric(
                  horizontal: AppSizes.spacingXXLarge,
                  vertical: AppSizes.spacingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pagination ───────────────────────────────────────
  Widget _buildPagination(dynamic paginatedCustomers) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: Responsive.r(AppSizes.spacingSmall),
            offset: Offset(0, -Responsive.h(2)),
          ),
        ],
      ),
      padding: Responsive.symmetric(
        horizontal: AppSizes.screenPaddingSmall,
        vertical: AppSizes.spacingSmall + 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          _buildPaginationButton(
            icon: Icons.chevron_left_rounded,
            label: 'Prev',
            enabled: _page > 1,
            onPressed: () => setState(() => _page--),
          ),
          // Page indicator
          Container(
            padding: Responsive.symmetric(
              horizontal: AppSizes.spacingLarge,
              vertical: AppSizes.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusXLarge)),
            ),
            child: Text(
              '$_page / ${paginatedCustomers.totalPages}',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          // Next button
          _buildPaginationButton(
            icon: Icons.chevron_right_rounded,
            label: 'Next',
            enabled: paginatedCustomers.hasNext,
            onPressed: () => setState(() => _page++),
            iconAfter: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
    bool iconAfter = false,
  }) {
    final iconWidget = Icon(
      icon,
      size: Responsive.icon(AppSizes.iconSmall),
      color: enabled ? AppColors.primary : AppColors.secondaryText.withValues(alpha: 0.4),
    );
    final labelWidget = Text(
      label,
      style: TextStyle(
        fontSize: Responsive.sp(AppSizes.fontSmall + 1),
        fontWeight: FontWeight.w600,
        color: enabled ? AppColors.primary : AppColors.secondaryText.withValues(alpha: 0.4),
      ),
    );

    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        padding: Responsive.symmetric(
          horizontal: AppSizes.spacingMedium,
          vertical: AppSizes.spacingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: iconAfter
            ? [labelWidget, SizedBox(width: Responsive.w(AppSizes.spacingTiny)), iconWidget]
            : [iconWidget, SizedBox(width: Responsive.w(AppSizes.spacingTiny)), labelWidget],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Customer Card Item
// ═══════════════════════════════════════════════════════
class CustomerCardItem extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const CustomerCardItem({
    super.key,
    required this.customer,
    required this.onTap,
  });

  // Primary theme-based colors
  Color get _accentBg => AppColors.primary.withValues(alpha: 0.08);
  Color get _accentFg => AppColors.primary;

  Widget _buildAvatar(BuildContext context) {
    final avatarSize = Responsive.w(AppSizes.iconXXLarge + AppSizes.spacingSmall);

    Widget avatar;
    if (customer.photoUrl != null && customer.photoUrl!.isNotEmpty) {
      avatar = CachedNetworkImage(
        imageUrl: customer.photoUrl!,
        imageBuilder: (context, imageProvider) => Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            border: Border.all(color: _accentFg.withValues(alpha: 0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: _accentFg.withValues(alpha: 0.15),
                blurRadius: Responsive.r(AppSizes.spacingSmall),
                offset: Offset(0, Responsive.h(2)),
              ),
            ],
          ),
        ),
        placeholder: (context, url) => Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _accentBg,
          ),
          child: Center(
            child: SizedBox(
              width: Responsive.w(AppSizes.spacingXLarge),
              height: Responsive.h(AppSizes.spacingXLarge),
              child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildInitialsAvatar(avatarSize),
      );
    } else {
      avatar = _buildInitialsAvatar(avatarSize);
    }

    // Wrap in Hero for transition to detail
    return Hero(
      tag: 'customer_avatar_${customer.id}',
      child: avatar,
    );
  }

  Widget _buildInitialsAvatar(double size) {
    final initials = customer.name.trim().isNotEmpty
        ? customer.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'C';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _accentBg,
        border: Border.all(color: _accentFg.withValues(alpha: 0.15), width: 2),
        boxShadow: [
          BoxShadow(
            color: _accentFg.withValues(alpha: 0.12),
            blurRadius: Responsive.r(AppSizes.spacingSmall),
            offset: Offset(0, Responsive.h(2)),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: _accentFg,
            fontWeight: FontWeight.w800,
            fontSize: Responsive.sp(AppSizes.fontLarge),
          ),
        ),
      ),
    );
  }

  void _callNumber() async {
    final uri = Uri.parse('tel:${customer.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _whatsappChat() async {
    String formattedPhone = customer.phone.replaceAll(RegExp(r'\D'), '');
    if (formattedPhone.length == 10) {
      formattedPhone = '91$formattedPhone';
    }
    final message = 'Hi ${customer.name}, this is regarding your costume booking at ${AppStrings.appName}.';
    final whatsappUrl = Uri.parse(
      'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}',
    );
    try {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isIdVerified = (customer.idNumber != null && customer.idNumber!.isNotEmpty) ||
        (customer.idDocuments != null && customer.idDocuments!.isNotEmpty);

    return Container(
      margin: Responsive.only(bottom: AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: Responsive.r(AppSizes.spacingMedium),
            offset: Offset(0, Responsive.h(2)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left accent strip
                Container(
                  width: Responsive.w(AppSizes.spacingTiny),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.5),
                        AppColors.primary.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                ),
                // Card content
                Expanded(
                  child: Padding(
                    padding: Responsive.all(AppSizes.spacingLarge),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        _buildAvatar(context),
                        SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                        // Name, phone, badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Name + verification dot
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      customer.name,
                                      style: TextStyle(
                                        fontSize: Responsive.sp(AppSizes.fontMedium + 1),
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                                  // Compact verification indicator
                                  Container(
                                    padding: Responsive.symmetric(
                                      horizontal: AppSizes.spacingSmall,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isIdVerified
                                          ? AppColors.success.withValues(alpha: 0.1)
                                          : AppColors.warning.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(Responsive.r(AppSizes.spacingSmall)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isIdVerified
                                              ? Icons.verified_rounded
                                              : Icons.info_outline_rounded,
                                          size: Responsive.icon(AppSizes.fontTiny + 2),
                                          color: isIdVerified ? AppColors.success : AppColors.warning,
                                        ),
                                        SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                        Text(
                                          isIdVerified ? 'ID' : 'No ID',
                                          style: TextStyle(
                                            fontSize: Responsive.sp(AppSizes.fontTiny),
                                            fontWeight: FontWeight.w700,
                                            color: isIdVerified ? AppColors.success : AppColors.warning,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Responsive.h(AppSizes.spacingTiny + 2)),
                              // Phone
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_android_rounded,
                                    color: AppColors.secondaryText.withValues(alpha: 0.6),
                                    size: Responsive.icon(AppSizes.fontSmall + 2),
                                  ),
                                  SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                  Text(
                                    customer.phone,
                                    style: TextStyle(
                                      fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                                      color: AppColors.secondaryText,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              // Email (if present)
                              if (customer.email != null && customer.email!.isNotEmpty) ...[
                                SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.mail_outline_rounded,
                                      color: AppColors.secondaryText.withValues(alpha: 0.5),
                                      size: Responsive.icon(AppSizes.fontSmall + 2),
                                    ),
                                    SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                    Expanded(
                                      child: Text(
                                        customer.email!,
                                        style: TextStyle(
                                          fontSize: Responsive.sp(AppSizes.fontSmall),
                                          color: AppColors.secondaryText.withValues(alpha: 0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                        // Quick action buttons (icon-only)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildQuickActionButton(
                              iconWidget: Icon(
                                Icons.phone_in_talk_rounded,
                                color: AppColors.info,
                                size: Responsive.icon(AppSizes.iconSmall - 2),
                              ),
                              color: AppColors.info,
                              onTap: _callNumber,
                            ),
                            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                            _buildQuickActionButton(
                              iconWidget: FaIcon(
                                FontAwesomeIcons.whatsapp,
                                color: AppColors.success,
                                size: Responsive.icon(AppSizes.iconSmall - 2),
                              ),
                              color: AppColors.success,
                              onTap: _whatsappChat,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required Widget iconWidget,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusXLarge)),
        child: Container(
          padding: Responsive.all(AppSizes.spacingSmall + 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: iconWidget,
        ),
      ),
    );
  }
}
