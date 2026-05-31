import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/views/home_view.dart';
import 'login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
    // Wait for the animation to finish
    await Future.delayed(const Duration(milliseconds: 1500));
    
    try {
      // Check if user is logged in using Supabase
      final user = Supabase.instance.client.auth.currentUser;
      
      if (mounted) {
        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeView()),
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
                  SvgPicture.asset(
                    'assets/images/logo_paris.svg',
                    width: Responsive.w(AppSizes.spacingMassive),
                    height: Responsive.w(AppSizes.spacingMassive),
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
