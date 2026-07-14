import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../models/customer.dart';
import '../viewmodels/providers/customer_provider.dart';
import 'customer_form_view.dart';

class CustomerDetailView extends ConsumerWidget {
  final Customer customer;

  const CustomerDetailView({super.key, required this.customer});

  // Primary theme-based colors
  Color get _accentBg => AppColors.primary.withValues(alpha: 0.08);
  Color get _accentFg => AppColors.primary;

  Widget _buildHeroAvatar(BuildContext context, Customer currentCustomer) {
    final avatarSize = Responsive.w(90);

    Widget avatar;
    if (currentCustomer.photoUrl != null && currentCustomer.photoUrl!.isNotEmpty) {
      avatar = CachedNetworkImage(
        imageUrl: currentCustomer.photoUrl!,
        imageBuilder: (context, imageProvider) => Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: Responsive.r(AppSizes.spacingLarge),
                offset: Offset(0, Responsive.h(AppSizes.spacingTiny)),
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
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        errorWidget: (context, url, error) => _buildInitialsAvatar(avatarSize, currentCustomer),
      );
    } else {
      avatar = _buildInitialsAvatar(avatarSize, currentCustomer);
    }

    return Hero(
      tag: 'customer_avatar_${currentCustomer.id}',
      child: avatar,
    );
  }

  Widget _buildInitialsAvatar(double size, Customer currentCustomer) {
    final initials = currentCustomer.name.trim().isNotEmpty
        ? currentCustomer.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'C';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _accentBg,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: _accentFg.withValues(alpha: 0.2),
            blurRadius: Responsive.r(AppSizes.spacingLarge),
            offset: Offset(0, Responsive.h(AppSizes.spacingTiny)),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: _accentFg,
            fontWeight: FontWeight.w800,
            fontSize: Responsive.sp(AppSizes.fontXXLarge + 2),
          ),
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────
  void _callNumber(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _whatsappChat(String phone, String name) async {
    String formattedPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (formattedPhone.length == 10) {
      formattedPhone = '91$formattedPhone';
    }
    final message = 'Hi $name, this is regarding your costume booking at ${AppStrings.appName}.';
    final whatsappUrl = Uri.parse(
      'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}',
    );
    try {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
    }
  }

  void _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatDateString(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
    } catch (e) {
      return dateStr;
    }
  }

