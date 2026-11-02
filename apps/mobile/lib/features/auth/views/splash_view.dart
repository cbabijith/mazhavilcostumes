import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/main_layout.dart';
import '../viewmodels/auth_provider.dart';
import 'login_view.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.splashAnimation,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isAuth = await ref.read(authProvider.notifier).restoreSession();
      
      if (mounted) {
        if (isAuth) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginView()),
          );
        }
      }
    } catch (e) {
      // If anything goes wrong, navigate to login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginView()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: Responsive.w(120),
                    height: Responsive.w(120),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/mazhavil.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),
                  Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontXXLarge),
                      fontWeight: FontWeight.w800,
                      letterSpacing: Responsive.w(AppSizes.spacingSmall),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                  Text(
                    AppStrings.adminDashboard,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontSmall),
                      fontWeight: FontWeight.w400,
                      letterSpacing: Responsive.w(AppSizes.spacingSmall),
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
