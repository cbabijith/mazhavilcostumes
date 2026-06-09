import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/main_layout.dart';
import '../viewmodels/auth_provider.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } else if (mounted) {
      final errorMsg = ref.read(authProvider).error ?? AppStrings.invalidCredentials;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SelectableText(errorMsg),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Copy',
            textColor: Colors.white,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: errorMsg));
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    Responsive.init(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: Responsive.symmetric(horizontal: AppSizes.screenPaddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: Responsive.h(AppSizes.spacingHuge)),
                  
                  // Logo
                  Center(
                    child: Container(
                      padding: Responsive.all(AppSizes.spacingXLarge),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        'assets/images/logo_paris.svg',
                        width: Responsive.icon(AppSizes.iconHuge),
                        height: Responsive.icon(AppSizes.iconHuge),
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingXXXLarge)),

                  // Title
                  Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontHuge),
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                  Text(
                    AppStrings.adminDashboard,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontLarge),
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingHuge)),

                  // Email Field
                  AppTextField(
                    controller: _emailController,
                    labelText: AppStrings.email,
                    hintText: AppStrings.enterYourEmail,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.pleaseEnterYourEmail;
                      }
                      if (!value.contains('@')) {
                        return AppStrings.pleaseEnterAValidEmail;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  
                  // Password Field
                  AppTextField(
                    controller: _passwordController,
                    labelText: AppStrings.password,
                    hintText: AppStrings.enterYourPassword,
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: Responsive.icon(AppSizes.iconSmall),
                        color: AppColors.secondaryText,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.pleaseEnterYourPassword;
                      }
                      if (value.length < 6) {
                        return AppStrings.passwordMustBeAtLeast6Characters;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),

                  // Login Button
                  AppButton(
                    text: AppStrings.signIn,
                    onPressed: authState.isLoading ? null : _handleLogin,
                    isLoading: authState.isLoading,
                    size: ButtonSize.large,
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingMassive)),
                  
                  // Footer
                  Text(
                    AppStrings.copyright,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Responsive.sp(AppSizes.fontTiny),
                      color: AppColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
