import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/auth_service.dart';

// Auth state
class AuthState {
  final bool isAuthenticated;
  final AuthUser? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    AuthUser? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth notifier using Riverpod 3.x pattern
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Start with loading false to allow form interaction
    // Check auth status in background
    _checkAuthStatus();
    return AuthState(isLoading: false);
  }

  Future<void> _checkAuthStatus() async {
    final authService = ref.read(authServiceProvider);
    final isAuth = authService.isAuthenticated();
    if (isAuth) {
      final user = await authService.getCurrentUser();
      state = AuthState(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );
    } else {
      state = AuthState(
        isAuthenticated: false,
        user: null,
        isLoading: false,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = AuthState(isLoading: true, error: null);

    try {
      final authService = ref.read(authServiceProvider);

      // Global 15-second timeout so the UI never hangs forever
      final user = await authService
          .login(email, password)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'Login timed out. The app could not reach the server.',
              );
            },
          );

      if (user != null) {
        state = AuthState(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
        return true;
      } else {
        state = AuthState(
          isLoading: false,
          error: 'Login failed. Please check your credentials.',
        );
        return false;
      }
    } catch (e) {
      state = AuthState(
        isLoading: false,
        error: 'Login error: $e',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = AuthState(isLoading: true);
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    state = AuthState(
      isAuthenticated: false,
      user: null,
      isLoading: false,
    );
  }
}

// Auth state provider using Riverpod 3.x pattern
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// Auth user provider for easy access to current user
final authUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider).user;
});