  void _showFullImage(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => ImageDetailDialog(imageUrl: imageUrl, title: title),
    );
  }

  Widget _buildShimmerDetail(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: Responsive.symmetric(horizontal: AppSizes.screenPaddingSmall),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
              // Avatar Shimmer
              Center(
                child: Container(
                  width: Responsive.w(90),
                  height: Responsive.w(90),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
              // Name Shimmer
              Center(
                child: Container(
                  width: Responsive.w(150),
                  height: Responsive.h(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.spacingTiny)),
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
              // Phone Shimmer
              Center(
                child: Container(
                  width: Responsive.w(100),
                  height: Responsive.h(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.spacingTiny)),
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
              // Buttons Shimmer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => Padding(
                  padding: Responsive.symmetric(horizontal: AppSizes.spacingMedium),
                  child: Container(
                    width: Responsive.w(52),
                    height: Responsive.w(52),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                )),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingHuge)),
              // Section Shimmer 1
              _buildShimmerSection(),
              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
              // Section Shimmer 2
              _buildShimmerSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerSection() {
    return Container(
      padding: Responsive.all(AppSizes.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: Responsive.w(32),
                height: Responsive.w(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                ),
              ),
              SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
              Container(
                width: Responsive.w(120),
                height: Responsive.h(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.spacingTiny)),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          ...List.generate(3, (index) => Padding(
            padding: Responsive.only(bottom: AppSizes.spacingMedium),
            child: Row(
              children: [
                Container(
                  width: Responsive.w(80),
                  height: Responsive.h(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.spacingTiny)),
                  ),
                ),
                SizedBox(width: Responsive.w(AppSizes.spacingXLarge)),
                Expanded(
                  child: Container(
                    height: Responsive.h(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Responsive.r(AppSizes.spacingTiny)),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Responsive.init(context);

    final customerDetailsAsync = ref.watch(customerProvider(customer.id));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: customerDetailsAsync.when(
        data: (activeCustomer) => _buildDetailContent(context, ref, activeCustomer),
        loading: () => _buildShimmerDetail(context),
        error: (err, stack) => _buildDetailContent(context, ref, customer),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, WidgetRef ref, Customer currentCustomer) {
    final bool isIdVerified = (currentCustomer.idNumber != null && currentCustomer.idNumber!.isNotEmpty) ||
        (currentCustomer.idDocuments != null && currentCustomer.idDocuments!.isNotEmpty);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Gradient Header with Profile ───────────────
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _accentFg.withValues(alpha: 0.08),
                  _accentFg.withValues(alpha: 0.03),
                  AppColors.scaffoldBackground,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top action bar
                  Padding(
                    padding: Responsive.symmetric(
                      horizontal: AppSizes.spacingSmall,
                      vertical: AppSizes.spacingSmall,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: Responsive.all(AppSizes.spacingSmall),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: Responsive.r(AppSizes.spacingSmall),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.text,
                              size: Responsive.icon(AppSizes.iconSmall),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        // Edit button
                        _buildHeaderActionButton(
                          icon: Icons.edit_rounded,
                          color: AppColors.primary,
                          onPressed: () {
                            final currentCustomerData = ref.read(customerProvider(customer.id)).value ?? customer;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerFormView(customer: currentCustomerData),
                              ),
                            ).then((_) {
                              ref.invalidate(customerProvider(customer.id));
                              ref.invalidate(customersProvider);
                            });
                          },
                        ),
                        SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                        // Delete button
                        _buildHeaderActionButton(
                          icon: Icons.delete_outline_rounded,
                          color: AppColors.error,
                          onPressed: () => _showDeleteDialog(context, ref),
                        ),
                      ],
                    ),
                  ),

                  // Avatar + Name
                  Padding(
                    padding: Responsive.only(bottom: AppSizes.spacingXLarge),
                    child: Column(
                      children: [
                        _buildHeroAvatar(context, currentCustomer),
                        SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                        Text(
                          currentCustomer.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontXXLarge),
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                        Text(
                          currentCustomer.phone,
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontMedium),
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                        // Verification badge
                        Container(
                          padding: Responsive.symmetric(
                            horizontal: AppSizes.spacingMedium,
                            vertical: AppSizes.spacingTiny + 2,
                          ),
                          decoration: BoxDecoration(
                            color: isIdVerified
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusXLarge)),
                            border: Border.all(
                              color: isIdVerified
                                  ? AppColors.success.withValues(alpha: 0.2)
                                  : AppColors.warning.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isIdVerified ? Icons.verified_rounded : Icons.warning_amber_rounded,
                                size: Responsive.icon(AppSizes.fontSmall + 2),
                                color: isIdVerified ? AppColors.success : AppColors.warning,
                              ),
                              SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                              Text(
                                isIdVerified ? 'Identity Verified' : 'ID Not Verified',
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontSmall),
                                  fontWeight: FontWeight.w700,
                                  color: isIdVerified ? AppColors.success : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),
                        // Communication buttons
                        Padding(
                          padding: Responsive.symmetric(horizontal: AppSizes.spacingHuge),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildFloatingComButton(
                                iconWidget: Icon(
                                  Icons.phone_in_talk_rounded,
                                  color: AppColors.info,
                                  size: Responsive.icon(AppSizes.iconSmall + 2),
                                ),
                                label: 'Call',
                                color: AppColors.info,
                                onPressed: () => _callNumber(currentCustomer.phone),
                              ),
                              SizedBox(width: Responsive.w(AppSizes.spacingXLarge)),
                              _buildFloatingComButton(
                                iconWidget: FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  color: AppColors.success,
                                  size: Responsive.icon(AppSizes.iconSmall + 2),
                                ),
                                label: 'WhatsApp',
                                color: AppColors.success,
                                onPressed: () => _whatsappChat(currentCustomer.phone, currentCustomer.name),
                              ),
                              if (currentCustomer.email != null && currentCustomer.email!.isNotEmpty) ...[
                                SizedBox(width: Responsive.w(AppSizes.spacingXLarge)),
                                _buildFloatingComButton(
                                  iconWidget: Icon(
                                    Icons.email_rounded,
                                    color: AppColors.primary,
                                    size: Responsive.icon(AppSizes.iconSmall + 2),
                                  ),
                                  label: 'Email',
                                  color: AppColors.primary,
                                  onPressed: () => _sendEmail(currentCustomer.email!),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Body Sections ──────────────────────────────
        SliverPadding(
          padding: Responsive.symmetric(horizontal: AppSizes.screenPaddingSmall),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Personal Information
              _buildInfoSection(
                title: 'Personal Information',
                icon: Icons.person_outline_rounded,
                color: AppColors.primary,
                children: [
                  _buildDetailRow('Full Name', currentCustomer.name),
                  _buildDetailRow('Phone', currentCustomer.phone),
                  if (currentCustomer.altPhone != null && currentCustomer.altPhone!.isNotEmpty)
                    _buildDetailRow('Alt. Phone', currentCustomer.altPhone!, isPhone: true),
                  _buildDetailRow('Email', currentCustomer.email ?? 'Not provided'),
                  _buildDetailRow('Address', currentCustomer.address ?? 'Not provided'),
                  if (currentCustomer.gstin != null && currentCustomer.gstin!.isNotEmpty)
                    _buildDetailRow('GSTIN', currentCustomer.gstin!.toUpperCase()),
                ],
              ),

              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),

              // Identity Verification
              if (currentCustomer.idType != null ||
                  currentCustomer.idNumber != null ||
                  (currentCustomer.idDocuments != null && currentCustomer.idDocuments!.isNotEmpty))
                _buildInfoSection(
                  title: 'Identity Verification',
                  icon: Icons.badge_outlined,
                  color: AppColors.primary,
                  children: [
                    if (currentCustomer.idType != null)
                      _buildDetailRow('ID Type', currentCustomer.idType.toString().split('.').last.toUpperCase()),
                    if (currentCustomer.idNumber != null && currentCustomer.idNumber!.isNotEmpty)
                      _buildDetailRow('ID Number', currentCustomer.idNumber!),
                    if (currentCustomer.idDocuments != null && currentCustomer.idDocuments!.isNotEmpty) ...[
                      SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                      Text(
                        'Uploaded Documents',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: Responsive.w(AppSizes.spacingMedium),
                          mainAxisSpacing: Responsive.h(AppSizes.spacingMedium),
                          childAspectRatio: 1.3,
                        ),
                        itemCount: currentCustomer.idDocuments!.length,
                        itemBuilder: (context, idx) {
                          final doc = currentCustomer.idDocuments![idx];
                          final sideLabel = doc.type == 'front' ? 'Front Side' : 'Back Side';
                          return GestureDetector(
                            onTap: () => _showFullImage(context, doc.url, '${currentCustomer.name} ID - $sideLabel'),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: Responsive.r(AppSizes.spacingSmall),
                                    offset: Offset(0, Responsive.h(2)),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: doc.url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: AppColors.scaffoldBackground,
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                      ),
                                    ),
                                    errorWidget: (context, url, err) => Container(
                                      color: AppColors.scaffoldBackground,
                                      child: const Icon(Icons.image_not_supported_rounded, color: AppColors.secondaryText),
                                    ),
                                  ),
                                  // Gradient overlay with label
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.7),
                                          ],
                                        ),
                                      ),
                                      padding: Responsive.symmetric(
                                        vertical: AppSizes.spacingSmall,
                                        horizontal: AppSizes.spacingMedium,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              sideLabel,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: Responsive.sp(AppSizes.fontSmall),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.zoom_in_rounded,
                                            color: Colors.white.withValues(alpha: 0.8),
                                            size: Responsive.icon(AppSizes.iconSmall - 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),

              if (currentCustomer.idType != null ||
                  currentCustomer.idNumber != null ||
                  (currentCustomer.idDocuments != null && currentCustomer.idDocuments!.isNotEmpty))
                SizedBox(height: Responsive.h(AppSizes.spacingLarge)),

              // ── Audit Timeline ─────────────────────────
              _buildAuditTimeline(currentCustomer),

              SizedBox(height: Responsive.h(AppSizes.spacingHuge)),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Header Action Button ─────────────────────────────
  Widget _buildHeaderActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: Responsive.all(AppSizes.spacingSmall),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: Responsive.r(AppSizes.spacingSmall),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: Responsive.icon(AppSizes.iconSmall),
        ),
      ),
    );
  }

  // ── Floating Communication Button ────────────────────
  Widget _buildFloatingComButton({
    required Widget iconWidget,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: Responsive.all(AppSizes.spacingMedium),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: Responsive.r(AppSizes.spacingMedium),
                  offset: Offset(0, Responsive.h(AppSizes.spacingTiny)),
                ),
              ],
            ),
            child: iconWidget,
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingTiny + 2)),
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontTiny + 1),
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Section Card ────────────────────────────────
  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
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
                      color.withValues(alpha: 0.8),
                      color.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: Responsive.all(AppSizes.spacingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: Responsive.all(AppSizes.spacingSmall),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: Responsive.icon(AppSizes.iconSmall),
                            ),
                          ),
                          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium + 1),
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                      ...children,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Detail Row ───────────────────────────────────────
  Widget _buildDetailRow(String label, String value, {bool isPhone = false}) {
    return Padding(
      padding: Responsive.only(bottom: AppSizes.spacingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Responsive.w(100),
            child: Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
          // Dot separator
          Padding(
            padding: Responsive.only(top: AppSizes.spacingSmall),
            child: Container(
              width: Responsive.w(AppSizes.spacingTiny),
              height: Responsive.h(AppSizes.spacingTiny),
              decoration: BoxDecoration(
                color: AppColors.secondaryText.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isPhone && value != 'N/A' && value.isNotEmpty)
                  GestureDetector(
                    onTap: () => _callNumber(value),
                    child: Padding(
                      padding: Responsive.symmetric(horizontal: AppSizes.spacingTiny),
                      child: Icon(
                        Icons.phone_rounded,
                        color: AppColors.info,
                        size: Responsive.icon(AppSizes.iconSmall - 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Audit Timeline ───────────────────────────────────
  Widget _buildAuditTimeline(Customer currentCustomer) {
    final entries = <_TimelineEntry>[
      _TimelineEntry(
        label: 'Created',
        value: _formatDateString(currentCustomer.createdAt),
        subtitle: currentCustomer.createdBy,
      ),
      _TimelineEntry(
        label: 'Last Updated',
        value: _formatDateString(currentCustomer.updatedAt),
        subtitle: currentCustomer.updatedBy,
      ),
    ];

    return Container(
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
                      AppColors.secondaryText.withValues(alpha: 0.5),
                      AppColors.secondaryText.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: Responsive.all(AppSizes.spacingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: Responsive.all(AppSizes.spacingSmall),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryText.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                            ),
                            child: Icon(
                              Icons.history_rounded,
                              color: AppColors.secondaryText,
                              size: Responsive.icon(AppSizes.iconSmall),
                            ),
                          ),
                          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                          Text(
                            'Activity Log',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium + 1),
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                      // Timeline entries
                      ...List.generate(entries.length, (index) {
                        final entry = entries[index];
                        final isLast = index == entries.length - 1;
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timeline indicator
                              Column(
                                children: [
                                  Container(
                                    width: Responsive.w(AppSizes.spacingMedium),
                                    height: Responsive.h(AppSizes.spacingMedium),
                                    decoration: BoxDecoration(
                                      color: index == 0
                                          ? AppColors.primary.withValues(alpha: 0.15)
                                          : AppColors.secondaryText.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: index == 0 ? AppColors.primary : AppColors.secondaryText.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 1.5,
                                        color: AppColors.border,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                              // Content
                              Expanded(
                                child: Padding(
                                  padding: Responsive.only(bottom: isLast ? 0 : AppSizes.spacingLarge),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.label,
                                        style: TextStyle(
                                          fontSize: Responsive.sp(AppSizes.fontSmall),
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                      SizedBox(height: Responsive.h(2)),
                                      Text(
                                        entry.value,
                                        style: TextStyle(
                                          fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      if (entry.subtitle != null) ...[
                                        SizedBox(height: Responsive.h(2)),
                                        Text(
                                          'by ${entry.subtitle}',
                                          style: TextStyle(
                                            fontSize: Responsive.sp(AppSizes.fontSmall),
                                            color: AppColors.secondaryText.withValues(alpha: 0.7),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Delete Dialog ────────────────────────────────────
  void _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        ),
        title: Row(
          children: [
            Container(
              padding: Responsive.all(AppSizes.spacingSmall),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: Responsive.icon(AppSizes.iconSmall),
              ),
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
            Text(
              'Delete Customer',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontLarge),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${customer.name}? This action cannot be undone.',
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontMedium),
            color: AppColors.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontMedium),
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontMedium),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(customerOperationsProvider).deleteCustomer(customer.id);
        if (context.mounted) {
          ref.invalidate(customersProvider);
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete customer: $e')),
          );
        }
      }
    }
  }
}

// ── Timeline Entry Model ───────────────────────────────
class _TimelineEntry {
  final String label;
  final String value;
  final String? subtitle;

  const _TimelineEntry({
    required this.label,
    required this.value,
    this.subtitle,
  });
}

// ═══════════════════════════════════════════════════════
// Image Detail Dialog (kept as-is from original)
// ═══════════════════════════════════════════════════════
class ImageDetailDialog extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ImageDetailDialog({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white,
                      size: Responsive.icon(AppSizes.iconHuge),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: Responsive.sp(AppSizes.fontMedium),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: Responsive.symmetric(
                horizontal: AppSizes.screenPaddingSmall,
                vertical: AppSizes.spacingMedium,
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.sp(AppSizes.fontLarge - 1),
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
