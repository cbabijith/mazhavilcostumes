import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/viewmodels/auth_provider.dart' as core_auth;
import '../features/auth/viewmodels/providers/auth_provider.dart';
import '../features/auth/views/login_view.dart';
import '../features/products/views/products_view.dart';
import '../features/dashboard/views/dashboard_view.dart';
import '../features/orders/views/orders_view.dart';
import '../features/calendar/views/calendar_view.dart';
import '../features/categories/views/categories_view.dart';
import '../features/branches/models/branch.dart';
import '../features/branches/viewmodels/providers/branch_provider.dart';
import '../features/branches/views/branches_view.dart';
import '../features/customers/views/customers_view.dart';
import 'utils/responsive.dart';
import 'constants/app_constants.dart';
import 'providers/navigation_provider.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Consumer(
      builder: (context, ref, _) {
        final user = ref.watch(authUserProvider);
        final branchesAsync = ref.watch(branchesProvider);
        final selectedIndex = ref.watch(navigationTabProvider);
        return Scaffold(
          key: _scaffoldKey,
          appBar: _buildAppBar(ref, user, branchesAsync, selectedIndex),
          drawer: _buildDrawer(context, user, ref, selectedIndex),
          body: _buildBody(selectedIndex),
          bottomNavigationBar: _buildBottomNav(ref, selectedIndex),
        );
      },
    );
  }

  // ── App Bar ──
  PreferredSizeWidget _buildAppBar(WidgetRef ref, AuthUser? user, AsyncValue<List<Branch>> branchesAsync, int selectedIndex) {
    if (selectedIndex == 0) {
      return AppBar(
        backgroundColor: AppColors.primary,
        titleSpacing: 0,
        toolbarHeight: Responsive.h(60),
        leading: GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Padding(
            padding: Responsive.only(left: 16),
            child: Center(
              child: Container(
                width: Responsive.icon(32),
                height: Responsive.icon(32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/mazhavil.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          AppStrings.appName.toUpperCase(),
          style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.white),
        ),
        actions: [
          _buildBranchSwitcher(ref, user, branchesAsync),
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, size: Responsive.icon(24), color: Colors.white),
            onPressed: () {},
          ),
          SizedBox(width: Responsive.w(4)),
        ],
      );
    }

    final titles = ['', 'Orders', 'Calendar', 'Products'];
    return AppBar(
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      toolbarHeight: Responsive.h(60),
      leading: GestureDetector(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        child: Padding(
          padding: Responsive.only(left: 16),
          child: Center(
            child: Container(
              width: Responsive.icon(32),
              height: Responsive.icon(32),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/mazhavil.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      title: Text(titles[selectedIndex], style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.w700, color: Colors.white)),
      actions: [
        _buildBranchSwitcher(ref, user, branchesAsync),
        SizedBox(width: Responsive.w(8)),
      ],
    );
  }

  // ── Drawer / Sidebar ──
  Widget _buildDrawer(BuildContext context, AuthUser? user, WidgetRef ref, int selectedIndex) {
    final isAdmin = user?.isAdmin ?? false;
    final canManage = user?.canManage ?? false;

    return Drawer(
      width: Responsive.w(300),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: Responsive.only(left: 24, right: 24, top: 32, bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: Responsive.icon(48),
                    height: Responsive.icon(48),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/mazhavil.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: Responsive.h(16)),
                  Text(
                    user?.name ?? 'User',
                    style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(fontSize: Responsive.sp(13), color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  SizedBox(height: Responsive.h(8)),
                  Container(
                    padding: Responsive.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(Responsive.r(20)),
                    ),
                    child: Text(
                      user?.roleLabel ?? 'STAFF',
                      style: TextStyle(fontSize: Responsive.sp(10), fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: Responsive.symmetric(vertical: 12),
                children: [
                  // Admin-only menu items
                  if (isAdmin) ...[
                    _buildDrawerSectionLabel('Management'),
                    _buildDrawerItem(ref, Icons.dashboard_rounded, 'Dashboard', 0, selectedIndex),
                    _buildDrawerItem(ref, Icons.account_tree_rounded, 'Categories', null, selectedIndex, onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CategoriesView()),
                      );
                    }),
                    _buildDrawerItem(ref, Icons.inventory_2_rounded, 'Products', 3, selectedIndex),
                    _buildDrawerItem(ref, Icons.receipt_long_rounded, 'Orders', 1, selectedIndex),
                    _buildDrawerItem(ref, Icons.calendar_month_rounded, 'Calendar', 2, selectedIndex),
                    Padding(
                      padding: Responsive.symmetric(horizontal: 24),
                      child: Divider(height: Responsive.h(24), color: Colors.grey[200]),
                    ),
                    _buildDrawerSectionLabel('Management'),
                    _buildDrawerItem(ref, Icons.storefront_rounded, 'Branches', null, selectedIndex, onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BranchesView()),
                      );
                    }),
                    _buildDrawerItem(ref, Icons.people_rounded, 'Customers', null, selectedIndex, onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CustomersView()),
                      );
                    }),
                  ] else if (canManage) ...[
                    // Manager sees nav items but no settings
                    _buildDrawerSectionLabel('Navigation'),
                    _buildDrawerItem(ref, Icons.dashboard_rounded, 'Dashboard', 0, selectedIndex),
                    _buildDrawerItem(ref, Icons.account_tree_rounded, 'Categories', null, selectedIndex, onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CategoriesView()),
                      );
                    }),
                    _buildDrawerItem(ref, Icons.inventory_2_rounded, 'Products', 3, selectedIndex),
                    _buildDrawerItem(ref, Icons.receipt_long_rounded, 'Orders', 1, selectedIndex),
                    _buildDrawerItem(ref, Icons.calendar_month_rounded, 'Calendar', 2, selectedIndex),
                    Padding(
                      padding: Responsive.symmetric(horizontal: 24),
                      child: Divider(height: Responsive.h(24), color: Colors.grey[200]),
                    ),
                    _buildDrawerSectionLabel('Management'),
                    _buildDrawerItem(ref, Icons.storefront_rounded, 'Branches', null, selectedIndex, onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BranchesView()),
                      );
                    }),
                    _buildDrawerItem(ref, Icons.people_rounded, 'Customers', null, selectedIndex, onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CustomersView()),
                      );
                    }),
                  ] else ...[
                    // Staff sees minimal menu
                    _buildDrawerSectionLabel('Navigation'),
                    _buildDrawerItem(ref, Icons.dashboard_rounded, 'Dashboard', 0, selectedIndex),
                    _buildDrawerItem(ref, Icons.receipt_long_rounded, 'Orders', 1, selectedIndex),
                  ],
                ],
              ),
            ),

            // Logout at bottom
            Padding(
              padding: Responsive.only(left: 16, right: 16, bottom: 16),
              child: SizedBox(
                width: double.infinity,
                height: Responsive.h(52),
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, ref),
                  icon: Icon(Icons.logout_rounded, size: Responsive.icon(20)),
                  label: Text('Log Out', style: TextStyle(fontSize: Responsive.sp(15), fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B8A),
                    side: const BorderSide(color: Color(0xFFFF6B8A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(12))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSectionLabel(String label) {
    return Padding(
      padding: Responsive.only(left: 24, top: 8, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: Responsive.sp(11), fontWeight: FontWeight.w700, color: Colors.grey[400], letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildDrawerItem(WidgetRef ref, IconData icon, String label, int? tabIndex, int selectedIndex, {VoidCallback? onTap}) {
    final isSelected = tabIndex != null && selectedIndex == tabIndex;

    return Padding(
      padding: Responsive.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(Responsive.r(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(Responsive.r(12)),
          onTap: () {
            if (onTap != null) {
              onTap();
            } else if (tabIndex != null) {
              ref.read(navigationTabProvider.notifier).setTab(tabIndex);
              Navigator.pop(context);
            }
          },
          child: Padding(
            padding: Responsive.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: Responsive.icon(22), color: isSelected ? AppColors.primary : Colors.grey[600]),
                SizedBox(width: Responsive.w(16)),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Responsive.sp(15),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : Colors.grey[800],
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Container(
                    width: Responsive.w(6), height: Responsive.h(6),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(16))),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, size: Responsive.icon(24), color: const Color(0xFFFF6B8A)),
            SizedBox(width: Responsive.w(10)),
            Text('Log Out', style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to log out of ${AppStrings.appName}?',
          style: TextStyle(fontSize: Responsive.sp(14), height: 1.5),
        ),
        actionsPadding: Responsive.only(left: 16, right: 16, bottom: 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: Responsive.h(46),
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(10))),
                    ),
                    child: Text('Cancel', style: TextStyle(fontSize: Responsive.sp(14))),
                  ),
                ),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: SizedBox(
                  height: Responsive.h(46),
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(core_auth.authProvider.notifier).logout();
                      ref.read(selectedBranchIdProvider.notifier).select(null);
                      
                      if (!context.mounted || !ctx.mounted) return;
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginView()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B8A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(10))),
                    ),
                    child: Text('Log Out', style: TextStyle(fontSize: Responsive.sp(14), fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Branch Switcher ──
  Widget _buildBranchSwitcher(WidgetRef ref, AuthUser? user, AsyncValue<List<Branch>> branchesAsync) {
    if (user?.canSwitchBranches != true) {
      return const SizedBox.shrink();
    }

    final selectedBranchId = ref.watch(selectedBranchIdProvider);

    return branchesAsync.when(
      loading: () => Padding(
        padding: Responsive.symmetric(horizontal: 12),
        child: SizedBox(
          width: Responsive.icon(18),
          height: Responsive.icon(18),
          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
      error: (error, stackTrace) => IconButton(
        tooltip: 'Reload branches',
        icon: Icon(Icons.storefront_rounded, size: Responsive.icon(20), color: Colors.white),
        onPressed: () => ref.invalidate(branchesProvider),
      ),
      data: (branches) {
        final activeBranches = branches.where((branch) => branch.isActive).toList();
        
        // Auto-select first branch if none selected
        if (selectedBranchId == null && activeBranches.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedBranchIdProvider.notifier).select(activeBranches.first.id);
          });
        }
        
        Branch? selectedBranch;
        for (final branch in activeBranches) {
          if (branch.id == selectedBranchId) {
            selectedBranch = branch;
            break;
          }
        }

        final label = selectedBranch?.name ?? (activeBranches.isNotEmpty ? activeBranches.first.name : 'No Branch');

        return PopupMenuButton<String>(
          onSelected: (String branchId) {
            ref.read(selectedBranchIdProvider.notifier).select(branchId);
          },
          offset: Offset(0, Responsive.h(50)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(14))),
          itemBuilder: (BuildContext context) {
            return activeBranches.map((branch) => _buildBranchMenuItem(branch.id, branch.name, selectedBranchId == branch.id)).toList();
          },
          child: Container(
            padding: Responsive.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Responsive.r(20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.storefront_rounded, size: Responsive.icon(14), color: Colors.white),
                SizedBox(width: Responsive.w(6)),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: Responsive.w(92)),
                  child: Text(
                    label,
                    style: TextStyle(fontSize: Responsive.sp(11), fontWeight: FontWeight.w600, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded, size: Responsive.icon(18), color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _buildBranchMenuItem(String value, String label, bool isSelected) {
    return PopupMenuItem<String>(
      value: value,
      height: Responsive.h(48),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            size: Responsive.icon(18),
            color: isSelected ? AppColors.primary : Colors.grey,
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(14),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav ──
  Widget _buildBottomNav(WidgetRef ref, int selectedIndex) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: Responsive.r(16),
              offset: Offset(0, -Responsive.h(4)),
            ),
          ],
        ),
        child: Padding(
          padding: Responsive.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCustomNavItem(ref, Icons.home_outlined, Icons.home_rounded, 'Home', 0, selectedIndex),
              _buildCustomNavItem(ref, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Orders', 1, selectedIndex),
              _buildCustomNavItem(ref, Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Calendar', 2, selectedIndex),
              _buildCustomNavItem(ref, Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Products', 3, selectedIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavItem(WidgetRef ref, IconData icon, IconData activeIcon, String label, int index, int selectedIndex) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => ref.read(navigationTabProvider.notifier).setTab(index),
      child: Container(
        padding: Responsive.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(Responsive.r(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : Colors.grey[500],
              size: Responsive.icon(22),
            ),
            SizedBox(height: Responsive.h(4)),
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(10),
                color: isSelected ? AppColors.primary : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body ──
  Widget _buildBody(int selectedIndex) {
    switch (selectedIndex) {
      case 0: return const DashboardView();
      case 1: return const OrdersView();
      case 2: return const CalendarView();
      case 3: return const ProductsView();
      default: return const DashboardView();
    }
  }
}
