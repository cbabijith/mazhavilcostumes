import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../models/customer.dart';
import '../viewmodels/providers/customer_provider.dart';
import 'customer_form_view.dart';

class CustomerDetailView extends ConsumerWidget {
  final Customer customer;

  const CustomerDetailView({super.key, required this.customer});

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

  Future<void> _launchSMS(String phone) async {
    final url = Uri.parse('sms:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Responsive.init(context);

    final customerAsync = ref.watch(customerProvider(customer.id));

    return customerAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Customer Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Shimmer Header block
              Container(
                height: Responsive.h(130),
                color: Colors.white,
                padding: Responsive.all(AppSizes.spacingLarge),
                child: Row(
                  children: [
                    Container(
                      width: Responsive.w(64),
                      height: Responsive.w(64),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: Responsive.h(18),
                            width: Responsive.w(150),
                            color: Colors.white,
                          ),
                          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                          Container(
                            height: Responsive.h(14),
                            width: Responsive.w(100),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusXXLarge)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingMedium)),

              // Shimmer TabBar Pill
              Padding(
                padding: Responsive.symmetric(horizontal: AppSizes.spacingMedium),
                child: Container(
                  height: Responsive.h(45),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingMedium)),

              // Shimmer Details Card
              Expanded(
                child: Padding(
                  padding: Responsive.symmetric(horizontal: AppSizes.spacingMedium),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                    ),
                    padding: Responsive.all(AppSizes.spacingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(4, (index) {
                        return Padding(
                          padding: Responsive.symmetric(vertical: AppSizes.spacingMedium),
                          child: Row(
                            children: [
                              Container(
                                width: Responsive.w(36),
                                height: Responsive.w(36),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: Responsive.w(AppSizes.spacingLarge)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: Responsive.h(12),
                                      width: Responsive.w(100),
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                                    Container(
                                      height: Responsive.h(14),
                                      width: Responsive.w(180),
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Customer Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error', style: const TextStyle(color: AppColors.error)),
              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
              ElevatedButton(
                onPressed: () => ref.invalidate(customerProvider(customer.id)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (liveCustomer) {
        IdDocument? frontDoc;
        IdDocument? backDoc;
        final docs = liveCustomer.idDocuments;
        if (docs != null) {
          for (final doc in docs) {
            if (doc.type == 'front') {
              frontDoc = doc;
            } else if (doc.type == 'back') {
              backDoc = doc;
            }
          }
        }

        final hasId = liveCustomer.idType != null && liveCustomer.idNumber != null && liveCustomer.idNumber!.isNotEmpty;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Customer Details',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.edit_rounded, size: Responsive.icon(AppSizes.iconMedium), color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerFormView(customer: liveCustomer),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_rounded, size: Responsive.icon(AppSizes.iconMedium), color: Colors.white),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Customer'),
                        content: Text('Are you sure you want to delete ${liveCustomer.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      try {
                        await ref.read(customerOperationsProvider).deleteCustomer(liveCustomer.id);
                        if (context.mounted) {
                          ref.invalidate(customersProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Customer deleted successfully!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Premium Header Banner block
                _buildHeaderBlock(context, liveCustomer, hasId),

                // 2. Custom Pill styled TabBar
                _buildTabBar(),

                // 3. Tab content
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1: Profile Contact Details
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: Responsive.symmetric(horizontal: AppSizes.spacingMedium),
                        child: Column(
                          children: [
                            _buildContactCard(liveCustomer),
                            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                            _buildAuditFootnote(liveCustomer),
                            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                          ],
                        ),
                      ),

                      // Tab 2: Identity Documents Verification
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: Responsive.symmetric(horizontal: AppSizes.spacingMedium),
                        child: Column(
                          children: [
                            _buildIdentityCard(context, liveCustomer, hasId, frontDoc, backDoc),
                            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                            _buildAuditFootnote(liveCustomer),
                            SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderBlock(BuildContext context, Customer customer, bool hasId) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(Responsive.r(AppSizes.radiusLarge)),
        ),
      ),
      child: Padding(
        padding: Responsive.all(AppSizes.spacingLarge),
        child: Column(
          children: [
            Row(
              children: [
                // White-bordered Avatar
                Container(
                  padding: Responsive.all(AppSizes.spacingTiny - 1),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Container(
                    width: Responsive.w(64),
                    height: Responsive.w(64),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.08),
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
                ),
                SizedBox(width: Responsive.w(AppSizes.spacingMedium)),

                // Name and Verification Pill
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontLarge + 2),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                      Container(
                        padding: Responsive.symmetric(
                          horizontal: AppSizes.spacingMedium,
                          vertical: AppSizes.spacingTiny / 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusXXLarge)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasId ? Icons.verified_user_rounded : Icons.pending_actions_rounded,
                              size: Responsive.icon(AppSizes.iconTiny + 2),
                              color: Colors.white,
                            ),
                            SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                            Text(
                              hasId ? 'Verified Profile' : 'Verification Missing',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontTiny),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            Container(color: Colors.white24, height: 1),
            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),

            // Interactive action triggers
            Row(
              children: [
                Expanded(
                  child: Text(
                    customer.phone,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontMedium + 1),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildCompactActionBtn(
                      icon: Icons.phone_rounded,
                      color: Colors.white,
                      iconColor: AppColors.primary,
                      onTap: () => _launchCall(customer.phone),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                    _buildCompactActionBtn(
                      icon: Icons.chat_rounded,
                      color: Colors.white,
                      iconColor: const Color(0xFF25D366),
                      onTap: () => _launchWhatsApp(customer.phone),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                    _buildCompactActionBtn(
                      icon: Icons.textsms_rounded,
                      color: Colors.white,
                      iconColor: const Color(0xFF26C6DA),
                      onTap: () => _launchSMS(customer.phone),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActionBtn({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusXXLarge)),
      child: Container(
        padding: Responsive.all(AppSizes.spacingSmall + 1),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: Responsive.icon(AppSizes.iconSmall),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: Responsive.symmetric(
        horizontal: AppSizes.spacingMedium,
        vertical: AppSizes.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: Responsive.r(8),
            offset: Offset(0, Responsive.h(2)),
          ),
        ],
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium - 1)),
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.secondaryText,
        labelStyle: TextStyle(
          fontSize: Responsive.sp(AppSizes.fontMedium),
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: Responsive.sp(AppSizes.fontMedium),
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Contact Info'),
          Tab(text: 'Identity Docs'),
        ],
      ),
    );
  }

  Widget _buildContactCard(Customer customer) {
    return Card(
      elevation: AppSizes.spacingTiny / 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
      ),
      child: Padding(
        padding: Responsive.all(AppSizes.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Phone Number',
              customer.phone,
              Icons.phone_rounded,
              iconColor: AppColors.success,
              iconBgColor: AppColors.success.withValues(alpha: 0.08),
              onTap: () => _launchCall(customer.phone),
            ),
            if (customer.altPhone != null && customer.altPhone!.isNotEmpty) ...[
              _buildDivider(),
              _buildDetailRow(
                'Alt Phone Number',
                customer.altPhone!,
                Icons.phone_android_rounded,
                iconColor: AppColors.info,
                iconBgColor: AppColors.info.withValues(alpha: 0.08),
                onTap: () => _launchCall(customer.altPhone!),
              ),
            ],
            _buildDivider(),
            _buildDetailRow(
              'Email Address',
              customer.email ?? 'Not provided',
              Icons.email_rounded,
              iconColor: AppColors.warning,
              iconBgColor: AppColors.warning.withValues(alpha: 0.08),
              isMuted: customer.email == null,
              onTap: customer.email != null ? () => _launchEmail(customer.email!) : null,
            ),
            _buildDivider(),
            _buildDetailRow(
              'Home Address',
              customer.address ?? 'Not provided',
              Icons.map_rounded,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primary.withValues(alpha: 0.08),
              isMuted: customer.address == null,
            ),
            if (customer.gstin != null && customer.gstin!.isNotEmpty) ...[
              _buildDivider(),
              _buildDetailRow(
                'GSTIN Number',
                customer.gstin!,
                Icons.receipt_long_rounded,
                iconColor: AppColors.secondaryText,
                iconBgColor: AppColors.secondaryText.withValues(alpha: 0.08),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard(
    BuildContext context,
    Customer customer,
    bool hasId,
    IdDocument? frontDoc,
    IdDocument? backDoc,
  ) {
    return Card(
      elevation: AppSizes.spacingTiny / 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
      ),
      child: Padding(
        padding: Responsive.all(AppSizes.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Verification ID Type',
              customer.idType != null ? _idTypeToString(customer.idType!) : 'Not provided',
              Icons.credit_card_rounded,
              iconColor: AppColors.info,
              iconBgColor: AppColors.info.withValues(alpha: 0.08),
              isMuted: customer.idType == null,
            ),
            _buildDivider(),
            _buildDetailRow(
              'Verification ID Number',
              customer.idNumber ?? 'Not provided',
              Icons.badge_rounded,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primary.withValues(alpha: 0.08),
              isMuted: customer.idNumber == null,
            ),
            if (frontDoc != null || backDoc != null) ...[
              _buildDivider(),
              SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
              Text(
                'Document Scans',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
              Row(
                children: [
                  if (frontDoc != null)
                    Expanded(
                      child: _buildDocPreviewCard(context, 'Front Scan', frontDoc.url),
                    ),
                  if (frontDoc != null && backDoc != null)
                    SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                  if (backDoc != null)
                    Expanded(
                      child: _buildDocPreviewCard(context, 'Back Scan', backDoc.url),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDocPreviewCard(BuildContext context, String label, String url) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, url, label),
      child: Container(
        height: Responsive.h(110),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall + 2)),
          border: Border.all(
            color: AppColors.border,
            width: AppSizes.spacingTiny / 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: Responsive.r(4),
              offset: Offset(0, Responsive.h(2)),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall + 1)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: AppColors.shimmerBase,
                  highlightColor: AppColors.shimmerHighlight,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[100],
                  child: Icon(Icons.broken_image_rounded, color: AppColors.secondaryText),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black54,
                  padding: Responsive.symmetric(vertical: AppSizes.spacingTiny),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.sp(AppSizes.fontTiny),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: Responsive.h(AppSizes.spacingTiny),
                right: Responsive.w(AppSizes.spacingTiny),
                child: Container(
                  padding: Responsive.all(AppSizes.spacingTiny / 2),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fullscreen_rounded,
                    size: Responsive.icon(AppSizes.iconTiny + 2),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSizes.spacingMedium,
              left: AppSizes.spacingMedium,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSizes.spacingMedium + 8,
              right: AppSizes.spacingMedium + 8,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.sp(AppSizes.fontLarge),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    required Color iconColor,
    required Color iconBgColor,
    bool isMuted = false,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: Responsive.symmetric(vertical: AppSizes.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: Responsive.all(AppSizes.spacingMedium - 1),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: Responsive.icon(AppSizes.iconMedium - 4),
              color: iconColor,
            ),
          ),
          SizedBox(width: Responsive.w(AppSizes.spacingLarge)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: Responsive.sp(AppSizes.fontMedium),
                    fontWeight: FontWeight.bold,
                    color: isMuted ? AppColors.secondaryText : AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              size: Responsive.icon(AppSizes.iconSmall),
              color: AppColors.secondaryText.withValues(alpha: 0.5),
            ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        child: content,
      );
    }
    return content;
  }

  Widget _buildDivider() {
    return Padding(
      padding: Responsive.symmetric(vertical: AppSizes.spacingSmall / 2),
      child: Divider(color: AppColors.border, height: 1),
    );
  }

  Widget _buildAuditFootnote(Customer customer) {
    final created = _formatDate(customer.createdAt);
    final updated = _formatDate(customer.updatedAt);
    return Padding(
      padding: Responsive.symmetric(vertical: AppSizes.spacingSmall),
      child: Center(
        child: Text(
          'Created: $created  •  Last Updated: $updated',
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontTiny + 1),
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
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
          fontSize: Responsive.sp(AppSizes.fontXXLarge),
        ),
      ),
    );
  }

  String _idTypeToString(IdType type) {
    switch (type) {
      case IdType.aadhaar:
        return 'Aadhaar Card';
      case IdType.pan:
        return 'PAN Card';
      case IdType.drivingLicence:
        return 'Driving Licence';
      case IdType.passport:
        return 'Passport';
      case IdType.others:
        return 'Others';
    }
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
