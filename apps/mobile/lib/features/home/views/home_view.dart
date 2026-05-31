import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/viewmodels/auth_provider.dart' as core_auth;
import '../../auth/viewmodels/providers/auth_provider.dart';
import '../../dashboard/views/dashboard_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const _OrdersPage(),
    const _ProductsPage(),
    const _ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: Responsive.r(AppSizes.radiusLarge),
                offset: Offset(0, -Responsive.h(AppSizes.spacingTiny)),
              ),
            ],
          ),
          child: Padding(
            padding: Responsive.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard_outlined, 'Dashboard', 0),
                _buildNavItem(Icons.receipt_long_outlined, 'Orders', 1),
                _buildNavItem(Icons.inventory_2_outlined, 'Products', 2),
                _buildNavItem(Icons.person_outline, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: Responsive.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.secondaryText,
              size: Responsive.icon(AppSizes.iconMedium),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontTiny),
                color: isSelected ? AppColors.primary : AppColors.secondaryText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersPage extends StatelessWidget {
  const _OrdersPage();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: Responsive.icon(AppSizes.iconXXLarge), color: AppColors.secondaryText),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          Text(
            'Orders',
            style: TextStyle(fontSize: Responsive.sp(AppSizes.fontXXLarge), color: AppColors.text, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ProductsPage extends StatelessWidget {
  const _ProductsPage();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: Responsive.icon(AppSizes.iconXXLarge), color: AppColors.secondaryText),
          SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
          Text(
            'Products',
            style: TextStyle(fontSize: Responsive.sp(AppSizes.fontXXLarge), color: AppColors.text, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ProfilePage extends ConsumerWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Responsive.init(context);
    final user = ref.watch(authUserProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: DashboardConstants.gradientTopLeftOpacity),
              AppColors.primary.withValues(alpha: DashboardConstants.gradientMidOpacity),
              AppColors.primary.withValues(alpha: DashboardConstants.gradientBottomOpacity),
              Colors.white,
            ],
            stops: const [0.0, 0.2, 0.5, 1.0],
          ),
        ),
        child: CustomPaint(
          painter: MeshGradientPainter(AppColors.primary),
          child: Column(
            children: [
              AppBar(
                title: const Text('Profile'),
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.text,
                elevation: 0,
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: Responsive.all(AppSizes.screenPaddingLarge),
                    child: Column(
                      children: [
                        SizedBox(height: Responsive.h(AppSizes.spacingXXXLarge)),
                        CircleAvatar(
                          radius: Responsive.r(AppSizes.radiusXXLarge),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.person, size: Responsive.icon(AppSizes.iconXXLarge), color: AppColors.primary),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),
                        Text(
                          user?.name ?? 'User',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontXXLarge),
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                        Text(
                          user?.email ?? 'user@example.com',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontLarge),
                            color: AppColors.secondaryText,
                          ),
                        ),
                        SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                        Text(
                          user?.roleLabel ?? 'Staff',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontMedium),
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        AppButton(
                          text: 'Logout',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Logout'),
                                content: const Text('Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await ref.read(core_auth.authProvider.notifier).logout();
                                      if (context.mounted) {
                                        Navigator.of(context).pushReplacementNamed('/');
                                      }
                                    },
                                    child: const Text('Logout', style: TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icons.logout,
                          backgroundColor: AppColors.error,
                          size: ButtonSize.large,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MeshGradientPainter extends CustomPainter {
  final Color baseColor;

  MeshGradientPainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = baseColor.withValues(alpha: DashboardConstants.meshPaintOpacity);

    // Draw mesh-like pattern
    final path = Path();
    final gridSize = DashboardConstants.meshGridSize;
    
    for (double y = 0; y < size.height; y += gridSize) {
      for (double x = 0; x < size.width; x += gridSize) {
        // Create subtle wave pattern
        final offsetX = x + (y % (gridSize * 2) == 0 ? 0 : gridSize / 2);
        final offsetY = y;
        
        // Draw diamond shapes
        path.moveTo(offsetX + gridSize / 2, offsetY);
        path.lineTo(offsetX + gridSize, offsetY + gridSize / 2);
        path.lineTo(offsetX + gridSize / 2, offsetY + gridSize);
        path.lineTo(offsetX, offsetY + gridSize / 2);
        path.close();
      }
    }
    
    canvas.drawPath(path, paint);

    // Add subtle dots
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = baseColor.withValues(alpha: DashboardConstants.meshDotPaintOpacity);

    for (double y = 0; y < size.height; y += gridSize * 2) {
      for (double x = 0; x < size.width; x += gridSize * 2) {
        canvas.drawCircle(Offset(x, y), DashboardConstants.meshDotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
