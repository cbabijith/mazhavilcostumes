import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/theme.dart';
import 'core/utils/startup_timing.dart';
import 'features/auth/views/splash_view.dart';

void main() {
  StartupTiming.start();
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addPostFrameCallback((_) => StartupTiming.mark('first_frame'));
  // The API client restores its own session. Storage uploads initialize lazily.
  // Run the app wrapped in ProviderScope for Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashView(),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.25,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
