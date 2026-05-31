import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthUser {
  final String id;
  final String email;
  final String role;
  final String? storeId;
  final String? branchId;
  final String? staffId;

  AuthUser({
    required this.id,
    required this.email,
    required this.role,
    this.storeId,
    this.branchId,
    this.staffId,
  });

  factory AuthUser.fromUser(User user) {
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      role: (user.userMetadata?['role'] as String?) ?? 'staff',
      storeId: user.userMetadata?['store_id'] as String?,
      branchId: user.userMetadata?['branch_id'] as String?,
      staffId: user.userMetadata?['staff_id'] as String?,
    );
  }
}

class AuthService {
  final _supabase = Supabase.instance.client;

  /// Login with email and password using Supabase
  Future<AuthUser?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return AuthUser.fromUser(response.user!);
      }
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  /// Logout the user
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// Get the current user
  Future<AuthUser?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return AuthUser.fromUser(user);
    }
    return null;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }
}

// Global instance
final authService = AuthService();
